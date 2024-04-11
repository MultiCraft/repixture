--
-- Achievements mod
--

local COLOR_GOTTEN = "#00FF00"

local COLOR_GOTTEN_MSG = "#00FF00"
local COLOR_REVERT_MSG = "#FFFF00"
local COLOR_GOTTEN_HUD = 0x00FF00
local COLOR_REVERT_HUD = 0xFFFF00

local MSG_PRE = "*** "
local BULLET_PRE = "• "
local HUD_TIMER = 5.0

local S = minetest.get_translator("rp_achievements")
local NS = function(s) return s end

achievements = {}
achievements.ACHIEVEMENT_GOTTEN = 1
achievements.ACHIEVEMENT_IN_PROGRESS = 2
achievements.ACHIEVEMENT_NOT_GOTTEN = 3

achievements.registered_achievements = {}
achievements.registered_achievements_list = {}

local huds = {} -- HUD IDs, per-player

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

-- Spawn an achievement popup message. The popup has an icon, caption and message.
-- Any popup that is currently shown will be instantly replaced.
-- * player_name: Show to this player
-- * icon_type: Type of icon. One of "image" or "item_image"
-- * icon: If icon_type is "image", specify the icon by its texture name here.
--   If icon_type is "item_image", specify the itemname here.
-- * caption: Caption text (keep it short)
-- * message: Message text (keep it short)
-- * caption_color: RGB color code for caption, as 3-byte number (default: 0xFFFFFF)
-- * message_color: RGB color code for message, as 3-byte number (default: 0xFFFFFF)
local achievement_popup = function(player_name, icon_type, icon, caption, message, caption_color, message_color)
   local player = minetest.get_player_by_name(player_name)
   if not player then
      return
   end
   if huds[player_name] then
      player:hud_remove(huds[player_name].bg)
      player:hud_remove(huds[player_name].caption)
      player:hud_remove(huds[player_name].message)
      player:hud_remove(huds[player_name].icon)
   end
   local hud_bg = player:hud_add({
      hud_elem_type = "image",
      text = "rp_achievements_hud_bg.png",
      position = { x = 0.5, y = 0 },
      alignment = { x = 0, y = 1 },
      offset = { x = 0, y = 10 },
      scale = { x = 4, y = 4 },
      z_index = 100,
   })
   local hud_icon
   if icon_type == "image" then
      hud_icon = player:hud_add({
         hud_elem_type = "image",
         text = "("..icon..")^[resize:32x32",
         position = { x = 0.5, y = 0 },
         alignment = { x = 1, y = 1 },
         offset = { x = -240, y = 24 },
         scale = { x = 1.9, y = 1.9 },
         z_index = 101,
      })
   elseif icon_type == "item_image" then
      -- TODO: Actually support item image
      hud_icon = player:hud_add({
         hud_elem_type = "image",
         text = "rp_achievements_icon_default.png",
         position = { x = 0.5, y = 0 },
         alignment = { x = 1, y = 1 },
         offset = { x = -240, y = 24 },
         scale = { x = 3.8, y = 3.8 },
         z_index = 101,
      })
   else
      minetest.log("error", "[rp_achievements] achievement_popup called with invalid icon_type!")
      return
   end
   local hud_caption = player:hud_add({
      hud_elem_type = "text",
      number = caption_color or 0xFFFFFF,
      text = caption,
      position = { x = 0.5, y = 0 },
      alignment = { x = 1, y = 1 },
      offset = { x = -160, y = 24 },
      size = { x = 1, y = 1 },
      scale = { x = 1, y = 1 },
      z_index = 102,
      style = 1,
   })
   local hud_message = player:hud_add({
      hud_elem_type = "text",
      number = message_color or 0xFFFFFF,
      text = message,
      position = { x = 0.5, y = 0 },
      alignment = { x = 1, y = 1 },
      offset = { x = -160, y = 52 },
      size = { x = 1, y = 1 },
      scale = { x = 1, y = 1 },
      z_index = 102,
   })
   huds[player_name] = {
      message = hud_message,
      caption = hud_caption,
      icon = hud_icon,
      bg = hud_bg,
      timer = 0
   }
end

