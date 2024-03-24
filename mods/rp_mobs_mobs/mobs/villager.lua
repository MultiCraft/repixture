-- Villager

local S = minetest.get_translator("rp_mobs_mobs")

-- How many different trades a villager offers
local TRADES_COUNT = 4
-- Time after which to heal 1 HP (in seconds)
local HEAL_TIME = 7.0
-- Time it takes for villager to forget being mad at player
local ANGRY_COOLDOWN_TIME = 60.0
-- View range for hostilities
local VIEW_RANGE = 16
-- Maximum jump height
local MAX_JUMP = 1
-- Maximum tolerated drop
local MAX_DROP = 4
-- Villager wants to stay this close to their home bed at all times
local HOME_BED_DISTANCE = 32
-- 'searchdistance' argument for minetest.find_path for pathfinding towards bed
local HOME_BED_PATHFIND_DISTANCE = 8
-- If villager is at least this many nodes away from home bed, it will be forgotten
local MAX_HOME_BED_DISTANCE = 48
-- Maximum distance to look for work
local WORK_DISTANCE = 24
-- Time in seconds it takes for villager to forget home bed
local HOME_BED_FORGET_TIME = 10.0
-- How fast to walk
local WALK_SPEED = 2
-- How strong to jump
local JUMP_STRENGTH = 6
-- Time the mob idles around
local IDLE_TIME = 3.0

-- Load villager speech functions

local villager_speech = dofile(minetest.get_modpath("rp_mobs_mobs").."/mobs/villager_speech.lua")

-- Returns a string for the phase of the day.
-- Possible values: "day", "night"
local get_day_phase = function()
	local tod = minetest.get_timeofday()
	if tod < 0.25 or tod > 0.75 then
		return "night"
	else
		return "day"
	end
end

local villager_types = {
	{ "farmer", S("Farmer") },
	{ "tavernkeeper", S("Tavern Keeper") },
	{ "blacksmith", S("Blacksmith") },
	{ "butcher", S("Butcher") },
	{ "carpenter", S("Carpenter") },
}

