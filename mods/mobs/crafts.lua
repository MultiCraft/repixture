
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
      sounds = rp_sounds.node_sound_fuzzy_defaults(),
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


-- on_use function for the mob capturing tools.
-- This currently triggers the on_rightclick handler of
-- the mob, which might call capture_mob.
-- This is somewhat hacky but works for now, but
-- (TODO) the whole system needs improvement later.
local capture_tool_on_use = function(itemstack, player, pointed_thing)
    if pointed_thing.type ~= "object" then
        return
    end
    if not player or not player:is_player() then
        return
    end
    local ent = pointed_thing.ref:get_luaentity()
    if ent and ent._cmi_is_mob then
        if ent.on_rightclick then
            ent:on_rightclick(player)
        end
    end
end

-- Net

minetest.register_tool(
   "mobs:net",
   {
      description = S("Net"),
      _tt_help = S("Good for capturing small animals"),
      inventory_image = "mobs_net.png",
      on_use = capture_tool_on_use,
      -- Note: no on_place function as mobs have their on_rightclick handlers
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
      on_use = capture_tool_on_use,
})

crafting.register_craft(
   {
      output = "mobs:lasso",
      items = {
         "rp_default:rope 4",
         "rp_default:stick",
      }
})
