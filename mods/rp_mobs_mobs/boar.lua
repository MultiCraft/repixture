-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local main_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="roam"})
	local startpos = mob.object:get_pos()
	startpos.y = math.floor(startpos.y)
	startpos = vector.round(startpos)
	local nodes = minetest.find_nodes_in_area_under_air(
		vector.add(startpos, vector.new(-5, -1, -5)),
		vector.add(startpos, vector.new(5, -1, 5)),
		{"group:crumbly", "group:cracky"}
	)
	if #nodes > 0 then
		local n = math.random(1, #nodes)
		local endpos = vector.add(vector.new(0,1,0), nodes[n])
		local mt_pathfind = rp_mobs.microtasks.pathfind_and_walk_to(endpos, 100, 1, 4)
		mt_pathfind.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_pathfind, task)
	end
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(500, 2000)/1000)
	mt_sleep.start_animation = "idle"
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
rp_mobs.register_mob("rp_mobs_mobs:boar", {
	description = S("Boar"),
	is_animal = true,
	drops = {"rp_mobs_mobs:pork_raw"},
	default_sounds = {
		death = "mobs_boar_angry",
		damage = "mobs_boar",
		eat = "mobs_eat",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
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
			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 10,
				drowning_point = vector.new(0, -0.1, 0.49)
			})
			rp_mobs.init_node_damage(self, true)

			rp_mobs.init_physics(self)
			rp_mobs.activate_gravity(self)

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(main_decider))
		end,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame_breed(self, clicker, { "rp_default:apple", "rp_default:acorn" }, 8, true)
			rp_mobs.handle_capture(self, clicker)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 5, ["rp_mobs:lasso"] = 40 })
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
