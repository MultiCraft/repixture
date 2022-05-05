local water_level = tonumber(minetest.get_mapgen_setting("water_level"))
local S = minetest.get_translator("rp_default")

-- If a sapling fails to grow, check the sapling again after this many seconds
local SAPLING_RECHECK_TIME_MIN = 60
local SAPLING_RECHECK_TIME_MAX = 70

--
-- Functions/ABMs
--

-- Chest naming via signs

function default.write_name(pos, text)
-- TODO: Allow container naming later
--[[
   -- Check above, if allowed

   if minetest.settings:get_bool("signs_allow_name_above") then
      local above = {x = pos.x, y = pos.y + 1, z = pos.z}

      local abovedef = nil

      if minetest.registered_nodes[minetest.get_node(above).name] then
	 abovedef = minetest.registered_nodes[minetest.get_node(above).name]
      end
      if abovedef and abovedef.write_name ~= nil then
	 abovedef.write_name(above, text)
      end
   end

   -- Then below

   local below = {x = pos.x, y = pos.y - 1, z = pos.z}

   local belowdef = nil

   if minetest.registered_nodes[minetest.get_node(below).name] then
      belowdef = minetest.registered_nodes[minetest.get_node(below).name]
   end

   if belowdef and belowdef.write_name ~= nil then
      belowdef.write_name(below, text)
   end
]]
end

-- Saplings growing and placing

function default.place_sapling(itemstack, placer, pointed_thing)
   local place_on, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
   if place_on == nil then
      return itemstack
   end
   local floornode = minetest.get_node(place_floor)

   if minetest.get_item_group(floornode.name, "soil") == 0 then
      return itemstack
   end

   minetest.set_node(place_on, {name = itemstack:get_name()})

   if not minetest.is_creative_enabled(placer:get_player_name()) then
       itemstack:take_item()
   end

   return itemstack
end

local sapling_data = {
	["rp_default:sapling"] = {
		grows_to = "apple",
		grow_time_min = 300,
		grow_time_max = 480,
	},
	["rp_default:sapling_oak"] = {
		grows_to = "oak",
		grow_time_min = 700,
		grow_time_max = 960,
	},
	["rp_default:sapling_birch"] = {
		grows_to = "birch",
		grow_time_min = 480,
		grow_time_max = 780,
	},
	["rp_default:sapling_dry_bush"] = {
		grows_to = "dry_bush",
		grow_time_min = 180,
		grow_time_max = 400
	}
}

local tree_data = {
	["apple"] = {
		schem = "default_appletree.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-2,3,-2), vector.new(2,5,2) },
		},
	},
	["oak"] = {
		schem = "default_oaktree.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-1,3,-1), vector.new(1,5,1) },
		},
	},
	["birch"] = {
		schem = "default_squaretree.mts",
		replacements = {
			["rp_default:leaves"] = "rp_default:leaves_birch",
			["rp_default:tree"] = "rp_default:tree_birch",
			["rp_default:apple"] = "air"
		},
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
			{ vector.new(-1,2,-1), vector.new(1,4,1) },
		},
	},
	["dry_bush"] = {
		schem = "default_dry_bush.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
		},
	},
}

function default.check_sapling_space(pos, variety)
	local tdata = tree_data[variety]
	if not tdata then
		return false
	end
	local space = tdata.space
	for i=1, #space do
		local min, max = space[i][1], space[i][2]
		min = vector.add(pos, min)
		max = vector.add(pos, max)

		-- Every node of the volume needs to be air,
		-- so we calculate the volume first
		local required_airs = (max.x - min.x + 1) * (max.y - min.y + 1) * (max.z - min.z + 1)

		-- If pos is inside the volume, don’t count it (cut it’s the sapling)
		if pos.x >= min.x and pos.y >= min.y and pos.z >= min.z and pos.x <= max.x and pos.y <= max.y and pos.z <= max.z then
			required_airs = required_airs - 1
		end
		local _, counts = minetest.find_nodes_in_area(min, max, {"air"}, false)
		local counted_airs = counts.air
		if counted_airs < required_airs then
			return false
		end
	end
	return true
end

-- Start the sapling grow timer of the sapling at pos.
-- Returns true on success or false if it was not a sapling.
function default.begin_growing_sapling(pos)
   local node = minetest.get_node(pos)

   local sdata = sapling_data[node.name]
   if not sdata then
      return false
   end

   local min, max = sdata.grow_time_min, sdata.grow_time_max

   minetest.get_node_timer(pos):start(math.random(min, max))
   return true
