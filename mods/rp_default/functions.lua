local water_level = tonumber(minetest.get_mapgen_setting("water_level"))
local S = minetest.get_translator("rp_default")

-- If a sapling fails to grow, check the sapling again after this many seconds
local SAPLING_RECHECK_TIME_MIN = 60
local SAPLING_RECHECK_TIME_MAX = 70

-- Maximum growth height of cactus, normally
local CACTUS_MAX_HEIGHT = 4
-- Maximum growth height of cactus, fertilized
local CACTUS_MAX_HEIGHT_PLUS = 6
-- Maximum growth height of thistle, normally
local THISTLE_MAX_HEIGHT = 2
-- Maximum growth height of thistle, fertilized
local THISTLE_MAX_HEIGHT_PLUS = 3
-- Maximum growth height of papyrus, normally
local PAPYRUS_MAX_HEIGHT = 3
-- Maximum growth height of papyrus, fertilized
local PAPYRUS_MAX_HEIGHT_PLUS = 4
-- Bonus height for papyrus when growing on swamp dirt
local PAPYRUS_SWAMP_HEIGHT_BONUS = 1

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
   -- Boilerplate to handle pointed node handlers
   local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
   if handled then
      return handled_itemstack
   end

   -- Find position to place sapling at
   local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
   if place_in == nil then
      return itemstack
   end
   local floornode = minetest.get_node(place_floor)

   -- Check protection
   if minetest.is_protected(place_in, placer:get_player_name()) and
           not minetest.check_player_privs(placer, "protection_bypass") then
       minetest.record_protection_violation(pos, placer:get_player_name())
       return itemstack
   end

   -- Floor must be soil
   if minetest.get_item_group(floornode.name, "soil") == 0 then
      return itemstack
   end

   -- Place sapling
   minetest.set_node(place_in, {name = itemstack:get_name()})

   -- Reduce item count
   if not minetest.is_creative_enabled(placer:get_player_name()) then
       itemstack:take_item()
   end

   return itemstack
end

local sapling_data = {
	["rp_default:sapling"] = {
		grows_to = {
			["dry"] = "normal_tiny",
			["swamp"] = "apple_swamp",
			["default"] = "apple",
		},
		grow_time_min = 300,
		grow_time_max = 480,
	},
	["rp_default:sapling_oak"] = {
		grows_to = {
			["dry"] = "oak_tiny",
			["swamp"] = "oak_swamp",
			["normal"] = "oak_acorns",
			["default"] = "oak",
		},
		grow_time_min = 700,
		grow_time_max = 960,
	},
	["rp_default:sapling_birch"] = {
		grows_to = {
			["dry"] = "birch_tiny",
			["swamp"] = "birch_swamp",
			["default"] = "birch_cuboid",
		},
		grows_to = "birch",
		grow_time_min = 480,
		grow_time_max = 780,
	},
	["rp_default:sapling_dry_bush"] = {
		grows_to = {
			["dry"] = "dry_bush",
			["swamp"] = "dry_bush_small",
			["default"] = "dry_bush",
		},
		grows_to = "dry_bush",
		grow_time_min = 180,
		grow_time_max = 400
	}
}

