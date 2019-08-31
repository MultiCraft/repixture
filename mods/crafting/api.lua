local S = minetest.get_translator("crafting")

-- Crafting menu display modes
local MODE_CRAFTABLE = 1 -- crafting guide mode, show all recipes (default)
local MODE_GUIDE = 2 -- craftable mode, only show recipes craftable from input slots

--
-- API
--

crafting = {}

-- Callbacks

crafting.callbacks = {}

-- Array of registered craft recipes

crafting.registered_crafts = {}

-- User table of last selected row etc.

crafting.userdata = {}

-- Crafting can only take 4 itemstacks as input for sanity/interface reasons

crafting.max_inputs = 4

-- Default crafting definition values

crafting.default_craftdef = {
   output = nil,
   items = {},
   groups = {},
}

function crafting.register_craft(def)
   if def.output == nil then
      minetest.log("warning",
                   "No output for craft recipe")
      return
   end

   local itemstack = ItemStack(def.output)
   local itemkey = itemstack:to_string()

   if crafting.registered_crafts[itemkey] ~= nil then
      minetest.log("warning",
                   "Tried to register an existing craft " .. itemkey .. ", allowing")
   end

   if not minetest.registered_items[itemstack:get_name()] then
      minetest.log("warning",
                   "Trying to register craft " .. itemkey
                      .. " that has an unknown output item")
   end

   local craftdef = {
      output = itemstack,
      items = def.items or crafting.default_craftdef.items,
      groups = def.groups or crafting.default_craftdef.groups,
   }

   if #craftdef.items > 4 then
      minetest.log("warning",
                   "Attempting to register craft " .. itemkey .." with more than "
                      .. crafting.max_inputs .. " inputs, allowing")
   end

   for i = 1, crafting.max_inputs do
      if craftdef.items[i] ~= nil then
         craftdef.items[i] = ItemStack(craftdef.items[i])
      end
   end

   crafting.registered_crafts[itemkey] = craftdef

   minetest.log("info", "Registered recipe for " .. itemkey)
end

function crafting.get_crafts(player_inventory)
   local results = {}

   local function get_filtered()
      for craftname, craftdef in pairs(crafting.registered_crafts) do
         local contains_all = true
         for c=1, #craftdef.items do
             local name = craftdef.items[c]:get_name()
             if string.sub(name, 1, 6) == "group:" then
                 local group = string.sub(name, 7)
                 local gcount = craftdef.items[c]:get_count()
                 local items_in = player_inventory:get_list("craft_in")
                 if items_in == nil then
                     contains_all = false
                     break
                 end
                 local count = 0
                 for i=1, #items_in do
                     if minetest.get_item_group(items_in[i]:get_name(), group) ~= 0 then
                         count = count + items_in[i]:get_count()
                     end
                 end
                 if count < gcount then
                     contains_all = false
                     break
                 end
             elseif not player_inventory:contains_item("craft_in", craftdef.items[c]) then
                 contains_all = false
                 break
             end
         end
         if contains_all then
             table.insert(results, craftname)
         end
      end
   end

   local function get_all()
      for craftname, _ in pairs(crafting.registered_crafts) do
         table.insert(results, craftname)
      end
   end

   if player_inventory == nil then
      get_all()
   else
      get_filtered()
   end

   local function sort_function(a, b)
      local a_itemn = ItemStack(a):get_name()
      local b_itemn = ItemStack(b):get_name()

      local a_name = minetest.registered_items[a_itemn].description
      local b_name = minetest.registered_items[b_itemn].description

      return a_name < b_name
   end

   table.sort(results, sort_function)

   return results
end

function crafting.register_on_craft(func)
   if not crafting.callbacks.on_craft then
      crafting.callbacks.on_craft = {}
   end

   table.insert(crafting.callbacks.on_craft, func)
end

