-- Generate jewel ore.

-- Jewel ore generated in birch tree nodes in the giga tree decorations
-- in the Deep Forest biome.
-- The algorithm uses LVM to imitate Minetest's scatter ores,
-- since ores in Minetest are generated after decorations.

-- Fields of the original ore definition:
local clust_scarcity = 11*11*11
local clust_num_ores = 3
local clust_size = 6
local y_min = 0

-- Helper variables
local gigatree_decoration_id = minetest.get_decoration_id("rp_default:gigatree")
local biome_y
local biome_exists
if minetest.registered_biomes["Deep Forest"] then
   biome_y = minetest.registered_biomes["Deep Forest"].y_min
   biome_exists = true
else
   biome_y = tonumber(minetest.get_mapgen_setting("water_level")) or 1
   biome_exists = false
end

local lvm_buffer = {}

local c_birch = minetest.get_content_id("rp_default:tree_birch")
local c_jewel_ore = minetest.get_content_id("rp_jewels:jewel_ore")

-- Generation algorithm:
do

	-- Helper function to find a random minimum/maxium range of length clust_size.
	-- Returned numbers are offsets.
	local rnd_minmax = function(pr)
		local min = pr:next(- clust_size + 1, 0)
		local max = min + (clust_size - 1)
		return min, max
	end

	minetest.set_gen_notify({decoration=true}, {gigatree_decoration_id})
	minetest.register_on_generated(function(minp, maxp, blockseed)
		if maxp.y < y_min then
			return
		end
		local ores_in_mapblock = {}
		local pr = PseudoRandom(blockseed)
		local deco_ok = true
		if gigatree_decoration_id then
			-- Was a giga tree was found anywhere in generated area?
			local mgobj = minetest.get_mapgen_object("gennotify")
			local deco = mgobj["decoration#"..gigatree_decoration_id]
			deco_ok = deco and #deco > 0
		end
		if deco_ok then
			-- This code tries to imitate scatter ores in Minetest
			local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
			local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
			local data = vm:get_data(lvm_buffer)
			-- Interate through all nodes and place jewel ore in birch tree nodes
			-- with a low chance (1/clust_scarcity)
			for z=minp.z, maxp.z do
			for y=math.max(y_min, minp.y), maxp.y do
			for x=minp.x, maxp.x do
				local p_pos = area:index(x,y,z)
				if data[p_pos] == c_birch then
					local bdata, bname
					if biome_exists then
						bdata = minetest.get_biome_data({x=x,y=math.max(y, biome_y),z=z})
						bname = minetest.get_biome_name(bdata.biome)
					end
					if ((not biome_exists) or (bname == "Deep Forest")) and pr:next(1, clust_scarcity) == 1 then
						data[p_pos] = c_jewel_ore
						table.insert(ores_in_mapblock, {x=x,y=y,z=z})
					end
				end
			end
			end
			end
			-- If jewel ore was placed in the first phase, also place additional near the initial ore
			for o=1, #ores_in_mapblock do
				local start_ore = ores_in_mapblock[o]
				for n=1, clust_num_ores do
					local ore = {}
					local axes = {"z","y","x"}
					for a=1, #axes do
						local ax = axes[a]
						-- New ores are placed within a randomly positioned bounding box
						-- of size clust_size^3 around the initial ore
						ore[ax] = start_ore[ax] + pr:next(rnd_minmax(pr))
						-- Make sure we stay within minp, maxp
						if ore[ax] < minp[ax] then
							ore[ax] = minp[ax]
						elseif ore[ax] > maxp[ax] then
							ore[ax] = maxp[ax]
						end
					end
					local p_pos = area:index(ore.x, ore.y, ore.z)
					-- The new random pos must also be a birch tree to generate a jewel ore
					if data[p_pos] == c_birch then
						data[p_pos] = c_jewel_ore
					end
				end
			end
			-- Only write back to map when any ore was actually placed
			if #ores_in_mapblock > 0 then
				vm:set_data(data)
				vm:write_to_map()
			end
		end
	end)
end
