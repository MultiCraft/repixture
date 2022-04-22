--
-- Goodies mod
-- By Kaadmy, for Pixture
--

goodies = {}

goodies.max_stack_default = 6
goodies.max_items = 20

goodies.types = {}
goodies.types_valuable = {}
-- custom types
goodies.types["FURNACE_SRC"] = {
   ["rp_default:lump_iron"] = 3,
   ["rp_farming:flour"] = 5,
}
goodies.types["FURNACE_FUEL"] = {
   ["rp_default:lump_coal"] = 2,
   ["rp_default:planks_oak"] = 4,
   ["rp_default:planks_birch"] = 5,
}
goodies.types["FURNACE_DST"] = {
   ["rp_default:ingot_wrought_iron"] = 5,
   ["rp_farming:bread"] = 8,
}

-- chunk types for villages
if minetest.get_modpath("village") ~= nil then
   goodies.types["forge"] = {
      ["rp_default:lump_coal"] = 4,
      ["rp_default:lump_iron"] = 6,
      ["rp_default:pick_stone"] = 9,
      ["rp_default:tree_oak"] = 2,
      ["rp_default:ingot_steel"] = { chance = 20, max_stack = 1 },
   }
   goodies.types_valuable["forge"] = {
      ["rp_default:ingot_steel"] = 10,
      ["rp_default:ingot_carbon_steel"] = 12,
   }
   goodies.types["tavern"] = {
      ["bed:bed"] = { chance = 8, max_stack = 1},
      ["rp_default:bucket"] = 20,
      ["mobs:meat"] = 5,
      ["rp_default:ladder"] = 9,
   }
   goodies.types_valuable["tavern"] = {
      ["mobs:pork"] = 9,
   }
   goodies.types["house"] = {
      ["rp_default:stick"] = 2,
      ["rp_farming:bread"] = 6,
      ["rp_farming:cotton_1"] = 9,
      ["rp_farming:wheat_1"] = 6,
      ["rp_default:axe_stone"] = 13,
      ["rp_default:apple"] = 3,
      ["rp_default:bucket"] = 8,
      ["rp_default:bucket_water"] = 12,
   }
   goodies.types_valuable["house"] = {}

   -- jewels and gold
   if minetest.get_modpath("jewels") ~= nil then
      goodies.types_valuable["house"]["jewels:bench"] = { chance = 24, max_stack = 1 }
      goodies.types_valuable["house"]["jewels:jewel"] = 34
      goodies.types_valuable["tavern"]["jewels:jewel"] = 32
      goodies.types_valuable["forge"]["jewels:jewel"] = 30
   end
   if minetest.get_modpath("gold") ~= nil then
      goodies.types["forge"]["gold:ingot_gold"] = { chance = 24, max_stack = 2 }
      goodies.types["forge"]["gold:lump_gold"] = { chance = 18, max_stack = 6 }
      goodies.types_valuable["house"]["gold:ingot_gold"] = 12
      goodies.types_valuable["tavern"]["gold:ingot_gold"] = 10
      goodies.types_valuable["forge"]["gold:ingot_gold"] = 8
   end
end

goodies.types_all = {}

for k,v in pairs(goodies.types) do
  goodies.types_all[k] = table.copy(v)
end
for k,v in pairs(goodies.types_valuable) do
  if not goodies.types_all[k] then
    goodies.types_all[k] = table.copy(v)
  else
    for q,r in pairs(v) do
      goodies.types_all[k][q] = r
    end
  end
end

function goodies.fill(pos, ctype, pr, listname, keepchance)
   -- fill an inventory with a specified type's goodies

   if goodies.types_all[ctype] == nil then return end

   if pr:next(1, keepchance) ~= 1 then
      minetest.remove_node(pos)
      return
   end

   local meta = minetest.get_meta(pos)
   local inv = meta:get_inventory()

   local size = inv:get_size(listname)

   if size < 1 then return end

   local is_locked = false
   local node = minetest.get_node(pos)
   if minetest.get_item_group(node.name, "locked") > 0 then
      is_locked = true
   end

   -- In locked chests, double the amount of item attempts,
   -- 75% of which are drawn from all items,
   -- 25% are drawn only from valuable items.
   local item_amt = pr:next(1, size)
   local valuable_guaranteed_at
   if is_locked then
      item_amt = item_amt * 2
      valuable_guaranteed_at = item_amt * 0.75
   end

   local types
   -- Select initial items pool to draw items from
   if is_locked then
      types = goodies.types_all -- unvaluable and valuable
   else
      types = goodies.types -- unvaluable only
   end

   for i = 1, item_amt do
      if is_locked and i >= valuable_guaranteed_at then
         types = goodies.types_valuable
      end
      local item = util.choice(types[ctype], pr)
      local goodie = types[ctype][item]
      local chance, max_stack
      if type(goodie) == "table" then
         chance = goodie.chance
         max_stack = goodie.max_stack
      else
         chance = goodie
         max_stack = goodies.max_stack_default
      end
      if pr:next(1, chance) <= 1 then
	 local max = math.min(max_stack, minetest.registered_items[item].stack_max)
	 local itemstr = item.." "..pr:next(1, max)
         local slot = pr:next(1, size)
         if inv:get_stack(listname, slot):item_fits(ItemStack(itemstr)) then
	    inv:set_stack(listname, pr:next(1, size), ItemStack(itemstr))
         else
	    local leftover = inv:add_item(listname, ItemStack(itemstr))
            if not leftover:is_empty() then
               -- Chest is full, abort!
               break
            end
         end
      end
   end
end
