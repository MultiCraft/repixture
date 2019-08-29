
--
-- Bed mod
-- By PilzAdam, thefamilygrog66
-- Tweaked by Kaadmy, for Pixture
--

local S = minetest.get_translator("bed")

bed = {}

-- Per-user data table

bed.userdata = {}

-- Savefile

local bed_file = minetest.get_worldpath() .. "/bed.dat"
local saving = false

-- Timer

local timer_interval = 1
local timer = 0

local delay_daytime = false

local function is_bed_node(pos)
   if pos == nil then
      return false
   end

   local node = minetest.get_node(pos)

   if node.name == "bed:bed_foot" then
      return true
   end

   return false
end

local function put_player_in_bed(player)
   if player == nil then
      return
   end

   local name = player:get_player_name()

   if bed.userdata[name].slept
   and not is_bed_node(bed.userdata[name].node_pos) then
      return
   end

   player:set_look_horizontal(bed.userdata[name].spawn_yaw)
   player:set_pos(bed.userdata[name].spawn_pos)

   player_effects.apply_effect(player, "inbed")

   player:set_eye_offset(vector.new(0, -13, 0), vector.new(0, -13, 0))
   player:set_local_animation(
      {x=162, y=166},
      {x=162, y=166},
      {x=162, y=166},
      {x=162, y=168},
      default.player_animation_speed)

   default.player_set_animation(player, "lay", default.player_animation_speed)

   default.player_attached[name] = true

end

local function take_player_from_bed(player)
   if player == nil then
      return
   end

   local name = player:get_player_name()

   player:set_pos(bed.userdata[name].spawn_pos)

   player_effects.remove_effect(player, "inbed")

   player:set_eye_offset(vector.new(0, 0, 0), vector.new(0, 0, 0))
   player:set_local_animation(
      {x=0, y=79},
      {x=168, y=187},
      {x=189, y=198},
      {x=200, y=219},
      default.player_animation_speed)

   default.player_set_animation(player, "stand", default.player_animation_speed)

   default.player_attached[name] = false
end

local function save_bed()
   local f = io.open(bed_file, "w")

   f:write(minetest.serialize(bed.userdata))

   io.close(f)

   saving = false
end

local function delayed_save()
   if not saving then
      saving = true

      minetest.after(40, save_bed)
   end
end

local function load_bed()
   local f = io.open(bed_file, "r")

   if f then
      bed.userdata = minetest.deserialize(f:read("*all"))

      io.close(f)
   else
      save_bed()
   end
end

-- Server start

local function on_load()
   load_bed()
end

-- Server shutdown

local function on_shutdown()
   save_bed()
end

-- Joining player

local function on_joinplayer(player)
   local name = player:get_player_name()

   if not bed.userdata[name] then
      bed.userdata[name] = {
         in_bed = false,

         spawn_yaw = 0,
         spawn_pos = nil,

         slept = false,

         node_pos = nil,
      }

      delayed_save()
   end

   if bed.userdata[name].in_bed then
      minetest.after(
         0.1,
         function(player)
            if player and player:is_player() then
                put_player_in_bed(player)
            end
      end, player)
   end
end

-- Respawning player

local function on_respawnplayer(player)
   local name = player:get_player_name()

   if bed.userdata[name] then
      if not bed.userdata[name].slept then
         return
      end

      bed.userdata[name].in_bed = false

      take_player_from_bed(player)

      return true
   end
end

-- Update function

local function on_globalstep(dtime)
   timer = timer + dtime

   if timer < timer_interval then
      return
   end

   timer = 0

   local sleeping_players = 0

   for name, data in pairs(bed.userdata) do
      if data.in_bed then
         local player = minetest.get_player_by_name(name)

         sleeping_players = sleeping_players + 1

         if vector.distance(player:get_pos(), data.spawn_pos) > 2 then
            player:move_to(data.spawn_pos)
         end
      end
   end

   local players = minetest.get_connected_players()
   local player_count = #players

   if player_count > 0 and (player_count / 2.0) < sleeping_players then
      if minetest.get_timeofday() < 0.2 or minetest.get_timeofday() > 0.8 then
         if not delay_daytime then
            delay_daytime = true

            minetest.after(
               2,
               function()
                  minetest.chat_send_all(
                     minetest.colorize(
                        "#0ff",
                        "*** " .. S("Players have slept, rise and shine!")))

                  minetest.set_timeofday(0.23)
                  delay_daytime = false

                  local players = minetest.get_connected_players()
                  for _, player in ipairs(players) do
                     if bed.userdata[player:get_player_name()].in_bed then
                        bed.userdata[player:get_player_name()].slept = true
                     end
                  end
            end)

            delayed_save()
         end
      end
   end
