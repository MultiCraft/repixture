-- Mine Turtle

local S = minetest.get_translator("rp_mobs_mobs")

-- Constants

local VIEW_RANGE = 10

-- Time until mine goes boom (seconds)
local BOOM_TIMER = 3

-- Time until mob blinks on/off (seconds)
local BLINK_TIMER = 0.2

-- Radius of explosion
local EXPLODE_RADIUS = 3

-- Max. distance required to activate mine
local MINE_ACTIVATION_RANGE = 3

-- Min. distance required to deactivate mine
local MINE_DEACTIVATION_RANGE = 3.5

local task_queue_roam_settings = {
	walk_speed = 2,
	liquid_rise_speed = 2,
	jump_strength = 5,
	jump_clear_height = 1,
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
	no_follow_time = 4.0,
}

local function find_closest_player_in_range(pos, range)
	local objs = minetest.get_objects_inside_radius(pos, range)
	local c_player, c_dist
	for o=1, #objs do
		if objs[o]:is_player() then
			local dist = vector.distance(objs[o]:get_pos(), pos)
			if (not c_player) or (dist < c_dist) then
				c_player = objs[o]
				c_dist = dist
			end
		end
	end
	return c_player
end

local function explode(mob)
	local pos = mob.object:get_pos()
	mob.object:remove()
	pos.y = pos.y - 1
	tnt.boom_notnt(pos, EXPLODE_RADIUS)
	minetest.log("action", "[rp_mobs_mobs] "..mob.name.." exploded at "..minetest.pos_to_string(pos, 1))
end

local function microtask_mine()
	return rp_mobs.create_microtask({
		label = "Trigger mine",
		on_start = function(self, mob)
			mob._temp_custom_state.mine_timer = 0
			mob._temp_custom_state.mine_notifications = 0
			mob._temp_custom_state.mine_blink_timer = 0
			mob._temp_custom_state.mine_blink_state = false
			mob._temp_custom_state.mine_active = false
			mob.object:set_properties({textures = { "mobs_mineturtle.png" }})
		end,
		on_step = function(self, mob, dtime)
			local mobpos = mob.object:get_pos()
			local range
			if mob._temp_custom_state.mine_active then
				-- Mine active
				local closest = find_closest_player_in_range(mobpos, MINE_DEACTIVATION_RANGE)
				if not closest then
					-- Target out of range: Disable mine
					mob._temp_custom_state.mine_active = false
					mob._temp_custom_state.mine_timer = 0
					mob._temp_custom_state.mine_blink_timer = 0
					mob._temp_custom_state.mine_blink_state = false
					mob._temp_custom_state.mine_notifications = 0
					-- Blink off
					mob.object:set_texture_mod("")
					-- Normal texture (happy face)
					mob.object:set_properties({textures = { "mobs_mineturtle.png" }})
				else
					-- Target in range: Keep ticking until BOOM
					mob._temp_custom_state.mine_timer = mob._temp_custom_state.mine_timer + dtime
					mob._temp_custom_state.mine_blink_timer = mob._temp_custom_state.mine_blink_timer + dtime
					if mob._temp_custom_state.mine_timer >= BOOM_TIMER then
						-- BOOM!
						explode(mob)
						return
					end
					-- Blink
					if mob._temp_custom_state.mine_blink_timer >= BLINK_TIMER then
						mob._temp_custom_state.mine_blink_state = not mob._temp_custom_state.mine_blink_state
						if mob._temp_custom_state.mine_blink_state == true then
							-- Blink on
							mob.object:set_texture_mod("^mobs_mineturtle_blink_overlay.png")
						else
							-- Blink off
							mob.object:set_texture_mod("")
						end
						mob._temp_custom_state.mine_blink_timer = 0
					end
					-- Attack sound, played periodically
					if mob._temp_custom_state.mine_notifications < math.floor(mob._temp_custom_state.mine_timer) then
						rp_mobs.default_mob_sound(mob, "war_cry", false)
						mob._temp_custom_state.mine_notifications = math.floor(mob._temp_custom_state.mine_timer)
					end
				end
			else
				-- Mine inactive
				local closest = find_closest_player_in_range(mobpos, MINE_ACTIVATION_RANGE)
				if closest then
					-- Target in range: Activate mine
					mob._temp_custom_state.mine_active = true
					mob._temp_custom_state.mine_timer = 0
					mob._temp_custom_state.mine_blink_timer = 0
					mob._temp_custom_state.mine_blink_state = false
					mob._temp_custom_state.mine_notifications = 0
					rp_mobs.default_mob_sound(mob, "war_cry", false)
					-- Angry face
					mob.object:set_properties({textures = { "mobs_mineturtle.png^mobs_mineturtle_angry_overlay.png" }})
				end
			end
		end,
		is_finished = function()
			return false
		end,
	})
end

local function mine_decider(task_queue, mob)
	local task = rp_mobs.create_task({label="Trigger mine"})
	local mtask = microtask_mine()
	rp_mobs.add_microtask_to_task(mob, mtask, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

rp_mobs.register_mob("rp_mobs_mobs:mineturtle", {
	description = S("Mine Turtle"),
	drops = {
		{name = "rp_tnt:tnt", chance = 1, min = 1, max = 3},
	},
	default_sounds = {
		war_cry = "mobs_mineturtle",
		damage = "default_punch",
		death = "default_punch",
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
	front_body_point = vector.new(0, 0.35, 0.8),
	dead_y_offset = -0.4,
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
				drowning_point = vector.new(0, 0.5, 0.79)
			})

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_land_animal_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_player_follow_scan(VIEW_RANGE))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(mine_decider))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
		end,
		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:mineturtle", "mobs_mineturtle_inventory.png")


rp_mobs.register_on_die(function(mob, killer)
	if mob.name == "rp_mobs_mobs:mineturtle" then
		-- Blink off (in case the blink was on when dying)
		mob.object:set_texture_mod("")
		-- Achievements
		if killer and killer:is_player() then
			achievements.trigger_achievement(killer, "bomb_has_been_defused")
		end
	end
end)