function crafting.craft(player, wanted, wanted_count, output, items)
   -- `output` can be any ItemStack value
   -- Duplicate items in `items` should work correctly

   local craftdef = crafting.registered_crafts[wanted:to_string()]

   if craftdef == nil then
      minetest.log("warning",
                   "Tried to craft an unregistered item " .. wanted:to_string())

      return nil
   end

   -- Check for validity

   local craft_count = wanted_count

   for i = 1, crafting.max_inputs do
      local required_itemstack = ItemStack(craftdef.items[i])
      local itemc = 0

      local group = string.match(required_itemstack:get_name(), "group:(.*)")

      if required_itemstack ~= nil and required_itemstack:get_count() ~= 0 then
         for j = 1, crafting.max_inputs do
            local input_itemstack = ItemStack(items[j])

            if (group ~= nil
                   and minetest.get_item_group(input_itemstack:get_name(), group) ~= 0)
               or (input_itemstack ~= nil
                   and input_itemstack:get_name() == required_itemstack:get_name()) then
                  itemc = itemc + input_itemstack:get_count()
            end
         end

         craft_count = math.min(craft_count,
                                math.floor(itemc / required_itemstack:get_count()))

         if craft_count < 1 then
            return nil -- Not enough items to craft
         end
      end
   end

   -- Put stuff in output stack

   local free_space = wanted:get_stack_max() - output:get_count()
   if free_space < (craft_count * craftdef.output:get_count()) then
      craft_count = math.floor(free_space / craftdef.output:get_count())
   end

   if craft_count < 1 then
      return nil -- Can't hold any output
   end

   output:add_item(
      ItemStack({
            name = craftdef.output:get_name(),
            count = craftdef.output:get_count() * craft_count
   }))

   -- Iterate through second time to take items used for crafting

   local function remove_used_item(itemn, count)
      local items_required = count

      local group = string.match(itemn, "group:(.*)")

      for i = 1, crafting.max_inputs do
         local input_itemstack = ItemStack(items[i])

         if (group ~= nil
                and minetest.get_item_group(input_itemstack:get_name(), group) ~= 0)
            or (items[i] ~= nil
                and input_itemstack:get_name() == itemn) then
               local items_left = items_required - input_itemstack:get_count()

               input_itemstack:take_item(items_required)

               if items_left > 0 then
                  items_required = items_required - (items_required - items_left)
               else
                  items[i] = input_itemstack:to_table()
                  break
               end

               items[i] = input_itemstack:to_table()
         end
      end
   end

   for i = 1, crafting.max_inputs do
      local required_itemstack = ItemStack(craftdef.items[i])

      if craftdef.items[i] ~= nil then
         remove_used_item(required_itemstack:get_name(),
                          required_itemstack:get_count() * craft_count)
      end
   end

   for _, func in ipairs(crafting.callbacks.on_craft) do
      for i = 1, (craftdef.output:get_count() * craft_count) do
         func(output, player)
      end
   end

   return {items = items, output = output}
end

local form = default.ui.get_page("default:2part")

form = form .. "field[-1,-1;0,0;crafting_tracker;;]"

form = form .. "list[current_player;main;0.25,4.75;8,4;]"
form = form .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form = form .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

form = form .. "list[current_player;craft_in;0.25,0.25;1,4;]"

form = form .. "list[current_player;craft_out;7.25,3.25;1,1;]"

form = form .. "listring[current_player;main]"
form = form .. "listring[current_player;craft_in]"
form = form .. "listring[current_player;main]"
form = form .. "listring[current_player;craft_out]"

form = form .. default.ui.get_itemslot_bg(0.25, 0.25, 1, 4)
form = form .. default.ui.get_itemslot_bg(7.25, 3.25, 1, 1)

-- FIXME: This is placed below the item display, so it would collide with a potential 4th item in a craft recipe
-- As of 0.1.1, no craft used more than 3 item stacks so far.
form = form .. default.ui.button(1.25, 3.25, 1.0, 1.0, "toggle_filter", "?", nil, S("Show all recipes/show only craftable recipes"))
form = form .. default.ui.button(7.25, 1.25, 1, 1, "do_craft_1", "1")
form = form .. default.ui.button(7.25, 2.25, 1, 1, "do_craft_10", "10")

form = form .. "tableoptions[background=#DDDDDD30]"
form = form .. "tablecolumns[text,align=left,width=2;text,align=left,width=40]"

default.ui.register_page("crafting:crafting", form)

