
--
-- Crafts and items
--
local S = minetest.get_translator("rp_mobs_mobs")

-- Wool

minetest.register_node(
   "rp_mobs_mobs:wool",
   {
      description = S("Wool Bundle"),
      tiles ={"mobs_wool.png"},
      is_ground_content = false,
      groups = {snappy = 2, oddly_breakable_by_hand = 3, fall_damage_add_percent = -25, fuzzy = 1, unmagnetic = 1},
      sounds = rp_sounds.node_sound_fuzzy_defaults(),
})

-- Raw meat

minetest.register_craftitem(
   "rp_mobs_mobs:meat_raw",
   {
      description = S("Raw Meat"),
      _rp_hunger_food = 3,
      _rp_hunger_sat = 30,
      inventory_image = "mobs_meat_raw.png",
      groups = { food = 2 },
      on_use = minetest.item_eat(0),
})

-- Cooked meat

minetest.register_craftitem(
   "rp_mobs_mobs:meat",
   {
      description = S("Cooked Meat"),
      _rp_hunger_food = 7,
      _rp_hunger_sat = 70,
      inventory_image = "mobs_meat_cooked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat(0),
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_mobs_mobs:meat",
      recipe = "rp_mobs_mobs:meat_raw",
      cooktime = 5,
})

-- Raw porkchop

minetest.register_craftitem(
   "rp_mobs_mobs:pork_raw",
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
   "rp_mobs_mobs:pork",
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
      output = "rp_mobs_mobs:pork",
      recipe = "rp_mobs_mobs:pork_raw",
      cooktime = 5,
})
