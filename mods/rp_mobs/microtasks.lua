-- Microtask templates

rp_mobs.microtasks = {}

-- DUMMY TEMPLATES (need to do better later)

rp_mobs.microtasks.jump = function(strength)
	return {
		label = "jump",
		singlestep = true,
		on_step = function(self)
			self.object:add_velocity({x=0, y=strength, z=0})
		end,
	}
end

rp_mobs.microtasks.go_to_x = function(target_x, tolerance)
	return {
		label = "move to x coordinate",
		on_step = function(self)
			local pos = self.object:get_pos()
			if pos.x > target_x then
				if self._mob_velocity.x < -1.001 or self._mob_velocity.x > -0.999 then
					self._mob_velocity.x = -1
					self._mob_velocity_changed = true
				end
			else
				if self._mob_velocity.x > 1.001 or self._mob_velocity.x < 0.999 then
					self._mob_velocity.x = 1
					self._mob_velocity_changed = true
				end
			end
		end,
		is_finished = function(self)
			local pos = self.object:get_pos()
			if math.abs(pos.x - target_x) <= tolerance then
				return true
			else
				return false
			end
		end,
		on_end = function(self)
			self._mob_velocity = vector.zero()
			self._mob_velocity_changed = true
		end,
	}
end
