
--
-- Bed mod
--

local S = minetest.get_translator("rp_bed")

bed = {}

local DEFAULT_BED_COLOR = rp_paint.COLOR_AZURE_BLUE

-- Per-user data table

local bed_userdata = {}
bed_userdata.saved = {}
bed_userdata.temp = {}

-- List of occupied beds, indexed by node position hash
local occupied_beds = {}

-- Returns <spawn position> of `player` or
-- nil if if there is no spawn active
bed.get_spawn = function(player)
   local name = player:get_player_name()
   local spawn
   if bed_userdata.saved[name].spawn_pos then
      spawn = bed_userdata.saved[name].spawn_pos
   end
   return spawn
end

-- Sets the bed spawn position for `player`.
-- Returns true if spawn position was set and changed.
-- Returns false if spawn position was not changed because
-- it's already used by the player.
bed.set_spawn = function(player, spawn_pos)
   local name = player:get_player_name()
   local old_spawn_pos = bed_userdata.saved[name].spawn_pos
   if old_spawn_pos and vector.equals(spawn_pos, old_spawn_pos) then
      return false
   end
   bed_userdata.saved[name].spawn_pos = table.copy(spawn_pos)
   minetest.log("action", "[rp_bed] Respawn position of "..name.." set to "..minetest.pos_to_string(spawn_pos, 1))
   return true
end

-- Unsets the bed spawn position of `player`
bed.unset_spawn = function(player)
   local name = player:get_player_name()
   bed_userdata.saved[name].spawn_pos = nil
end

-- Returns true if pos has a valid bed
bed.is_valid_bed = function(pos)
   local node = minetest.get_node(pos)
   local dir = minetest.fourdir_to_dir(node.param2)
   if node.name == "rp_bed:bed_head" then
      local neighbor = vector.subtract(pos, dir)
      local nnode = minetest.get_node(neighbor)
      if nnode.name == "rp_bed:bed_foot" and nnode.param2 == node.param2 then
         return true
      end
   elseif node.name == "rp_bed:bed_foot" then
      local neighbor = vector.add(pos, dir)
      local nnode = minetest.get_node(neighbor)
      if nnode.name == "rp_bed:bed_head" and nnode.param2 == node.param2 then
         return true
      end
   end
   return false
end

bed.get_bed_segment = function(pos, node, segment)
   local dir = minetest.fourdir_to_dir(node.param2)
   if node.name == "rp_bed:bed_head" then
      if segment == "head" then
         return pos
      elseif segment == "foot" or segment == "other" then
         return vector.subtract(pos, dir)
      end
   elseif node.name == "rp_bed:bed_foot" then
      if segment == "head" or segment == "other" then
         return vector.add(pos, dir)
      elseif segment == "foot" then
         return pos
      end
   else
      return nil
   end
end

-- Savefile

local bed_file = minetest.get_worldpath() .. "/bed.dat"
local saving = false

-- Timer

local TIMER_INTERVAL = 1
local timer = 0

local delay_daytime = false

local function is_bed_node(pos)
   if pos == nil then
      return false
   end

   local node = minetest.get_node(pos)

   if node.name == "rp_bed:bed_foot" then
      return true
   end

   return false
end

-- Returns name of player in bed at pos or nil if not occupied
local function get_player_in_bed(pos)
	local hash = minetest.hash_node_position(pos)
	local playername = occupied_beds[hash]
	return playername
end
-- Assign a player to the bed at pos.
-- If playername==nil, bed will be unassigned.
local function set_bed_occupier(pos, playername)
	local hash = minetest.hash_node_position(pos)
	occupied_beds[hash] = playername
end

local function put_player_in_bed(player)
   if player == nil then
      return
   end

   local name = player:get_player_name()

   if not is_bed_node(bed_userdata.temp[name].node_pos) then
      return
   end

   player:set_pos(bed_userdata.temp[name].sleep_pos)

   player_effects.apply_effect(player, "inbed")

   rp_player.player_attached[name] = true
   rp_player.player_set_animation(player, "lay")

   minetest.log("action", "[rp_bed] "..name.." was put into bed")
end

