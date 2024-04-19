local S = minetest.get_translator("rp_default")

local grow_tall = function(pos, y_dir, nodename)
	local newpos
	for i=1, 10 do
		newpos = vector.offset(pos, 0, i*y_dir, 0)
		local newnode = minetest.get_node(newpos)
		if newnode.name == "air" then
			minetest.set_node(newpos, {name=nodename})
			return true
		elseif newnode.name ~= nodename then
			return false
		end
	end
	return false
end

local degrow_tall = function(pos, y_dir, nodename)
	local prevpos, newpos
	for i=1, 10 do
		prevpos = vector.offset(pos, 0, (i-1)*y_dir, 0)
		newpos = vector.offset(pos, 0, i*y_dir, 0)
		local newnode = minetest.get_node(newpos)
		if newnode.name ~= nodename then
			-- Check if this is the only node
			local prevprevpos = vector.offset(pos, 0, (i-2)*y_dir, 0)
			local prevprevnode = minetest.get_node(prevprevpos)
			if prevprevnode.name ~= nodename and newnode.name ~= nodename then
				return false
			end
			minetest.remove_node(prevpos)
			minetest.check_single_for_falling(vector.offset(prevpos, 0, 1, 0))
			return true
		end
	end
	return false
end

-- Cacti

minetest.register_node(
   "rp_default:cactus",
   {
      description = S("Cactus"),
      _tt_help = S("Grows on sand and dry dirt"),
      _rp_hunger_food = 2,
      _rp_hunger_sat = 5,
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
      sounds = rp_sounds.node_sound_defaults({
         footstep = { name = "rp_default_footstep_cactus", gain = 1.0 },
         dig = { name = "rp_default_dig_cactus", gain = 0.5 },
         dug = { name = "rp_default_dig_cactus", gain = 0.7, pitch = 0.9 },
      }),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_use = minetest.item_eat(0),
      _on_grow = function(pos, node)
		return grow_tall(pos, 1, node.name)
      end,
      _on_degrow = function(pos, node)
		return degrow_tall(pos, 1, node.name)
      end,
})

