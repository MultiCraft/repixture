
--
-- Parachute mod
--

local S = minetest.get_translator("rp_parachute")

local GRAVITY = tonumber(minetest.settings:get("movement_gravity") or 9.81)

-- Parachute collisionbox values
local CBOX_BOTTOM = -0.8
local CBOX_TOP = 2.8
local CBOX_SIDE = 0.5

local VELOCITY_H_DAMP = 0.95 -- X/Z velocity is multiplied with this when it's above the max value
local VELOCITY_H_MAX = 8.0  -- Above this horizontal velocity the velocity will be dampened
local VELOCITY_Y_MIN = -10.0 -- Minimum Y velocity (hard cap)
local VELOCITY_Y_DAMP = 0.92 -- Y velocity is multiplied with this when it's below the min value
local AIR_PHYSICS_DAMP = 0.25 -- air_physics() value is multiplied with this
local ACCEL_H_DAMP = 1.0   -- Horizontal acceleration is multiplied with that if too fast
local ACCEL_CONTROL = 4.0   -- Acceleration to apply when pushing the movement controls

local SKY_DIVER_DEPTH = 100 -- how many nodes to sink to get the sky_diver achievement

local SND_GAIN_OPEN = 0.5 -- Sound gain for opening the parachute
local SND_GAIN_CLOSE = 0.8 -- Sound gain for closing the parachute
local SND_GAIN_FAIL = 0.5 -- Sound gain for failing to open the parachute

local function air_physics(v)
   local m = 80    -- Weight of player, kg
   local g = -GRAVITY  -- Earth Acceleration, m/s^2
   local cw = 1.25 -- Drag coefficient
   local rho = 1.2 -- Density of air (on ground, not accurate), kg/m^3
   local A = 25    -- Surface of the parachute, m^2

   return ((m * g + 0.5 * cw * rho * A * v * v) / m)
end

-- Checks if pos is suitable for a parachute to spawn in
-- for player.
-- Returns <success>, <fail_reason>.
-- * <success> is true on success
-- * <fail_reason> is the reason for failure
--    * `nil`: not failed
--    * `"on_ground"`: Player standing on ground
--    * `"in_liquid"`: Player inside liquid
--    * `"no_space"`: Not enough space (non-walkable non-liquid nodes count as space)
local check_parachute_spawnable = function(pos, player)
   -- We do a few raycasts which go vertically
   -- to test potential collision with the (soon-to-exist)
   -- parachute collisionbox.

   -- Tiny number added to the coordinates to make
   -- the checked area slightly bigger than the expected
   -- collision box to make sure the collisionbox
   -- definitely won't overlap with nodes or objects when
   -- spawned.
   local tiny = 0.01
   local y_extend = 1 -- Check a little bit below the potential collisionbox as well
                      -- so the parachute isn't spawned when standing on the ground
   local side = CBOX_SIDE + tiny
   local bottom = - y_extend - tiny
   local top = (CBOX_TOP - CBOX_BOTTOM) + tiny

   local offsets = {
           -- Format: { Xmin, Ymin, Zmin, Xmax, Ymax, Zmax }
           -- middle vertical ray
           { 0, bottom, 0, 0, top, 0 },
           -- for testing the 4 vertical edges of the collisionbox
           { -side, bottom, -side, -side, top, -side },
           { -side, bottom,  side, -side, top,  side },
           {  side, bottom, -side,  side, top, -side },
           {  side, bottom,  side,  side, top,  side },
   }
   -- Finally check the rays
   for i=1, #offsets do
      local off_start = vector.new(offsets[i][1], offsets[i][2], offsets[i][3])
      local off_end = vector.new(offsets[i][4], offsets[i][5], offsets[i][6])
      local ray_start = vector.add(pos, off_start)
      local ray_end = vector.add(pos, off_end)
      local ray = minetest.raycast(ray_start, ray_end, true, true)
      local on_ground_only = true -- whether we stand on ground
      local in_liquid = false -- whether we're in liquid (liquidtype unqual to "none")
      local collide = false -- whethe we collide
      while true do
         local thing = ray:next()
         if not thing then
            break
         end
         -- Any collision counts, EXCEPT with the parachuting player
         if not (thing.type == "object" and thing.ref == player) then
            local fail_reason
            collide = true
            if thing.intersection_point.y >= pos.y then
               on_ground_only = false
            end
            if not on_ground_only and not in_liquid and thing.type == "node" then
               local colnode = minetest.get_node(thing.under)
               local cdef = minetest.registered_nodes[colnode.name]
               if cdef and cdef.liquidtype ~= "none" then
                  in_liquid = true
               end
            end
         end
      end
      if collide then
         if on_ground_only then
            return false, "on_ground"
         elseif in_liquid then
            return false, "in_liquid"
         else
            return false, "no_space"
         end
      end
   end

   -- Finally, check nodes at the player feet to be extra sure
   local node1 = minetest.get_node(pos)
   local node2 = minetest.get_node(vector.new(pos.x, pos.y-1, pos.z))
   local def1 = minetest.registered_nodes[node1.name]
   local def2 = minetest.registered_nodes[node2.name]
   if not def1 or def1.walkable then
      return false, "on_ground"
   elseif not def2 or def2.walkable then
      return false, "on_ground"
   end

   -- All checks passed!
   return true
