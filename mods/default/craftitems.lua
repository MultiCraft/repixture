
--
-- Crafting items
--

local S = minetest.get_translator("default")

-- Organic items

minetest.register_craftitem(
   "default:fiber",
   {
      description = S("Fiber"),
      inventory_image = "default_fiber.png",
})

minetest.register_craftitem(
   "default:stick",
   {
      description = S("Stick"),
      inventory_image = "default_stick.png",
      groups = {stick = 1}
})

minetest.register_craftitem(
   "default:paper",
   {
      description = S("Paper"),
      inventory_image = "default_paper.png",
})

minetest.register_craftitem(
   "default:pearl",
   {
      description = S("Pearl"),
      inventory_image = "default_pearl.png",
})

-- Mineral misc.

minetest.register_craftitem(
   "default:sheet_graphite",
   {
      description = S("Graphite Sheet"),
      inventory_image = "default_sheet_graphite.png",
})

-- Mineral lumps

minetest.register_craftitem(
   "default:lump_sulfur",
   {
      description = S("Sulfur Lump"),
      inventory_image = "default_lump_sulfur.png",
})

minetest.register_craftitem(
   "default:lump_coal",
   {
      description = S("Coal Lump"),
      inventory_image = "default_lump_coal.png",
})

minetest.register_craftitem(
   "default:lump_iron",
   {
      description = S("Iron Lump"),
      inventory_image = "default_lump_iron.png",
})

minetest.register_craftitem(
   "default:lump_tin",
   {
      description = S("Tin Lump"),
      inventory_image = "default_lump_tin.png",
})

minetest.register_craftitem(
   "default:lump_copper",
   {
      description = S("Copper Lump"),
      inventory_image = "default_lump_copper.png",
})

minetest.register_craftitem(
   "default:lump_bronze",
   {
      description = S("Bronze Lump"),
      inventory_image = "default_lump_bronze.png",
})

-- Ingots

minetest.register_craftitem(
   "default:ingot_wrought_iron",
   {
      description = S("Wrought Iron Ingot"),
      inventory_image = "default_ingot_wrought_iron.png",
})

minetest.register_craftitem(
   "default:ingot_steel",
   {
      description = S("Steel Ingot"),
      inventory_image = "default_ingot_steel.png",
})

minetest.register_craftitem(
   "default:ingot_carbon_steel",
   {
      description = S("Carbon Steel Ingot"),
      inventory_image = "default_ingot_carbon_steel.png",
})

minetest.register_craftitem(
   "default:ingot_copper",
   {
      description = S("Copper Ingot"),
      inventory_image = "default_ingot_copper.png",
})

minetest.register_craftitem(
   "default:ingot_tin",
   {
      description = S("Tin Ingot"),
      inventory_image = "default_ingot_tin.png",
})

minetest.register_craftitem(
   "default:ingot_bronze",
   {
      description = S("Bronze Ingot"),
      inventory_image = "default_ingot_bronze.png",
})

-- Crafted items

minetest.register_craftitem(
   "default:flint",
   {
      description = S("Flint Shard"),
      inventory_image = "default_flint.png",
})

minetest.register_craftitem(
   "default:book",
   {
      description = S("Book"),
      inventory_image = "default_book.png",
      wield_scale = {x=1,y=1,z=2},
      stack_max = 1,
})

minetest.register_craftitem(
   "default:fertilizer",
   {
      description = S("Fertilizer"),
      inventory_image = "default_fertilizer_inventory.png",
      wield_scale = {x=1,y=1,z=2},
      on_place = function(itemstack, user, pointed_thing)
         local pos = pointed_thing.above

         local underdef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

         if underdef.groups then
            if underdef.groups.plantable_soil then
               minetest.remove_node(pos)
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_dirt"})
            elseif underdef.groups.plantable_sandy then
               minetest.remove_node(pos)
               minetest.set_node(pointed_thing.under, {name = "default:fertilized_sand"})
            end
         end

         itemstack:take_item()

         return itemstack
      end,
})

default.log("craftitems", "loaded")
