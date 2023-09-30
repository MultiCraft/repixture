local PATH_DEBUG = true
local PATH_DISTANCE_TO_GOAL_POINT = 0.7

-- Task templates

rp_mobs.tasks = {}

-- Microtask templates

rp_mobs.microtasks = {}

rp_mobs.microtasks.pathfind_and_walk_to = function(target_pos, searchdistance, max_jump, max_drop)
	local mtask = {}
	mtask.label = "pathfind and walk to coordinate"
	mtask.on_step = function(self, mob)
		local start_pos = mob.object:get_pos()
		start_pos.y = math.floor(start_pos.y)
		start_pos = vector.round(start_pos)
		local path = minetest.find_path(start_pos, target_pos, searchdistance, max_jump, max_drop, "A*")
		if not path then
			minetest.log("error", "can't find target")
			return
		end
		if PATH_DEBUG then
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
		local next_pos = path[1]
		local mob_pos = mob.object:get_pos()
		if path[2] then
			local dist_mob_to_next = vector.distance(mob_pos, next_pos)
			local dist_mob_to_next_next = vector.distance(mob_pos, path[2])
			if dist_mob_to_next < PATH_DISTANCE_TO_GOAL_POINT or dist_mob_to_next_next < dist_mob_to_next then
				table.remove(path, 1)
				if #path == 0 then
					return
				end
				next_pos = path[1]
			end
		end
		local dir = vector.direction(mob_pos, next_pos)
		if vector.length(dir) > 0.001 then
			mob._mob_velocity = dir
			mob._mob_velocity_changed = true
		else
			mob._mob_velocity = vector.zero()
			mob._mob_velocity_changed = true
		end
	end
	mtask.is_finished = function(self, mob)
		local pos = mob.object:get_pos()
		if vector.distance(pos, target_pos) < PATH_DISTANCE_TO_GOAL_POINT then
			-- DEBUG
			minetest.log("error", "target reached")
			return true
		else
			return false
		end
	end
	mtask.on_end = function(self, mob)
		mob._mob_velocity = vector.zero()
		mob._mob_velocity_changed = true
	end
	return mtask
end

-- DUMMY TEMPLATES (need to do better later)

rp_mobs.microtasks.jump = function(strength)
	return {
		label = "jump",
		singlestep = true,
		on_step = function(self, mob)
			mob.object:add_velocity({x=0, y=strength, z=0})
		end,
	}
end

rp_mobs.microtasks.go_to_x = function(target_x, tolerance)
	return {
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
	}
end
