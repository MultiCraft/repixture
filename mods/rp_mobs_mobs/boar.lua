-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
rp_mobs.register_mob("rp_mobs_mobs:boar", {
	description = S("Boar"),
	drops = {"rp_mobs_mobs:pork_raw"},
	entity_definition = {
		hp_max = 20,
		physical = true,
		collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
		selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
		visual = "mesh",
		mesh = "mobs_boar.x",
		textures = { "mobs_boar.png" },
		makes_footstep_sound = true,
		on_activate = function(self)
			rp_mobs.init_physics(self)
			rp_mobs.activate_gravity(self)
			rp_mobs.init_tasks(self)
		end,
		on_rightclick = function(self, clicker)
			--rp_mobs.feed_tame(self, clicker, 8, true)
			--rp_mobs.capture_mob(self, clicker, 0, 5, 40, false, nil)

			-- DEBUG: Microtask tests
			local task = {}
			local taskEntry = rp_mobs.add_task(self, task)
			local microtask = {
				label = "move to Z > 0",
				on_step = function(self)
					if self._mob_velocity.z > 1.001 or self._mob_velocity.z < 0.999 then
						self._mob_velocity.z = 1
						self._mob_velocity_changed = true
					end
				end,
				is_finished = function(self)
					if self.object:get_pos().z > 0 then
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
			local microtask2 = {
				label = "move to X > 0",
				on_step = function(self)
					if self._mob_velocity.x > 1.001 or self._mob_velocity.x < 0.999 then
						self._mob_velocity.x = 1
						self._mob_velocity_changed = true
					end
				end,
				is_finished = function(self)
					if self.object:get_pos().x > 0 then
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
			rp_mobs.add_microtask_to_task(self, microtask, task)
			rp_mobs.add_microtask_to_task(self, microtask2, task)
		end,
		on_step = function(self, dtime)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self)
		end,
		on_death = rp_mobs.on_death_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
