-- Based off MT's core builtin/game/statbars.lua, changed a lot

rp_hud = {}

rp_hud.registered_statbars = {}

-- time in seconds the breath bar will still show after going full again
local BREATH_KEEP_TIME = 2.05

local hud_ids = {} -- HUD IDs, per-player
local hidden_huds = {} -- List of hidden HUDs, per-player
local breath_timers = {} -- count the time each player has a full breath bar

-- Adds the statbar of the given type if it does not exist yet.
-- Returns ID if statbar was added, nil otherwise
local add_statbar_raw = function(player, statbarname, initial_value)
   local name = player:get_player_name()
   if hud_ids[name]["id_"..statbarname] then
      return
   else
      local hud_def = table.copy(rp_hud.registered_statbars[statbarname])
      if initial_value then
         hud_def.number = initial_value
      end
      local id = player:hud_add(hud_def)
      hud_ids[name]["id_"..statbarname] = id
      return id
   end
end

-- Removes the statbar of the given type if it does exist.
-- Returns true if statbar was actually removed.
local remove_statbar_raw = function(player, statbarname)
   local name = player:get_player_name()
   if not hud_ids[name]["id_"..statbarname] then
      return false
   else
      player:hud_remove(hud_ids[name]["id_"..statbarname])
      hud_ids[name]["id_"..statbarname] = nil
      return true
   end
end

local function initialize_hotbar(player)
   player:hud_set_hotbar_selected_image("ui_hotbar_selected.png")
   player:hud_set_hotbar_image("ui_hotbar_bg.png")
end

local function initialize_builtin_statbars(player)
   if not player:is_player() then
      return
   end

   local name = player:get_player_name()

   if name == "" then
      return
   end

   if hidden_huds[name] == nil then
      hidden_huds[name] = {
         healthbar = false,
         breathbar = false,
      }
   end

   if hud_ids[name] == nil then
      hud_ids[name] = {}
      -- flags are not transmitted to client on connect, we need to make sure
      -- our current flags are transmitted by sending them actively
      local flg=player:hud_get_flags()
      flg["healthbar"]=false
      flg["breathbar"]=false

      player:hud_set_flags(flg)
   end
   if breath_timers[name] == nil then
      -- Initial breath time is initialized to use a time so a full breath bar
      -- initially does NOT show up.
      breath_timers[name] = BREATH_KEEP_TIME + 1
   end

   -- Health bar
   if not hidden_huds[name].healthbar and minetest.settings:get_bool("enable_damage", true) then
      add_statbar_raw(player, "healthbar", player:get_hp())
   else
      remove_statbar_raw(player, "healthbar")
   end

   -- Breath bar
   -- This bar will automatically hide when its full.
   -- But a full bar stay shown for short delay (BREATH_KEEP_TIME)
   -- after it has become full again instead of instantly disappearing.
   if (not hidden_huds[name].breathbar) and ((player:get_breath() < minetest.PLAYER_MAX_BREATH_DEFAULT) or (breath_timers[name] <= BREATH_KEEP_TIME)) then
      if minetest.settings:get_bool("enable_damage", true) then
         local id = add_statbar_raw(player, "breathbar", player:get_breath()*2)
         if id ~= nil then
            breath_timers[name] = 0
         end
      else
         remove_statbar_raw(player, "breathbar")
      end
   elseif hud_ids[name].id_breathbar ~= nil then
      remove_statbar_raw(player, "breathbar")
   end
end



local function cleanup_builtin_statbars(player)
   if not player:is_player() then
      return
   end

   local name = player:get_player_name()

   if name == "" then
      return
   end

   hud_ids[name] = nil
   breath_timers[name] = nil
end

local function player_event_handler(player, eventname)
   assert(player:is_player())

   local name = player:get_player_name()

   if name == "" then
      return
   end

   if eventname == "health_changed" then
      initialize_builtin_statbars(player)

      if hud_ids[name].id_healthbar ~= nil then
	 player:hud_change(hud_ids[name].id_healthbar,"number",player:get_hp())
	 return true
      end
   end

   if eventname == "breath_changed" then
      initialize_builtin_statbars(player)

      if hud_ids[name].id_breathbar ~= nil then
	 player:hud_change(hud_ids[name].id_breathbar,"number",player:get_breath()*2)
	 return true
      end
   end

   if eventname == "hud_changed" then
      initialize_builtin_statbars(player)
      return true
   end

   return false