-- Advanced pathfinder that finds a path between two positions.
-- Like minetest.find_path, but can also traverse a single door.
-- This is a greedy algorithm so it won't neccessary find the
-- shortest path if there's a door.
-- Arguments are the same as for minetest.find_path.
-- This algorithm performs up to 5 path searches so it is less efficient
-- than calling minetest.find_path.
--
-- Returns: list of paths on success, nil on failure.
local find_path_advanced = function(pos1, pos2, searchdistance, max_jump, max_drop)
	local algorithm = "A*_noprefetch"
	-- First check if we can find a direct path
	local path = minetest.find_path(pos1, pos2, searchdistance, max_jump, max_drop, algorithm)
	if path then
		return { path }
	end
	local doorarea_min = vector.add(pos2, vector.new(-12, -6, -12))
	local doorarea_max = vector.add(pos2, vector.new(12, 6, 12))
	local doors = minetest.find_nodes_in_area(doorarea_min, doorarea_max, {"group:door"})
	if #doors == 0 then
		return nil
	end
	-- Door neighbors
	local neighbors = {
		{ vector.new(-1,0,0), vector.new(1,0,0) }, -- X neighbors
		{ vector.new(0,0,-1), vector.new(0,0,1) }, -- Z neighbors
	}
	-- Splits contains a list of positions where the path is
	-- "split" by a door that is in the way.
	local splits = {}
	for d=1, #doors do
		local doorpos = doors[d]
		local node = minetest.get_node(doorpos)
		-- Look at bottom door segments only
		if minetest.get_item_group(node.name, "door_position") == 1 then
			-- Check if node below door is walkable
			local below = vector.offset(doorpos, 0, -1, 0)
			local bnode = minetest.get_node(below)
			local bdef = minetest.registered_nodes[bnode.name]
			if bdef and bdef.walkable then
				-- Check if 2 sides of the door are clear,
				-- either both on the X axis or both on the Z axis.
				-- These sides will become the start and end
				-- points of the following pathfindings.
				for n=1, #neighbors do
					local splits_ok = 0
					local new_split = {}
					for s=1, #neighbors[n] do
						local split = neighbors[n][s]
						local spos = vector.add(doorpos, split)
						local snode = minetest.get_node(spos)
						local sdef = minetest.registered_nodes[snode.name]
						-- Non-walkable and non-damaging = "clear" to walk
						if sdef and not sdef.walkable and sdef.damage_per_second <= 0 then
							splits_ok = splits_ok + 1
							table.insert(new_split, spos)
						else
							break
						end
					end
					if splits_ok == 2 then
						-- Add the 2 door neighbor nodes and the door position itself
						table.insert(splits, { new_split[1], doorpos, new_split[2] })
					end
				end
			end
		end
	end

	for s=1, #splits do
		local splitpos1 = splits[s][1]
		local doorpos = splits[s][2]
		local splitpos2 = splits[s][3]
		-- Do a path search from start to the side of the door (splitpos1),
		-- then another path search from the other side (splitpos2) to the goal position.
		local path1 = minetest.find_path(pos1, splitpos1, searchdistance, max_jump, max_drop, algorithm)
		if path1 then
			local path2 = minetest.find_path(splitpos2, pos2, searchdistance, max_jump, max_drop, algorithm)
			if path2 then
				-- Both paths found. Return them
				return { path1, path2 }
			end
		end
		-- On failure, try it again but do it from start to the *other* side of the door (splitpos2) first.
		local path3 = minetest.find_path(pos1, splitpos2, searchdistance, max_jump, max_drop, algorithm)
		if path3 then
			local path4 = minetest.find_path(splitpos1, splitpos2, searchdistance, max_jump, max_drop, algorithm)
			if path4 then
				return { path3, path4 }
			end
		end
	end
end

local find_free_horizontal_neighbor = function(pos)
	local neighbors = {
		vector.new(-1,0,0),
		vector.new(1,0,0),
		vector.new(0,0,-1),
		vector.new(0,0,1),
	}
	local possible = {}
	for n=1,#neighbors do
		local npos = vector.add(pos, neighbors[n])
		local nnode = minetest.get_node(npos)
		local ndef = minetest.registered_nodes[nnode.name]
		local bpos = vector.offset(npos, 0, -1, 0)
		local bnode = minetest.get_node(bpos)
		local bdef = minetest.registered_nodes[bnode.name]
		if ndef and not ndef.walkable and ndef.drowning == 0 and ndef.damage_per_second <= 0 and bdef and bdef.walkable then
			table.insert(possible, npos)
		end
	end
	if #possible > 0 then
		local r = math.random(1, #possible)
		return possible[r]
	end
	return nil
end

local find_reachable_node = function(startpos, nodenames, searchdistance, under_air)
	local offset = vector.new(searchdistance, searchdistance, searchdistance)
	local smin = vector.subtract(startpos, offset)
	local smax = vector.add(startpos, offset)
	local nodes
	if under_air then
		nodes = minetest.find_nodes_in_area_under_air(smin, smax, nodenames)
	else
		nodes = minetest.find_nodes_in_area(smin, smax, nodenames)
	end
	while #nodes > 0 do
		local r = math.random(1, #nodes)
		local npos = nodes[r]
		local searchpos
		local nnode = minetest.get_node(nodes[r])
		local ndef = minetest.registered_nodes[nnode.name]
		local look_for_neighbor = ndef.walkable == true or minetest.get_item_group(nnode.name, "bonfire") == 1
		if look_for_neighbor then
			searchpos = find_free_horizontal_neighbor(npos)
		else
			searchpos = npos
		end
		if searchpos then
			local path_to_node = find_path_advanced(startpos, searchpos, searchdistance, MAX_JUMP, MAX_DROP)
			if path_to_node then
				return npos, path_to_node
			end
		end
		table.remove(nodes, r)
	end
end

local microtask_find_new_home_bed = rp_mobs.create_microtask({
	label = "find new home bed",
	singlestep = true,
	on_step = function(self, mob)
		if mob._custom_state.home_bed then
			if bed.is_valid_bed(mob._custom_state.home_bed) then
				return
			else
				mob._custom_state.home_bed = nil
				local mobpos = mob.object:get_pos()
				minetest.log("action", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mobpos, 1).." lost their home bed")
			end
		end
		local mobpos = mob.object:get_pos()
		if not mobpos then
			return
		end
		local bedpos = find_reachable_node(mobpos, { "group:bed" }, MAX_HOME_BED_DISTANCE, true)
		if bedpos then
			mob._custom_state.home_bed = bedpos
			minetest.log("action", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mobpos, 1).." found new home bed at "..minetest.pos_to_string(bedpos))
		end
	end,
})

