-- Based off MT's core builtin/game/statbars.lua, changed a lot to add statbar background and better layout

rp_hud={}

local health_bar_definition = {
   hud_elem_type = "statbar",
   position = { x=0.5, y=1 },
   text = "heart.png",
   text2 = "heart.png^[colorize:#666666:255",
   number = 20,
   item = 20,
   direction = 0,
   size = { x=24, y=24 },
   offset = { x=(-10*16)-64-32, y=-(48+24+24)},
   z_index = 1,
}

local breath_bar_definition = {
   hud_elem_type = "statbar",
   position = { x=0.5, y=1 },
   text = "bubble.png",
   text2 = "bubble.png^[colorize:#666666:255",
   number = 20,
   item = 20,
   dir = 0,
   size = { x=24, y=24 },
   offset = {x=16,y=-(48+24+24)-24},
   z_index = 1,
}

rp_hud.ids={}

function rp_hud.initialize_builtin_statbars(player)
   if not player:is_player() then
      return
   end

   local name = player:get_player_name()

   if name == "" then
      return
   end

   player:hud_set_hotbar_selected_image("ui_hotbar_selected.png")
   player:hud_set_hotbar_image("ui_hotbar_bg.png")

   if rp_hud.ids[name] == nil then
      rp_hud.ids[name] = {}
      -- flags are not transmitted to client on connect, we need to make sure
      -- our current flags are transmitted by sending them actively
      local flg=player:hud_get_flags()
      flg["healthbar"]=false
      flg["breathbar"]=false

      player:hud_set_flags(flg)
   end

   if minetest.is_yes(minetest.settings:get("enable_damage")) then
      if rp_hud.ids[name].id_healthbar == nil then
	 health_bar_definition.number = player:get_hp()
	 rp_hud.ids[name].id_healthbar  = player:hud_add(health_bar_definition)
      end
   else
      if rp_hud.ids[name].id_healthbar ~= nil then
	 player:hud_remove(rp_hud.ids[name].id_healthbar)
	 rp_hud.ids[name].id_healthbar = nil
      end
   end

   if (player:get_breath() < minetest.PLAYER_MAX_BREATH_DEFAULT) then
      if minetest.is_yes(minetest.settings:get("enable_damage")) then
	 if rp_hud.ids[name].id_breathbar == nil then
	    breath_bar_definition.number = player:get_breath()*2
	    rp_hud.ids[name].id_breathbar = player:hud_add(breath_bar_definition)
	 end
      else
	 if rp_hud.ids[name].id_breathbar ~= nil then
	    player:hud_remove(rp_hud.ids[name].id_breathbar)
	    rp_hud.ids[name].id_breathbar = nil
	 end
      end
   elseif rp_hud.ids[name].id_breathbar ~= nil then
      player:hud_remove(rp_hud.ids[name].id_breathbar)
      rp_hud.ids[name].id_breathbar = nil
   end
end

function rp_hud.cleanup_builtin_statbars(player)
   if not player:is_player() then
      return
   end

   local name = player:get_player_name()

   if name == "" then
      return
   end

   rp_hud.ids[name] = nil
end

function rp_hud.player_event_handler(player, eventname)
   assert(player:is_player())

   local name = player:get_player_name()

   if name == "" then
      return
   end

   if eventname == "health_changed" then
      rp_hud.initialize_builtin_statbars(player)

      if rp_hud.ids[name].id_healthbar ~= nil then
	 player:hud_change(rp_hud.ids[name].id_healthbar,"number",player:get_hp())
	 return true
      end
   end

   if eventname == "breath_changed" then
      rp_hud.initialize_builtin_statbars(player)

      if rp_hud.ids[name].id_breathbar ~= nil then
	 player:hud_change(rp_hud.ids[name].id_breathbar,"number",player:get_breath()*2)
	 return true
      end
   end

   if eventname == "hud_changed" then
      rp_hud.initialize_builtin_statbars(player)
      return true
   end

   return false
end

function rp_hud.replace_builtin(name, definition)
   if definition == nil or type(definition) ~= "table" or definition.hud_elem_type ~= "statbar" then
      return false
   end

   if name == "health" then
      health_bar_definition = definition

      for name,ids in pairs(rp_hud.ids) do
	 local player = minetest.get_player_by_name(name)
	 if  player and rp_hud.ids[name].id_healthbar then
	    player:hud_remove(rp_hud.ids[name].id_healthbar)
	    rp_hud.initialize_builtin_statbars(player)
	 end
      end
      return true
   end

   if name == "breath" then
      breath_bar_definition = definition

      for name,ids in pairs(rp_hud.ids) do
	 local player = minetest.get_player_by_name(name)
	 if  player and rp_hud.ids[name].id_breathbar then
	    player:hud_remove(rp_hud.ids[name].id_breathbar)
	    rp_hud.initialize_builtin_statbars(player)
	 end
      end
      return true
   end

   return false
end

minetest.register_on_joinplayer(rp_hud.initialize_builtin_statbars)
minetest.register_on_leaveplayer(rp_hud.cleanup_builtin_statbars)
minetest.register_playerevent(rp_hud.player_event_handler)
