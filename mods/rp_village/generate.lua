
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

-- Savefile

local village_file = minetest.get_worldpath() .. "/villages.dat"

local modpath = minetest.get_modpath("rp_village")
local mod_locks = minetest.get_modpath("rp_locks") ~= nil
local mapseed = minetest.get_mapgen_setting("seed")
local water_level = tonumber(minetest.get_mapgen_setting("water_level"))

--[[ List of village wood materials (schematic replacements)
One of these will be chosen at random and it applies
for the whole world. ]]
local village_replaces = {
   -- Default (Birch + Oak, as specified in schematics)
   {
   },
   -- Birch → Normal (Normal + Oak)
   {
      ["rp_default:planks_birch"] = "rp_default:planks",
      ["rp_default:tree_birch"] = "rp_default:tree",
      ["rp_default:fence_birch"] = "rp_default:fence",
   },
   -- Oak → Normal (Normal + Birch)
   {
      ["rp_default:planks_oak"] = "rp_default:planks",
      ["rp_default:tree_oak"] = "rp_default:tree",
      ["rp_default:fence_oak"] = "rp_default:fence",
   },
   -- Normal wood only
   {
      ["rp_default:planks_birch"] = "rp_default:planks",
      ["rp_default:planks_oak"] = "rp_default:planks",
      ["rp_default:tree_birch"] = "rp_default:tree",
      ["rp_default:tree_oak"] = "rp_default:tree",
      ["rp_default:fence_birch"] = "rp_default:fence",
      ["rp_default:fence_oak"] = "rp_default:fence",
   },
   -- Birch wood only
   {
      ["rp_default:planks"] = "rp_default:planks_birch",
      ["rp_default:planks_oak"] = "rp_default:planks_birch",
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
      ["rp_default:tree"] = "rp_default:tree_oak",
      ["rp_default:tree_birch"] = "rp_default:tree_oak",
      ["rp_default:fence"] = "rp_default:fence_oak",
      ["rp_default:fence_birch"] = "rp_default:fence_oak",
      ["rp_door:door_wood_t_1"] = "rp_door:door_wood_oak_t_1",
      ["rp_door:door_wood_b_1"] = "rp_door:door_wood_oak_b_1",
   },
}

local village_replace_id

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

village.chunkdefs["livestock_pen"] = {
   entities = {
      ["mobs:sheep"] = 3,
      ["mobs:boar"] = 1,
   },
}
village.chunkdefs["lamppost"] = { -- not road because of road height limit of 1 nodes
   entity_chance = 2,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["well"] = {
   entities = {
      ["mobs:npc_farmer"] = 1,
      ["mobs:npc_tavernkeeper"] = 1,
   },
}
village.chunkdefs["house"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_carpenter"] = 1,
   },
}
village.chunkdefs["tavern"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_tavernkeeper"] = 1,
   },
}

