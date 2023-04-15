--
-- Ambiance mod
--

ambiance = {}
local ambiance_local = {}
ambiance_local.sounds = {}

-- When the weather changes, the mod will still use
-- for a few seconds the old weather as the basis for
-- ambience decision. This is so the birds don’t
-- immediately start singing when the rain ends.
local WEATHER_CONDITION_DELAY = 5000000 -- µs

-- Maximum cooldown time to prevent sound repetitions
local SOUND_COOLDOWN_MAX = 3.0

local mod_weather = minetest.get_modpath("rp_weather") ~= nil
-- Returns true if the rp_weather mod has been detected
ambiance.weather_available = function()
   return mod_weather
end

if ambiance.weather_available() then
	ambiance.get_weather_lagged = function()
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
ambiance.is_in_timeofday_range = function(tod, start_time, end_time)
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
ambiance.is_sky_exposed_direct = function(pos, check_neighbors)
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
ambiance.is_sky_exposed_indirect = function(pos, min_light)
   local light = minetest.get_natural_light(pos, 0.5)
   if light then
     return light >= min_light
   else
     return false
   end
end

--[[ Registers ambience `name` with definition `def`.
An ambience is a sound will play if a player is close to a certain node.
It tries to play about every `length` seconds (plus/minus some delay)
with a chance of `1/chance` and if the `can_play` function is either
`nil` or returns `true`.

* name: unique ambience identifier
* def: ambience definition. These fields are used:
    * length: Length of ambient sound in seconds. Ambience will try to play every `length` seconds
    * chance: Chance to play sound in `1/chance`. Must be a natural number greater than 0
    * file: name of sound file (without the suffix) to play
    * dist: players need to be this many nodes away or closer for the sound to play
    * nodename: name of the node at which to play the sound. Can also be a group name like `"group:example"`
    * gain: (optional) gain of sound (same meaning as in a SimpleSoundSpec) (default: 1.0)
    * can_play: (optional) A function that will be called before playing the sound
         and controls whether the sound is allowed to play this time.
         Takes an argument `pos` (node position of sound) and must return
	 true if the sound can be played, false otherwise.
	 If `can_play` is `nil`, there are no restrictions.
]]

ambiance.register_ambiance = function(name, def)
	ambiance_local.sounds[name] = def
end

local ambiance_volume = tonumber(minetest.settings:get("ambiance_volume")) or 1.0
ambiance_volume = math.max(0.0, math.min(1.0, ambiance_volume))

if minetest.settings:get_bool("ambiance_enable") == true then
   local lastsound = {}
   local cooldown = {}

   local function ambient_node_near(sound, pos)
      local nodepos = minetest.find_node_near(pos, sound.dist, sound.nodename)

      if nodepos ~= nil and math.random(1, sound.chance) == 1 then
         return nodepos
      end

      return nil
   end

   local function step(dtime)
      local players = minetest.get_connected_players()

      -- Shuffle table so the player distance check is more likely
      -- to fail for a random player, and not biased to the order
      -- returned by `minetest.get_connected_players()`.
      table.shuffle(players)

      local player_positions = {}
      for _, player in ipairs(players) do
         table.insert(player_positions, {name=player:get_player_name(), pos=player:get_pos()})
      end

      for _, player in ipairs(players) do
         local pos = player:get_pos()
         local name = player:get_player_name()

         for soundname, sound in pairs(ambiance_local.sounds) do
            if lastsound[name] == nil or cooldown[name] == nil then
               -- variables are not initialized yet
               return
            end
            if lastsound[name][soundname] then
               lastsound[name][soundname] = lastsound[name][soundname] + dtime
            else
               lastsound[name][soundname] = 0
            end
	    if cooldown[name][soundname] then
               cooldown[name][soundname] = cooldown[name][soundname] + dtime
            else
               cooldown[name][soundname] = 0
            end

            if lastsound[name][soundname] > sound.length and cooldown[name][soundname] > math.min(SOUND_COOLDOWN_MAX, sound.length) then
               local sourcepos = ambient_node_near(sound, pos)

               -- Check if can_play of sound definition allows sound to be played
               if sound.can_play and sourcepos ~= nil and (not sound.can_play(sourcepos)) then
                  sourcepos = nil
               end

               if sourcepos then
                  local ok = true
                  -- Check if no other player who recently has played the same sound isn't too close to us
                  for _, other in pairs(player_positions) do
                     if name ~= other.name and -- other player
                        vector.distance(other.pos, pos) < sound.dist * 2 and -- minimum distance requirement
                        lastsound[other.name] and lastsound[other.name][soundname] <= sound.length then -- same sound was played recently
                        -- Too close! Suppress sound
                        ok = false
                        break
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

               -- Reset cooldown timer to avoid spamming
               -- the can_play function
               cooldown[name][soundname] = 0
            end
         end
      end
   end

   local function on_joinplayer(player)
      local name = player:get_player_name()

      lastsound[name] = {}
      cooldown[name] = {}
   end

   local function on_leaveplayer(player)
      local name = player:get_player_name()

      lastsound[name] = nil
      cooldown[name] = nil
   end

   minetest.register_on_joinplayer(on_joinplayer)
   minetest.register_on_leaveplayer(on_leaveplayer)
   minetest.register_globalstep(step)
end


dofile(minetest.get_modpath("rp_ambiance").."/register.lua")
