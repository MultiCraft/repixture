-- Mine Turtle

-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

-- Boar constants

local VIEW_RANGE = 10

local task_queue_roam_settings = {
	walk_speed = 2,
	liquid_rise_speed = 2,
	jump_strength = 5,
	fall_height = 4,
	walk_duration_min = 3000,
	walk_duration_max = 4000,
	find_land_duration_min = 7000,
	find_land_duration_max = 10000,
	find_safe_land_duration_min = 1000,
	find_safe_land_duration_max = 1100,
	idle_duration_min = 500,
	idle_duration_max = 2000,
	find_land_length = 20,
	view_range = VIEW_RANGE,
	follow_reach_distance = 1,
	follow_give_up_time = 10.0,
	no_follow_time = 6.0,
}

rp_mobs.register_mob("rp_mobs_mobs:mineturtle", {
	description = S("Mine Turtle"),
	is_animal = false,
	is_peaceful = false,
	drops = {
		{name = "rp_tnt:tnt", chance = 1, min = 1, max = 3},
	},
	default_sounds = {
		war_cry = "mobs_mineturtle",
		random = "mobs_mineturtle",
		explode = "tnt_explode",
		distance = 16,
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 30 }, default_frame_speed = 25 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 31, y = 50 }, default_frame_speed = 25 },
		["run"] = { frame_range = { x = 31, y = 50 }, default_frame_speed = 35 },
		["punch"] = { frame_range = { x = 51, y = 60 }, default_frame_speed = 25 },
	},
	front_body_point = vector.new(0, -0.4, 0.5),
	entity_definition = {
		initial_properties = {
			hp_max = 15,
			physical = true,
			collisionbox = {-0.4, 0, -0.4, 0.4, 0.7, 0.4},
			selectionbox = {-0.4, 0, -0.5, 0.4, 0.7, 0.8, rotate=true},
			visual = "mesh",
			mesh = "mobs_mineturtle.x",
			textures = { "mobs_mineturtle.png" },
			makes_footstep_sound = true,
			stepheight = 0.6,
		},
		on_activate = function(self, staticdata)
			rp_mobs.init_mob(self)
			rp_mobs.restore_state(self, staticdata)

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 20,
				drowning_point = vector.new(0, -0.1, 0.49)
			})

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_land_animal_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_follow_scan(VIEW_RANGE, {}))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
		end,
		on_death = function(self, killer)
			if killer and killer:is_player() then
				achievements.trigger_achievement(killer, "bomb_has_been_defused")
			end
			return rp_mobs.on_death_default(self, killer)
		end,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:mineturtle", "mobs_mineturtle_inventory.png")
