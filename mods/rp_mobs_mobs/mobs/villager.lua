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

-- Pathfinder stuff
local is_node_walkable = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def or def.walkable then
		if minetest.get_item_group(node.name, "door") ~= 0 then
			return false
		else
			return true
		end
	else
		return false
	end
end
local is_node_blocking = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def or def.walkable then
		if minetest.get_item_group(node.name, "door") ~= 0 then
			return false
		else
			return true
		end
	elseif def.damage_per_second > 0 then
		return true
	elseif minetest.get_item_group(node.name, "water") ~= 0 then
		return true
	elseif minetest.get_item_group(node.name, "door") ~= 0 then
		return false
	else
		return false
	end
end

local PATHFINDER_SEARCHDISTANCE = 30
local PATHFINDER_TIMEOUT = 1.0
local PATHFINDER_OPTIONS = {
	max_jump = MAX_JUMP,
	max_drop = MAX_DROP,
	climb = false,
	clear_height = 2,
	use_vmanip = false,
	respect_disable_jump = true,
	handler_walkable = is_node_walkable,
	handler_blocking = is_node_blocking,
}


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

local professions = {
	{ "farmer", S("Farmer") },
	{ "tavernkeeper", S("Tavern Keeper") },
	{ "blacksmith", S("Blacksmith") },
	{ "butcher", S("Butcher") },
	{ "carpenter", S("Carpenter") },
}
local professions_keys = {}
for p=1, #professions do
	local profession = professions[p][1]
	professions_keys[profession] = true
end

local profession_exists = function(profession)
	if professions_keys[profession] then
		return true
	else
		return false
	end
end

local set_random_profession = function(mob)
	local p = math.random(1, #professions)
	local profession = professions[p][1]
	mob._custom_state.profession = profession
	minetest.log("action", "[rp_mobs_mobs] Profession of villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).." initialized as: "..tostring(profession))
end

-- Gets profession of villager; also initializes
-- the profession if none set, and re-initializes
-- profession if set to an invalid one
local get_profession = function(mob)
	if mob._custom_state.profession then
		if profession_exists(mob._custom_state.profession) then
			return mob._custom_state.profession
		else
			local old_profession = mob._custom_state.profession
			minetest.log("warning", "[rp_mobs_mobs] Profession of villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).." was invalid ("..tostring(old_profession).."). Re-rolling ...")
			set_random_profession(mob)
			return mob._custom_state.profession
		end
	else
		set_random_profession(mob)
		return mob._custom_state.profession
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
		if ndef and not ndef.walkable and ndef.drowning == 0 and ndef.damage_per_second <= 0 and bdef and bdef.walkable and minetest.get_item_group(bnode.name, "fence") == 0 then
			table.insert(possible, npos)
		end
	end
	if #possible > 0 then
		local r = math.random(1, #possible)
		return possible[r]
	end
	return nil
end

local needs_look_for_neighbor = function(nodename, nodedef)
	if nodedef.walkable then
		return true
	else
		if nodename == "rp_default:papyrus" or minetest.get_item_group(nodename, "bonfire") == 1 then
			return true
		end
	end
	return false
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
		local look_for_neighbor = needs_look_for_neighbor(nnode.name, ndef)
		if look_for_neighbor then
			searchpos = find_free_horizontal_neighbor(npos)
		else
			searchpos = npos
		end
		if searchpos then
			local options = PATHFINDER_OPTIONS
			local timeout = PATHFINDER_TIMEOUT
			local path = rp_pathfinder.find_path(startpos, searchpos, searchdistance, options, timeout)
			if path then
				return npos, path
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

local create_microtask_open_door = function(door_pos)
	return rp_mobs.create_microtask({
		label = "open door",
		singlestep = true,
		on_step = function(self, mob)
			if door.is_open(door_pos) == false then
				door.toggle_door(door_pos)
			end
		end,
	})
end



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
			local target = find_free_horizontal_neighbor(mob._custom_state.home_bed)

			local path = rp_pathfinder.find_path(mobpos, target, PATHFINDER_SEARCHDISTANCE, PATHFINDER_OPTIONS, PATHFINDER_TIMEOUT)
			if path then
				local mt_walk_to_bed = rp_mobs.microtasks.follow_path(path, WALK_SPEED, JUMP_STRENGTH, true)
				mt_walk_to_bed.start_animation = "walk"
				local task_walk_to_bed = rp_mobs.create_task({label="walk to bed"})
				rp_mobs.add_microtask_to_task(mob, mt_walk_to_bed, task_walk_to_bed)
				rp_mobs.add_task_to_task_queue(task_queue, task_walk_to_bed)
			end
		end
	elseif day_phase == "day" then
		local r = math.random(1, 2)
		local profession = mob._custom_state.profession
		local targetnodes
		local under_air = true
		if r == 1 then
			-- profession
			if profession == "farmer" then
				local a = math.random(1, 2)
				if a == 1 then
					targetnodes = { "group:farming_plant" }
					under_air = true
				else
					targetnodes = { "rp_default:papyrus" }
					under_air = false
				end
			elseif profession == "blacksmith" then
				targetnodes = { "group:furnace" }
				under_air = false
			elseif profession == "tavernkeeper" then
				targetnodes = { "group:bucket", "rp_decor:barrel" }
				under_air = false
			elseif profession == "butcher" then
				targetnodes = { "group:tree", "rp_jewels:bench" }
				under_air = true
			elseif profession == "carpenter" then
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
			local targetpos, goals = find_reachable_node(mobpos, targetnodes, WORK_DISTANCE, under_air)
			if targetpos and goals and #goals > 0 then
				local task_walk_to_target = rp_mobs.create_task({label="walk to recreation/workplace"})
				for g=1, #goals do
					local goal = goals[g]
					-- Open door
					if goal.goal_type == "door" then
						local mt_open_door = create_microtask_open_door(goal.pos)
						mt_open_door.start_animation = "idle"
						rp_mobs.add_microtask_to_task(mob, mt_open_door, task_walk_to_target)
					-- Traverse path
					elseif goal.goal_type == "path" then
						local path = goal.path
						local target = path[#path]
						local start = path[1]
						local mt_walk_to_target = rp_mobs.microtasks.pathfind_and_walk_to(start, target, WALK_SPEED, JUMP_STRENGTH, true, WORK_DISTANCE, MAX_JUMP, MAX_DROP)
						mt_walk_to_target.start_animation = "walk"
						rp_mobs.add_microtask_to_task(mob, mt_walk_to_target, task_walk_to_target)
					else
						minetest.log("error", "[rp_mobs_mobs] Villager walk algorithm: Invalid goal_type!")
						return
					end
				end
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

	-- Remember when the mob has chosen its initial textures
	mob._custom_state.textures_chosen = true
end

rp_mobs.register_mob("rp_mobs_mobs:villager", {
	description = S("Villager"),
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
			if not self._custom_state.textures_chosen then
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

			if not self._custom_state.profession then
				set_random_profession(self)
			end
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

			local profession = get_profession(self)

			local iname = item:get_name()
			if profession ~= "blacksmith" and (minetest.get_item_group(iname, "sword") > 0 or minetest.get_item_group(iname, "spear") > 0) then
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
					local possible_trades = table.copy(gold.trades[profession])
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

				if not gold.trade(self._trade, profession, clicker, self, self._trade_index, self._trades) then
					-- Good mood: Give hint or funny text
					if hp >= hp_max-7 then
						villager_speech.talk_about_item(profession, iname, name)
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

rp_mobs.register_mob_item("rp_mobs_mobs:villager", "mobs_villager_farmer_inventory.png")