function crafting.get_formspec(name, select_item)
   local row = 1

   if crafting.userdata[name] ~= nil then
      row = crafting.userdata[name].row
   end

   local inv = minetest.get_player_by_name(name):get_inventory()

   local craft_list = ""

   local craftitems
   if crafting.userdata[name] and crafting.userdata[name].mode == MODE_GUIDE then
       craftitems = crafting.get_crafts()
   else
       craftitems = crafting.get_crafts(inv)
   end
   if select_item == nil then
       if row > #craftitems then
           row = #craftitems
           if crafting.userdata[name] ~= nil then
               crafting.userdata[name].row = row
           end
       elseif row < 1 and #craftitems >= 1 then
           row = 1
           if crafting.userdata[name] ~= nil then
               crafting.userdata[name].row = row
           end
       end
   end

   local selected_craftdef = nil

   local craft_count = 0
   for i, itemn in ipairs(craftitems) do
      local itemstack = ItemStack(itemn)
      local itemname = itemstack:get_name()
      local itemdef = minetest.registered_items[itemname]

      if select_item then
         if itemname == select_item then
            selected_craftdef = crafting.registered_crafts[itemn]
            row = i
            if crafting.userdata[name] ~= nil then
                crafting.userdata[name].row = row
            end
         end
      elseif i == row then
         selected_craftdef = crafting.registered_crafts[itemn]
      end

      if itemdef ~= nil then
        local craftdef = crafting.registered_crafts[itemn]

         if craft_list ~= "" then
            craft_list = craft_list .. ","
         end

         if itemstack:get_count() ~= 1 then
            craft_list = craft_list .. minetest.formspec_escape(itemstack:get_count())
         end

         local desc = itemdef.description
         -- Cut off item description after first newline
         local firstnewline = string.find(desc, "\n")
         if firstnewline then
             desc = string.sub(desc, 1, firstnewline-1)
         end

         craft_list = craft_list .. "," .. minetest.formspec_escape(desc)
         craft_count = craft_count + 1
      end
   end
   if select_item and (not selected_craftdef) and #craftitems > 0 then
      row = 1
      selected_craftdef = crafting.registered_crafts[craftitems[row]]
      if crafting.userdata[name] ~= nil then
          crafting.userdata[name].row = row
      end
   end

   local form = default.ui.get_page("crafting:crafting")

   if craft_count > 0 then
       form = form .. "table[2.25,0.25;4.75,3.75;craft_list;" .. craft_list
          .. ";" .. row .. "]"
   end

   if selected_craftdef ~= nil then
      if selected_craftdef.items[1] ~= nil then
         form = form .. default.ui.fake_itemstack_any(
            1.25, 0.25, selected_craftdef.items[1], "craftex_in_1")
      end
      if selected_craftdef.items[2] ~= nil then
         form = form .. default.ui.fake_itemstack_any(
            1.25, 1.25, selected_craftdef.items[2], "craftex_in_2")
      end
      if selected_craftdef.items[3] ~= nil then
         form = form .. default.ui.fake_itemstack_any(
            1.25, 2.25, selected_craftdef.items[3], "craftex_in_3")
      end
      if selected_craftdef.items[4] ~= nil then
         form = form .. default.ui.fake_itemstack_any(
            1.25, 3.25, selected_craftdef.items[4], "craftex_in_4")
      end
      if selected_craftdef.output ~= nil then
         form = form .. default.ui.fake_itemstack_any(
            7.25, 0.25, selected_craftdef.output, "craftex_out")
      end
   end

   return form
end

local function clear_craft_slots(player)
   local inv = player:get_inventory()
   -- Move items out of input and output slots
   local items_moved = false
   local pos = player:get_pos()
   local lists = { "craft_out", "craft_in" }
   for l = 1, #lists do
      local list = lists[l]
      for i = 1, inv:get_size(list) do
          local itemstack = inv:get_stack(list, i)
          if not itemstack:is_empty() then
              if inv:room_for_item("main", itemstack) then
                  inv:add_item("main", itemstack)
              else
                  item_drop.drop_item(pos, itemstack)
              end

              itemstack:clear()
              inv:set_stack(list, i, itemstack)

              items_moved = true
          end
      end
   end

   if items_moved then
       player:set_inventory_formspec(crafting.get_formspec(player:get_player_name()))
   end
end