village.chunkdefs["forge"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_blacksmith"] = 1,
   },
}
village.chunkdefs["orchard"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["farm"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["farm_wheat"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["farm_cotton"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}
village.chunkdefs["farm_papyrus"] = {
   entity_chance = 2,
   entities = {
      ["mobs:npc_farmer"] = 1,
   },
}

-- List of chunk types. Chunk types are structurs and buildings
-- that are not the well and are placed next to roads.
-- The number is their absolute frequency. The higher the number,
-- the more likely it will occur.
-- The well is not listed here because it acts as the start point.
village.chunktypes = {
   -- chunktype, absolute frequency
   { "house", 12 },
   { "tavern", 6 },
   { "forge", 6 },
   { "farm_wheat", 2 },
   { "farm_cotton", 2 },
   { "farm", 2 },
   { "farm_papyrus", 3 },
   { "livestock_pen", 3 },
   { "orchard", 3 },
}

-- List of chunktypes to be used as fallback for the starting
-- village chunk if the village failed to place any buildings
-- outside the starting point.
-- In this case, the "starter well" will be a house
-- instead. This will create nice "lonely huts".
village.chunktypes_start_fallback = {
   -- chunktype, absolute frequency
   { "house", 10 },
   { "tavern", 5 },
   { "forge", 2 },
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
local function random_chunktype(pr, chunktypes)
   if not chunktypes then
      chunktypes = village.chunktypes
   end
   local rnd = pr:next(1, chunktypes.chunksum)
   for i=1, #chunktypes do
      if rnd <= chunktypes[i][3] then
         return chunktypes[i][1]
      end
   end
   return chunktypes[#chunktypes][1]
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

function village.generate_hill(vmanip, vdata, pos, ground, ground_top)
   local c_ground = minetest.get_content_id(ground)
   local c_ground_top = minetest.get_content_id(ground_top)
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
               local vindex_above = varea:index(p.x,p.y+1,p.z)
               if vdata[vindex_above] == minetest.CONTENT_AIR then
                  vdata[vindex] = c_ground_top
               else
                  vdata[vindex] = c_ground
               end
            else
               vdata[vindex] = c_ground
            end
            if not prev_was_ground then
               nodes_set = nodes_set + 1
            end
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

function village.spawn_chunk(vmanip, pos, state, orient, replace, pr, chunktype, noclear, nofill, dont_check_empty, ground, ground_top)
   if not dont_check_empty and not check_empty(pos) then
      minetest.log("verbose", "[rp_village] Chunk not generated (too many stone/leaves/trees in the way) at "..minetest.pos_to_string(pos))
      return false
   end

   if nofill ~= true then
      local vdata = vmanip:get_data()
      -- Make a hill for the buildings to stand on
      local full_hill = village.generate_hill(vmanip, vdata, {x=pos.x-6, y=pos.y-5, z=pos.z-6}, ground, ground_top)

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


   local sreplace = table.copy(replace)
   if chunktype == "orchard" then
      sreplace["rp_default:tree"] = nil
   end
   local ok = minetest.place_schematic_on_vmanip(
      vmanip,
      pos,
      modpath .. "/schematics/village_" .. chunktype .. ".mts",
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

	    local structure = random_chunktype(pr)
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

local ROAD_NODE_NORTH = "rp_default:planks"
local ROAD_NODE_EAST = "rp_default:cobble"
local ROAD_NODE_SOUTH = "rp_default:planks_oak"
local ROAD_NODE_WEST = "rp_default:planks_birch"

local function after_village_area_emerged(blockpos, action, calls_remaining, params)
   local done = action == minetest.EMERGE_GENERATED or action == minetest.EMERGE_FROM_DISK or action == minetest.EMERGE_FROM_MEMORY
   if not done or calls_remaining > 0 then
      return
   end
   local vmanip = VoxelManip(params.emin, params.emax)
   local vmin, vmax = vmanip:get_emerged_area()
   local varea = VoxelArea:new({MinEdge=vmin, MaxEdge=vmax})
   local pos = params.pos
   local pr = params.pr
   local ground = params.ground
   local ground_top = params.ground_top
   local force_place_starter = params.force_place_starter
   local village_name = params.village_name

   minetest.log("info", "[rp_village] Village area emerged at startpos = "..minetest.pos_to_string(pos))

   local depth = pr:next(village.min_size, village.max_size)

   local houses = {}
   local built = {}
   local roads = {}
   local state = {}

   local spawnpos = pos

   -- Get village wood type based on mapseed. All villages in the world
   -- will have the same style.
   -- This is done because the schematic replacements cannot be changed
   -- once the schematic was loaded.
   if not village_replace_id then
      local vpr = PseudoRandom(mapseed)
      village_replace_id = vpr:next(1,#village_replaces)
   end
   local replace = village_replaces[village_replace_id]
   local dirt_path = "rp_default:dirt_path"

   -- For measuring the generation time
   local t1 = os.clock()

   built[minetest.hash_node_position(pos)] = true

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
   local hnp = minetest.hash_node_position(pos)
   roads[hnp] = { pos = pos, is_starter = true }

   -- Connect dirt paths with other village tiles.
   -- The dirt path schematic uses planks and cobble for each of the 4 cardinal
   -- directions and it will be replaced either with a dirt path or
   -- the ground.

   local c_path = minetest.get_content_id(dirt_path)
   local c_ground_top = minetest.get_content_id(ground_top)
   local c_road_north = minetest.get_content_id(ROAD_NODE_NORTH)
   local c_road_west = minetest.get_content_id(ROAD_NODE_WEST)
   local c_road_south = minetest.get_content_id(ROAD_NODE_SOUTH)
   local c_road_east = minetest.get_content_id(ROAD_NODE_EAST)

   local vdata_bulk_set_node = function(vdata, varea, minpos, maxpos, content_id, check_for_road)
      for z=minpos.z, maxpos.z do
      for y=minpos.y, maxpos.y do
      for x=minpos.x, maxpos.x do
         local vindex = varea:index(x, y, z)
	 if check_for_road then
            local content = vdata[vindex]
	    if content == c_road_north or content == c_road_west or content == c_road_south or content == c_road_east then
               vdata[vindex] = content_id
            end
	 else
            vdata[vindex] = content_id
         end
      end
      end
      end
   end

   for _,road in pairs(roads) do
   if road ~= false then
      village.spawn_chunk(vmanip, road.pos, state, "0", {}, pr, "road", false, false, true, ground, ground_top)
   end
   end

   local vdata = vmanip:get_data()
   local lamps = {}

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
               vdata_bulk_set_node(vdata, varea, vector.add(road.pos, {x=4,y=0,z=8}), vector.add(road.pos, {x=7,y=0,z=11}), c_path)
	    end
	 elseif i == 2 then -- East (cobble)
	    nextpos.x = nextpos.x + 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               vdata_bulk_set_node(vdata, varea, vector.add(road.pos, {x=8,y=0,z=4}), vector.add(road.pos, {x=11,y=0,z=7}), c_path)
	    end
	 elseif i == 3 then -- South (oak planks)
	    nextpos.z = nextpos.z - 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               vdata_bulk_set_node(vdata, varea, vector.add(road.pos, {x=4,y=0,z=0}), vector.add(road.pos, {x=7,y=0,z=3}), c_path)
	    end
	 else
	    nextpos.x = nextpos.x - 12 -- West (birch planks)
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               vdata_bulk_set_node(vdata, varea, vector.add(road.pos, {x=0,y=0,z=4}), vector.add(road.pos, {x=3,y=0,z=7}), c_path)
	    end
	 end

      end
      vdata_bulk_set_node(vdata, varea, road.pos, vector.add(road.pos, {x=11,y=0,z=11}), c_ground_top, true)


      if amt_connections >= 2 and not road.is_starter then
         table.insert(lamps, {x=road.pos.x, y=road.pos.y, z=road.pos.z})
      end
   end
   end

   vmanip:set_data(vdata)

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

   -- Check if this village has created any houses so far
   local has_house = false
   for k,v in pairs(houses) do
      if v ~= false then
         has_house = true
      end
   end
   local chunk_ok
   -- Place a building at the start position as the final step.
   -- Normally this is the well
   if has_house then
      chunk_ok = village.spawn_chunk(vmanip, pos, state, "0", replace, pr, "well", true, nil, true, ground, ground_top)
   else
      -- Place a fallback building instead of the well if the village does not have any buildings yet.
      -- A nice side-effect of this is that this will create 'lonely huts'.
      local structure = random_chunktype(pr, village.chunktypes_start_fallback)
      chunk_ok = village.spawn_chunk(vmanip, pos, state, "random", replace, pr, structure, true, nil, true, ground, ground_top)
      minetest.log("info", "[rp_village] Village generated with fallback building instead of well")
   end
   if not chunk_ok then
      minetest.log("warning", string.format("[rp_village] Failed to generated starter chunk at %s", minetest.pos_to_string(pos)))
   end

   -- The main village generation is complete here
   vmanip:write_to_map()
   vmanip:update_liquids()

   -- Final step: set node metadata (stuff that cannot be done in VManip)
   if state.nodeupdates then
   for u=1, #state.nodeupdates do
      local upos = state.nodeupdates[u].pos
      local upos2 = vector.add(upos, vector.new(VILLAGE_CHUNK_SIZE, VILLAGE_CHUNK_SIZE, VILLAGE_CHUNK_SIZE))
      local chunktype = state.nodeupdates[u].chunktype
      -- Replace some chests with locked chests
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

      -- Force on_construct to be called
      util.reconstruct(upos, upos2)

      -- Populate chests
      util.nodefunc(
         upos, upos2,
         {"rp_default:chest", "rp_locks:chest"},
         function(pos)
            goodies.fill(pos, chunktype, pr, "main", 3)
         end, true)

      -- Populate furnaces
      if chunktype == "forge" then
         util.nodefunc(
            upos, upos2,
            "rp_default:furnace",
            function(pos)
               goodies.fill(pos, "FURNACE_SRC", pr, "src", 1)
               goodies.fill(pos, "FURNACE_DST", pr, "dst", 1)
               goodies.fill(pos, "FURNACE_FUEL", pr, "fuel", 1)
            end, true)
      end

      -- Maximum of 1 music player per village
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

      -- Set entity spawner metadata
      local chunkdef = village.chunkdefs[chunktype]
      if chunkdef ~= nil then
         if chunkdef.entities ~= nil then
	    if chunkdef.entity_chance ~= nil and pr:next(1, chunkdef.entity_chance) == 1 then
               -- Remove some entity spawners
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
   minetest.emerge_area(emerge_min, emerge_max, after_village_area_emerged, {pos=pos, pr=pr, force_place_starter=force_place_starter, ground=ground, ground_top=ground_top, village_name=village_name, emin=emerge_min, emax=emerge_max})
   return true
end

minetest.register_on_mods_loaded(village.load_villages)
