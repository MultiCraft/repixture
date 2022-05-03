local S = minetest.get_translator("rp_default")

-- Fences

minetest.register_node(
   "rp_default:fence",
   {
      description = S("Wooden Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood.png^default_fence_overlay.png"},
      inventory_image = "default_fence.png",
      wield_image = "default_fence.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, fence = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

minetest.register_node(
   "rp_default:fence_oak",
   {
      description = S("Oak Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood_oak.png^default_fence_overlay.png"},
      inventory_image = "default_fence_oak.png",
      wield_image = "default_fence_oak.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 1, choppy = 1, oddly_breakable_by_hand = 1, fence = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

minetest.register_node(
   "rp_default:fence_birch",
   {
      description = S("Birch Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood_birch.png^default_fence_overlay.png"},
      inventory_image = "default_fence_birch.png",
      wield_image = "default_fence_birch.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 1, choppy = 1, oddly_breakable_by_hand = 1, fence = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

default.log("fence", "loaded")
