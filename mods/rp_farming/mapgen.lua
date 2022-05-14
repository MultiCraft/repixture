
--
-- Mapgen
--

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.008,
      biomes = {"Wilderness"},
      decoration = {"rp_farming:wheat_4"},
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Grassland"},
      decoration = {"rp_farming:wheat_4"},
      y_min = 1,
      y_max = 32000,
      noise_params = {
          seed = 13,
	  octaves = 2,
	  scale = 0.001,
	  offset = 0.0,
	  spread = { x = 50, y = 50, z = 50 },
      },
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Savanna"},
      decoration = {"rp_farming:cotton_4"},
      y_min = 1,
      y_max = 32000,
})