local function clear_bed_status(player)
   if player == nil then
      return
   end
   local name = player:get_player_name()

   bed_userdata.temp[name].in_bed = false
   if bed_userdata.temp[name].node_pos then
      set_bed_occupier(bed_userdata.temp[name].node_pos, nil)
   end
   bed_userdata.temp[name].node_pos = nil

   player_effects.remove_effect(player, "inbed")

   rp_player.player_attached[name] = false
   rp_player.player_set_animation(player, "stand")
end

local function take_player_from_bed(player)
   if player == nil then
      return
   end
   local name = player:get_player_name()

   local was_in_bed = bed_userdata.temp[name].in_bed == true
   if was_in_bed then
      minetest.log("action", "[rp_bed] "..name.." was taken from bed")
   end
   local spawn_pos = bed.get_spawn(player)
   if spawn_pos then
      player:set_pos(spawn_pos)
   end

   clear_bed_status(player)
end

local function save_bed()
   local f = io.open(bed_file, "w")

   f:write(minetest.serialize(bed_userdata.saved))

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
      bed_userdata.saved = minetest.deserialize(f:read("*all"), true)

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

   if not bed_userdata.saved[name] then
      bed_userdata.saved[name] = {
         spawn_pos = nil,
      }
   end
   bed_userdata.temp[name] = {
         in_bed = false,
         node_pos = nil,
	 sleep_pos = nil,
      }
   delayed_save()
end

-- Leaving player

local function on_leaveplayer(player)
   local name = player:get_player_name()
   if bed_userdata.temp[name] then
      bed_userdata.temp[name].in_bed = false
      if bed_userdata.temp[name].node_pos then
         set_bed_occupier(bed_userdata.temp[name].node_pos, nil)
      end
      bed_userdata.temp[name].node_pos = nil
   end
end

-- Returns true if players can spawn into the given node safely.
local function node_is_spawnable_in(node, is_upper)
	-- All non-walkable, non-damaging, non-drowning nodes are safe.
	-- Also the bed as a special case for the lower check.
	if not node then
		return false, "no_node"
	end
	if not is_upper and minetest.get_item_group(node.name, "bed") ~= 0 then
		return true
	end
	local def = minetest.registered_nodes[node.name]
	if not def.walkable and def.drowning <= 0 and def.damage_per_second <= 0 then
		return true
	end
	local fail_reason
	if def.walkable then
		fail_reason = "blocked"
	elseif def.damage_per_second > 0 then
		fail_reason = "damage"
	elseif def.drowning > 0 then
		fail_reason = "drowning"
	else
		fail_reason = "blocked"
	end
	return false, fail_reason
end

-- Returns true if players can spawn on given node safely (without falling).
local function node_is_spawnable_on(node)
	-- All walkable full cube nodes that don't disable jump are accepted
	if not node then
		return false
	end
	local def = minetest.registered_nodes[node.name]
	if def.walkable and
			((def.collision_box == nil and def.node_box == nil) or
			(not def.collision_box and def.node_box and def.node_box.type == "regular") or
			(not def.node_box and def.collision_box and def.collision_box.type == "regular")) and
			(minetest.get_item_group(node.name, "disable_jump") == 0) then
		return true
	end
	return false
end

local respawn_check_posses = {
	vector.new(0, 0, 0 ),
	vector.new(0, 0, -1 ),
	vector.new(0, 0, 1 ),
	vector.new(-1,0, 0 ),
	vector.new(1, 0, 0 ),
	vector.new(-1,0, -1 ),
	vector.new(-1,0, 1 ),
	vector.new(1, 0, -1 ),
	vector.new(1, 0, 1 ),
}

