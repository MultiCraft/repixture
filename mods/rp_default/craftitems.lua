
--
-- Crafting items
--

local S = minetest.get_translator("rp_default")

-- Organic items

minetest.register_craftitem(
   "rp_default:fiber",
   {
      description = S("Fiber"),
      inventory_image = "default_fiber.png",
})

minetest.register_craftitem(
   "rp_default:stick",
   {
      description = S("Stick"),
      inventory_image = "default_stick.png",
      groups = {stick = 1}
})

minetest.register_craftitem(
   "rp_default:paper",
   {
      description = S("Paper"),
      inventory_image = "default_paper.png",
})

minetest.register_craftitem(
   "rp_default:pearl",
   {
      description = S("Pearl"),
      inventory_image = "default_pearl.png",
})

-- Mineral misc.

minetest.register_craftitem(
   "rp_default:sheet_graphite",
   {
      description = S("Graphite Sheet"),
      inventory_image = "default_sheet_graphite.png",
})

-- Mineral lumps

minetest.register_craftitem(
   "rp_default:lump_sulfur",
   {
      description = S("Sulfur Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_sulfur.png",
})

minetest.register_craftitem(
   "rp_default:lump_coal",
   {
      description = S("Coal Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_coal.png",
})

minetest.register_craftitem(
   "rp_default:lump_iron",
   {
      description = S("Iron Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_iron.png",
})

minetest.register_craftitem(
   "rp_default:lump_tin",
   {
      description = S("Tin Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_tin.png",
})

minetest.register_craftitem(
   "rp_default:lump_copper",
   {
      description = S("Copper Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_copper.png",
})

minetest.register_craftitem(
   "rp_default:lump_bronze",
   {
      description = S("Bronze Lump"),
      groups = { mineral_lump = 1 },
      inventory_image = "default_lump_bronze.png",
})

-- Crafted items

minetest.register_craftitem(
   "rp_default:flint",
   {
      description = S("Flint Shard"),
      inventory_image = "default_flint.png",
})

minetest.register_craftitem(
   "rp_default:book",
   {
      description = S("Book"),
      inventory_image = "default_book.png",
      wield_scale = {x=1,y=1,z=2},
      stack_max = 1,
})
