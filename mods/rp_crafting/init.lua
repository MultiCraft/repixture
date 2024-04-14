local S = minetest.get_translator("rp_crafting")

-- Crafting menu display modes
local MODE_CRAFTABLE = 1 -- crafting guide mode, show all recipes (default)
local MODE_GUIDE = 2 -- craftable mode, only show recipes craftable from input slots

local mod_creative = minetest.get_modpath("rp_creative") ~= nil

--
-- API
--

crafting = {}

-- Callbacks

crafting.callbacks = {}

-- Array of registered craft recipes

crafting.registered_crafts = {}

-- User table of last selected row etc.

local userdata = {}

-- Crafting can only take a limited number of itemstacks as
-- input for sanity/interface reasons

crafting.MAX_INPUTS = 4

-- Unique ID for crafting recipes
local max_craft_id = 0

-- Default crafting definition values

local default_craftdef = {
   output = nil,
   items = {},
}

function crafting.register_craft(def)
   if def.output == nil or def.output == "" then
      minetest.log("error",
                   "[rp_crafting] No output for craft recipe, ignoring")
      return
   end

   local itemstack = ItemStack(def.output)
   local output = itemstack:to_string()
   max_craft_id = max_craft_id + 1
   local itemkey = max_craft_id

   if not minetest.registered_items[itemstack:get_name()] then
      minetest.log("warning",
                   "[rp_crafting] Trying to register craft #"..itemkey.." ('" .. output
                      .. "') that has an unknown output item, allowing")
   end

   local craftdef = {
      output = itemstack,
      output_str = output,
      items = def.items or default_craftdef.items,
   }

   if #craftdef.items > crafting.MAX_INPUTS then
      minetest.log("warning",
                   "[rp_crafting] Attempting to register craft #" .. itemkey .." ("..output..") with more than "
                      .. crafting.MAX_INPUTS .. " inputs, allowing")
   end

   for i = 1, crafting.MAX_INPUTS do
      if craftdef.items[i] ~= nil then
         craftdef.items[i] = ItemStack(craftdef.items[i])
      end
   end

   crafting.registered_crafts[itemkey] = craftdef

   minetest.log("info", "[rp_crafting] Registered craft #" .. itemkey .." for " .. output)

   return itemkey
end

-- Cache the crafting list for the crafting guide for a much faster
-- loading time.
-- The crafting guide list only needs to be generated once because
-- it will never change.
local all_crafts_cached

function crafting.get_crafts(player_inventory, player_name)
   local results = {}

   local function get_filtered()
      for craft_id, craftdef in pairs(crafting.registered_crafts) do
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
             table.insert(results, craft_id)
         end
      end
   end

   local function get_all()
      for craft_id, craft in pairs(crafting.registered_crafts) do
         local output_stack = ItemStack(craft.output)
         local name = output_stack:get_name()
         -- Hide items with the 'not_in_craft_guide' group when the crafting guide is active;
         -- These items are only craftable with the craft guide disabled.
         -- This is useful for secret crafting recipes.
         if minetest.get_item_group(name, "not_in_craft_guide") == 0 then
            table.insert(results, craft_id)
         end
      end
   end

   local function sort_crafts()
      local lang_code = minetest.get_player_information(player_name).lang_code

      local function sort_function(a, b)
	 local a_item = crafting.registered_crafts[a].output
	 local b_item = crafting.registered_crafts[b].output

         local a_itemn = a_item:get_name()
         local b_itemn = b_item:get_name()

         local a_name = minetest.get_translated_string(lang_code, minetest.registered_items[a_itemn].description)
         local b_name = minetest.get_translated_string(lang_code, minetest.registered_items[b_itemn].description)

         return a_name < b_name
      end
      table.sort(results, sort_function)
   end

   if player_inventory == nil then
      if all_crafts_cached then
         results = all_crafts_cached
      else
         get_all()
	 sort_crafts()
	 all_crafts_cached = table.copy(results)
      end
   else
      get_filtered()
      sort_crafts()
   end

   return results
end

function crafting.register_on_craft(func)
   if not crafting.callbacks.on_craft then
      crafting.callbacks.on_craft = {}
   end

   table.insert(crafting.callbacks.on_craft, func)
end

