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
      _rp_hunger_food = 5,
      _rp_hunger_sat = 50,
      inventory_image = "farming_bread.png",
      groups = { food = 2 },
      on_use = minetest.item_eat("auto"),
})

minetest.register_craftitem(
   "rp_farming:asparagus",
   {
      description = S("Asparagus"),
      _rp_hunger_food = 2,
      _rp_hunger_sat = 15,
      inventory_image = "farming_asparagus.png",
      groups = { food = 2 },
      on_use = minetest.item_eat("auto"),
})

minetest.register_craftitem(
   "rp_farming:asparagus_cooked",
   {
      description = S("Cooked Asparagus"),
      _rp_hunger_food = 3,
      _rp_hunger_sat = 40,
      inventory_image = "farming_asparagus_cooked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat("auto"),
})

minetest.register_craftitem(
   "rp_farming:potato_baked",
   {
      description = S("Baked Potato"),
      _rp_hunger_food = 4,
      _rp_hunger_sat = 35,
      inventory_image = "farming_potato_baked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat("auto"),
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
      output = "rp_farming:cotton_bale",
      items = {
         "rp_farming:cotton 3",
      }
})

crafting.register_craft(
   {
      output = "rp_farming:straw",
      items = {
         "rp_farming:wheat 3",
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

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_farming:straw",
      burntime = 4,
})


