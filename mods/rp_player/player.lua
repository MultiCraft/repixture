local S = minetest.get_translator("rp_player")

local player_soundspec = {}
local player_lastsound = {}
local player_health = {}
local player_lastpos = {}
local player_watertime = {} -- for aqualung achievement

local particlespawners = {}

local AQUALUNG_TIME = 150 -- seconds required for aqualung achievement

local mod_achievements = minetest.get_modpath("rp_achievements") ~= nil

if mod_achievements then
   -- Achievement for staying underwater for a long time and not taking drowning
   -- damage.
   -- player_watertime is used to count the underwater time.
   -- NOTE: The timer is NOT preserved on server shutdown.
   achievements.register_achievement(
      "aqualung",
      {
         title = S("Aqualung"),
         description = S("Stay underwater for 2 and a half consecutive minutes without drowning."),
         times = 1,
         difficulty = 5.5,
         icon = "rp_player_achievement_aqualung.png",
   })

   -- Reset water time for aqualung achievement if taking drowning damage
   minetest.register_on_player_hpchange(function(player, hp_change, reason)
      if reason.type == "drown" and hp_change < 0 then
         player_watertime[player:get_player_name()] = 0
      end
   end)
end

local function step(dtime)
   local player_positions = {}

   for _, player in ipairs(minetest.get_connected_players()) do
      local player_pos = player:get_pos()
      local head_pos = table.copy(player_pos)
      local bubble_pos = table.copy(player_pos)
      local name = player:get_player_name()

      player_lastpos[name] = player:get_pos()

      player_health[name] = player:get_hp()

      head_pos.x=math.floor(head_pos.x+0.5)
      head_pos.y=math.ceil(head_pos.y+1.0)
      head_pos.z=math.floor(head_pos.z+0.5)

      bubble_pos.y=bubble_pos.y+1.5

      player_pos.x=math.floor(player_pos.x+0.5)
      player_pos.y=math.ceil(player_pos.y-0.3)
      player_pos.z=math.floor(player_pos.z+0.5)

      if player_lastsound[name] == nil then player_lastsound[name] = 100 end

      player_lastsound[name] = player_lastsound[name] + dtime

      local headnode = minetest.get_node(head_pos)
      if minetest.get_item_group(headnode.name, 'water') > 0 then
	 particlespawners[name] = minetest.add_particlespawner(
	    {
	       amount = 2,
	       time = 0.1,
	       pos = {
                  min = {
                     x = bubble_pos.x - 0.2,
                     y = bubble_pos.y - 0.3,
                     z = bubble_pos.z - 0.3
                  },
	          max = {
                     x = bubble_pos.x + 0.3,
                     y = bubble_pos.y + 0.3,
                     z = bubble_pos.z + 0.3
                  },
               },
               vel = {
                  min = {x = -0.5, y = 0, z = -0.5},
                  max = {x = 0.5, y = 0, z = 0.5},
               },
               acc = {
                  min = {x = -0.5, y = 4, z = -0.5},
                  max = {x = 0.5, y = 1, z = 0.5},
               },
               exptime = {min=0.3,max=0.8},
               size = {min=0.7, max=2.4},
               texture = {
                  name = "bubble.png",
                  alpha_tween = { 1, 0, start = 0.75 }
               }
         })

	 minetest.after(0.15, function(name)
               if particlespawners[name] then
                       minetest.delete_particlespawner(particlespawners[name])
               end
         end, name)

         if mod_achievements then
	    -- Increase underwater time and give achievement if enough time
            if player_health[name] > 0 then
	       player_watertime[name] = player_watertime[name] + dtime
               if player_watertime[name] >= AQUALUNG_TIME then
                  achievements.trigger_achievement(player, "aqualung")
               end
            else
	       -- Reset timer if player's dead
	       player_watertime[name] = 0
            end
         end
      else
	  -- Reset water timer if player's not in water
         if mod_achievements then
            -- Exception: If player is in ignore node, timer is not affected.
	    -- The ignore node MIGHT turn out to be water.
            if headnode.name ~= "ignore" then
               player_watertime[name] = 0
            end
         end
      end

      if minetest.get_item_group(minetest.get_node(player_pos).name, "water") > 0 then
	 if player_lastsound[name] > 3.3 then
	    player_soundspec[name]=minetest.sound_play(
	       "default_water",
	       {
		  pos = player_pos,
		  max_hear_distance = 16,
            })
	    player_lastsound[name] = 0
	 end

      else
	 if player_soundspec[name] ~= nil then
	    minetest.sound_stop(player_soundspec[name])

	    player_lastsound[name] = 100
	 end
      end

      table.insert(player_positions, player_pos)
   end
end

local function on_joinplayer(player)
   local name=player:get_player_name()

   player_health[name] = player:get_hp()
   player_lastpos[name] = player:get_pos()
   if mod_achievements then
      player_watertime[name] = 0
   end

   local inv = player:get_inventory()
   inv:set_size("hand", 1)

   player:set_properties({
      stepheight = 0.626, -- slightly above 10/16
   })
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   player_health[name] = nil

   player_lastpos[name] = nil
   player_watertime[name] = nil

   player_soundspec[name] = nil
   player_lastsound[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

minetest.register_globalstep(step)
