rp_mobs_mobs.microtasks.dogfight = function(attack_range, attack_toolcaps, attack_time)
	return rp_mobs.create_microtask({
		label = "dogfight",
		start_animation = "punch",
		on_start = function(self, mob)
			self.statedata.attack_target = mob._temp_custom_state.angry_at
			-- For attack timer; initialize at attack_time + 1 to guarantee an instant attack
			self.statedata.attack_timer = attack_time + 1
			-- Time of last punch for punch() function
			self.statedata.last_punch = nil
		end,
		on_step = function(self, mob, dtime)
			if self.statedata.last_punch then
				self.statedata.last_punch = self.statedata.last_punch + dtime
			end
			if not self.statedata.attack_target then
				return
			elseif self.statedata.attack_target:get_hp() == 0 then
				return
			end
			local mpos = mob.object:get_pos()
			local tpos = self.statedata.attack_target:get_pos()
			local mpos_h = table.copy(mpos)
			local tpos_h = table.copy(tpos)
			mpos_h.y = 0
			tpos_h.y = 0
			local dir = vector.direction(mpos_h, tpos_h)
			local yaw = minetest.dir_to_yaw(dir)
			mob.object:set_yaw(yaw)
			if not tpos then
				return
			end
			local dist = vector.distance(mpos, tpos)
			if dist <= attack_range then
				self.statedata.attack_timer = self.statedata.attack_timer + dtime
				if self.statedata.attack_timer > attack_time then
					local time_from_last_punch = self.statedata.last_punch or 1000000
					local dir = vector.direction(mpos, tpos)
					rp_mobs.default_mob_sound(mob, "attack")
					self.statedata.attack_target:punch(mob.object, time_from_last_punch, attack_toolcaps, dir)
					self.statedata.attack_timer = 0
				end
			else
				self.statedata.attack_timer = 0
			end
		end,
		is_finished = function(self, mob)
			if self.statedata.attack_target == nil then
				return true
			elseif self.statedata.attack_target:get_hp() == 0 then
				return true
			elseif self.statedata.attack_target._dying then
				return true
			else
				local mpos = mob.object:get_pos()
				local tpos = self.statedata.attack_target:get_pos()
				if not tpos then
					return true
				end
				local dist = vector.distance(mpos, tpos)
				if dist > attack_range then
					return true
				end
			end
			return false
		end,
	})
end

rp_mobs_mobs.create_dogfight_decider = function(attack_range, attack_toolcaps, attack_time)
	return function (task_queue, mob)
		local mt_dogfight = rp_mobs_mobs.microtasks.dogfight
		local task = rp_mobs.create_task({label="dogfight"})
		rp_mobs.add_microtask_to_task(mob, mt_dogfight, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end

rp_mobs_mobs.create_player_angry_decider = function()
	return function (task_queue, mob)
		local mt = rp_mobs.create_microtask({
			label = "mark players as attack target",
			on_step = function(self, mob, dtime)
				-- Children are never angry
				if mob._child then
					return
				end
				-- Closest player becomes target
				if mob._temp_custom_state.closest_player then
					-- Don't change attack target if already set
					if not mob._temp_custom_state.angry_at then
						local player = mob._temp_custom_state.closest_player
						if player and player:is_player() and player:get_hp() > 0 then
							mob._temp_custom_state.angry_at = player
							mob._temp_custom_state.angry_at_timer = 0
						else
							mob._temp_custom_state.angry_at = nil
							mob._temp_custom_state.angry_at_timer = 0
						end
					end
				else
					mob._temp_custom_state.angry_at = nil
					mob._temp_custom_state.angry_at_timer = 0
				end
			end,
			is_finished = function()
				return false
			end,
		})
		local task = rp_mobs.create_task({label="mark players as attack target"})
		rp_mobs.add_microtask_to_task(mob, mt, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end

rp_mobs_mobs.create_angry_cooldown_decider = function(range, cooldown_time)
	return function (task_queue, mob)
		local mt = rp_mobs.create_microtask({
			label = "stop being angry at target when out of range for a time",
			on_start = function(self, mob)
				mob._temp_custom_state.angry_at_timer = 0
			end,
			on_step = function(self, mob, dtime)
				if mob._temp_custom_state.angry_at then
					local mobpos = mob.object:get_pos()
					local targetpos = mob._temp_custom_state.angry_at:get_pos()
					if not targetpos then
						mob._temp_custom_state.angry_at = nil
						mob._temp_custom_state.angry_at_timer = 0
						return
					end
					local dist = vector.distance(mobpos, targetpos)
					if dist > range then
						mob._temp_custom_state.angry_at_timer = mob._temp_custom_state.angry_at_timer + dtime
						if mob._temp_custom_state.angry_at_timer > cooldown_time then
							mob._temp_custom_state.angry_at = nil
							mob._temp_custom_state.angry_at_timer = 0
						end
					else
						mob._temp_custom_state.angry_at_timer = 0
					end
				end
			end,
			is_finished = function()
				return false
			end,
		})
		local task = rp_mobs.create_task({label="anger cooldown"})
		rp_mobs.add_microtask_to_task(mob, mt, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end



rp_mobs_mobs.on_punch_make_hostile = function(mob, puncher, time_from_last_punch, tool_capabilities, dir, damage, ...)
	-- Children are never angry
	if not mob._child and puncher and puncher:is_player() then
		mob._temp_custom_state.angry_at = puncher
		mob._temp_custom_state.angry_at_timer = 0
	end
	return rp_mobs.on_punch_default(mob, puncher, time_from_last_punch, tool_capabilities, dir, damage, ...)
end