local attempt_bed_respawn = function(player)
	-- Place player on respawn position if set
	local name = player:get_player_name()
	local pos = bed.get_spawn(player)
	if pos then
		-- Load area around spawn pos to make sure
		-- we don't get ignore nodes.
		local load_offset = vector.new(1,1,1)
		local load_min = vector.subtract(pos, load_offset)
		local load_max = vector.add(pos, load_offset)
		minetest.load_area(load_min, load_max)
		-- Check if position is safe, if not, try to spawn to one of the
		-- neighbor blocks
		for n=1, #respawn_check_posses do
			local cpos = vector.add(pos, respawn_check_posses[n])
			local node = minetest.get_node(cpos)
			if node_is_spawnable_in(node, false) then
				local is_bed = minetest.get_item_group(node.name, "bed") ~= 0
				-- Check posses above (must be free)
				-- and below (must be walkable)
				-- If bed, 2 posses must be free above
				local acpos = { x=cpos.x, y=cpos.y+1, z=cpos.z }
				local aacpos = { x=cpos.x, y=cpos.y+2, z=cpos.z }
				local abpos = { x=cpos.x, y=cpos.y-1, z=cpos.z }
				local anode = minetest.get_node(acpos)
				local aanode = minetest.get_node(aacpos)
				local bnode = minetest.get_node(abpos)
				if node_is_spawnable_in(anode, true) and
						((n == 1 and is_bed) or node_is_spawnable_on(bnode)) and
						(not is_bed or node_is_spawnable_in(aanode, true)) then
					local spos = cpos
					if not is_bed then
						spos.y = spos.y - 0.5
					end
					player:set_pos(spos)
					return true
				end
			end
		end
		bed.unset_spawn(player)
		minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Your respawn position was blocked or dangerous. You’ve lost your old respawn position.")))
		return false
	end
	return false
end

local on_respawnplayer = function(player)
	clear_bed_status(player)
	return attempt_bed_respawn(player)
end


local function on_dieplayer(player)
   local name = player:get_player_name()
   if bed_userdata.temp[name] then
      bed_userdata.temp[name].in_bed = false
      if bed_userdata.temp[name].node_pos then
         set_bed_occupier(bed_userdata.temp[name].node_pos, nil)
      end
      bed_userdata.temp[name].node_pos = nil
   end
end

-- Update function

local function on_globalstep(dtime)
   timer = timer + dtime

   local sleeping_players = 0

   -- Count number of sleeping players;
   -- also check for Sneak key
   local in_bed = {}
   for name, data in pairs(bed_userdata.temp) do
      if data.in_bed then
         local player = minetest.get_player_by_name(name)
         if player then
             local ctrl = player:get_player_control()
             -- Get up from bed if holding down Sneak
             if ctrl and ctrl.sneak then
                take_player_from_bed(player)
             -- Count player
             else
                table.insert(in_bed, name)
                sleeping_players = sleeping_players + 1
             end
         end
      end
   end

   -- Reduce load of the following section
   if timer < TIMER_INTERVAL then
      return
   end
   timer = 0

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
                  local msg
                  if #players == 1 then
                      msg = S("You have slept, rise and shine!")
                  else
                      msg = S("Players have slept, rise and shine!")
                  end
                  minetest.chat_send_all(minetest.colorize("#0ff", "*** " .. msg))
                  minetest.log("action", "[rp_bed] Players have slept; the night was skipped")
            end)

            delayed_save()
         end
      end
   end
end

-- Force player to wake up when punched
local function on_punchplayer(player)
	if player:get_hp() <= 0 then
		return
	end
	local name = player:get_player_name()
	if bed_userdata.temp[name].in_bed then
		take_player_from_bed(player)
	end
end

-- Force player to wake up when taking damage
local function on_player_hpchange(player, hp_change)
	if player:get_hp() <= 0 or hp_change >= 0 then
		return
	end
	local name = player:get_player_name()
	if bed_userdata.temp[name].in_bed then
		take_player_from_bed(player)
	end
end

minetest.register_on_mods_loaded(on_load)

minetest.register_on_shutdown(on_shutdown)

minetest.register_on_joinplayer(on_joinplayer)

minetest.register_on_leaveplayer(on_joinplayer)

minetest.register_on_respawnplayer(on_respawnplayer)

minetest.register_on_dieplayer(on_dieplayer)

minetest.register_on_punchplayer(on_punchplayer)

minetest.register_on_player_hpchange(on_player_hpchange)

minetest.register_globalstep(on_globalstep)

-- Nodes

local sounds = rp_sounds.node_sound_planks_defaults({
   footstep = {name="rp_sounds_footstep_fuzzy", gain=0.7},
   dug = {name="rp_sounds_dug_planks", gain=1.0, pitch=0.8},
   place = {name="rp_sounds_place_planks", gain=1.0, pitch=0.8},
})

