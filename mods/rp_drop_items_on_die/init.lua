-- Drop items on die mod

drop_items_on_die = {}

drop_items_on_die.registered_listnames = {}

local enable_drop = minetest.settings:get_bool("drop_items_on_die") or false

function drop_items_on_die.register_listname(listname)
   table.insert(drop_items_on_die.registered_listnames, listname)
end

local function on_die(player)
   local pos = player:get_pos()
   pos = vector.add(pos, {x=0,y=0.5,z=0})

   local inv = player:get_inventory()

   for _, listname in ipairs(drop_items_on_die.registered_listnames) do
      for i = 1, inv:get_size(listname) do
         local item = inv:get_stack(listname, i)

         item_drop.drop_item(pos, item)

         item:clear()

         inv:set_stack(listname, i, item)
      end
   end
end

if enable_drop then
   minetest.register_on_dieplayer(on_die)

   drop_items_on_die.register_listname("main")
end
