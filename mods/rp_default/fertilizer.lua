-- Fertilizer

local S = minetest.get_translator("rp_default")

minetest.register_node(
   "rp_default:fertilized_dirt",
   {
      description = S("Fertilized Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_dirt.png^default_fertilizer.png",
         "default_dirt.png",
         "default_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 normal_dirt = 1,
	 plantable_soil = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -5,
	 not_in_craft_guide = 1,
      },
      drop = "rp_default:dirt",
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_dry_dirt",
   {
      description = S("Fertilized Dry Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_dry_dirt.png^default_fertilizer.png",
         "default_dry_dirt.png",
         "default_dry_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 dry_dirt = 1,
	 plantable_dry = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
	 not_in_craft_guide = 1,
      },
      drop = "rp_default:dry_dirt",
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_swamp_dirt",
   {
      description = S("Fertilized Swamp Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_swamp_dirt.png^default_fertilizer.png",
         "default_swamp_dirt.png",
         "default_swamp_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 swamp_dirt = 1,
	 plantable_soil = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
	 not_in_craft_guide = 1,
      },
      drop = "rp_default:swamp_dirt",
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_sand",
   {
      description = S("Fertilized Sand"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {"default_sand.png^default_fertilizer.png", "default_sand.png", "default_sand.png"},
      groups = {
	 crumbly = 3,
	 falling_node = 1,
	 sand = 1,
	 plantable_sandy = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
	 not_in_craft_guide = 1,
      },
      drop = "rp_default:sand",
      is_ground_content = false,
      sounds = rp_sounds.node_sound_sand_defaults(),
})

minetest.register_craftitem(
   "rp_default:fertilizer",
   {
      description = S("Fertilizer"),
      _tt_help = S("Used to fertilize dirt and sand to speed up plant growth"),
      inventory_image = "default_fertilizer_inventory.png",
      wield_scale = {x=1,y=1,z=2},
      on_place = function(itemstack, placer, pointed_thing)
         -- Boilerplace to handle pointed node's rightclick handler
         if not placer or not placer:is_player() then
            return itemstack
         end
         if pointed_thing.type ~= "node" then
            return minetest.item_place_node(itemstack, placer, pointed_thing)
         end
         local node = minetest.get_node(pointed_thing.under)
         local def = minetest.registered_nodes[node.name]
         if def and def.on_rightclick and
               ((not placer) or (placer and not placer:get_player_control().sneak)) then
            return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
               pointed_thing) or itemstack
         end

	 -- Check protection
         local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
         if minetest.is_protected(pos_protected, placer:get_player_name()) and
                 not minetest.check_player_privs(placer, "protection_bypass") then
             minetest.record_protection_violation(pos_protected, placer:get_player_name())
             return itemstack
         end

	 -- Fertilize node (depending on node type)
         local undernode = minetest.get_node(pointed_thing.under)
         local diff = vector.subtract(pointed_thing.above, pointed_thing.under)
	 local fertilized = false
         if diff.y > 0 then
            if minetest.get_item_group(undernode.name, "plantable_fertilizer") ~= 0 then
               return itemstack
            elseif minetest.get_item_group(undernode.name, "normal_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "rp_default:fertilized_dirt"})
	       fertilized = true
            elseif minetest.get_item_group(undernode.name, "swamp_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "rp_default:fertilized_swamp_dirt"})
	       fertilized = true
            elseif minetest.get_item_group(undernode.name, "dry_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "rp_default:fertilized_dry_dirt"})
	       fertilized = true
            elseif undernode.name == "rp_default:sand" then
               minetest.set_node(pointed_thing.under, {name = "rp_default:fertilized_sand"})
	       fertilized = true
            end
	    if fertilized then
               minetest.sound_play({name="rp_default_fertilize", gain=1.0}, {pos=pointed_thing.under}, true)
	       minetest.log("action", "[rp_default] " .. placer:get_player_name() .. " fertilizes " .. undernode.name .. " at " .. minetest.pos_to_string(pointed_thing.under, 0))
	    end
         end

         -- Reduce item count
         if not minetest.is_creative_enabled(placer:get_player_name()) then
            itemstack:take_item()
         end

         return itemstack
      end,
})
