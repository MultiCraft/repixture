local S = minetest.get_translator("rp_farming")
local N = function(s) return s end
--
-- Nodes
--

farming.register_plant_nodes("rp_farming:wheat", {
   description_stage_1 = S("Wheat Seed"),
   description_general = N("Wheat Plant (stage @1)"),
   tooltip_stage_1 = S("Grows on dirt and swamp dirt; it likes water"),
   texture_prefix = "farming_wheat",
   drop_stages = {
      [1] = {
         items = {
            {items = {"rp_farming:wheat"}, rarity = 3}
         }
      },
      [2] = {
         items = {
            {items = {"rp_farming:wheat"}, rarity = 2}
         },
      },
      [3] = {
         items = {
            {items = {"rp_farming:wheat"}, rarity = 1}
         },
      },
      [4] = {
         items = {
            {items = {"rp_farming:wheat"}, rarity = 1},
            {items = {"rp_farming:wheat 2"}, rarity = 4},
            {items = {"rp_farming:wheat_1"}, rarity = 1},
            {items = {"rp_farming:wheat_1"}, rarity = 2},
         }
      },
   },
})

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
   if not minetest.is_creative_enabled(player:get_player_name()) then
      local def = tool:get_definition()
      tool:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
   end

   -- Keep it growing

   farming.begin_growing_plant(pos)

   return tool
end

farming.register_plant_nodes("rp_farming:cotton", {
   description_stage_1 = S("Cotton Seed"),
   description_general = N("Cotton Plant (stage @1)"),
   tooltip_stage_1 = S("Grows on dirt, swamp dirt, dry dirt and sand; it likes water"),
   texture_prefix = "farming_cotton",
   drop_stages = {
      [1] = {
         items = {
            {items = {"rp_farming:cotton"}, rarity = 3}
         }
      },
      [2] = {
         items = {
            {items = {"rp_farming:cotton"}, rarity = 2}
         },
      },
      [3] = {
         items = {
            {items = {"rp_farming:cotton"}, rarity = 1}
         },
      },
      [4] = {
         items = {
            {items = {"rp_farming:cotton"}, rarity = 1},
            {items = {"rp_farming:cotton 2"}, rarity = 4},
            {items = {"rp_farming:cotton_1"}, rarity = 1},
            {items = {"rp_farming:cotton_1"}, rarity = 2},
         }
      },
   },
   stage_extras = {
      [4] = {
         _on_trim = trim_cotton,
      },
   },
   stage_extra_groups = {
      [4] = {
         unmagnetic = 1,
      },
   },

})


minetest.register_node(
   "rp_farming:cotton_bale",
   {
      description = S("Cotton Bale"),
      tiles ={"farming_cotton_bale.png"},
      is_ground_content = false,
      groups = {snappy = 2, oddly_breakable_by_hand = 3,
                fall_damage_add_percent = -15, fuzzy = 1,
		unmagnetic = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
   }
)
