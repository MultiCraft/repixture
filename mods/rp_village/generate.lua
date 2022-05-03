
--
-- Single village generation
--

village.villages = {}

-- Sidelength of the square of a village chunk, in nodes
local VILLAGE_CHUNK_SIZE = 14
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
      ["default:planks_birch"] = "rp_default:planks",
      ["default:tree_birch"] = "rp_default:tree",
      ["default:fence_birch"] = "rp_default:fence",
   },
   -- Oak → Normal (Normal + Birch)
   {
      ["default:planks_oak"] = "rp_default:planks",
      ["default:tree_oak"] = "rp_default:tree",
      ["default:fence_oak"] = "rp_default:fence",
   },
   -- Normal wood only
   {
      ["default:planks_birch"] = "rp_default:planks",
      ["default:planks_oak"] = "rp_default:planks",
      ["default:tree_birch"] = "rp_default:tree",
      ["default:tree_oak"] = "rp_default:tree",
      ["default:fence_birch"] = "rp_default:fence",
      ["default:fence_oak"] = "rp_default:fence",
   },
   -- Birch wood only
   {
      ["default:planks"] = "rp_default:planks_birch",
      ["default:planks_oak"] = "rp_default:planks_birch",
      ["default:tree"] = "rp_default:tree_birch",
      ["default:tree_oak"] = "rp_default:tree_birch",
      ["default:fence"] = "rp_default:fence_birch",
      ["default:fence_oak"] = "rp_default:fence_birch",
   },
   -- Oak wood only
   {
      ["default:planks"] = "rp_default:planks_oak",
      ["default:planks_birch"] = "rp_default:planks_oak",
      ["default:tree"] = "rp_default:tree_oak",
      ["default:tree_birch"] = "rp_default:tree_oak",
      ["default:fence"] = "rp_default:fence_oak",
      ["default:fence_birch"] = "rp_default:fence_oak"
   },
}

local village_replace_id

function village.get_id(name, pos)
   return name .. minetest.hash_node_position(pos)
end

function village.save_villages()
   local f = io.open(village_file, "w")

   for name, def in pairs(village.villages) do
      f:write(name .. " " .. def.name .. " "
                 .. minetest.hash_node_position(def.pos) .. "\n")
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
   local npos = nil
   local fname = nil

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

-- Calculate cumulated absolute frequency and put it in index 3
local chunksum = 0
for i=1, #village.chunktypes do
   chunksum = chunksum + village.chunktypes[i][2]
   village.chunktypes[i][3] = chunksum
end

