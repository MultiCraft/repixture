local WALK_SPEED = 2
local LIQUID_RISE_SPEED = 2
local JUMP_STRENGTH = 5
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

local mt_set_velocity = function(velocity)
	return rp_mobs.create_microtask({
		label = "set velocity",
		singlestep = true,
		on_step = function(self, mob, dtime)
			mob.object:set_velocity(velocity)
		end,
	})
end

local mt_set_acceleration = function(acceleration)
	return rp_mobs.create_microtask({
		label = "set acceleration",
		singlestep = true,
		on_step = function(self, mob, dtime)
			mob.object:set_acceleration(acceleration)
		end,
	})
end

local function is_liquid(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and (ndef.liquid_move_physics == true or (ndef.liquid_move_physics == nil and ndef.liquidtype ~= "none"))
end

local roam_decider = function(task_queue, mob)
	local task_roam
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
	mt_sleep.start_animation = "idle"

	if mob._env_node.name == "ignore" then
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif is_liquid(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="swim upwards"})
		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local move_vector = vector.new(0, LIQUID_RISE_SPEED, 0)
		local mt_swim_up = rp_mobs.microtasks.move_straight(move_vector, yaw, vector.new(2, 0.3, 2))
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(vector.zero()), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_swim_up, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif is_liquid(mob._env_node_floor.name) then
		task_roam = rp_mobs.create_task({label="swim on liquid surface"})

		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_velocity(vector.zero()), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	else
		task_roam = rp_mobs.create_task({label="roam land"})

		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_acceleration(rp_mobs.GRAVITY_VECTOR), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_set_velocity(vector.zero()), task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
	end

	rp_mobs.add_task_to_task_queue(task_queue, task_roam)
end

local roam_decider_step = function(task_queue, mob)
	if mob._env_node then
		local current = task_queue.tasks:getFirst()
		if current and current.data then
			if current.data.label == "roam land" then
				if is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			elseif current.data.label == "swim upwards" then
				if not is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			elseif current.data.label == "swim on liquid surface" then
				if not is_liquid(mob._env_node.name) and not is_liquid(mob._env_node_floor.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			end
		end
	end
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

			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(roam_decider, roam_decider_step))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(call_sound_decider))
		end,
		on_step = function(self, dtime, moveresult)
			rp_mobs.scan_environment(self)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
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