local on_rightclick_bed_foot = function(pos, node, clicker, itemstack)
	if not clicker:is_player() then
		return itemstack
	end

	local clicker_name = clicker:get_player_name()

	local sleeper_name = get_player_in_bed(pos)

	if clicker_name == sleeper_name then
		take_player_from_bed(clicker)
	elseif sleeper_name == nil and not rp_player.player_attached[clicker_name]
			and bed_userdata.temp[clicker_name].in_bed == false then
		if not minetest.settings:get_bool("bed_enable", true) then
			minetest.chat_send_player(clicker_name, minetest.colorize("#FFFF00", S("Sleeping is disabled.")))
			return itemstack
		end

		local dir = minetest.fourdir_to_dir(node.param2)
		local above_posses = {
			{x=pos.x, y=pos.y+1, z=pos.z},
			vector.add({x=pos.x, y=pos.y+1, z=pos.z}, dir),
			{x=pos.x, y=pos.y+2, z=pos.z},
			vector.add({x=pos.x, y=pos.y+2, z=pos.z}, dir),
			}
		for a=1,#above_posses do
			local apos = above_posses[a]
			local anode = minetest.get_node(apos)
			local is_spawnable, fail_reason = node_is_spawnable_in(anode, true)
			if not is_spawnable then
				local msg
				if fail_reason == "damage" then
					msg = S("It’s too painful to sleep here!")
				elseif fail_reason == "drowning" then
					msg = S("You can’t sleep while holding your breath!")
				elseif fail_reason == "blocked" then
					msg = S("Not enough space to sleep!")
				else
					msg = S("You can’t sleep here!")
				end
				minetest.chat_send_player(clicker_name, minetest.colorize("#FFFF00", msg))
				return itemstack
			end
		end

		-- No sleeping while moving
		if vector.length(clicker:get_velocity()) > 0.001 then
			minetest.chat_send_player(clicker_name, minetest.colorize("#FFFF00", S("You have to stop moving before going to bed!")))
			return itemstack
		end

		local put_pos = table.copy(pos)

		local yaw = (-(node.param2 / 2.0) * math.pi) + math.pi

		bed_userdata.temp[clicker_name].in_bed = true

		local changed = bed.set_spawn(clicker, put_pos)
		if changed then
			minetest.chat_send_player(clicker_name, minetest.colorize("#00FFFF", S("Respawn position set!")))
		end

		bed_userdata.temp[clicker_name].node_pos = pos
		-- Put player slightly away from the bed middle
		local sleep_pos = vector.add(pos, vector.multiply(minetest.fourdir_to_dir(node.param2), 0.49))
		-- Increase player Y to reach exact position of bed top
		sleep_pos = vector.offset(sleep_pos, 0, 0.125, 0)
		bed_userdata.temp[clicker_name].sleep_pos = sleep_pos

		set_bed_occupier(pos, clicker_name)

		put_player_in_bed(clicker)
	end
	return itemstack
end

local function drop_bed(pos, player)
	local item = ItemStack("rp_bed:bed_foot")
	if player and player:is_player() and minetest.is_creative_enabled(player:get_player_name()) then
		local inv = player:get_inventory()
		if not inv:contains_item("main", item) then
			inv:add_item("main", item)
		end
	else
		minetest.add_item(pos, item)
	end
end

