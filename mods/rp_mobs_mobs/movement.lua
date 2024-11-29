-- Scan for players/mobs and update the following state every this many seconds
local FOLLOW_CHECK_TIME = 1.0

-- This function creates and returns a microtask that scans the
-- mob's surroundings within view_range for players.
-- The result is stored in mob._temp_custom_state.closest_player.
-- Parameters:
-- * view_range: Range in which mob can detect players
rp_mobs_mobs.microtasks.player_find_follow = function(view_range)
	return rp_mobs.create_microtask({
		label = "find player to follow",
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
			if (mob._temp_custom_state.closest_player == nil) then
				-- Mark closest player within view range as player to follow
				local p, dist
				local min_dist, closest_player
				local objs = minetest.get_objects_inside_radius(s, view_range)
				for o=1, #objs do
					local obj = objs[o]
					if obj:is_player() and obj:get_hp() > 0 then
						local player = obj
						p = player:get_pos()
						dist = vector.distance(s, p)
						if dist <= view_range and ((not min_dist) or dist < min_dist) then
							min_dist = dist
							closest_player = player
							break
						end
					end
				end
				if closest_player then
					mob._temp_custom_state.closest_player = closest_player
				end
			else
				-- Unfollow player if out of view range, dead or gone
				local player = mob._temp_custom_state.closest_player
				local p = player and player:get_pos()
				if p then
					local dist = vector.distance(s, p)
					-- Out of range
					if dist > view_range then
						mob._temp_custom_state.closest_player = nil
					elseif player:get_hp() == 0 then
						mob._temp_custom_state.closest_player = nil
					end
				else
					mob._temp_custom_state.closest_player = nil
				end
			end
		end,
		is_finished = function()
			return false
		end,
	})
end

-- Creates and returns a task queue that exclusively performs the
-- 'player_find_follow' microtask. Provided for convenience.
-- See `rp_mobs_mobs.microtasks.player_find_follow` for details.
-- Parameters:
-- * view_range: Range in which mob can detect players
rp_mobs_mobs.task_queues.player_follow_scan = function(view_range)
	local decider = function(task_queue, mob)
		local task = rp_mobs.create_task({label="scan for entities to follow"})
		local mt_find_follow = rp_mobs_mobs.microtasks.player_find_follow(view_range)
		rp_mobs.add_microtask_to_task(mob, mt_find_follow, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
	local tq = rp_mobs.create_task_queue(decider)
	return tq
end

-- This function creates and returns a microtask that scans the
-- mob's surroundings within view_range for other interesting entities:
-- 1) Players holding food
-- 2) Mobs of same species to mate with
-- The result is stored in mob._temp_custom_state.closest_mating_partner
-- and mob._temp_custom_state.closest_food_player.
-- This microtask only *searches* for suitable targets to follow,
-- it does *NOT* actually follow them. Other microtasks
-- are supposed to decide what do do with this information.
-- Parameters:
-- * view_range: Range in which mob can detect other objects
-- * food_list: List of food items the mob likes to follow (itemstrings)
rp_mobs_mobs.microtasks.food_breed_find_follow = function(view_range, food_list)
	return rp_mobs.create_microtask({
		label = "find entities to follow (partners and players holding food)",
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
				if mob._temp_custom_state.closest_mating_partner == nil then
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
						mob._temp_custom_state.closest_mating_partner = closest_partner_h
					elseif closest_partner then
						mob._temp_custom_state.closest_mating_partner = closest_partner
					end
				-- Unfollow partner if out of range
				elseif mob._temp_custom_state.closest_mating_partner:get_luaentity() then
					local p = mob._temp_custom_state.closest_mating_partner:get_pos()
					local dist = vector.distance(s, p)
					-- Out of range
					if dist > view_range then
						mob._temp_custom_state.closest_mating_partner = nil
					end
				else
					-- Partner object is gone
					mob._temp_custom_state.closest_mating_partner = nil
				end
			else
				-- Unfollow partner if no longer horny
				mob._temp_custom_state.closest_mating_partner = nil
			end

			if (mob._temp_custom_state.closest_food_player == nil) then
				-- Mark closest player holding food within view range as player to follow
				local p, dist
				local min_dist, closest_player
				for o=1, #objs do
					local obj = objs[o]
					if obj:is_player() and obj:get_hp() > 0 then
						local player = obj
						p = player:get_pos()
						dist = vector.distance(s, p)
						if dist <= view_range and ((not min_dist) or dist < min_dist) then
							local wield = player:get_wielded_item()
							-- Is holding food?
							for f=1, #food_list do
								if wield:get_name() == food_list[f].name then
									min_dist = dist
									closest_player = player
									break
								end
							end
						end
					end
				end
				if closest_player then
					mob._temp_custom_state.closest_food_player = closest_player
				end
			else
				-- Unfollow player if out of view range or not holding food
				local player = mob._temp_custom_state.closest_food_player
				if player then
					local p = player:get_pos()
					local dist = vector.distance(s, p)
					-- Non-player or dead
					if not player:is_player() or player:get_hp() == 0 then
						mob._temp_custom_state.closest_food_player = nil
					-- Out of range
					elseif dist > view_range then
						mob._temp_custom_state.closest_food_player = nil
					-- Not holding food
					else
						local wield = player:get_wielded_item()
						for f=1, #food_list do
							if wield:get_name() == food_list[f].name then
								return
							end
						end
						mob._temp_custom_state.closest_food_player = nil
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

-- Creates and returns a task queue that exclusively performs the 'find_follow'
-- microtask. Provided for convenience.
-- See `rp_mobs_mobs.microtasks.food_breed_find_follow` for details.
-- Parameters:
-- * view_range: Range in which mob can detect other objects
-- * food_list: List of food items the mob likes to follow (itemstrings)
rp_mobs_mobs.task_queues.food_breed_follow_scan = function(view_range, food_list)
	local decider = function(task_queue, mob)
		local task = rp_mobs.create_task({label="scan for entities to follow"})
		local mt_find_follow = rp_mobs_mobs.microtasks.food_breed_find_follow(view_range, food_list)
		rp_mobs.add_microtask_to_task(mob, mt_find_follow, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
	local tq = rp_mobs.create_task_queue(decider)
	return tq
end

-- Creates and returns a task queue that randomly plays the mob's 'call'
-- sound from time to time.
-- Parameters:
-- * sound_timer_min: Minimum time between call sounds (milliseconds)
-- * sound_timer_max: Maximum time between call sounds (milliseconds)
rp_mobs_mobs.task_queues.call_sound = function(sound_timer_min, sound_timer_max)
	local decider = function(task_queue, mob)
		local task = rp_mobs.create_task({label="random call sound"})
		local mt_sleep = rp_mobs.microtasks.sleep(math.random(sound_timer_min, sound_timer_max)/1000)
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
	local tq = rp_mobs.create_task_queue(decider)
	return tq
end


