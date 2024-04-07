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
-- Time in second to check the home bed again
local HOME_BED_RECHECK_TIME = 6.0
-- Radius within which villagers resolve home bed and worksite conflicts
local SITE_CONFLICT_RESOLVE_RADIUS = 5
-- Range at which villager looks at nearby player
local PLAYER_LOOK_AT_RANGE = 3
-- How fast to walk
local WALK_SPEED = 2
-- How fast to climb
local CLIMB_SPEED = 1
-- How fast to slow down if Y moving fast in climbable/swimmable node
local CLIMB_DRAG = 1
-- How strong to jump
local JUMP_STRENGTH = 4
-- Time the mob idles around
local IDLE_TIME = 3.0
-- Delay between attempting to find new home bed or work site
local FIND_SITE_IDLE_TIME = 6.0
-- How many nodes the villager can be away from nodes and entities to interact with them
local REACH = 4.0
-- Y offset to apply when checking if vertical climb is complete
local CLIMB_CHECK_Y_OFFSET = 0.6
-- Interval in seconds for mob to react to being in danger, blocking node, liquid, ...
local REFLEX_TIME = 0.333
-- Range within to search for safe dry nodes when stuck in liquid
local LIQUID_ESCAPE_RANGE = 6
-- Number of tries to find safe dry nodes when stuck in liquid
local LIQUID_ESCAPE_TRIES = 10

-- Pathfinder stuff

-- For pathfinder: returns true if node can be walked *on*
local is_node_walkable = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def then
		-- Unknown nodes are walkable
		return true
	elseif node.name == "rp_itemshow:frame" then
		-- Item frames are to thin to walk *on*
		return false
	elseif minetest.get_item_group(node.name, "door") ~= 0 then
		-- Same for doors
		return false
	elseif minetest.get_item_group(node.name, "fence") ~= 0 then
		-- We refuse to walk on fences (although we could)
		-- because it looks weird.
		return false
	elseif def.walkable then
		-- Walkable by definition
		return true
	else
		return false
	end
end

-- For pathfinder: returns true if node is blocking the path
local is_node_blocking = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def then
		-- Unknown nodes are blocking
		return true
	elseif minetest.get_item_group(node.name, "door") ~= 0 then
		-- Villagers know how to open doors so they pathfind through them
		return false
	elseif def.damage_per_second > 0 then
		-- No damage allowed
		return true
	elseif minetest.get_item_group(node.name, "water") ~= 0 then
		-- No water allowed
		return true
	elseif def.walkable then
		-- Walkable by definition = blocking
		return true
	else
		return false
	end
end

-- Same as is_node_blocking, but water is OK
local is_node_blocking_water_ok = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def then
		-- Unknown nodes are blocking
		return true
	elseif minetest.get_item_group(node.name, "door") ~= 0 then
		-- Villagers know how to open doors so they pathfind through them
		return false
	elseif def.damage_per_second > 0 then
		-- No damage allowed
		return true
	elseif def.walkable then
		-- Walkable by definition = blocking
		return true
	else
		return false
	end
end

-- Returns true if node is swimmable
local is_node_swimmable = function(node)
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	elseif def.liquid_move_physics == true or (def.liquid_move_physics == nil and def.liquidtype ~= "none") then
		return true
	else
		return false
	end
end

local PATHFINDER_SEARCHDISTANCE = 30
local PATHFINDER_TIMEOUT = 1.0
local PATHFINDER_OPTIONS = {
	max_jump = MAX_JUMP,
	max_drop = MAX_DROP,
	climb = true,
	clear_height = 2,
	use_vmanip = false,
	respect_disable_jump = true,
	handler_walkable = is_node_walkable,
	handler_blocking = is_node_blocking,
	use_vmanip = true,
}


-- Load villager speech functions

local villager_speech = dofile(minetest.get_modpath("rp_mobs_mobs").."/mobs/villager_speech.lua")

-- Returns a string for the phase of the day.
local get_day_phase = function()
	local tod = minetest.get_timeofday()
	-- 0:00 to 5:00
	if tod < 0.20833 then
		return "early_night"
	-- 5:00 to 6:00
	elseif tod < 0.25 then
		return "sunrise"
	-- 6:00 to 8:00
	elseif tod < 0.33333 then
		return "morning"
	-- 8:00 to 12:00
	elseif tod < 0.5 then
		return "forenoon"
	-- 12:00 to 13:00
	elseif tod < 0.54167 then
		return "noon"
	-- 13:00 to 16:30
	elseif tod < 0.6837 then
		return "afternoon"
	-- 16:00 to 18:30
	elseif tod < 0.7708 then
		return "evening"
	-- 18:30 to 19:30
	elseif tod < 0.8125 then
		return "sunset"
	-- 19:30 to 0:00
	else
		return "late_night"
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
	professions_keys[profession] = professions[p][2]
end

