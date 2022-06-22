local S = minetest.get_translator("rp_default")

-- Cacti

minetest.register_node(
   "rp_default:cactus",
   {
      description = S("Cactus"),
      _tt_help = S("Grows on sand and dry dirt"),
      _tt_food = true,
      _tt_food_hp = 2,
      _tt_food_satiation = 5,
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/8), -0.5, -0.5+(1/8), 0.5-(1/8), 0.5, 0.5-(1/8)},
	    {-0.5, -0.5, -0.5+(1/3), 0.5, 0.5-(1/3), 0.5-(1/3)},
	    {-0.5+(1/3), -0.5, -0.5, 0.5-(1/3), 0.5-(1/3), 0.5},
	 },
      },
      selection_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/8), -0.5, -0.5+(1/8), 0.5-(1/8), 0.5, 0.5-(1/8)},
	 },
      },
      tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_sides.png"},
      --	damage_per_second = 1,
      groups = {snappy = 2, choppy = 2, fall_damage_add_percent = 20, plant = 1, food = 2},
      sounds = rp_sounds.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_use = minetest.item_eat({hp = 2, sat = 5}),
})

-- Papyrus

minetest.register_node(
   "rp_default:papyrus",
   {
      description = S("Papyrus"),
      _tt_help = S("Grows on sand or dirt near water"),
      drawtype = "nodebox",
      tiles = {"default_papyrus_repixture.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_papyrus_inventory.png",
      wield_image = "default_papyrus_inventory.png",
      paramtype = "light",
      walkable = false,
      climbable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5+(2/16), -0.5, -0.5+(2/16), 0.5-(2/16), 0.5, 0.5-(2/16)}
      },
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(2/16), -0.5, -0.5+(2/16), -0.5+(4/16), 0.5, -0.5+(4/16)},
	    {0.5-(2/16), -0.5, -0.5+(2/16), 0.5-(4/16), 0.5, -0.5+(4/16)},
	    {-0.5+(2/16), -0.5, 0.5-(2/16), -0.5+(4/16), 0.5, 0.5-(4/16)},
	    {0.5-(2/16), -0.5, 0.5-(2/16), 0.5-(4/16), 0.5, 0.5-(4/16)},
	    {-1/16, -0.5, -1/16, 1/16, 0.5, 1/16},
	 }
      },
      groups = {snappy = 3, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
})

-- Vine

minetest.register_node(
   "rp_default:vine",
   {
      description = S("Vine"),
      _tt_help = S("Hangs from stone or dirt"),
      drawtype = "plantlike",
      tiles = {"rp_default_vine.png"},
      use_texture_alpha = "clip",
      inventory_image = "rp_default_vine_inventory.png",
      wield_image = "rp_default_vine_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      walkable = false,
      climbable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-2/16, -0.5, -2/16, 2/16, 0.5, 2/16 },
      },
      floodable = true,
      groups = {_attached_node_top = 1, snappy = 3, plant = 1, vine = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_down(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
	 util.dig_down(pos, oldnode)
      end,
      on_blast = function(pos)
         local oldnode = minetest.get_node(pos)
         util.dig_down(pos, oldnode)
      end,
      on_place = function(itemstack, placer, pointed_thing)
         -- Boilerplate to handle pointed node handlers
         local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
         if handled then
            return handled_itemstack
         end

         -- Find position to place vine at
         local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing, true)
         if place_in == nil then
            return itemstack
         end
         local ceilingnode = minetest.get_node(place_floor)

         -- Ceiling must be stone, dirt or another vine
         if minetest.get_item_group(ceilingnode.name, "dirt") == 0 and ceilingnode.name ~= "rp_default:stone" and ceilingnode.name ~= "rp_default:vine" then
            return itemstack
         end

         -- Check protection
         if minetest.is_protected(place_in, placer:get_player_name()) and
               not minetest.check_player_privs(placer, "protection_bypass") then
            minetest.record_protection_violation(pos, placer:get_player_name())
            return itemstack
         end

         -- Place vine
         minetest.set_node(place_in, {name = itemstack:get_name()})

         -- Reduce item count
         if not minetest.is_creative_enabled(placer:get_player_name()) then
             itemstack:take_item()
         end

	 return itemstack
      end,
})

-- Fern

minetest.register_node(
   "rp_default:fern",
   {
      description = S("Fern"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_fern.png"},
      inventory_image = "default_fern_inventory.png",
      wield_image = "default_fern_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, fern = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Flowers

minetest.register_node(
   "rp_default:flower",
   {
      description = S("Flower"),
      _tt_help = S("It looks beautiful"),
      drawtype = "nodebox",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + (1 / 16), 0.5}
      },
      tiles = {"default_flowers.png", "default_flowers.png^[transformFY", "blank.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_flowers_inventory.png",
      wield_image = "default_flowers_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, flower = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Grasses

minetest.register_node(
   "rp_default:swamp_grass",
   {
      description = S("Swamp Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_swamp_grass_clump.png"},
      inventory_image = "default_swamp_grass_clump_inventory.png",
      wield_image = "default_swamp_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, swamp_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:dry_grass",
   {
      description = S("Dry Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_dry_grass_clump.png"},
      inventory_image = "default_dry_grass_clump_inventory.png",
      wield_image = "default_dry_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, dry_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:grass",
   {
      description = S("Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_grass_clump.png"},
      inventory_image = "default_grass_clump_inventory.png",
      wield_image = "default_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:tall_grass",
   {
      description = S("Tall Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_grass_clump_tall.png"},
      inventory_image = "default_grass_clump_tall_inventory.png",
      wield_image = "default_grass_clump_tall_inventory.png",
      drop = "rp_default:grass",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      -- Trim tall grass with shears
      _on_trim = function(pos, node, player, itemstack)
          -- This turns it to a normal grass clump and drops one bonus grass clump
          minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
          minetest.set_node(pos, {name = "rp_default:grass"})

          item_drop.drop_item(pos, "rp_default:grass")

          -- Add wear
          if not minetest.is_creative_enabled(player:get_player_name()) then
             local def = itemstack:get_definition()
             itemstack:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
          end
          return itemstack
      end,
})

-- Thistle

minetest.register_node(
   "rp_default:thistle",
   {
      description = S("Thistle"),
      _tt_help = S("Careful, it stings!"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, 0.5, 6/16}
      },
      tiles = {"default_thistle.png"},
      inventory_image = "default_thistle_inventory.png",
      wield_image = "default_thistle_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      damage_per_second = 1,
      groups = {snappy = 3, dig_immediate = 3, falling_node = 1, plant = 1, immortal_item = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
         util.dig_up(pos, oldnode)
      end,
})