end

minetest.register_on_joinplayer(initialize_builtin_statbars)
minetest.register_on_joinplayer(initialize_hotbar)
minetest.register_on_leaveplayer(cleanup_builtin_statbars)
minetest.register_playerevent(player_event_handler)

-- Increase or reset player breath timers.
-- Time increases when player has full breath, time resets to 0
-- otherwise. This is used to make sure the breath bar will
-- keep showing for a few seconds after going full breath again
minetest.register_globalstep(function(dtime)
   local players = minetest.get_connected_players()
   for p=1, #players do
      local player = players[p]
      local name = player:get_player_name()
      if not hidden_huds[name].breathbar then
         if not breath_timers[name] then
            breath_timers[name] = BREATH_KEEP_TIME + 1
         end
         if player:get_breath() >= minetest.PLAYER_MAX_BREATH_DEFAULT then
            breath_timers[name] = breath_timers[name] + dtime
            if breath_timers[name] > BREATH_KEEP_TIME then
               remove_statbar_raw(player, "breathbar")
            end
         else
            breath_timers[name] = 0
         end
      end
   end
end)


--[[ Public functions ]]

-- Hide a HUD element from view for player.
-- hud_name is either "breathbar" or "healthbar".
rp_hud.hide_hud = function(player, hud_name)
   if not rp_huds.registered_statbars[hud_name] then
      minetest.log("error", "[rp_hud] rp_hud.hide_hud called with unknown hud_name: "..tostring(hud_name))
      return
   end
   local name = player:get_player_name()
   local ids = hud_ids[name]
   if not ids then
      return
   end
   remove_statbar_raw(player, hud_name)
   hidden_huds[name][hud_name] = true
   initialize_builtin_statbars(player)
end

-- Un-hide a HUD element from view for player.
-- hud_name is one of the registered statbars names.
rp_hud.unhide_hud = function(player, hud_name)
   if not rp_huds.registered_statbars[hud_name] then
      minetest.log("error", "[rp_hud] rp_hud.unhide_hud called with unknown hud_name: "..tostring(hud_name))
      return
   end
   local name = player:get_player_name()
   local ids = hud_ids[name]
   if not ids then
      return
   end
   hidden_huds[name][hud_name] = false
   initialize_builtin_statbars(player)
end

-- Registers a statbar.
-- * name: Identifier
-- * def: Table with these fields:
--    * image: Statbar icon
--    * image_gone: Statbar icon when empty/gone
--    * max_value: Maximum possible statbar value (number of "half-images")
--    * init_value: Initial value (defaults to max_value)
--    * direction: Statbar direction (see lua_api.md) (default: 0)
--    * offset: Statbar offset (see lua_api.md)
--    * z_index: Statbar Z-index (see lua_api.md)
rp_hud.register_statbar = function(name, def)
   local statbar_definition = {
      hud_elem_type = "statbar",
      position = { x=0.5, y=1 },
      text = def.image,
      text2 = def.image_gone,
      number = def.max_value or def.init_value,
      item = def.max_value,
      direction = def.direction or 0,
      size = { x=24, y=24 },
      offset = def.offset,
      z_index = def.z_index or 1,
   }
   rp_hud.registered_statbars[name] = statbar_definition
end

rp_hud.change_statbar = function(player, statbarname, value)
   local name = player:get_player_name()
   local id = hud_ids[name]["id_"..statbarname]
   if not id then
      return
   end
   player:hud_change(id, "number", value)
end

rp_hud.register_statbar("healthbar", {
   image = "heart.png",
   image_gone = "heart_gone.png",
   max_value = minetest.PLAYER_MAX_HP_DEFAULT,
   offset = { x=-256, y=-96},
})

rp_hud.register_statbar("breathbar", {
   image = "bubble.png",
   image_gone = "bubble_gone.png",
   max_value = minetest.PLAYER_MAX_BREATH_DEFAULT*2,
   offset = {x=16,y=-120},
})