local tree_data = {
	["apple"] = {
		schem = "rp_default_apple_tree.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-2,3,-2), vector.new(2,5,2) },
		},
	},
	["normal_tiny"] = {
		schem = "rp_default_tiny_normal_tree.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
			{ vector.new(-1,2,-1), vector.new(1,4,1) },
		},
	},
	["apple_swamp"] = {
		schem = "rp_default_swamp_apple_tree.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-2,3,-2), vector.new(2,4,2) },
		},
	},
	["oak"] = {
		schem = "rp_default_oak_tree.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-1,3,-1), vector.new(1,5,1) },
		},
	},
	["oak_acorns"] = {
		schem = "rp_default_oak_tree_acorns.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-1,3,-1), vector.new(1,5,1) },
		},
	},
	["oak_swamp"] = {
		schem = "rp_default_swamp_oak.mts",
		offset = vector.new(-3, -1, -3),
		space = {
			{ vector.new(0,0,0), vector.new(0,2,0) },
			{ vector.new(-2,3,-2), vector.new(2,5,2) },
		},
	},
	["oak_tiny"] = {
		schem = "rp_default_tiny_oak.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
			{ vector.new(-1,2,-1), vector.new(1,4,1) },
		},
	},
	["birch_cuboid"] = {
		schem = "rp_default_birch_cuboid_3x3_short.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
			{ vector.new(-1,2,-1), vector.new(1,4,1) },
		},
	},
	["birch_swamp"] = {
		schem = "rp_default_swamp_birch.mts",
		offset = vector.new(-2, -1, -2),
		space = {
			{ vector.new(0,0,0), vector.new(0,3,0) },
			{ vector.new(-1,4,-1), vector.new(1,6,1) },
		},
	},
	["birch_tiny"] = {
		schem = "rp_default_tiny_birch.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
			{ vector.new(-1,2,-1), vector.new(1,4,1) },
		},
	},
	["dry_bush"] = {
		schem = "rp_default_dry_bush.mts",
		offset = vector.new(-1, -1, -1),
		space = {
			{ vector.new(0,0,0), vector.new(0,1,0) },
		},
	},
	["dry_bush_small"] = {
		schem = "rp_default_dry_bush_small.mts",
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

-- Returns true if node at pos is a sapling and
-- the sapling growth timer is activated.
function default.is_sapling_growing(pos)
   local node = minetest.get_node(pos)
   if minetest.get_item_group(node.name, "sapling") == 0 then
	   return false
   end
   local timer = minetest.get_node_timer(pos)
   return timer:is_started()
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
   local below = minetest.get_node(vector.add(pos, vector.new(0,-1,0)))
   local fertilized = minetest.get_item_group(below.name, "plantable_fertilizer") > 0
   -- Determine the full growth time of this sapling
   local timeout = math.random(min, max)
   -- Time bonus if node is fertilized
   local timebonus = 0
   if fertilized then
      -- The time bonus is a fraction of the full groth time
      -- If the soil is fertilized, this will start the node timer
      -- with a few seconds counted as 'elapsed' already.
      timebonus = timeout * default.SAPLING_FERTILIZER_TIME_BONUS_FACTOR
   end
   minetest.get_node_timer(pos):set(timeout, timebonus)
   minetest.log("action", "[rp_default] Sapling timer of "..node.name.. " started at "..minetest.pos_to_string(pos,0).." with timeout="..timeout.."s, elapsed="..timebonus.." (fertilized="..tostring(fertilized)..")")
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
	 "random", replacements, false)
   end

   local node = minetest.get_node(pos)
   local sdata = sapling_data[node.name]
   if not sdata then
      return false
   end
   local grows_to = sdata.grows_to
   local belownode = minetest.get_node(vector.add(pos, vector.new(0,-1,0)))
   local dirttype
   if minetest.get_item_group(belownode.name, "normal_dirt") == 1 then
	   dirttype = "normal"
   elseif minetest.get_item_group(belownode.name, "swamp_dirt") == 1 then
	   dirttype = "swamp"
   elseif minetest.get_item_group(belownode.name, "dry_dirt") == 1 then
	   dirttype = "dry"
   end
   local variety = grows_to[dirttype]
   if not variety then
	   dirttype = "default"
	   variety = grows_to[dirttype]
   end
   local enough_space = default.check_sapling_space(pos, variety)

   if not enough_space and dirttype ~= "default" then
	variety = grows_to["default"]
        enough_space = default.check_sapling_space(pos, variety)
   end

   if not enough_space then
	   minetest.get_node_timer(pos):start(math.random(SAPLING_RECHECK_TIME_MIN, SAPLING_RECHECK_TIME_MAX))
	   return false
   end

   minetest.remove_node(pos)

   minetest.after(0, grow, variety)

   minetest.log("action", "[rp_default] Sapling of type '" .. variety .. "' grows at " ..
                  minetest.pos_to_string(pos))
   return true
end