-- Remove achievement HUD elements after some time
minetest.register_globalstep(function(dtime)
   for name, hud_ids in pairs(huds) do
      local player = minetest.get_player_by_name(name)
      if player and player:is_player() then
         if huds[name] and huds[name].timer then
            huds[name].timer = huds[name].timer + dtime
            if huds[name].timer > HUD_TIMER then
               player:hud_remove(huds[name].caption)
               player:hud_remove(huds[name].message)
               player:hud_remove(huds[name].icon)
               player:hud_remove(huds[name].bg)
               huds[name] = nil
            end
         end
      else
         huds[name] = nil
      end
   end
end)

local achievement_message = function(name, aname, color, msg_private, msg_all)
   local notify_all = minetest.settings:get_bool("rp_achievements_notify_all", false)
   local str
   if notify_all and (not minetest.is_singleplayer()) then
      -- Notify all players but the given player
      local players = minetest.get_connected_players()
      for p=1, #players do
         local pname = players[p]:get_player_name()
         if pname ~= name then
            if aname then
               str = MSG_PRE .. S(msg_all, name, achievements.registered_achievements[aname].title)
            else
               str = MSG_PRE .. S(msg_all, name)
            end
            minetest.chat_send_player(pname, minetest.colorize(color, str))
         end
      end
   end
   -- Notify the given player
   if aname then
      str = MSG_PRE .. S(msg_private, achievements.registered_achievements[aname].title)
   else
      str = MSG_PRE .. S(msg_private)
   end
   minetest.chat_send_player(name, minetest.colorize(color, str))
end

local achievement_gotten_message = function(name, aname)
   achievement_message(name, aname, COLOR_GOTTEN_MSG,
      NS("You have earned the achievement “@1”."),
      NS("@1 has earned the achievement “@2”."))

   local adef = achievements.registered_achievements[aname]
   local title = adef.title
   local icon_type, icon
   if adef.icon then
      icon_type = "image"
      icon = adef.icon
   elseif adef.item_icon then
      icon_type = "item_image"
      icon = adef.item_icon
   else
      icon_type = "image"
      icon = "rp_achievements_icon_default.png"
   end
   achievement_popup(name, icon_type, icon, S("Achievement gotten!"), title, COLOR_GOTTEN_HUD)
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
      difficulty = def.difficulty or nil, -- optional difficulty rating for sorting (0..11, floating-point)
   }

   achievements.registered_achievements[name] = rd
   table.insert(achievements.registered_achievements_list, name)

   local sort_by_difficulty = function(aname1, aname2)
	   local def1 = achievements.registered_achievements[aname1]
	   local def2 = achievements.registered_achievements[aname2]
	   -- compare difficulty
	   local diff1 = def1.difficulty or 100 -- assume arbitrary high value if nil; achievements w/ undefined difficulty will thus show up last
	   local diff2 = def2.difficulty or 100
	   return diff1 < diff2
   end
   table.sort(achievements.registered_achievements_list, sort_by_difficulty)
end

function achievements.register_subcondition_alias(aname, old_subcondition_name, new_subcondition_name)
   local achv = achievements.registered_achievements[aname]
   if not achv then
      return
   end
   if not achv.subcondition_aliases then
      achv.subcondition_aliases = {}
   end
   achv.subcondition_aliases[old_subcondition_name] = new_subcondition_name
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

--[[ Returns progress of achievement for player
* player: Player to look for
* aname: Achievement identifier
* def: Achievement definition
* states: Achievement states table, returned by get_achievement_states

Returns: part, total
   where:
   * part: Current progress of this achievement (number)
   * total: Required goal number of this achievement
]]
local get_progress = function(player, aname, def, states)
   local part, total
   if def.subconditions then
      local completed = get_completed_subconditions(player, aname)
      part = #completed
      total = #def.subconditions
   else
      part = states[aname]
      total = def.times
   end
   return part, total
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
      achievement_gotten_message(name, aname)
      minetest.log("action", "[rp_achievements] " .. name .. " got achievement '"..aname.."'")
   end

   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")
end