end

-- Tries to spawn a parachute entity and attaches it to player.
-- Will fail if player is already attached to something
-- or if player is too close to the ground.
-- * `player`: Player to open the parachute for
-- * `play_sound`: If true, will play a sound for opening the parachute (default: true)
-- * `load_area`: If true, will load the area before spawning the parachute
-- Returns true on success or
-- false, <failure_reason> on failure.
-- * <failure_reason> = "already_attached" if player was attached
-- * <failure_reason> = "on_ground" if player already on ground
-- * <failure_reason> = "ignore" if player is in ignore
local function open_parachute_for_player(player, play_sound, load_area)
   local name = player:get_player_name()
   if play_sound == nil then
      play_sound = true
   end

   local pos = player:get_pos()

   if rp_player.player_attached[name] then
      if play_sound then
         minetest.sound_play({name="rp_parachute_fail", gain=SND_GAIN_FAIL}, {object=player}, true)
      end
      return false, "already_attached"
   end

   local spawnable, fail_reason = check_parachute_spawnable(pos, player)

   if spawnable then
      -- Spawn parachute
      local ppos = vector.new(pos.x, pos.y - CBOX_BOTTOM, pos.z)

      if load_area then
         -- Load area around parachute to make sure it doesn't spawn into ignore
         local load1 = vector.add(ppos, vector.new(-2, -2, -2))
         local load2 = vector.add(ppos, vector.new(2, 4, 2))
         minetest.load_area(load1, load2)
      end

      local in_node = minetest.get_node(pos)
      if in_node.name == "ignore" then
         if play_sound then
            minetest.sound_play({name="rp_parachute_fail", gain=SND_GAIN_FAIL}, {object=player}, true)
         end
         return false, "ignore"
      end

      local obj = minetest.add_entity(ppos, "rp_parachute:entity")
      if play_sound then
         minetest.sound_play({name="rp_parachute_open", gain=SND_GAIN_OPEN}, {object=player}, true)
      end

      obj:set_velocity(
         {
            x = 0,
            y = math.min(0, player:get_velocity().y),
            z = 0
      })

      player:set_attach(obj, "", {x = 0, y = -8, z = 0}, {x = 0, y = 0, z = 0}, true)

      obj:set_yaw(player:get_look_horizontal())

      local lua = obj:get_luaentity()
      lua.attached = name

      rp_player.player_attached[name] = true

      local meta = player:get_meta()
      if meta:get_int("parachute:active") == 0 then
         -- Save parachute state in player meta. Used to re-open the parachute when
         -- leaving the server and then re-joining.
         meta:set_int("parachute:active", 1)
         -- Remember the initial Y position of the parachute for sky_diver achievement
         meta:set_float("parachute:start_y", obj:get_pos().y)
         -- This marks that parachute:start_y has been set (1 = set, 0 = unset)
         meta:set_int("parachute:start_y_set", 1)
      end

      minetest.log("action", "[rp_parachute] "..name.." opens a parachute at "..minetest.pos_to_string(obj:get_pos(), 1))
      return true
   else
      if play_sound then
         minetest.sound_play({name="rp_parachute_fail", gain=SND_GAIN_FAIL}, {object=player}, true)
      end
      return false, fail_reason
   end
end

minetest.register_craftitem(
   "rp_parachute:parachute", {
      description = S("Parachute"),
      _tt_help = S("Lets you glide safely to the ground when falling"),
      inventory_image = "parachute_inventory.png",
      wield_image = "parachute_inventory.png",
      stack_max = 1,
      groups = { tool = 1 },
      sound = {},
      on_use = function(itemstack, player, pointed_thing)
         local ok, fail_reason = open_parachute_for_player(player, true, true)
         if ok then
            if not minetest.is_creative_enabled(player:get_player_name()) then
               itemstack:take_item()
            end
            return itemstack
         else
            if fail_reason == "on_ground" or fail_reason == "in_liquid" then
               minetest.chat_send_player(
                 player:get_player_name(),
                 minetest.colorize("#FFFF00", S("You can open the parachute only in air!")))
	    elseif fail_reason == "no_space" then
               minetest.chat_send_player(
                 player:get_player_name(),
                 minetest.colorize("#FFFF00", S("Not enough space to open parachute!")))
            elseif fail_reason == "ignore" then
               -- If we're in ignore, we might either be in an unloaded area or outside the map
               minetest.chat_send_player(
                 player:get_player_name(),
                 -- Intentionally vague message
                 minetest.colorize("#FFFF00", S("The parachute fails to open for some reason.")))
	    end
         end
         return itemstack
      end,
})

