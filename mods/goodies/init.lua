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
   ["default:lump_iron"] = 3,
   ["farming:flour"] = 5,
}
goodies.types["FURNACE_FUEL"] = {
   ["default:lump_coal"] = 2,
   ["default:planks_oak"] = 4,
   ["default:planks_birch"] = 5,
}
goodies.types["FURNACE_DST"] = {
   ["default:ingot_wrought_iron"] = 5,
   ["farming:bread"] = 8,
}

-- chunk types for villages
if minetest.get_modpath("village") ~= nil then
   goodies.types["forge"] = {
      ["default:lump_coal"] = 4,
      ["default:lump_iron"] = 6,
      ["default:pick_stone"] = 9,
      ["default:tree_oak"] = 2,
   }
   goodies.types_valuable["forge"] = {
      ["default:ingot_steel"] = 10,
      ["default:ingot_carbon_steel"] = 12,
   }
   goodies.types["tavern"] = {
      ["bed:bed"] = { chance = 8, max_stack = 1},
      ["default:bucket"] = 20,
      ["mobs:meat"] = 5,
      ["default:ladder"] = 9,
   }
   goodies.types_valuable["tavern"] = {
      ["mobs:pork"] = 9,
   }
   goodies.types["house"] = {
      ["default:stick"] = 2,
      ["farming:bread"] = 6,
      ["farming:cotton_1"] = 9,
      ["farming:wheat_1"] = 6,
      ["default:axe_stone"] = 13,
      ["default:apple"] = 3,
      ["default:bucket"] = 8,
      ["default:bucket_water"] = 12,
   }

   -- jewels and gold
   if minetest.get_modpath("jewels") ~= nil then
      goodies.types_valuable["house"] = {
        ["jewels:bench"] = { chance = 24, max_stack = 1},
        ["jewels:jewel"] = 34,
      }
      goodies.types_valuable["tavern"] = { ["jewels:jewel"] = 32 }
      goodies.types_valuable["forge"] = { ["jewels:jewel"] = 30 }
   end
   if minetest.get_modpath("gold") ~= nil then
      goodies.types_valuable["house"] = { ["gold:ingot_gold"] = 12 }
      goodies.types_valuable["tavern"] = { ["gold:ingot_gold"] = 10 }
      goodies.types_valuable["forge"] = { ["gold:ingot_gold"] = 8 }
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

   local item_amt = pr:next(1, size)

   local types
   if is_locked then
      types = goodies.types_all
   else
      types = goodies.types
   end

   for i = 1, item_amt do
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
	 inv:set_stack(listname, pr:next(1, size), ItemStack(itemstr))
      end
   end
end