minetest.register_node(
   "rp_bed:bed_foot",
   {
      description = S("Bed"),
      _tt_help = S("Sets the respawn position and allows to pass the night"),
      drawtype = "nodebox",
      paramtype = "light",
      paramtype2 = "color4dir",
      palette = "bed_palette.png",
      sunlight_propagates = true,
      wield_image = "bed_bed_inventory.png",
      inventory_image = "bed_bed_inventory.png",
      tiles = {
         "bed_foot.png",
	 {name="default_wood.png",color="white"},
	 "bed_side_l.png",
	 "bed_side_r.png",
	 "bed_inside.png",
	 "bed_back.png",
      },
      overlay_tiles = {
         {name="bed_foot_overlay.png",color="white"},
         "",
         {name="bed_side_l_overlay.png",color="white"},
         {name="bed_side_r_overlay.png",color="white"},
         {name="bed_inside_overlay.png",color="white"},
         {name="bed_back_overlay.png",color="white"},
      },
      use_texture_alpha = "clip",
      groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 1, fall_damage_add_percent = -15, creative_decoblock = 1, interactive_node = 1, paintable = 1, furniture = 1, pathfinder_soft = 1},
      is_ground_content = false,
      sounds = sounds,
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 0.5}
      },

      node_placement_prediction = "",
      on_rightclick = function(pos, node, clicker, itemstack)
         local dir = minetest.fourdir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         local head_node = minetest.get_node(head_pos)
         -- Make sure the bed is complete
         if head_node.name == "rp_bed:bed_head" then
            return on_rightclick_bed_foot(pos, node, clicker, itemstack)
         end
         return itemstack
      end,

      on_place = function(itemstack, placer, pointed_thing)
              local under = pointed_thing.under

              -- Use pointed node's on_rightclick function first, if present
              local node = minetest.get_node(under)
              if placer and not placer:get_player_control().sneak then
                     if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                            return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing) or itemstack
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
                     rp_sounds.play_place_failed_sound(placer)
                     return itemstack
              end

              local dir = minetest.dir_to_fourdir(placer:get_look_dir())
              local botpos = vector.add(pos, minetest.fourdir_to_dir(dir))

              if minetest.is_protected(botpos, placer:get_player_name()) and
                            not minetest.check_player_privs(placer, "protection_bypass") then
                     minetest.record_protection_violation(botpos, placer:get_player_name())
                     return itemstack
              end

              local bot = minetest.get_node(botpos)
              local botdef = minetest.registered_nodes[bot.name]
              -- Check if the 2nd node for the bed is free to build to
              if not botdef or not botdef.buildable_to then
                     rp_sounds.play_place_failed_sound(placer)
                     return itemstack
              end

              local param2 = dir + (DEFAULT_BED_COLOR - 1) * 4

              local footnode = {name = "rp_bed:bed_foot", param2 = param2}
              local headnode = {name = "rp_bed:bed_head", param2 = param2}
              minetest.set_node(pos, footnode)
              minetest.set_node(botpos, headnode)
              rp_sounds.play_node_sound(pos, footnode, "place")

              if not minetest.is_creative_enabled(placer:get_player_name()) then
                     itemstack:take_item()
              end
              return itemstack
       end,

      on_destruct = function(pos)
	 local player_name = get_player_in_bed(pos)
         if player_name then
            local player = minetest.get_player_by_name(player_name)
            take_player_from_bed(player)
         end

	 set_bed_occupier(pos, nil)
      end,
      after_destruct = function(pos, oldnode)
         local dir = minetest.fourdir_to_dir(oldnode.param2)
         local head_pos = vector.add(pos, dir)
         if minetest.get_node(head_pos).name == "rp_bed:bed_head" then
            minetest.remove_node(head_pos)
            minetest.check_for_falling({x=head_pos.x, y=head_pos.y+1, z=head_pos.z})
         end
      end,
      on_blast = function(pos)
         -- Needed to force on_destruct/after_destruct to be called
         minetest.remove_node(pos)
         minetest.check_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
      end,

      -- Can be dug if no sleeper or digger equals sleeper
      can_dig = function(pos, digger)
         local sleeper_name = get_player_in_bed(pos)
         if not sleeper_name then
            return true
         end
         local sleeper = minetest.get_player_by_name(sleeper_name)
         if (not digger) or (not sleeper) or (digger and digger:is_player() and sleeper == digger) then
            return true
         end
         return false
      end,

      on_dig = function(pos, node, digger)
         -- Drop bed if neccessary
         local dir = minetest.fourdir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         if minetest.get_node(head_pos).name == "rp_bed:bed_head" then
            drop_bed(pos, digger)
         end
         return minetest.node_dig(pos, node, digger)
      end,



      -- Paint support for rp_paint mod
      _on_paint = function(pos, new_param2)
         local node = minetest.get_node(pos)
         local dir = minetest.fourdir_to_dir(node.param2)
         local head_pos = vector.add(pos, dir)
         if minetest.get_node(head_pos).name == "rp_bed:bed_head" then
            minetest.swap_node(head_pos, {name = "rp_bed:bed_head", param2=new_param2})
         end
         return true
      end,
      _rp_blast_resistance = 1,

      -- Drop is handled in on_dig
      drop = "",
})