local schedules = {}
schedules.farmer = {
	early_night = "sleep",
	morning = "sleep",
	sunrise = "play",
	morning = "work",
	forenoon = "work",
	noon = "play",
	afternoon = "work",
	evening = "work",
	sunset = "play",
	late_night = "sleep",
}
schedules.butcher = schedules.farmer
schedules.carpenter = schedules.farmer
schedules.blacksmith = schedules.farmer
schedules.tavernkeeper = {
	early_night = "sleep",
	morning = "sleep",
	sunrise = "sleep",
	morning = "sleep",
	forenoon = "play",
	noon = "work",
	afternoon = "play",
	evening = "play",
	sunset = "work",
	late_night = "work",
}
schedules.none = {
	early_night = "sleep",
	morning = "sleep",
	sunrise = "sleep",
	morning = "play",
	forenoon = "play",
	noon = "play",
	afternoon = "play",
	evening = "play",
	sunset = "play",
	late_night = "sleep",
}

local worksites = {
	farmer = { "group:farming_plant", true },
	blacksmith = { "group:furnace", false },
	tavernkeeper = { "rp_decor:barrel", false },
	butcher = { "group:furnace", true },
	carpenter = { "rp_default:bookshelf", false },
}

local profession_exists = function(profession)
	if professions_keys[profession] then
		return true
	else
		return false
	end
end

local set_random_textures = function(mob)
	local r = math.random(1, 6)
	local tex_base = "mobs_villager_base_"..r..".png"
	local profession = mob._custom_state.profession or "unemployed"
	local tex_clothes = "mobs_villager_clothes_"..profession..".png"
	local tex = { tex_base .. "^" .. tex_clothes }

	mob.object:set_properties({
		textures = tex,
	})
	mob._textures_adult = tex

	-- Remember when the mob has chosen its initial textures
	mob._custom_state.textures_chosen = true
end