local movement_decider = function(task_queue, mob)
	local task_stand = rp_mobs.create_task({label="stand still"})
	local yaw = math.random(0, 360) / 360 * (math.pi*2)
	local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
	rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR), task_stand)
	rp_mobs.add_microtask_to_task(mob, mt_yaw, task_stand)
	local mt_sleep = rp_mobs.microtasks.sleep(IDLE_TIME)
	mt_sleep.start_animation = "idle"
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task_stand)
	rp_mobs.add_task_to_task_queue(task_queue, task_stand)

	local task_find_new_home_bed = rp_mobs.create_task({label="find new home bed"})
	rp_mobs.add_microtask_to_task(mob, microtask_find_new_home_bed, task_find_new_home_bed)
	rp_mobs.add_task_to_task_queue(task_queue, task_find_new_home_bed)

	local day_phase = get_day_phase()
	if day_phase == "night" then
		-- Go to home bed at night
		if mob._custom_state.home_bed then
			local mobpos = mob.object:get_pos()
			local searchpos = find_free_horizontal_neighbor(mob._custom_state.home_bed)
			local pathlist_to_bed = find_path_advanced(mobpos, searchpos, HOME_BED_PATHFIND_DISTANCE, MAX_JUMP, MAX_DROP)
			if pathlist_to_bed then
				local path = pathlist_to_bed[1]
				local target = path[#path]
				local mt_walk_to_bed = rp_mobs.microtasks.pathfind_and_walk_to(target, WALK_SPEED, JUMP_STRENGTH, true, HOME_BED_PATHFIND_DISTANCE, MAX_JUMP, MAX_DROP)
				mt_walk_to_bed.start_animation = "walk"
				local task_walk_to_bed = rp_mobs.create_task({label="walk to bed"})
				rp_mobs.add_microtask_to_task(mob, mt_walk_to_bed, task_walk_to_bed)
				rp_mobs.add_task_to_task_queue(task_queue, task_walk_to_bed)
			end
		end
	elseif day_phase == "day" then
		local r = math.random(1, 2)
		local profession = mob.name
		local targetnodes
		local under_air = true
		if r == 1 then
			-- profession
			if profession == "rp_mobs_mobs:villager_farmer" then
				local a = math.random(1, 2)
				if a == 1 then
					targetnodes = { "group:farming_plant" }
					under_air = true
				else
					targetnodes = { "rp_default:papyrus" }
					under_air = false
				end
			elseif profession == "rp_mobs_mobs:villager_blacksmith" then
				targetnodes = { "group:furnace" }
				under_air = false
			elseif profession == "rp_mobs_mobs:villager_tavernkeeper" then
				targetnodes = { "group:bucket", "rp_decor:barrel" }
				under_air = false
			elseif profession == "rp_mobs_mobs:villager_butcher" then
				targetnodes = { "group:tree", "rp_jewels:bench" }
				under_air = true
			elseif profession == "rp_mobs_mobs:villager_carpenter" then
				targetnodes = { "rp_default:bookshelf" }
				under_air = false
			end
		else
			-- recreational
			local a = math.random(1, 4)
			if a == 1 then
				targetnodes = { "group:bonfire" }
				under_air = true
			else
				targetnodes = { "group:bookshelf", "group:chest", "rp_itemshow:showcase" }
				under_air = false
			end
		end

		if targetnodes then
			-- Go to workplace/recreational node at day
			local mobpos = mob.object:get_pos()
			local targetpos, pathlist_to_target = find_reachable_node(mobpos, targetnodes, WORK_DISTANCE, under_air)
			if targetpos and pathlist_to_target then
				local path = pathlist_to_target[1]
				local target = path[#path]
				local mt_walk_to_target = rp_mobs.microtasks.pathfind_and_walk_to(target, WALK_SPEED, JUMP_STRENGTH, true, WORK_DISTANCE, MAX_JUMP, MAX_DROP)
				mt_walk_to_target.start_animation = "walk"
				local task_walk_to_target = rp_mobs.create_task({label="walk to recreation/workplace"})
				rp_mobs.add_microtask_to_task(mob, mt_walk_to_target, task_walk_to_target)
				rp_mobs.add_task_to_task_queue(task_queue, task_walk_to_target)
			end
		end
	end
end

local heal_decider = function(task_queue, mob)
	local mt_heal = rp_mobs.create_microtask({
		label = "regenerate health",
		on_start = function(self, mob)
			mob._custom_state.healing_timer = 0
		end,
		on_step = function(self, mob, dtime)
			-- Slowly heal over time
			mob._custom_state.healing_timer = mob._custom_state.healing_timer + dtime
			if mob._custom_state.healing_timer >= HEAL_TIME then
				rp_mobs.heal(mob, 1)
				mob._custom_state.healing_timer = 0
			end
		end,
		is_finished = function()
			return false
		end,
	})
	local task = rp_mobs.create_task({label="regenerate health"})
	rp_mobs.add_microtask_to_task(mob, mt_heal, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

local set_random_textures = function(mob)
	local r = math.random(1, 6)
	local tex = { "mobs_villager"..r..".png" }
	mob.object:set_properties({
		textures = tex,
	})
	mob._textures_adult = tex
end

for _, villager_type_table in pairs(villager_types) do
	local villager_type = villager_type_table[1]
	local villager_name = villager_type_table[2]

	rp_mobs.register_mob("rp_mobs_mobs:villager_"..villager_type, {
		description = villager_name,
		tags = { peaceful = 1 },
		drops = {
			{ name = "rp_default:planks_oak", chance = 1, min = 1, max = 3 },
			{ name = "rp_default:apple", chance = 2, min = 1, max = 2 },
			{ name = "rp_default:axe_stone", chance = 5, min = 1, max = 1 },
		},
		animations = {
			["idle"] = { frame_range = { x = 0, y = 79 }, default_frame_speed = 30 },
			["dead_static"] = { frame_range = { x = 0, y = 0 } },
			["walk"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
			["run"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
			["punch"] = { frame_range = { x = 200, y = 219 }, default_frame_speed = 30 },
		},
		front_body_point = vector.new(0, -0.6, 0.2),
		dead_y_offset = 0.6,
		default_sounds = {
			damage = "default_punch",
			death = "default_punch",
		},
		entity_definition = {
			initial_properties = {
				hp_max = 20,
				physical = true,
				collisionbox = { -0.35, -1.0, -0.35, 0.35, 0.77, 0.35},
				selectionbox = { -0.32, -1.0, -0.22, 0.32, 0.77, 0.22, rotate=true},
				visual = "mesh",
				mesh = "mobs_villager.b3d",
				-- Texture will be overridden on first spawn
				textures = { "mobs_villager1.png" },
				makes_footstep_sound = true,
				stepheight = 0.6,
			},
			get_staticdata = rp_mobs.get_staticdata_default,
			on_death = rp_mobs.on_death_default,
			on_punch = rp_mobs_mobs.on_punch_make_hostile,
			on_activate = function(self, staticdata)
				rp_mobs.init_mob(self)
				rp_mobs.restore_state(self, staticdata)
				if not self._textures_adult then
					set_random_textures(self)
				else
					self.object:set_properties({textures = self._textures_adult})
				end

				rp_mobs.init_fall_damage(self, true)
				rp_mobs.init_breath(self, true, {
					breath_max = 11,
					drowning_point = vector.new(0, 0.5, 0.1)
				})
				rp_mobs.init_node_damage(self, true, {
					node_damage_points={
						vector.new(0, -0.5, 0),
						vector.new(0, 0.5, 0),
					},
				})

				rp_mobs.init_tasks(self)
				local movement_task_queue = rp_mobs.create_task_queue(movement_decider)
				local heal_task_queue = rp_mobs.create_task_queue(heal_decider)
				rp_mobs.add_task_queue(self, movement_task_queue)
				rp_mobs.add_task_queue(self, heal_task_queue)
				rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(rp_mobs_mobs.create_angry_cooldown_decider(VIEW_RANGE, ANGRY_COOLDOWN_TIME)))

				self._villager_type = villager_type
			end,
			on_step = function(self, dtime, moveresult)
				rp_mobs.handle_dying(self, dtime)
				rp_mobs.scan_environment(self, dtime)
				rp_mobs.handle_environment_damage(self, dtime, moveresult)
				rp_mobs.handle_tasks(self, dtime, moveresult)
			end,
			on_rightclick = function(self, clicker)
				if self._dying then
					return
				end
				local item = clicker:get_wielded_item()
				local name = clicker:get_player_name()

				if self._temp_custom_state.angry_at and self._temp_custom_state.angry_at:is_player() and self._temp_custom_state.angry_at == clicker then
					villager_speech.say_random("hostile", name)
					return
				end

				local villager_type = self._villager_type

				local iname = item:get_name()
				if villager_type ~= "blacksmith" and (minetest.get_item_group(iname, "sword") > 0 or minetest.get_item_group(iname, "spear") > 0) then
					villager_speech.say_random("annoying_weapon", name)
					return
				end

				achievements.trigger_achievement(clicker, "smalltalk")

				local hp = self.object:get_hp()
				local hp_max = self.object:get_properties().hp_max
				do
					-- No trading if low health
					if hp < 5 then
						villager_speech.say_random("hurt", name)
						return
					end

					if not self._trades or not self._trade or not self._trade_index then
						self._trades = {}
						local possible_trades = table.copy(gold.trades[villager_type])
						for t=1, TRADES_COUNT do
							if #possible_trades == 0 then
								break
							end
							local index = util.choice(possible_trades, gold.pr)
							local trade = possible_trades[index]
							table.insert(self._trades, trade)
							table.remove(possible_trades, index)
						end
						self._trade_index = 1
						if not self._trade then
							self._trade = self._trades[self._trade_index]
						end
						minetest.log("action", "[rp_mobs_mobs] Villager trades of villager at "..minetest.pos_to_string(self.object:get_pos(), 1).." initialized")
					end

					if not gold.trade(self._trade, villager_type, clicker, self, self._trade_index, self._trades) then
						-- Good mood: Give hint or funny text
						if hp >= hp_max-7 then
							villager_speech.talk_about_item(villager_type, iname, name)
						elseif hp >= 5 then
							villager_speech.say_random("exhausted", name)
						else
							villager_speech.say_random("hurt", name)
						end
					end
				end
			end,
		},
	})

	rp_mobs.register_mob_item("rp_mobs_mobs:villager_" .. villager_type, "mobs_villager_"..villager_type.."_inventory.png")
end
