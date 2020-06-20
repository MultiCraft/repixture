
--
-- Bed mod
-- By PilzAdam, thefamilygrog66
-- Tweaked by Kaadmy, for Pixture
--

local S = minetest.get_translator("bed")

bed = {}

-- Per-user data table

bed.userdata = {}
bed.userdata.saved = {}
bed.userdata.temp = {}

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

   if bed.userdata.temp[name].slept
   and not is_bed_node(bed.userdata.temp[name].node_pos) then
      return
   end

   player:set_look_horizontal(bed.userdata.saved[name].spawn_yaw)
   player:set_pos(bed.userdata.saved[name].spawn_pos)

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

   if bed.userdata.saved[name].spawn_pos then
      player:set_pos(bed.userdata.saved[name].spawn_pos)
   end

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

   f:write(minetest.serialize(bed.userdata.saved))

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
      bed.userdata.saved = minetest.deserialize(f:read("*all"))

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

   if not bed.userdata.saved[name] then
      bed.userdata.saved[name] = {
         spawn_yaw = 0,
         spawn_pos = nil,
      }
   end
   bed.userdata.temp[name] = {
         in_bed = false,
         slept = false,
         node_pos = nil,
      }
   delayed_save()
end

-- Respawning player

local function on_respawnplayer(player)
   local name = player:get_player_name()

   if bed.userdata.temp[name] then
      if not bed.userdata.temp[name].slept then
         return
      end

      bed.userdata.temp[name].in_bed = false

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

   local in_bed = {}
   for name, data in pairs(bed.userdata.temp) do
      if data.in_bed then
         local player = minetest.get_player_by_name(name)
         if player then
             table.insert(in_bed, name)
             sleeping_players = sleeping_players + 1
         end
      end
   end
   for p=1, #in_bed do
      local data = bed.userdata.saved[in_bed[p]]
      if data then
          local player = minetest.get_player_by_name(in_bed[p])
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
                  minetest.set_timeofday(0.23)
                  delay_daytime = false

                  local players = minetest.get_connected_players()
                  for _, player in ipairs(players) do
                     if bed.userdata.temp[player:get_player_name()].in_bed then
                        bed.userdata.temp[player:get_player_name()].slept = true
                     end
                  end

                  local msg
                  if #players == 1 then
                      msg = S("You have slept, rise and shine!")
                  else
                      msg = S("Players have slept, rise and shine!")
                  end
                  minetest.chat_send_all(minetest.colorize("#0ff", "*** " .. msg))
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
      _tt_help = S("Use it to sleep and pass the night"),
      drawtype = "nodebox",
      paramtype = "light",
      paramtype2 = "facedir",
      sunlight_propagates = true,
      wield_image = "bed_bed_inventory.png",
      inventory_image = "bed_bed_inventory.png",
      tiles = {"bed_foot.png", "default_wood.png", "bed_side.png"},
      groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 1},
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

      on_place = function(itemstack, placer, pointed_thing)
              local under = pointed_thing.under

              -- Use pointed node's on_rightclick function first, if present
              local node = minetest.get_node(under)
              if placer and not placer:get_player_control().sneak then
                     if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                            return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
                     end
              end

              local pos
              local undername = minetest.get_node(under).name
              if minetest.registered_items[undername] and minetest.registered_items[undername].buildable_to then
                     pos = under
              else
                     pos = pointed_thing.above
              end

              if minetest.is_protected(pos, placer:get_player_name()) and
                            not minetest.check_player_privs(placer, "protection_bypass") then
                     minetest.record_protection_violation(pos, placer:get_player_name())
                     return itemstack
              end

              local node_def = minetest.registered_nodes[minetest.get_node(pos).name]
              if not node_def or not node_def.buildable_to then
                     return itemstack
              end

              local dir = minetest.dir_to_facedir(placer:get_look_dir())
              local botpos = vector.add(pos, minetest.facedir_to_dir(dir))

              if minetest.is_protected(botpos, placer:get_player_name()) and
                            not minetest.check_player_privs(placer, "protection_bypass") then
                     minetest.record_protection_violation(botpos, placer:get_player_name())
                     return itemstack
              end

              local botdef = minetest.registered_nodes[minetest.get_node(botpos).name]
              if not botdef or not botdef.buildable_to then
                     return itemstack
              end

              minetest.set_node(pos, {name = "bed:bed_foot", param2 = dir})
              minetest.set_node(botpos, {name = "bed:bed_head", param2 = dir})

              if not minetest.settings:get_bool("creative_mode") then
                     itemstack:take_item()
              end
              return itemstack
       end,

      on_destruct = function(pos)
         local meta = minetest.get_meta(pos)
         local name = meta:get_string("player")
         local player = minetest.get_player_by_name(name)
         if name ~= "" and player then
            bed.userdata.temp[name].in_bed = false
            take_player_from_bed(player)
         end

         local node = minetest.get_node(pos)
         local dir = minetest.facedir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         if minetest.get_node(head_pos).name == "bed:bed_head" then
            minetest.remove_node(head_pos)
         end
      end,

      on_rightclick = function(pos, node, clicker, itemstack)
         if not clicker:is_player() then
            return itemstack
         end

         local name = clicker:get_player_name()
         local meta = minetest.get_meta(pos)
         local put_pos = vector.add(pos, vector.divide(minetest.facedir_to_dir(node.param2), 2))

         -- Clear player if player is not online
         local playername_in_bed = meta:get_string("player")
         if playername_in_bed ~= "" then
             local player_in_bed = minetest.get_player_by_name(playername_in_bed)
             if not player_in_bed then
                 meta:set_string("player", "")
             end
         end

         if name == meta:get_string("player") then
            bed.userdata.temp[name].in_bed = false

            take_player_from_bed(clicker)

            meta:set_string("player", "")
         elseif meta:get_string("player") == "" and not default.player_attached[name]
         and bed.userdata.temp[name].in_bed == false then
            if not minetest.settings:get_bool("bed_enable", true) then
               minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Sleeping is disabled.")))
               return itemstack
            end

            local dir = minetest.facedir_to_dir(node.param2)
            local above_posses = {
                {x=pos.x, y=pos.y+1, z=pos.z},
                vector.add({x=pos.x, y=pos.y+1, z=pos.z}, dir),
                {x=pos.x, y=pos.y+2, z=pos.z},
                vector.add({x=pos.x, y=pos.y+2, z=pos.z}, dir),
            }
            for a=1,#above_posses do
                local apos = above_posses[a]
                local anode = minetest.get_node(apos)
                local adef = minetest.registered_nodes[anode.name]
                if adef.walkable then
                    minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Not enough space to sleep!")))
                    return itemstack
                end
            end

            -- No sleeping while moving
            if vector.length(clicker:get_player_velocity()) > 0.001 then
               minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("You have to stop moving before going to bed!")))
               return itemstack
            end

            put_pos.y = put_pos.y + 0.6

            local yaw = 0

            if node.param2 ~= 2 then
               yaw = (node.param2 / 2.0) * math.pi
            end

            bed.userdata.temp[name].in_bed = true

            bed.userdata.saved[name].spawn_yaw = yaw
            bed.userdata.saved[name].spawn_pos = put_pos

            bed.userdata.temp[name].node_pos = pos

            put_player_in_bed(clicker)

            meta:set_string("player", name)
         end
         return itemstack
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
      diggable = false,
      tiles = {"bed_head.png", "default_wood.png", "bed_side.png"},
      groups = {snappy = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 3},
      sounds = default.node_sound_wood_defaults(),
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 0.5}
      },
      on_blast = function() end,
      drop = "",
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
      },
      save = false,
      icon = "bed_effect.png",
})

-- Achievements

achievements.register_achievement(
   "bedtime",
   {
      title = S("Bed Time"),
      description = S("Craft a bed."),
      times = 1,
      craftitem = "bed:bed_foot",
})

minetest.register_lbm({
   label = "Reset beds",
   name = "bed:reset_beds",
   nodenames = {"bed:bed_foot"},
   run_at_every_load = true,
   action = function(pos, node)
      local meta = minetest.get_meta(pos)
      meta:set_string("player", "")
   end,
})

default.log("mod:bed", "loaded")
