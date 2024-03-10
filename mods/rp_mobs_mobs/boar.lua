-- Boar

-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

-- Boar constants

-- How fast it walks
local WALK_SPEED = 2

-- How fast it rises in a liquid
local LIQUID_RISE_SPEED = 2

-- How strong it jumps
local JUMP_STRENGTH = 5

-- Maximum fall height
local FALL_HEIGHT = 4

-- When mob is about to decide to fall on a block, this is the
-- maximum fall_damage_add_percent group value this node
-- is allowed to have. Otherwise, the mob will avoid this node.
local MAX_FALL_DAMAGE_ADD_PERCENT_DROP_ON = 10

-- Random duration in ms (minimum and maximum)
local WALK_DURATION_MIN = 3000
local WALK_DURATION_MAX = 4000

-- Random duration in milliseconds (minimum and maximum)
local FIND_LAND_DURATION_MIN = 7000
local FIND_LAND_DURATION_MAX = 10000

-- Duration to find safe land (no danger)
local FIND_SAFE_LAND_DURATION = 1000

-- Random duration the mob just stands still
local IDLE_DURATION_MIN = 500
local IDLE_DURATION_MAX = 2000

-- Play the random 'call' sound after this duration
local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000

-- How far the mob looks away for safe land (raycast length)
local FIND_LAND_LENGTH = 20

-- Range the mob can 'see' players and mods for following/attacking
local VIEW_RANGE = 10

-- When the mob is this far away from a follow target, or closer, the target
-- is supposed to be "reached" and the mob stops walking.
local FOLLOW_REACH_DISTANCE = 2

-- Stop following after this many seconds (if not reached first)
local FOLLOW_GIVE_UP_TIME = 10.0

-- If mob stops following players/mobs due to danger,
-- disable following for this many seconds.
local NO_FOLLOW_TIME = 6.0

-- List of foods the mob can eat. All foods may also
-- activate Love Mode.
local FOOD = { "rp_default:apple", "rp_default:acorn" }


local roam_decider = function(task_queue, mob)
	local task_roam
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
	mt_sleep.start_animation = "idle"

	if mob._env_node.name == "ignore" then
		task_roam = rp_mobs.create_task({label="stand still"})
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif rp_mobs_mobs.is_damaging(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="escape from damaging node"})

		local yaw
		-- Find direction to walk to
		local safepos, safeangle = rp_mobs_mobs.find_safe_node_from_pos(mob.object:get_pos())
		local walk_duration
		-- Prefer walking towards safe place
		if safepos and safeangle then
			yaw = safeangle
			walk_duration = math.random(FIND_LAND_DURATION_MIN, FIND_LAND_DURATION_MAX)/1000
		else
			-- If no safe place found, walk randomly (panic!)
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, nil, walk_duration)
		local mt_acceleration = rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_acceleration, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)

	elseif rp_mobs_mobs.is_liquid(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="swim upwards"})
		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		local move_vector = vector.new(0, LIQUID_RISE_SPEED, 0)
		local mt_swim_up = rp_mobs.microtasks.move_straight(move_vector, yaw, vector.new(2, 0.3, 2))
		local mt_acceleration = rp_mobs.microtasks.set_acceleration(vector.zero())
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_acceleration, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_swim_up, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif rp_mobs_mobs.is_liquid(mob._env_node_floor.name) then
		task_roam = rp_mobs.create_task({label="swim on liquid surface"})

		local yaw
		-- Find direction to walk to
		local landpos, landangle = rp_mobs_mobs.find_land_from_liquid(mob.object:get_pos())
		local walk_duration
		-- Prefer walking towards land. Boar wants to stay dry. ;-)
		if landpos and landangle then
			-- towards land
			yaw = landangle
			walk_duration = FIND_SAFE_LAND_DURATION
		else
			-- If no land found, go randomly on water
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		local mt_acceleration = rp_mobs.microtasks.set_acceleration(vector.zero())
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_acceleration, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	else
		task_roam = rp_mobs.create_task({label="roam land"})

		local yaw = math.random(0, 360) / 360 * (math.pi*2)
		local walk_duration = math.random(WALK_DURATION_MIN, WALK_DURATION_MAX)/1000
		local mt_walk = rp_mobs.microtasks.walk_straight(WALK_SPEED, yaw, JUMP_STRENGTH, walk_duration)
		local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
		local mt_acceleration = rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR)
		mt_walk.start_animation = "walk"
		rp_mobs.add_microtask_to_task(mob, mt_acceleration, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_yaw, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_walk, task_roam)
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	end

	rp_mobs.add_task_to_task_queue(task_queue, task_roam)
end

