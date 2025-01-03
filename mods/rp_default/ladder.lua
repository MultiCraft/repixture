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
      paramtype2 = "4dir",
      walkable = false,
      climbable = true,
      floodable = true,
      on_flood = function(pos)
         minetest.add_item(pos, "rp_default:ladder")
      end,
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
      groups = {choppy = 3, oddly_breakable_by_hand = 3, level = -3, creative_decoblock = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults({
         footstep = { name = "rp_default_footstep_ladder_wood", gain = 0.5 },
         dig = { name = "rp_sounds_dig_wood", gain = 0.5, pitch = 1.4 },
         dug = { name = "rp_sounds_dug_planks", gain = 0.5, pitch = 1.175 },
         place = { name = "rp_sounds_place_planks", gain = 0.7, pitch = 1.3 },
      }),
})
