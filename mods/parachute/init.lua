
--
-- Parachute mod
--

local S = minetest.get_translator("parachute")

local function air_physics(v)
   local m = 80    -- Weight of player, kg
   local g = -9.81 -- Earth Acceleration, m/s^2
   local cw = 1.25 -- Drag coefficient
   local rho = 1.2 -- Density of air (on ground, not accurate), kg/m^3
   local A = 25    -- Surface of the parachute, m^2

   return ((m * g + 0.5 * cw * rho * A * v * v) / m)
end

-- Tries to spawn a parachute entity and attaches it to player.
-- Will fail if player is already attached to something
-- or if player is too close to the ground.
-- * `player`: Player to open the parachute for
-- * `play_sound`: If true, will play a sound for opening the parachute (default: true)
-- Returns true on success or
-- false, <failure_reason> on failure.
-- * <failure_reason> = "already_attached" if player was attached
-- * <failure_reason> = "on_ground" if player already on ground
local function open_parachute_for_player(player, play_sound)
   local name = player:get_player_name()
   if play_sound == nil then
      play_sound = true
   end

   local pos = player:get_pos()

   local on = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})

   if rp_player.player_attached[name] then
      return false, "already_attached"
   end

   if on.name == "air" or on.name == "ignore" then
      -- Spawn parachute
      local ppos = vector.new(pos.x, pos.y + 3, pos.z)

      local obj = minetest.add_entity(ppos, "parachute:entity")
      if play_sound then
         minetest.sound_play({name="parachute_open", pos=ppos}, {gain=0.5}, true)
      end

      if on.name ~= "ignore" then
         obj:set_velocity(
            {
               x = 0,
               y = math.min(0, player:get_velocity().y),
               z = 0
         })
      else
	 obj:set_velocity(vector.zero())
      end

      player:set_attach(obj, "", {x = 0, y = -8, z = 0}, {x = 0, y = 0, z = 0}, true)

      obj:set_yaw(player:get_look_horizontal())

      local lua = obj:get_luaentity()
      lua.attached = name

      local in_node = minetest.get_node(pos)
      lua.ignore_mode = in_node.name == "ignore"

      rp_player.player_attached[name] = true

      local meta = player:get_meta()
      -- Save parachute state in player meta. Used to re-open the parachute when
      -- leaving the server and then re-joining.
      meta:set_int("parachute:active", 1)

      minetest.log("action", "[parachute] "..name.." opens a parachute at "..minetest.pos_to_string(obj:get_pos(), 1))
      return true
   else
      return false, "on_ground"
   end
end

minetest.register_craftitem(
   "parachute:parachute", {
      description = S("Parachute"),
      _tt_help = S("Lets you glide safely to the ground when falling"),
      inventory_image = "parachute_inventory.png",
      wield_image = "parachute_inventory.png",
      stack_max = 1,
      on_activate = function(self)
         self.object:set_armor_groups({immortal=1})
      end,
      on_use = function(itemstack, player, pointed_thing)
         local ok, fail_reason = open_parachute_for_player(player)
         if ok then
            if not minetest.is_creative_enabled(player:get_player_name()) then
               itemstack:take_item()
            end
            return itemstack
         else
            if fail_reason == "on_ground" then
               minetest.chat_send_player(
                 player:get_player_name(),
                 minetest.colorize("#FFFF00", S("You can open the parachute only in air!")))
            end
         end
         return itemstack
      end,
})

minetest.register_entity(
   "parachute:entity",
   {
      visual = "mesh",
      mesh = "parachute.b3d",
      textures = {"parachute_mesh.png"},
      physical = false,
      pointable = false,
      automatic_face_movement_dir = -90,

      attached = nil,
      start_y = nil,
      ignore_mode = false,

      on_activate = function(self, staticdata, dtime_s)
         if dtime_s == 0 then
           local pos = self.object:get_pos()
           self.start_y = pos.y
         end
      end,
      on_step = function(self, dtime)
         local pos = self.object:get_pos()
         local under = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
	 if under.name ~= "ignore" then
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

            local speed = 4.0

            local accel = {x = 0, y = 0, z = 0}

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

            accel.y = accel.y + air_physics(vel.y) * 0.25

	    if under.name ~= "ignore" then
               self.object:set_acceleration(accel)
            else
               self.object:set_acceleration(vector.zero())
               self.object:set_velocity(vector.zero())
            end

            if under.name ~= "air" and (self.ignore_mode == false or under.name ~= "ignore") then
               rp_player.player_attached[self.attached] = false
            end
         end

         if under.name ~= "air" and (self.ignore_mode == false or under.name ~= "ignore") then
            local player
            if self.attached ~= nil then
               rp_player.player_attached[self.attached] = false

               player = minetest.get_player_by_name(self.attached)
               if player then
                  local meta = player:get_meta()
                  meta:set_int("parachute:active", 0)
                  if self.start_y ~= nil and self.start_y - self.object:get_pos().y > 100 then
                     achievements.trigger_achievement(player, "sky_diver")
                  end
               end
            end

            minetest.sound_play({name="parachute_close", pos=self.object:get_pos()}, {gain=0.5}, true)

            local final_pos_str = minetest.pos_to_string(self.object:get_pos(), 1)
            if player then
               minetest.log("action", "[parachute] Parachute of "..player:get_player_name().." getting destroyed at "..final_pos_str)
            else
               minetest.log("action", "[parachute] Parachute getting destroyed at "..final_pos_str)
            end
            self.object:remove()
         end
      end,
      on_deactivate = function(self)
         minetest.log("info", "[parachute] Parachute at "..minetest.pos_to_string(self.object:get_pos(), 1).." about to get removed")
         if self.attached ~= nil then
	    if rp_player.player_attached[self.attached] then
               local player = minetest.get_player_by_name(self.attached)
	       if player then
                  rp_player.player_attached[self.attached] = false
                  player:set_detach()
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
      minetest.log("action", "[parachute] Trying to open parachute for reconnected player "..player:get_player_name().." ...")
      open_parachute_for_player(player, false)
   end
end)

-- Crafting

crafting.register_craft(
   {
      output = "parachute:parachute",
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
      item_icon = "parachute:parachute",
})
