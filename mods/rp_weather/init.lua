-- Weather mod

local S = minetest.get_translator("rp_weather")

local mod_storage = minetest.get_mod_storage()

weather = {}
weather.weather = "clear"
weather.previous_weather = "clear"
weather.last_weather_change = nil
weather.types = {"storm", "clear"}

local sound_handles = {}

local function addvec(v1, v2)
   return {x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z}
end

local mapseed = minetest.get_mapgen_setting("seed")
local weather_pr = PseudoRandom(mapseed + 2387 + minetest.get_us_time())

local sound_min_height = -20 -- Below -20m you can't hear weather

local loaded_weather = mod_storage:get_string("rp_weather:weather")
local weather_inited = false

local function update_sounds(do_repeat)
   if weather.weather == "storm" then
      for _, player in ipairs(minetest.get_connected_players()) do
         local name = player:get_player_name()
         local pos = player:get_pos()
         local node = minetest.get_node({x=pos.x, y=pos.y+1.5, z=pos.z})
         if pos.y > sound_min_height and minetest.get_item_group(node.name, "water") == 0 then
            if not sound_handles[name] then
               sound_handles[name] = minetest.sound_play(
                  { name = "weather_storm" }, { to_player = name, loop = true, fade = 0.5 }
               )
            end
         else
            if sound_handles[name] then
               minetest.sound_fade(sound_handles[name], -0.5, 0)
               sound_handles[name] = nil
            end
         end
      end
   else
      for _, player in ipairs(minetest.get_connected_players()) do
         local name = player:get_player_name()
         if sound_handles[name] then
            minetest.sound_fade(sound_handles[name], -1.0, 0)
            sound_handles[name] = nil
         end
      end
   end

   if do_repeat then
      minetest.after(3, update_sounds, do_repeat)
   end
end

-- This timer prevents the weather from changing naturally too fast
local stoptimer = 0
local stoptimer_init = 300 -- minimum time between natural weather changes in seconds

local function setweather_raw(new_weather)
      weather.previous_weather = weather.weather
      weather.weather = new_weather
      weather.last_weather_change = minetest.get_us_time()
end

local function setweather_type(wtype, do_repeat)
   local valid = false
   for i = 1, #weather.types do
      if weather.types[i] == wtype then
	 valid = true
      end
   end
   if valid then
      if weather.weather ~= wtype then
        -- Only reset stoptimer if weather actually changed
        stoptimer = stoptimer_init
      end
      setweather_raw(wtype)
      mod_storage:set_string("rp_weather:weather", weather.weather)
      minetest.log("action", "[rp_weather] Weather set to: "..weather.weather)
      update_sounds(do_repeat)
      return true
   else
      return false
   end
end

-- Returns the current weather
function weather.get_weather()
   return weather.weather
end

-- Returns true is position `pos` is in a place in which it could rain into
function weather.is_node_rainable(pos)
   for i=0, 15 do
      local cpos = {x=pos.x, y=pos.y+i, z=pos.z}
      local node = minetest.get_node(cpos)
      local def = minetest.registered_nodes[node.name]
      if not def or def.walkable then
         return false
      end
      if i == 0 then
         local light = minetest.get_node_light(cpos, 0.5)
         if light < 15 then
            return false
         end
      end
   end
   return true
end

-- Returns a number telling how many µs the weather was changed before.
-- Returns nil if weather was not changed before
function weather.weather_last_changed_before()
	local time = minetest.get_us_time()
	if not weather.last_weather_change then
		return nil
	end
	local diff = time - weather.last_weather_change
	return diff
end

minetest.register_globalstep(
   function(dtime)
      if stoptimer > 0 then
         stoptimer = stoptimer - dtime
      end
      if minetest.settings:get_bool("weather_enable") and stoptimer <= 0 then
         if not weather_inited then
             if loaded_weather == "" then
                setweather_type("clear", true)
             else
                setweather_type(loaded_weather, true)
             end
             weather_inited = true
	 elseif weather_pr:next(0, 5000) < 1 then
	    local weathertype = weather_pr:next(0, 19)

	    -- on avg., every 1800 globalsteps, the weather.weather will change to one of:
	    -- 13/20 chance of clear weather
	    -- 7/20 chance or stormy weather

            local oldweather = weather.weather
	    if weathertype < 13 then
               setweather_raw("clear")
	    else
               setweather_raw("storm")
	    end
            if oldweather ~= weather.weather then
               mod_storage:set_string("rp_weather:weather", weather.weather)
               minetest.log("action", "[rp_weather] Weather changed to: "..weather.weather)
               update_sounds()
               stoptimer = stoptimer_init
            end
	 end
      end

      for _, player in ipairs(minetest.get_connected_players()) do

	 local p=player:get_pos()

	 if weather.weather == "storm" then
	    if minetest.get_node_light({x=p.x, y=p.y+15, z=p.z}, 0.5) == 15 then
	       local minpos = addvec(player:get_pos(), {x = -15, y = 15, z = -15})
	       local maxpos = addvec(player:get_pos(), {x = 15, y = 10, z = 15})
	       minetest.add_particlespawner(
		  {
		     amount = 30,
		     time = 0.5,
		     minpos = minpos,
		     maxpos = maxpos,
		     minvel = {x = 0, y = -20, z = 0},
		     maxvel = {x = 0, y = -20, z = 0},
		     minexptime = 0.9,
		     maxexptime = 1.1,
		     minsize = 2,
		     maxsize = 3,
		     collisiondetection = true,
		     collision_removal = true,
		     vertical = true,
		     texture = "weather_rain.png",
		     playername = player:get_player_name()
		  }
	       )
	    end
	 end
      end
   end
)

minetest.register_privilege(
   "weather",
   {
      description = S("Can change the weather using the /weather command"),
      give_to_singleplayer = false
})

minetest.register_chatcommand(
   "weather",
   {
      params = "storm | clear",
      description = S("Change the weather"),
      privs = {weather = true},
      func = function(name, param)
         local weather_set = setweather_type(param)
         if not weather_set then
             return false, S("Incorrect weather. Valid weathers are “storm” and “clear”.")
         else
             return true, S("Weather changed.")
         end
      end
})

minetest.register_on_leaveplayer(function(player)
    sound_handles[player:get_player_name()] = nil
end)

local on_rain_abm = function(pos, node)
        if weather.get_weather() ~= "storm" then
           return
        end
	-- Don't call handlers for the first 5 seconds of rain
        local lwc = weather.weather_last_changed_before()
	if lwc ~= nil and lwc < 5000000 then
           return
	end
        if not weather.is_node_rainable({x=pos.x,y=pos.y+1,z=pos.z}) then
           return
        end
        local def = minetest.registered_nodes[node.name]
        if def._rp_on_rain then
              def._rp_on_rain(pos, node)
        else
           minetest.log("error", "[rp_weather] Node "..node.name.." has react_on_rain group but no _rp_on_rain handler!")
        end
end


minetest.register_abm({
    label = "Call _rp_on_rain node handlers during rain (low frequency)",
    chance = 3,
    interval = 30.0,
    nodenames = { "group:react_on_rain" },
    action = on_rain_abm,
})

minetest.register_abm({
    label = "Call _rp_on_rain node handlers during rain (high frequency)",
    chance = 2,
    interval = 5.0,
    nodenames = { "group:react_on_rain_hf" },
    action = on_rain_abm,
})

