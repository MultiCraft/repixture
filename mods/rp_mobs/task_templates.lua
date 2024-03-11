local PATH_DEBUG = true
local PATH_DISTANCE_TO_GOAL_POINT = 0.7
local YAW_PRECISION = 10000
local JUMP_REPEAT_TIME = 1

-- if the ratio of the current walk speed to the
-- target walk speed is lower than this number,
-- the mob will reset the walk speed
local WALK_SPEED_RESET_THRESHOLD = 0.9

-- if the ratio of the current walk angle to the
-- target walk angle is lower than this number,
-- the mob will reset the walk angle
local WALK_ANGLE_RESET_THRESHOLD = 0.99

local MOVE_SPEED_MAX_DIFFERENCE = 0.01

local show_pathfinder_path = function(path)
	local pathstr = ""
	for p=1, #path do
		local tex
		if p == 1 then
			tex = "rp_mobs_debug_pathfinder_waypoint_start.png"
		elseif p == #path then
			tex = "rp_mobs_debug_pathfinder_waypoint_end.png"
		else
			tex = "rp_mobs_debug_pathfinder_waypoint.png"
		end
		minetest.add_particle({
			pos = path[p],
			expirationtime = 1,
			size = 2,
			texture = tex,
			glow = minetest.LIGHT_MAX,
		})
	end
end

local random_yaw = function()
	return (math.random(0, YAW_PRECISION) / YAW_PRECISION) * (math.pi*2)
end

-- Task templates

rp_mobs.tasks = {}

-- Microtask templates

rp_mobs.microtasks = {}

rp_mobs.microtasks.pathfind_and_walk_to = function(target_pos, searchdistance, max_jump, max_drop)
	local mtask = {}
	mtask.label = "pathfind and walk to coordinate"
	mtask.on_step = function(self, mob, dtime)
		if self.statedata.moving == nil then
			self.statedata.moving = false
		end
		local start_pos = mob.object:get_pos()
		start_pos.y = math.floor(start_pos.y)
		start_pos = vector.round(start_pos)
		local path = self.statedata.path
		if not path then
			path = minetest.find_path(start_pos, target_pos, searchdistance, max_jump, max_drop, "A*")
			self.statedata.path = path
		end
		if not path then
			minetest.log("error", "[rp_mobs] pathfind_and_walk_to: Mob can't find target")
			return
		end
		if PATH_DEBUG then
			show_pathfinder_path(path)
		end
		local next_pos = path[1]
		local mob_pos = mob.object:get_pos()
		if path[2] then
			local dist_mob_to_next = vector.distance(mob_pos, next_pos)
			local dist_mob_to_next_next = vector.distance(mob_pos, path[2])
			if dist_mob_to_next < PATH_DISTANCE_TO_GOAL_POINT or dist_mob_to_next_next < dist_mob_to_next then
				table.remove(path, 1)
				self.statedata.path = path
				if #path == 0 then
					return
				end
				next_pos = path[1]
			end
		end
		-- Pretend that next_pos is on same height as the mob so the direction
		-- vector is always horizontal
		local dir_next_pos = table.copy(next_pos)
		dir_next_pos.y = mob_pos.y
		local dir = vector.direction(mob_pos, dir_next_pos)
		local dist = vector.distance(mob_pos, dir_next_pos)
		if vector.length(dir) > 0.001 and dist > 0.1 then
			mob.object:set_velocity(dir)
			self.statedata.moving = true
		else
			if self.statedata.moving ~= false then
				mob.object:set_velocity(vector.zero())
				self.statedata.moving = false
			end
		end
	end
	mtask.is_finished = function(self, mob)
		local pos = mob.object:get_pos()
		return vector.distance(pos, target_pos) < PATH_DISTANCE_TO_GOAL_POINT
	end
	mtask.on_end = function(self, mob)
		mob.object:set_velocity(vector.zero())
	end
	return rp_mobs.create_microtask(mtask)
end

-- Set yaw instantly
rp_mobs.microtasks.set_yaw = function(yaw)
	local label
	if yaw == "random" then
		label = "set yaw randomly"
	else
		label = "set yaw to "..string.format("%.3f", yaw)
	end
	return rp_mobs.create_microtask({
		label = label,
		singlestep = true,
		on_step = function(self, mob, dtime)
			if yaw == "random" then
				yaw = random_yaw()
			end
			mob.object:set_yaw(yaw)
		end,
	})
