local water_level = tonumber(minetest.get_mapgen_setting("water_level"))
local S = minetest.get_translator("rp_default")

-- If a sapling fails to grow, check the sapling again after this many seconds
local SAPLING_RECHECK_TIME_MIN = 60
local SAPLING_RECHECK_TIME_MAX = 70

local AIRWEED_RECHARGE_TIME_DEFAULT = 10.0 -- how many seconds it takes for an airweed to become usable again by default

local GRAVITY = tonumber(minetest.settings:get("movement_gravity") or 9.81)

-- Maximum growth height of cactus on dry dirt, normally
local CACTUS_MAX_HEIGHT_DDIRT = 2
-- Maximum growth height of cactus on dry dirt, fertilized
local CACTUS_MAX_HEIGHT_DDIRT_PLUS = 3
-- Maximum growth height of cactus on sand, normally
local CACTUS_MAX_HEIGHT_SAND = 4
-- Maximum growth height of cactus on sand, fertilized
local CACTUS_MAX_HEIGHT_SAND_PLUS = 6
-- Maximum growth height of thistle, normally
local THISTLE_MAX_HEIGHT_NORMAL = 2
-- Maximum growth height of thistle, fertilized
local THISTLE_MAX_HEIGHT_PLUS = 3
-- Maximum growth height of papyrus, normally
local PAPYRUS_MAX_HEIGHT_NORMAL = 3
-- Maximum growth height of papyrus, fertilized
local PAPYRUS_MAX_HEIGHT_PLUS = 4
-- Bonus height for papyrus when growing on swamp dirt
local PAPYRUS_SWAMP_HEIGHT_BONUS = 1

-- Maximum possible cactus growth height
default.CACTUS_MAX_HEIGHT_TOTAL = CACTUS_MAX_HEIGHT_SAND_PLUS
-- Maximum possible thistle growth height
default.THISTLE_MAX_HEIGHT_TOTAL = THISTLE_MAX_HEIGHT_PLUS
-- Maximum possible papyrus growth height
default.PAPYRUS_MAX_HEIGHT_TOTAL = PAPYRUS_MAX_HEIGHT_PLUS + PAPYRUS_SWAMP_HEIGHT_BONUS

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

   local sapling_name = itemstack:get_name()

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

   -- Update achievement
   if placer and placer:is_player() then
      achievements.trigger_subcondition(placer, "forester", sapling_name)
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
		if not util.is_water_source_or_waterfall(pos2) then
			return false
		end
	end
	minetest.swap_node(pos, node)
	local top = vector.new(pos.x, pos.y + height, pos.z)
	return true, top
end

-- Starts the timer of an inert airweed at pos
-- (if not started already) so it will become
-- usable to get air bubbles soon.
-- Do not call this function on any other node type!
function default.start_inert_airweed_timer(pos)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		return
	else
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		timer:start(def._airweed_recharge_time or AIRWEED_RECHARGE_TIME_DEFAULT)
	end
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

-- Make sure to restart the timer of inert airweeds
minetest.register_lbm(
   {
      label = "Restart inert airweed timers",
      name = "rp_default:restart_inert_airweed_timers",
      nodenames = {"group:airweed_inert"},
      action = function(pos, node)
         default.start_inert_airweed_timer(pos)
      end
   }
)

-- Update sign formspecs/infotexts
minetest.register_lbm(
   {
      label = "Update signs",
      name = "rp_default:update_signs_3_7_0",
      nodenames = {"group:sign"},
      action = function(pos, node)
         local meta = minetest.get_meta(pos)
         default.refresh_sign(meta, node)
      end
   }
)