-- Select a random chunk. The probability of a chunk being selected is
-- <absolute frequency> / <sum of all absolute frequencies>
local function random_chunktype(pr)
   local rnd = pr:next(1, chunksum)
   for i=1, #village.chunktypes do
      if rnd <= village.chunktypes[i][3] then
         return village.chunktypes[i][1]
      end
   end
   return village.chunktypes[#village.chunktypes][1]
end

function village.get_column_nodes(pos, scanheight, dirtnodes)
   local nn = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name
   local nd = minetest.registered_nodes[nn]
   if (not nd) or (not nd.is_ground_content and minetest.registered_nodes[nn].liquidtype == "none" and nn ~= "ignore") then
       return
   end

   for y = pos.y, pos.y - scanheight, -1 do
      local p = {x = pos.x, y = y, z = pos.z}

      nn = minetest.get_node(p).name
      nd = minetest.registered_nodes[nn]
      if (not nd) or (not nd.is_ground_content and minetest.registered_nodes[nn].liquidtype == "none" and nn ~= "ignore") then
         break
      else
         table.insert(dirtnodes, p)
      end
   end
end

function village.generate_hill(pos)
   local dirts = {}
   local dirts_with_grass = {}
   for y=0,HILL_H-1 do
   for z=y,HILL_W-1-y do
   for x=y,HILL_W-1-y do
      local p = {x=pos.x+x, y=pos.y+y, z=pos.z+z}
      local n = minetest.get_node(p)
      local def = minetest.registered_nodes[n.name]
      if n.name == "air" or n.name == "ignore" or (def and (def.liquidtype ~= "none" or (def.is_ground_content))) then
         if (y == HILL_H-1 or z == y or x == y or z == HILL_W-1-y or x == HILL_W-1-y) and (p.y >= water_level) then
            table.insert(dirts_with_grass, p)
         else
            table.insert(dirts, p)
         end
      end
   end
   end
   end
   minetest.bulk_set_node(dirts, {name="rp_default:dirt"})
   minetest.bulk_set_node(dirts_with_grass, {name="rp_default:dirt_with_grass"})
end

local function check_empty(pos)
   local min = { x = pos.x, y = pos.y + 1, z = pos.z }
   local max = { x = pos.x+12, y = pos.y+12, z = pos.z+12 }
   local stones = minetest.find_nodes_in_area(min, max, "group:stone")
   local leaves = minetest.find_nodes_in_area(min, max, "group:leaves")
   local trees = minetest.find_nodes_in_area(min, max, "group:tree")
   return #stones <= 15 and #leaves <= 2 and #trees == 0
end

function village.spawn_chunk(pos, state, orient, replace, pr, chunktype, nofill, dont_check_empty)
   if not dont_check_empty and not check_empty(pos) then
      minetest.log("verbose", "[rp_village] Chunk not generated (too many stone/leaves/trees in the way) at "..minetest.pos_to_string(pos))
      return false, state
   end
   if not state then
      state = { music_players = 0 }
   end

   util.getvoxelmanip(pos, {x = pos.x+12, y = pos.y+12, z = pos.z+12})

   if nofill ~= true then
      -- Make a hill for the building to stand on
      village.generate_hill({x=pos.x-6, y=pos.y-5, z=pos.z-6})

      local py = pos.y-6
      local dirtnodes = {}
      -- Extend the dirt below the hill, in case the hill is floating
      -- in mid-air
      for z=pos.z-6, pos.z+17 do
      for x=pos.x-6, pos.x+17 do
          village.get_column_nodes({x=x, y=py, z=z}, HILL_EXTEND_BELOW, dirtnodes)
      end
      end
      minetest.bulk_set_node(dirtnodes, {name="rp_default:dirt"})

      minetest.place_schematic(
	 pos,
	 modpath .. "/schematics/village_empty.mts",
	 "0",
	 {},
	 true
      )

   end

   local sreplace = table.copy(replace)
   if chunktype == "orchard" then
      sreplace["default:tree"] = nil
   end
   minetest.place_schematic(
      pos,
      modpath .. "/schematics/village_" .. chunktype .. ".mts",
      orient,
      sreplace,
      true
   )

   util.fixlight(pos, {x = pos.x+12, y = pos.y+12, z = pos.z+12})

   -- Replace some chests with locked chests
   if mod_locks then
      util.nodefunc(
         pos,
         {x = pos.x+12, y = pos.y+12, z = pos.z+12},
         "rp_default:chest",
         function(pos)
            if pr:next(1,4) == 1 then
               local node = minetest.get_node(pos)
               node.name = "rp_locks:chest"
               minetest.swap_node(pos, node)
            end
         end, true)
   end

   util.reconstruct(pos, {x = pos.x+12, y = pos.y+12, z = pos.z+12})

   util.nodefunc(
      pos,
      {x = pos.x+12, y = pos.y+12, z = pos.z+12},
      {"rp_default:chest", "rp_locks:chest"},
      function(pos)
         goodies.fill(pos, chunktype, pr, "main", 3)
      end, true)

   -- Maximum of 1 music player per village
   util.nodefunc(
      pos,
      {x = pos.x+12, y = pos.y+12, z = pos.z+12},
      "rp_music:player",
      function(pos)
	 if state.music_players >= 1 or pr:next(1,8) > 1 then
	    minetest.remove_node(pos)
	 else
	    state.music_players = state.music_players + 1
	 end
      end, true)

   -- Replace legacy torches
   -- TODO: Fix the torches in the schematic instead
   util.nodefunc(
      pos,
      {x = pos.x+12, y = pos.y+12, z = pos.z+12},
      "rp_default:torch",
      function(pos)
	 local node = minetest.get_node(pos)
         local dir = minetest.wallmounted_to_dir(node.param2)
         if dir.x ~= 0 or dir.z ~= 0 then
            node.name = "rp_default:torch_wall"
            minetest.set_node(pos, node)
         end
      end, true)



   local chunkdef = village.chunkdefs[chunktype]
   if chunkdef ~= nil then
      if chunkdef.entities ~= nil then
	 if chunkdef.entity_chance ~= nil and pr:next(1, chunkdef.entity_chance) == 1 then
	    util.nodefunc(
	       pos,
	       {x = pos.x+12, y = pos.y+12, z = pos.z+12},
	       "village:entity_spawner",
	       function(pos)
		  minetest.remove_node(pos)
            end)
	    return true, state
	 end

	 local ent_spawns = {}

	 util.nodefunc(
	    pos,
	    {x = pos.x+12, y = pos.y+12, z = pos.z+12},
	    "village:entity_spawner",
	    function(pos)
	       table.insert(ent_spawns, pos)
	    end, true)

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

   if chunktype == "forge" then
      util.nodefunc(
	 pos,
	 {x = pos.x+12, y = pos.y+12, z = pos.z+12},
	 "rp_default:furnace",
	 function(pos)
	    goodies.fill(pos, "FURNACE_SRC", pr, "src", 1)
	    goodies.fill(pos, "FURNACE_DST", pr, "dst", 1)
	    goodies.fill(pos, "FURNACE_FUEL", pr, "fuel", 1)
	 end, true)
   end
   minetest.log("verbose", "[rp_village] Chunk generated at "..minetest.pos_to_string(pos))
   return true, state
end

function village.spawn_road(pos, state, houses, built, roads, depth, pr, replace, dont_check_empty, dist_from_start)
   if not dont_check_empty and not check_empty(pos) then
      minetest.log("verbose", "[rp_village] Road not generated (too many stone/leaves/trees in the way) at "..minetest.pos_to_string(pos))
      return false, state
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
	    chunk_ok, state = village.spawn_chunk(nextpos, state, orient, replace, pr, structure)
            if not chunk_ok then
               houses[hnp] = false
            end
	 else
	    roads[hnp] = {pos = nextpos}
	    chunk_ok, state = village.spawn_road(nextpos, state, houses, built, roads, depth - 1, pr, replace, false, new_dist_from_start)
            if not chunk_ok then
               roads[hnp] = false
            end
	 end
      end
   end
   return true, state
end

function after_village_area_emerged(blockpos, action, calls_remaining, params)
   local done = action == minetest.EMERGE_GENERATED or action == minetest.EMERGE_FROM_DISK or action == minetest.EMERGE_FROM_MEMORY
   if not done or calls_remaining > 0 then
      return
   end
   local pos = params.pos
   local pr = params.pr
   local force_place_well = params.force_place_well

   minetest.log("info", "[rp_village] Village area emerged at startpos = "..minetest.pos_to_string(pos))

   local name = village.name.generate(pr)

   local depth = pr:next(village.min_size, village.max_size)

   local houses = {}
   local built = {}
   local roads = {}

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
   local dirt_path = "rp_default:heated_dirt_path"

   -- For measuring the generation time
   local t1 = os.clock()

   -- Every village generation starts with a well.
   local chunk_ok, state = village.spawn_chunk(pos, nil, "0", replace, pr, "well", nil, force_place_well == true)
   if not chunk_ok then
      -- Oops! Not enough space for the well. Village generation fails.
      minetest.log("action", "[rp_village] Village generation not done at "..minetest.pos_to_string(pos)..". Not enough space")
      return false
   end

   village.villages[village.get_id(name, pos)] = {
      name = name,
      pos = pos,
   }
   village.save_villages()
   village.load_waypoints()
   built[minetest.hash_node_position(pos)] = true

   local wellpos = table.copy(pos)

   -- Generate a road below the well. The road tries to grow in 4 directions
   -- growing either recursively more roads or buildings (where the road
   -- terminates)
   local _, state = village.spawn_road(pos, state, houses, built, roads, depth, pr, replace, true, vector.zero())

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

   -- Add position of well to roads list to connect it properly with
   -- the road network.
   local hnp = minetest.hash_node_position(wellpos)
   roads[hnp] = { pos = wellpos, is_well = true }

   -- Connect dirt paths with other village tiles.
   -- The dirt path schematic uses planks and cobble for each of the 4 cardinal
   -- directions and it will be replaced either with a dirt path or
   -- the ground.

   for _,road in pairs(roads) do
   if road ~= false then

      local replaces = {
	 ["default:planks"]       = "rp_default:dirt_with_grass", -- north
	 ["default:cobble"]       = "rp_default:dirt_with_grass", -- east
	 ["default:planks_oak"]   = "rp_default:dirt_with_grass", -- south
	 ["default:planks_birch"] = "rp_default:dirt_with_grass"  -- west
      }

      if not road.is_well then
         _, state = village.spawn_chunk(road.pos, state, "0", replaces, pr, "road")
      end

      local amt_connections = 0

      for i = 1, 4 do
	 local nextpos = {x = road.pos.x, y = road.pos.y, z = road.pos.z}

	 if i == 1 then
	    nextpos.z = nextpos.z + 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               local nodes = minetest.find_nodes_in_area(vector.add(road.pos, {x=4, y=0, z=8}), vector.add(road.pos, {x=7,y=0,z=11}), {"rp_default:dirt_with_grass"})
               minetest.bulk_set_node(nodes, {name=dirt_path})
	    end
	 elseif i == 2 then
	    nextpos.x = nextpos.x + 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               local nodes = minetest.find_nodes_in_area(vector.add(road.pos, {x=8, y=0, z=4}), vector.add(road.pos, {x=11,y=0,z=7}), {"rp_default:dirt_with_grass"})
               minetest.bulk_set_node(nodes, {name=dirt_path})
	    end
	 elseif i == 3 then
	    nextpos.z = nextpos.z - 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               local nodes = minetest.find_nodes_in_area(vector.add(road.pos, {x=4, y=0, z=0}), vector.add(road.pos, {x=7,y=0,z=3}), {"rp_default:dirt_with_grass"})
               minetest.bulk_set_node(nodes, {name=dirt_path})
	    end
	 else
	    nextpos.x = nextpos.x - 12
	    if connects(road.pos, nextpos) then
               amt_connections = amt_connections + 1
               local nodes = minetest.find_nodes_in_area(vector.add(road.pos, {x=0, y=0, z=4}), vector.add(road.pos, {x=3,y=0,z=7}), {"rp_default:dirt_with_grass"})
               minetest.bulk_set_node(nodes, {name=dirt_path})
	    end
	 end

      end

      if amt_connections >= 2 and not road.is_well then
	 village.spawn_chunk(
	    {x = road.pos.x, y = road.pos.y+1, z = road.pos.z},
	    state,
	    "0",
	    {},
	    pr,
	    "lamppost",
	    true,
	    true
         )
      end
   end
   end
   minetest.log("action", string.format("[rp_village] Generated village '%s' at %s in %.2fms", name, minetest.pos_to_string(pos), (os.clock() - t1) * 1000))
   return true
end

function village.spawn_village(pos, pr, force_place_well)
   local spread = VILLAGE_CHUNK_SIZE * village.max_village_spread
   local vspread = vector.new(spread, spread, spread)
   local emerge_min = vector.add(pos, vector.new(-spread, -(HILL_H + HILL_EXTEND_BELOW + 1), -spread))
   local emerge_max = vector.add(pos, vector.new(spread, VILLAGE_CHUNK_HEIGHT, spread))
   minetest.emerge_area(emerge_min, emerge_max, after_village_area_emerged, {pos=pos, pr=pr, force_place_well=force_place_well})

end

minetest.register_on_mods_loaded(village.load_villages)
