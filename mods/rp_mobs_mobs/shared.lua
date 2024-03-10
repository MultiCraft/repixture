-- Scan for players/mobs and update the following state every this many seconds
local FOLLOW_CHECK_TIME = 1.0

-- When trying to find a safe spot, the mob makes multiple raycasts
-- from the mob all around the mob horizontally. This number is
-- the angle difference in degrees between each ray.
local FIND_LAND_ANGLE_STEP = 15

-- Returns true if the given node (by node name) is a liquid
rp_mobs_mobs.is_liquid = function(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and (ndef.liquid_move_physics == true or (ndef.liquid_move_physics == nil and ndef.liquidtype ~= "none"))
end

-- Returns true if node deals damage
rp_mobs_mobs.is_damaging = function(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and ndef.damage_per_second > 0
end

-- Returns true if node is walkable
rp_mobs_mobs.is_walkable = function(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and ndef.walkable
end

-- Returns true if the node(s) in front of the mob are safe.
-- This is considered unsafe:
-- * damage_per_second > 0
-- * drowning > 0
-- * a drop, if greater than cliff_depth
-- * a drop on a node with high fall_damage_add_percent
-- 
-- Parameters:
-- * mob: Mob object to check
-- * cliff_depth: How deep the mob is allowed to fall
-- * max_fall_damage_add_percent_drop_on: (optional): If set, mob can
--   not fall on a node with a fall_damage_add_percent group that is higher or equal than this value
rp_mobs_mobs.is_front_safe = function(mob, cliff_depth, max_fall_damage_add_percent_drop_on)
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
			if cdef.drowning > 0 then
				return false
			elseif cdef.damage_per_second > 0 then
				return false
			elseif cdef.walkable then
				-- Mob doesn't like to land on node with high fall damage addition
				if max_fall_damage_add_percent_drop_on and c > 1 and minetest.get_item_group(cnode.name, "fall_damage_add_percent") >= max_fall_damage_add_percent_drop_on then
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
-- * find_land_length: How far the mob looks away for safe land (raycast length)
--
-- returns: <position>, <angle from position>
-- or nil, nil if no position found
rp_mobs_mobs.find_land_from_liquid = function(pos, find_land_length)
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
		vec = vector.multiply(vec, find_land_length)
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

-- Arguments:
-- * pos: Start position
-- * find_land_length: How far the mob looks away for safe land (raycast length)
--
-- returns: <position>, <angle from position>
-- or nil, nil if no position found
rp_mobs_mobs.find_safe_node_from_pos = function(pos)
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
		vec = vector.multiply(vec, find_land_length)
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

-- Add a "stand still" task to the mob's task queue with
-- an optional yaw
rp_mobs_mobs.add_halt_to_task_queue = function(task_queue, mob, set_yaw, idle_min, idle_max)
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(idle_min, idle_max)/1000)
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
	local mt_acceleration = rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR)

	rp_mobs.add_microtask_to_task(mob, mt_acceleration, task)
	if set_yaw then
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task)
	end
	rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.move_straight(vel, yaw, vector.new(0.5,0,0.5), 1), task)
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

-- This function creates and returns a microtask thta scans the
-- mob's surroundings within view_range for other interesting entities:
-- 1) Players holding food
-- 2) Mobs of same species to mate with
-- The result is stored in mob._temp_custom_state.follow_partner
-- and mob._temp_custom_state.follow_player.
-- This microtask only *searches* for suitable targets to follow,
-- it does *NOT* actually follow them. Other microtasks
-- are supposed to decide what do do with this information.
-- Parameters:
-- * view_range: Range in which mob can detect other objects
-- * foodlist: List of food items the mob likes to follow (itemstrings)
rp_mobs_mobs.microtask_find_follow = function(view_range, foodlist)
	return rp_mobs.create_microtask({
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
			local objs = minetest.get_objects_inside_radius(s, view_range)

			-- Look for other horny mob nearby
			if mob._horny then
				if mob._temp_custom_state.follow_partner == nil then
					local min_dist, closest_partner
					local min_dist_h, closest_partner_h
					for o=1, #objs do
						local obj = objs[o]
						local ent = obj:get_luaentity()
						-- Find other mob of same species
						if obj ~= mob.object and ent and ent._cmi_is_mob and ent.name == mob.name and not ent._child then
							local p = obj:get_pos()
							local dist = vector.distance(s, p)
							-- Find closest one
							if dist <= view_range then
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
					if dist > view_range then
						mob._temp_custom_state.follow_partner = nil
					end
				else
					-- Partner object is gone
					mob._temp_custom_state.follow_partner = nil
				end
			else
				-- Unfollow partner if no longer horny
				mob._temp_custom_state.follow_partner = nil
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
						if dist <= view_range and ((not min_dist) or dist < min_dist) then
							local wield = player:get_wielded_item()
							-- Is holding food?
							for f=1, #foodlist do
								if wield:get_name() == foodlist[f] then
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
					if dist > view_range then
						mob._temp_custom_state.follow_player = nil
					else
						local wield = player:get_wielded_item()
						for f=1, #foodlist do
							if wield:get_name() == foodlist[f] then
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
end