-- Give all achievements to player with 100% progress
-- (with notification)
local function give_all_achievements(player)
   local playername = player:get_player_name()
   local states = get_achievement_states(player)
   local subconds = get_achievement_subconditions(player)
   local alist = achievements.registered_achievements_list
   for a=1, #alist do
      local aname = alist[a]
      states[aname] = -1
      local reg_subconds = achievements.registered_achievements[aname].subconditions
      if reg_subconds then
         if not subconds[aname] then
            subconds[aname] = {}
         end
         for s=1, #reg_subconds do
            subconds[aname][reg_subconds[s]] = true
         end
      end
   end
   set_achievement_states(player, states)
   set_achievement_subconditions(player, subconds)
   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")

   achievement_message(playername, nil, COLOR_GOTTEN_MSG,
      NS("You have gotten all achievements!"),
      NS("@1 has gotten all achievements!"))
   achievement_popup(playername, "image", "rp_achievements_icon_default.png", S("All achievements gotten!"), "", COLOR_GOTTEN_HUD)
   minetest.log("action", "[rp_achievements] " .. playername .. " got all achievements")
end

-- Remove all achievements from player, including achievement progress
-- (with notification)
local function remove_all_achievements(player)
   local playername = player:get_player_name()
   set_achievement_states(player, {})
   set_achievement_subconditions(player, {})
   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")

   achievement_message(playername, nil, COLOR_REVERT_MSG,
      NS("You have lost all achievements!"),
      NS("@1 has lost all achievements!"))
   achievement_popup(playername, "image", "rp_achievements_icon_removed.png", S("All achievements lost!"), "", COLOR_REVERT_HUD)
   minetest.log("action", "[rp_achievements] " .. playername .. " lost all achievements")
end

-- Give an achievement `aname` to player and mark it as 100% complete
-- (with notification)
local function give_achievement(player, aname)
   local states = get_achievement_states(player)
   local subconds = get_achievement_subconditions(player)
   if states[aname] == -1 then
      -- No-op if we already have the achievement
      return
   end
   states[aname] = -1
   local reg_subconds = achievements.registered_achievements[aname].subconditions
   if reg_subconds then
      for s=1, #reg_subconds do
         if not subconds[aname] then
            subconds[aname] = {}
         end
         subconds[aname][reg_subconds[s]] = true
      end
   end
   set_achievement_states(player, states)
   set_achievement_subconditions(player, subconds)
   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")

   local playername = player:get_player_name()
   achievement_gotten_message(playername, aname)
   minetest.log("action", "[rp_achievements] " .. playername .. " got achievement '"..aname.."'")
end

-- Remove an achievement `aname` from player and erase all its progress
-- (with notification)
local function remove_achievement(player, aname)
   local states = get_achievement_states(player)
   local subconds = get_achievement_subconditions(player)

   if states[aname] == nil and subconds[aname] == nil then
      -- No-op if achievement had no progress so far
      return
   end
   states[aname] = nil
   subconds[aname] = nil
   set_achievement_states(player, states)
   set_achievement_subconditions(player, subconds)
   rp_formspec.refresh_invpage(player, "rp_achievements:achievements")

   local playername = player:get_player_name()
   achievement_message(playername, aname, COLOR_REVERT_MSG,
      NS("You have lost the achievement “@1”."),
      NS("@1 has lost the achievement “@2”."))
   local title = achievements.registered_achievements[aname]
   achievement_popup(playername, "image", "rp_achievements_icon_removed.png", S("Achievement lost!"), title, COLOR_REVERT_HUD)
   minetest.log("action", "[rp_achievements] " .. playername .. " lost achievement '"..aname.."'")
end

-- Iterate through all subconditions of the player's achievements
-- and move the subcondition completion status of aliased
-- subcondition names to the new subcondition name.
-- Required if an achievmement has subcondition aliases
-- and the player comes from a version with old subcondition
-- names.
local function update_aliased_subconditions(player)
   local subconds = get_achievement_subconditions(player)

   for aname, achv in pairs(achievements.registered_achievements) do
      if subconds[aname] and achv.subcondition_aliases then
         for old_name, new_name in pairs(achv.subcondition_aliases) do
            if subconds[aname][old_name] == true then
               minetest.log("action", "[rp_achievements] Updating aliased subcondition name for "..player:get_player_name()..": "..old_name.." -> "..new_name.." (aname="..aname..")")
               subconds[aname][new_name] = true
               subconds[aname][old_name] = nil
            end
         end
      end
   end
   set_achievement_subconditions(player, subconds)
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

   update_aliased_subconditions(player)
   -- Mark subcondition achievement that are marked as complete
   -- as incomplete again if it no longer meets all subconditions.
   -- This can happen if the player joins in a new version
   -- with updated achievements.
   local states = get_achievement_states(player)
   local changed = false
   local pname = player:get_player_name()
   for aname, def in pairs(achievements.registered_achievements) do
      if def.subconditions then
         local subconds_done = check_achievement_subconditions(player, aname)
         if states[aname] == -1 and not subconds_done then
            states[aname] = 0
	    changed = true
            -- Notify player about the new goals
            minetest.chat_send_player(pname,
               minetest.colorize(
               COLOR_REVERT_MSG,
               MSG_PRE .. S("The achievement “@1” has new goals.",
               achievements.registered_achievements[aname].title)))
            minetest.log("action", "[rp_achievements] " .. pname .. " lost the achievement '"..aname.."' on join because of new unfulfilled subconditions")
         elseif states[aname] ~= -1 and subconds_done then
            -- Also give an achievement in case subconditions have been reduced
            states[aname] = -1
            changed = true
            achievement_gotten_message(pname, aname)
            minetest.log("action", "[rp_achievements] " .. pname .. " got achievement '"..aname.."' on join because all subconditions are already met")
         end
      end
   end
   if changed then
      set_achievement_states(player, states)
   end