minetest.register_entity(
   "rp_parachute:entity",
   {
      initial_properties = {
          visual = "mesh",
          mesh = "rp_parachute.b3d",
          textures = {"parachute_mesh.png"},
          pointable = false,
          physical = true,
          collide_with_objects = true,
          -- This collisionbox ranges from the feet of the player up to the top of the parachute.
          -- That way, the parachute will collide when either the player feet touch the ground
          -- or the parachute collides.
          -- This collisionbox MUST be re-checked whenever the player model or collisionbox
          -- was changed
          collisionbox = {-CBOX_SIDE, CBOX_BOTTOM, -CBOX_SIDE, CBOX_SIDE, CBOX_TOP, CBOX_SIDE},
          automatic_face_movement_dir = -90,
          static_save = false,
      },

      attached = nil,
      ignore_mode = false,

      on_activate = function(self, staticdata, dtime_s)
         minetest.log("info", "[rp_parachute] Parachute at "..minetest.pos_to_string(self.object:get_pos(), 1).." is activating (dtime_s="..dtime_s..")")
         self.object:set_armor_groups({immortal=1})
         if dtime_s == 0 then
           local pos = self.object:get_pos()
         end
               self.object:set_acceleration({x=0,y=0,z=0})
      end,
      on_step = function(self, dtime, moveresult)
	 local is_ignore = false
	 local collides = false
	 -- Check for regular collision
	 if moveresult and moveresult.collides then
            collides = true
            local nodes = 0
            for m=1, #moveresult.collisions do
               local col = moveresult.collisions[m]
               if col.type == "node" then
                  nodes = nodes + 1
               end
           end
	   if nodes == 0 then
              is_ignore = true
	   end
         end
	 if not collides then
             -- Check for special collision in liquids and nodes that slow players (e.g. water, spikes)
             local pos = self.object:get_pos()
             local node = minetest.get_node(pos)
	     local def = minetest.registered_nodes[node.name]
             if def and (def.liquidtype ~= "none" or def.liquid_move_physics == true or (def.move_resistance and def.move_resistance > 0)) then
                collides = true
             end
         end
         if not is_ignore then
            self.ignore_mode = false
         end

         if self.attached ~= nil then
            local player = minetest.get_player_by_name(self.attached)

            local vel = self.object:get_velocity()

            local lookyaw = math.pi - player:get_look_horizontal()

            if lookyaw < 0 then
               lookyaw = lookyaw + (math.pi * 2)
            end

            if lookyaw >= (math.pi * 2) then
               lookyaw = lookyaw - (math.pi * 2)
            end

            local s = math.sin(lookyaw)
            local c = math.cos(lookyaw)

            local sr = math.sin(lookyaw - (math.pi / 2))
            local cr = math.cos(lookyaw - (math.pi / 2))

            local controls = player:get_player_control()

            local speed = ACCEL_CONTROL

            local accel = {x = 0, y = 0, z = 0}

            -- Control horizontal velocity with the Up/Left/Right/Down keys.
            if controls.down then
               accel.x = s * speed
               accel.z = c * speed
            elseif controls.up then
               accel.x = s * -speed
               accel.z = c * -speed
            end

            if controls.right then
               accel.x = sr * speed
               accel.z = cr * speed
            elseif controls.left then
               accel.x = sr * -speed
               accel.z = cr * -speed
            end
            -- If above max hor. velocity, reduce it
            local vel = self.object:get_velocity()
            local old_y = vel.y
            vel.y = 0
            local maxed = vector.length(vel) >= VELOCITY_H_MAX
            local vel_changed = false
            if maxed then
               vel.y = old_y
               vel.x = vel.x * VELOCITY_H_DAMP
               vel.z = vel.z * VELOCITY_H_DAMP
               vel_changed = true
            end

            -- Accelerate Y, until we reach a maximum velocity (hard cap).
            if old_y > VELOCITY_Y_MIN then
               accel.y = accel.y + air_physics(vel.y) * AIR_PHYSICS_DAMP
            else
               accel.y = 0
               vel.y = old_y * VELOCITY_Y_DAMP
               if vel.y > VELOCITY_Y_MIN then
                   vel.y = VELOCITY_Y_MIN
               end
               vel_changed = true
	    end

            if not is_ignore then
               self.object:set_acceleration(accel)
               if vel_changed then
                  self.object:set_velocity(vel)
               end
            else
               self.object:set_acceleration(vector.zero())
               self.object:set_velocity(vector.zero())
            end

            -- Destroy parachute if colliding
            if collides and (self.ignore_mode == false or not is_ignore) then
               rp_player.player_attached[self.attached] = false
            end
         end

         -- Destroy parachute if colliding
         if collides and (self.ignore_mode == false or not is_ignore) then
            local player
            if self.attached ~= nil then
               rp_player.player_attached[self.attached] = false

               player = minetest.get_player_by_name(self.attached)
               if player then
                  local meta = player:get_meta()
                  -- award sky_diver achievement
                  local start_y_set = meta:get_int("parachute:start_y_set")
                  local start_y = meta:get_float("parachute:start_y", "start_y")
                  if start_y_set == 1 and start_y - self.object:get_pos().y >= SKY_DIVER_DEPTH then
                     achievements.trigger_achievement(player, "sky_diver")
                  end
                  -- reset metadata
                  meta:set_int("parachute:active", 0)
                  meta:set_int("parachute:start_y_set", 0)
                  meta:set_string("parachute:start_y", "")
               end
            end

            local snd_object
            if player then
               snd_object = player
            else
               snd_object = self.object
            end
            minetest.sound_play({name="rp_parachute_close", gain=SND_GAIN_CLOSE}, {object=snd_object}, true)

            local final_pos_str = minetest.pos_to_string(self.object:get_pos(), 1)
            if player then
               minetest.log("action", "[rp_parachute] Parachute of "..player:get_player_name().." getting destroyed at "..final_pos_str)
            else
               minetest.log("action", "[rp_parachute] Parachute getting destroyed at "..final_pos_str)
            end
            self.object:remove()
         end
      end,
      on_deactivate = function(self, removal)
         minetest.log("info", "[rp_parachute] Parachute at "..minetest.pos_to_string(self.object:get_pos(), 1).." is deactivating (removal="..tostring(removal)..")")
         if self.attached ~= nil then
            if rp_player.player_attached[self.attached] then
               local player = minetest.get_player_by_name(self.attached)
               if player then
                  rp_player.player_attached[self.attached] = false
                  player:set_detach()
                  if removal == true then
                     local meta = player:get_meta()
                     meta:set_int("parachute:active", 0)
                  end
               end
            end
         end
      end,
})

