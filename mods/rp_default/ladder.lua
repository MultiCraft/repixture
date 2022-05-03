local S = minetest.get_translator("rp_default")

-- Ladder

minetest.register_node(
   "rp_default:ladder",
   {
      description = S("Ladder"),
      drawtype = "nodebox",
      tiles = {
         "default_ladder_nodebox_sides.png",
         "default_ladder_nodebox_sides.png",
         "default_ladder_nodebox_sides.png",
         "default_ladder_nodebox_sides.png",
         "default_ladder_nodebox_back.png",
         "default_ladder_nodebox_front.png"
      },
      use_texture_alpha = "clip",
      inventory_image = "default_ladder_inventory.png",
      wield_image = "default_ladder_inventory.png",
      paramtype = "light",
      paramtype2 = "facedir",
      walkable = false,
      climbable = true,
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/16), -0.5, 0.5, -0.5+(4/16), 0.5, 0.5-(2/16)},
	    {0.5-(1/16), -0.5, 0.5, 0.5-(4/16), 0.5, 0.5-(2/16)},
	    {-0.5+(4/16), 0.5-(3/16), 0.5, 0.5-(4/16), 0.5-(5/16), 0.5-(1/16)},
	    {-0.5+(4/16), -0.5+(3/16), 0.5, 0.5-(4/16), -0.5+(5/16), 0.5-(1/16)}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5, -0.5, 0.5, 0.5, 0.5, 0.5-(2/15)}
	 }
      },
      groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

default.log("ladder", "loaded")
