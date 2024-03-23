rp_mobs_mobs.microtasks = {}
rp_mobs_mobs.tasks = {}
rp_mobs_mobs.task_queues = {}

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
			if not cdef then
				-- Unknown node
				return false
			elseif cdef.drowning > 0 then
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
	if not rp_mobs_mobs.is_liquid(startnode.name) then
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
							not rp_mobs_mobs.is_walkable(upnode.name) then
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
				if rp_mobs_mobs.is_walkable(upnode.name) then
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
rp_mobs_mobs.find_safe_node_from_pos = function(pos, find_land_length)
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
				if rp_mobs_mobs.is_walkable(floornode.name) then
					if rp_mobs_mobs.is_walkable(upnode.name) then
						break
					elseif not rp_mobs_mobs.is_walkable(upnode.name) and not rp_mobs_mobs.is_damaging(upnode.name) then
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

