local WALK_SPEED = 2
local LIQUID_RISE_SPEED = 2
local JUMP_STRENGTH = 5
local WALK_DURATION_MIN = 3000
local WALK_DURATION_MAX = 4000
local FIND_LAND_DURATION_MIN = 7000
local FIND_LAND_DURATION_MAX = 10000
local FIND_SAFE_LAND_DURATION = 1000
local IDLE_DURATION_MIN = 500
local IDLE_DURATION_MAX = 2000
local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000
local VIEW_RANGE = 10
local FIND_LAND_ANGLE_STEP = 15
local FIND_LAND_LENGTH = 20
local MAX_FALL_DAMAGE_ADD_PERCENT_DROP_ON = 10
local FALL_HEIGHT = 4
local FOLLOW_CHECK_TIME = 1.0
local FOLLOW_REACH_DISTANCE = 2
local FOLLOW_GIVE_UP_TIME = 10.0
local MAX_NO_FOLLOW_TIME = 6.0

local FOOD = { "rp_default:apple", "rp_default:acorn" }

-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local mt_set_acceleration = function(acceleration)
	return rp_mobs.create_microtask({
		label = "set acceleration",
		singlestep = true,
		on_step = function(self, mob, dtime)
			mob.object:set_acceleration(acceleration)
		end,
	})
end

