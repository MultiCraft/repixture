local S = minetest.get_translator("default")

-- Torches

minetest.register_node(
   "default:torch_dead",
   {
      description = S("Dead Torch"),
      drawtype = "nodebox",
      tiles = {
	 "default_torch_ends.png",
	 "default_torch_ends.png",
	 "default_torch_base.png",
      },
      inventory_image = "default_torch_dead_inventory.png",
      wield_image = "default_torch_dead_inventory.png",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      node_box = {
	 type = "wallmounted",
	 wall_top = {-2/16, 0, -2/16, 2/16, 0.5, 2/16},
	 wall_bottom = {-2/16, -0.5, -2/16, 2/16, 0, 2/16},
	 wall_side = {-0.5, -8/16, -2/16, -0.5+4/16, 0, 2/16},
      },
      groups = {choppy = 2, dig_immediate = 3, attached_node = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
})

minetest.register_node(
   "default:torch_weak",
   {
      description = S("Weak Torch"),
      drawtype = "nodebox",
      tiles = {
	 {
	    name = "default_torch_ends.png",
	 },
	 {
	    name = "default_torch_ends.png",
	 },
	 {
	    name = "default_torch_base.png",
	 },
      },
      overlay_tiles = {
	 {
	    name = "default_torch_weak_ends_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
	 {
	    name = "default_torch_weak_ends_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
	 {
	    name = "default_torch_weak_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
      },
      inventory_image = "default_torch_weak_inventory.png",
      wield_image = "default_torch_weak_inventory.png",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      light_source = default.LIGHT_MAX-4,
      node_box = {
	 type = "wallmounted",
	 wall_top = {-2/16, 0, -2/16, 2/16, 0.5, 2/16},
	 wall_bottom = {-2/16, -0.5, -2/16, 2/16, 0, 2/16},
	 wall_side = {-0.5, -8/16, -2/16, -0.5+4/16, 0, 2/16},
      },
      groups = {choppy = 2, dig_immediate = 3, attached_node = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
})

minetest.register_node(
   "default:torch",
   {
      description = S("Torch"),
      drawtype = "nodebox",
      tiles = {
	 {
	    name = "default_torch_ends.png",
	 },
	 {
	    name = "default_torch_ends.png",
	 },
	 {
	    name = "default_torch_base.png",
	 },
      },
      overlay_tiles = {
	 {
	    name = "default_torch_ends_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
	 {
	    name = "default_torch_ends_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
	 {
	    name = "default_torch_overlay.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1.0,
	    },
	 },
      },
      inventory_image = "default_torch_inventory.png",
      wield_image = "default_torch_inventory.png",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      light_source = default.LIGHT_MAX-1,
      node_box = {
	 type = "wallmounted",
	 wall_top = {-2/16, 0, -2/16, 2/16, 0.5, 2/16},
	 wall_bottom = {-2/16, -0.5, -2/16, 2/16, 0, 2/16},
	 wall_side = {-0.5, -8/16, -2/16, -0.5+4/16, 0, 2/16},
      },
      groups = {choppy = 2, dig_immediate = 3, attached_node = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
})

