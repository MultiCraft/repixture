-- Boar

local S = minetest.get_translator("rp_mobs_mobs")

-- Boar constants

local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000
local VIEW_RANGE = 10
local ANGRY_COOLDOWN_TIME = 30.0

local FOOD = { { name = "rp_default:apple", points = 1 }, { name = "rp_default:acorn", points = 1 } }

local task_queue_roam_settings = {
	walk_speed = 2,
	hunt_speed = 3,
	liquid_rise_speed = 2,
	jump_strength = 4.6,
	jump_clear_height = 1,
	fall_height = 4,
	max_fall_damage_add_percent_drop_on = 10,
	walk_duration_min = 3000,
	walk_duration_max = 4000,
	find_land_duration_min = 7000,
	find_land_duration_max = 10000,
	find_safe_land_duration_min = 1000,
	find_safe_land_duration_max = 1100,
	idle_duration_min = 500,
	idle_duration_max = 2000,
	find_land_length = 20,
	follow_reach_distance = 1.8,
	follow_max_distance = VIEW_RANGE,
	follow_give_up_time = 10.0,
	no_follow_time = 6.0,

	dogfight = true,
	dogfight_range = 2,
	dogfight_toolcaps = { damage_groups = { fleshy = 2 } },
	dogfight_interval = 1.0,
}

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
rp_mobs.register_mob("rp_mobs_mobs:boar", {
	description = S("Boar"),
	tags = { animal = 1, child_exists = 1, peaceful = 1 },
	drops = {
		{name="rp_mobs_mobs:pork_raw", chance=1, min=1, max=4},
	},
	default_sounds = {
		death = "mobs_boar_die",
		damage = "mobs_boar_hurt",
		eat = "mobs_eat",
		call = "mobs_boar_call",
		give_birth = "mobs_boar_give_birth",
		horny = "mobs_boar_horny",
		attack = "mobs_boar_attack",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["run"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 30 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
	textures_child = { "mobs_boar_child.png" },
	front_body_point = vector.new(0, -0.4, 0.6),
	dead_y_offset = 0.6,
	entity_definition = {
		initial_properties = {
			hp_max = 20,
			physical = true,
			collisionbox = {-0.49, -1, -0.49, 0.49, 0.1, 0.49},
			selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
			visual = "mesh",
			mesh = "mobs_boar.x",
			textures = { "mobs_boar.png" },
			makes_footstep_sound = true,
			stepheight = 0.26,
		},
		on_activate = function(self, staticdata)
			rp_mobs.init_mob(self)
			rp_mobs.restore_state(self, staticdata)

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 10,
				drowning_point = vector.new(0, -0.1, 0.49)
			})
			rp_mobs.init_node_damage(self, true)

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_land_animal_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_food_breed_follow_scan(VIEW_RANGE, FOOD))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_player_follow_scan(VIEW_RANGE))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(rp_mobs_mobs.create_angry_cooldown_decider(VIEW_RANGE, ANGRY_COOLDOWN_TIME)))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_call_sound(RANDOM_SOUND_TIMER_MIN, RANDOM_SOUND_TIMER_MAX))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime, -0.3)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.advance_child_growth(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame_breed(self, clicker, FOOD, 8, 8)
			rp_mobs.call_on_capture(self, clicker)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 5, ["rp_mobs:lasso"] = 40 })
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs_mobs.on_punch_make_hostile,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