end

local collides_with_wall = function(moveresult, include_objects)
	if moveresult and moveresult.collides then
		for c=1, #moveresult.collisions do
			local coll = moveresult.collisions[c]
			if (coll.type == "node" or (coll.type == "object" and include_objects)) and (coll.axis == "x" or coll.axis == "z") then
				return true, coll
			end
		end
	end
	return false
end

-- Move in a straight line on any axis
-- * move_vector: velocity vector to target.
-- * yaw: look direction in radians
-- * drag: (optional) if set as a vector, will adjust the velocity smoothly towards the target
--   velocity, with higher axis values leading to faster change. If unset, will set
--   velocity instantly. If drag is 0 or very small on an axis, this axis will see no velocity change
-- * max_timer: automatically finish microtask after this many seconds (nil = infinite)
rp_mobs.microtasks.move_straight = function(move_vector, yaw, drag, max_timer)
	local label
	if max_timer then
		label = "move straight for "..string.format("%.1f", max_timer).."s"
	else
		label = "move straight"
	end
	return rp_mobs.create_microtask({
		label = label,
		on_start = function(self, mob)
			self.statedata.stop = false -- is set to true if microtask is supposed to be finished after the current step finishes
			self.statedata.timer = 0 -- how long this microtask has been going, in seconds
		end,
		on_step = function(self, mob, dtime, moveresult)
			self.statedata.timer = self.statedata.timer + dtime
			if max_timer and self.statedata.timer >= max_timer then
				self.statedata.stop = true
				mob.object:set_velocity(vector.zero())
				return
			end
			local vel = move_vector
			local realvel = mob.object:get_velocity()
			local targetvel = table.copy(vel)
			local changevel = false
			if drag then
				for _, axis in pairs({"x","y","z"}) do
					if drag[axis] > 0.001 and math.abs(targetvel[axis] - realvel[axis]) > MOVE_SPEED_MAX_DIFFERENCE then
						if realvel[axis] > targetvel[axis] then
							targetvel[axis] = math.max(targetvel[axis], realvel[axis] - drag[axis])
						else
							targetvel[axis] = math.min(targetvel[axis], realvel[axis] + drag[axis])
						end
						changevel = true
					end
				end
			else
				changevel = true
				self.statedata.stop = true
			end
			if changevel then
				mob.object:set_velocity(targetvel)
			else
				self.statedata.stop = true
			end
		end,
		is_finished = function(self, mob)
			if self.statedata.stop then
				return true
			end
			return false
		end
	})
end

-- Walk in a straight line, jumping if hitting obstable and jump~=nil
-- * yaw: walk direction in radians
-- * jump: jump strength if mob needs to jump or nil if no jumping
-- * max_timer: automatically finish microtask after this many seconds (nil = infinite)
rp_mobs.microtasks.walk_straight = function(walk_speed, yaw, jump, max_timer)
	local label
	if max_timer then
		label = "walk straight for "..string.format("%.1f", max_timer).."s"
	else
		label = "walk straight"
	end
	return rp_mobs.create_microtask({
		label = label,
		on_start = function(self, mob)
			self.statedata.jumping = false -- is true when mob is currently jumpin
			self.statedata.jump_timer = 0 -- timer counting the time of the current jump, in seconds
			self.statedata.stop = false -- is set to true if microtask is supposed to be finished after the current step finishes
			self.statedata.timer = 0 -- how long this microtask has been going, in seconds
		end,
		on_step = function(self, mob, dtime, moveresult)
			self.statedata.timer = self.statedata.timer + dtime
			local vel = mob.object:get_velocity()
			if max_timer and self.statedata.timer >= max_timer then
				self.statedata.stop = true
				vel.x = 0
				vel.z = 0
				mob.object:set_velocity(vel)
				return
			end
			if self.statedata.jumping then
				self.statedata.jump_timer = self.statedata.jump_timer + dtime
				if self.statedata.jump_timer >= JUMP_REPEAT_TIME then
					if moveresult.touching_ground then
						self.statedata.jumping = false
					end
				end
			end
			local wall_collision, wall_collision_data = collides_with_wall(moveresult, true)
			if wall_collision and wall_collision_data.type == "object" then
				self.statedata.stop = true
				vel.x = 0
				vel.z = 0
				mob.object:set_velocity(vel)
				return
			end

			-- Jump
			if jump and not self.statedata.jumping and moveresult.touching_ground and wall_collision then
				local can_jump = true
				-- Can't jump if standing on a disable_jump node
				if mob._env_node_floor then
					local floordef = minetest.registered_nodes[mob._env_node_floor.name]
					if floordef.walkable and minetest.get_item_group(mob._env_node_floor.name, "disable_jump") > 0 then
						can_jump = false
					end
				end
				-- Can't jump inside a disable_jump node either
				if can_jump and mob._env_node then
					local def = minetest.registered_nodes[mob._env_node.name]
					if minetest.get_item_group(mob._env_node.name, "disable_jump") > 0 then
						can_jump = false
					end
				end
				if can_jump then
					self.statedata.jumping = true
					self.statedata.jump_timer = 0
					vel.y = jump
				end
			end

			vel.x = math.sin(yaw) * -walk_speed
			vel.z = math.cos(yaw) * walk_speed
			local realvel_hor = mob.object:get_velocity()
			realvel_hor.y = 0
			local targetvel_hor = table.copy(vel)
			targetvel_hor.y = 0
			if (vector.length(realvel_hor) < WALK_SPEED_RESET_THRESHOLD * vector.length(targetvel_hor)) or
					(0.01 > math.abs(vector.angle(vector.zero(), realvel_hor) - vector.angle(vector.zero(), targetvel_hor))) then
				mob.object:set_velocity(vel)
			end
		end,
		is_finished = function(self, mob)
			if self.statedata.stop then
				return true
			end
			return false
		end
	})
