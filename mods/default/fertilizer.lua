-- Fertilizer

local S = minetest.get_translator("default")

minetest.register_node(
   "default:fertilized_dirt",
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
      drop = "default:dirt",
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:fertilized_dry_dirt",
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
      drop = "default:dry_dirt",
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:fertilized_swamp_dirt",
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
      drop = "default:swamp_dirt",
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:fertilized_sand",
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
      drop = "default:sand",
      is_ground_content = false,
      sounds = default.node_sound_sand_defaults(),
})

minetest.register_craftitem(
   "default:fertilizer",
   {
      description = S("Fertilizer"),
      _tt_help = S("Used to fertilize dirt and sand to speed up plant growth"),
      inventory_image = "default_fertilizer_inventory.png",
      wield_scale = {x=1,y=1,z=2},
      on_place = function(itemstack, user, pointed_thing)
         local pos = pointed_thing.above

         local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
         if minetest.is_protected(pos_protected, user:get_player_name()) and
                 not minetest.check_player_privs(user, "protection_bypass") then
             minetest.record_protection_violation(pos_protected, user:get_player_name())
             return itemstack
         end

         local undernode = minetest.get_node(pointed_thing.under)

         local diff = vector.subtract(pointed_thing.above, pointed_thing.under)
         if diff.y > 0 then
            if minetest.get_item_group(undernode.name, "plantable_fertilizer") ~= 0 then
               return itemstack
            elseif minetest.get_item_group(undernode.name, "normal_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_dirt"})
            elseif minetest.get_item_group(undernode.name, "swamp_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_swamp_dirt"})
            elseif minetest.get_item_group(undernode.name, "dry_dirt") ~= 0 then
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_dry_dirt"})
            elseif undernode.name == "default:sand" then
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_sand"})
            end
         end

         if not minetest.settings:get_bool("creative_mode") then
            itemstack:take_item()
         end

         return itemstack
      end,
})

default.log("fertilizer", "loaded")