end

-- Grow a sapling at pos
function default.grow_sapling(pos)
   local function grow(variety)
      local tdata = tree_data[variety]
      if not tdata then
	      minetest.log("error", "[rp_default] Unknown sapling variety in default.grow_sapling!")
	      return
      end
      local opos = vector.add(pos, tdata.offset)
      local replacements = tdata.replacements or {}
      minetest.place_schematic(
         opos,
         minetest.get_modpath("rp_default") .. "/schematics/" .. tdata.schem,
	 "0", replacements, false)
   end

   local node = minetest.get_node(pos)
   local sdata = sapling_data[node.name]
   if not sdata then
      return false
   end
   local variety = sdata.grows_to

   local enough_space = default.check_sapling_space(pos, variety)
   if not enough_space then
	   minetest.get_node_timer(pos):start(math.random(SAPLING_RECHECK_TIME_MIN, SAPLING_RECHECK_TIME_MAX))
	   return false
   end

   minetest.remove_node(pos)

   minetest.after(0, grow, variety)

   minetest.log("action", "[rp_default] A " .. variety .. " tree sapling grows at " ..
                  minetest.pos_to_string(pos))
   return true
end

-- Make preexisting trees restart the growing process

minetest.register_lbm(
   {
      label = "Grow legacy trees",
      name = "rp_default:grow_legacy_trees",
      nodenames = {"rp_default:sapling", "rp_default:sapling_oak", "rp_default:sapling_birch"},
      action = function(pos, node)
         default.begin_growing_sapling(pos)
      end
   }
)

-- Update nodes after the rename orgy after 1.5.3
minetest.register_lbm(
   {
      label = "Update signs",
      name = "rp_default:update_signs",
      nodenames = {"rp_default:sign"},
      action = function(pos, node)
         local meta = minetest.get_meta(pos)
         local text = meta:get_string("text")
         meta:set_string("infotext", S('"@1"', text))
      end
   }
)
minetest.register_lbm(
   {
      label = "Update bookshelves",
      name = "rp_default:update_bookshelves",
      nodenames = {"rp_default:bookshelf"},
      action = function(pos, node)
         local def = minetest.registered_nodes[node.name]
         def.on_construct(pos)
      end
   }
)
minetest.register_lbm(
   {
      label = "Update chests",
      name = "rp_default:update_chests",
      nodenames = {"rp_default:chest"},
      action = function(pos, node)
         local def = minetest.registered_nodes[node.name]
         def.on_construct(pos)
      end
   }
)


-- Vertical plants

-- Leaf decay

default.leafdecay_trunk_cache = {}
default.leafdecay_enable_cache = true
-- Spread the load of finding trunks
default.leafdecay_trunk_find_allow_accumulator = 0

minetest.register_globalstep(function(dtime)
      local finds_per_second = 5000
      default.leafdecay_trunk_find_allow_accumulator =
         math.floor(dtime * finds_per_second)
end)

default.after_place_leaves = function(pos, placer, itemstack, pointed_thing)
   local node = minetest.get_node(pos)
   node.param2 = 1
   minetest.set_node(pos, node)
end