local function is_liquid(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and (ndef.liquid_move_physics == true or (ndef.liquid_move_physics == nil and ndef.liquidtype ~= "none"))
end

local function is_damaging(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and ndef.damage_per_second > 0
end

local function is_walkable(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and ndef.walkable
end

local function is_front_safe(mob, check_liquids, cliff_depth)
	local vel = mob.object:get_velocity()
	vel.y = 0
	local yaw = mob.object:get_yaw()
	local dir = vector.normalize(vel)
	if vector.length(dir) > 0.5 then
		yaw = minetest.dir_to_yaw(dir)
	else
		yaw = mob.object:get_yaw()
		dir = minetest.yaw_to_dir(yaw)
	end
	local pos = mob.object:get_pos()
	if mob._front_body_point then
		local fbp = table.copy(mob._front_body_point)
		fbp = vector.rotate_around_axis(fbp, vector.new(0, 1, 0), yaw)
		pos = vector.add(pos, fbp)
	end
	local pos_front = vector.add(pos, dir)
	local node_front = minetest.get_node(pos_front)
	local def_front = minetest.registered_nodes[node_front.name]
	if def_front and (def_front.drowning > 0 or def_front.damage_per_second > 0) then
		return false
	end
	if def_front and not def_front.walkable then
		local safe_drop = false
		for c=1, cliff_depth do
			local cpos = vector.add(pos_front, vector.new(0, -c, 0))
			local cnode = minetest.get_node(cpos)
			local cdef = minetest.registered_nodes[cnode.name]
			if check_liquids and cdef.drowning > 0 then
				return false
			elseif cdef.damage_per_second > 0 then
				return false
			elseif cdef.walkable then
				-- Mob doesn't like to land on node with high fall damage addition
				if c > 1 and minetest.get_item_group(cnode.name, "fall_damage_add_percent") >= MAX_FALL_DAMAGE_ADD_PERCENT_DROP_ON then
					return false
				else
					safe_drop = true
					break
				end
			end
		end
		if not safe_drop then
			return false
		end
	end
	return true
end

-- This function helps the mob find safe land from a lake or ocean.
--
-- Assuming that pos is a position above a large body of
-- liquid (like a lake or ocean), this function can return
-- the (approximately) closest position of walkable land
-- from that position, up to a hardcoded maximum range.
--
--
-- Argument:
-- * pos: Start position
--
-- returns: <position>, <angle from position>
-- or nil, nil if no position found
local find_land_from_liquid = function(pos)
	local startpos = table.copy(pos)
	startpos.y = startpos.y - 1
	local startnode = minetest.get_node(startpos)
	if not is_liquid(startnode.name) then
		startpos.y = startpos.y - 1
	end
	local vec_y = vector.new(0, 1, 0)
	local best_pos
	local best_dist
	local best_angle
	for angle=0, 359, FIND_LAND_ANGLE_STEP do
		local angle_rad = (angle/360) * (math.pi*2)
		local vec = vector.new(0, 0, 1)
		vec = vector.rotate_around_axis(vec, vec_y, angle_rad)
		vec = vector.multiply(vec, FIND_LAND_LENGTH)
		local rc = minetest.raycast(startpos, vector.add(startpos, vec), false, false)
		for pt in rc do
			if pt.type == "node" then
				local dist = vector.distance(startpos, pt.under)
				local up = vector.add(pt.under, vector.new(0, 1, 0))
				local upnode = minetest.get_node(up)
				if not best_dist or dist < best_dist then
					-- Ignore if ray collided with overhigh selection boxes (kelp, seagrass, etc.)
					if pt.intersection_point.y - 0.5 < pt.under.y and
							-- Node above must be non-walkable
							not is_walkable(upnode.name) then
						best_pos = up
						best_dist = dist
						local pos1 = vector.copy(startpos)
						local pos2 = vector.copy(up)
						pos1.y = 0
						pos2.y = 0
						best_angle = minetest.dir_to_yaw(vector.direction(pos1, pos2))
						break
					end
				end
				if is_walkable(upnode.name) then
					break
				end
			end
		end
	end
	return best_pos, best_angle
end

-- Argument:
-- * pos: Start position
--
-- returns: <position>, <angle from position>
-- or nil, nil if no position found
local find_safe_node_from_pos = function(pos)
	local startpos = table.copy(pos)
	startpos.y = math.floor(startpos.y)
	startpos.y = startpos.y - 1
	local startnode = minetest.get_node(startpos)
	local best_pos
	local best_dist
	local best_angle
	local vec_y = vector.new(0, 1, 0)
	for angle=0, 359, FIND_LAND_ANGLE_STEP do
		local angle_rad = (angle/360) * (math.pi*2)
		local vec = vector.new(0, 0, 1)
		vec = vector.rotate_around_axis(vec, vec_y, angle_rad)
		vec = vector.multiply(vec, FIND_LAND_LENGTH)
		local rc = minetest.raycast(startpos, vector.add(startpos, vec), false, false)
		for pt in rc do
			if pt.type == "node" then
				local floor = pt.under
				local floornode = minetest.get_node(floor)
				local up = vector.add(floor, vector.new(0, 1, 0))
				local upnode = minetest.get_node(up)
				if is_walkable(floornode.name) then
					if is_walkable(upnode.name) then
						break
					elseif not is_walkable(upnode.name) and not is_damaging(upnode.name) then
						local dist = vector.distance(startpos, floor)
						if not best_dist or dist < best_dist then
							best_pos = up
							best_dist = dist
							local pos1 = vector.copy(startpos)
							local pos2 = vector.copy(up)
							pos1.y = 0
							pos2.y = 0
							best_angle = minetest.dir_to_yaw(vector.direction(pos1, pos2))
						end
						break
					end
				end
			end
		end
	end
	return best_pos, best_angle
end

local roam_decider = function(task_queue, mob)
	local task_roam
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
	mt_sleep.start_animation = "idle"

	if mob._env_node.name == "ignore" then
		task_roam = rp_mobs.create_task({label="stand still"})
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif is_damaging(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="escape from damaging node"})

		local yaw
		-- Find direction to walk to
		local safepos, safeangle = find_safe_node_from_pos(mob.object:get_pos())
		local walk_duration
		-- Prefer walking towards safe place
		if safepos and safeangle then
			yaw = safeangle
			walk_duration = math.random(FIND_LAND_DURATION_MIN, FIND_LAND_DURATION_MAX)/1000
		else
			-- If no safe place found, walk randomly (panic!)
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, nil, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(rp_mobs.GRAVITY_VECTOR), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)

	elseif is_liquid(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="swim upwards"})
		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		local move_vector = vector.new(0, LIQUID_RISE_SPEED, 0)
		local mt_swim_up = rp_mobs.microtasks.move_straight(move_vector, yaw, vector.new(2, 0.3, 2))
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(vector.zero()), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_swim_up, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif is_liquid(mob._env_node_floor.name) then
		task_roam = rp_mobs.create_task({label="swim on liquid surface"})

		local yaw
		-- Find direction to walk to
		local landpos, landangle = find_land_from_liquid(mob.object:get_pos())
		local walk_duration
		-- Prefer walking towards land. Boar wants to stay dry. ;-)
		if landpos and landangle then
			-- towards land
			yaw = landangle
			walk_duration = FIND_SAFE_LAND_DURATION
		else
			-- If no land found, go randomly on water
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(vector.zero()), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	else
		task_roam = rp_mobs.create_task({label="roam land"})

		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(rp_mobs.GRAVITY_VECTOR), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	end

	rp_mobs.add_task_to_task_queue(task_queue, task_roam)
