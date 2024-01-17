-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local dummy_texture = "mobs_dummy.png"

-- Dummy mob only for testing
rp_mobs.register_mob("rp_mobs_mobs:dummy", {
	description = S("Dummy"),
	decider = function(self)
	end,
	entity_definition = {
		initial_properties = {
			hp_max = 20,
			physical = true,
			collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate=true},
			visual = "cube",
			textures = { dummy_texture, dummy_texture, dummy_texture, dummy_texture, dummy_texture, dummy_texture },
			makes_footstep_sound = false,
		},
		on_activate = function(self)
			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_physics(self)
			rp_mobs.init_tasks(self)
			rp_mobs.activate_gravity(self)
			self._get_fall_damage = true
		end,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self, dtime)
		end,
		on_death = rp_mobs.on_death_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:dummy", dummy_texture)
