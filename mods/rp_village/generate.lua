
--
-- Single village generation
--

village.villages = {}

-- Sidelength of the square of a village chunk, in nodes
local VILLAGE_CHUNK_SIZE = 12
-- Maximum height of village chunks (buildings)
local VILLAGE_CHUNK_HEIGHT = 20

-- Hill width and height
local HILL_W, HILL_H = 24, 6
-- Number of dirt nodes to extend below hill
local HILL_EXTEND_BELOW = 15

-- Chance values. Each chance is provided in a 1:x value,
-- e.g. a value of 8 means a chance of 1:8.
-- Only positive integers are allowed.

-- Chance that a ground node has a decor node on top (grass, etc.)
local DECOR_CHANCE = 8

-- Chance that a village is abandoned
local ABANDONED_CHANCE = 25

-- Chance a village chunk in an abandoned village spawns using
-- a 'ruins' variant (if one is available)
local ABANDONED_RUINS_CHANCE = 2

-- Savefile

local village_file = minetest.get_worldpath() .. "/villages.dat"

local modpath = minetest.get_modpath("rp_village")
local mod_locks = minetest.get_modpath("rp_locks") ~= nil
local mapseed = minetest.get_mapgen_setting("seed")
local water_level = tonumber(minetest.get_mapgen_setting("water_level"))

--[[ List of village wood materials (schematic replacements)
One of these will be chosen at random per village. ]]
local village_replaces = {
   -- Default (Birch + Oak, as specified in schematics)
   {
   },
   -- Birch → Normal (Normal + Oak)
   {
      ["rp_default:planks_birch"] = "rp_default:planks",
      ["rp_partialblocks:stair_birch"] = "rp_partialblocks:stair_wood",
      ["rp_partialblocks:slab_birch"] = "rp_partialblocks:slab_wood",
      ["rp_default:tree_birch"] = "rp_default:tree",
      ["rp_default:fence_birch"] = "rp_default:fence",
   },
   -- Oak → Normal (Normal + Birch)
   {
      ["rp_default:planks_oak"] = "rp_default:planks",
      ["rp_partialblocks:stair_oak"] = "rp_partialblocks:stair_wood",
      ["rp_partialblocks:slab_oak"] = "rp_partialblocks:slab_wood",
      ["rp_default:tree_oak"] = "rp_default:tree",
      ["rp_default:fence_oak"] = "rp_default:fence",
   },
   -- Normal wood only
   {
      ["rp_default:planks_birch"] = "rp_default:planks",
      ["rp_default:planks_oak"] = "rp_default:planks",
      ["rp_partialblocks:stair_birch"] = "rp_partialblocks:stair_wood",
      ["rp_partialblocks:slab_birch"] = "rp_partialblocks:slab_wood",
      ["rp_partialblocks:stair_oak"] = "rp_partialblocks:stair_wood",
      ["rp_partialblocks:slab_oak"] = "rp_partialblocks:slab_wood",
      ["rp_default:tree_birch"] = "rp_default:tree",
      ["rp_default:tree_oak"] = "rp_default:tree",
      ["rp_default:fence_birch"] = "rp_default:fence",
      ["rp_default:fence_oak"] = "rp_default:fence",
   },
   -- Birch wood only
   {
      ["rp_default:planks"] = "rp_default:planks_birch",
      ["rp_default:planks_oak"] = "rp_default:planks_birch",
      ["rp_partialblocks:stair_wood"] = "rp_partialblocks:stair_birch",
      ["rp_partialblocks:slab_wood"] = "rp_partialblocks:slab_birch",
      ["rp_partialblocks:stair_oak"] = "rp_partialblocks:stair_birch",
      ["rp_partialblocks:slab_oak"] = "rp_partialblocks:slab_birch",
      ["rp_default:tree"] = "rp_default:tree_birch",
      ["rp_default:tree_oak"] = "rp_default:tree_birch",
      ["rp_default:fence"] = "rp_default:fence_birch",
      ["rp_default:fence_oak"] = "rp_default:fence_birch",
      ["rp_door:door_wood_t_1"] = "rp_door:door_wood_birch_t_1",
      ["rp_door:door_wood_b_1"] = "rp_door:door_wood_birch_b_1",
   },
   -- Oak wood only
   {
      ["rp_default:planks"] = "rp_default:planks_oak",
      ["rp_default:planks_birch"] = "rp_default:planks_oak",
      ["rp_partialblocks:stair_wood"] = "rp_partialblocks:stair_oak",
      ["rp_partialblocks:slab_wood"] = "rp_partialblocks:slab_oak",
      ["rp_partialblocks:stair_birch"] = "rp_partialblocks:stair_oak",
      ["rp_partialblocks:slab_birch"] = "rp_partialblocks:slab_oak",
      ["rp_default:tree"] = "rp_default:tree_oak",
      ["rp_default:tree_birch"] = "rp_default:tree_oak",
      ["rp_default:fence"] = "rp_default:fence_oak",
      ["rp_default:fence_birch"] = "rp_default:fence_oak",
      ["rp_door:door_wood_t_1"] = "rp_door:door_wood_oak_t_1",
      ["rp_door:door_wood_b_1"] = "rp_door:door_wood_oak_b_1",
   },
}

local schematic_cache = {}
-- Wrapper around minetest.read_schematic to
-- speed up loading time on subsequent reads.
-- returns a schematic specifier.
local function read_cached_chunk_schematic(subchunktype)
   if schematic_cache[subchunktype] then
      return schematic_cache[subchunktype], true
   end
   local schem_path = modpath .. "/schematics/village_" .. subchunktype .. ".mts"
   local schem_spec = minetest.read_schematic(schem_path, {})
   schematic_cache[subchunktype] = schem_spec
   return schem_spec, false
end

function village.get_id(name, pos)
   return name .. string.format("%d", minetest.hash_node_position(pos))
end

function village.save_villages()
   local f = io.open(village_file, "w")

   for name, def in pairs(village.villages) do
      f:write(name .. " " .. def.name .. " "
                 .. string.format("%d", minetest.hash_node_position(def.pos)) .. "\n")
   end

   io.close(f)
end

function village.load_villages()
   local f = io.open(village_file, "r")

   if f then
      repeat
	 local l = f:read("*l")
	 if l == nil then break end

	 for name, fname, pos in string.gmatch(l, "(.+) (%a+) (%d.+)") do
	    village.villages[name] = {
	       name = fname,
	       pos = minetest.get_position_from_hash(pos),
	    }
	    village.name.used[fname] = true
	 end
      until f:read(0) == nil

      io.close(f)
   else
      village.save_villages()
   end

   village.load_waypoints()
end

function village.load_waypoints()
   for name, def in pairs(village.villages) do
      nav.remove_waypoint("village_" .. name)
      nav.add_waypoint(
	 def.pos,
	 "village_" .. name,
	 def.name .. " village",
	 true,
	 "village"
      )
   end
end

function village.get_nearest_village(pos)
   local nearest = math.huge
   local npos = nil -- village pos
   local fname = nil -- human-readable village name
   local name = nil -- village ID

   for name, def in pairs(village.villages) do
      local dist = vector.distance(pos, def.pos)
      if dist < nearest then
	 nearest = dist
	 name = name
	 fname = def.name
	 npos = def.pos
      end
   end
   if not fname then
	   return nil
   end
   return {dist = nearest, pos = npos, name = name, fname = fname}