function crafting.craft(player, wanted, wanted_count, output, items, craft_id)
   -- `output` can be any ItemStack value
   -- Duplicate items in `items` should work correctly
   if wanted:is_empty() then
      return nil
   end

   local craftdef = crafting.registered_crafts[craft_id]

   if craftdef == nil then
      minetest.log("error",
                   "[rp_crafting] Tried to craft unknown recipe #"..craft_id)
      return nil
   end

   -- Check for validity

   local craft_count = wanted_count

   for i = 1, crafting.MAX_INPUTS do
      local required_itemstack = ItemStack(craftdef.items[i])
      local itemc = 0

      local group = string.match(required_itemstack:get_name(), "group:(.*)")

      if required_itemstack ~= nil and required_itemstack:get_count() ~= 0 then
         for j = 1, crafting.MAX_INPUTS do
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

      for i = 1, crafting.MAX_INPUTS do
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

   for i = 1, crafting.MAX_INPUTS do
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

local form = rp_formspec.get_page("rp_formspec:2part")

form = form .. rp_formspec.default.player_inventory

form = form .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"
form = form .. rp_formspec.get_itemslot_bg(0, 0, 1, 4)
form = form .. "list[current_player;craft_in;0,0;1,4;]"

form = form .. "listring[current_player;main]"
form = form .. "listring[current_player;craft_in]"
form = form .. "listring[current_player;main]"

form = form .. "container_end[]"

form = form .. "tablecolumns[text,align=left,width=2;text,align=left,width=40]"

