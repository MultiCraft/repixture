local player_soundspec = {}
local player_lastsound = {}
local player_health = {}

local enable_flowing_water_sound = minetest.setting_getbool("enable_flowing_water_sound")
if enable_flowing_water_sound == nil then enable_flowing_water_sound = true end

local function step(dtime)
   local player_positions = {}

   for _, player in ipairs(minetest.get_connected_players()) do
      local player_pos=player:getpos()
      local name=player:get_player_name()

      if player_pos.x < -30000 or player_pos.x > 30000
	 or player_pos.y < -30000 or player_pos.y > 30000
	 or player_pos.z < -30000 or player_pos.z > 30000 then
	 minetest.chat_send_player(name, "Don't go past 30000m in any direction!")
	 player.set_hp(0)
      end

      if player:get_hp() < player_health[name] then
	 minetest.sound_play(
	    "default_hurt",
	    {
	       pos = player_pos,
	       max_hear_distance = 4,
	    })	 
      end
      player_health[name] = player:get_hp()

      player_pos.x=math.floor(player_pos.x+0.5)
      player_pos.y=math.ceil(player_pos.y-0.3)
      player_pos.z=math.floor(player_pos.z+0.5)
      
      local nodename=minetest.get_node(player_pos).name

      if player_lastsound[name] == nil then player_lastsound[name] = 100 end

      player_lastsound[name] = player_lastsound[name] + dtime

      local flowing_water_pos = nil
      if enable_flowing_water_sound then
	 flowing_water_pos = minetest.find_node_near(player_pos, 16, "group:flowing_water")
      end

      if nodename == "default:water_source" or nodename == "default:river_water_source" then
	 if player_lastsound[name] > 3.3 then
	    player_soundspec[name]=minetest.sound_play(
	       "default_water",
	       {
		  pos = player_pos,
		  max_hear_distance = 16,
	       })
	    player_lastsound[name] = 0
	 end
      elseif flowing_water_pos then
	 if player_lastsound[name] > 3.3 then

	    local c = true
	    for _, p in pairs(player_positions) do
	       if (p.x * player_pos.x) + (p.y * player_pos.y) + (p.z * player_pos.z) < 256 then
		  -- 256 is 16*16 for distance checking
		  c = false
	       end
	    end
	    
	    if c then
	       player_soundspec[name]=minetest.sound_play(
		  "default_water",
		  {
		     pos = flowing_water_pos,
		     max_hear_distance = 16,
		  })
	       player_lastsound[name] = 0
	    end
	 end	 
      else
	 if player_soundspec[name] ~= nil then
	    minetest.sound_stop(player_soundspec[name])

	    player_lastsound[name] = 100
	 end
      end
      
      local grass_pos=minetest.find_node_near(player_pos, 1, {"default:dirt_with_grass"})

      if grass_pos ~= nil and math.random(1, 500) == 1 then
	 if grass_pos.x == player_pos.x and grass_pos.z == player_pos.z then
	    minetest.set_node(grass_pos, {name = "default:dirt_with_grass_footsteps"})
	 end
      end

      table.insert(player_positions, player_pos)
   end
end

local function on_joinplayer(player)
   local name=player:get_player_name()

   player_health[name] = player:get_hp()

-- uncomment to enable player-on-player collisions
--   player:set_properties({physical = true})

   -- uncomment to disable the sneak glitch
   player:set_physics_override({sneak_glitch = false})
end

local function on_leaveplayer(player)
   local name=player:get_player_name()

   player_soundspec[name] = nil
   player_lastsound[name] = nil
   player_health[name] = nil
end

minetest.register_privilege("uberspeed", "Can use /uberspeed command")

minetest.register_chatcommand(
   "uberspeed",
   {
      params = "[on|off|cinematic]",
      description = "Set Uberspeed",
      privs = {weather = true},
      func = function(name, param)
		local player=minetest.get_player_by_name(name)

		if param == "on" then
		   player:set_physics_override({speed = 8})
		elseif param == "off" then
		   player:set_physics_override({speed = 1})
		elseif param == "cinematic" then
		   player:set_physics_override({speed = 2})
		else
		   minetest.chat_send_player(name, "Bad param for /uberspeed; type /help uberspeed")
		end
	     end
   })

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_globalstep(step)

default.log("player", "loaded")