local set_random_profession = function(mob)
	local p = math.random(1, #professions)
	local profession = professions[p][1]
	rp_mobs_mobs.set_villager_profession(mob, profession)
end

-- Set profession of villager mob to the given profession.
-- NOTE: This function must only be called right after the spawning of a villager.
-- Calling it at a later time will change the skin!
rp_mobs_mobs.set_villager_profession = function(mob, profession)
	mob._custom_state.profession = profession
	minetest.log("action", "[rp_mobs_mobs] Profession of villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).." initialized as: "..tostring(profession))

	set_random_textures(mob)
	mob._custom_state.textures_chosen = true
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

find_closest_horizontal_dir = function(pos)
	local modpos = table.copy(pos)
	modpos.x = (modpos.x) % 1
	modpos.z = (modpos.z) % 1
	if (1-math.abs(modpos.x-0.5)) > (1-math.abs(modpos.z-0.5)) then
		if modpos.x < 0.5 then
			return "+x"
		else
			return "-x"
		end
	else
		if modpos.z < 0.5 then
			return "+z"
		else
			return "-z"
		end
	end
end

local find_free_horizontal_neighbor = function(pos, precise)
	local neighbors = {
		{ vector.new(-1,0,0), "-x" },
		{ vector.new(1,0,0), "+x" },
		{ vector.new(0,0,-1), "-z" },
		{ vector.new(0,0,1), "+z" },
	}
	-- Check which neighbors are 'free'
	-- (not blocking, not dangerous, not on air or fence;
	-- 2 nodes space;
	-- on walkable node)
	local possible = {}
	for n=1,#neighbors do
		local npos = vector.add(pos, neighbors[n][1])
		local nnode = minetest.get_node(npos)
		local ndef = minetest.registered_nodes[nnode.name]
		local bpos = vector.offset(npos, 0, -1, 0)
		local bnode = minetest.get_node(bpos)
		local bdef = minetest.registered_nodes[bnode.name]
		local apos = vector.offset(npos, 0, 1, 0)
		local anode = minetest.get_node(apos)
		local adef = minetest.registered_nodes[anode.name]
		if ndef and not ndef.walkable and ndef.drowning == 0 and ndef.damage_per_second <= 0 and
				adef and not adef.walkable and adef.drowning == 0 and adef.damage_per_second <= 0 and
				bdef and bdef.walkable and minetest.get_item_group(bnode.name, "fence") == 0 then
			table.insert(possible, neighbors[n])
		end
	end
	if #possible == 0 then
		return
	end

	if precise then
		-- Find the neighbor closest to pos
		local closest_dir = find_closest_horizontal_dir(pos)
		for p=1, #possible do
			local offset = possible[p][1]
			local dir = possible[p][2]
			if closest_dir == dir then
				return vector.round(vector.add(pos, offset))
			end
		end
	end

	-- Pick random possible neighbor
	local r = math.random(1, #possible)
	local offset = possible[r][1]
	return vector.add(pos, offset)
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

-- Checks random nodes around startpos within distance searchdistance and
-- returns a node position that is both safe to stand on and
-- "dry" (i.e. no liquid move physics). tries is the maximum number of
-- node checks before giving up.
-- Returns nil if nothing was found.
local find_safe_and_dry_pos = function(startpos, searchdistance, tries)
	local offset = vector.new(searchdistance, searchdistance, searchdistance)
	local smin = vector.subtract(startpos, offset)
	local smax = vector.add(startpos, offset)
	for t=1, tries do
		local pos = vector.new()
		pos.x = math.random(smin.x, smax.x)
		pos.y = math.random(smin.y, smax.y)
		pos.z = math.random(smin.z, smax.z)
		local node = minetest.get_node(pos)
		local pos2 = vector.offset(pos, 0, 1, 0)
		local node2 = minetest.get_node(pos2)
		local pos3 = vector.offset(pos, 0, -1, 0)
		local node3 = minetest.get_node(pos3)
		-- Target position must be both non-blocking and non-swimmable (includes the node above)
		if not is_node_blocking(node) and not is_node_blocking(node2) and
				not is_node_swimmable(node) and not is_node_swimmable(node2) and
				-- We must be able to stand
				is_node_walkable(node3) then
			return pos
		end
	end
end


local find_reachable_node = function(startpos, nodenames, searchdistance, under_air, check_site)
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
			local taken = false
			if check_site then
				taken = check_site(npos)
			end
			if taken then
			end
			if not taken then
				return npos, searchpos
			end
		end
		table.remove(nodes, r)
	end
end

-- This microtask asynchronically searches a path from start to target.
-- When it's done, it will put the path in mob._temp_custom_state.follow_path
-- options are the pathfinder options
local create_microtask_find_path_async = function(start, target, options, target_type)
	return rp_mobs.create_microtask({
		label = "find path",
		on_start = function(self, mob)
			self.statedata.done = false
			self.statedata.target_type = target_type
			mob._temp_custom_state.follow_path = nil
			local find_path = function(start, target, searchdistance, options, timeout)
				local path = rp_pathfinder.find_path(start, target, searchdistance, options, timeout)
				return path
			end
			local callback = function(path)
				mob._temp_custom_state.follow_path = path
				self.statedata.done = true
			end
			local options_ = table.copy(options)
			local vmanip = rp_pathfinder.get_voxelmanip_for_path(start, target, PATHFINDER_SEARCHDISTANCE)
			options_.vmanip = vmanip
			minetest.handle_async(find_path, callback, start, target, PATHFINDER_SEARCHDISTANCE, options_, PATHFINDER_TIMEOUT)
		end,
		on_step = function()
			-- no-op
		end,
		is_finished = function(self, mob)
			if self.statedata.done then
				return true
			else
				return false
			end
		end,
	})
end


-- Check if villager site at site_pos is already taken by any nearby
-- mob besides `mob`.
-- site_type is either 'home_bed' or 'worksite'.
-- Returns true if site is taken, false otherwise.
local check_site_taken = function(mob, site_pos, site_type)
	local objs = minetest.get_objects_inside_radius(site_pos, SITE_CONFLICT_RESOLVE_RADIUS)
	local sites = {}
	local site_hash = minetest.hash_node_position(site_pos)
	for o=1, #objs do
		local obj = objs[o]
		local ent = obj:get_luaentity()
		if ent and ent ~= mob and ent.name == "rp_mobs_mobs:villager" then
			local site = ent._custom_state[site_type]
			if site then
				local hash = minetest.hash_node_position(site)
				if hash == site_hash then
					return true
				end
			end
		end
	end
	return false
end



-- Resolve conflicts of the villagers's villager sites with nearby villagers,
-- i.e. when 2 or more villagers same home bed or worksite.
-- site_type is either 'home_bed' or 'worksite'.
local resolve_site_conflicts = function(mob, site_type)
	local pos = mob.object:get_pos()
	local objs = minetest.get_objects_inside_radius(pos, SITE_CONFLICT_RESOLVE_RADIUS)
	local sites = {}
	for o=1, #objs do
		local obj = objs[o]
		local ent = obj:get_luaentity()
		if ent and ent.name == "rp_mobs_mobs:villager" then
			local site = ent._custom_state[site_type]
			if site then
				local hash = minetest.hash_node_position(site)
				if sites[hash] then
					table.insert(sites[hash], ent)
				else
					sites[hash] = { ent }
				end
			end
		end
	end

	for hash, users in pairs(sites) do
		if #users >= 2 then
			for u=2, #users do
				users[u]._custom_state[site_type] = nil
			end
		end
	end
end

local microtask_find_new_home_bed = rp_mobs.create_microtask({
	label = "find new home bed",
	singlestep = true,
	on_step = function(self, mob, dtime)
		if mob._custom_state.home_bed then
			if bed.is_valid_bed(mob._custom_state.home_bed) then
				resolve_site_conflicts(mob, "home_bed")
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
		local check_site = function(pos)
			return check_site_taken(mob, pos, "home_bed")
		end
		local bedpos = find_reachable_node(mobpos, { "rp_bed:bed_foot" }, MAX_HOME_BED_DISTANCE, true, check_site)
		if bedpos then
			mob._custom_state.home_bed = bedpos
			minetest.log("action", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mobpos, 1).." found new home bed at "..minetest.pos_to_string(bedpos))
		end
	end,
})

local is_valid_worksite = function(pos, profession)
	local expected_worksite = worksites[profession]
	if not expected_worksite then
		return false
	end
	local node = minetest.get_node(pos)
	local expected_nodename = expected_worksite[1]
	if string.sub(expected_nodename, 1, 6) == "group:" then
		local groupname = string.sub(expected_nodename, 7)
		return minetest.get_item_group(node.name, groupname) ~= 0
	else
		return node.name == expected_nodename
	end
end

local microtask_find_new_worksite = rp_mobs.create_microtask({
	label = "find new worksite",
	singlestep = true,
	on_step = function(self, mob, dtime)
		local profession = mob._custom_state.profession
		if mob._custom_state.worksite then
			if is_valid_worksite(mob._custom_state.worksite, profession) then
				resolve_site_conflicts(mob, "worksite")
			else
				mob._custom_state.worksite = nil
				local mobpos = mob.object:get_pos()
				minetest.log("action", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mobpos, 1).." lost their worksite")
			end
			return
		end
		local mobpos = mob.object:get_pos()
		if not mobpos then
			return
		end

		local targetnodes
		local under_air = true
		if worksites[profession] then
			targetnodes = worksites[profession][1]
			under_air = worksites[profession][2]
		end
		local target
		if targetnodes then
			local check_site = function(pos)
				return check_site_taken(mob, pos, "worksite")
			end
			target = find_reachable_node(mobpos, targetnodes, WORK_DISTANCE, under_air, check_site)
		end
		if target then
			mob._custom_state.worksite = target
			minetest.log("action", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mobpos, 1).." found new worksite at "..minetest.pos_to_string(target))
		end
	end,
})