-- Force nodes to update infotext/formspec
minetest.register_lbm(
   {
      label = "Update bookshelves",
      name = "rp_default:update_bookshelves_3_5_0",
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
      name = "rp_default:update_chests_3_5_0",
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
            local leafdecay_drop = minetest.get_item_group(n0.name, "leafdecay_drop") ~= 0
            for _, itemname in ipairs(itemstacks) do
               if leafdecay_drop or itemname ~= n0.name then
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
	    if not leafdecay_drop then
               minetest.add_particlespawner({
                  amount = math.random(10, 20),
                  time = 0.1,
                  minpos = vector.add(p0, {x=-0.4, y=-0.4, z=-0.4}),
                  maxpos = vector.add(p0, {x=0.4, y=0.4, z=0.4}),
                  minvel = {x=-0.2, y=-0.2, z=-0.2},
                  maxvel = {x=0.2, y=0.1, z=0.2},
                  minacc = {x=0, y=-GRAVITY, z=0},
                  maxacc = {x=0, y=-GRAVITY, z=0},
                  minexptime = 0.1,
                  maxexptime = 0.5,
                  minsize = 0.5,
                  maxsize = 1.5,
                  collisiondetection = true,
                  vertical = false,
                  node = n0,
               })
            end
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

-- Returns true if the given biome is considered to be
-- a swamp biome. Custom or unknown biomes are not
-- part of the swamp.
default.is_swamp_biome = function(biomename)
   if biome_data[biomename] then
      return biome_data[biomename].class == "swampy"
   end
   return false
end

-- List of biomes registered with default.set_biome_info
local core_biomes = {}
-- Same as above, but without special sub-biomes like beach and underwater variants
local main_biomes = {}

-- Returns a list of names with all biomes registered with
-- default.set_biome_info
default.get_core_biomes = function()
   return core_biomes
end
-- Returns a list of names with all main layer biomes registered with
-- default.set_biome_info (no sub-biomes like underwater or beach)
default.get_main_biomes = function()
   return main_biomes
end

-- Sets biome metadata for a built-in biome.
-- Must be called AFTER biome registration.
-- * biome_name: Name of the *main* biome (not Underwater or Beach variant!)
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

   local underwater = biomename .. " Underwater"
   if minetest.registered_biomes[underwater] then
      local odata = table.copy(data)
      odata.layer = "underwater"
      biome_data[underwater] = odata
      table.insert(core_biomes, underwater)
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
-- * main_biome: Name of the main biome (useful if you have an underwater or beach biome variant)
-- * layer: "main" for the core biome, "underwater" and "beach" for the special Underwater and Beach variants
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
         if nodedef and (not partialblock) and (nodedef.sunlight_propagates or nodedef.paramtype == "light") and nodedef.liquidtype == "none" and nodedef.drawtype ~= "plantlike_rooted" and (minetest.get_node_light(above) or 0) >= 8 then
            local biomedata = minetest.get_biome_data(pos)
            local biomename = minetest.get_biome_name(biomedata.biome)
            if node.name == "rp_default:swamp_dirt" then
                if default.is_swamp_biome(biomename) then
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
         if name ~= "ignore" and nodedef and (partialblock or nodedef.paramtype ~= "light" or nodedef.liquidtype ~= "none" or nodedef.drawtype == "plantlike_rooted") then
            if node.name == "rp_default:dirt_with_swamp_grass" then
                minetest.set_node(pos, {name = "rp_default:swamp_dirt"})
            else
                minetest.set_node(pos, {name = "rp_default:dirt"})
            end
         end
      end
})

minetest.register_abm( -- seagrass and airweed dies if not underwater
   {
      label = "Sea grass / airweed decay",
      nodenames = {"group:seagrass", "group:airweed"},
      interval = 10,
      chance = 20,
      action = function(pos, node)
         local dir = vector.new(0,1,0)
         local plantpos = vector.add(pos, dir)
         local is_water = util.is_water_source_or_waterfall(plantpos)
         if not is_water then
            local def = minetest.registered_nodes[node.name]
            if def._waterplant_base_node then
                minetest.set_node(pos, {name = def._waterplant_base_node})
            else
                minetest.log("error", "[rp_default] Missing _waterplant_base_node for "..node.name)
                minetest.remove_node(pos)
            end
         end
      end
})