minetest.register_abm( -- leaf decay
   {

      label = "Leaf decay",
      nodenames = {"group:leafdecay"},
      neighbors = {"air", "group:liquid"},
      -- A low interval and a high inverse chance spreads the load
      interval = 2,
      chance = 3,

      action = function(p0, node, _, _)
         local do_preserve = false
         local d = minetest.registered_nodes[node.name].groups.leafdecay
         if not d or d == 0 then
            return
         end
         local n0 = minetest.get_node(p0)
         if n0.param2 ~= 0 then
            return
         end
         local p0_hash = nil
         if default.leafdecay_enable_cache then
            p0_hash = minetest.hash_node_position(p0)
            local trunkp = default.leafdecay_trunk_cache[p0_hash]
            if trunkp then
               local n = minetest.get_node(trunkp)
               local reg = minetest.registered_nodes[n.name]
               -- Assume ignore is a trunk, to make the thing work at the border of the active area
               if n.name == "ignore" or (reg and reg.groups.tree and reg.groups.tree ~= 0) then
                  return
               end
               -- Cache is invalid
               table.remove(default.leafdecay_trunk_cache, p0_hash)
            end
         end
         if default.leafdecay_trunk_find_allow_accumulator <= 0 then
            return
         end
         default.leafdecay_trunk_find_allow_accumulator =
            default.leafdecay_trunk_find_allow_accumulator - 1
         -- Assume ignore is a trunk, to make the thing work at the border of the active area
         local p1 = minetest.find_node_near(p0, d, {"ignore", "group:tree"})
         if p1 then
            do_preserve = true
            if default.leafdecay_enable_cache then
               -- Cache the trunk
               default.leafdecay_trunk_cache[p0_hash] = p1
            end
         end
         if not do_preserve then
            -- Drop stuff other than the node itself
            local itemstacks = minetest.get_node_drops(n0.name)
            for _, itemname in ipairs(itemstacks) do
               if minetest.get_item_group(n0.name, "leafdecay_drop") ~= 0 or itemname ~= n0.name then
                  local p_drop = {
                     x = p0.x - 0.5 + math.random(),
                     y = p0.y - 0.5 + math.random(),
                     z = p0.z - 0.5 + math.random(),
                  }
                  minetest.add_item(p_drop, itemname)
               end
            end
            -- Remove node
            minetest.remove_node(p0)
         end
      end
})

local is_dry_biome = function(biomename)
   return biomename == "Charparral" or biomename == "Savanna" or biomename == "Savanna Ocean" or biomename == "Desert" or biomename == "Wasteland"
end

minetest.register_abm( -- dirt and grass footsteps becomes dirt with grass if uncovered
   {
      label = "Grow grass on dirt",
      nodenames = {"rp_default:dirt", "rp_default:dirt_with_grass_footsteps", "rp_default:swamp_dirt"},
      interval = 2,
      chance = 40,
      action = function(pos, node)
         local above = {x=pos.x, y=pos.y+1, z=pos.z}
         local name = minetest.get_node(above).name
         local partialblock = minetest.get_item_group(name, "path") ~= 0 or minetest.get_item_group(name, "slab") ~= 0 or minetest.get_item_group(name, "stair") ~= 0
         local nodedef = minetest.registered_nodes[name]
         if nodedef and (not partialblock) and (nodedef.sunlight_propagates or nodedef.paramtype == "light") and nodedef.liquidtype == "none" and (minetest.get_node_light(above) or 0) >= 8 then
            local biomedata = minetest.get_biome_data(pos)
            local biomename = minetest.get_biome_name(biomedata.biome)
            if node.name == "rp_default:swamp_dirt" then
                if biomename == "Swamp" then
                    minetest.set_node(pos, {name = "rp_default:dirt_with_swamp_grass"})
                end
            else
                if is_dry_biome(biomename) then
                    minetest.set_node(pos, {name = "rp_default:dirt_with_dry_grass"})
                else
                    minetest.set_node(pos, {name = "rp_default:dirt_with_grass"})
                end
            end
         end
      end
})

minetest.register_abm( -- dirt with grass becomes dirt if covered
   {
      label = "Remove grass on covered dirt",
      nodenames = {"group:grass_cover"},
      interval = 2,
      chance = 10,
      action = function(pos, node)
         local above = {x=pos.x, y=pos.y+1, z=pos.z}
         local name = minetest.get_node(above).name
         local partialblock = minetest.get_item_group(name, "path") ~= 0 or minetest.get_item_group(name, "slab") ~= 0 or minetest.get_item_group(name, "stair") ~= 0
         local nodedef = minetest.registered_nodes[name]
         if nodedef and (name ~= "ignore" and (partialblock) or (not ((nodedef.sunlight_propagates or nodedef.paramtype == "light") and nodedef.liquidtype == "none"))) then
            if node.name == "rp_default:dirt_with_swamp_grass" then
                minetest.set_node(pos, {name = "rp_default:swamp_dirt"})
            else
                minetest.set_node(pos, {name = "rp_default:dirt"})
            end
         end
      end
})