-- Grows a plantlike_rooted plant that lives underwater by `add` node lengths
-- (default: 1).
-- Returns: <success>, <top_pos>
-- <success>: true if plant was grown, false otherwise
-- <top_pos>: position to which a new "plant segment" was added (nil if none)
function default.grow_underwater_leveled_plant(pos, node, add)
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	end
	if not add then
		add = 1
	end
	local old_param2 = node.param2
	local new_level = node.param2 + (16 * add)
	if new_level % 16 > 0 then
		new_level = new_level - new_level % 16
	end
	local max_level = def.leveled_max
	if new_level > max_level then
		new_level = max_level
	end
	if new_level < 0 then
		new_level = 0
	end
	node.param2 = new_level
	if node.param2 == old_param2 then
		return false
	end
	local height = math.ceil(new_level / 16)
	for i = 1, height do
		local pos2 = vector.new(pos.x, pos.y + i, pos.z)
		local node2 = minetest.get_node(pos2)
		local def2 = minetest.registered_nodes[node2.name]
		if not (minetest.get_item_group(node2.name, "water") > 0 and def2.liquidtype == "source") then
			return false
		end
	end
	minetest.set_node(pos, node)
	local top = vector.new(pos.x, pos.y + height, pos.z)
	return true, top
end

-- Make preexisting sapling restart the growing process

minetest.register_lbm(
   {
      label = "Grow legacy trees",
      name = "rp_default:grow_legacy_trees",
      nodenames = {"rp_default:sapling", "rp_default:sapling_oak", "rp_default:sapling_birch"},
      action = function(pos, node)
         if not default.is_sapling_growing(pos) then
            default.begin_growing_sapling(pos)
         end
      end
   }
)

-- Update sign formspecs/infotexts
minetest.register_lbm(
   {
      label = "Update signs",
      name = "rp_default:update_signs_2_2_0",
      nodenames = {"group:sign"},
      action = function(pos, node)
         local meta = minetest.get_meta(pos)
         default.refresh_sign(meta)
      end
   }
)

