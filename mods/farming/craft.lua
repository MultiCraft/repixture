--
-- Crafts and items
--
local S = minetest.get_translator("farming")

-- Items

minetest.register_craftitem(
   "farming:cotton",
   {
      description = S("Cotton"),
      inventory_image = "farming_cotton.png"
})

minetest.register_craftitem(
   "farming:wheat",
   {
      description = S("Wheat"),
      inventory_image = "farming_wheat.png"
})

minetest.register_craftitem(
   "farming:flour",
   {
      description = S("Flour"),
      inventory_image = "farming_flour.png"
})

minetest.register_craftitem(
   "farming:bread",
   {
      description = S("Bread"),
      _tt_food = true,
      _tt_food_hp = 4,
      _tt_food_satiation = 40,
      inventory_image = "farming_bread.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 4, sat = 40})
})

-- Craft recipes

crafting.register_craft(
   {
      output = "farming:flour",
      items = {
         "farming:wheat 4",
      }
})

crafting.register_craft(
   {
      output = "farming:cotton_bale 2",
      items = {
         "farming:cotton 2",
      }
})

-- Cooking

minetest.register_craft(
   {
      type = "cooking",
      output = "farming:bread",
      recipe = "farming:flour",
      cooktime = 15,
})

default.log("craft", "loaded")
