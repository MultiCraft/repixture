--
-- Player effects mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("player_effects")
local DISPLAY_ICONS = false

player_effects = {}

player_effects.effects = {}
player_effects.registered_effects = {}

local effects_file = minetest.get_worldpath() .. "/player_effects.dat"
local timer_interval = 1 -- update every second
local timer = 10

local function save_effects()
   local f = io.open(effects_file, "w")

   f:write(minetest.serialize(player_effects.effects))

   io.close(f)
end

local function load_effects()
   local f = io.open(effects_file, "r")

   if f then
      player_effects.effects = minetest.deserialize(f:read("*all"))

      io.close(f)
   else
      save_effects()
   end
end

local huds = {}

local function display_effect_icons(player)
   if not DISPLAY_ICONS then
      return
   end

   local name = player:get_player_name()
   for _,h in pairs(huds[name]) do
     player:hud_remove(h)
   end
   huds[name] = {}
   local i = 0
   for en, _ in pairs(player_effects.effects[name]) do
     local effect = player_effects.get_registered_effect(en)
     if effect.icon then
        local id = player:hud_add({
            hud_elem_type = "image",
            position = { x = 1, y = 0 },
            offset = { x = -52 - i*52, y = 270 },
            text = effect.icon,
            scale = { x = 3, y = 3 },
            size = { x = 16, y = 16 },
            alignment = { x = 1, y = 1 },
            z_index = 10,
        })
        table.insert(huds[name], id)
        i = i + 1
     end
   end
end

function player_effects.register_effect(name, def)
   local rd = {
      title = def.title or name, -- good-looking name of the effect
      description = def.description or S("The @1 effect", name), -- description of what the effect does
      duration = def.duration or 1, -- how long the effect lasts, <0 is infinite and has to be disabled manually
      physics = def.physics or {}, -- physics overrides for the player
      icon = def.icon, -- effect icon for HUD (optional)
      save = def.save, -- if true, effect will be preserved after server shutdown (default: true)
   }
   if rd.save == nil then
      rd.save = true
   end

   player_effects.registered_effects[name] = rd
end

function player_effects.get_registered_effect(ename)
   local e = player_effects.registered_effects[ename]

   if not e then
      default.log("[mod:player_effects] Cannot find registered player effect " .. ename, "error")

      return nil
   end

   return e
end

function player_effects.apply_effect(player, ename)
   local effect = player_effects.get_registered_effect(ename)

   if effect.duration >= 0 then
      player_effects.effects[player:get_player_name()][ename] = minetest.get_gametime() + effect.duration
   else
      player_effects.effects[player:get_player_name()][ename] = -1
   end

   local phys = {speed = 1, jump = 1, gravity = 1}

   for en, _ in pairs(player_effects.effects[player:get_player_name()]) do
      local effect = player_effects.get_registered_effect(en)

      if effect.physics.speed ~= nil then
	 phys.speed = phys.speed * effect.physics.speed
      end

      if effect.physics.jump ~= nil then
	 phys.jump = phys.jump * effect.physics.jump
      end

      if effect.physics.gravity ~= nil then
	 phys.gravity = phys.gravity * effect.physics.gravity
      end
   end

   player:set_physics_override(phys)
   display_effect_icons(player)

   save_effects()
end

function player_effects.remove_effect(player, ename)
   if player_effects.effects[player:get_player_name()][ename] == nil then return end

   local phys = {speed = 1, jump = 1, gravity = 1}

   for en, _ in pairs(player_effects.effects[player:get_player_name()]) do
      if en ~= ename then
	 local effect = player_effects.get_registered_effect(en)

	 if effect.physics.speed ~= nil then
	    phys.speed = phys.speed * effect.physics.speed
	 end

	 if effect.physics.jump ~= nil then
	    phys.jump = phys.jump * effect.physics.jump
	 end

	 if effect.physics.gravity ~= nil then
	    phys.gravity = phys.gravity * effect.physics.gravity
	 end
      end
   end

   player:set_physics_override(phys)

   player_effects.effects[player:get_player_name()][ename] = nil
   display_effect_icons(player)

   save_effects()
end

function player_effects.refresh_effects(player)
   local phys = {speed = 1, jump = 1, gravity = 1}

   local clear = {}
   local name = player:get_player_name()
   for en, _ in pairs(player_effects.effects[name]) do
      local effect = player_effects.get_registered_effect(en)
      if effect.save == false then
         table.insert(clear, en)
      else
         if effect.physics.speed ~= nil then
            phys.speed = phys.speed * effect.physics.speed
         end

         if effect.physics.jump ~= nil then
            phys.jump = phys.jump * effect.physics.jump
         end

         if effect.physics.gravity ~= nil then
            phys.gravity = phys.gravity * effect.physics.gravity
         end
      end
   end
   for e=1, #clear do
      player_effects.effects[name][clear[e]] = nil
   end

   player:set_physics_override(phys)

   display_effect_icons(player)

   save_effects()
end

function player_effects.clear_effects(player)
   -- call this if you want to clear all effects, it's faster and more efficient
   player:set_physics_override({speed = 1, jump = 1, gravity = 1})

   player_effects.effects[player:get_player_name()] = {}
   display_effect_icons(player)

   save_effects()
end

local function step(dtime)
   timer = timer + dtime

   if timer < timer_interval then
      return
   end

   timer = 0

   local gt = minetest.get_gametime()

   if player_effects.effects == nil then
      return
   end

   for _, player in pairs(minetest.get_connected_players()) do
      local name = player:get_player_name()

      for ename, endtime in pairs(player_effects.effects[name]) do
         if endtime > 0 then
            local timeleft = endtime - gt
            if timeleft <= 0 then
               player_effects.remove_effect(player, ename)
            end
         end
      end
   end
end

local function on_joinplayer(player)
   local name = player:get_player_name()

   load_effects()

   if player_effects.effects[name] == nil then
      player_effects.effects[name] = {}
   end
   huds[name] = {}

   player_effects.refresh_effects(player)

   save_effects()
end

local function on_leaveplayer(player)
   save_effects()
end

local function on_dieplayer(player)
   player_effects.clear_effects(player)
end

minetest.register_globalstep(step)
minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_dieplayer(on_dieplayer)

minetest.register_chatcommand(
   "player_effects",
   {
      description = S("Show your current player effects"),
      func = function(name, param)
         local s = S("Current player effects:").."\n"
         local ea = 0

         for ename, endtime in pairs(player_effects.effects[name]) do
            if endtime < 0 then
               s = s .. "  " .. S("@1: unlimited", player_effects.registered_effects[ename].title) .. "\n"
            else
               s = s .. "  " .. S("@1: @2 s remaining", player_effects.registered_effects[ename].title, (endtime - minetest.get_gametime())) .. "\n"
            end

            ea = ea + 1
         end

         if ea > 0 then
            return true, s
         else
            return true, S("You currently have no effects.")
         end
      end
})

default.log("mod:player_effects", "loaded")
