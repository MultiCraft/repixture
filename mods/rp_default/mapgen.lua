
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

--[[ BIOMES ]]

minetest.clear_registered_biomes()

local mg_name = minetest.get_mapgen_setting("mg_name")

if mg_name ~= "v6" then

minetest.register_biome(
   {
      name = "Marsh",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_cave_liquid = "rp_default:swamp_water_source",

      depth_filler = 0,
      depth_top = 1,

      y_min = 2,
      y_max = 7,

      heat_point = 35,
      humidity_point = 55,
})

minetest.register_biome(
   {
      name = "Swamp",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",

      depth_filler = 7,
      depth_top = 1,

      y_min = 2,
      y_max = 7,

      heat_point = 30,
      humidity_point = 42,
})

minetest.register_biome(
   {
      name = "Deep Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 6,
      depth_top = 1,

      y_min = 30,
      y_max = 40,

      heat_point = 33,
      humidity_point = 40,
})

minetest.register_biome(
   {
      name = "Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 6,
      depth_top = 1,

      y_min = 2,
      y_max = 200,

      heat_point = 35,
      humidity_point = 40,
})

minetest.register_biome(
   {
      name = "Grove",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 4,
      depth_top = 1,

      y_min = 3,
      y_max = 32000,

      heat_point = 40,
      humidity_point = 38,
})

minetest.register_biome(
   {
      name = "Wilderness",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 6,
      depth_top = 1,

      y_min = 3,
      y_max = 32000,

      heat_point = 46,
      humidity_point = 35,
})

minetest.register_biome(
   {
      name = "Grassland",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 4,
      depth_top = 1,

      y_min = 3,
      y_max = 20,

      heat_point = 50,
      humidity_point = 33,
})

minetest.register_biome(
   {
      name = "Orchard",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 4,
      depth_top = 1,

      y_min = 21,
      y_max = 32000,

      heat_point = 50,
      humidity_point = 33,
})

minetest.register_biome(
   {
      name = "Chaparral",

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",

      depth_filler = 0,
      depth_top = 1,

      y_min = 56,
      y_max = 32000,

      heat_point = 60,
      humidity_point = 30,
})

minetest.register_biome(
   {
      name = "Savanna",

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",

      depth_filler = 2,
      depth_top = 1,

      y_min = 1,
      y_max = 55,

      heat_point = 60,
      humidity_point = 25,
})

minetest.register_biome(
   {
      name = "Desert",

      node_top = "rp_default:sand",
      node_filler = "rp_default:sandstone",

      depth_filler = 8,
      depth_top = 3,

      y_min = 1,
      y_max = 32000,

      heat_point = 75,
      humidity_point = 20,
})

minetest.register_biome(
   {
      name = "Wasteland",

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:sandstone",

      depth_filler = 3,
      depth_top = 1,

      y_min = -32000,
      y_max = 32000,

      heat_point = 80,
      humidity_point = 20,
})

-- Oceans

minetest.register_biome(
   {
      name = "Grassland Ocean",

      node_top = "rp_default:sand",
      node_filler = "rp_default:dirt",

      depth_filler = 1,
      depth_top = 3,

      y_min = -32000,
      y_max = 2,

      heat_point = 50,
      humidity_point = 35,
})

minetest.register_biome(
   {
      name = "Gravel Beach",

      node_top = "rp_default:gravel",
      node_filler = "rp_default:sand",

      depth_filler = 2,
      depth_top = 1,

      y_min = -5,
      y_max = 1,

      heat_point = 59,
      humidity_point = 31,
})

minetest.register_biome(
   {
      name = "Savanna Ocean",

      node_top = "rp_default:dirt",
      node_filler = "dfault:dirt",

      depth_filler = 0,
      depth_top = 1,

      y_min = -32000,
      y_max = 0,

      heat_point = 60,
      humidity_point = 30,
})
end

local function spring_ore_np(seed)
	return {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = seed or 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
end

-- Water

minetest.register_ore( -- Springs
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Grassland"},
      clust_scarcity = 26*26*26,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = 20,
      y_max          = 31000,
      noise_params   = spring_ore_np(),
})

minetest.register_ore( -- Pools
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Wilderness"},
      clust_scarcity = 32*32*32,
      clust_num_ores = 20,
      clust_size     = 6,
      y_min          = 10,
      y_max          = 30,
      noise_params   = spring_ore_np(),
})
if mg_name ~= "v6" then
minetest.register_ore( -- Swamp (big springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Swamp"},
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(13943),
})
minetest.register_ore( -- Swamp (medium springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Swamp"},
      clust_scarcity = 5*5*5,
      clust_num_ores = 8,
      clust_size     = 2,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(49494),
})

minetest.register_ore( -- Swamp (small springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Swamp"},
      clust_scarcity = 6*6*6,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(59330),
})

minetest.register_ore( -- Marsh
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      biomes         = {"Marsh"},
      clust_scarcity = 8*8*8,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(),
})
end


--[[ DECORATIONS ]]
-- The decorations are roughly ordered by size;
-- largest decorations first.

-- Tree decorations

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      replacements = {
         ["default:leaves"] = "rp_default:leaves_birch",
         ["default:tree"] = "rp_default:tree_birch",
         ["default:apple"] = "air"
      },
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_squaretree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.007,
      biomes = {"Orchard"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_appletree.mts",
      y_min = 10,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.009,
      biomes = {"Forest", "Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_appletree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.008,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_megatree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      name = "rp_default:gigatree",
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.023,
      biomes = {"Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_gigatree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      replacements = {
         ["default:apple"] = "air",
      },
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_appletree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_oaktree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.0008,
      biomes = {"Swamp"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_oak.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_talltree.mts",
      y_min = 0,
      y_max = 32000,
})

end

-- Cactus decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:sand"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Desert"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/default_cactus.mts",
      y_min = 10,
      y_max = 500,
      rotation = "random",
})

