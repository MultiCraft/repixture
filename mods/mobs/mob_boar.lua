local S = minetest.get_translator("mobs")

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
mobs.register_mob("mobs:boar", {
   description = S("Boar"),
   entity_definition = {
      hp_max = 20,
      collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
      selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
      visual = "mesh",
      mesh = "mobs_boar.x",
      textures = { "mobs_boar.png" },
      makes_footstep_sound = true,
      on_rightclick = function(self, clicker)
         mobs.feed_tame(self, clicker, 8, true)
         mobs.capture_mob(self, clicker, 0, 5, 40, false, nil)
      end,
   },
})



-- Boar craftitems

-- Raw porkchop

minetest.register_craftitem(
   "mobs:pork_raw",
   {
      description = S("Raw Porkchop"),
      _tt_food = true,
      _tt_food_hp = 4,
      _tt_food_satiation = 30,
      inventory_image = "mobs_pork_raw.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 4, sat = 30}),
})

-- Cooked porkchop

minetest.register_craftitem(
   "mobs:pork",
   {
      description = S("Cooked Porkchop"),
      _tt_food = true,
      _tt_food_hp = 8,
      _tt_food_satiation = 50,
      inventory_image = "mobs_pork_cooked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat({hp = 8, sat = 50}),
})

minetest.register_craft(
   {
      type = "cooking",
      output = "mobs:pork",
      recipe = "mobs:pork_raw",
      cooktime = 5,
})