function crafting.get_formspec(name)
   local row = 1
   local select_craft_id

   if userdata[name] ~= nil then
      row = userdata[name].row
      select_craft_id = userdata[name].old_craft_id
      userdata[name].old_craft_id = nil
   end

   local inv = minetest.get_player_by_name(name):get_inventory()

   local craft_list = ""

   local craftitems
   if userdata[name] and userdata[name].mode == MODE_GUIDE then
       craftitems = crafting.get_crafts(nil, name)
   else
       craftitems = crafting.get_crafts(inv, name)
   end
   if select_craft_id == nil then
       if row > #craftitems then
           row = #craftitems
           if userdata[name] ~= nil then
               userdata[name].row = row
           end
       elseif row < 1 and #craftitems >= 1 then
           row = 1
           if userdata[name] ~= nil then
               userdata[name].row = row
           end
       end
   end

   local selected_craftdef = nil

   local BUTTONS_WIDTH = 5
   local BUTTONS_HEIGHT = 4

   local craft_count = 0
   local crx, cry = 0, 0
   for i, craft_id in ipairs(craftitems) do
      local itemstack = crafting.registered_crafts[craft_id].output
      local itemstring = itemstack:to_string()
      local itemname = itemstack:get_name()
      local itemdef = minetest.registered_items[itemname]

      if select_craft_id then
         if craft_id == select_craft_id then
            selected_craftdef = crafting.registered_crafts[craft_id]
            row = i
            if userdata[name] ~= nil then
                userdata[name].row = row
            end
         end
      elseif i == row then
         selected_craftdef = crafting.registered_crafts[craft_id]
      end

      if itemdef ~= nil then
         if craft_list ~= "" then
            --craft_list = craft_list .. ","
         end

         if itemstack:get_count() ~= 1 then
            local cnt = tostring(itemstack:get_count())
            --craft_list = craft_list .. minetest.formspec_escape(cnt)
         end

         local desc = itemstack:get_short_description()

         --craft_list = craft_list .. "," .. minetest.formspec_escape(desc)
         local iib_item = itemname .. " " .. itemstack:get_count()
         craft_list = craft_list .. "item_image_button["..(crx*1.1)..","..(cry*1.1)..";0.9,0.9;"..iib_item..";".."craft_select_"..i..";]"
	
         crx = crx + 1
         if crx >= BUTTONS_WIDTH then
            crx = 0
            cry = cry + 1
         end

         craft_count = craft_count + 1
      end
   end
   if select_craft_id and (not selected_craftdef) and #craftitems > 0 then
      row = 1
      selected_craftdef = crafting.registered_crafts[craftitems[row]]
      if userdata[name] ~= nil then
          userdata[name].row = row
      end
   end

   local form = rp_formspec.get_page("rp_crafting:crafting")

   form = form .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"

   -- Crafting list
   if craft_count > 0 then
       -- Text list
       --form = form .. "table[1.5,0;6,4.5;craft_list;" .. craft_list
       --   .. ";" .. row .. "]"

       -- Recipe selector
       if craft_count > BUTTONS_WIDTH*BUTTONS_HEIGHT then
          -- Render scrollbar if scrolling is neccessary
          local scrollmax = math.max(1, cry * 1 - BUTTONS_HEIGHT)
          local scrollpos = (userdata[name] and userdata[name].scrollpos) or 0
          form = form .. "scrollbaroptions[min=0;max="..scrollmax..";smallstep="..BUTTONS_HEIGHT..";largestep="..(BUTTONS_HEIGHT*2).."]"
          form = form .. "scrollbar[6.7,0;0.4,4.4;vertical;craft_scroller;"..scrollpos.."]"
       end
       form = form .. "scroll_container[1.25,0;5.35,4.25;craft_scroller;vertical;1.1]"

       -- Craft recipe button style
       form = form .. "style_type[item_image_button;bgimg=ui_button_crafting_inactive.png;border=false;padding=2]"
       form = form .. "style_type[item_image_button:pressed;bgimg=ui_button_crafting_active.png;border=false;padding=2]"
       if row then
          -- Current selected button
          form = form .. "style[craft_select_"..row..";bgimg=ui_button_crafting_selected_inactive.png]"
          form = form .. "style[craft_select_"..row..":pressed;bgimg=ui_button_crafting_selected_active.png]"
       end

       -- Craft recipe buttons
       form = form .. craft_list
       form = form .. "scroll_container_end[]"
   end

   if selected_craftdef ~= nil then
      local input_items = 0
      -- Crafting input slots
      for i=1, crafting.MAX_INPUTS do
         local y = (i-1) * (1 + rp_formspec.default.list_spacing.y)
         if selected_craftdef.items[i] ~= nil then
            input_items = input_items + 1
            form = form .. rp_formspec.fake_itemstack_any(
               7.25, y, selected_craftdef.items[i], "craftex_in_"..i)
         end
      end

      -- Crafting buttons and output preview
      if selected_craftdef.output ~= nil then
         form = form .. rp_formspec.fake_itemstack_any(
            8.95, 0, selected_craftdef.output, "craftex_out")

         if input_items >= 1 and input_items <= crafting.MAX_INPUTS then
            -- Arrow(s) pointing from input to output (a visual helper)
            form = form .. "image[8.35,0;0.5,4;ui_crafting_arrow_"..input_items..".png]"
         end

         -- Show crafting buttons only if something is selected
         form = form .. rp_formspec.button(8.95, 1.15, 1, 1, "do_craft_1", "1", nil, S("Craft once"))
         form = form .. rp_formspec.button(8.95, 2.3, 1, 1, "do_craft_10", "10", nil, S("Craft 10 times"))
      end
   end
   form = form .. "container_end[]"

   -- Crafting guide button
   local guide_icon, guide_tip, guide_pushed
   if userdata[name] and userdata[name].mode == MODE_GUIDE then
      guide_icon = "ui_icon_craftingguide_active.png"
      guide_tip = S("Show only craftable recipes")
      guide_pushed = true
   else
      guide_icon = "ui_icon_craftingguide.png"
      guide_tip = S("Show all recipes")
      guide_pushed = false
   end
   form = form .. rp_formspec.tab(rp_formspec.default.size.x, 0.5, "toggle_filter", guide_icon, guide_tip, "right", guide_pushed)

   return form
end
rp_formspec.register_page("rp_crafting:crafting", form)
rp_formspec.register_invpage("rp_crafting:crafting", {
	get_formspec = crafting.get_formspec,
	_is_startpage = function(pname)
		if mod_creative and minetest.is_creative_enabled(pname) then
			return false
		else
			return true
		end
	end,
})

rp_formspec.register_invtab("rp_crafting:crafting", {
   icon = "ui_icon_crafting.png",
   icon_active = "ui_icon_crafting_active.png",
   tooltip = S("Crafting"),
})

local function clear_craft_slots(player)
   local inv = player:get_inventory()
   -- Move items out of input and output slots
   local items_moved = false
   local pos = player:get_pos()
   local lists = { "craft_in" }
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
       rp_formspec.refresh_invpage(player, "rp_crafting:crafting")
   end
end