-- Rock decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_small_rock.mts",
      replacements = {["default:dirt"] = "rp_default:dry_dirt"},
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/default_large_rock.mts",
      replacements = {["default:dirt"] = "rp_default:dry_dirt"},
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})

-- Sulfur decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dry_dirt",
      sidelen = 16,
      fill_ratio = 0.005,
      biomes = {"Wasteland"},
      decoration = {"rp_default:stone_with_sulfur"},
      y_min = 2,
      y_max = 14,
})

-- Bush/shrub decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.005,
      biomes = {"Savanna", "Chaparral"},
      flags = "place_center_x, place_center_z",
      replacements = {["default:leaves"] = "rp_default:dry_leaves"},
      schematic = minetest.get_modpath("rp_default") .. "/schematics/default_shrub.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.06,
      biomes = {"Chaparral"},
      flags = "place_center_x, place_center_z",
      replacements = {["default:leaves"] = "rp_default:dry_leaves"},
      schematic = minetest.get_modpath("rp_default") .. "/schematics/default_dry_bush.mts",
      y_min = 0,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wilderness", "Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/default_bush.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})

-- Thistle decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.024,
      biomes = {"Wilderness"},
      decoration = {"rp_default:thistle"},
      height = 2,
      y_min = -32000,
      y_max = 32000,
})

-- Papyrus decorations

-- Beach papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:dirt", "rp_default:dirt_with_grass"},
      spawn_by = {"rp_default:water_source", "rp_default:water_flowing"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland Ocean", "Grassland", "Forest", "Deep Forest", "Wilderness"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      y_max = 3,
      y_min = 0,
})

-- Grassland papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dirt_with_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland", "Marsh", "Forest", "Deep Forest", "Wilderness"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      height_max = 3,
      y_max = 30,
      y_min = 4,
})


-- Swamp papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:swamp_dirt", "rp_default:dirt_with_swamp_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.30,
      biomes = {"Swamp"},
      decoration = {"rp_default:papyrus"},
      height = 3,
      height_max = 4,
      y_max = 31000,
      y_min = -100,
})

-- Flower decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Grassland", "Wilderness", "Orchard"},
      decoration = {"rp_default:flower"},
      y_min = -32000,
      y_max = 32000,
})

-- Grass decorations

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.18,
      biomes = {"Grassland", "Orchard"},
      decoration = {"rp_default:grass"},
      y_min = 10,
      y_max = 32000,
})
end

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_swamp_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Swamp"},
      decoration = {"rp_default:swamp_grass"},
      y_min = 2,
      y_max = 40,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_dry_grass",
      sidelen = 16,
      fill_ratio = 0.07,
      biomes = {"Desert", "Savanna", "Chaparral"},
      decoration = {"rp_default:dry_grass"},
      y_min = 10,
      y_max = 500,
})

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Forest", "Deep Forest"},
      decoration = {"rp_default:grass"},
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Forest", "Marsh", "Grove"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.15,
      biomes = {"Deep Forest"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = 32000,
})
end

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.16,
      biomes = {"Wilderness"},
      decoration = {"rp_default:grass"},
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.12,
      biomes = {"Wilderness"},
      decoration = {"rp_default:tall_grass"},
      y_min = -32000,
      y_max = 32000,
})

-- Fern decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Wilderness", "Grove"},
      decoration = {"rp_default:fern"},
      y_min = -32000,
      y_max = 32000,
})

-- Clam decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:gravel"},
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Grassland Ocean", "Gravel Beach"},
      decoration = {"rp_default:clam"},
      y_min = 0,
      y_max = 1,
})


--[[ ORES ]]

-- Graphite ore

minetest.register_ore( -- Common above sea level mainly
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 9*9*9,
      clust_num_ores = 8,
      clust_size     = 8,
      y_min          = -8,
      y_max          = 32,
})

minetest.register_ore( -- Slight scattering deeper down
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 6,
      clust_size     = 8,
      y_min          = -31000,
      y_max          = -32,
})

-- Coal ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 10*10*10,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 32,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 8,
      y_min          = -40,
      y_max          = -32,
})

minetest.register_ore( -- Deep ore sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 26,
      clust_size     = 12,
      y_min          = -130,
      y_max          = -120,
})

-- Iron ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 12*12*12,
      clust_num_ores = 4,
      clust_size     = 3,
      y_min          = -31000,
      y_max          = -8,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 20,
      clust_size     = 12,
      y_min          = -32,
      y_max          = -24,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 17,
      clust_size     = 6,
      y_min          = -80,
      y_max          = -60,
})

-- Tin ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 14*14*14,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = -100,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = -150,
      y_max          = -140,
})

-- Copper ore

minetest.register_ore( -- Begin sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 12,
      clust_size     = 5,
      y_min          = -90,
      y_max          = -80,
})

minetest.register_ore( -- Rare even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 10,
      clust_size     = 5,
      y_min          = -31000,
      y_max          = -90,
})

minetest.register_ore( -- Large clusters
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 22,
      clust_size     = 10,
      y_min          = -230,
      y_max          = -180,
})