local create_microtask_open_door = function(door_pos, walk_axis)
	return rp_mobs.create_microtask({
		label = "open door",
		singlestep = true,
		on_step = function(self, mob)
			local dist = vector.distance(mob.object:get_pos(), door_pos)
			if dist > REACH then
				-- Fail microtask if mob is too far away from door
				return
			end

			-- Technically, this does not *really* open
			-- the door but instead check if the current
			-- free axis (that the mob can move through)
			-- mismatches the axis the mob wants to walk in
			-- and only *then* toggles the door.
			-- This may not always align with the door's
			-- open/close state but the mob doesn't need to
			-- care, it just wants to free the way.
			-- The door will be "opened" from the mob's perspective.
			local free_axis = door.get_free_axis(door_pos)
			if not free_axis then
				return
			end
			if free_axis ~= walk_axis then
				door.toggle_door(door_pos)
			end
		end,
	})
end

-- Handle basic physics (gravity)
local physics_decider = function(task_queue, mob)
	local mt_gravity = rp_mobs.create_microtask({
		label = "gravity",
		on_start = function(self, mob)
			-- Is true when mob is in climbable node
			mob._temp_custom_state.in_climbable_node = false

			-- Is true when mob is in liquid node
			mob._temp_custom_state.in_liquid_node = false

			-- Is true when gravity is enabled
			self.statedata.gravity = nil

			self.statedata.timer = 0
		end,
		on_step = function(self, mob, dtime)
			local mobpos = mob.object:get_pos()

			local rmobpos = vector.round(mobpos)
			local hash = minetest.hash_node_position(rmobpos)
			self.statedata.timer = self.statedata.timer + dtime
			if self.statedata.last_pos_hash ~= hash or self.statedata.timer >= 1 then

				local ndef = minetest.registered_nodes[mob._env_node.name]
				local nfdef = minetest.registered_nodes[mob._env_node_floor.name]

				if (ndef and ndef.climbable) or (nfdef and nfdef.climbable) then
					mob._temp_custom_state.in_climbable_node = true
				else
					mob._temp_custom_state.in_climbable_node = false
				end
				if (ndef and is_node_swimmable(mob._env_node)) or (nfdef and is_node_swimmable(mob._env_node_floor)) then
					mob._temp_custom_state.in_liquid_node = true
				else
					mob._temp_custom_state.in_liquid_node = false
				end

				local grav = not (mob._temp_custom_state.in_climbable_node or mob._temp_custom_state.in_liquid_node)

				-- If falling or rising fast in climbable/swimmable node, slow down
				if not grav then
					local vel = mob.object:get_velocity()
					local epsilon = 0.05
					if vel.y > CLIMB_SPEED+epsilon then
						vel.y = math.max(CLIMB_SPEED+epsilon, vel.y - CLIMB_DRAG)
						mob.object:set_velocity(vel)
					elseif vel.y < -CLIMB_SPEED-epsilon then
						vel.y = math.min(-CLIMB_SPEED-epsilon, vel.y + CLIMB_DRAG)
						mob.object:set_velocity(vel)
					end
				end
				if grav ~= self.statedata.gravity then
					self.statedata.gravity = grav
					if grav then
						mob.object:set_acceleration(rp_mobs.GRAVITY_VECTOR)
					else
						mob.object:set_acceleration(vector.zero())
					end
				end

				self.statedata.last_pos_hash = hash
				self.statedata.timer = 0
			end
		end,
		is_finished = function(self, mob)
			return false
		end,
	})

	local task = rp_mobs.create_task({label="physics handling"})
	rp_mobs.add_microtask_to_task(mob, mt_gravity, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end


-- Walk through all nodes along the given path
-- and create a table of "to-do" tasks.
-- each element in the todo table is either:
-- { type = "path", path = <path> }
-- or:
-- { type = "door", pos = <door pos> }

-- The point of this is to split the input path
-- into multiple paths separated by doors.
local path_to_todo_list = function(path)
	if not path then
		return
	end

	local todo = {}

	local current_path = {}
	local current_climb_path = {}

	local flush_path = function()
		if #current_path > 0 then
			table.insert(todo, {
				type = "path",
				path = table.copy(current_path),
			})
			current_path = {}
		end
	end
	local flush_climb = function()
		if #current_climb_path > 0 then
			table.insert(todo, {
				type = "climb",
				path = table.copy(current_climb_path),
			})
			current_climb_path = {}
		end
	end

	local prev_pos
	local prev_todo
	for p=1, #path do
		local pos = path[p]
		local pos2 = vector.offset(pos, 0, 1, 0)
		local pos3 = vector.offset(pos, 0, -1, 0)
		local node = minetest.get_node(pos)
		local node2 = minetest.get_node(pos2)
		local node3 = minetest.get_node(pos3)
		local def = minetest.registered_nodes[node.name]
		local def2 = minetest.registered_nodes[node2.name]
		local def3 = minetest.registered_nodes[node3.name]

		local going_down, going_up = false, false
		local next_pos
		if p < #path then
			next_pos = path[p+1]
			if pos.y > next_pos.y then
				going_down = true
			elseif pos.y < next_pos.y then
				going_up = true
			end
		end


		-- Climbable node (ladder, etc.).
		-- Also: swimmable node
		if (def and def.climbable) or (def3 and def3.climbable) or
				is_node_swimmable(node) or is_node_swimmable(node3) then

			if prev_todo == "walk" or prev_todo == "door" then
				table.insert(current_path, pos)
			end
			flush_path()

			table.insert(current_climb_path, pos)

			prev_todo = "climb"

		-- Door
		elseif minetest.get_item_group(node.name, "door") ~= 0 or minetest.get_item_group(node2.name, "door") ~= 0 then
			flush_climb()
			flush_path()

			-- Get the mob walking direction
			-- by looking at previous or next position in the path
			local axis
			local other_pos
			local next_pos
			if p < #path then
				next_pos = path[p+1]
			end
			local uses_prev = false
			if prev_pos then
				other_pos = prev_pos
				uses_prev = true
			else
				if p < #path then
					other_pos = next_pos
				else
					-- Fallback if path is only 1 entry long
					other_pos = vector.zero()
				end
			end

			-- Record the axis the mob wants to walk,
			-- so the mob knows whether the door needs to be toggled
			if other_pos.x ~= pos.x then
				axis = "x"
			else
				axis = "z"
			end

			local door_pos
			if minetest.get_item_group(node.name, "door") == 0 then
				-- In case the door is 1 node above the ground.
				door_pos = pos2
			else
				door_pos = pos
			end
			-- Mark the door to be opened.
			-- Note: This does not mean the mob will always toggle the door,
			-- only if it is *neccessary* to toggle it to free the way
			-- once the mob reaches it.
			table.insert(todo, {
				type = "door",
				pos = door_pos,
				axis = axis,
			})

			-- Add a 1-entry long path todo right after the door to force the mob
			-- to walk into the door node. This avoids the mob opening multiple doors
			-- that are placed right behind each other to be opened all at once.
			table.insert(current_path, pos)
			flush_path()

			-- Literal Corner Case:
			-- If the door is right in a position where the path takes a corner (90° turn),
			-- the door might need to get toggled *again* after the mob is
			-- inside the door node.
			if uses_prev and next_pos and next_pos.x ~= prev_pos.x then
				if next_pos.x ~= pos.x then
					axis = "x"
				else
					axis = "z"
				end
				table.insert(todo, {
					type = "door",
					pos = door_pos,
					axis = axis,
				})
			end

			prev_todo = "door"

		-- Any other node ...
		else
			flush_climb()

			-- ... is part of a normal path to walk on
			table.insert(current_path, pos)

			prev_todo = "walk"
		end
		prev_pos = pos
	end
	flush_climb()
	flush_path()

	return todo
end

-- Turns a path (sequence of coordinates) into a sequence of
-- microtasks
local path_to_microtasks = function(path)
	-- Stop following the climb path if no longer climbing or in liquid.
	-- Note: Villagers treat climbable and liquid nodes to be phyiscally equal.
	local stop_follow_path_climb = function(self, mob, dtime)
		if not mob._temp_custom_state.in_climbable_node and not mob._temp_custom_state.in_liquid_node then
			return true, false
		else
			return false
		end
	end

	local todo = path_to_todo_list(path)
	local microtasks = {}
	if not todo then
		return {}
	end
	for t=1, #todo do
		local entry = todo[t]
		local mt
		if entry.type == "path" then
			mt = rp_mobs.microtasks.follow_path(entry.path, WALK_SPEED, JUMP_STRENGTH, true)
			mt.start_animation = "walk"
		elseif entry.type == "door" then
			mt = create_microtask_open_door(entry.pos, entry.axis)
			mt.start_animation = "idle"
		elseif entry.type == "climb" then
			mt = rp_mobs.microtasks.follow_path_climb(entry.path, WALK_SPEED, CLIMB_SPEED, true, nil, nil, stop_follow_path_climb)
		else
			minetest.log("error", "[rp_mobs_mobs] path_to_microtasks: Invalid entry type in TODO list!")
			return
		end
		table.insert(microtasks, mt)
	end
	return microtasks
end

-- Make mob look at target object (by setting yaw)
local look_at = function(mob, target)
	local mpos = mob.object:get_pos()
	local tpos = target:get_pos()
	mpos.y = 0
	tpos.y = 0
	local dir = vector.direction(mpos, tpos)
	local yaw = minetest.dir_to_yaw(dir)
	mob.object:set_yaw(yaw)
end

-- Look at random direction or nearby player
local microtask_look_around = rp_mobs.create_microtask({
	label = "look around",
	singlestep = true,
	on_step = function(self, mob, dtime)
		local look_at_player = true

		-- Villager must not be angry to look at player
		if not mob._temp_custom_state.angry_at then

			-- Pick random player in range and look at them
			local mpos = mob.object:get_pos()
			local objs = minetest.get_objects_inside_radius(mpos, PLAYER_LOOK_AT_RANGE)
			local players = {}
			for o=1, #objs do
				local obj = objs[o]
				if obj:is_player() then
					table.insert(players, obj)
				end
			end
			if #players > 0 then
				local r = math.random(1, #players)
				look_at(mob, players[r])
				return
			end
		end

		-- Look randomly if no player found
		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		mob.object:set_yaw(yaw)
	end,
	start_animation = "idle",
})

local create_microtask_generate_microtasks_from_path = function()
	return rp_mobs.create_microtask({
		label = "generate microtasks from path",
		singlestep = true,
		on_step = function(self, mob)
			if not mob._temp_custom_state.follow_path then
				return
			end
			local mts = path_to_microtasks(mob._temp_custom_state.follow_path)
			for m=1, #mts do
				local parent_task = self.task
				local microtask = mts[m]
				rp_mobs.add_microtask_to_task(mob, microtask, parent_task)
			end
		end,
	})
end

local movement_decider_step = function(task_queue, mob, dtime)
	-- Reduce load
	if not mob._temp_custom_state.reflex_timer then
		mob._temp_custom_state.reflex_timer = 0
	end
	mob._temp_custom_state.reflex_timer = mob._temp_custom_state.reflex_timer + dtime
	if mob._temp_custom_state.reflex_timer < REFLEX_TIME then
		return
	end
	mob._temp_custom_state.reflex_timer = 0

	local mobpos = mob.object:get_pos()
	local umobpos = vector.offset(mobpos, 0, -0.5, 0)
	local rmobpos = vector.round(umobpos)
	local rmobpos2 = vector.offset(rmobpos, 0, 1, 0)
	local mnode = minetest.get_node(rmobpos)
	local mnode2 = minetest.get_node(rmobpos2)

	-- Test if mob is stuck; unstuck it if that's the case
	if is_node_blocking_water_ok(mnode) or is_node_blocking_water_ok(mnode2) then
		local current_task_entry = task_queue.tasks:getFirst()
		if current_task_entry and current_task_entry.data and current_task_entry.data.label == "get unstuck" then
			return
		end
		rp_mobs.clear_task_queue(task_queue)

		-- Mob is stuck in some solid node;
		-- try to find a free neighbor.
		local unstuckmobpos = table.copy(mobpos)
		unstuckmobpos.y = unstuckmobpos.y - 0.5
		local target = find_free_horizontal_neighbor(unstuckmobpos, true)
		if not target then
			return
		end

		-- Add a minimal microtask to walk to a neighboring free node
		mob._temp_custom_state.follow_path = {target}
		local mts = path_to_microtasks(mob._temp_custom_state.follow_path)
		local task_walk = rp_mobs.create_task({label="get unstuck"})
		for m=1, #mts do
			local microtask = mts[m]
			rp_mobs.add_microtask_to_task(mob, microtask, task_walk)
		end

		rp_mobs.add_task_to_task_queue(task_queue, task_walk)
		return
	-- Test if node is in a swimmable node; pathfind out of that if that's the case
	elseif is_node_swimmable(mnode) or is_node_swimmable(mnode2) then
		local current_task_entry = task_queue.tasks:getFirst()
		if current_task_entry and current_task_entry.data and current_task_entry.data.label == "swim to safety" then
			return
		end
		local safe_pos = find_safe_and_dry_pos(mobpos, LIQUID_ESCAPE_RANGE, LIQUID_ESCAPE_TRIES)
		if safe_pos then
			rp_mobs.clear_task_queue(task_queue)

			local options = table.copy(PATHFINDER_OPTIONS)
			options.handler_blocking = is_node_blocking_water_ok
			options.handler_climbable = is_node_swimmable

			local mt_find_path = create_microtask_find_path_async(mobpos, safe_pos, options, "swim to safety")
			mt_find_path.start_animation = "idle"

			local mt_generate_microtasks = create_microtask_generate_microtasks_from_path()

			local task = rp_mobs.create_task({label="swim to safety"})
			rp_mobs.add_microtask_to_task(mob, mt_find_path, task)
			rp_mobs.add_microtask_to_task(mob, mt_generate_microtasks, task)
			rp_mobs.add_task_to_task_queue(task_queue, task)
			return
		end
	end
end

local movement_decider_empty = function(task_queue, mob)
	local mobpos = mob.object:get_pos()

	local task_stand = rp_mobs.create_task({label="stand still"})
	rp_mobs.add_microtask_to_task(mob, microtask_look_around, task_stand)
	local mt_sleep = rp_mobs.microtasks.sleep(IDLE_TIME)
	mt_sleep.start_animation = "idle"
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task_stand)
	rp_mobs.add_task_to_task_queue(task_queue, task_stand)

	-- Regular day activity based on schedule: Go to bed, go to work or play

	local day_phase = get_day_phase()
	local profession = mob._custom_state.profession
	local schedule
	if profession then
		schedule = schedules[profession]
	else
		schedule = schedules.none
	end

	local activity = schedule[day_phase]
	if not activity then
		minetest.log("error", "[rp_mobs_mobs] No villager schedule for villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).."! (day_phase='"..tostring(day_phase).."', profession='"..tostring(profession).."'")
		return
	end

	-- target is the position where we actually go to;
	-- target_block is the position of the block we target
	local target, target_block
	local task_label
	if activity == "sleep" then
		-- Go to home bed
		if mob._custom_state.home_bed then
			target_block = mob._custom_state.home_bed
			target = find_free_horizontal_neighbor(mob._custom_state.home_bed)
			task_label = "walk to bed"
		end
	elseif activity == "work" then
		-- Go to worksite
		if mob._custom_state.worksite then
			target_block = mob._custom_state.worksite
			if profession == "farmer" then
				-- Farmer's worksite is crops, so we can stand directly on top
				target = mob._custom_state.worksite
			else
				target = find_free_horizontal_neighbor(mob._custom_state.worksite)
			end
			task_label = "walk to workplace"
		end
	elseif activity == "play" then
		-- Go around sites of interest in village
		local targetnodes
		local under_air = true
		task_label = "walk to recreation site"
		local a = math.random(1, 4)
		if a == 1 then
			targetnodes = { "group:bonfire" }
			under_air = true
		else
			targetnodes = { "group:bookshelf", "group:chest", "rp_itemshow:showcase" }
			under_air = false
		end
		if targetnodes then
			target_block, target = find_reachable_node(mobpos, targetnodes, WORK_DISTANCE, under_air)
		end
	else
		minetest.log("error", "[rp_mobs_mobs] Unknown villager schedule type: "..tostring(activity))
		return
	end

	if target and target_block then
		-- Check if we are already close to the target block.
		-- If yes, no need to pathfind again.
		local dist = vector.distance(mobpos, target_block)
		local ydist = math.abs(target_block.y - mobpos.y)
		if dist >= 1.42 or ydist >= 1 then
			-- First find the path asynchronously ...
			local mt_find_path = create_microtask_find_path_async(mobpos, target, PATHFINDER_OPTIONS, activity)

			-- Reset home bed or work site if no path found
			mt_find_path.on_end = function(self, mob)
				if mob._temp_custom_state.follow_path == nil then
					if self.statedata.target_type == "work" then
						mob._custom_state.worksite = nil
						minetest.log("info", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).." couldn't find path to worksite; resetting ...")
					elseif self.statedata.target_type == "sleep" then
						mob._custom_state.home_bed = nil
						minetest.log("info", "[rp_mobs_mobs] Villager at "..minetest.pos_to_string(mob.object:get_pos(), 1).." couldn't find path to home bed; resetting ...")
					end
				end
			end
			mt_find_path.start_animation = "idle"

			-- ... then follow it
			local mt_generate_microtasks = create_microtask_generate_microtasks_from_path()

			local task_walk = rp_mobs.create_task({label=task_label or "walk to somewhere"})
			rp_mobs.add_microtask_to_task(mob, mt_find_path, task_walk)

			rp_mobs.add_microtask_to_task(mob, mt_generate_microtasks, task_walk)

			rp_mobs.add_task_to_task_queue(task_queue, task_walk)
		end
	end
end

local find_sites_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="find new home bed and worksite"})
	local mt_sleep = rp_mobs.microtasks.sleep(FIND_SITE_IDLE_TIME)

	rp_mobs.add_microtask_to_task(mob, microtask_find_new_home_bed, task)
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
	rp_mobs.add_microtask_to_task(mob, microtask_find_new_worksite, task)
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)

	rp_mobs.add_task_to_task_queue(task_queue, task)
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

