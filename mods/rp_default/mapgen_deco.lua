--[[ DECORATIONS ]]
-- The decorations are roughly ordered by size;
-- largest decorations first.

local mg_name = minetest.get_mapgen_setting("mg_name")

-- Tree decorations

if mg_name ~= "v6" then
default.register_decoration(
   {
      name = "rp_default:giga_birch_tree",
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.023,
      biomes = {"Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_giga_birch_tree.mts",
      rotation = "random",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tall_grove_tree.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.008,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_coniferlike_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.015,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_tall.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_layer_birch_2.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00075,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_candlestick.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})


default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0003,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_5x4.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x4.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_long.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_plus.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})



default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Dry Swamp"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_long.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00133333,
      biomes = {"Dry Swamp Highland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00035,
      biomes = {"Orchard"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_big.mts",
      y_min = 15,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.007,
      biomes = {"Orchard"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = 10,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.000033,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00067,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.009,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_chance_50.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.009,
      biomes = {"Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0009,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00415,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00045,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004375,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.000225,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})


default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0325,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0035,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0325,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0035,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})




default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.0008,
      biomes = {"Mixed Swamp", "Mixed Swamp Highland", "Mixed Swamp Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_oak.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Swamp Forest", "Swamp Forest Highland", "Swamp Forest Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_oak.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Swamp Forest", "Swamp Forest Highland", "Swamp Forest Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_birch.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Dry Swamp", "Dry Swamp Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_birch.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Dry Swamp Highland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_birch.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})


local MYSTERY_FOREST_SPREAD = { x=500, y=500, z=500 }
local MYSTERY_FOREST_OFFSET = 0.001
local MYSTERY_FOREST_OFFSET_STAIRCASE = -0.001
local MYSTERY_FOREST_OFFSET_APPLES = -0.0005
local MYSTERY_FOREST_SCALE = 0.008

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_staircase_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET_STAIRCASE,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_layer_birch.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
              scale = MYSTERY_FOREST_SCALE,
              offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_telephone_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_telephone_tree_apples.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET_APPLES,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})




default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_cross_birch.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
              scale = MYSTERY_FOREST_SCALE,
              offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_large.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
              scale = 0.01,
              offset = -0.004,
	      spread = {x=50,y=50,z=50},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
              scale = 0.01,
              offset = -0.001,
	      spread = {x=50,y=50,z=50},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      fill_ratio = 0.0002,
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

-- Small poplar tree blobs
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 8,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
              scale = 0.05,
	      offset = -0.032,
	      spread = {x=24,y=24,z=24},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})

-- Occasional lonely poplars
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

-- Cactus decorations (legacy Desert only)

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:sand"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Desert"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_cactus.mts",
      y_min = 10,
      y_max = 500,
      rotation = "random",
})

-- Bushes
--
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.0015,
      biomes = {"Mixed Swamp", "Mixed Swamp Highland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_swamp_oak_bush.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})


default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00625,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush_big.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = 0.001,
	      offset = -0.0000001,
	      spread = { x = 50, y = 50, z = 50 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 98421,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = -0.004,
	      offset = 0.002,
	      spread = { x = 82, y = 82, z = 82 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43905,
      },
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})

-- Wilderness apple trees: 50/50 split between
-- trees with apples and those without.
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Dry Swamp"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Dry Swamp Highland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Oak Forest", "Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.018,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.02035,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00225,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})



default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00145,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00015,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_acorns_chance_50.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})




end

-- Rock decorations

if mg_name ~= "v6" then
-- Underwater
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt", "rp_default:dirt", "rp_default:gravel"},
      sidelen = 16,
      fill_ratio = 0.006,
      flags = "place_center_x, place_center_z",
      biomes = { "Wasteland Ocean", "Wasteland Beach", "Savannic Wasteland Ocean", "Rocky Dryland Ocean", "Grassland Ocean", "Savanna Ocean" },
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_boulder_small.mts",
      y_min = -200,
      y_max = -2,
      rotation = "random",
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      flags = "place_center_x, place_center_z",
      biomes = { "Wasteland Ocean", "Savannic Wasteland Ocean", "Rocky Dryland Ocean" },
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_boulder.mts",
      y_min = -200,
      y_max = -10,
      rotation = "random",
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      flags = "place_center_x, place_center_z",
      biomes = { "Mystery Forest Ocean" },
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_boulder.mts",
      y_min = -200,
      y_max = -3,
      rotation = "random",
      flags = "force_placement",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt", "rp_default:sand"},
      sidelen = 16,
      biomes = { "Savannic Wasteland Ocean", "Wilderness Ocean" },
      fill_ratio = 0.003,
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_sandstone_mound.mts",
      y_min = -200,
      y_max = 2,
      rotation = "random",
      flags = "force_placement",
})