minetest.register_abm( -- algae die/become smaller if not fully underwater
-- also reset age to 0 (no growth) by implication
   {
      label = "Alga decay",
      nodenames = {"group:alga"},
      interval = 10,
      chance = 20,
      action = function(pos, node)
         local height = math.ceil(node.param2 / 16)
         local segmentpos = vector.new(pos.x,pos.y,pos.z)
	 local height_ok = 0
	 for h=1, height do
            segmentpos.y = pos.y + h
            local is_water = util.is_water_source_or_waterfall(segmentpos)
            if not is_water then
               break
            end
            height_ok = h
         end
         if height_ok == height then
            return
         end

	 if height_ok < 1 then
            local def = minetest.registered_nodes[node.name]
            if def and def._waterplant_base_node then
                minetest.set_node(pos, {name = def._waterplant_base_node})
            else
                minetest.log("error", "[rp_default] Missing _waterplant_base_node for "..node.name)
                minetest.remove_node(pos)
            end
         else
            local param2 = height_ok * 16
	    minetest.set_node(pos, {name=node.name, param2=param2})
         end
         minetest.add_particlespawner({
            amount = math.random(10*height, 20*height),
            time = 0.1,
            minpos = vector.add(pos, {x=-0.3, y=0.6, z=-0.3}),
            maxpos = vector.add(pos, {x=0.3, y=0.4+height, z=0.3}),
            minvel = {x=-0.2, y=-0.2, z=-0.2},
            maxvel = {x=0.2, y=0.1, z=0.2},
            minacc = {x=0, y=-GRAVITY, z=0},
            maxacc = {x=0, y=-GRAVITY, z=0},
            minexptime = 0.1,
            maxexptime = 0.5,
            minsize = 0.5,
            maxsize = 0.75,
            collisiondetection = true,
            vertical = false,
            node = {name="rp_default:alga_block"},
         })
      end,
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
    label = "Grass clump growth",
    nodenames = {"rp_default:grass"},
    neighbors = {"group:plantable_fertilizer"},
    interval = 20,
    chance = 160,
    action = function(pos, node)
       local below = vector.add(pos, vector.new(0,-1,0))
       local belownode = minetest.get_node(below)
       local fert = belownode.name == "rp_default:fertilized_dirt"
       if fert then
          minetest.set_node(pos, {name="rp_default:tall_grass", param2=node.param2})
       end
    end,
})

minetest.register_abm({
    label = "Sea grass clump growth",
    nodenames = {"group:seagrass"},
    neighbors = {"group:water"},
    interval = 20,
    chance = 160,
    action = function(pos, node)
       local fert = minetest.get_item_group(node.name, "plantable_fertilizer") > 0
       local above = vector.add(pos, vector.new(0,1,0))
       local abovenode = minetest.get_node(above)
       local in_water = minetest.get_item_group(abovenode.name, "water") > 0
       if in_water and fert then
          if node.name == "rp_default:seagrass_on_fertilized_dirt" then
              minetest.set_node(pos, {name="rp_default:tall_seagrass_on_fertilized_dirt", param2=node.param2})
          elseif node.name == "rp_default:seagrass_on_fertilized_swamp_dirt" then
              minetest.set_node(pos, {name="rp_default:tall_seagrass_on_fertilized_swamp_dirt", param2=node.param2})
          elseif node.name == "rp_default:seagrass_on_fertilized_sand" then
              minetest.set_node(pos, {name="rp_default:tall_seagrass_on_fertilized_sand", param2=node.param2})
          end
       end
    end,
})

-- Grow vine
minetest.register_abm(
   {
      label = "Grow vines",
      name = "rp_default:grow_vines",
      nodenames = {"rp_default:vine"},
      interval = 21,
      chance = 120,
      action = function(pos, node)
         local meta = minetest.get_meta(pos)
         local age = node.param2
         if node.param2 == 0 or node.param2 >= default.VINE_MAX_AGE then
            return
         end
         local below = {x=pos.x, y=pos.y-1, z=pos.z}
         local nbelow = minetest.get_node(below)
         if nbelow.name == "air" then
            age = math.min(default.VINE_MAX_AGE, age + 1)
            minetest.set_node(below, {name="rp_default:vine", param2 = age})
         end
      end,
   }
)

