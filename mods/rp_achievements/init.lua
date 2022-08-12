--
-- Achievements mod
--

local COLOR_GOTTEN = "#00FF00"
local COLOR_GOTTEN_MSG = "#00FF00"
local COLOR_REVERT_MSG = "#FFFF00"
local MSG_PRE = "*** "

local S = minetest.get_translator("rp_achievements")

achievements = {}

achievements.registered_achievements = {}
achievements.registered_achievements_list = {}

local selected_row = {} -- current selected row, per-player

local legacy_achievements_file = minetest.get_worldpath() .. "/achievements.dat"

local legacy_achievements_states = {}

local function load_legacy_achievements()
   local f = io.open(legacy_achievements_file, "r")

   if f then
      legacy_achievements_states = minetest.deserialize(f:read("*all"))
      io.close(f)
   end
end

local function set_achievement_states(player, states)
    local meta = player:get_meta()
    meta:set_string("rp_achievements:achievement_states", minetest.serialize(states))
end
local function get_achievement_states(player)
    local meta = player:get_meta()
    local data = meta:get_string("rp_achievements:achievement_states")
    if data ~= "" then
       return minetest.deserialize(data)
    else
       return {}
    end
end
local function set_achievement_subconditions(player, subconditions)
    local meta = player:get_meta()
    meta:set_string("rp_achievements:achievement_subconditions", minetest.serialize(subconditions))
end
local function get_achievement_subconditions(player)
    local meta = player:get_meta()
    local data = meta:get_string("rp_achievements:achievement_subconditions")
    if data ~= "" then
       return minetest.deserialize(data)
    else
       return {}
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
      subconditions = def.subconditions or nil, -- list of subconditions required to get achievement (optional)
      subconditions_readable = def.subconditions_readable or nil, -- list of subcondition names to be shown in HUD (optional)
      dignode = def.dignode or nil, -- digging this node also triggers the achievement
      placenode = def.placenode or nil, -- placing this node also triggers the achievement
      craftitem = def.craftitem or nil, -- crafting this item also triggers the achievement
      icon = def.icon or nil, -- optional icon for achievement (texture)
      item_icon = def.item_icon or nil, -- optional icon for achievement (itemstring)
   }

   achievements.registered_achievements[name] = rd

   table.insert(achievements.registered_achievements_list, name)
end

local function get_completed_subconditions(player, aname)
   local reg_subconds = achievements.registered_achievements[aname].subconditions
   local reg_subconds_readable = achievements.registered_achievements[aname].subconditions_readable
   local completed_subconds = {}
   if reg_subconds then
      local player_subconds_all = get_achievement_subconditions(player)
      local player_subconds = player_subconds_all[aname]
      if not player_subconds then
         return completed_subconds
      end
      for s=1, #reg_subconds do
         local subcond = reg_subconds[s]
	 if player_subconds[subcond] == true then
            local subcond_read = subcond
	    if reg_subconds_readable and reg_subconds_readable[s] then
               subcond_read = reg_subconds_readable[s]
	    end
            table.insert(completed_subconds, subcond_read)
	 end
      end
   end
   return completed_subconds
end

local function check_achievement_subconditions(player, aname)
   local name = player:get_player_name()
   local reg_subconds = achievements.registered_achievements[aname].subconditions
   if reg_subconds then
      local player_subconds_all = get_achievement_subconditions(player)
      local player_subconds = player_subconds_all[aname]
      if not player_subconds then
         return false
      end
      -- Check if player has failed to meet any subcondition
      for s=1, #reg_subconds do
         local subcond = reg_subconds[s]
	 if player_subconds[subcond] ~= true then
            -- A subcondition failed! Failure!
            return false
	 end
      end
      -- All subconditions met! Success!
      return true
   else
      -- Achievement does not have subconditions: Success!
      return true
   end
end

local function check_achievement_gotten(player, aname)
   local name = player:get_player_name()

   local states = get_achievement_states(player)
   if states[aname]
         >= achievements.registered_achievements[aname].times and
	 check_achievement_subconditions(player, aname) then

      -- The state of -1 means the achievement has been completed
      states[aname] = -1
      set_achievement_states(player, states)
      minetest.after(
         2.0,
         function(name, aname)
            local notify_all = minetest.settings:get_bool("rp_achievements_notify_all", false)
            if notify_all and (not minetest.is_singleplayer()) then
               -- Notify all players
               minetest.chat_send_all(
                  minetest.colorize(
                     COLOR_GOTTEN_MSG,
                     MSG_PRE .. S("@1 has earned the achievement “@2”.",
                        name,
                        achievements.registered_achievements[aname].title)))
            else
               -- Only notify the player who got the achievement
               minetest.chat_send_player(name,
                  minetest.colorize(
                     COLOR_GOTTEN_MSG,
                     MSG_PRE .. S("You have earned the achievement “@1”.",
                        achievements.registered_achievements[aname].title)))
            end
      end, name, aname)
      minetest.log("action", "[rp_achievements] " .. name .. " got achievement '"..aname.."'")
   end

   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")
end

function achievements.trigger_subcondition(player, aname, subcondition)
   if not achievements.registered_achievements[aname] then
      minetest.log("error", "[rp_achievements] Cannot find registered achievement " .. aname)
      return
   end

   local states = get_achievement_states(player)
   local subconds = get_achievement_subconditions(player)
   if states[aname] == -1 then
      return
   end
   if states[aname] == nil then
      states[aname] = 0
      set_achievement_states(player, states)
   end
   if not subconds[aname] then
      subconds[aname] = {}
   end
   if subconds[aname][subcondition] == true then
      return
   end
   subconds[aname][subcondition] = true

   set_achievement_subconditions(player, subconds)

   check_achievement_gotten(player, aname)
end

