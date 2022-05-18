
--
-- Mapgen
--

-- Uncomment this to cut a big portion of ground out for visualizing ore spawning

--[[
local function on_generated(minp, maxp, blockseed)
   for x = minp.x, maxp.x do
      if x > 0 then
         return
      end

      for z = minp.z, maxp.z do
         if z > -16 and z < 16 then
            for y = minp.y, maxp.y do
               minetest.remove_node({x = x, y = y, z = z})
            end
         end
      end
   end
end

minetest.register_on_generated(on_generated)
--]]

default.UNDERGROUND_Y_MAX = -200
default.ORCHARD_Y_MIN = 20
default.SWAMP_Y_MAX = 7
default.SWAMP_HIGH_Y_MAX = 24
default.GLOBAL_Y_MAX = 31000
default.GLOBAL_Y_MIN = -31000


-- Aliases for map generator outputs

minetest.register_alias("mapgen_stone", "rp_default:stone")
minetest.register_alias("mapgen_desert_stone", "rp_default:sandstone")
minetest.register_alias("mapgen_desert_sand", "rp_default:sand")
minetest.register_alias("mapgen_sandstone", "rp_default:sandstone")
minetest.register_alias("mapgen_sandstonebrick", "rp_default:compressed_sandstone")
minetest.register_alias("mapgen_cobble", "rp_default:cobble")
minetest.register_alias("mapgen_gravel", "rp_default:gravel")
minetest.register_alias("mapgen_mossycobble", "rp_default:cobble")
minetest.register_alias("mapgen_dirt", "rp_default:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_sand", "rp_default:sand")
minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_snowblock", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_ice", "rp_default:water_source")
minetest.register_alias("mapgen_tree", "rp_default:tree")
minetest.register_alias("mapgen_leaves", "rp_default:leaves")
minetest.register_alias("mapgen_apple", "rp_default:apple")
minetest.register_alias("mapgen_jungletree", "rp_default:tree_birch")
minetest.register_alias("mapgen_jungleleaves", "rp_default:leaves_birch")
minetest.register_alias("mapgen_junglegrass", "rp_default:tall_grass")
minetest.register_alias("mapgen_pine_tree", "rp_default:tree_oak")
minetest.register_alias("mapgen_pine_needles", "rp_default:leaves_oak")

minetest.register_alias("mapgen_water_source", "rp_default:water_source")
minetest.register_alias("mapgen_river_water_source", "rp_default:river_water_source")

minetest.register_alias("mapgen_lava_source", "rp_default:water_source")


local biomes_list

-- Wrapper around minetest.register_decoration, but register decoration only
-- if biome exists.
-- The biomes table (if present) MUST be a list of biome
-- names. Biome IDs or biome definitions are not permitted.
default.register_decoration = function(def)
	-- Check if at least one of the bioms in the biomes table exists
	local ok = false
	if def.biomes then
		for b=1, #def.biomes do
			local biome = def.biomes[b]
			if minetest.registered_biomes[biome] then
				ok = true
				break
			end
		end
	else
		-- If no biomes table exists, using the decoration everywhere is intentional
		ok = true
	end
	if ok then
		minetest.register_decoration(def)
	end
end

-- Wrapper around minetest.register_ore, but register ore only
-- if biome exists.
-- The biomes table (if present) MUST be a list of biome
-- names. Biome IDs or biome definitions are not permitted.
default.register_ore = function(def)
	-- Check if at least one of the bioms in the biomes table exists
	local ok = false
	if def.biomes then
		for b=1, #def.biomes do
			local biome = def.biomes[b]
			if minetest.registered_biomes[biome] then
				ok = true
				break
			end
		end
	else
		-- If no biomes table exists, using the ore everywhere is intentional
		ok = true
	end
	if ok then
		minetest.register_ore(def)
	end
end