-- Profession-specific drops
local droptables = {
	-- The drops are intentionally pretty cheap. While this allows the player
	-- to kill villagers for loot, the reward isn't great and there
	-- are usually more efficient methods to get these items.
	tavernkeeper = {
		{ name = "rp_default:apple", chance = 2, min = 1, max = 2 },
		{ name = "rp_default:bucket", chance = 4, min = 1, max = 1 },
	},
	blacksmith = {
		{ name = "rp_default:lump_coal", chance = 2, min = 1, max = 2 },
	},
	farmer = {
		{ name = "rp_farming:wheat", chance = 2, min = 1, max = 3 },
	},
	carpenter = {
		{ name = "rp_default:planks_oak", chance = 1, min = 1, max = 3 },
		{ name = "rp_default:stick", chance = 3, min = 2, max = 6 },
	},
	butcher = {
		{ name = "rp_default:axe_stone", chance = 8, min = 1, max = 1 },
		{ name = "rp_mobs_mobs:meat_raw", chance = 4, min = 1, max = 1 },
	},
}

rp_mobs.register_mob("rp_mobs_mobs:villager", {
	description = S("Villager"),
	tags = { peaceful = 1 },

	-- Profession-specific drops
	drop_func = function(self)
		if (self._child) then
			return {}
		end
		if not self._custom_state then
			return {}
		end
		local profession = self._custom_state.profession
		local droptable = droptables[profession]
		if not droptable then
			return {}
		end

		local to_drop = {}
		for d=1, #droptable do
			local drop = droptable[d]
			local rnd = math.random(1, drop.chance)
			if rnd == 1 then
				local count = math.random(drop.min, drop.max)
				if count > 0 then
					drop = drop.name .. " "..count
					table.insert(to_drop, drop)
				end
			end
		end
		return to_drop
	end,
	animations = {
		["idle"] = { frame_range = { x = 0, y = 79 }, default_frame_speed = 30 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
		["run"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
		["punch"] = { frame_range = { x = 200, y = 219 }, default_frame_speed = 30 },
	},
	front_body_point = vector.new(0, -0.6, 0.2),
	path_check_point = vector.new(0, -0.5, 0),
	dead_y_offset = 0.6,
	default_sounds = {
		damage = "default_punch",
		death = "default_punch",
	},
	entity_definition = {
		initial_properties = {
			hp_max = 20,
			physical = true,
			-- disable object collision to simplify pathfinding
			collide_with_objects = false,
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

			if not self._custom_state.profession then
				set_random_profession(self)
			end
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

			-- Stop horizontal movement on (re-)spawn
			local vel = self.object:get_velocity()
			vel.x = 0
			vel.z = 0
			self.object:set_velocity(vel)

			rp_mobs.init_tasks(self)
			local physics_task_queue = rp_mobs.create_task_queue(physics_decider)
			local movement_task_queue = rp_mobs.create_task_queue(movement_decider_empty, movement_decider_step)
			local heal_task_queue = rp_mobs.create_task_queue(heal_decider)
			local angry_task_queue = rp_mobs.create_task_queue(rp_mobs_mobs.create_angry_cooldown_decider(VIEW_RANGE, ANGRY_COOLDOWN_TIME))
			local find_sites_task_queue = rp_mobs.create_task_queue(find_sites_decider)
			rp_mobs.add_task_queue(self, physics_task_queue)
			rp_mobs.add_task_queue(self, movement_task_queue)
			rp_mobs.add_task_queue(self, heal_task_queue)
			rp_mobs.add_task_queue(self, angry_task_queue)
			rp_mobs.add_task_queue(self, find_sites_task_queue)
		end,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime, moveresult, rp_mobs_mobs.get_dying_step(true, true))
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


rp_mobs.register_mob_item("rp_mobs_mobs:villager", "mobs_villager_inventory.png", nil, function(mob, itemstack)
	local profession = mob._custom_state.profession
	if profession then
		local meta = itemstack:get_meta()
		meta:set_string("inventory_image", "mobs_villager_"..profession.."_inventory.png")
		meta:set_string("wield_image", "mobs_villager_"..profession.."_inventory.png")
		meta:set_string("description", professions_keys[profession])
	else
		meta:set_string("inventory_image", "")
		meta:set_string("wield_image", "")
	end
	return itemstack
end)
do
	local groups = minetest.registered_items["rp_mobs_mobs:villager"].groups
	groups.not_in_creative_inventory = 1
	minetest.override_item("rp_mobs_mobs:villager", { groups = groups })
end

for p=1, #professions do
	local profession = professions[p][1]
	local desc = professions[p][2]
	local item = ItemStack("rp_mobs_mobs:villager")
	local meta = item:get_meta()
	meta:set_string("inventory_image", "mobs_villager_"..profession.."_inventory.png")
	meta:set_string("wield_image", "mobs_villager_"..profession.."_inventory.png")
	meta:set_string("description", desc)

	local staticdata_table = { _custom_state = { profession = profession } }
	local staticdata = minetest.serialize(staticdata_table)
	meta:set_string("staticdata", staticdata)

	creative.register_special_item(item)
end


minetest.register_async_dofile(minetest.get_modpath("rp_pathfinder").."/init.lua")