end

-- Add a "stand still" task to the mob's task queue with
-- an optional yaw
local halt = function(task_queue, mob, set_yaw)
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
	mt_sleep.start_animation = "idle"
	local task = rp_mobs.create_task({label="stand still"})
	local vel = mob.object:get_velocity()
	vel.x = 0
	vel.z = 0
	local yaw
	if not set_yaw then
		yaw = mob.object:get_yaw()
	else
		yaw = set_yaw
	end
	local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)

	rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(rp_mobs.GRAVITY_VECTOR), task)
	if set_yaw then
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task)
	end
	rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.move_straight(vel, yaw, vector.new(0.5,0,0.5), 1), task)
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

local roam_decider_step = function(task_queue, mob, dtime)
	-- Re-enable following after a few seconds
	if mob._temp_custom_state.no_follow then
		mob._temp_custom_state.no_follow_timer = mob._temp_custom_state.no_follow_timer + dtime
		if mob._temp_custom_state.no_follow_timer > MAX_NO_FOLLOW_TIME then
			mob._temp_custom_state.no_follow = false
			mob._temp_custom_state.no_follow_timer = 0
		end
	end

	if mob._env_node then
		local current = task_queue.tasks:getFirst()
		if current and current.data then
			-- Escape from damaging node has reached safety
			if current.data.label == "escape from damaging node" then
				if not is_damaging(mob._env_node.name) or is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			-- Stop following player or partner if gone
			elseif (current.data.label == "follow player holding food" and not mob._temp_custom_state.follow_player) or
					(current.data.label == "follow mating partner" and not mob._temp_custom_state.follow_partner) then
				rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				halt(task_queue, mob)
			-- Update land movement (roam, standing, following)
			-- Note: The follow tasks are all considered to be land movement.
			-- There is no following while swimming!
			elseif current.data.label == "roam land" or current.data.label == "stand still" or
					current.data.label == "follow player holding food" or current.data.label == "follow mating partner" then
				-- Abort when in damaging or liquid node
				if is_damaging(mob._env_node.name) or is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				-- Abort and stop movement when walking towards of a cliff or other dangerous node
				elseif not is_front_safe(mob, true, FALL_HEIGHT) and current.data.label ~= "stand still" then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)

					-- Rotate by 70° to 180° left or right
					local sign = math.random(0, 1)
					local yawplus = math.random(70, 180)/360 * (math.pi*2)
					local yaw = mob.object:get_yaw() + yawplus
					if sign == 1 then
						yaw = -yaw
					end
					halt(task_queue, mob, yaw)
					-- Disable following for a few seconds if mob just avoided a danger
					if current.data.label == "follow player holding food" or current.data.label == "follow mating partner" then
						mob._temp_custom_state.no_follow = true
						mob._temp_custom_state.no_follow_timer = 0
					end
				-- Follow player holding food or mating partner
				elseif (mob._temp_custom_state.follow_partner or mob._temp_custom_state.follow_player) and not mob._temp_custom_state.no_follow then
					local target, task_label
					-- If horny, following mating partner
					if mob._horny and mob._temp_custom_state.follow_partner then
						if mob._temp_custom_state.follow_partner:get_luaentity() then
							target = mob._temp_custom_state.follow_partner
							task_label = "follow mating partner"
						end
					end
					-- Follow player holding food only if not horny
					if not mob._horny and mob._temp_custom_state.follow_player then
						local player = minetest.get_player_by_name(mob._temp_custom_state.follow_player)
						if player then
							target = player
							task_label = "follow player holding food"
						end
					end
					if target then
						if task_label == current.data.label then
							-- We're already doing this task - no change
							return
						end
						rp_mobs.end_current_task_in_task_queue(mob, task_queue)
						local task = rp_mobs.create_task({label=task_label})
						rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(rp_mobs.GRAVITY_VECTOR), task)
						local mt_follow = rp_mobs.microtasks.walk_straight_towards(WALK_SPEED, "object", target, true, FOLLOW_REACH_DISTANCE, JUMP_STRENGTH, FOLLOW_GIVE_UP_TIME)
						mt_follow.start_animation = "walk"
						rp_mobs.add_microtask_to_task(mob, mt_follow, task)
						local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
						mt_sleep.start_animation = "idle"
						rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
						rp_mobs.add_task_to_task_queue(task_queue, task)
					end
				end
			-- Surface from liquid
			elseif current.data.label == "swim upwards" then
				if not is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
					local vel = vector.zero()
					-- Transitionary task to reset velocity.
					local task = rp_mobs.create_task({label="surface"})
					rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.move_straight(vel, mob.object:get_yaw()), task)
					rp_mobs.add_task_to_task_queue(task_queue, task)
				end
			-- Reaching land or air when swimming on liquid
			elseif current.data.label == "swim on liquid surface" then
				if not is_liquid(mob._env_node.name) and not is_liquid(mob._env_node_floor.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			end
		end
	end
end

-- This microtasks scans the mob's surroundings within
-- VIEW_RANGE for other interesting entities:
-- 1) Players holding food
-- 2) Mobs of same species to mate with
-- The result is stored in mob._temp_custom_state.follow_partner
-- and mob._temp_custom_state.follow_player.
-- This microtask only *searches* for suitable targets to follow,
-- it does *NOT* actually follow them. Other microtasks
-- are supposed to decide what do do with this information.
local mt_find_follow = rp_mobs.create_microtask({
	label = "find entities to follow",
	on_start = function(self, mob)
		self.statedata.timer = 0
	end,
	on_step = function(self, mob, dtime)
		-- Perform the follow check periodically
		self.statedata.timer = self.statedata.timer + dtime
		if self.statedata.timer < FOLLOW_CHECK_TIME then
			return
		end
		self.statedata.timer = 0

		local s = mob.object:get_pos()
		local objs = minetest.get_objects_inside_radius(s, VIEW_RANGE)

		-- Look for other horny mob nearby
		if mob._horny then
			if mob._temp_custom_state.follow_partner == nil then
				local min_dist, closest_partner
				local min_dist_h, closest_partner_h
				for o=1, #objs do
					local obj = objs[o]
					local ent = obj:get_luaentity()
					-- Find other mob of same species
					if obj ~= mob.object and ent and ent._cmi_is_mob and ent.name == "rp_mobs_mobs:boar" and not ent._child then
						local p = obj:get_pos()
						local dist = vector.distance(s, p)
						-- Find closest one
						if dist <= VIEW_RANGE then
							-- Closest partner
							if ((not min_dist) or dist < min_dist) then
								min_dist = dist
								closest_partner = obj
							end
							-- Closest horny partner
							if ent._horny and ((not min_dist_h) or dist < min_dist_h) then
								min_dist_h = dist
								closest_partner_h = obj
							end
						end
					end
				end
				-- Set new partner to follow (prefer horny)
				if closest_partner_h then
					mob._temp_custom_state.follow_partner = closest_partner_h
				elseif closest_partner then
					mob._temp_custom_state.follow_partner = closest_partner
				end
			-- Unfollow partner if out of range
			elseif mob._temp_custom_state.follow_partner:get_luaentity() then
				local p = mob._temp_custom_state.follow_partner:get_pos()
				local dist = vector.distance(s, p)
				-- Out of range
				if dist > VIEW_RANGE then
					mob._temp_custom_state.follow_partner = nil
				end
			else
				-- Partner object is gone
				mob._temp_custom_state.follow_partner = nil
			end
		end

		if (mob._temp_custom_state.follow_player == nil) then
			-- Mark closest player holding food within view range as player to follow
			local p, dist
			local min_dist, closest_player
			for o=1, #objs do
				local obj = objs[o]
				if obj:is_player() then
					local player = obj
					p = player:get_pos()
					dist = vector.distance(s, p)
					if dist <= VIEW_RANGE and ((not min_dist) or dist < min_dist) then
						local wield = player:get_wielded_item()
						-- Is holding food?
						for f=1, #FOOD do
							if wield:get_name() == FOOD[f] then
								min_dist = dist
								closest_player = player
								break
							end
						end
					end
				end
			end
			if closest_player then
				mob._temp_custom_state.follow_player = closest_player:get_player_name()
			end
		else
			-- Unfollow player if out of view range or not holding food
			local player = minetest.get_player_by_name(mob._temp_custom_state.follow_player)
			if player then
				local p = player:get_pos()
				local dist = vector.distance(s, p)
				-- Out of range
				if dist > VIEW_RANGE then
					mob._temp_custom_state.follow_player = nil
				else
					local wield = player:get_wielded_item()
					for f=1, #FOOD do
						if wield:get_name() == FOOD[f] then
							return
						end
					end
					-- Not holding food
					mob._temp_custom_state.follow_player = nil
					return
				end
			end
		end
	end,
	is_finished = function()
		return false
	end,
})

