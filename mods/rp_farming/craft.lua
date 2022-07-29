--
-- Crafts and items
--
local S = minetest.get_translator("rp_farming")

-- Items

minetest.register_craftitem(
   "rp_farming:cotton",
   {
      description = S("Cotton"),
      inventory_image = "farming_cotton.png"
})

minetest.register_craftitem(
   "rp_farming:wheat",
   {
      description = S("Wheat"),
      inventory_image = "farming_wheat.png"
})

minetest.register_craftitem(
   "rp_farming:flour",
   {
      description = S("Flour"),
      inventory_image = "farming_flour.png"
})

minetest.register_craftitem(
   "rp_farming:bread",
   {
      description = S("Bread"),
      _tt_food = true,
      _tt_food_hp = 5,
      _tt_food_satiation = 50,
      inventory_image = "farming_bread.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 5, sat = 50})
})

minetest.register_craftitem(
   "rp_farming:asparagus",
   {
      description = S("Asparagus"),
      _tt_food = true,
      _tt_food_hp = 2,
      _tt_food_satiation = 15,
      inventory_image = "farming_asparagus.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 2, sat = 15})
})

minetest.register_craftitem(
   "rp_farming:asparagus_cooked",
   {
      description = S("Cooked Asparagus"),
      _tt_food = true,
      _tt_food_hp = 3,
      _tt_food_satiation = 40,
      inventory_image = "farming_asparagus_cooked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 3, sat = 40})
})

minetest.register_craftitem(
   "rp_farming:potato_baked",
   {
      description = S("Baked Potato"),
      _tt_food = true,
      _tt_food_hp = 4,
      _tt_food_satiation = 35,
      inventory_image = "farming_potato_baked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 4, sat = 35})
})

-- Craft recipes

crafting.register_craft(
   {
      output = "rp_farming:flour",
      items = {
         "rp_farming:wheat 4",
      }
})

crafting.register_craft(
   {
      output = "rp_farming:cotton_bale 2",
      items = {
         "rp_farming:cotton 2",
      }
})

-- Cooking

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_farming:bread",
      recipe = "rp_farming:flour",
      cooktime = 15,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_farming:asparagus_cooked",
      recipe = "rp_farming:asparagus",
      cooktime = 5,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_farming:potato_baked",
      recipe = "rp_farming:potato_1",
      cooktime = 7,
})