end

local function on_leaveplayer(player)
   local name = player:get_player_name()
   selected_row[name] = nil
   huds[name] = nil
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

-- column 1: status image (0=gotten, 1..8=partial, 9=missing)
-- column 2: achievement name
-- column 3: achievement description
local progress_icons = ""
-- Icons for achievement progress, shown in 1/8ths
-- (special case: ui_achievment_progress_0.png, for
-- progress lower than 1/8 but greater than 0)
for i=1,8 do
	progress_icons = progress_icons ..
		i.."=ui_achievement_progress_"..(i-1)..".png,"
end

-- Construct achievements table formspec element
form = form .. "tablecolumns[color;image,align=left,width=1,"..
        -- checkmark icon = achievement complete
	"0=ui_checkmark.png^[colorize:"..COLOR_GOTTEN..":255,"..
	-- progress icons (see above)
	progress_icons..
	-- no icon if achievement was not gotten
	"9=blank.png;"..
	"text,align=left,width=11;"
   .. "text,align=left,width=28]"

rp_formspec.register_page("rp_achievements:achievements", form)

rp_formspec.register_invtab("rp_achievements:achievements", {
   icon = "ui_icon_achievements.png",
   icon_active = "ui_icon_achievements_active.png",
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

      local progress_column = ""
      local color = ""
      local status = achievements.get_completion_status(player, aname)
      if status == achievements.ACHIEVEMENT_GOTTEN then
         progress_column = "0"
         color = COLOR_GOTTEN
	 amt_gotten = amt_gotten + 1
      elseif status == achievements.ACHIEVEMENT_IN_PROGRESS then
         local part, total = get_progress(player, aname, def, states)
         -- One of 8 icons to roughly show achievement progress
         local completion_ratio = math.max(0, math.min(7, math.floor((part / total) * 8)))
         progress_column = tostring(completion_ratio+1)
         amt_progress = amt_progress + 1
      else
         progress_column = "9"
      end

      if achievement_list ~= "" then
	 achievement_list = achievement_list .. ","
      end

      achievement_list = achievement_list .. color .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(progress_column) .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(def.title) .. ","
      achievement_list = achievement_list .. minetest.formspec_escape(def.description)
   end

   local form = rp_formspec.get_page("rp_achievements:achievements")

   form = form .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"
   form = form .. "table[0,2.8;9.75,6.4;achievement_list;" .. achievement_list
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
         local part, total = get_progress(player, aname, def, states)
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


   form = form .. "label[0,9.5;"
      .. minetest.formspec_escape(progress_total)
      .. "]"

   form = form .. "label[0,0.4;" .. minetest.formspec_escape(title) .. "]"
   form = form .. "label[8.5,0.4;" .. minetest.formspec_escape(progress) .. "]"

   form = form .. "textarea[3,0.6;5.25,2;;;" .. minetest.formspec_escape(description) .. "]"

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
      form = form .. "image[0,0.75;1.8,1.8;" .. minetest.formspec_escape(icon) .. "]"
   elseif item_icon then
      form = form .. "item_image[0,0.75;1.8,1.8;" .. minetest.formspec_escape(item_icon) .. "]"
   end
   form = form .. "container_end[]"

   return form
end

rp_formspec.register_invpage("rp_achievements:achievements", {
   get_formspec = achievements.get_formspec,
})

function achievements.get_completion_status(player, aname)
   local def = achievements.registered_achievements[aname]
   local states = get_achievement_states(player)
   if states[aname] then
      if states[aname] == -1 then
         return achievements.ACHIEVEMENT_GOTTEN
      else
         return achievements.ACHIEVEMENT_IN_PROGRESS
      end
   else
      return achievements.ACHIEVEMENT_NOT_GOTTEN
   end
end

local function receive_fields(player, form_name, fields)
   local invpage = rp_formspec.get_current_invpage(player)
   if not (form_name == "" and invpage == "rp_achievements:achievements") then
      return
   end

   local name = player:get_player_name()

   local selected = 1

   if fields.achievement_list then
      local selection = minetest.explode_table_event(fields.achievement_list)

      if selection.type == "CHG" or selection.type == "DCL" then
	 selected = selection.row
	 selected_row[name] = selected
      elseif selection.type == "INV" then
	 selected_row[name] = nil
      end
      rp_formspec.refresh_invpage(player, "rp_achievements:achievements")
   end
end

minetest.register_on_player_receive_fields(receive_fields)

-- Chat command to manipulate and review player achievements
minetest.register_chatcommand("achievement", {
   privs = {server=true},
   params = S("(list [<player>]) | ((give | remove) <player> (<achievement> | all))"),
   description = S("List, give or remove achievements of player"),
   func = function(name, param)
      if param == "" then
         return false
      end
      -- list: List all technical achievement names
      if param == "list" then
         local strs = {}
         for a=1, #achievements.registered_achievements_list do
            local aname = achievements.registered_achievements_list[a]
            local ach = achievements.registered_achievements[aname]
            local str = BULLET_PRE .. S("@1: @2 (@3)", aname, ach.title, ach.difficulty or S("unset"))
            table.insert(strs, str)
         end
         local output = table.concat(strs, "\n")
	 if output == "" then
            output = S("No achievements.")
	 else
            output = S("List of achievements (difficulty rating in brackets):") .."\n"..output
         end
         return true, output
      end

      -- list <player>: List all achievements of player (gotten or in progress)
      local playername = string.match(param, "list (%S+)")
      if playername then
         local player = minetest.get_player_by_name(playername)
         if not player then
            return false, S("Player is not online!")
         end
	 local strs = {}
         for _, aname in ipairs(achievements.registered_achievements_list) do
            local status = achievements.get_completion_status(player, aname)
            if status == achievements.ACHIEVEMENT_GOTTEN then
               local str = BULLET_PRE .. S("@1: Gotten", aname)
               table.insert(strs, str)
            elseif status == achievements.ACHIEVEMENT_IN_PROGRESS then
               local ach = achievements.registered_achievements[aname]
               local part, total = get_progress(player, aname, ach, get_achievement_states(player))
               local str = BULLET_PRE .. S("@1: In progress (@2/@3)", aname, part, total)
               table.insert(strs, str)
            end
         end
         local output = table.concat(strs, "\n")
         if output == "" then
            output = S("No achievements.")
         else
	    output = S("Achievements of @1:", playername).."\n"..output
         end
	 return true, output
      end

      -- Give or remove one or all achievements
      local give_or_remove = nil
      local playername, aname = string.match(param, "give (%S+) (%S+)")
      if playername and aname then
	 give_or_remove = "give"
      else
         playername, aname = string.match(param, "remove (%S+) (%S+)")
         if playername and aname then
	    give_or_remove = "remove"
         end
      end
      if give_or_remove then
         local player = minetest.get_player_by_name(playername)
         if not player then
            return false, S("Player is not online!")
         end
	 -- Give or remove all achievements
         if aname == "all" then
	    -- give <player> all: Give all achievements
            if give_or_remove == "give" then
               give_all_achievements(player)

	    -- remove <player> all: Remove all achievements
            else
               remove_all_achievements(player)
            end
            return true

	 -- Give or remove a single achievement
         else
            local ach = achievements.registered_achievements[aname]
            if not ach then
               return false, S("Unknown achievement! Use “/achievement list” to list valid achievement names.")
            end
	    -- give <player> <achievement>: Give a single achievement
            if give_or_remove == "give" then
               give_achievement(player, aname)

	    -- remove <player> <achievement>: Remove a single achievement
            else
               remove_achievement(player, aname)
            end
            rp_formspec.refresh_invpage(player, "rp_achievements:achievements")
            return true
         end
      end

      return false
   end,
})