-- Papyrus
-- Note: param2 has a special meaning:
-- * 0: Papyrus node was not grown (i.e. placed or generated by mapgen)
-- * other values: Papyrus node was spawned because it has grown (by an ABM).
--   The value is the height to which the papyrus has grown.
-- This was done for the mega_papyrus achievement.

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
      sounds = rp_sounds.node_sound_grass_defaults({
         footstep = {name="rp_sounds_footstep_grass", gain=1.0, pitch=0.8},
         dug = {name="rp_sounds_dug_grass", gain=0.7, pitch=0.8},
         dig = {name="rp_sounds_dug_grass", gain=0.3, pitch=0.8},
         place = {name="rp_sounds_dug_grass", gain=1.0, pitch=0.8},
      }),
      floodable = true,
      on_flood = function(pos, oldnode)
         minetest.add_item(pos, "rp_default:papyrus")
         util.dig_up(pos, oldnode, nil, "rp_default:papyrus")
      end,
      after_dig_node = function(pos, node, metadata, digger)
	 -- Award player for digging the tallest possible papyrus
	 -- that can naturally grow (by ABM)
         local max = default.PAPYRUS_MAX_HEIGHT_TOTAL
         if node.param2 >= max and digger and digger:is_player() then
            achievements.trigger_achievement(digger, "mega_papyrus")
         end

         -- Dig up (papyrus can't float)
         util.dig_up(pos, node, digger)
      end,
      _on_grow = function(pos, node)
		return grow_tall(pos, 1, node.name)
      end,
      _on_degrow = function(pos, node)
		return degrow_tall(pos, 1, node.name)
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
      is_ground_content = false,
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
         -- Set random age of vine above, it it exists
         local above = {x=pos.x, y=pos.y+1, z=pos.z}
         local aboven = minetest.get_node(above)
         if aboven.name == "rp_default:vine" then
            minetest.set_node(above, {name="rp_default:vine", param2 = math.random(1, default.VINE_MAX_AGE-1)})
         end

         -- Detach vines below
         util.dig_down(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
         -- Set random age of vine above, it it exists
         local above = {x=pos.x, y=pos.y+1, z=pos.z}
         local aboven = minetest.get_node(above)
         if aboven.name == "rp_default:vine" then
            minetest.set_node(above, {name="rp_default:vine", param2 = math.random(1, default.VINE_MAX_AGE-1)})
         end

         -- Drop vine as item and detach vines below
         minetest.add_item(pos, "rp_default:vine")
         util.dig_down(pos, oldnode, nil, "rp_default:vine")
      end,
      on_blast = function(pos)
         -- Set random age of vine above, it it exists
         local above = {x=pos.x, y=pos.y+1, z=pos.z}
         local aboven = minetest.get_node(above)
         if aboven.name == "rp_default:vine" then
            minetest.set_node(above, {name="rp_default:vine", param2 = math.random(1, default.VINE_MAX_AGE-1)})
         end

         -- Destroy the blasted node and detach vines below
         local oldnode = minetest.get_node(pos)
         minetest.remove_node(pos)
         util.dig_down(pos, oldnode)
      end,
      node_placement_prediction = "",
      on_place = function(itemstack, placer, pointed_thing)
         -- Boilerplate to handle pointed node handlers
         local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
         if handled then
            return handled_itemstack
         end

         -- Find position to place vine at
         local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing, true)
         if place_in == nil then
            rp_sounds.play_place_failed_sound(placer)
            return itemstack
         end
         local ceilingnode = minetest.get_node(place_floor)

         -- Ceiling must be stone, dirt or another vine
         if minetest.get_item_group(ceilingnode.name, "dirt") == 0 and ceilingnode.name ~= "rp_default:stone" and ceilingnode.name ~= "rp_default:vine" then
            rp_sounds.play_place_failed_sound(placer)
            return itemstack
         end

         -- Check protection
         if minetest.is_protected(place_in, placer:get_player_name()) and
               not minetest.check_player_privs(placer, "protection_bypass") then
            minetest.record_protection_violation(pos, placer:get_player_name())
            return itemstack
         end

	 local age = ceilingnode.param2
	 -- Update age
         if ceilingnode.name == "rp_default:vine" then
	    -- Vine extended: Increase age by 1 or set random age
            local meta_c = minetest.get_meta(place_floor)
            if age > 0 then
               local meta_new = minetest.get_meta(place_in)
               age = math.min(default.VINE_MAX_AGE, age + 1)
            else
               age = math.random(1, default.VINE_MAX_AGE-1)
            end
         else
	    -- New vine: Set random age
	    age = math.random(1, default.VINE_MAX_AGE-1)
	 end

         -- Place vine
         local newnode = {name = itemstack:get_name(), param2 = age}
         minetest.set_node(place_in, newnode)
         rp_sounds.play_node_sound(place_in, newnode, "place")

         -- Reduce item count
         if not minetest.is_creative_enabled(placer:get_player_name()) then
             itemstack:take_item()
         end

	 return itemstack
      end,
      _on_trim = function(pos, node, player, itemstack)
          -- Cut the vine, set age of a remaining vine to 0 to stop growth
          -- Dig vine
          minetest.remove_node(pos)
          local is_creative = minetest.is_creative_enabled(player:get_player_name())
          if not is_creative then
             item_drop.drop_item(pos, "rp_default:vine")
          end
          util.dig_down(pos, node)
          minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)

	  -- Reset age of vine above, if present
          local above = {x=pos.x, y=pos.y+1, z=pos.z}
          local aboven = minetest.get_node(above)
          if aboven.name == "rp_default:vine" then
	     minetest.set_node(above, {name="rp_default:vine", param2=0})
          end

          -- Add tool wear
          if not is_creative then
             local def = itemstack:get_definition()
             itemstack:add_wear_by_uses(def.tool_capabilities.groupcaps.snappy.uses)
          end
          return itemstack
      end,
      _on_grow = function(pos, node)
         return grow_tall(pos, -1, node.name)
      end,
      _on_degrow = function(pos, node)
         return degrow_tall(pos, -1, node.name)
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
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, fern = 1, plant = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
})

-- Flowers

