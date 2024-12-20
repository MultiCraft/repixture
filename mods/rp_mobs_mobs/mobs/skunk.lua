-- Skunk

local S = minetest.get_translator("rp_mobs_mobs")

local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000
local VIEW_RANGE = 15
local ANGRY_COOLDOWN_TIME = 10.0

local FOOD = {{ name = "rp_default:apple", points = 1 }}

local task_queue_roam_settings = {
	walk_speed = 1.5,
	hunt_speed = 2,
	liquid_rise_speed = 3,
	jump_strength = 4.6,
	jump_clear_height = 1,
	fall_height = 4,
	walk_duration_min = 3000,
	walk_duration_max = 8000,
	find_land_duration_min = 5000,
	find_land_duration_max = 20000,
	find_safe_land_duration_min = 1000,
	find_safe_land_duration_max = 1100,
	idle_duration_min = 500,
	idle_duration_max = 4000,
	find_land_length = 20,
	follow_max_distance = VIEW_RANGE,
	follow_reach_distance = 1,
	follow_give_up_time = 10.0,
	no_follow_time = 6.0,

	dogfight = true,
	dogfight_range = 1.5,
	dogfight_toolcaps = { damage_groups = { fleshy = 1 } },
	dogfight_interval = 1.0,
}

rp_mobs.register_mob("rp_mobs_mobs:skunk", {
	description = S("Skunk"),
	tags = { animal = 1, child_exists = 1, peaceful = 1 },
	drops = {
		{name="rp_mobs_mobs:meat_raw", chance=1, min=1, max=2},
	},
	default_sounds = {
		attack = "mobs_skunk_hiss",
		damage = "mobs_skunk_hiss",
		death = "mobs_skunk_hiss",
		eat = "mobs_eat",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["run"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 26.66667 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
	front_body_point = vector.new(0, -0.1, 0.5),
	dead_y_offset = 0.3,
	entity_definition = {
		initial_properties = {
			hp_max = 15,
			physical = true,
			collisionbox = {-0.2, -0.45, -0.2, 0.2, 0.1, 0.2},
			selectionbox = {-0.15, -0.45, -0.35, 0.15, 0.1, 0.45, rotate=true},
			visual = "mesh",
			mesh = "mobs_skunk.x",
			textures = { "mobs_skunk.png" },
			makes_footstep_sound = true,
			stepheight = 0.26,
		},
		on_activate = function(self, staticdata)
			rp_mobs.init_mob(self)
			rp_mobs.restore_state(self, staticdata)

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 7,
				drowning_point = vector.new(0, -0.1, 0.49)
			})
			rp_mobs.init_node_damage(self, true, {
				node_damage_points={vector.new(0, -0.1, 0)},
			})

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queues.land_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queues.food_breed_follow_scan(VIEW_RANGE, FOOD))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queues.player_follow_scan(VIEW_RANGE))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(rp_mobs_mobs.create_angry_cooldown_decider(VIEW_RANGE, ANGRY_COOLDOWN_TIME)))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime, moveresult, rp_mobs_mobs.get_dying_step(true, false))
			rp_mobs.scan_environment(self, dtime, -0.1)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.advance_child_growth(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame_breed(self, clicker, FOOD, 6, 6)
			rp_mobs.call_on_capture(self, clicker)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 40, ["rp_mobs:lasso"] = 20 })
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs_mobs.on_punch_make_hostile,
		_rp_explosions_knockback = true,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:skunk", "mobs_skunk_inventory.png")