end

-- Walk in a straight line towards a position or object
-- * walk_speed: walk speed
-- * target_type: "pos" (position) or "object"
-- * target: target, depending on target_type: position or object handle
-- * set_yaw: If true, will set mob's yaw to face target
-- * reach_distance: If mob is within this distance towards target, finish task
-- * jump: jump strength if mob needs to jump or nil if no jumping
-- * max_timer: automatically finish microtask after this many seconds (nil = infinite)
rp_mobs.microtasks.walk_straight_towards = function(walk_speed, target_type, target, set_yaw, reach_distance, jump, max_timer)
	local label
	if max_timer then
		label = "walk towards something for "..string.format("%.1f", max_timer).."s"
	else
		label = "walk towards something"
	end
	return rp_mobs.create_microtask({
		label = label,
		on_start = function(self, mob)
			self.statedata.jumping = false -- is true when mob is currently jumpin
			self.statedata.stop = false -- is set to true if microtask is supposed to be finished after the current step finishes
			self.statedata.timer = 0 -- how long this microtask has been going, in seconds
		end,
		on_step = function(self, mob, dtime, moveresult)
			self.statedata.timer = self.statedata.timer + dtime
			local vel = mob.object:get_velocity()
			local oldvel = mob.object:get_velocity()
			if max_timer and self.statedata.timer >= max_timer then
				self.statedata.stop = true
				vel.x = 0
				vel.z = 0
				mob.object:set_velocity(vel)
				return
			end
			if self.statedata.jumping then
				self.statedata.jump_timer = self.statedata.jump_timer + dtime
				if self.statedata.jump_timer >= JUMP_REPEAT_TIME then
					if moveresult.touching_ground then
						self.statedata.jumping = false
					end
				end
			end
			local wall_collision, wall_collision_data = collides_with_wall(moveresult, true)
			if wall_collision and wall_collision_data.type == "object" then
				self.statedata.stop = true
				vel.x = 0
				vel.z = 0
				mob.object:set_velocity(vel)
				return
			end

			-- Get target position
			local mypos = mob.object:get_pos()
			local dir
			if target_type == "pos" then
				dir = vector.direction(mypos, target)
			elseif target_type == "object" then
				local tpos = target:get_pos()
				dir = vector.direction(mypos, tpos)
			else
				self.statedata.stop = true
				return
			end

			-- Face target
			local yaw = minetest.dir_to_yaw(dir)
			if set_yaw then
				mob.object:set_yaw(yaw)
			end

			-- Jump
			if jump and not self.statedata.jumping and moveresult.touching_ground and wall_collision then
				local can_jump = true
				-- Can't jump if standing on a disable_jump node
				if mob._env_node_floor then
					local floordef = minetest.registered_nodes[mob._env_node_floor.name]
					if floordef.walkable and minetest.get_item_group(mob._env_node_floor.name, "disable_jump") > 0 then
						can_jump = false
					end
				end
				-- Can't jump inside a disable_jump node either
				if can_jump and mob._env_node then
					local def = minetest.registered_nodes[mob._env_node.name]
					if minetest.get_item_group(mob._env_node.name, "disable_jump") > 0 then
						can_jump = false
					end
				end
				if can_jump then
					self.statedata.jumping = true
					self.statedata.jump_timer = 0
					vel.y = jump
				end
			end

			vel.x = math.sin(yaw) * -walk_speed
			vel.z = math.cos(yaw) * walk_speed
			local realvel_hor = mob.object:get_velocity()
			realvel_hor.y = 0
			local targetvel_hor = table.copy(vel)
			targetvel_hor.y = 0
			if (vector.length(realvel_hor) < WALK_SPEED_RESET_THRESHOLD * vector.length(targetvel_hor)) or
					(0.01 > math.abs(vector.angle(vector.zero(), realvel_hor) - vector.angle(vector.zero(), targetvel_hor))) then
				mob.object:set_velocity(vel)
			end
		end,
		is_finished = function(self, mob)
			if self.statedata.stop then
				return true
			end
			local mypos = mob.object:get_pos()
			local tpos
			if target_type == "pos" then
				tpos = table.copy(target)
			elseif target_type == "object" then
				if not target then
					return true
				end
				tpos = target:get_pos()
				if not tpos then
					return true
				end
			else
				minetest.log("error", "[rp_mobs] Incorrect target_type provided in rp_mobs.microtask.walk_straight_towards!")
				return true
			end
			mypos.y = 0
			tpos.y = 0
			if vector.distance(mypos, tpos) <= reach_distance then
				return true
			else
				return false
			end
		end,
		on_end = function(self, mob)
			mob.object:set_velocity(vector.zero())
		end,
	})