end

village.chunkdefs = {}

--[[
Village chunks are the square sections of a village. This includes buildings,
farms, roads, and the like.

village chunk definition:
{
   -- every field is optional
   can_cache = <bool>, -- if true, schematic can be cached by Minetest
                       -- use this if no random node replacements (like wood)
                      -- are required (default: false)
   variants = { "variant_1", ..., "variant_n" },
   -- list of chunktype variants. One random variatn will be picked at random
   -- on placement. Each name must correspond to a file
   -- in `schematics/village_<variant_name>.mts`. By default, a chunktype has
   -- 1 variant with the name equal to the chunktype identifier
   groundclass_variants = {
      [ "groundclass_1"] = { "variant_1", ... "variant_n" },
      ...,
      [ "groundclass_n"] = { "another_variant_1", ... "another_variant_n" },
   },
   -- An alternative way to specify variants. Instead of a single list of
   -- variants, this specifies multiple lists of variants, each assigned
   -- a groundclass. In this case, the chunktype can only be placed if
   -- the village has this given groundclass. If it has that groundclass,
   -- a random variant in that groundclass is selected.

   -- Note: either variants, groundclass_variants or neither can be specified,
   -- but not both.

   ruins = { "ruins_1", ..., "ruins_n" },
   -- Like variants, but for a ruined version of this chunktype. In abandoned
   -- villages, one random ruined variant MAY be chosen from the list, or the
   -- 'intact' schematic is placed (but "generic" ruinations like broken glass
   -- still apply).
   -- If unused, the 'intact' schematic will be placed.

   groundclass_ruins = {
      [ "groundclass_1"] = { "ruins_1", ... "ruins_n" },
      ...,
      [ "groundclass_n"] = { "another_ruins_1", ... "another_ruins_n" },
   },
   -- Like groundclass_variants, but for ruins.

   entities = {
      [entity_1] = <number>,
      ...
      [entity_n] = <number>,
   }, -- list of entities that can spawn (needs entity spawner node in schematic)
   entity_chance = <number>,
}
]]