-- Overwater
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_rock.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "random",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_large_rock.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "random",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:stone", "rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_rock.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "random",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:sand", "rp_default:dry_dirt", "rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.0005,
      biomes = {"Savannic Wasteland", "Savannic Wasteland Ocean"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_sandstone_rock.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dry_dirt", "rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      decoration = {"rp_default:stone"},
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})


-- Sulfur decorations

default.register_decoration(
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
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dry_dirt", "rp_default:stone"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      decoration = {"rp_default:stone_with_sulfur"},
      y_min = 2,
      y_max = 14,
})

-- Tiny tree decorations

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_3layer.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_2layer.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_3layer.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_2layer.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_oak.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})


default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})



-- Bush/shrub decorations

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0075,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.03,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.005,
      biomes = {"Savanna", "Chaparral"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.0025,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Rocky Dryland", "Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.06,
      biomes = {"Chaparral"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 5,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = -0.004,
	      offset = -0.001,
	      spread = { x = 82, y = 82, z = 82 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 493421,
      },
})


default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0003,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_normal_bush_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_normal_bush_small.mts",
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})



default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})
default.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0036,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,
      rotation = "0",
})



-- Thistle decorations

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.024,
      biomes = {"Wilderness"},
      decoration = {"rp_default:thistle"},
      height = 2,
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dirt_with_grass", "rp_default:dry_dirt"},
      sidelen = 4,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:thistle"},
      height = 2,
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
	      scale = 1,
	      offset = -0.5,
	      spread = { x = 12, y = 12, z = 12 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43905,
      },
})
end
-- Papyrus decorations

-- Beach papyrus
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:dirt", "rp_default:dirt_with_grass"},
      spawn_by = {"rp_default:water_source", "rp_default:water_flowing"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland Ocean", "Grassland", "Forest Ocean", "Forest", "Wilderness Ocean", "Wilderness", "Birch Forest Ocean", "Tall Birch Forest Ocean", "Marsh Beach", "Swamp Meadow Beach"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      y_max = 3,
      y_min = 0,
})

-- Grassland papyrus
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dirt_with_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland", "Dense Grassland", "Marsh", "Forest", "Deep Forest", "Wilderness", "Baby Poplar Plains"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      height_max = 3,
      y_max = 30,
      y_min = 4,
})


-- Swamp papyrus
default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:swamp_dirt", "rp_default:dirt_with_swamp_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      biomes = {"Mixed Swamp", "Mixed Swamp Highland"},
      decoration = {"rp_default:papyrus"},
      height = 4,
      y_max = default.GLOBAL_Y_MAX,
      y_min = -100,
	noise_params   = {
		offset  = 0,
		scale   = 0.15,
		spread  = {x=150, y=150, z=150},
		seed    = 40499,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:swamp_dirt", "rp_default:dirt_with_swamp_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.60,
      biomes = {"Papyrus Swamp"},
      decoration = {"rp_default:papyrus"},
      height = 4,
      height_max = 4,
      y_max = default.GLOBAL_Y_MAX,
      y_min = -100,
})

-- Flower decorations

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Grassland", "Wilderness", "Orchard", "Baby Poplar Plains", "Birch Forest"},
      decoration = {"rp_default:flower"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Dense Grassland", "Poplar Plains"},
      decoration = {"rp_default:flower"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})


-- Grass decorations

if mg_name ~= "v6" then
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.18,
      biomes = {"Grassland", "Dense Grassland", "Orchard", "Swamp Meadow", "Swamp Meadow Highland", "Baby Poplar Plains", "Poplar Plains", "Shrubbery", "Oak Shrubbery", "Thorny Shrubs", "Dry Swamp", "Dry Swamp Highland"},
      decoration = {"rp_default:grass"},
      y_min = 10,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland", "Dense Grassland", "Forest", "Deep Forest", "Birch Forest", "Tall Birch Forest", "Oak Forest", "Dense Oak Forest", "Tall Oak Forest", "Mystery Forest", "Baby Poplar Plains", "Poplar Plains", "Dry Swamp", "Dry Swamp Highland", "Shrubbery", "Oak Shrubbery"},
      decoration = {"rp_default:grass"},
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})


