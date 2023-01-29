local S = minetest.get_translator("rp_fire")

local LIGHT = 10

minetest.register_node(
   "rp_fire:bonfire",
   {
      description = S("Bonfire"),
      _tt_light_source_max = LIGHT,
      drawtype = "mesh",
      mesh = "rp_fire_bonfire.obj",
      paramtype = "light",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, -6/16, 6/16},
      },
      tiles = {"rp_fire_bonfire_stones.png", "rp_fire_bonfire_ground.png", "blank.png"},
      inventory_image = "rp_fire_bonfire_inventory.png",
      wield_image = "rp_fire_bonfire_inventory.png",
      use_texture_alpha = "clip",
      floodable = true,
      walkable = false,
      groups = {cracky = 3, bonfire = 1, attached_node = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_on_ignite = function(pos, itemstack, user)
         minetest.set_node(pos, {name="rp_fire:bonfire_burning"})
	 return {}
      end,
})

minetest.register_node(
   "rp_fire:bonfire_burning",
   {
      description = S("Bonfire (burning)"),
      drawtype = "mesh",
      mesh = "rp_fire_bonfire.obj",
      paramtype = "light",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, -6/16, 6/16},
      },
      tiles = {
         "rp_fire_bonfire_stones.png",
         "rp_fire_bonfire_ground.png",
	 {name="rp_fire_bonfire_flame.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1}},
      },
      damage_per_second = 2,
      floodable = true,
      light_source = LIGHT,
      use_texture_alpha = "clip",
      groups = {cracky = 3, bonfine = 2, attached_node = 1},
      walkable = false,
      drop = "rp_fire:bonfire",
      sounds = rp_sounds.node_sound_stone_defaults(),
})