minetest.register_node(
   "rp_bed:bed_head",
   {
      drawtype = "nodebox",
      paramtype = "light",
      paramtype2 = "color4dir",
      palette = "bed_palette.png",
      is_ground_content = false,

      tiles = {
         "bed_head.png",
	 {name="default_wood.png",color="white"},
	 "bed_side_r.png",
	 "bed_side_l.png",
	 "bed_front.png",
	 "bed_inside.png",
      },
      overlay_tiles = {
         {name="bed_head_overlay.png",color="white"},
         "",
         {name="bed_side_r_overlay.png",color="white"},
         {name="bed_side_l_overlay.png",color="white"},
         {name="bed_front_overlay.png",color="white"},
         {name="bed_inside_overlay.png",color="white"},
      },
      use_texture_alpha = "clip",
      groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 3, bed = 1, fall_damage_add_percent = -15, not_in_creative_inventory = 1, paintable = 1, furniture = 1, pathfinder_soft = 1 },
      sounds = sounds,
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 2/16, 0.5}
      },

      on_rightclick = function(pos, node, clicker, itemstack)
         local dir = minetest.fourdir_to_dir(node.param2)
         local foot_pos = vector.subtract(pos, dir)
         local foot_node = minetest.get_node(foot_pos)
         if foot_node.name == "rp_bed:bed_foot" then
            return on_rightclick_bed_foot(foot_pos, foot_node, clicker, itemstack)
         end
         return itemstack
      end,

      after_destruct = function(pos, oldnode)
         local dir = minetest.fourdir_to_dir(oldnode.param2)
         local foot_pos = vector.subtract(pos, dir)
         if minetest.get_node(foot_pos).name == "rp_bed:bed_foot" then
            minetest.remove_node(foot_pos)
         end
      end,

     on_blast = function(pos)
         -- Needed to force after_destruct to be called
         minetest.remove_node(pos)
         minetest.check_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
      end,

      -- Can be dug if no sleeper or digger equaals sleeper
      can_dig = function(pos, digger)
         local node = minetest.get_node(pos)
         local dir = minetest.fourdir_to_dir(node.param2)
         local foot_pos = vector.subtract(pos, dir)
	 local sleeper_name = get_player_in_bed(foot_pos)
         if not sleeper_name then
            return true
         end
         local sleeper = minetest.get_player_by_name(sleeper_name)
         if (not digger) or (not sleeper) or (digger and digger:is_player() and sleeper == digger) then
            return true
         end
         if sleeper and sleeper:is_player() and digger and digger:is_player() and sleeper == digger then
            return true
         end
         return false
      end,
      on_dig = function(pos, node, digger)
         -- Drop bed if neccessary
         local dir = minetest.fourdir_to_dir(node.param2)
         local foot_pos = vector.subtract(pos, dir)
         if minetest.get_node(foot_pos).name == "rp_bed:bed_foot" then
            drop_bed(foot_pos, digger)
         end
         return minetest.node_dig(pos, node, digger)
      end,

      -- Paint support for rp_paint mod
      _on_paint = function(pos, new_param2)
         local node = minetest.get_node(pos)
         local dir = minetest.fourdir_to_dir(node.param2)
         local foot_pos = vector.subtract(pos, dir)
         if minetest.get_node(foot_pos).name == "rp_bed:bed_foot" then
            minetest.swap_node(foot_pos, {name = "rp_bed:bed_foot", param2=new_param2})
         end
         return true
      end,
      drop = "",
})

minetest.register_alias("rp_bed:bed", "rp_bed:bed_foot")

-- Crafting

crafting.register_craft(
   {
      output = "rp_bed:bed",
      items = {
         "group:fuzzy 3",
         "group:planks 3",
      }
})
minetest.register_craft({
   type = "fuel",
   recipe = "rp_bed:bed_foot",
   burntime = 30,
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
      craftitem = "rp_bed:bed_foot",
      difficulty = 4.1,
})

minetest.register_lbm({
   label = "Clear legacy bed meta and initialize color param2",
   name = "rp_bed:reset_beds_v3_10_0",
   nodenames = {"rp_bed:bed_foot", "rp_bed:bed_head"},
   action = function(pos, node)
      -- Clear meta
      if node.name == "rp_bed:bed_foot" then
         local meta = minetest.get_meta(pos)
         meta:set_string("player", "")
      end

      -- Set default color
      if node.param2 <= 3 then
         node.param2 = node.param2 + (DEFAULT_BED_COLOR - 1) * 4
         minetest.swap_node(pos, node)
      end
   end,
})

-- Aliases
minetest.register_alias("bed:bed", "rp_bed:bed_foot")
minetest.register_alias("bed:bed_foot", "rp_bed:bed_foot")
minetest.register_alias("bed:bed_head", "rp_bed:bed_head")
