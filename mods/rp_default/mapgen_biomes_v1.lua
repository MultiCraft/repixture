--[[ BIOMES, version 1 (Repixture 2.1.0) ]]

minetest.clear_registered_biomes()

local mg_name = minetest.get_mapgen_setting("mg_name")

if mg_name ~= "v6" then

minetest.register_biome(
   {
      name = "Marsh",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",

      depth_filler = 0,
      depth_top = 1,

      y_min = 2,
      y_max = 6,

      heat_point = 35,
      humidity_point = 55,
})

minetest.register_biome(
   {
      name = "Swamp Meadow",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",

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

-- Underwater biomes (previously Ocean)

minetest.register_biome(
   {
      name = "Grassland Underwater",

      node_top = "rp_default:sand",
      node_filler = "rp_default:dirt",

      depth_filler = 1,
      depth_top = 3,

      y_min = default.GLOBAL_Y_MIN,
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
      name = "Savanna Underwater",

      node_top = "rp_default:dirt",
      node_filler = "dfault:dirt",

      depth_filler = 0,
      depth_top = 1,

      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,

      heat_point = 60,
      humidity_point = 30,
})
end

