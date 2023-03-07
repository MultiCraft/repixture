--
-- Ambiance mod
--

local mod_weather = minetest.get_modpath("rp_weather")

local ambiance = {}
ambiance.sounds = {}

-- When the weather changes, the mod will still use
-- for a few seconds the old weather as the basis for
-- ambience decision. This is so the birds don’t
-- immediately start singing when the rain ends.
local WEATHER_CONDITION_DELAY = 5000000 -- µs

-- Minimum theoretical sunlight level required for birds to sing
local BIRDS_MIN_LIGHT = 10

local get_weather_lagged
if mod_weather then
	get_weather_lagged = function()
		local time = weather.weather_last_changed_before()
		if time and time < WEATHER_CONDITION_DELAY then
			return weather.previous_weather
		else
			return weather.weather
		end
	end
end

--[[ Returns true if the provided timeofday (`tod`)
is between 2 times of day inclusive, false otherwise.
Recognizes the midnight

* `tod`: timeofday to check for, value returned by `minetest.get_timeofday()`. Range: [0.0-1.0)
* `start_time`: timeofday of the start of the time range. Range: [0-24000)
* `end_time`: timeofday of the end of the time range. Range: [0-24000)

If `start_time` is greater than `end_time`, it is a time range
that wraps around midnight.
]]
local is_in_timeofday_range = function(tod, start_time, end_time)
   local tod24k = tod * 24000
   if start_time < end_time then
      return tod24k >= start_time and tod24k <= end_time
   else
      return tod24k >= start_time or tod24k <= end_time
   end
end

-- Returns true if `pos` is exposed to the sky (sunlight would reach it with no limit),
-- or `false` otherwise.
-- If `pos` is not loaded, will also return `false`.
-- * `pos`: Position to check for
-- * `check_neighbors`: If true, also check the 6 neighboring nodes. If `pos`
--   OR any neighbor is exposed, `true` will be returned
local is_sky_exposed_direct = function(pos, check_neighbors)
   local self_exposed = minetest.get_node_light(pos, 0.5) == 15
   if self_exposed == true then
      return true
   end
   local neighbors = {
      vector.new(0, 1, 0),
      vector.new(0, 0, -1),
      vector.new(0, 0, 1),
      vector.new(-1, 0, 0),
      vector.new(1, 0, 0),
      vector.new(0, -1, 0),
   }
   if check_neighbors then
      for n=1, #neighbors do
         if minetest.get_node_light(vector.add(neighbors[n], pos), 0.5) == 15 then
            return true
         end
      end
   end
   return false
end

-- Returns true if pos is indirectly exposed to sunlight with a minimum light level
-- * `pos`: Positio to check
-- * `min_light`: Expected minimum light level
local is_sky_exposed_indirect = function(pos, min_light)
   local light = minetest.get_natural_light(pos, 0.5)
   if light then
     return light >= min_light
   else
     return false
   end
end

ambiance.sounds["birds_leaves"] = {
   length = 5.0,
   chance = 4,
   file = "ambiance_birds_robin",
   dist = 8,
   nodename = "rp_default:leaves",
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      -- Birds only sing in nodes that are close to sunlight.
      -- This ensures birds won't sing in the caves without
      -- needing a hardcoded (and ugly) Y check.
      if not is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
}

ambiance.sounds["birds_leaves_birch"] = {
   length = 8.0,
   chance = 6,
   file = "ambiance_birds_cold",
   dist = 8,
   nodename = "rp_default:leaves_birch",
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
}

ambiance.sounds["birds_leaves_oak"] = {
   length = 5.0,
   chance = 4,
   file = "ambiance_birds_blackbird",
   dist = 8,
   nodename = "rp_default:leaves_oak",
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
}

ambiance.sounds["owl_birch"] = {
   length = 5.0,
   chance = 10,
   file = "ambiance_whoot_owl",
   dist = 8,
   nodename = "rp_default:leaves_birch",
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      if is_in_timeofday_range(tod, 20000, 4000) then
         return true
      end

      return false
   end,
}

ambiance.sounds["owl_oak"] = {
   length = 5.0,
   chance = 5,
   file = "ambiance_tawny_owl",
   dist = 8,
   gain = 0.9,
   nodename = "rp_default:leaves_oak",
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      if is_in_timeofday_range(tod, 20000, 4000) then
         return true
      end

      return false
   end,
}

