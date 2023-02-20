
--
-- Crafts and items
--
local S = minetest.get_translator("mobs")

-- Wool

minetest.register_node(
   "mobs:wool",
   {
      description = S("Wool Bundle"),
      tiles ={"mobs_wool.png"},
      is_ground_content = false,
      groups = {snappy = 2, oddly_breakable_by_hand = 3, fall_damage_add_percent = -25, fuzzy = 1, unmagnetic = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Raw meat

minetest.register_craftitem(
   "mobs:meat_raw",
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
   "mobs:meat",
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
      output = "mobs:meat",
      recipe = "mobs:meat_raw",
      cooktime = 5,
})

-- Net

minetest.register_tool(
   "mobs:net",
   {
      description = S("Net"),
      _tt_help = S("Good for capturing small animals"),
      inventory_image = "mobs_net.png",
})

crafting.register_craft(
   {
      output = "mobs:net",
      items= {
         "rp_default:fiber 3",
         "rp_default:stick",
      }
})

-- Lasso

minetest.register_tool(
   "mobs:lasso",
   {
      description = S("Lasso"),
      _tt_help = S("Good for capturing large animals"),
      inventory_image = "mobs_lasso.png",
})

crafting.register_craft(
   {
      output = "mobs:lasso",
      items = {
         "rp_default:rope 4",
         "rp_default:stick",
      }
})
