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

local default_cloud_state = nil

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
local stoptimer_init = 15 -- minumum time between natural weather changes in seconds

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

      local light = (minetest.get_timeofday() * 2)

      if light > 1 then
	 light = 1 - (light - 1)
      end

      light = (light * 0.5) + 0.15

      local skycol = math.floor(light * 190)

      for _, player in ipairs(minetest.get_connected_players()) do
	 if weather.weather == "storm" then
	    player:set_sky({
               type = "regular",
               clouds = true,
               sky_color = {
                   day_sky = {r = skycol, g = skycol, b = skycol * 1.2},
                   day_horizon = {r = skycol, g = skycol, b = skycol * 1.2},
                   dawn_sky = {r = skycol*0.75, g = skycol*0.75, b = skycol * 0.9},
                   dawn_horizon = {r = skycol*0.75, g = skycol*0.75, b = skycol * 0.9},
                   night_sky = {r = skycol*0.5, g = skycol*0.5, b = skycol * 0.6},
                   night_horizon = {r = skycol*0.5, g = skycol*0.5, b = skycol * 0.6},
               },
            })
            player:set_sun({visible=false, sunrise_visible=false})
            player:set_stars({visible=false})
            player:set_moon({visible=false})
            if default_cloud_state == nil then
               default_cloud_state = player:get_clouds()
            end

            player:set_clouds({
                  density = 0.5,
                  color = "#a0a0a0f0",
                  ambient = "#000000",
                  height = 100,
                  thickness = 40,
                  speed = {x = -2, y = 1},
            })

	    player:override_day_night_ratio(light)
	 else
	    player:set_sky({type = "regular", clouds = true, sky_color = {
                day_sky = "#8cbafa",
                day_horizon = "#9bc1f0",
                dawn_sky = "#b4bafa",
                dawn_horizon = "#bac1f0",
                night_sky = "#006aff",
                night_horizon = "#4090ff",
            }})
            player:set_sun({visible=true, sunrise_visible=true})
            player:set_stars({visible=true})
            player:set_moon({visible=true})

            if default_cloud_state ~= nil then
               player:set_clouds(default_cloud_state)
            end

	    player:override_day_night_ratio(nil)
	 end

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
