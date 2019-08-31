-- Fertilizer

local S = minetest.get_translator("default")

minetest.register_node(
   "default:fertilized_dirt",
   {
      description = S("Fertilized Dirt"),
      tiles = {
         "default_dirt.png^default_fertilizer.png",
         "default_dirt.png",
         "default_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 plantable_soil = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -5,
	 not_in_craft_guide = 1,
      },
      drop = "default:dirt",
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:fertilized_sand",
   {
      description = S("Fertilized Sand"),
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
      inventory_image = "default_fertilizer_inventory.png",
      wield_scale = {x=1,y=1,z=2},
      on_place = function(itemstack, user, pointed_thing)
         local pos = pointed_thing.above

         local undernode = minetest.get_node(pointed_thing.under)
         local underdef = minetest.registered_nodes[undernode.name]

         local diff = vector.subtract(pointed_thing.above, pointed_thing.under)
         if diff.y > 0 then
            if underdef.groups then
               if underdef.groups.plantable_soil then
                  minetest.set_node(pointed_thing.under, {name = "default:fertilized_dirt"})
               elseif underdef.groups.plantable_sandy then
                  minetest.set_node(pointed_thing.under, {name = "default:fertilized_sand"})
               end
            end
         end

         if not minetest.settings:get_bool("creative_mode") then
            itemstack:take_item()
         end

         return itemstack
      end,
})

default.log("fertilizer", "loaded")