-- Force nodes to update infotext/formspec
minetest.register_lbm(
   {
      label = "Update bookshelves",
      name = "rp_default:update_bookshelves_3_0_1",
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
      name = "rp_default:update_chests_3_0_1",
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

local biome_data = {}

-- Returns true if the given biome is considered to be
-- a 'dry' biome (e.g. for dry grass). Custom or unknown
-- biomes are never dry.
default.is_dry_biome = function(biomename)
   if biome_data[biomename] then
      return biome_data[biomename].is_dry
   end
   return false
end

-- List of biomes registered with default.set_biome_info
local core_biomes = {}
-- Same as above, but without special sub-biomes like beach and ocean variants
local main_biomes = {}

-- Returns a list of names with all biomes registered with
-- default.set_biome_info
default.get_core_biomes = function()
   return core_biomes
end
-- Returns a list of names with all main layer biomes registered with
-- default.set_biome_info (no sub-biomes like ocean or beach)
default.get_main_biomes = function()
   return main_biomes
end

-- Sets biome metadata for a built-in biome.
-- Must be called AFTER biome registration.
-- * biome_name: Name of the *main* biome (not Ocean or Beach variant!)
-- * biome_class: One of: savannic, drylandic, swampy, desertic, undergroundy
default.set_biome_info = function(biomename, biome_class)
   local is_dry = false
   local dirt_blob = "rp_default:dirt"
   local sand_blob = "rp_default:sand"
   local gravel_blob = "rp_default:gravel"
   if biome_class == "savannic" then
      is_dry = true
   elseif biome_class == "drylandic" then
      dirt_blob = "rp_default:dry_dirt"
      is_dry = true
   elseif biome_class == "desertic" then
      dirt_blob = "rp_default:dry_dirt"
      is_dry = true
   elseif biome_class == "swampy" then
      dirt_blob = "rp_default:swamp_dirt"
   elseif biome_class == "undergroundy" then
      dirt_blob = nil
   end
   local data = {
      main_biome = biomename,
      layer = "main",
      class = biome_class,
      is_dry = is_dry,
      dirt_blob = dirt_blob,
      sand_blob = sand_blob,
      gravel_blob = gravel_blob,
   }
   biome_data[biomename] = data
   table.insert(main_biomes, biomename)
   table.insert(core_biomes, biomename)

   local ocean = biomename .. " Ocean"
   if minetest.registered_biomes[ocean] then
      local odata = table.copy(data)
      odata.layer = "ocean"
      biome_data[ocean] = odata
      table.insert(core_biomes, ocean)
   end
   local beach = biomename .. " Beach"
   if minetest.registered_biomes[beach] then
      local bdata = table.copy(data)
      bdata.layer = "beach"
      biome_data[beach] = bdata
      table.insert(core_biomes, beach)
   end
end

-- Returns metadata for a builtin biome. Returns a table with these fields:
-- * main_biome: Name of the main biome (useful if you have an ocean or beach biome variant)
-- * layer: "main" for the core biome, "ocean" and "beach" for the special Ocean and Beach variants
-- * class: Biome class that was assigned (see above)
-- * is_dry: True if biome is considered dry (e.g. for dry grass)
-- * dirt_blob: Name of dirt ore node or nil to suppress generation
-- * sand_blob: Name of sand ore node or nil to suppress generation
-- * gravel_blob: Name of gravel ore node or nil to suppress generation
--
-- Note: dirt_blob, sand_blob and gravel_blob are used to create ores after all builtin
-- biomes were created. These fields are useless for biomes from
-- external mods.
default.get_biome_info = function(biomename)
   return biome_data[biomename]
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
                if default.is_dry_biome(biomename) then
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

minetest.register_abm( -- seagrass dies if not underwater
   {
      label = "Sea grass death",
      nodenames = {"group:sea_grass"},
      interval = 10,
      chance = 20,
      action = function(pos, node)
	 local dir = minetest.wallmounted_to_dir(node.param2)
         local plantpos = vector.subtract(pos, dir)
         local name = minetest.get_node(plantpos).name
         local water = minetest.get_item_group(name, "water") ~= 0
         if not water then
            if node.name == "rp_default:sea_grass_on_dirt" then
                minetest.set_node(pos, {name = "rp_default:dirt"})
	    elseif node.name == "rp_default:sea_grass_on_swamp_dirt" then
                minetest.set_node(pos, {name = "rp_default:swamp_dirt"})
            end
         end
      end
})


minetest.register_abm({
    label = "Flower/fern expansion",
    nodenames = {"rp_default:flower", "rp_default:fern"},
    neighbors = {"rp_default:dirt_with_grass", "rp_default:fertilized_dirt"},
    interval = 13,
    chance = 300,
    action = function(pos, node)
        -- Spread flowers and fern planted on fertilized dirt
        -- to neighboring nodes.
	-- Fern: Spreads minimally on dirt with grass. Spreads greatly on fertilized dirt fields
	-- Flowers: Spreads a few on dirt with grass with high range. Spreads quickly when on fertilized dirt
	--          to dirt with grass, but more concentrated with low range. Never spreads on fertilized dirt
	--          on its own.
        local upos = vector.add(pos, vector.new(0,-1,0))
        local under = minetest.get_node(upos)
	local fertilized = false
	if under.name == "rp_default:fertilized_dirt" then
           fertilized = true
	end
	if not fertilized and under.name ~= "rp_default:dirt_with_grass" then
           return
	end


	local offset, maxplants, maxplants_few
	if node.name == "rp_default:fern" then
		maxplants = 2
		offset = vector.new(3,2,3)
	else
		maxplants = 3
		offset = vector.new(4,1,4)
	end
	maxplants_few = maxplants

	-- Overcrowding: Stop spreading if too many in area
	if fertilized then
		-- Higher limit if fertilized
		if node.name == "rp_default:fern" then
			maxplants = 7
		else
			offset = vector.new(1,1,1)
			maxplants = 6
		end
	end

	local pos0 = vector.subtract(pos, offset)
	local pos1 = vector.add(pos, offset)
        local same_plants = minetest.find_nodes_in_area(pos0, pos1, {"rp_default:flower", "rp_default:fern"})

        -- If on fertilized dirt, can to other fertilized dirt with
	-- higher overcrowding limit. Spreading to dirt with grass
	-- still needs to be below the low maxplants_few limit to be
	local can_grow_to_unfertilized = true
        -- Flowers can't spread TO fertilized dirt,
	-- but they can spread to dirt with grass FROM fertilized dirt.
	local can_grow_to_fertilized = node.name == "rp_default:fern"
	if #same_plants >= maxplants_few then
           if fertilized then
              if node.name == "rp_default:fern" then
	         can_grow_to_unfertilized = false
              end
	      if #same_plants >= maxplants then
                 return
              end
           else
	      return
           end
	end
        local airs = minetest.find_nodes_in_area(pos0, pos1, "air")
	local spread_candidates = {}
	for a=1, #airs do
           local ground = vector.add(airs[a], vector.new(0,-1,0))
           local gnode = minetest.get_node(ground)
	   -- New flower/fern spawns on fertilized dirt or dirt with grass
           if (can_grow_to_fertilized and gnode.name == "rp_default:fertilized_dirt") or (can_grow_to_unfertilized and gnode.name == "rp_default:dirt_with_grass") then
              table.insert(spread_candidates, airs[a])
           end
	end
	if #spread_candidates == 0 then
           return
	end
	local s = math.random(1, #spread_candidates)
	minetest.set_node(spread_candidates[s], node)
    end,
})

minetest.register_abm({
    label = "Grass clump expansion",
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
            local fertilized = minetest.get_item_group(name, "plantable_fertilizer") == 1
            pos.y = pos.y+1
            local height = 0
            local maxh
            -- Determine maximum height. Bonus height on fertilized node
            if fertilized then
               maxh = CACTUS_MAX_HEIGHT_PLUS
            else
               maxh = CACTUS_MAX_HEIGHT
            end
            while minetest.get_node(pos).name == "rp_default:cactus" and height < maxh do
               height = height+1
               pos.y = pos.y+1
            end
            if height < maxh then
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
         -- Papyrus grows upwards, up to a limit.
         -- The maximum height is on fertilized swamp dirt.

         -- Check underground first
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name
         if minetest.get_item_group(name, "plantable_sandy") == 0 and minetest.get_item_group(name, "plantable_soil") == 0 then
            return 0
	 end

         -- Needs water nearby
         if minetest.find_node_near(pos, 3, {"group:water"}) == nil then
            return
         end
         pos.y = pos.y+1

         -- Determine growth height
         local height = 0
         -- Maximum height is higher on fertilized
         local fertilized = minetest.get_item_group(name, "plantable_fertilizer") == 1
         local maxh
         if fertilized then
            maxh = PAPYRUS_MAX_HEIGHT_PLUS
         else
            maxh = PAPYRUS_MAX_HEIGHT
         end
         -- Bonus max. height on swamp dirt
         local is_swampy = minetest.get_item_group(name, "swamp_dirt") == 1
         if is_swampy then
            maxh = maxh + PAPYRUS_SWAMP_HEIGHT_BONUS
         end

         -- Find highest spot and grow
         while minetest.get_node(pos).name == "rp_default:papyrus" and height < maxh do
            height = height+1
            pos.y = pos.y+1
         end
         if height < maxh then
            if minetest.get_node(pos).name == "air" then
               minetest.set_node(pos, {name="rp_default:papyrus"})
            end
         end
      end,
})

minetest.register_abm( -- thistle grows (slowly)
   {
      label = "Growing thistle",
      nodenames = {"rp_default:thistle"},
      neighbors = {"group:normal_dirt"},
      interval = 120,
      chance = 20,
      action = function(pos, node)
         -- Thistle grows upwards, up to a limit.
         -- Check ground first
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name
         if minetest.get_item_group(name, "normal_dirt") == 0 then
            return
         end
         pos.y = pos.y+1
         local height = 0
         local fertilized = minetest.get_item_group(name, "plantable_fertilizer") == 1
         local maxh
         -- Maximum height is higher on fertilized
         if fertilized then
            maxh = THISTLE_MAX_HEIGHT_PLUS
         else
            maxh = THISTLE_MAX_HEIGHT
         end
         -- Get node above the highest node and grow, if possible
         while minetest.get_node(pos).name == "rp_default:thistle" and height < maxh do
            height = height+1
            pos.y = pos.y+1
         end
         if height < maxh then
            if minetest.get_node(pos).name == "air" then
               minetest.set_node(pos, {name="rp_default:thistle"})
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
	 local newnode = { param2 = node.param2 }
         if node.name == "rp_default:torch_weak_wall" then
            newnode.name = "rp_default:torch_dead_wall"
         else
            newnode.name = "rp_default:torch_dead"
         end
         minetest.swap_node(pos, newnode)
      end
})