minetest.register_abm({
    label = "Grass expansion",
    nodenames = {"group:grass"},
    neighbors = {"group:grass_cover"},
    interval = 20,
    chance = 160,
    action = function(pos, node)
        pos.y = pos.y - 1
        local under = minetest.get_node(pos)
        pos.y = pos.y + 1

        local required_under
        if minetest.get_item_group(node.name, "normal_grass") ~= 0 then
            required_under = "rp_default:dirt_with_grass"
        elseif minetest.get_item_group(node.name, "dry_grass") ~= 0 then
            required_under = "rp_default:dirt_with_dry_grass"
        elseif minetest.get_item_group(node.name, "swamp_grass") ~= 0 then
            required_under = "rp_default:dirt_with_swamp_grass"
        else
            return
        end

        if under.name ~= required_under then
            return
        end

        -- Lower chance to spread dry grass
        if node.name == "rp_default:dry_grass" and math.random(1,2) == 1 then
            return
        end

        local pos0 = vector.subtract(pos, 4)
        local pos1 = vector.add(pos, 4)
        -- Testing shows that a threshold of 3 results in an appropriate maximum
        -- density of approximately 7 nodes per 9x9 area.
        if #minetest.find_nodes_in_area(pos0, pos1, {"group:grass", "rp_default:fern"}) > 3 then
            return
        end

        local soils = minetest.find_nodes_in_area_under_air( pos0, pos1, "group:grass_cover")
        local num_soils = #soils
        if num_soils >= 1 then
            for si = 1, math.min(3, num_soils) do
                local soil = soils[math.random(num_soils)]
                local soil_above = {x = soil.x, y = soil.y + 1, z = soil.z}
                minetest.set_node(soil_above, {name = node.name})
            end
        end
    end
})

minetest.register_abm({
    label = "Growing clams",
    nodenames = {"rp_default:sand", "rp_default:gravel"},
    neighbors = {"rp_default:water_source"},
    interval = 20,
    chance = 160,
    action = function(pos, node)
        if pos.y ~= water_level then
           return
        end
        local pos0 = vector.add(pos, {x=-5, y=0, z=-5})
        local pos1 = vector.add(pos, {x=5, y=2, z=5})
        if #minetest.find_nodes_in_area(pos0, pos1, "rp_default:clam") >= 1 then
            return
        end

        pos0 = vector.add(pos, {x=-2, y=0, z=-2})
        pos1 = vector.add(pos, {x=2, y=0, z=2})
        local soils = minetest.find_nodes_in_area_under_air( pos0, pos1, {"rp_default:sand", "rp_default:gravel"})
        local num_soils = #soils
        if num_soils >= 1 then
            for si = 1, math.min(3, num_soils) do
                local soil = soils[math.random(num_soils)]
                local soil_above = {x = soil.x, y = soil.y + 1, z = soil.z}
                minetest.set_node(soil_above, {name = "rp_default:clam"})
            end
        end
    end
})

minetest.register_abm( -- cactus grows
   {
      label = "Growing cacti",
      nodenames = {"rp_default:cactus"},
      neighbors = {"group:sand"},
      interval = 20,
      chance = 10,
      action = function(pos, node)
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name
         if minetest.get_item_group(name, "sand") ~= 0 then
            pos.y = pos.y+1
            local height = 0
            while minetest.get_node(pos).name == "rp_default:cactus" and height < 3 do
               height = height+1
               pos.y = pos.y+1
            end
            if height < 3 then
               if minetest.get_node(pos).name == "air" then
                  minetest.set_node(pos, {name="rp_default:cactus"})
               end
            end
         end
      end,
})

minetest.register_abm( -- papyrus grows
   {
      label = "Growing papyrus",
      nodenames = {"rp_default:papyrus"},
      neighbors = {"group:plantable_sandy", "group:plantable_soil"},
      interval = 20,
      chance = 10,
      action = function(pos, node)
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name

         if minetest.find_node_near(pos, 3, {"group:water"}) == nil then
            return
         end
         pos.y = pos.y+1
         local height = 0
         while minetest.get_node(pos).name == "rp_default:papyrus" and height < 3 do
            height = height+1
            pos.y = pos.y+1
         end
         if height < 3 then
            if minetest.get_node(pos).name == "air" then
               minetest.set_node(pos, {name="rp_default:papyrus"})
            end
         end
      end,
})

minetest.register_abm( -- weak torchs burn out and die after ~3 minutes
   {
      label = "Burning out weak torches",
      nodenames = {"rp_default:torch_weak", "rp_default:torch_weak_wall"},
      interval = 3,
      chance = 60,
      action = function(pos, node)
         minetest.set_node(pos, {name = "rp_default:torch_dead", param = node.param, param2 = node.param2})
      end
})