-- Grow algae
minetest.register_abm(
   {
      label = "Grow algae",
      name = "rp_default:grow_algae",
      nodenames = {"group:alga"},
      neighbors = {"group:water"},
      interval = 20,
      chance = 90,
      action = function(pos, node)
	 local def = minetest.registered_nodes[node.name]
	 if not def or not def._waterplant_max_height then
	    return
	 end

         local meta = minetest.get_meta(pos)
         local age = meta:get_int("age")
         if age == 0 then
            return
         end
         local height = math.ceil(node.param2 / 16)
         local new_height = height + 1

	 -- Stop growh at max height
         if new_height > def._waterplant_max_height or age+1 > def._waterplant_max_height then
            return
         end

         local grown = default.grow_underwater_leveled_plant(pos, node, 1)
         if not grown then
            -- Stop growth once blocked
            meta:set_int("age", 0) -- age = 0 means no growth
            return
         else
            -- Increase age by 1
            age = math.min(age + 1, 255)
            meta:set_int("age", age)
         end
      end,
   }
)

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
    label = "Seagrass clump expansion",
    nodenames = {"group:seagrass"},
    neighbors = {"group:water"},
    interval = 20,
    chance = 160,
    action = function(pos, node)
        local abovenode = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
        local abovedef = minetest.registered_nodes[abovenode.name]

        if minetest.get_item_group(abovenode.name, "water") == 0 or not abovedef or abovedef.liquidtype ~= "source" then
           return
        end

        local pos0 = vector.subtract(pos, 4)
        local pos1 = vector.add(pos, 4)
        -- Testing shows that a threshold of 3 results in an appropriate maximum
        -- density of approximately 7 nodes per 9x9 area.
        if #minetest.find_nodes_in_area(pos0, pos1, {"group:seagrass"}) > 3 then
            return
        end

        local soils = minetest.find_nodes_in_area(pos0, pos1, {"rp_default:dirt", "rp_default:swamp_dirt", "rp_default:sand", "rp_default:fertilized_dirt", "rp_default:fertilized_swamp_dirt", "rp_default:fertilized_sand"})
        local num_soils = #soils
        if num_soils >= 1 then
            local to_set = math.min(3, num_soils)
            local has_set = 0
	    while true do
                local rnd = math.random(1, #soils)
                local soil = soils[rnd]
                local soil_above = {x = soil.x, y = soil.y + 1, z = soil.z}

		local soil_above_node = minetest.get_node(soil_above)
                local soil_above_def = minetest.registered_nodes[soil_above_node.name]
                if minetest.get_item_group(soil_above_node.name, "water") ~= 0 and soil_above_def and soil_above_def.liquidtype == "source" then
                   local soil_node = minetest.get_node(soil)
		   local newnode
                   if soil_node.name == "rp_default:dirt" then
                      newnode = "rp_default:seagrass_on_dirt"
                   elseif soil_node.name == "rp_default:swamp_dirt" then
                      newnode = "rp_default:seagrass_on_swamp_dirt"
                   elseif soil_node.name == "rp_default:sand" then
                      newnode = "rp_default:seagrass_on_sand"
                   elseif soil_node.name == "rp_default:fertilized_dirt" then
                      newnode = "rp_default:seagrass_on_fertilized_dirt"
                   elseif soil_node.name == "rp_default:fertilized_swamp_dirt" then
                      newnode = "rp_default:seagrass_on_fertilized_swamp_dirt"
                   elseif soil_node.name == "rp_default:fertilized_sand" then
                      newnode = "rp_default:seagrass_on_fertilized_sand"
	           else
                      return
	           end
		   minetest.set_node(soil, {name=newnode})
		   has_set = has_set + 1
                   if has_set >= to_set then
                      break
                   end
                end
		table.remove(soils, rnd)
                if #soils == 0 then
                   break
                end
            end
        end
    end
})