local roam_decider_step = function(task_queue, mob, dtime)
	-- Re-enable following after a few seconds
	if mob._temp_custom_state.no_follow then
		mob._temp_custom_state.no_follow_timer = mob._temp_custom_state.no_follow_timer + dtime
		if mob._temp_custom_state.no_follow_timer > NO_FOLLOW_TIME then
			mob._temp_custom_state.no_follow = false
			mob._temp_custom_state.no_follow_timer = 0
		end
	end

	if mob._env_node then
		local current = task_queue.tasks:getFirst()
		if current and current.data then
			-- Escape from damaging node has reached safety
			if current.data.label == "escape from damaging node" then
				if not rp_mobs_mobs.is_damaging(mob._env_node.name) or rp_mobs_mobs.is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			-- Stop following player or partner if gone
			elseif (current.data.label == "follow player holding food" and not mob._temp_custom_state.follow_player) or
					(current.data.label == "follow mating partner" and not mob._temp_custom_state.follow_partner) then
				rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				rp_mobs_mobs.add_halt_to_task_queue(task_queue, mob, nil, IDLE_DURATION_MIN, IDLE_DURATION_MAX)
			-- Update land movement (roam, standing, following)
			-- Note: The follow tasks are all considered to be land movement.
			-- There is no following while swimming!
			elseif current.data.label == "roam land" or current.data.label == "stand still" or
					current.data.label == "follow player holding food" or current.data.label == "follow mating partner" then
				-- Abort when in damaging or liquid node
				if rp_mobs_mobs.is_damaging(mob._env_node.name) or rp_mobs_mobs.is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				-- Abort and stop movement when walking towards of a cliff or other dangerous node
				elseif not rp_mobs_mobs.is_front_safe(mob, FALL_HEIGHT, MAX_FALL_DAMAGE_ADD_PERCENT_DROP_ON) and current.data.label ~= "stand still" then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)

					-- Rotate by 70° to 180° left or right
					local sign = math.random(0, 1)
					local yawplus = math.random(70, 180)/360 * (math.pi*2)
					local yaw = mob.object:get_yaw() + yawplus
					if sign == 1 then
						yaw = -yaw
					end
					rp_mobs_mobs.add_halt_to_task_queue(task_queue, mob, yaw, IDLE_DURATION_MIN, IDLE_DURATION_MAX)


					-- Disable following for a few seconds if mob just avoided a danger
					if current.data.label == "follow player holding food" or current.data.label == "follow mating partner" then
						mob._temp_custom_state.no_follow = true
						mob._temp_custom_state.no_follow_timer = 0
					end
				-- Follow player holding food or mating partner
				elseif (mob._temp_custom_state.follow_partner or mob._temp_custom_state.follow_player) and not mob._temp_custom_state.no_follow then
					local target, task_label
					-- If horny, following mating partner
					if mob._horny and mob._temp_custom_state.follow_partner then
						if mob._temp_custom_state.follow_partner:get_luaentity() then
							target = mob._temp_custom_state.follow_partner
							task_label = "follow mating partner"
						end
					end
					-- Follow player holding food only if not horny
					if not mob._horny and mob._temp_custom_state.follow_player then
						local player = minetest.get_player_by_name(mob._temp_custom_state.follow_player)
						if player then
							target = player
							task_label = "follow player holding food"
						end
					end
					if target then
						if task_label == current.data.label then
							-- We're already doing this task - no change
							return
						end
						rp_mobs.end_current_task_in_task_queue(mob, task_queue)
						local task = rp_mobs.create_task({label=task_label})
						local mt_acceleration = rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR)
						rp_mobs.add_microtask_to_task(mob, mt_acceleration, task)
						local mt_follow = rp_mobs.microtasks.walk_straight_towards(WALK_SPEED, "object", target, true, FOLLOW_REACH_DISTANCE, JUMP_STRENGTH, FOLLOW_GIVE_UP_TIME)
						mt_follow.start_animation = "walk"
						rp_mobs.add_microtask_to_task(mob, mt_follow, task)
						local mt_sleep = rp_mobs.microtasks.sleep(math.random(IDLE_DURATION_MIN, IDLE_DURATION_MAX)/1000)
						mt_sleep.start_animation = "idle"
						rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
						rp_mobs.add_task_to_task_queue(task_queue, task)
					end
				end
			-- Surface from liquid
			elseif current.data.label == "swim upwards" then
				if not rp_mobs_mobs.is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
					local vel = vector.zero()
					-- Transitionary task to reset velocity.
					local task = rp_mobs.create_task({label="surface"})
					rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.move_straight(vel, mob.object:get_yaw()), task)
					rp_mobs.add_task_to_task_queue(task_queue, task)
				end
			-- Reaching land or air when swimming on liquid
			elseif current.data.label == "swim on liquid surface" then
				if not rp_mobs_mobs.is_liquid(mob._env_node.name) and not rp_mobs_mobs.is_liquid(mob._env_node_floor.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				end
			end
		end
	end
end

mt_find_follow = rp_mobs_mobs.microtask_find_follow(VIEW_RANGE, FOOD)

local follow_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="scan for entities to follow"})
	rp_mobs.add_microtask_to_task(mob, mt_find_follow, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
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
	is_peaceful = true,
	drops = {"rp_mobs_mobs:pork_raw"},
	default_sounds = {
		death = "mobs_boar_die",
		damage = "mobs_boar_hurt",
		eat = "mobs_eat",
		call = "mobs_boar_call",
		give_birth = "mobs_boar_give_birth",
		horny = "mobs_boar_horny",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 20 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 20 },
		["punch"] = { frame_range = { x = 90, y = 101 }, default_frame_speed = 20 },
	},
	textures_child = { "mobs_boar_child.png" },
	front_body_point = vector.new(0, -0.4, 0.5),
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
			stepheight = 0.6,
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
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(roam_decider, roam_decider_step))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(follow_decider))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(call_sound_decider))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.advance_child_growth(self, dtime)
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