minetest.register_node(
   "rp_default:flower",
   {
      description = S("Flower"),
      drawtype = "nodebox",
      selection_box = {
         type = "fixed",
         fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0.5},
         }
      },
      node_box = {
         type = "fixed",
         fixed = {
            {-0.5, -0.5 + 1/16, -0.5, 0.5, -0.5 + 1/16 + 0.0001, 0.5}, -- flower petals
            {-3/16, -0.5, -3/16, -4/16, -7/16, -4/16}, -- flower stem 1
            {-2/16, -0.5, 3/16, -1/16, -0.5 + 1/16, 4/16}, -- flower stem 2
            {4/16, -0.5, -6/16, 5/16, -0.5 + 1/16, -5/16}, -- flower stem 3
         }
      },
      tiles = {
	      "rp_default_flowers.png",
	      "rp_default_flowers_below.png",
	      "rp_default_flowers_side.png",
      },
      use_texture_alpha = "clip",
      inventory_image = "rp_default_flowers_inventory.png",
      wield_image = "rp_default_flowers_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, flower = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
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
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, swamp_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults({
         footstep = { name = "rp_sounds_footstep_swamp_grass", gain = 1.0 },
      }),
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
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, dry_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
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
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
      _on_grow = function(pos)
         minetest.set_node(pos, {name="rp_default:tall_grass"})
      end,
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
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
      -- Trim tall grass with shears
      _on_trim = function(pos, node, player, itemstack)
          -- This turns it to a normal grass clump and drops one bonus grass clump
          minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
          minetest.set_node(pos, {name = "rp_default:grass"})

          item_drop.drop_item(pos, "rp_default:grass")

          -- Add wear
          if not minetest.is_creative_enabled(player:get_player_name()) then
             local def = itemstack:get_definition()
             itemstack:add_wear_by_uses(def.tool_capabilities.groupcaps.snappy.uses)
          end
          return itemstack
      end,
      _on_degrow = function(pos)
         minetest.set_node(pos, {name="rp_default:grass"})
      end,
})

minetest.register_node(
   "rp_default:sand_grass",
   {
      description = S("Sand Grass Clump"),
      drawtype = "plantlike",
      paramtype2 = "meshoptions",
      place_param2 = 2,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"rp_default_sand_grass_clump.png"},
      inventory_image = "rp_default_sand_grass_clump_inventory.png",
      wield_image = "rp_default_sand_grass_clump_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, sand_grass = 1, green_grass = 1, plant = 1, spawn_allowed_in = 1},
      sounds = rp_sounds.node_sound_grass_defaults(),
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
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      damage_per_second = 1,
      groups = {snappy = 3, dig_immediate = 3, _attached_node_bottom = 1, plant = 1, immortal_item = 1},
      sounds = rp_sounds.node_sound_plant_defaults(),
      node_placement_prediction = "",
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
         minetest.add_item(pos, "rp_default:thistle")
         util.dig_up(pos, oldnode, nil, "rp_default:thistle")
      end,
      on_blast = function(pos)
         -- Destroy the blasted node and detach thistles above
         local oldnode = minetest.get_node(pos)
         minetest.remove_node(pos)
         util.dig_up(pos, oldnode)
      end,
      on_place = function(itemstack, placer, pointed_thing)
         -- Boilerplate to handle pointed node handlers
         local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
         if handled then
            return handled_itemstack
         end

         -- Find position to place thistle at
         local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
         if place_in == nil then
            rp_sounds.play_place_failed_sound(placer)
            return itemstack
         end
         local floornode = minetest.get_node(place_floor)
         local floordef = minetest.registered_nodes[floornode.name]

         -- Floor must be a walkable node or another thistle
         if not (floornode.name == "rp_default:thistle" or (floordef and floordef.walkable)) then
            rp_sounds.play_place_failed_sound(placer)
            return itemstack
         end

         -- Check protection
         if minetest.is_protected(place_in, placer:get_player_name()) and
               not minetest.check_player_privs(placer, "protection_bypass") then
            minetest.record_protection_violation(pos, placer:get_player_name())
            return itemstack
         end

         -- Place thistle
         local newnode = {name = itemstack:get_name()}
         minetest.set_node(place_in, newnode)
         rp_sounds.play_node_sound(place_in, newnode, "place")

         -- Reduce item count
         if not minetest.is_creative_enabled(placer:get_player_name()) then
             itemstack:take_item()
         end

	 return itemstack
      end,
      _on_grow = function(pos, node)
         return grow_tall(pos, 1, node.name)
      end,
      _on_degrow = function(pos, node)
         return degrow_tall(pos, 1, node.name)
      end
})

