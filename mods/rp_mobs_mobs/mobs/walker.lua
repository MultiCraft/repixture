-- Walker

local S = minetest.get_translator("rp_mobs_mobs")

local VIEW_RANGE = 14
local ANGRY_COOLDOWN_TIME = 10.0

local ATTACK_REACH = 2
local ATTACK_TIME = 1.0
local ATTACK_TOOLCAPS = {
	full_punch_interval = 0.9,
	damage_groups = { fleshy = 3 },
}

local task_queue_roam_settings = {
	walk_speed = 1,
	hunt_speed = 3,
	liquid_rise_speed = 2,
	jump_strength = 7,
	jump_clear_height = 2,
	fall_height = 8,
	walk_duration_min = 10000,
	walk_duration_max = 20000,
	find_land_duration_min = 7000,
	find_land_duration_max = 10000,
	find_safe_land_duration_min = 1000,
	find_safe_land_duration_max = 1100,
	idle_duration_min = 500,
	idle_duration_max = 6000,
	find_land_length = 20,
	follow_max_distance = VIEW_RANGE,
	follow_reach_distance = 1,
	follow_give_up_time = 10.0,
	no_follow_time = 6.0,

	dogfight = true,
	dogfight_range = 2,
	dogfight_toolcaps = { damage_groups = { fleshy = 3 } },
	dogfight_interval = 1.0,
}

rp_mobs.register_mob("rp_mobs_mobs:walker", {
	description = S("Walker"),
	drops = {
		{
			name = "rp_default:stick",
			chance = 1, min = 1, max = 2
		},
		{
			name = "rp_default:stick",
			chance = 3, min = 2, max = 4
		},
		{
			name = "rp_default:fiber",
			chance = 15, min = 2, max = 3
		},
	},
	default_sounds = {
		attack = "mobs_swing",
		damage = "mobs_walker_damage",
		punch_no_damage = "mobs_walker_punch_no_damage",
		death = "mobs_walker_die",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 24 }, default_frame_speed = 20 },
		["dead_static"] = { frame_range = { x = 42, y = 42 } },
		["walk"] = { frame_range = { x = 35, y = 45 }, default_frame_speed = 6 },
		["run"] = { frame_range = { x = 35, y = 45 }, default_frame_speed = 15 },
		["punch"] = { frame_range = { x = 25, y = 34 }, default_frame_speed = 20 },
	},
	front_body_point = vector.new(0, 0.5, 0.5),
	dead_y_offset = -0.3,
	entity_definition = {
		initial_properties = {
			hp_max = 8,
			physical = true,
			collisionbox = {-0.3, 0, -0.3, 0.3, 1.5, 0.3},
			selectionbox = {-0.3, 0, -0.3, 0.3, 1.5, 0.3, rotate=true},
			visual = "mesh",
			mesh = "mobs_walker.b3d",
			textures = { "mobs_walker.png" },
			makes_footstep_sound = true,
			stepheight = 0.6,
		},
		on_activate = function(self, staticdata)
			rp_mobs.init_mob(self)
			rp_mobs.restore_state(self, staticdata)

			rp_mobs.init_fall_damage(self, true)

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queues.land_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queues.player_follow_scan(VIEW_RANGE))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(rp_mobs_mobs.create_angry_cooldown_decider(VIEW_RANGE, ANGRY_COOLDOWN_TIME)))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(rp_mobs_mobs.create_player_angry_decider()))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime, moveresult, rp_mobs_mobs.get_dying_step(true, false))
			rp_mobs.scan_environment(self, dtime, -0.5)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
		_rp_explosions_knockback = true,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:walker", "mobs_walker_inventory.png")
