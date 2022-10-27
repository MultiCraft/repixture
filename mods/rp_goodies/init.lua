--
-- Goodies mod
--

goodies = {}

goodies.max_stack_default = 6
goodies.max_items = 20

goodies.types = {}
goodies.types_valuable = {}
-- custom types
goodies.types["FURNACE_SRC_general"] = {
   ["rp_default:lump_iron"] = 3,
   ["rp_farming:flour"] = 5,
   ["rp_farming:potato_1"] = 8,
}
goodies.types["FURNACE_FUEL_general"] = {
   ["rp_default:lump_coal"] = 2,
   ["rp_default:planks_oak"] = 4,
   ["rp_default:planks_birch"] = 5,
}
goodies.types["FURNACE_DST_general"] = {
   ["rp_default:ingot_wrought_iron"] = 5,
   ["rp_farming:bread"] = 8,
   ["rp_farming:potato_baked"] = 9,
}

goodies.types["BOOKSHELF"] = {
   ["rp_default:book_empty"] = { chance = 4, max_stack = 1 },
   ["rp_default:paper"] = 16,
}

-- chunk types for villages
if minetest.get_modpath("rp_village") ~= nil then
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
      ["rp_bed:bed"] = { chance = 8, max_stack = 1},
      ["rp_default:bucket"] = 20,
      ["rp_farming:potato_baked"] = 5,
      ["rp_default:ladder"] = 9,
   }
   goodies.types_valuable["tavern"] = {
      ["rp_farming:bread"] = 5,
      ["mobs:meat"] = 7,
      ["mobs:pork"] = 9,
      ["rp_farming:asparagus_cooked"] = 9,
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
   goodies.types["hut"] = {
      ["rp_default:stick"] = 2,
      ["rp_farming:asparagus_cooked"] = 6,
      ["rp_farming:asparagus_1"] = 9,
      ["rp_default:axe_stone"] = 13,
      ["rp_default:shovel_stone"] = 13,
      ["rp_default:acorn"] = 3,
      ["rp_default:bucket"] = 8,
      ["rp_default:bucket_swamp_water"] = 12,
   }
   goodies.types["workshop"] = {
      ["rp_default:stick"] = 2,
      ["rp_default:fiber"] = 2,
      ["rp_default:planks_oak"] = 6,
      ["rp_default:planks_birch"] = 6,
      ["rp_default:bucket"] = 8,
      ["rp_default:axe_stone"] = 10,
      ["rp_default:pick_stone"] = 10,
      ["rp_default:spear_stone"] = 10,
      ["rp_default:shovel_stone"] = 10,
      ["rp_default:ladder"] = 10,
      ["rp_farming:cotton"] = 12,
   }
   goodies.types["bakery"] = {
      ["rp_farming:bread"] = 4,
      ["rp_farming:flour"] = 8,
      ["rp_farming:wheat"] = 12,
      ["rp_default:lump_coal"] = 15,
   }
   goodies.types["FURNACE_SRC_bakery"] = {
      ["rp_farming:flour"] = 4,
   }
   goodies.types["FURNACE_FUEL_bakery"] = {
      ["rp_default:lump_coal"] = 2,
      ["rp_default:planks_oak"] = 6,
      ["rp_default:planks_birch"] = 6,
   }
   goodies.types["FURNACE_DST_bakery"] = {
      ["rp_farming:bread"] = 7,
   }

   goodies.types_valuable["bakery"] = {
      ["rp_farming:bread"] = 5,
   }
   goodies.types_valuable["workshop"] = {
      ["rp_default:reinforced_frame"] = 20,
      ["rp_default:reinforced_cobble"] = 5,
      ["rp_default:axe_wrought_iron"] = 10,
      ["rp_default:pick_wrought_iron"] = 10,
      ["rp_default:spear_wrought_iron"] = 10,
      ["rp_default:shovel_wrought_iron"] = 10,
      ["rp_default:ingot_steel"] = 20,
      ["rp_locks:lock"] = 20,
   }
   goodies.types_valuable["house"] = {}
   goodies.types_valuable["hut"] = {}

   -- jewels and gold
   if minetest.get_modpath("rp_jewels") ~= nil then
      goodies.types_valuable["house"]["rp_jewels:bench"] = { chance = 24, max_stack = 1 }
      goodies.types_valuable["house"]["rp_jewels:jewel"] = 34
      goodies.types_valuable["hut"]["rp_jewels:bench"] = { chance = 24, max_stack = 1 }
      goodies.types_valuable["hut"]["rp_jewels:jewel"] = 34
      goodies.types_valuable["tavern"]["rp_jewels:jewel"] = 32
      goodies.types_valuable["forge"]["rp_jewels:jewel"] = 30
      goodies.types_valuable["workshop"]["rp_jewels:jewel"] = 28
   end
   if minetest.get_modpath("rp_gold") ~= nil then
      goodies.types["forge"]["rp_gold:ingot_gold"] = { chance = 24, max_stack = 2 }
      goodies.types["forge"]["rp_gold:lump_gold"] = { chance = 18, max_stack = 6 }
      goodies.types_valuable["house"]["rp_gold:ingot_gold"] = 12
      goodies.types_valuable["hut"]["rp_gold:ingot_gold"] = 12
      goodies.types_valuable["tavern"]["rp_gold:ingot_gold"] = 10
      goodies.types_valuable["forge"]["rp_gold:ingot_gold"] = 8
      goodies.types_valuable["bakery"]["rp_gold:ingot_gold"] = 11
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

   -- Remove/replace node with a certain chance
   if pr:next(1, keepchance) ~= 1 then
      -- Check if node above is a falling node
      local above = vector.add(pos, vector.new(0, 1, 0))
      local anode = minetest.get_node(above)
      if minetest.get_item_group(anode.name, "falling_node") >= 1 then
         -- If yes, make sure we don't end up with a floating
	 -- falling node.
         local below = vector.add(pos, vector.new(0, -1, 0))
         local bnode = minetest.get_node(below)
         local bdef = minetest.registered_nodes[bnode.name]
	 -- If node below is walkable, copy the falling node to the container pos
	 if bdef.walkable then
            minetest.set_node(pos, anode)
         else
            -- Wooden planks are the final fallback for the container
	    -- (this is just a block to stop the fall)
            minetest.set_node(pos, {name="rp_default:planks"})
         end
	 return
      end
      -- Regular case: Just remove the node
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

-- In testing mode, verify if all goodies are known, valid and registered items
local function goodies_verify()
   for location, ldata in pairs(goodies.types_all) do
      for goodie, gdata in pairs(ldata) do
	 if type(goodie) ~= "string" then
            minetest.log("error", "[rp_goodies] Malformed goodie found: "..tostring(goodie).." (type="..type(goodie)..")")
         elseif goodie == "" then
            minetest.log("error", "[rp_goodies] Empty string goodie found")
         elseif not minetest.registered_items[goodie] then
            local alias = minetest.registered_aliases[goodie]
	    if not alias or not minetest.registered_items[alias] then
               minetest.log("error", "[rp_goodies] Unknown goodie found: "..tostring(goodie))
            end
	 end
      end
   end
end
if minetest.settings:get_bool("rp_testing_enable", false) then
   goodies_verify()
end