minetest.register_abm({
    label = "Sand Grass clump expansion",
    nodenames = {"group:sand_grass"},
    neighbors = {"group:sand"},
    interval = 21,
    chance = 160,
    action = function(pos, node)
        pos.y = pos.y - 1
        local under = minetest.get_node(pos)
        pos.y = pos.y + 1

        if minetest.get_item_group(under.name, "plantable_sandy") == 0 then
            return
        end

        local pos0 = vector.add(pos, vector.new(-4, 0, -4))
        local pos1 = vector.add(pos, vector.new(4, 1, 4))
        -- Testing shows that a threshold of 3 results in an appropriate maximum
        -- density of approximately 7 nodes per 9x9 area.
        if #minetest.find_nodes_in_area(pos0, pos1, {"group:sand_grass"}) > 3 then
            return
        end

	-- Sand grass can spread to sand on the same level
	-- and on the level above, but it can't spread downwards
        pos0 = vector.add(pos, vector.new(-4, -1, -4))
        pos1 = vector.add(pos, vector.new(4, 0, 4))
        local soils = minetest.find_nodes_in_area_under_air( pos0, pos1, "group:plantable_sandy")
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

-- Clams "washing up" at shallow sand and gravel beaches
minetest.register_abm({
    label = "Growing clams",
    nodenames = {"rp_default:sand", "rp_default:gravel"},
    neighbors = {"rp_default:water_source"},
    interval = 20,
    chance = 160,
    min_y = water_level,
    max_y = water_level+2,
    action = function(pos, node)
        if pos.y < water_level or pos.y > water_level+2 then
           return
        end
        -- Abort if there's a clam nearby
        local pos0 = vector.add(pos, {x=-5, y=0, z=-5})
        local pos1 = vector.add(pos, {x=5, y=2, z=5})
        if #minetest.find_nodes_in_area(pos0, pos1, "group:clam") >= 1 then
            return
        end

        -- Check the terrain around pos if it roughly resembles a shallow beach.
        -- Done to prevent clam spawning in trivial cases like
        -- 1 water source + 1 sand

        -- Count water around pos 1 level below where the clam would be
        pos0 = vector.add(pos, {x=-5, y=0, z=-5})
        pos1 = vector.add(pos, {x=5, y=0, z=5})
        local waternodes = #minetest.find_nodes_in_area(pos0, pos1, "rp_default:water_source")
        -- Count sand and gravel around pos 2 levels below where the clam would be.
        -- This is 1 level below the water.
        pos0 = vector.add(pos, {x=-5, y=-1, z=-5})
        pos1 = vector.add(pos, {x=5, y=-1, z=5})
        -- Seagrass also counts as the node position is the solid sand-/dirt-like node, not the plant itself
        local beachnodes = #minetest.find_nodes_in_area(pos0, pos1, {"rp_default:sand", "rp_default:gravel", "group:seagrass"})
        -- Check if enough nodes were found. 30 is roughly 1/4 of an 11×11 area
        if waternodes < 30 or beachnodes < 30 then
           return
        end

        -- All checks passed! Clam spawning begins.
        -- Check for places for 1 or multiple clams to spawn on.
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
      neighbors = {"group:sand", "group:dry_dirt"},
      interval = 20,
      chance = 10,
      action = function(pos, node)
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name
         local is_sand = minetest.get_item_group(name, "sand") ~= 0
         local is_ddirt = minetest.get_item_group(name, "dry_dirt") ~= 0
         if is_sand or is_ddirt then
            local fertilized = minetest.get_item_group(name, "plantable_fertilizer") == 1
            pos.y = pos.y+1
            local height = 0
            local maxh
            -- Determine maximum height. Bonus height on fertilized node
	    if is_sand then
               if fertilized then
                  maxh = CACTUS_MAX_HEIGHT_SAND_PLUS
               else
                  maxh = CACTUS_MAX_HEIGHT_SAND
               end
            else
               if fertilized then
                  maxh = CACTUS_MAX_HEIGHT_DDIRT_PLUS
               else
                  maxh = CACTUS_MAX_HEIGHT_DDIRT
               end
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
      neighbors = {"group:plantable_sandy", "group:plantable_soil", "group:plantable_wet"},
      interval = 20,
      chance = 10,
      action = function(pos, node)
         -- Papyrus grows upwards, up to a limit.
         -- The maximum height is on fertilized swamp dirt.

         -- Check underground first
         pos.y = pos.y-1
         local name = minetest.get_node(pos).name
         if minetest.get_item_group(name, "plantable_sandy") == 0 and minetest.get_item_group(name, "plantable_soil") == 0 and minetest.get_item_group(name, "plantable_wet") == 0 then
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
            maxh = PAPYRUS_MAX_HEIGHT_NORMAL
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
               -- Set param2 to the height. This tells the game
	       -- this papyrus node was grown
               local p2 = height + 1
               minetest.set_node(pos, {name="rp_default:papyrus", param2=p2})
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
            maxh = THISTLE_MAX_HEIGHT_NORMAL
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



