-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local dummy_texture = "mobs_dummy.png"

-- Dummy mob only for testing
rp_mobs.register_mob("rp_mobs_mobs:dummy", {
	description = S("Dummy"),
	decider = function(self)
		local task = rp_mobs.create_task({label="Dummy stuff"})
		rp_mobs.add_microtask_to_task(self, rp_mobs.microtasks.set_yaw("random"), task)
		local sleep_time = math.random(500, 2000)/1000
		local mt_sleep = rp_mobs.microtasks.sleep(sleep_time)
		rp_mobs.add_microtask_to_task(self, mt_sleep, task)
		rp_mobs.add_task(self, task)
	end,
	entity_definition = {
		hp_max = 1,
		physical = true,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate=true},
		visual = "cube",
		textures = { dummy_texture, dummy_texture, dummy_texture, dummy_texture, dummy_texture, dummy_texture },
		makes_footstep_sound = false,
		on_activate = function(self)
			rp_mobs.init_physics(self)
			rp_mobs.init_tasks(self)
		end,
		on_step = function(self, dtime)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self, dtime)
			rp_mobs.decide(self)
		end,
		on_death = rp_mobs.on_death_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:dummy", dummy_texture)