local function on_player_receive_fields(player, form_name, fields)
   local inv = player:get_inventory()

   local invpage = rp_formspec.get_current_invpage(player)
   if not (form_name == "" and invpage == "rp_crafting:crafting") then
      return
   end

   if fields.quit then
      clear_craft_slots(player)
      return
   end

   local name = player:get_player_name()

   if not userdata[name].row then
      return
   end

   if fields.craft_scroller then
      local evnt = minetest.explode_scrollbar_event(fields.craft_scroller)
      if evnt.type == "CHG" then
         userdata[name].scrollpos = evnt.value
         return
      end
   end

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
      if userdata[name] and userdata[name].mode == MODE_GUIDE then
          craftitems = crafting.get_crafts(nil, name)
      else
          craftitems = crafting.get_crafts(inv, name)
      end
      local old_craft_id = nil
      if userdata[name] then
	  old_craft_id = craftitems[userdata[name].row]
      end

      local wanted_id = craftitems[userdata[name].row]
      if not wanted_id then
         return
      end
      local wanted_itemstack = crafting.registered_crafts[wanted_id].output
      local output_itemstack
      local count = 1

      if do_craft_1 then
         count = 1
      elseif do_craft_10 then
         count = 10
      else
         return
      end

      -- Do the craft
      local has_crafted = false
      repeat
         -- Repeat the craft count times or until materials or space run out
         output_itemstack = ItemStack("")
         local crafted = crafting.craft(player, wanted_itemstack, 1,
                                         output_itemstack, inv:get_list("craft_in"), wanted_id)
         if crafted then
            if inv:room_for_item("main", crafted.output) then
               -- Move result directly into the player inventory
               inv:add_item("main", crafted.output)

               local new_list = {}
               for i=1, #crafted.items do
                   new_list[i] = ItemStack(crafted.items[i])
               end
               inv:set_list("craft_in", new_list)
               has_crafted = true
            end
         else
            break
         end
         count = count - 1
      until count < 1
      if has_crafted then
         crafting.update_crafting_formspec(player, old_craft_id)
      end

   elseif fields.craft_list then
      local selection = minetest.explode_table_event(fields.craft_list)

      if selection.type == "CHG" then
         userdata[name].row = selection.row
      elseif selection.type == "INV" then
         userdata[name].row = nil
      end
   elseif fields.toggle_filter then
      local craftitems
      if userdata[name] and userdata[name].mode == MODE_GUIDE then
          craftitems = crafting.get_crafts(nil, name)
      else
          craftitems = crafting.get_crafts(inv, name)
      end
      if userdata[name] and userdata[name].row then
          local craft_id = craftitems[userdata[name].row]
          userdata[name].old_craft_id = craft_id
      end

      if userdata[name].mode == MODE_GUIDE then
          userdata[name].mode = MODE_CRAFTABLE
      else
          userdata[name].mode = MODE_GUIDE
      end
   else
      for k,v in pairs(fields) do
         if string.sub(k, 1, 13) == "craft_select_" then
            local id = tonumber(string.sub(k, 14))
            if id then
               userdata[name].row = id
            end
            break
         end
     end
   end

   rp_formspec.refresh_invpage(player, "rp_crafting:crafting")
end

function crafting.update_crafting_formspec(player, craft_id)
   local name = player:get_player_name()
   if craft_id then
      userdata[name].old_craft_id = craft_id
   end
   rp_formspec.refresh_invpage(player, "rp_crafting:crafting")
end

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

   if userdata[name] == nil then
      userdata[name] = {row = 1, mode = MODE_CRAFTABLE}
   end

   if inv:get_size("craft_in") ~= 4 then
      inv:set_size("craft_in", 4)
   end

   clear_craft_slots(player)
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   userdata[name] = nil
end

if minetest.get_modpath("rp_drop_items_on_die") ~= nil then
   drop_items_on_die.register_listname("craft_in")
end

if minetest.settings:get_bool("rp_testing_enable", false) == true then
    -- Check if all input items of crafting recipes are known
    minetest.register_on_mods_loaded(function()
        for id, craftdef in pairs(crafting.registered_crafts) do
           for i=1, #craftdef.items do
              local iname = craftdef.items[i]:get_name()
	      if string.sub(iname, 1, 6) ~= "group:" and not minetest.registered_items[iname] then
                 minetest.log("error", "[rp_crafting] Unknown input item in craft '"..id.."': "..tostring(iname))
              end
	   end
        end
    end)
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_player_receive_fields(on_player_receive_fields)
