--
-- Achivements mod
-- By Kaadmy, for Pixture
--

local COLOR_GOTTEN = "#00FF00"

local S = minetest.get_translator("rp_achievements")

achievements = {}

achievements.achievements = {}
achievements.registered_achievements = {}
achievements.registered_achievements_list = {}

local achievements_file = minetest.get_worldpath() .. "/achievements.dat"
local saving = false

local function save_achievements()
   local f = io.open(achievements_file, "w")

   f:write(minetest.serialize(achievements.achievements))

   io.close(f)

   saving = false
end

local function delayed_save()
   if not saving then
      saving = true

      minetest.after(40, save_achievements)
   end
end

local function load_achievements()
   local f = io.open(achievements_file, "r")

   if f then
      achievements.achievements = minetest.deserialize(f:read("*all"))

      io.close(f)
   else
      save_achievements()
   end
end

-- Returns true if itemstring exists or is a "group:" argument,
-- for the error checks below. Also returns true if argument is
-- nil for simplifying the testing code.
local function check_item(itemstring)

   if itemstring == nil then
      return true
   end
   if string.sub(itemstring, 1, 6) == "group:" then
      return true
   end
   local def_ok = minetest.registered_items[itemstring] ~= nil
   if def_ok then
      return true
   else
      local alias = minetest.registered_aliases[itemstring]
      if alias and minetest.registered_items[alias] then
         return true
      end
   end
end

-- Check all item names in the achievement definitions for validity,
-- to make sure we don't accidentally break things.
local verify_achievements = function()
   for name,def in pairs(achievements.registered_achievements) do
      if not check_item(def.dignode) then
         error("[rp_achievements] Invalid dignode in achievement definition for "..name)
         return
      elseif not check_item(def.placenode) then
         error("[rp_achievements] Invalid placenode in achievement definition for "..name)
         return
      elseif not check_item(def.craftitem) then
         error("[rp_achievements] Invalid craftitem in achievement definition for "..name)
         return
      elseif not check_item(def.item_icon) then
         error("[rp_achievements] Invalid item_icon in achievement definition for "..name)
         return
      end
   end
end

function achievements.register_achievement(name, def)

   local rd = {
      title = def.title or name, -- good-looking name of the achievement
      description = def.description or "The " .. name .. " achievement", -- description of what the achievement is, and how to get it
      times = def.times or 1, -- how many times to trigger before getting the achievement
      dignode = def.dignode or nil, -- digging this node also triggers the achievement
      placenode = def.placenode or nil, -- placing this node also triggers the achievement
      craftitem = def.craftitem or nil, -- crafting this item also triggers the achievement
      icon = def.icon or nil, -- optional icon for achievement (texture)
      item_icon = def.item_icon or nil, -- optional icon for achievement (itemstring)
   }

   achievements.registered_achievements[name] = def

   table.insert(achievements.registered_achievements_list, name)
end

function achievements.trigger_achievement(player, aname, times)
   local name = player:get_player_name()

   times = times or 1

   if achievements.achievements[name][aname] == nil then
      achievements.achievements[name][aname] = 0
   end

   if achievements.achievements[name][aname] == -1 then
      return
   end

   achievements.achievements[name][aname] = achievements.achievements[name][aname] + times

   if not achievements.registered_achievements[aname] then
      minetest.log("error", "[rp_achievements] Cannot find registered achievement " .. aname)
      return
   end

   if achievements.achievements[name][aname]
   >= achievements.registered_achievements[aname].times then
      achievements.achievements[name][aname] = -1
      minetest.after(
         2.0,
         function(name, aname)
            minetest.chat_send_all(
               minetest.colorize(
                  "#0f0",
                  "*** " .. S("@1 has earned the achievement “@2”.",
                     name,
                     achievements.registered_achievements[aname].title)))

	    minetest.log("action", "[rp_achievements] " .. name .. " got achievement '"..aname.."'")
      end, name, aname)
   end

   if rp_formspec.current_page[name] == "rp_achievements:achievements" then
      local form = achievements.get_formspec(name)
      player:set_inventory_formspec(form)
   end

   delayed_save()
end

-- Load achievements table

local function on_load()
   load_achievements()
   verify_achievements()
end

-- Save achievements table

local function on_shutdown()
   save_achievements()
end

-- Joining player

local function on_joinplayer(player)
   local name = player:get_player_name()

   if not achievements.achievements[name] then
      achievements.achievements[name] = {}
   end
end

-- Interaction callbacks

local function on_craft(itemstack, player)
   if not player or not player:is_player() then
      return
   end
   for aname, def in pairs(achievements.registered_achievements) do
      if def.craftitem ~= nil then
	 if def.craftitem == itemstack:get_name() then
	    achievements.trigger_achievement(player, aname)
	 else
	    local group = string.match(def.craftitem, "group:(.*)")

	    if group and minetest.get_item_group(itemstack:get_name(), group) ~= 0 then
	       achievements.trigger_achievement(player, aname)
	    end
	 end
      end
   end
end

local function on_dig(pos, oldnode, player)
   if not player or not player:is_player() then
      return
   end
   for aname, def in pairs(achievements.registered_achievements) do
      if def.dignode ~= nil then

	 if def.dignode == oldnode.name then
	    achievements.trigger_achievement(player, aname)
	 else
	    local group = string.match(def.dignode, "group:(.*)")

	    if group and minetest.get_item_group(oldnode.name, group) ~= 0 then
	       achievements.trigger_achievement(player, aname)
	    end
	 end
      end
   end
end

