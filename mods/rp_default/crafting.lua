
--
-- Crafting/creation
--

-- Cooking

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:torch_weak",
      recipe = "rp_default:torch_dead",
      cooktime = 1,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:torch",
      recipe = "rp_default:torch_weak",
      cooktime = 4,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:glass",
      recipe = "rp_default:sand",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_coal",
      recipe = "group:tree",
      cooktime = 4,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:stone",
      recipe = "rp_default:cobble",
      cooktime = 6,
})

-- Metal smelting

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_wrought_iron",
      recipe = "rp_default:lump_iron",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_tin",
      recipe = "rp_default:lump_tin",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_copper",
      recipe = "rp_default:lump_copper",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_bronze",
      recipe = "rp_default:lump_bronze",
      cooktime = 6,
})

-- Fuels

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:leaves",
      burntime = 1,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:dry_grass",
      burntime = 1,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:fern",
      burntime = 2,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:papyrus",
      burntime = 2,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:ladder",
      burntime = 5,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:rope",
      burntime = 5,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:planks",
      burntime = 9,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:torch",
      burntime = 7,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:sapling",
      burntime = 4,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:sign",
      burntime = 6,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:sign_birch",
      burntime = 6,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:sign_oak",
      burntime = 6,
})


minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:cactus",
      burntime = 10,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:fence",
      burntime = 8,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:frame",
      burntime = 13,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:reinforced_frame",
      burntime = 17,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:tree",
      burntime = 22,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:chest",
      burntime = 25,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:bookshelf",
      burntime = 32,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:lump_coal",
      burntime = 20,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:block_coal",
      burntime = 180,
})

default.log("crafting", "loaded")
