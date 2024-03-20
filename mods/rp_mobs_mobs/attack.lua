rp_mobs_mobs.create_dogfight_microtask = function(attack_range, attack_toolcaps, attack_time)
	return rp_mobs.create_microtask({
		label = "dogfight",
		start_animation = "punch",
		on_start = function(self, mob)
			mob._temp_custom_state.attacking = false
			mob._temp_custom_state.attack_target = nil
			-- For attack timer; initialize at attack_time + 1 to guarantee an instant attack
			self.statedata.attack_timer = attack_time + 1
			-- Time of last punch for punch() function
			self.statedata.last_punch = nil
		end,
		on_step = function(self, mob, dtime)
			if self.statedata.last_punch then
				self.statedata.last_punch = self.statedata.last_punch + dtime
			end
			if not mob._temp_custom_state.attack_target then
				return
			elseif mob._temp_custom_state.attack_target:get_hp() == 0 then
				return
			end
			local mpos = mob.object:get_pos()
			local tpos = mob._temp_custom_state.attack_target:get_pos()
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
					rp_mobs.default_mob_sound(mob, "attack", true)
					mob._temp_custom_state.attack_target:punch(mob.object, time_from_last_punch, attack_toolcaps, dir)
					self.statedata.attack_timer = 0
				end
			else
				self.statedata.attack_timer = 0
			end
		end,
		is_finished = function(self, mob)
			if mob._temp_custom_state.attack_target == nil then
				return true
			elseif mob._temp_custom_state.attack_target:get_hp() == 0 then
				return true
			elseif mob._temp_custom_state.attack_target._dying then
				return true
			else
				local mpos = mob.object:get_pos()
				local tpos = mob._temp_custom_state.attack_target:get_pos()
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
		local mt_dogfight = rp_mobs_mobs.microtask_dogfight
		local task = rp_mobs.create_task({label="dogfight"})
		rp_mobs.add_microtask_to_task(mob, mt_dogfight, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end

rp_mobs_mobs.create_player_attack_decider = function()
	return function (task_queue, mob)
		local mt = rp_mobs.create_microtask({
			label = "mark players as attack target",
			on_step = function(self, mob, dtime)
				if mob._temp_custom_state.follow_player then
					local playername = mob._temp_custom_state.follow_player
					local player = minetest.get_player_by_name(mob._temp_custom_state.follow_player)
					if player and player:is_player() and player:get_hp() > 0 then
						mob._temp_custom_state.attack_target = player
					else
						mob._temp_custom_state.attack_target = nil
					end
				else
					mob._temp_custom_state.attack_target = nil
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