local follow_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="find player to follow"})
	rp_mobs.add_microtask_to_task(mob, mt_find_follow, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

local call_sound_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="random call sound"})
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(RANDOM_SOUND_TIMER_MIN, RANDOM_SOUND_TIMER_MAX)/1000)
	local mt_call = rp_mobs.create_microtask({
		label = "play call sound",
		singlestep = true,
		on_step = function(self, mob, dtime)
			rp_mobs.default_mob_sound(mob, "call", false)
		end
	})
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
	rp_mobs.add_microtask_to_task(mob, mt_call, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
rp_mobs.register_mob("rp_mobs_mobs:boar", {
	description = S("Boar"),
	is_animal = true,
	drops = {"rp_mobs_mobs:pork_raw"},
	default_sounds = {
		death = "mobs_boar_die",
		damage = "mobs_boar_hurt",
		eat = "mobs_eat",
		call = "mobs_boar_call",
		give_birth = "mobs_boar_give_birth",
		horny = "mobs_boar_horny",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
	textures_child = { "mobs_boar_child.png" },
	front_body_point = vector.new(0, -0.4, 0.5),
	entity_definition = {
		initial_properties = {
			hp_max = 20,
			physical = true,
			collisionbox = {-0.49, -1, -0.49, 0.49, 0.1, 0.49},
			selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
			visual = "mesh",
			mesh = "mobs_boar.x",
			textures = { "mobs_boar.png" },
			makes_footstep_sound = true,
			stepheight = 0.6,
		},
		on_activate = function(self, staticdata)
			rp_mobs.restore_state(self, staticdata)

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 10,
				drowning_point = vector.new(0, -0.1, 0.49)
			})
			rp_mobs.init_node_damage(self, true)

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(roam_decider, roam_decider_step))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(follow_decider))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(call_sound_decider))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.advance_child_growth(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame_breed(self, clicker, FOOD, 8, true)
			rp_mobs.call_on_capture(self, clicker)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 5, ["rp_mobs:lasso"] = 40 })
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
