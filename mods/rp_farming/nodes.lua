local S = minetest.get_translator("rp_farming")
--
-- Nodes
--

minetest.register_node(
   "rp_farming:wheat_1",
   {
      description = S("Wheat Seed"),
      _tt_help = S("Grows on dirt and swamp dirt; it likes water"),
      drawtype = "plantlike",
      tiles = {"farming_wheat_1.png"},
      inventory_image = "farming_wheat_seed.png",
      wield_image = "farming_wheat_seed.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:wheat"}, rarity = 3}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, seed=1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:wheat_2",
   {
      description = S("Wheat Plant (stage 1)"),
      drawtype = "plantlike",
      tiles = {"farming_wheat_2.png"},
      inventory_image = "farming_wheat_2.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:wheat"}, rarity = 2}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:wheat_3",
   {
      description = S("Wheat Plant (stage 2)"),
      drawtype = "plantlike",
      tiles = {"farming_wheat_3.png"},
      inventory_image = "farming_wheat_3.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:wheat"}, rarity = 1}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:wheat_4",
   {
      description = S("Wheat Plant (stage 3)"),
      drawtype = "plantlike",
      tiles = {"farming_wheat_4.png"},
      inventory_image = "farming_wheat_4.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:wheat"}, rarity = 1},
	    {items = {"rp_farming:wheat 2"}, rarity = 4},
	    {items = {"rp_farming:wheat_1"}, rarity = 1},
	    {items = {"rp_farming:wheat_1"}, rarity = 2},
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:cotton_1",
   {
      description = S("Cotton Seed"),
      _tt_help = S("Grows on dirt, swamp dirt, dry dirt and sand; it likes water"),
      drawtype = "plantlike",
      tiles = {"farming_cotton_1.png"},
      inventory_image = "farming_cotton_seed.png",
      wield_image = "farming_cotton_seed.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:cotton"}, rarity = 3}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, seed=1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:cotton_2",
   {
      description = S("Cotton Plant (stage 1)"),
      drawtype = "plantlike",
      tiles = {"farming_cotton_2.png"},
      inventory_image = "farming_cotton_2.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:cotton"}, rarity = 2}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

minetest.register_node(
   "rp_farming:cotton_3",
   {
      description = S("Cotton Plant (stage 2)"),
      drawtype = "plantlike",
      tiles = {"farming_cotton_3.png"},
      inventory_image = "farming_cotton_3.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:cotton"}, rarity = 1}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds=rp_sounds.node_sound_leaves_defaults()
   }
)

local trim_cotton = function(pos, node, player, tool)
   -- This cuts down the cotton plant to stage 1 and might drop some bonus goodies

   local name = tool:get_name()
   minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
   minetest.set_node(pos, {name = "rp_farming:cotton_2"})

   -- Drop some seeds

   if math.random(1, 2) == 1 then
      item_drop.drop_item(pos, "rp_farming:cotton_1")
   end

   -- Drop an extra cotton ball

   for i = 1, 2 do
      if math.random(1, 4) == 1 then -- 25% chance of dropping 2x
         item_drop.drop_item(pos, "rp_farming:cotton 2")
      else
         item_drop.drop_item(pos, "rp_farming:cotton")
      end
   end

   -- Add wear
   if not minetest.settings:get_bool("creative_mode") then
      local def = tool:get_definition()
      tool:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
   end

   -- Keep it growing

   farming.begin_growing_plant(pos)

   return tool
end

minetest.register_node(
   "rp_farming:cotton_4",
   {
      description = S("Cotton Plant (stage 3)"),
      drawtype = "plantlike",
      tiles = {"farming_cotton_4.png"},
      inventory_image = "farming_cotton_4.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      floodable = true,
      buildable_to = true,
      is_ground_content = true,
      drop = {
	 items = {
	    {items = {"rp_farming:cotton"}, rarity = 1},
	    {items = {"rp_farming:cotton 2"}, rarity = 4},
	    {items = {"rp_farming:cotton_1"}, rarity = 1},
	    {items = {"rp_farming:cotton_1"}, rarity = 2},
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5+(4/16), 0.5}
      },
      groups = {snappy=3, handy=2, attached_node=1, not_in_craft_guide = 1, not_in_creative_inventory = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),

      -- Trim cotton with shears
      _on_trim = trim_cotton,
   }
)

minetest.register_node(
   "rp_farming:cotton_bale",
   {
      description = S("Cotton Bale"),
      tiles ={"farming_cotton_bale.png"},
      is_ground_content = false,
      groups = {snappy = 2, oddly_breakable_by_hand = 3,
                fall_damage_add_percent = -15, fuzzy = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
   }
)

default.log("nodes", "loaded")