local function on_place(pos, newnode, player, oldnode, itemstack, pointed_thing)
   if not player or not player:is_player() then
      return
   end
   for aname, def in pairs(achievements.registered_achievements) do
      if def.placenode ~= nil then
	 if def.placenode == newnode.name then
	    achievements.trigger_achievement(player, aname)
	 else
	    local group = string.match(def.placenode, "group:(.*)")

	    if group and minetest.get_item_group(newnode.name, group) ~= 0 then
	       achievements.trigger_achievement(player, aname)
	    end
	 end
      end
   end
end

-- Add callback functions

minetest.register_on_mods_loaded(on_load)

minetest.register_on_shutdown(on_shutdown)

minetest.register_on_joinplayer(on_joinplayer)

minetest.register_on_dignode(on_dig)
minetest.register_on_placenode(on_place)

crafting.register_on_craft(on_craft)

-- Formspecs

local form = rp_formspec.get_page("rp_default:default")

-- column 1: status image (0=gotten, 1=partial, 2=missing)
-- column 2: achievement name
-- column 3: achievement description
form = form .. "tablecolumns[color;image,align=left,width=1,0=ui_checkmark.png^[colorize:"..COLOR_GOTTEN..":255,1=blank.png,2=blank.png;text,align=left,width=11;"
   .. "text,align=left,width=28]"

rp_formspec.register_page("rp_achievements:achievements", form)

function achievements.get_formspec(name, row)
   row = row or 1

   if not achievements.achievements[name] then
      achievements.achievements[name] = {}
   end

   local achievement_list = ""

   local amt_gotten = 0
   local amt_progress = 0

   for _, aname in ipairs(achievements.registered_achievements_list) do
      local def = achievements.registered_achievements[aname]

      local progress = ""
      local color = ""
      if achievements.achievements[name][aname] then
	 if achievements.achievements[name][aname] == -1 then
	    progress = "0"
            color = COLOR_GOTTEN
	    amt_gotten = amt_gotten + 1
	 else
	    progress = "1"
	    amt_progress = amt_progress + 1
	 end
      else
	 progress = "2"
      end

      if achievement_list ~= "" then
	 achievement_list = achievement_list .. ","
      end

      achievement_list = achievement_list .. color .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(progress) .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(def.title) .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(def.description)
   end

   local form = rp_formspec.get_page("rp_achievements:achievements")

   form = form .. "set_focus[achievement_list]"
   form = form .. "table[0.25,2.5;7.9,5.5;achievement_list;" .. achievement_list
      .. ";" .. row .. "]"

   local aname = achievements.registered_achievements_list[row]
   local def = achievements.registered_achievements[aname]

   local progress = ""
   local title = def.title
   local description = def.description
   local gotten = false
   if achievements.achievements[name][aname] then
      if achievements.achievements[name][aname] == -1 then
	 gotten = true
	 progress = minetest.colorize(COLOR_GOTTEN, S("Gotten"))
         title = minetest.colorize(COLOR_GOTTEN, title)
         description = minetest.colorize(COLOR_GOTTEN, description)
      else
	 progress = S("@1/@2", achievements.achievements[name][aname], def.times)
      end
   else
      progress = S("Missing")
   end

   local progress_total =
      S("@1 of @2 achievements gotten, @3 in progress",
      amt_gotten,
      #achievements.registered_achievements_list,
      amt_progress)
   if amt_gotten == #achievements.registered_achievements_list then
      progress_total = minetest.colorize(COLOR_GOTTEN, progress_total)
   end
   form = form .. "label[0.25,8.15;"
      .. minetest.formspec_escape(progress_total)
      .. "]"

   form = form .. "label[0.25,0.25;" .. minetest.formspec_escape(title) .. "]"
   form = form .. "label[7.25,0.25;" .. minetest.formspec_escape(progress) .. "]"

   -- TODO: Revert this back to a label
   -- Currently a textarea as a workaround for a bug in Minetest that makes labels too short when translated.
   form = form .. "textarea[2.5,0.75;5.75,2;;;" .. minetest.formspec_escape(description) .. "]"

   local icon, item_icon
   if not gotten then
      icon = "rp_achievements_icon_missing.png"
   else
      icon = def.icon
      item_icon = def.item_icon
   end
   if not icon and not item_icon then
      if def.craftitem then
         item_icon = def.craftitem
      elseif def.dignode then
         item_icon = def.dignode
      elseif def.placenode then
         item_icon = def.placenode
      end
      if item_icon and string.sub(item_icon, 1, 6) == "group:" then
         item_icon = nil
      end
   end
   if not icon and not item_icon then
      -- Fallback icon
      icon = "rp_achievements_icon_default.png"
   end

   if icon then
      form = form .. "image[0.25,0.75;1.8,1.8;" .. minetest.formspec_escape(icon) .. "]"
   elseif item_icon then
      form = form .. "item_image[0.25,0.75;1.8,1.8;" .. minetest.formspec_escape(item_icon) .. "]"
   end

   return form
end

local function receive_fields(player, form_name, fields)
   local name = player:get_player_name()

   local in_achievements_menu = false
   if form_name == "rp_achievements:achievements" then
      in_achievements_menu = true
   elseif form_name ~= "" then
      return
   end
   if fields.quit then
      return
   end

   local selected = 1

   if fields.tab_achievements then
      in_achievements_menu = true
   end
   if fields.achievement_list then
      in_achievements_menu = true
      local selection = minetest.explode_table_event(fields.achievement_list)

      if selection.type == "CHG" or selection.type == "DCL" then
	 selected = selection.row
      end

   end
   if in_achievements_menu then
      local form = achievements.get_formspec(name, selected)
      minetest.show_formspec(
         name,
         "rp_achievements:achievements",
         form
      )
      player:set_inventory_formspec(form)
   end
end

minetest.register_on_player_receive_fields(receive_fields)