function achievements.trigger_achievement(player, aname, times)
   if not achievements.registered_achievements[aname] then
      minetest.log("error", "[rp_achievements] Cannot find registered achievement " .. aname)
      return
   end

   times = times or 1

   local states = get_achievement_states(player)
   local subconds = get_achievement_subconditions(player)
   if states[aname] == -1 then
      return
   end
   if states[aname] == nil then
      states[aname] = 0
   end
   if not subconds[aname] then
      subconds[aname] = {}
   end
   states[aname] = states[aname] + times

   set_achievement_states(player, states)
   set_achievement_subconditions(player, subconds)

   check_achievement_gotten(player, aname)
end

-- Load achievements table

local function on_load()
   load_legacy_achievements()
   verify_achievements()
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

local function on_joinplayer(player)
   local meta = player:get_meta()
   -- Get version number of data format.
   -- Version 0: old file-based storage (achievements.dat)
   -- Version 1: Player metadata-based storage
   local v = meta:get_int("rp_achievements:version")
   if v == 0 then
      -- Load achievements from legacy file
      local name = player:get_player_name()
      local legacy_states = legacy_achievements_states[name]
      if legacy_states then
         set_achievement_states(player, legacy_states)
      end
      -- Upgrade version to 1, so the player achievements in
      -- file will be ignored on the next join.
      meta:set_int("rp_achievements:version", 1)
   end

   -- Mark subcondition achievement that are marked as complete
   -- as incomplete again if it no longer meets all subconditions.
   -- This can happen if the player joins in a new version
   -- with updated achievements.
   local states = get_achievement_states(player)
   local changed = false
   local pname = player:get_player_name()
   for aname, def in pairs(achievements.registered_achievements) do
      if def.subconditions and states[aname] == -1 and not check_achievement_subconditions(player, aname) then
         states[aname] = 0
	 changed = true
         -- Notify player about the new goals
         minetest.chat_send_player(pname,
            minetest.colorize(
            COLOR_REVERT_MSG,
            MSG_PRE .. S("The achievement “@1” has new goals.",
            achievements.registered_achievements[aname].title)))
      end
   end
   if changed then
      set_achievement_states(player, states)
   end
end

local function on_leaveplayer(player)
   local name = player:get_player_name()
   selected_row[name] = nil
end

-- Add callback functions

minetest.register_on_mods_loaded(on_load)

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

minetest.register_on_dignode(on_dig)
minetest.register_on_placenode(on_place)

crafting.register_on_craft(on_craft)

-- Formspecs

local form = rp_formspec.get_page("rp_formspec:default")

-- column 1: status image (0=gotten, 1=partial, 2=missing)
-- column 2: achievement name
-- column 3: achievement description
form = form .. "tablecolumns[color;image,align=left,width=1,0=ui_checkmark.png^[colorize:"..COLOR_GOTTEN..":255,1=blank.png,2=blank.png;text,align=left,width=11;"
   .. "text,align=left,width=28]"

rp_formspec.register_page("rp_achievements:achievements", form)

rp_formspec.register_invtab("rp_achievements:achievements", {
   icon = "ui_icon_achievements.png",
   tooltip = S("Achievements"),
})

function achievements.get_formspec(name)
   local row = 1

   local player = minetest.get_player_by_name(name)
   if not player then
      return
   end
   if selected_row[name] then
      row = selected_row[name]
   end
   local states = get_achievement_states(player)

   local achievement_list = ""

   local amt_gotten = 0
   local amt_progress = 0

   for _, aname in ipairs(achievements.registered_achievements_list) do
      local def = achievements.registered_achievements[aname]

      local progress = ""
      local color = ""
      if states[aname] then
	 if states[aname] == -1 then
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

   local form = rp_formspec.get_page("rp_achievements:achievements", true)

   form = form .. "set_focus[achievement_list]"
   form = form .. "table[0.25,2.5;7.9,5.5;achievement_list;" .. achievement_list
      .. ";" .. row .. "]"

   local aname = achievements.registered_achievements_list[row]
   local def = achievements.registered_achievements[aname]

   local progress = ""
   local title = def.title
   local description = def.description
   local gotten = false
   local achievement_times = states[aname]
   if achievement_times then
      if achievement_times == -1 then
	 gotten = true
	 progress = minetest.colorize(COLOR_GOTTEN, S("Gotten"))
         title = minetest.colorize(COLOR_GOTTEN, title)
         description = minetest.colorize(COLOR_GOTTEN, description)
      else
         local part, total
         if def.subconditions then
		 local completed = get_completed_subconditions(player, aname)
		 part = #completed
		 total = #def.subconditions
	 else
		 part = achievement_times
		 total = def.times
	 end
	 progress = S("@1/@2", part, total)
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
   if def.subconditions then
      local progress_subconds = get_completed_subconditions(player, aname)
      if #progress_subconds > 0 then
         local progress_subconds_str = table.concat(progress_subconds, S(", "))
         description = description .. "\n\n" .. S("Completed: @1", progress_subconds_str)
      end
   end


   form = form .. "label[0.25,8.15;"
      .. minetest.formspec_escape(progress_total)
      .. "]"

   form = form .. "label[0.25,0.25;" .. minetest.formspec_escape(title) .. "]"
   form = form .. "label[7.25,0.25;" .. minetest.formspec_escape(progress) .. "]"

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

rp_formspec.register_invpage("rp_achievements:achievements", {
   get_formspec = achievements.get_formspec,
})

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
	 selected_row[name] = selected
      elseif selection.type == "INV" then
	 selected_row[name] = nil
      end

   end
   if in_achievements_menu then
      rp_formspec.refresh_invpage(player, "rp_achievements:achievements")
   end
end

minetest.register_on_player_receive_fields(receive_fields)