end

minetest.register_on_mods_loaded(on_load)

minetest.register_on_shutdown(on_shutdown)

minetest.register_on_joinplayer(on_joinplayer)

minetest.register_on_respawnplayer(on_respawnplayer)

minetest.register_globalstep(on_globalstep)

-- Nodes

minetest.register_node(
   "bed:bed_foot",
   {
      description = S("Bed"),
      drawtype = "nodebox",
      paramtype = "light",
      paramtype2 = "facedir",
      sunlight_propagates = true,
      wield_image = "bed_bed_inventory.png",
      inventory_image = "bed_bed_inventory.png",
      tiles = {"bed_foot.png", "default_wood.png", "bed_side.png"},
      groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 0.5}
      },
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 1.5}
      },

      after_place_node = function(pos)
         local node = minetest.get_node(pos)
         local dir = minetest.facedir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         node.name = "bed:bed_head"
         if minetest.registered_nodes[minetest.get_node(head_pos).name].buildable_to then
            minetest.set_node(head_pos, node)
         else
            minetest.remove_node(pos)
         end
      end,

      on_destruct = function(pos)
         local node = minetest.get_node(pos)
         local dir = minetest.facedir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         if minetest.get_node(head_pos).name == "bed:bed_head" then
            minetest.remove_node(head_pos)
         end
      end,

      on_rightclick = function(pos, node, clicker)
         if not clicker:is_player() then
            return
         end

         local name = clicker:get_player_name()
         local meta = minetest.get_meta(pos)
         local put_pos = vector.add(pos, vector.divide(
                                       minetest.facedir_to_dir(node.param2), 2))

         if clicker:get_player_name() == meta:get_string("player") then
            put_pos.y = put_pos.y - 0.5

            bed.userdata[name].in_bed = false

            take_player_from_bed(clicker)

            meta:set_string("player", "")
         elseif meta:get_string("player") == "" and not default.player_attached[name]
         and bed.userdata[name].in_bed == false then
            if not minetest.settings:get_bool("bed_enabled") then
               return
            end

            put_pos.y = put_pos.y + 0.6

            local yaw = 0

            if node.param2 ~= 2 then
               yaw = (node.param2 / 2.0) * math.pi
            end

            bed.userdata[name].in_bed = true

            bed.userdata[name].spawn_yaw = yaw
            bed.userdata[name].spawn_pos = put_pos

            bed.userdata[name].node_pos = pos

            put_player_in_bed(clicker)

            meta:set_string("player", name)
         end
      end,

      can_dig = function(pos)
         return minetest.get_meta(pos):get_string("player") == ""
      end
})

minetest.register_node(
   "bed:bed_head",
   {
      drawtype = "nodebox",
      paramtype = "light",
      paramtype2 = "facedir",
      is_ground_content = false,
      pointable = false,
      tiles = {"bed_head.png", "default_wood.png", "bed_side.png"},
      groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
      sounds = default.node_sound_wood_defaults(),
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 0.5}
      }
})

minetest.register_alias("bed:bed", "bed:bed_foot")

-- Crafting

crafting.register_craft(
   {
      output = "bed:bed",
      items = {
         "group:fuzzy 3",
         "group:planks 3",
      }
})

-- Player effects

player_effects.register_effect(
   "inbed",
   {
      title = S("In bed"),
      description = S("You're in a bed"),
      duration = -1,
      physics = {
	 speed = 0,
	 jump = 0,
	 gravity = 0,
      }
})

-- Achievements

achievements.register_achievement(
   "bedtime",
   {
      title = S("Bed Time"),
      description = S("Craft a bed"),
      times = 1,
      craftitem = "bed:bed_foot",
})

default.log("mod:bed", "loaded")
