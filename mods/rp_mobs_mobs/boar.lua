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
			--rp_mobs.activate_gravity(self)
			rp_mobs.init_tasks(self)
		end,
		on_rightclick = function(self, clicker)
			--rp_mobs.feed_tame(self, clicker, 8, true)
			--rp_mobs.capture_mob(self, clicker, 0, 5, 40, false, nil)

			-- DEBUG: Microtask tests
			local task = {}
			local taskEntry = rp_mobs.add_task(self, task)
			local startpos = self.object:get_pos()
			startpos.y = math.floor(startpos.y)
			startpos = vector.round(startpos)
			local endpos = vector.add(startpos, vector.new(3, 0, 5))
			local microtask1 = rp_mobs.microtasks.pathfind_and_walk_to(endpos, 100, 1, 4)
			rp_mobs.add_microtask_to_task(self, microtask1, task)
--[[
			local microtask1 = rp_mobs.microtasks.go_to_x(0, 0.1)
			local microtask2 = rp_mobs.microtasks.go_to_x(5, 0.1)
			local microtask3 = rp_mobs.microtasks.jump(10)
			local microtask4 = rp_mobs.microtasks.go_to_x(-5, 0.1)
			local microtask5 = rp_mobs.microtasks.jump(10)
			rp_mobs.add_microtask_to_task(self, microtask1, task)
			rp_mobs.add_microtask_to_task(self, microtask2, task)
			rp_mobs.add_microtask_to_task(self, microtask3, task)
			rp_mobs.add_microtask_to_task(self, microtask4, task)
			rp_mobs.add_microtask_to_task(self, microtask5, task)
]]
		end,
		on_step = function(self, dtime)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self)
		end,
		on_death = rp_mobs.on_death_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
