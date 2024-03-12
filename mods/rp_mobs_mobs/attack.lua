rp_mobs_mobs.create_dogfight_decider = function(attack_range, attack_toolcaps, attack_time)
	return function (task_queue, mob)
		local mt_dogfight = rp_mobs.create_microtask({
			label = "dogfight",
			on_start = function(self, mob)
				mob._temp_custom_state.attacking = false
				mob._temp_custom_state.attack_target = nil
				self.statedata.attack_timer = 0
				self.statedata.last_punch = nil
			end,
			on_step = function(self, mob, dtime)
				if self.statedata.last_punch then
					self.statedata.last_punch = self.statedata.last_punch + dtime
				end
				if not mob._temp_custom_state.attack_target then
					self.statedata.attacking = false
					return
				end
				if mob._temp_custom_state.attack_target:get_hp() == 0 then
					self.statedata.attacking = false
					return
				end
				local mpos = mob.object:get_pos()
				local tpos = mob._temp_custom_state.attack_target:get_pos()
				if not tpos then
					self.statedata.attacking = false
					return
				end
				local dist = vector.distance(mpos, tpos)
				if dist <= attack_range then
					self.statedata.attacking = true
					self.statedata.attack_timer = self.statedata.attack_timer + dtime
					if self.statedata.attack_timer > attack_time then
						local time_from_last_punch = self.statedata.last_punch or 1000000
						local dir = vector.direction(mpos, tpos)
						rp_mobs.default_mob_sound(mob, "attack", true)
						mob._temp_custom_state.attack_target:punch(mob.object, time_from_last_punch, attack_toolcaps, dir)
						self.statedata.attack_timer = 0
					end
				else
					self.statedata.attacking = false
					self.statedata.attack_timer = 0
				end
			end,
			is_finished = function()
				return false
			end,
		})

		local task = rp_mobs.create_task({label="dogfight"})
		rp_mobs.add_microtask_to_task(mob, mt_dogfight, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end

rp_mobs_mobs.create_player_attack_decider = function()
	return function (task_queue, mob)
		local mt = rp_mobs.create_microtask({
			label = "attack players",
			on_step = function(self, mob, dtime)
				if mob._temp_custom_state.follow_player then
					local playername = mob._temp_custom_state.follow_player
					local player = minetest.get_player_by_name(mob._temp_custom_state.follow_player)
					if player and player:is_player() then
						mob._temp_custom_state.attack_target = player
					end
				end
			end,
			is_finished = function()
				return false
			end,
		})
		local task = rp_mobs.create_task({label="attack players"})
		rp_mobs.add_microtask_to_task(mob, mt, task)
		rp_mobs.add_task_to_task_queue(task_queue, task)
	end
end

