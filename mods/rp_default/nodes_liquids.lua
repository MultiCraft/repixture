
local S = minetest.get_translator("rp_default")

-- Water

minetest.register_node(
   "rp_default:water_flowing",
   {
      description = S("Flowing Water"),
      drawtype = "flowingliquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    name = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      drop = "",
      paramtype = "light",
      sunlight_propagates = false,
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:water_flowing",
      liquid_alternative_source = "rp_default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a = 90, r = 40, g = 40, b = 100},
      groups = {water = 1, flowing_water = 1, liquid = 1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})

minetest.register_node(
   "rp_default:water_source",
   {
      description = S("Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 2.2}
	 },
	 {
	    name = "default_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 2.2}
	 },
      },
      use_texture_alpha = "blend",
      sunlight_propagates = false,
      drop = "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:water_flowing",
      liquid_alternative_source = "rp_default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a=90, r=40, g=40, b=100},
      groups = {water=1, liquid=1},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})

minetest.register_node(
   "rp_default:river_water_flowing",
   {
      description = S("Flowing River Water"),
      drawtype = "flowingliquid",
      tiles = {"default_river_water.png"},
      special_tiles = {
	 {
	    name = "default_river_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_river_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:river_water_flowing",
      liquid_alternative_source = "rp_default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water=1, flowing_water = 1, river_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})

minetest.register_node(
   "rp_default:river_water_source",
   {
      description = S("River Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_river_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 2.2}
	 },
	 {
	    name = "default_river_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 2.2}
	 },

      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:river_water_flowing",
      liquid_alternative_source = "rp_default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water = 1, river_water = 1, liquid = 1},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})

minetest.register_node(
   "rp_default:swamp_water_flowing",
   {
      description = S("Flowing Swamp Water"),
      drawtype = "flowingliquid",
      tiles = {"default_swamp_water.png"},
      special_tiles = {
	 {
	    name = "default_swamp_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
	 {
	    name = "default_swamp_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:swamp_water_flowing",
      liquid_alternative_source = "rp_default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water=1, flowing_water = 1, swamp_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})

minetest.register_node(
   "rp_default:swamp_water_source",
   {
      description = S("Swamp Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_swamp_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 3}
	 },
	 {
	    name = "default_swamp_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 3}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:swamp_water_flowing",
      liquid_alternative_source = "rp_default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water = 1, swamp_water = 1, liquid = 1},
      sounds = rp_sounds.node_sound_water_defaults(),
      _rp_blast_resistance = 4,
})
