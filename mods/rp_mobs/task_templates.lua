local PATH_DEBUG = true
local PATH_DISTANCE_TO_GOAL_POINT = 0.7
local YAW_PRECISION = 10000

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
			minetest.log("error", "can't find target")
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
			mob._mob_velocity = dir
			mob._mob_velocity_changed = true
			self.statedata.moving = true
		else
			if self.statedata.moving ~= false then
				mob._mob_velocity = vector.zero()
				mob._mob_velocity_changed = true
				self.statedata.moving = false
			end
		end
	end
	mtask.is_finished = function(self, mob)
		local pos = mob.object:get_pos()
		return vector.distance(pos, target_pos) < PATH_DISTANCE_TO_GOAL_POINT
	end
	mtask.on_end = function(self, mob)
		mob._mob_velocity = vector.zero()
		mob._mob_velocity_changed = true
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

-- Walk in a straight line, ignoring obstacles. No finish condition
rp_mobs.microtasks.walk_straight = function(walk_speed, yaw)
	return rp_mobs.create_microtask({
		label = "walk straight",
		on_step = function(self, mob, dtime)
			local vel = vector.new()
			vel.y = 0
			vel.x = math.sin(yaw) * -walk_speed
			vel.z = math.cos(yaw) * walk_speed
			if not self.statedata.vel_set then
				mob._mob_velocity.x = vel.x
				mob._mob_velocity.y = vel.y
				mob._mob_velocity.z = vel.z
				mob._mob_velocity_changed = true
				self.statedata.vel_set = true
			end
		end,
		is_finished = function()
			-- never finishes; must be aborted
			return false
		end
	})
end

-- Walk in a straight line towards a position or object
rp_mobs.microtasks.walk_straight_towards = function(walk_speed, target_type, target, reach_distance)
	return rp_mobs.create_microtask({
		label = "walk towards something",
		on_step = function(self, mob, dtime)
			local vel = vector.new()
			local mypos = mob.object:get_pos()
			local dir
			if target_type == "pos" then
				dir = vector.direction(mypos, target)
			elseif target_type == "object" then
				local tpos = target:get_pos()
				dir = vector.direction(mypos, tpos)
			else
				return
			end
			local yaw = minetest.dir_to_yaw(dir)
			vel.y = 0
			vel.x = math.sin(yaw) * -walk_speed
			vel.z = math.cos(yaw) * walk_speed
			if not self.statedata.vel_set or target_type == "object" then
				mob._mob_velocity.x = vel.x
				mob._mob_velocity.y = vel.y
				mob._mob_velocity.z = vel.z
				mob._mob_velocity_changed = true
				if target_type == "pos" then
					self.statedata.vel_set = true
				end
			end
		end,
		is_finished = function(self, mob)
			local mypos = mob.object:get_pos()
			local tpos
			if target_type == "pos" then
				tpos = table.copy(target)
			elseif target_type == "object" then
				tpos = target:get_pos()
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
			mob._mob_velocity = vector.zero()
			mob._mob_velocity_changed = true
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

-- DUMMY TEMPLATES (need to do better later)

rp_mobs.microtasks.jump = function(strength)
	return rp_mobs.create_microtask({
		label = "jump",
		singlestep = true,
		on_step = function(self, mob)
			mob.object:add_velocity({x=0, y=strength, z=0})
		end,
	})
end

rp_mobs.microtasks.go_to_x = function(target_x, tolerance)
	return rp_mobs.create_microtask({
		label = "move to x coordinate",
		on_step = function(self, mob)
			local pos = mob.object:get_pos()
			if pos.x > target_x then
				if mob._mob_velocity.x < -1.001 or mob._mob_velocity.x > -0.999 then
					mob._mob_velocity.x = -1
					mob._mob_velocity_changed = true
				end
			else
				if mob._mob_velocity.x > 1.001 or mob._mob_velocity.x < 0.999 then
					mob._mob_velocity.x = 1
					mob._mob_velocity_changed = true
				end
			end
		end,
		is_finished = function(self, mob)
			local pos = mob.object:get_pos()
			if math.abs(pos.x - target_x) <= tolerance then
				return true
			else
				return false
			end
		end,
		on_end = function(self, mob)
			mob._mob_velocity = vector.zero()
			mob._mob_velocity_changed = true
		end,
	})
end