ambiance.sounds["crickets"] = {
   length = 6.0,
   chance = 15,
   file = "ambiance_crickets",
   dist = 8,
   gain = 0.15,
   nodename = {"group:normal_grass", "group:dry_grass"},
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_direct(pos) then
         return false
      end

      local tod = minetest.get_timeofday()
      if is_in_timeofday_range(tod, 18000, 6000) then
         return true
      end

      return false
   end,
}

ambiance.sounds["cricket_mountain"] = {
   length = 0.5,
   chance = 100,
   file = "ambiance_cricket_mountain",
   dist = 8,
   nodename = {"group:dry_leaves", "group:dry_grass"},
   can_play = function(pos)
      if mod_weather then
         if get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not is_sky_exposed_direct(pos, true) then
         return false
      end

      local tod = minetest.get_timeofday()
      if is_in_timeofday_range(tod, 6000, 18000) then
         return true
      end

      return false
   end,
}



ambiance.sounds["frog"] = {
   length = 0.5,
   chance = 64,
   pitch_min = -10,
   pitch_max = 10,
   file = "ambiance_frog",
   dist = 16,
   nodename = "group:swamp_grass",
   can_play = function(pos)
      if not is_sky_exposed_direct(pos) then
         return false
      end

      local tod = minetest.get_timeofday()
      if is_in_timeofday_range(tod, 19200, 4800) then
         return true
      end

      return false
   end,
}

ambiance.sounds["flowing_water"] = {
   length = 2.6,
   chance = 1,
   file = "ambiance_water",
   dist = 16,
   gain = 0.08,
   nodename = "group:flowing_water",
}

local ambiance_volume = tonumber(minetest.settings:get("ambiance_volume")) or 1.0
ambiance_volume = math.max(0.0, math.min(1.0, ambiance_volume))

if minetest.settings:get_bool("ambiance_enable") == true then
   local lastsound = {}

   local function ambient_node_near(sound, pos)
      local nodepos = minetest.find_node_near(pos, sound.dist, sound.nodename)

      if nodepos ~= nil and math.random(1, sound.chance) == 1 then
         return nodepos
      end

      return nil
   end

   local function step(dtime)
      local player_positions = {}

      for _, player in ipairs(minetest.get_connected_players()) do
         local pos = player:get_pos()
         local name = player:get_player_name()

         for soundname, sound in pairs(ambiance.sounds) do
            if not minetest.settings:get_bool("ambiance_disable_" .. soundname) then
               if lastsound[name] == nil then
                  -- lastsound is not initialized yet
                  return
               end
               if lastsound[name][soundname] then
                  lastsound[name][soundname] = lastsound[name][soundname] + dtime
               else
                  lastsound[name][soundname] = 0
               end

               if lastsound[name][soundname] > sound.length then
                  local sourcepos = ambient_node_near(sound, pos)

                  if sound.can_play and sourcepos ~= nil and (not sound.can_play(sourcepos)) then
                     sourcepos = nil
                  end

                  if sourcepos then
                     local ok = true
                     for _, p in pairs(player_positions) do
                        if (p.x * pos.x) + (p.y * pos.y) + (p.z * pos.z) < sound.dist * sound.dist then
                           ok = false
                        end
                     end

                     if ok then
                        local pitch = nil
                        if sound.pitch_min and sound.pitch_max then
                           pitch = 1 + 0.01 * math.random(sound.pitch_min, sound.pitch_max)
                        end
                        minetest.sound_play(
                           sound.file,
                           {
                              pos = sourcepos,
                              max_hear_distance = sound.dist,
                              gain = ambiance_volume * (sound.gain or 1),
                              pitch = pitch,
                           }, true)

                        lastsound[name][soundname] = 0
                     end
                  end
               end
            end
         end

         table.insert(player_positions, pos)
      end
   end

   local function on_joinplayer(player)
      local name = player:get_player_name()

      lastsound[name] = {}
   end

   local function on_leaveplayer(player)
      local name = player:get_player_name()

      lastsound[name] = nil
   end

   minetest.register_on_joinplayer(on_joinplayer)
   minetest.register_on_leaveplayer(on_leaveplayer)
   minetest.register_globalstep(step)
end
