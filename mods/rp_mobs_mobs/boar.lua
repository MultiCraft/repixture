local WALK_SPEED = 2
local JUMP_STRENGTH = 4
local WALK_DURATION_MIN = 3000
local WALK_DURATION_MAX = 4000
local IDLE_DURATION_MIN = 500
local IDLE_DURATION_MAX = 2000
local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000
local VIEW_RANGE = 10
local FOOD = { "rp_default:apple", "rp_default:acorn" }

-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local roam_decider = function(task_queue, mob)
	local task_roam = rp_mobs.create_task({label="roam"})

	local yaw = math.random(0, 360) / 360 * (math.pi*2)
	local walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
	local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
	mt_walk.start_animation = "walk"
	rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
	mt_sleep.start_animation = "idle"
	rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	rp_mobs.add_task_to_task_queue(task_queue, task_roam)
end

local autoyaw_decider = function(task_queue, mob)
	local task_autoyaw = rp_mobs.create_task({label="autoyaw"})
	local mt_autoyaw = rp_mobs.microtasks.autoyaw()
	rp_mobs.add_microtask_to_task(mob, mt_autoyaw, task_autoyaw)
	rp_mobs.add_task_to_task_queue(task_queue, task_autoyaw)
end

local call_sound_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="random call sound"})
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(RANDOM_SOUND_TIMER_MIN, RANDOM_SOUND_TIMER_MAX)/1000)
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
		call = "mobs_boar",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
	entity_definition = {
		initial_properties = {
			hp_max = 20,
			physical = true,
			collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
			selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
			visual = "mesh",
			mesh = "mobs_boar.x",
			textures = { "mobs_boar.png" },
			makes_footstep_sound = true,
			stepheight = 0.6,
		},
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
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(roam_decider))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(autoyaw_decider))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(call_sound_decider))
		end,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.handle_breeding(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame_breed(self, clicker, FOOD, 8, true)
			rp_mobs.call_on_capture(self, clicker)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 5, ["rp_mobs:lasso"] = 40 })
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