local function on_player_receive_fields(player, form_name, fields)
   local inv = player:get_inventory()


   if fields.quit then
      clear_craft_slots(player)
   end

   if fields.crafting_tracker == nil then
      return
   end

   local name = player:get_player_name()

   local do_craft_1, do_craft_10 = false, false
   if fields.craft_list then
      -- Double-click on list entry crafts single time
      local selection = minetest.explode_table_event(fields.craft_list)
      if selection.type == "DCL" then
          do_craft_1 = true
      end
   else
      do_craft_1 = fields.do_craft_1 ~= nil
   end
   do_craft_10 = fields.do_craft_10 ~= nil
   if do_craft_1 or do_craft_10 then
      local craftitems
      if crafting.userdata[name] and crafting.userdata[name].mode == MODE_GUIDE then
          craftitems = crafting.get_crafts()
      else
          craftitems = crafting.get_crafts(inv)
      end

      local wanted_itemstack = ItemStack(craftitems[crafting.userdata[name].row])
      local output_itemstack = inv:get_stack("craft_out", 1)

      if output_itemstack:get_name() ~= wanted_itemstack:get_name()
      and output_itemstack:get_count() ~= 0 then
         return -- Different item type in output already
      end

      local count = 1

      if do_craft_1 then
         count = 1
      elseif do_craft_10 then
         count = 10
      else
         return
      end

      local crafted = crafting.craft(player, wanted_itemstack, count,
                                     output_itemstack, inv:get_list("craft_in"))

      if crafted then
         inv:set_stack("craft_out", 1, "")

         if inv:room_for_item("craft_out", crafted.output) then
            inv:set_stack("craft_out", 1, crafted.output)

            -- FIXME? inv:set_list worked in 0.4.15 but no longer works for some reason
            inv:set_stack("craft_in", 1, crafted.items[1])
            inv:set_stack("craft_in", 2, crafted.items[2])
            inv:set_stack("craft_in", 3, crafted.items[3])
            inv:set_stack("craft_in", 4, crafted.items[4])

            crafting.update_crafting_formspec(player)
         end
      end
   elseif fields.craft_list then
      local selection = minetest.explode_table_event(fields.craft_list)

      if selection.type == "CHG" or selection.type == "DCL" then
         crafting.userdata[name].row = selection.row

         minetest.show_formspec(name, "crafting:crafting",
                                crafting.get_formspec(name))
      end
   elseif fields.toggle_filter then
      local craftitems
      if crafting.userdata[name] and crafting.userdata[name].mode == MODE_GUIDE then
          craftitems = crafting.get_crafts()
      else
          craftitems = crafting.get_crafts(inv)
      end
      local old_item = craftitems[crafting.userdata[name].row]
      if crafting.userdata[name].mode == MODE_GUIDE then
          crafting.userdata[name].mode = MODE_CRAFTABLE
      else
          crafting.userdata[name].mode = MODE_GUIDE
      end

      minetest.show_formspec(name, "crafting:crafting",
                             crafting.get_formspec(name, old_item))
   end

   player:set_inventory_formspec(crafting.get_formspec(name))
end

function crafting.update_crafting_formspec(player)
   local name = player:get_player_name()
   minetest.show_formspec(name, "crafting:crafting",
                          crafting.get_formspec(name))
   player:set_inventory_formspec(crafting.get_formspec(name))
end

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
   if action == "put" then
      if inventory_info.listname == "craft_out" then
          return 0
      end
   elseif action == "move" then
      if inventory_info.to_list == "craft_out" then
          return 0
      end
   end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
   if action == "move" then
      if inventory_info.from_list == "craft_in" or inventory_info.to_list == "craft_in" then
          crafting.update_crafting_formspec(player)
      end
   elseif action == "put" or action == "take" then
      if inventory_info.listname == "craft_in" then
          crafting.update_crafting_formspec(player)
      end
   end
end)

local function on_joinplayer(player)
   local name = player:get_player_name()

   local inv = player:get_inventory()

   if crafting.userdata[name] == nil then
      crafting.userdata[name] = {row = 1, mode = MODE_CRAFTABLE}
   end

   if inv:get_size("craft_in") ~= 4 then
      inv:set_size("craft_in", 4)
   end

   if inv:get_size("craft_out") ~= 1 then
      inv:set_size("craft_out", 1)
   end

   clear_craft_slots(player)
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   crafting.userdata[name] = nil
end

if minetest.get_modpath("drop_items_on_die") ~= nil then
   drop_items_on_die.register_listname("craft_in")
   drop_items_on_die.register_listname("craft_out")
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_player_receive_fields(on_player_receive_fields)

default.log("api", "loaded")
