local S = minetest.get_translator("rp_player")

local mod_textures = minetest.get_modpath("rp_textures") ~= nil

local player_soundspec = {}
local player_lastsound = {}
local player_health = {}
local player_lastpos = {}
local player_watertime = {} -- for aqualung achievement
local player_sneak = {}

local particlespawners = {}

local AQUALUNG_TIME = 150 -- seconds required for aqualung achievement

-- texture modifier when player takes damage
local DAMAGE_TEXTURE_MODIFIER = "^[colorize:#df2222:180"

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

      -- Make nametag color less visible while sneaking
      local controls = player:get_player_control()
      if player_sneak[name] ~= controls.sneak then
         if controls.sneak then
            player:set_nametag_attributes({
               color = {a = 30, r = 255, g = 255, b = 255},
               bgcolor = {a = 10, r = 0, g = 0, b = 0},
            })
         else
            player:set_nametag_attributes({
               color = {a = 255, r = 255, g = 255, b = 255},
               bgcolor = {a = 50, r = 0, g = 0, b = 0},
            })
         end
      end
      if player_sneak[name] ~= controls.sneak then
         player_sneak[name] = controls.sneak
      end

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
                  name = "rp_textures_bubble_particle.png",
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

local function on_respawnplayer(player)
	local pos = player:get_pos()
	if mod_textures then
		minetest.add_particlespawner({
			amount = 16,
			time = 0.02,
			pos = {
				min = vector.add(pos, vector.new(-0.4, 0.0, -0.4)),
				max = vector.add(pos, vector.new(0.4, 0.1, 0.4)),
			},
			vel = {
				min = vector.new(-1, 0.2, -1),
				max = vector.new(1, 2, 1),
			},
			acc = vector.zero(),
			exptime = { min = 1.0, max = 1.5 },
			size = { min = 8, max = 12 },
			drag = vector.new(1,1,1),
			texture = {
				name = "rp_textures_death_smoke_anim_1.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
				name = "rp_textures_death_smoke_anim_2.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
				name = "rp_textures_death_smoke_anim_1.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
				name = "rp_textures_death_smoke_anim_2.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
			},
		})
	end
	minetest.sound_play({name="rp_sounds_disappear", gain=0.4}, {pos=pos, max_hear_distance=12}, true)
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

   local zoom
   if minetest.is_creative_enabled(name) then
      zoom = 10 -- to match spyglass zoom
   end
   player:set_properties({
      damage_texture_modifier = DAMAGE_TEXTURE_MODIFIER,
      zoom_fov = zoom,
   })

   -- No free coordinates for you, sorry!
   rp_hud.set_hud_flag_semaphore(player, "rp_player:debug", "basic_debug", false)
end


local function on_leaveplayer(player)
   local name = player:get_player_name()

   player_health[name] = nil

   player_lastpos[name] = nil
   player_watertime[name] = nil
   player_sneak[name] = nil

   player_soundspec[name] = nil
   player_lastsound[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_respawnplayer(on_respawnplayer)

minetest.register_globalstep(step)