-- Algae (selected biomes)
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.0025,
     biomes = { "Wilderness Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_big.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -9,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.005,
     biomes = { "Wilderness Ocean", "Shrubbery Ocean", "Mystery Forest Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_diamond.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -5,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.005,
     biomes = { "Wilderness Ocean", "Shrubbery Ocean", "Forest Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_4x4.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -4,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.005,
     biomes = { "Wilderness Ocean", "Shrubbery Ocean", "Forest Ocean", "Tall Birch Forest Ocean", "Mixed Swamp Ocean", "Grove Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_cross.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -2,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.005,
     biomes = { "Wilderness Ocean", "Shrubbery Ocean", "Forest Ocean", "Tall Birch Forest Ocean", "Mixed Swamp Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_3x3.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -2,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})
default.register_decoration(
  {
     deco_type = "schematic",
     place_on = {"rp_default:swamp_dirt", "rp_default:dirt", "rp_default:sand"},
     sidelen = 16,
     fill_ratio = 0.005,
     biomes = { "Wilderness Ocean", "Shrubbery Ocean", "Forest Ocean", "Tall Birch Forest Ocean", "Mixed Swamp Ocean" },
     schematic = minetest.get_modpath("rp_default").."/schematics/rp_default_algae_blocks_3step.mts",
     rotation = "random",
     y_min = default.GLOBAL_Y_MIN,
     y_max = -3,
     place_offset_y = 0,
     spawn_by = { "rp_default:water_source" },
     num_spawn_by = 1,
     flags = "force_placement,place_center_x,place_center_z",
})


for h=1,5 do
   default.register_decoration(
      {
         deco_type = "simple",
         place_on = "rp_default:dirt",
         sidelen = 16,
         fill_ratio = 0.01,
	 biomes = { "Birch Forest Ocean", "Tall Birch Forest Ocean", "Tall Oak Forest Ocean", "Baby Poplar Plains Ocean", "Poplar Plains Ocean", "Shrubbery Ocean", "Thorny Shrubs Ocean", "Wilderness Ocean"  },
         decoration = {"rp_default:alga_on_dirt"},
         y_min = default.GLOBAL_Y_MIN,
         y_max = -h,
         spawn_by = { "rp_default:water_source" },
         num_spawn_by = 1,
         place_offset_y = -1,
         param2 = h*16,
         flags = "force_placement",
   })
   if h <= 3 then
      default.register_decoration(
         {
            deco_type = "simple",
            place_on = "rp_default:sand",
            sidelen = 16,
            fill_ratio = 0.01,
	    biomes = { "Birch Forest Ocean", "Tall Birch Forest Ocean", "Tall Oak Forest Ocean", "Baby Poplar Plains Ocean", "Poplar Plains Ocean", "Shrubbery Ocean", "Thorny Shrubs Ocean", "Wilderness Ocean"  },
            decoration = {"rp_default:alga_on_sand"},
            y_min = default.GLOBAL_Y_MIN,
            y_max = -h,
            spawn_by = { "rp_default:water_source" },
            num_spawn_by = 1,
            place_offset_y = -1,
            param2 = h*16,
            flags = "force_placement",
      })
   end

   default.register_decoration(
      {
         deco_type = "simple",
         place_on = "rp_default:swamp_dirt",
         sidelen = 16,
         fill_ratio = 0.01,
	 biomes = { "Papyrus Swamp Ocean", "Mixed Swamp Ocean" },
         decoration = {"rp_default:alga_on_swamp_dirt"},
         y_min = default.GLOBAL_Y_MIN,
         y_max = -(h+2),
         spawn_by = { "rp_default:water_source" },
         num_spawn_by = 1,
         place_offset_y = -1,
         param2 = (h+2)*16,
         flags = "force_placement",
   })

   -- Grow algae on algae blocks (from previous alga block schematic decorations)
   default.register_decoration(
      {
         deco_type = "simple",
         place_on = {"rp_default:alga_block"},
         sidelen = 16,
         fill_ratio = 0.025,
         decoration = {"rp_default:alga_on_alga_block"},
         y_min = default.GLOBAL_Y_MIN,
         y_max = -h,
         spawn_by = { "rp_default:water_source" },
	 place_offset = -1,
         num_spawn_by = 1,
         param2 = h*16,
         flags = "force_placement",
   })

end


-- Sea grass
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt",
      sidelen = 16,
      fill_ratio = 0.06,
      decoration = {"rp_default:seagrass_on_dirt"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt",
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = { "Forest Ocean", "Marsh Ocean", "Dense Grassland Ocean", "Grove Ocean", "Shrubbery Ocean", "Oak Shrubbery Ocean", "Mystery Forest Ocean", "Baby Poplar Plains Ocean", "Mixed Swamp Ocean" },
      decoration = {"rp_default:tall_seagrass_on_dirt"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:sand",
      sidelen = 16,
      fill_ratio = 0.04,
      decoration = {"rp_default:seagrass_on_sand"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:sand",
      sidelen = 16,
      fill_ratio = 0.008,
      biomes = { "Forest Ocean", "Marsh Ocean", "Dense Grassland Ocean", "Grove Ocean", "Shrubbery Ocean", "Oak Shrubbery Ocean", "Mystery Forest Ocean", "Wilderness Ocean", "Thorny Shrubs Ocean", "Shrubbery Ocean" },
      decoration = {"rp_default:tall_seagrass_on_sand"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})



default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:swamp_dirt",
      sidelen = 16,
      fill_ratio = 0.08,
      decoration = {"rp_default:seagrass_on_swamp_dirt"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:swamp_dirt",
      sidelen = 16,
      fill_ratio = 0.06,
      biomes = { "Swamp Meadow Beach", "Swamp Meadow Ocean", "Papyrus Swamp Ocean", "Mixed Swamp Ocean", "Mixed Swamp Beach", "Swamp Forest Ocean" },
      decoration = {"rp_default:tall_seagrass_on_swamp_dirt"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})

-- Extra sea grass in swamp meadow biomes
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:swamp_dirt",
      sidelen = 16,
      fill_ratio = 0.10,
      decoration = {"rp_default:seagrass_on_swamp_dirt"},
      biomes = {"Swamp Meadow", "Swamp Meadow Ocean", "Swamp Meadow Beach"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:swamp_dirt",
      sidelen = 16,
      fill_ratio = 0.10,
      decoration = {"rp_default:tall_seagrass_on_swamp_dirt"},
      biomes = {"Swamp Meadow", "Swamp Meadow Ocean", "Swamp Meadow Beach"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 0,
      spawn_by = { "rp_default:water_source", "rp_default:river_water_source" },
      num_spawn_by = 1,
      place_offset_y = -1,
      flags = "force_placement",
})

end

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_swamp_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Mixed Swamp", "Mixed Swamp Highland", "Dry Swamp", "Dry Swamp Highland", "Papyrus Swamp", "Swamp Forest", "Swamp Forest Highland"},
      decoration = {"rp_default:swamp_grass"},
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_swamp_grass",
      sidelen = 16,
      fill_ratio = 0.16,
      biomes = {"Swamp Meadow", "Swamp Meadow Highland"},
      decoration = {"rp_default:swamp_grass"},
      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_dry_grass",
      sidelen = 16,
      fill_ratio = 0.07,
      biomes = {"Savanna", "Chaparral", "Savannic Wasteland"},
      decoration = {"rp_default:dry_grass"},
      y_min = 10,
      y_max = 500,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_dry_grass",
      sidelen = 16,
      fill_ratio = 0.007,
      biomes = {"Savanna", "Savannic Wasteland"},
      decoration = {"rp_default:dry_grass"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = 9,
})


if mg_name ~= "v6" then

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Forest", "Marsh", "Dense Grassland", "Grove", "Shrubbery", "Oak Shrubbery"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.15,
      biomes = {"Deep Forest", "Tall Oak Forest"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.05,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})
default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.1,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:grass"},
      y_min = 0,
      y_max = default.GLOBAL_Y_MAX,
})

end

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.16,
      biomes = {"Wilderness", "Thorny Shrubs"},
      decoration = {"rp_default:grass"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.12,
      biomes = {"Wilderness", "Thorny Shrubs"},
      decoration = {"rp_default:tall_grass"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

-- Fern decorations

default.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Wilderness", "Grove", "Tall Oak Forest", "Mystery Forest"},
      decoration = {"rp_default:fern"},
      y_min = default.GLOBAL_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,
})

-- Clam decorations

default.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:gravel"},
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Grassland Ocean", "Wasteland Beach", "Forest Ocean", "Wilderness Ocean", "Grove Ocean", "Thorny Shrubs Ocean", "Birch Forest Ocean", "Tall Birch Forest Ocean", "Savanna Ocean", "Rocky Dryland Ocean", "Savannic Wasteland Ocean", "Baby Poplar Plains", "Gravel Beach"},
      decoration = {"rp_default:clam"},
      y_min = 0,
      y_max = 1,
})