minetest.register_on_joinplayer(function(player)
   local meta = player:get_meta()
   -- Re-open parachute when player left the server
   -- with the parachute still active.
   -- Important to prevent the player falling to their doom.
   -- This isn't perfect as the old velocity isn't preserved but better
   -- better than nothing.
   if meta:get_int("parachute:active") == 1 then
      minetest.log("action", "[rp_parachute] Trying to open parachute for reconnected player "..player:get_player_name().." ...")
      local pos = player:get_pos()
      local ok, fail_reason = open_parachute_for_player(player, false, true)
      if not ok then
         minetest.log("action", "[rp_parachute] Parachute opening failed because: "..fail_reason)
      end
   end
end)

-- Crafting

crafting.register_craft(
   {
      output = "rp_parachute:parachute",
      items = {
         "group:fuzzy 3",
         "rp_default:rope 4",
         "rp_default:stick 6",
      }
})

-- Achievements

achievements.register_achievement(
   "sky_diver",
   {
      title = S("Skydiver"),
      description = S("Descend over 100 blocks with a parachute."),
      times = 1,
      icon = "rp_parachute_achievement_sky_diver.png",
      difficulty = 6.2,
})

-- Legacy support
minetest.register_alias("parachute:parachute", "rp_parachute:parachute")

-- Remove legacy parachute entity
minetest.register_entity(":parachute:entity", {
	initial_properties = {
		is_visible = false,
		pointable = false,
		physical = false,
		static_save = false,
	},
	on_activate = function(self)
		self.object:remove()
		minetest.log("action", "[rp_parachute] Legacy parachute entity at "..minetest.pos_to_string(self.object:get_pos(), 1).." removed")
	end,
})

minetest.register_on_chatcommand(function(name, command, params)
	if command == "spawnentity" then
		local entityname = string.match(params, "[a-zA-Z0-9_:]+")
		if entityname == "parachute:entity" then
			minetest.chat_send_player(name, S("Entity name “@1” is outdated. Use “@2” instead.", entityname, "rp_parachute:parachute"))
			return true
		end
	end
end)