village.chunkdefs["livestock_pen"] = {
   groundclass_variants = {
      ["grassland"] = {"livestock_pen"},
   },
   entities = {
      ["mobs:sheep"] = 3,
      ["mobs:boar"] = 1,
   },
}
village.chunkdefs["lamppost"] = { -- not road because of road height limit of 1 nodes
   groundclass_variants = {
      ["grassland"] = {"lamppost"},
      ["dry"] = {"lamppost"},
      ["savanna"] = {"lamppost"},
      ["swamp"] = {"swamp_lamppost"},
   },
   groundclass_ruins = {
      ["grassland"] = {"lamppost_ruins"},
      ["dry"] = {"lamppost_ruins"},
      ["savanna"] = {"lamppost_ruins"},
      ["swamp"] = {"swamp_lamppost_ruins", "swamp_lamppost_ruins_2"},
   },
   can_cache = true,
   entity_chance = 2,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["well"] = {
   ruins = {"well_ruins"},
   entities = {
      ["mobs:npc_farmer"] = 1,
      ["mobs:npc_tavernkeeper"] = 1,
   },
}
village.chunkdefs["house"] = {
   groundclass_variants = {
      ["grassland"] = {"house", "house_2", "house_3", "house_4", "house_5", "house_6", "house_7", "house_8", "house_9"},
      ["dry"] = {"house", "house_2", "house_3", "house_4", "house_5", "house_6", "house_7", "house_8", "house_9"},
      ["savanna"] = {"house", "house_2", "house_3", "house_4", "house_5", "house_6", "house_7", "house_8", "house_9"},
   },
   ruins = {"house_ruins", "house_ruins_2"},
   entity_chance = 2,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["hut_s"] = {
   groundclass_variants = {
      ["swamp"] = {"reed_hut_s_1","reed_hut_s_2","reed_hut_s_3","reed_hut_s_4","reed_hut_s_5","reed_hut_s_6","reed_hut_s_7"},
   },
   ruins = {"reed_hut_s_ruins", "reed_hut_s_ruins_2"},
   entitity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["hut_m"] = {
   groundclass_variants = {
      ["swamp"] = {"reed_hut_m_1","reed_hut_m_2","reed_hut_m_3","reed_hut_m_4","reed_hut_m_5","reed_hut_m_6","reed_hut_m_7"},
   },
   ruins = {"reed_hut_m_ruins", "reed_hut_m_ruins_2"},
   entitity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}

village.chunkdefs["workshop"] = {
   groundclass_variants = {
      grassland = {"workshop"},
      dry = {"workshop"},
      savanna = {"workshop"},
      swamp = {"reed_workshop"},
   },
   groundclass_ruins = {
      grassland = {"workshop_ruins", "rubble"},
      dry = {"workshop_ruins", "rubble"},
      savanna = {"workshop_ruins", "rubble"},
      swamp = {"reed_workshop_ruins"},
   },
   entity_chance = 2,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["townhall"] = {
   groundclass_variants = {
      grassland = {"townhall"},
      dry = {"townhall"},
      savanna = {"townhall"},
      swamp = {"reed_townhall"},
   },
   groundclass_ruins = {
      grassland = {"townhall_ruins", "rubble"},
      dry = {"townhall_ruins", "rubble"},
      savanna = {"townhall_ruins", "rubble"},
      swamp = {"reed_townhall_ruins"},
   },
   entity_chance = 1,
   entities = {
      ["mobs:npc_tavernkeeper"] = 1,
      ["mobs:npc_farmer"] = 1,
      ["mobs:npc_blacksmith"] = 1,
      ["mobs:npc_carpenter"] = 1,
   },
}


village.chunkdefs["tavern"] = {
   groundclass_variants = {
      grassland = {"tavern"},
      dry = {"tavern"},
      savanna = {"tavern"},
      swamp = {"reed_tavern_1"},
   },
   groundclass_ruins = {
      grassland = {"tavern_ruins"},
      dry = {"tavern_ruins"},
      savanna = {"tavern_ruins"},
      swamp = {"reed_tavern_ruins_1", "reed_tavern_ruins_2"},
   },
   entity_chance = 2,
   entities = {
      ["mobs:npc_tavernkeeper"] = 1,
   },
}
village.chunkdefs["library"] = {
   groundclass_variants = {
      grassland = {"library"},
      dry = {"library"},
      savanna = {"library"},
      swamp = {"reed_library"},
   },
   groundclass_ruins = {
      grassland = {"library_ruins"},
      dry = {"library_ruins"},
      savanna = {"library_ruins"},
      swamp = {"reed_library_ruins"},
   },
   entity_chance = 3,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["reading_club"] = {
   groundclass_variants = {
      grassland = {"reading_club"},
      dry = {"reading_club"},
      savanna = {"reading_club"},
   },
   ruins = {"house_ruins", "house_ruins_2"},
   entity_chance = 3,
   entities = {
      ["mobs:npc_farmer"] = 1,
      ["mobs:npc_blacksmith"] = 1,
   },
}

village.chunkdefs["bakery"] = {
   groundclass_variants = {
      grassland = {"bakery"},
      dry = {"bakery"},
      savanna = {"bakery"},
   },
   ruins = {"bakery_ruins"},
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}


village.chunkdefs["forge"] = {
   groundclass_variants = {
      grassland = {"forge"},
      dry = {"forge"},
      savanna = {"forge"},
      swamp = {"reed_forge"},
   },
   groundclass_ruins = {
      grassland = {"forge_ruins", "rubble"},
      dry = {"forge_ruins", "rubble"},
      savanna = {"forge_ruins", "rubble"},
      swamp = {"reed_forge_ruins"},
   },
   entity_chance = 2,
   entities = {
      ["mobs:npc_blacksmith"] = 1,
   },
}
village.chunkdefs["orchard"] = {
   groundclass_variants = {
      ["grassland"] = {"orchard"},
   },
   ruins = {"orchard_ragged"},
   can_cache = true,
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["road"] = {
   can_cache = true,
}

-- Farm chunktypes.
--
-- Farm chunktype naming scheme:
--
--    farm_<water><lines>_<plants>
--
-- * <water>: water position:
--    * "v": vertical lines
--    * "h": horizontal lines
--    * "c": center
--    * "o": outwards
-- * <lines>:
--    * for v/h: list of numbers at where the water will be
--    * for c/o: how much water in total
-- * <plants>: List of plants (from left to right)

village.chunkdefs["farm_small_plants"] = {
   groundclass_variants = {
      ["grassland"] = {
         "farm_v24_potato",
         "farm_v24_potato_wheat",
         "farm_v24_wheat",
         "farm_v24_wheat_cotton",
         "farm_v24_cotton",
         "farm_h246_potato",
         "farm_h246_wheat",
         "farm_h246_cotton",
      },
      ["swamp"] = {
         "farm_swamp_v24_asparagus",
         "farm_swamp_h246_asparagus",
      },
      ["savanna"] = {
         "farm_dry_v24_cotton",
         "farm_dry_h246_cotton",
      },
      ["dry"] = {
         "farm_dryd_v24_carrot",
         "farm_dryd_h246_carrot",
      },
   },
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   }
}

village.chunkdefs["farm_papyrus"] = {
   groundclass_variants = {
      ["grassland"] = {
         "farm_c4_papyrus",
         "farm_o4_papyrus",
      },
      ["swamp"] = {
         "farm_swamp_c4_papyrus",
         "farm_swamp_o4_papyrus",
      },
   },
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   }
}

-- List of chunk types. Chunk types are structurs and buildings
-- that are not the well and are placed next to roads.
-- The number is their absolute frequency. The higher the number,
-- the more likely it will occur.
-- The well is not listed here because it acts as the start point.
village.chunktypes = {
   -- { chunktype, absolute frequency }

   -- houses
   { "house", 210 },
   { "hut_s", 105 },
   { "hut_m", 105 },
   -- meeting rooms
   { "tavern", 120 },
   { "townhall", 60 },
   { "library", 20 },
   { "reading_club", 30 },
   -- workplaces
   { "forge", 100 },
   { "workshop", 100 },
   { "bakery", 60 },
   -- farming
   { "farm_small_plants", 120 },
   { "farm_papyrus", 120 },
   { "orchard", 60 },
   { "livestock_pen", 60 },
}

-- List of chunktypes to be used as fallback for the starting
-- village chunk if the village failed to place any buildings
-- outside the starting point.
-- In this case, the "starter well" will be a house
-- instead. This will create nice "lonely huts".
village.chunktypes_start_fallback = {
   -- chunktype, absolute frequency
   { "house", 14 },
   { "tavern", 7 },
   { "forge", 3 },
}

-- Calculate cumulated absolute frequency of a chunktypes
-- table and put it in index 3 of each entry. Puts the sum
-- of all absolute frequencies in `chunksum`.
local write_absolute_frequencies = function(chunktypes)
   local chunksum = 0
   for i=1, #chunktypes do
      chunksum = chunksum + chunktypes[i][2]
      chunktypes[i][3] = chunksum
   end
   chunktypes.chunksum = chunksum
end
write_absolute_frequencies(village.chunktypes)
write_absolute_frequencies(village.chunktypes_start_fallback)

-- Select a random chunk. The probability of a chunk being selected is
-- <absolute frequency> / <sum of all absolute frequencies>.
-- * `pr`: PseudoRandom object
-- * `chunktypes`: A table of chunktypes (see above) (default: `village.chunktypes`)
-- * `groundclass`: Restrict chunktypes to this ground class
local function random_chunktype(pr, chunktypes, groundclass)
   if not chunktypes then
      chunktypes = village.chunktypes
   end
   local check_chunktypes = table.copy(chunktypes)
   while #check_chunktypes > 0 do
      local rnd = pr:next(1, check_chunktypes.chunksum)
      for i=1, #check_chunktypes do
         if rnd <= check_chunktypes[i][3] then
            local chunktype = check_chunktypes[i][1]
            if groundclass and village.chunkdefs[chunktype].groundclass_variants and village.chunkdefs[chunktype].groundclass_variants[groundclass] == nil then
               table.remove(check_chunktypes, i)
               break
            else
               return chunktype
            end
         end
      end
   end
   minetest.log("error", "[rp_village] random_chunktype: Failed to find a chunktype, using a fallback")
   return "house" -- fallback
end

local function get_chunktype_variant(pr, chunktype, groundclass)
   local ctd = village.chunkdefs[chunktype]
   if not ctd then
      return chunktype
   end
   if ctd.variants then
      return ctd.variants[pr:next(1, #ctd.variants)]
   elseif groundclass and ctd.groundclass_variants and ctd.groundclass_variants[groundclass] then
      return ctd.groundclass_variants[groundclass][pr:next(1, #ctd.groundclass_variants[groundclass])]
   else
      return chunktype
   end
end

-- Given a chunktype, returns a random 'ruins' version
-- for that chunktype if one is available. Otherwise,
-- returns `chunktype`.
-- * `pr`: PseudoRandom object
-- * `chunktype`: Chunktype identifier
-- * `groundclass`: Restrict chunktypes to this ground class
local function get_ruined_chunktype(pr, chunktype, groundclass)
   local ctd = village.chunkdefs[chunktype]
   if not ctd then
      return chunktype
   end
   if ctd.ruins then
      return ctd.ruins[pr:next(1, #ctd.ruins)]
   elseif groundclass and ctd.groundclass_ruins and ctd.groundclass_ruins[groundclass] then
      return ctd.groundclass_ruins[groundclass][pr:next(1, #ctd.groundclass_ruins[groundclass])]
   else
      return get_chunktype_variant(pr, chunktype, groundclass)
   end
end

local function check_column_end(nn)
   local nd = minetest.registered_nodes[nn]
   return (not nd) or nn == "ignore" or (not (nn == "air" or (not nd.walkable) or ((minetest.get_item_group(nn, "dirt") > 0) and minetest.get_item_group(nn, "grass_cover") > 0)))
end

function village.get_column_nodes(vmanip, pos, scanheight, dirtnodes)
   local nn = vmanip:get_node_at({x=pos.x,y=pos.y+1,z=pos.z}).name
   if check_column_end(nn) then
       return
   end

   for y = pos.y, pos.y - scanheight, -1 do
      local p = {x = pos.x, y = y, z = pos.z}

      nn = vmanip:get_node_at(p).name
      if check_column_end(nn) then
         break
      else
         table.insert(dirtnodes, p)
      end
   end
end

-- Generate a hill.
--
-- * vmanip: VoxelMapnip object
-- * vdata: VoxelManip data table
-- * pos: Hill position
-- * ground: Ground nodename (below surface)
-- * ground_top: Ground nodename (surface)
-- * top_decors: Optional table of possible decorations to place on top of ground_top
-- * decors_to_place: Table in which positions of decor nodes will be stored (call-by-reference)
--                    Must be provided if `top_decors` is set
function village.generate_hill(vmanip, vdata, pos, ground, ground_top, top_decors, decors_to_place)
   local c_ground = minetest.get_content_id(ground)
   local c_ground_top = minetest.get_content_id(ground_top)
   local c_decors = {}
   local seed = 13 + minetest.hash_node_position(pos) + mapseed
   local decor_pr = PcgRandom(seed)
   if top_decors then
      for d=1, #top_decors do
         c_decors[d] = minetest.get_content_id(top_decors[d])
      end
   end
   local dirts = {}
   local dirts_with_grass = {}
   local vmin, vmax = vmanip:get_emerged_area()
   local varea = VoxelArea:new({MinEdge = vmin, MaxEdge = vmax})
   for y=HILL_H-1, 0, -1 do
   -- Count number of nodes that were actually changed on this layer
   local nodes_set = 0
   for z=y,HILL_W-1-y do
   for x=y,HILL_W-1-y do
      local p = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
      local vindex = varea:index(p.x,p.y,p.z)
      local vindex_above = varea:index(p.x,p.y+1,p.z)
      local n_content = vdata[vindex]
      if n_content then
         local nname = minetest.get_name_from_content_id(n_content)
         local def = minetest.registered_nodes[nname]
         local is_any_dirt = minetest.get_item_group(nname, "dirt") == 1
         local is_dirt = nname == "rp_default:dirt"
         local is_dry_dirt = nname == "rp_default:dry_dirt"
         if (not is_dry_dirt) and (is_dirt or (not is_any_dirt)) and (nname == "air" or nname == "ignore" or (def and (def.liquidtype ~= "none" or (def.is_ground_content)))) then
            local prev_was_ground = n_content == c_ground or n_content == c_ground_top
            if (y == HILL_H-1 or z == y or x == y or z == HILL_W-1-y or x == HILL_W-1-y) and (p.y >= water_level) then
               -- set surface node (e.g. dirt-with-grass)
               vdata[vindex] = c_ground_top
            else
               -- set 'below ground' node (e.g. dirt)
               vdata[vindex] = c_ground
            end
            if not prev_was_ground then
               nodes_set = nodes_set + 1
            end
         end
         -- chance to spawn a decor node (like grass) above ground_top
         local vindex_above = varea:index(p.x,p.y+1,p.z)
         if top_decors and #c_decors > 0 and vdata[vindex] == c_ground_top and vdata[vindex_above] == minetest.CONTENT_AIR and decor_pr:next(1,DECOR_CHANCE) == 1 then
            local decor = c_decors[decor_pr:next(1, #c_decors)]
            -- Don't place the decor immediately, instead remember this position and decor nodename
            -- and place all decorations at the end. This makes it easier to avoid conflicts
            -- with the rest of the generation algorithm.
            table.insert(decors_to_place, {
               -- VManip data index of decor position
               index_decor = vindex_above,
               -- content ID of decor node
               content_decor = c_decors[decor_pr:next(1, #c_decors)],
               -- VManip data index of floor position (on which decor will be placed)
               index_floor = vindex,
               -- content ID of floor node
               content_floor = vdata[vindex],
            })
            -- decors_to_place is call-by-reference, the caller can use this table afterwards
         end
      end
   end
   end
   -- Stop hill generation if no nodes were changed in this layer,
   -- because the building already has a foundation.
   if nodes_set == 0 then
      -- Partial / no hill generated (because not neccessary)
      return false
   end
   end
   -- Full hill generated
   return true
end

local function check_empty(pos)
   local min = { x = pos.x, y = pos.y + 1, z = pos.z }
   local max = { x = pos.x+12, y = pos.y+12, z = pos.z+12 }
   local ignores = minetest.find_nodes_in_area(min, max, "ignore")
   -- Treat an area of ignore nodes as non-empty (we err on the side of caution)
   if #ignores > 0 then
       minetest.log("action", "[rp_village] check_empty: Ignore found! pos="..minetest.pos_to_string(pos, 0).."; number of ignores="..(#ignores))
       return false
   end
   local stones = minetest.find_nodes_in_area(min, max, "group:stone")
   if #stones > 15 then
      return false
   end
   local leaves = minetest.find_nodes_in_area(min, max, "group:leaves")
   if #leaves > 2 then
      return false
   end
   local trees = minetest.find_nodes_in_area(min, max, "group:tree")
   if #trees > 0 then
      return false
   end
   return true
end

-- Map ground nodes with appropiate decor nodes to place on top
-- (e.g. grass)
-- Decors for normal villages
local decors_from_ground = {
   ["rp_default:dirt_with_grass"] = { "rp_default:grass" },
   ["rp_default:dirt_with_dry_grass"] = { "rp_default:dry_grass" },
   ["rp_default:dirt_with_swamp_grass"] = { "rp_default:swamp_grass" },
}
-- Decors for abandoned villages
local decors_from_ground_abandoned = table.copy(decors_from_ground)
-- Same as normal villages, except there's also tall grass
decors_from_ground_abandoned["rp_default:dirt_with_grass"] =
   {"rp_default:grass", "rp_default:grass", "rp_default:grass", "rp_default:tall_grass"}

-- Spawns a village chunk. This is a section of a village.
-- By default, this checks for empty space first (fails if no space),
-- then it generates a foundation of ground nodes, then it deletes
-- nodes above, then places the building as specified in chunktype.
--
-- Parameters:
-- * vmanip: VoxelManip object
-- * pos: pos to spawn chunk in
-- * state: table for internal state (call-by-reference)
-- * orient: orientation (for minetest.place_schematic)
-- * replace: one of these:
--    * node replacements table (for minetest.place_schematic)
--    * number of village replacements ID (from village_replacements table)
-- * pr: PseudoRandom object for random stuff
-- * chunktype: village chunk type ID
-- * noclear: If true, won't delete nodes before spawning
-- * nofill: If true, won't build a dirt foundation
-- * dont_check_empty: If true, don't fail if there is no empty space
-- * ground: ground node below surface
-- * ground_top: ground node on surface
--
-- returns true if chunk was placed, false otherwise.
function village.spawn_chunk(vmanip, pos, state, orient, replace, pr, chunktype, noclear, nofill, dont_check_empty, ground, ground_top)
   if not dont_check_empty and not check_empty(pos) then
      minetest.log("verbose", "[rp_village] Chunk not generated (too many stone/leaves/trees in the way) at "..minetest.pos_to_string(pos))
      return false
   end

   if noclear ~= true then
       local ok = minetest.place_schematic_on_vmanip(
         vmanip,
         pos,
         modpath .. "/schematics/village_empty.mts",
         "0",
         {},
         true
      )
      if not ok then
         minetest.log("warning", "[rp_village] Could not fully place empty schematic in village at "..minetest.pos_to_string(pos, 0))
      end
   end

   if nofill ~= true then
      local vdata = vmanip:get_data()
      -- Make a hill for the buildings to stand on
      local decors
      if state.is_abandoned then
         decors = decors_from_ground_abandoned[ground_top] or {}
      else
         decors = decors_from_ground[ground_top] or {}
      end
      if not state.decors_to_place then
         state.decors_to_place = {}
      end
      local full_hill = village.generate_hill(vmanip, vdata, {x=pos.x-6, y=pos.y-5, z=pos.z-6}, ground, ground_top, decors, state.decors_to_place)

      if full_hill then
         -- Extend the dirt below the hill, in case the hill is floating
         -- in mid-air
         local py = pos.y-6
         local dirtnodes = {}
         local vmin, vmax = vmanip:get_emerged_area()
         local varea = VoxelArea:new({MinEdge=vmin, MaxEdge=vmax})
         local c_ground = minetest.get_content_id(ground)
         for z=pos.z-6, pos.z+17 do
         for x=pos.x-6, pos.x+17 do
            village.get_column_nodes(vmanip, {x=x, y=py, z=z}, HILL_EXTEND_BELOW, dirtnodes)
            for d=1, #dirtnodes do
               local vindex = varea:index(dirtnodes[d].x, dirtnodes[d].y, dirtnodes[d].z)
               vdata[vindex] = c_ground
            end
         end
         end
      end
      vmanip:set_data(vdata)
   end

   if type(replace) == "number" then
      replace = village_replaces[replace]
   end
   local sreplace = table.copy(replace)
   if chunktype == "orchard" or chunktype == "orchard_ragged" then
      sreplace["rp_default:tree"] = nil
   end

   -- Select random variant (ruins or normal) for schematic name
   local schem_segment = chunktype
   if state.is_abandoned and pr:next(1, ABANDONED_RUINS_CHANCE) == 1 then
      schem_segment = get_ruined_chunktype(pr, chunktype, state.groundclass)
   else
      schem_segment = get_chunktype_variant(pr, chunktype, state.groundclass)
   end

   local schem_spec
   if village.chunkdefs[chunktype] and village.chunkdefs[chunktype].can_cache then
      -- Minetest's caching is allowed for this chunktype, so we call the schematic place function
      -- in the normal way (schematics are cached by Minetest if the schematic path is
      -- specified in the place function)
      schem_spec = modpath .. "/schematics/village_" .. schem_segment .. ".mts"
   else
      -- load schematic from table definition (read_schematic). This will force Minetest
      -- to skip its schematic cache and guarantee that node replacements are
      -- applied every time.
      -- However, this mod still caches the result of read_schematic itself to save
      -- a bit of time.
      local cached
      schem_spec, cached = read_cached_chunk_schematic(schem_segment)
   end
   local ok = minetest.place_schematic_on_vmanip(
      vmanip,
      pos,
      schem_spec,
      orient,
      sreplace,
      true
   )
   if not ok then
      minetest.log("warning", "[rp_village] Could not fully place village chunk in village at "..minetest.pos_to_string(pos, 0))
   end

   if not state.nodeupdates then
      state.nodeupdates = {}
   end
   table.insert(state.nodeupdates, {pos=pos, chunktype=chunktype})

   minetest.log("verbose", "[rp_village] Chunk generated at "..minetest.pos_to_string(pos))
   return true
end

function village.spawn_road(vmanip, pos, state, houses, built, roads, depth, pr, replace, dont_check_empty, dist_from_start, ground, ground_top)
   if not dont_check_empty and not check_empty(pos) then
      minetest.log("verbose", "[rp_village] Road not generated (too many stone/leaves/trees in the way) at "..minetest.pos_to_string(pos))
      return false
   end

   for i=1,4 do
      local nextpos = {x = pos.x, y = pos.y, z = pos.z}
      local orient = "random"

      local new_dist_from_start = vector.new(dist_from_start.x, dist_from_start.y, dist_from_start.z)
      if i == 1 then
	 orient = "0"
	 new_dist_from_start.z = new_dist_from_start.z - 1
	 nextpos.z = nextpos.z - 12
      elseif i == 2 then
	 orient = "90"
	 new_dist_from_start.x = new_dist_from_start.x - 1
	 nextpos.x = nextpos.x - 12
      elseif i == 3 then
	 orient = "180"
	 new_dist_from_start.z = new_dist_from_start.z + 1
	 nextpos.z = nextpos.z + 12
      else
	 orient = "270"
	 new_dist_from_start.x = new_dist_from_start.x + 1
	 nextpos.x = nextpos.x + 12
      end

      local hnp = minetest.hash_node_position(nextpos)

      local chunk_ok
      if built[hnp] == nil then
	 built[hnp] = true

         -- True is the next position is at or beyond the maximum village boundaries.
         -- This will ensure the village does not spread too far from the starting
         -- point.
         local is_at_village_border = math.abs(new_dist_from_start.x) >= village.max_village_spread or math.abs(new_dist_from_start.z) >= village.max_village_spread
         if is_at_village_border then
            minetest.log("verbose", "[rp_village] Border hit at "..minetest.pos_to_string(nextpos).." "..minetest.pos_to_string(new_dist_from_start))
         end

	 if depth <= 0 or is_at_village_border or pr:next(1, 8) < 6 then
	    houses[hnp] = {pos = nextpos, front = pos}

	    local structure = random_chunktype(pr, nil, state.groundclass)
	    chunk_ok = village.spawn_chunk(vmanip, nextpos, state, orient, replace, pr, structure, nil, nil, nil, ground, ground_top)
            if not chunk_ok then
               houses[hnp] = false
            end
	 else
	    roads[hnp] = {pos = nextpos}
	    chunk_ok = village.spawn_road(vmanip, nextpos, state, houses, built, roads, depth - 1, pr, replace, false, new_dist_from_start, ground, ground_top)
            if not chunk_ok then
               roads[hnp] = false
            end
	 end
      end
   end
   return true
end

-- Village modifiy functions: These are called after the VManip has placed
-- the village for further changes like setting metadata or tweak
-- nodes.
--
-- Parameters for all village_modify_* functions:
-- * upos, upos2: Lower and upper bounds of the village
-- * pr: PseudoRandom object used for randomness
-- * extras: Table with extra infos (function-specific, not always used)

-- Village modifier: Abandoned village. A complex modifier that
-- makes a village look like it was abandoned. It does these things:
-- * Turns all torches into dead torches
-- * Removes music players
-- * Makes grass overgrow on floor
-- * Randomly destroys farming plants, fences, glass, doors
-- * Generates seagrass and algae in water
--
-- The `extras` parameter must specify:
-- {
--    path = <itemname of path node>,
--    path_slab = <itemname of path node slab>,
--    ground_top = <itemname of top surface node outdoors (e.g. rp_default:dirt_with_grass>>,
-- }
local function village_modify_abandoned_village(upos, upos2, pr, extras)
      -- Replace all torches with dead torches
      util.nodefunc(
         upos, upos2,
	 {"rp_default:torch", "rp_default:torch_weak"},
         function(pos)
           local node = minetest.get_node(pos)
           minetest.set_node(pos, {name="rp_default:torch_dead", param2=node.param2})
         end, true)
      util.nodefunc(
         upos, upos2,
	 {"rp_default:torch_wall", "rp_default:torch_weak_wall"},
         function(pos)
           local node = minetest.get_node(pos)
           minetest.set_node(pos, {name="rp_default:torch_dead_wall", param2=node.param2})
         end, true)

      -- Remove all music players
      util.nodefunc(
         upos, upos2,
         "rp_music:player",
         function(pos)
           minetest.remove_node(pos)
         end, true)

      -- Remove 95% of farming plants
      util.nodefunc(
         upos, upos2,
	 "group:farming_plant",
         function(pos)
           if pr:next(1,100) <= 95 then
              -- 30% chance to replace with a decor (grass), if the ground type allows it
              if pr:next(1,10) <= 3 then
                 local below = vector.add(pos, vector.new(0,-1,0))
                 local belownode = minetest.get_node(below)
                 local decors = decors_from_ground_abandoned[belownode.name]
                 if decors then
                    local plant = decors[pr:next(1, #decors)]
                    minetest.set_node(pos, {name=plant})
                 else
                    minetest.remove_node(pos)
                 end
              else
                 minetest.remove_node(pos)
              end
           end
         end, true)

      -- Remove 80% of glass
      util.nodefunc(
         upos, upos2,
	 "group:glass",
         function(pos)
           if pr:next(1,5) >= 4 then
              minetest.remove_node(pos)
           end
         end, true)

      -- Replace 25% of path nodes
      util.nodefunc(
         upos, upos2,
	 {extras.path},
         function(pos)
           if pr:next(1,4) == 1 then
              minetest.set_node(pos, {name=extras.ground_top})
              local above = {x=pos.x,y=pos.y+1,z=pos.z}
              local abovenode = minetest.get_node(above)
              if abovenode.name == "air" and pr:next(1,DECOR_CHANCE) == 1 then
                 local decors = decors_from_ground_abandoned[extras.ground_top]
		 if decors then
		    local decor = decors[pr:next(1, #decors)]
                    minetest.set_node(above, {name=decor})
                 end
              end
           end
         end, true)
      -- Remove 25% of path slab nodes
      util.nodefunc(
         upos, upos2,
	 {extras.path_slab},
         function(pos)
           if pr:next(1,4) == 1 then
              minetest.remove_node(pos)
	      local below = vector.add(pos, vector.new(0,-1,0))
	      if minetest.get_node(below).name == "rp_default:dirt" then
                 if pr:next(1,3) == 1 then
                    minetest.set_node(below, {name=extras.path})
                 else
                    minetest.set_node(below, {name=extras.ground_top})
                 end
              end
           end
         end, true)

      -- Replace 25% of brick/cobble floor with ground
      util.nodefunc(
         upos, upos2,
	 {"rp_default:cobble", "rp_default:brick"},
         function(pos)
           if pr:next(1,4) == 1 then
	      local below = vector.add(pos, vector.new(0,-1,0))
	      local above = vector.add(pos, vector.new(0,1,0))
	      local nbelow = minetest.get_node(below)
	      local nabove = minetest.get_node(above)
	      if nabove.name == "air" and (nbelow.name == "rp_default:dirt" or nbelow.name == "rp_default:stone") then
                 minetest.set_node(pos, {name=extras.ground_top})
                 local plant = pr:next(1,5)
                 if plant == 1 then
                    minetest.set_node(above, {name="rp_default:grass"})
                 end
              end
           end
         end, true)

      -- Remove 50% of doors
      util.nodefunc(
         upos, upos2,
	 "group:door",
         function(pos)
           if pr:next(1,2) == 1 then
              local posup = vector.add(pos, vector.new(0,1,0))
              local posdn = vector.add(pos, vector.new(0,-1,0))

              local nup = minetest.get_node(posup)
              local ndn = minetest.get_node(posdn)
              if minetest.get_item_group(ndn.name, "door") == 1 then
                 return
              end
              minetest.remove_node(pos)
              if minetest.get_item_group(nup.name, "door") == 1 then
                 minetest.remove_node(posup)
              end
           end
         end, true)

      -- Remove 10% of fences
      util.nodefunc(
         upos, upos2,
	 "group:fence",
         function(pos)
            if pr:next(1,10) == 1 then
               local posup = vector.add(pos, vector.new(0,1,0))
               local posdn = vector.add(pos, vector.new(0,-1,0))
	       local nup = minetest.get_node(posup)
	       local ndn = minetest.get_node(posdn)
               -- make sure only fences on floor and below air are removed so we don't
               -- leave floating fences behind
	       if nup.name == "air" and minetest.get_item_group(ndn.name, "group:fence") == 0 then
                  minetest.remove_node(pos)
               end
            end
         end, true)

      -- Place seagrass or alga underwater
      util.nodefunc(
         upos, upos2,
         {"rp_default:water_source", "rp_default:swamp_water_source"},
         function(pos)
            if pr:next(1,2) == 1 then
               local posdn = vector.add(pos, vector.new(0,-1,0))
               local posup = vector.add(pos, vector.new(0,1,0))
               local ndn = minetest.get_node(posdn)
               local nup = minetest.get_node(posup)
               -- Alga may replaces seagrass if water is at least 2 nodes deep and if we're VERY lucky
               local alga = pr:next(1,100) == 1 and minetest.get_item_group(nup.name, "water") ~= 0
               local plant, p2
               if alga then
                  plant = "alga"
                  p2 = 16
               else
                  plant = "seagrass"
                  p2 = 0
               end
               if ndn.name == "rp_default:dirt" or ndn.name == "rp_default:dirt_with_grass" or ndn.name == "rp_default:dirt_with_dry_grass" then
                  minetest.set_node(posdn, {name="rp_default:"..plant.."_on_dirt", param2=p2})
               elseif ndn.name == "rp_default:swamp_dirt" or ndn.name == "rp_default:dirt_with_swamp_grass" then
                  minetest.set_node(posdn, {name="rp_default:"..plant.."_on_swamp_dirt", param2=p2})
               end
            end
      end, true)
end

-- Village modifier: Fills containers with goodies
local function village_modify_populate_containers(upos, upos2, pr, extras)
      -- Populate chests
      -- TODO: Damaged tools in abandoned villages
      util.nodefunc(
         upos, upos2,
         {"rp_default:chest", "rp_locks:chest"},
         function(pos)
            goodies.fill(pos, extras.chunktype, pr, "main", 3)
         end, true)

      -- Populate bookshelves
      util.nodefunc(
         upos, upos2,
         {"rp_default:bookshelf"},
         function(pos)
            goodies.fill(pos, "BOOKSHELF", pr, "main", 1)
         end, true)

      -- Populate furnaces
      if extras.chunktype == "forge" or extras.chunktype == "bakery" then
         local g_src, g_fuel, g_dst
         if extras.chunktype == "bakery" then
            g_src = "FURNACE_SRC_bakery"
            g_fuel = "FURNACE_FUEL_bakery"
            g_dst = "FURNACE_DST_bakery"
         else
            g_src = "FURNACE_SRC_general"
            g_fuel = "FURNACE_FUEL_general"
            g_dst = "FURNACE_DST_general"
         end
         util.nodefunc(
            upos, upos2,
            "rp_default:furnace",
            function(pos)
               goodies.fill(pos, g_src, pr, "src", 1)
               goodies.fill(pos, g_fuel, pr, "fuel", 1)
               goodies.fill(pos, g_dst, pr, "dst", 1)
               -- If both the src and fuel slots have an item,
               -- simulate the cooking process.
               -- We convert the src item into its cooked version,,,,
               -- put it into dst and reduce the fuel itemstack by 1.
               -- This prevents the furnace from going into
               -- active state when the village generates.
               local inv = minetest.get_meta(pos):get_inventory()
               local src = inv:get_stack("src", 1)
               local fuel = inv:get_stack("fuel", 1)
               if not src:is_empty() and not fuel:is_empty() then
                  local output = minetest.get_craft_result({method="cooking", items={src:get_name()}, width=1})
                  if output and not output.item:is_empty() then
                     local cooked = output.item
                     cooked:set_count(src:get_count()*cooked:get_count())
                     if cooked:get_count() > cooked:get_stack_max() then
                        cooked:set_count(cooked:set_stack_max())
                     end
                     inv:set_stack("src", 1, "")
                     inv:add_item("dst", cooked)
                     fuel:set_count(fuel:get_count()-1)
                     inv:set_stack("fuel", 1, fuel)
                  end
               end
            end, true)
      end
end

-- Village modifier: Limit number of music players in village to 1
local function village_modify_limit_music_players(upos, upos2, pr)
      -- Maximum of 1 music player per village; remove excess music players
      local music_players = 0
      util.nodefunc(
         upos, upos2,
         "rp_music:player",
         function(pos)
           if music_players >= 1 or pr:next(1,8) > 1 then
              minetest.remove_node(pos)
           else
              music_players = music_players + 1
           end
         end, true)
end

-- Village modifier: Randomly turn some chests into locked chests
local function village_modify_lock_chests(upos, upos2, pr)
      -- Replace 25% of chests with locked chests
      if mod_locks then
         util.nodefunc(
            upos, upos2,
            "rp_default:chest",
            function(pos)
               if pr:next(1,4) == 1 then
                  local node = minetest.get_node(pos)
                  node.name = "rp_locks:chest"
                  minetest.swap_node(pos, node)
               end
            end, true)
      end
end

local function after_village_area_emerged(blockpos, action, calls_remaining, params)
   local done = action == minetest.EMERGE_GENERATED or action == minetest.EMERGE_FROM_DISK or action == minetest.EMERGE_FROM_MEMORY
   if not done or calls_remaining > 0 then
      return
   end
   local vmanip = VoxelManip(params.emin, params.emax)
   local vmin, vmax = vmanip:get_emerged_area()
   local varea = VoxelArea:new({MinEdge=vmin, MaxEdge=vmax})
   local pos = params.pos
   local poshash = minetest.hash_node_position(pos)
   local pr = params.pr
   local ground = params.ground
   local ground_top = params.ground_top
   local force_place_starter = params.force_place_starter
   local is_abandoned = params.is_abandoned == true
   local village_name = params.village_name

   minetest.log("info", "[rp_village] Village area emerged at startpos = "..minetest.pos_to_string(pos))

   local depth = pr:next(village.min_size, village.max_size)

   local houses = {}
   local built = {}
   local roads = {}
   local state = {}

   state.is_abandoned = is_abandoned
   state.groundclass = "grassland"
   if ground_top == "rp_default:dirt_with_swamp_grass" or ground_top == "rp_default:swamp_dirt" then
      state.groundclass = "swamp"
   elseif ground_top == "rp_default:dirt_with_dry_grass" then
      state.groundclass = "savanna"
   elseif ground_top == "rp_default:dry_dirt" then
      state.groundclass = "dry"
   end

   local spawnpos = pos

   -- Get random village wood type for this village
   local vpr = PcgRandom(mapseed + poshash)
   local village_replace_id = vpr:next(1,#village_replaces)
   minetest.log("verbose", "[rp_village] village_replace_id="..village_replace_id)
   local replace = village_replaces[village_replace_id]
   local dirt_path = "rp_default:dirt_path"
   local dirt_path_slab = "rp_default:path_slab"

   -- For measuring the generation time
   local t1 = os.clock()

   built[poshash] = true

   -- Generate a road below the starting position. The road tries to grow in 4 directions
   -- growing either recursively more roads or buildings (where the road
   -- terminates)
   village.spawn_road(vmanip, pos, state, houses, built, roads, depth, pr, replace, true, vector.zero(), ground, ground_top)

   local function connects(pos, nextpos)
      local hnp = minetest.hash_node_position(nextpos)

      if houses[hnp] ~= nil and houses[hnp] ~= false then
	 if vector.equals(houses[hnp].front, pos) then
	    return true
	 end
      end

      if roads[hnp] ~= nil and roads[hnp] ~= false then
	 return true
      end

      if vector.equals(pos, nextpos) or vector.equals(nextpos, spawnpos) then
	 return true
      end
   end

   -- Add position of starter chunk to roads list to connect it properly with
   -- the road network.
   roads[poshash] = { pos = pos, is_starter = true }

   -- Connect dirt paths with other village tiles.
   -- The road schematic uses planks and cobble for each of the 4 cardinal
   -- directions and it will be replaced either with a dirt path or
   -- the ground.

   local c_path = minetest.get_content_id(dirt_path)
   local c_ground_top = minetest.get_content_id(ground_top)

   -- Generate road center tiles
   for _,road in pairs(roads) do
      -- No road center tile for starter chunk since we expect it to occupy the center
      if road ~= false and not road.is_starter then
         -- This only places the center of the road, the connections will be manually placed
         village.spawn_chunk(vmanip, road.pos, state, "0", {}, pr, "road", false, false, true, ground, ground_top)
      end
   end

   -- Iterate through the road tiles and determine where to place dirt path nodes and lamps

   -- Lamp positions
   local lamps = {}
   -- Store positions of nodes to replace, they will be set after the last village chunk
   -- was generated
   local road_bulk_set = {}

   for _,road in pairs(roads) do
   if road ~= false then
      local amt_connections = 0
      local all_nodes = {}
      for i = 1, 4 do
	 local nextpos = {x = road.pos.x, y = road.pos.y, z = road.pos.z}

	 if i == 1 then -- North (planks)
	    nextpos.z = nextpos.z + 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               table.insert(road_bulk_set, {vector.add(road.pos, {x=4, y=0, z=8}), vector.add(road.pos, {x=7,y=0,z=11}), c_path})
	    end
	 elseif i == 2 then -- East (cobble)
	    nextpos.x = nextpos.x + 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               table.insert(road_bulk_set, {vector.add(road.pos, {x=8, y=0, z=4}), vector.add(road.pos, {x=11, y=0, z=7}), c_path})
	    end
	 elseif i == 3 then -- South (oak planks)
	    nextpos.z = nextpos.z - 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               table.insert(road_bulk_set, {vector.add(road.pos, {x=4, y=0, z=0}), vector.add(road.pos, {x=7, y=0, z=3}), c_path})
	    end
	 else
	    nextpos.x = nextpos.x - 12 -- West (birch planks)
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               table.insert(road_bulk_set, {vector.add(road.pos, {x=0, y=0, z=4}), vector.add(road.pos, {x=3, y=0, z=7}), c_path})
	    end
	 end
      end


      if amt_connections >= 2 and not road.is_starter then
         table.insert(lamps, {x=road.pos.x, y=road.pos.y, z=road.pos.z})
      end
   end
   end

   -- Place lamp posts
   for l=1, #lamps do
      village.spawn_chunk(
         vmanip,
         lamps[l],
         state,
         "0",
         {},
         pr,
         "lamppost",
         true,
         true,
         true,
         ground,
         ground_top
         )
   end

   -- <<< FINAL VILLAGE CHUNK! >>>

   -- Check if this village has created any houses so far
   local has_house = false
   for k,v in pairs(houses) do
      if v ~= false then
         has_house = true
         break
      end
   end
   -- Place a building at the start position as the final step.
   -- Normally, this is the well.
   local chunk_ok
   if has_house then
      chunk_ok = village.spawn_chunk(vmanip, pos, state, "0", replace, pr, "well", true, nil, true, ground, ground_top)
   else
      -- Place a fallback building instead of the well if the village does not have any buildings yet.
      -- A nice side-effect of this is that this will create 'lonely huts'.
      local structure = random_chunktype(pr, village.chunktypes_start_fallback, state.groundclass)
      chunk_ok = village.spawn_chunk(vmanip, pos, state, "random", replace, pr, structure, true, nil, true, ground, ground_top)
      minetest.log("info", "[rp_village] Village generated with fallback building instead of well")
   end
   if not chunk_ok then
      minetest.log("warning", string.format("[rp_village] Failed to generated starter chunk at %s", minetest.pos_to_string(pos)))
   end

   -- <<< END OF VILLAGE CHUNK GENERATION >>>

   -- All village chunks have been generated!
   -- Now we apply changes to the VoxelManip data
   local vdata = vmanip:get_data()

   local vdata_bulk_set_node = function(vdata, varea, minpos, maxpos, content_id)
      for z=minpos.z, maxpos.z do
      for y=minpos.y, maxpos.y do
      for x=minpos.x, maxpos.x do
         local vindex = varea:index(x, y, z)
         vdata[vindex] = content_id
      end
      end
      end
   end

   -- Apply the road node replacements that were calculated above
   for r=1, #road_bulk_set do
      local rdata = road_bulk_set[r]
      vdata_bulk_set_node(vdata, varea, rdata[1], rdata[2], rdata[3])
   end

   -- Generate ground decorations (like grass)
   for d=1, #state.decors_to_place do
      -- We just iterate through the positions we have collected earlier
      local decor_info = state.decors_to_place[d]
      -- Check if this position is still valid for the decor. Prevents placing decorations
      -- in non-air nodes and if the floor node has changed (e.g. dirt path).
      if vdata[decor_info.index_decor] == minetest.CONTENT_AIR and vdata[decor_info.index_floor] == decor_info.content_floor then
          vdata[decor_info.index_decor] = decor_info.content_decor
      end
   end

   vmanip:set_data(vdata)

   -- The main village generation is complete here
   vmanip:write_to_map()
   vmanip:update_liquids()

   -- <<< END OF VOXELMANIP CHANGES >>>

   -- Final step: set node metadata (stuff that cannot be done in VManip)
   -- and perform other manipulations
   if state.nodeupdates then
   for u=1, #state.nodeupdates do
      local chunktype = state.nodeupdates[u].chunktype
      local upos = state.nodeupdates[u].pos
      local upos2 = vector.add(upos, vector.new(VILLAGE_CHUNK_SIZE, VILLAGE_CHUNK_SIZE, VILLAGE_CHUNK_SIZE))

      -- Replace random chests with locked chests
      village_modify_lock_chests(upos, upos2, pr)

      -- Maximum of 1 music player per village
      village_modify_limit_music_players(upos, upos2, pr)

      -- Village modifier: Abandoned village
      if state.is_abandoned then
         village_modify_abandoned_village(upos, upos2, pr, {path=dirt_path, path_slab=dirt_path_slab, ground_top=ground_top})
      end

      -- Force on_construct to be called on all nodes
      util.reconstruct(upos, upos2, pr)

      -- Fill containers with goodies
      village_modify_populate_containers(upos, upos2, pr, {chunktype=chunktype})

      -- Handle entity spawner nodes.
      -- In abandoned villages, remove all spawners and don't spawn anything.
      -- Otherwise, randomly spawn an entity at each
      -- spawner (chance of 1:chunkdef.entity_chance), then
      -- remove the spawner nodes.
      local chunkdef = village.chunkdefs[chunktype]
      if chunkdef ~= nil then
         if chunkdef.entities ~= nil then
	    if state.is_abandoned or (chunkdef.entity_chance ~= nil and pr:next(1, chunkdef.entity_chance) == 1) then
               -- Remove entity spawners
	       util.nodefunc(
	          upos, upos2,
	          "rp_village:entity_spawner",
	          function(pos)
		     minetest.remove_node(pos)
                  end)
            else
               local ent_spawns = {}

               -- Collect entitiy spawners
               util.nodefunc(
                  upos, upos2,
                  "rp_village:entity_spawner",
                  function(pos)
                     table.insert(ent_spawns, pos)
                  end, true)

               -- Initialize entity spawners
	       if #ent_spawns > 0 then
	          for ent, amt in pairs(chunkdef.entities) do
                     for j = 1, pr:next(1, amt) do
                        if #ent_spawns == 0 then
                           break
                        end
                        local spawn, index = util.choice_element(ent_spawns, pr)
                        if spawn ~= nil then
                           local meta = minetest.get_meta(spawn)
                           meta:set_string("entity", ent)
                           minetest.get_node_timer(spawn):start(1)
                           -- Prevent spawning on same tile
                           table.remove(ent_spawns, index)
                        end
                     end
                  end
               end
               -- Remove unused entity spawners
               for e=1, #ent_spawns do
                  minetest.remove_node(ent_spawns[e])
               end
            end
          end
       end
   end
   end

   minetest.log("action", string.format("[rp_village] Generated village '%s' at %s in %.2fms", village_name, minetest.pos_to_string(pos), (os.clock() - t1) * 1000))
   return true
end

function village.spawn_village(pos, pr, force_place_starter, ground, ground_top)
   if not ground then
      ground = "rp_default:dirt"
   end
   if not ground_top then
      ground_top = "rp_default:dirt_with_grass"
   end

   -- Before we begin, make sure there is enough space for the first chunk
   -- (unless force_place_starter is true)
   local empty = force_place_starter or check_empty(pos)
   if not empty then
      -- Oops! Not enough space. Village generation fails.
      minetest.log("action", "[rp_village] Village generation not done at "..minetest.pos_to_string(pos)..". Not enough space for the first village chunk")
      return false
   end

   -- Village generation can start!
   -- Set village init stuff
   local village_name = village.name.generate(pr, village.name.used)
   village.villages[village.get_id(village_name, pos)] = {
      name = village_name,
      pos = pos,
   }
   village.save_villages()
   village.load_waypoints()

   local spread = VILLAGE_CHUNK_SIZE * village.max_village_spread
   local vspread = vector.new(spread, spread, spread)
   local emerge_min = vector.add(pos, vector.new(-spread, -(HILL_H + HILL_EXTEND_BELOW + 1), -spread))
   local emerge_max = vector.add(pos, vector.new(spread, VILLAGE_CHUNK_HEIGHT, spread))
   -- chance for village to be abandoned
   local is_abandoned = pr:next(1,ABANDONED_CHANCE) == 1
   minetest.emerge_area(emerge_min, emerge_max, after_village_area_emerged, {
      pos=pos,
      pr=pr,
      force_place_starter=force_place_starter,
      ground=ground,ground_top=ground_top,
      village_name=village_name,
      emin=emerge_min,
      emax=emerge_max,
      is_abandoned=is_abandoned})
   return true
end

minetest.register_on_mods_loaded(village.load_villages)