end

-- Rotate yaw linearly over time
rp_mobs.microtasks.rotate_yaw_smooth = function(yaw, time)
	local label
	if yaw == "random" then
		label = "rotate yaw randomly"
	else
		label = "rotate yaw to "..string.format("%.3f", yaw)
	end
	return rp_mobs.create_microtask({
		label = label,
		on_step = function(self, mob, dtime)
			local sd = self.statedata
			if not sd.target_yaw then
				if yaw == "random" then
					yaw = random_yaw()
				end
				sd.target_yaw = yaw
			end
			if not sd.start_yaw then
				sd.start_yaw = mob.object:get_yaw()
			end
			if not sd.timer then
				sd.timer = 0
			end
			sd.timer = sd.timer + dtime
			local timer = math.min(sd.timer, time)
			local time_progress = 1 - ((time - timer) / time)

			local current_yaw = sd.start_yaw + (sd.target_yaw - sd.start_yaw) * time_progress
			mob.object:set_yaw(current_yaw)
		end,
		is_finished = function(self, mob)
			return self.statedata.timer and self.statedata.timer >= time
		end,
	})
end

-- Set yaw based on XZ velocity
rp_mobs.microtasks.autoyaw = function()
	return rp_mobs.create_microtask({
		label = "automatically set yaw",
		singlestep = true,
		on_step = function(self, mob, dtime)
			local vel = mob.object:get_velocity()
			vel.y = 0
			-- Only set yaw if moving
			if vector.length(vel) > 0.001 then
				vel = vector.normalize(vel)
				local yaw = minetest.dir_to_yaw(vel)
				mob.object:set_yaw(yaw)
			end
		end,
	})
end

-- Do nothing for the given time in seconds
rp_mobs.microtasks.sleep = function(time)
	return rp_mobs.create_microtask({
		label = "sleep for "..time.."s",
		on_step = function(self, mob, dtime)
			if not self.statedata.sleeptimer then
				self.statedata.sleeptimer = 0
			end
			self.statedata.sleeptimer = self.statedata.sleeptimer + dtime
		end,
		is_finished = function(self, mob)
			return self.statedata.sleeptimer and self.statedata.sleeptimer >= time
		end
	})
end

-- Instantly set mob acceleration to the given parameter
rp_mobs.microtasks.set_acceleration = function(acceleration)
	return rp_mobs.create_microtask({
		label = "set acceleration",
		singlestep = true,
		on_step = function(self, mob, dtime)
			mob.object:set_acceleration(acceleration)
		end,
	})
end

