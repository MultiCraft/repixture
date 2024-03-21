-- Behavior functions for land animals

-- Decider functions for random roaming behavior (and following)

local create_roam_decider_empty = function(settings)
return function(task_queue, mob)
	local task_roam
	local mt_sleep = rp_mobs.microtasks.sleep(math.random(settings.idle_duration_min, settings.idle_duration_max)/1000)
	mt_sleep.start_animation = "idle"

	if mob._env_node.name == "ignore" then
		task_roam = rp_mobs.create_task({label="stand still"})
		rp_mobs.add_microtask_to_task(mob, mt_sleep, task_roam)
	elseif rp_mobs_mobs.is_damaging(mob._env_node.name) then
		task_roam = rp_mobs.create_task({label="escape from damaging node"})

		local yaw
		-- Find direction to walk to
		local safepos, safeangle = rp_mobs_mobs.find_safe_node_from_pos(mob.object:get_pos(), settings.find_land_length)
		local walk_duration
		-- Prefer walking towards safe place
		if safepos and safeangle then
			yaw = safeangle
			walk_duration = math.random(settings.find_land_duration_min, settings.find_land_duration_max)/1000
		else
			-- If no safe place found, walk randomly (panic!)
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(settings.walk_duration_min, settings.walk_duration_max)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(settings.walk_speed, yaw, nil, nil, walk_duration)
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
		local move_vector = vector.new(0, settings.liquid_rise_speed, 0)
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
		local landpos, landangle = rp_mobs_mobs.find_land_from_liquid(mob.object:get_pos(), settings.find_land_length)
		local walk_duration
		-- Prefer walking towards land. Mob wants to stay dry. ;-)
		if landpos and landangle then
			-- towards land
			yaw = landangle
			walk_duration = math.random(settings.find_safe_land_duration_min, settings.find_safe_land_duration_max)/1000
		else
			-- If no land found, go randomly on water
			yaw = math.random(0, 360) / 360 * (math.pi*2)
			walk_duration = math.random(settings.walk_duration_min, settings.walk_duration_max)/1000
		end
		local mt_walk = rp_mobs.microtasks.walk_straight(settings.walk_speed, yaw, settings.jump_strength, settings.jump_clear_height, walk_duration)
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
		local walk_duration = math.random(settings.walk_duration_min, settings.walk_duration_max)/1000
		local mt_walk = rp_mobs.microtasks.walk_straight(settings.walk_speed, yaw, settings.jump_strength, settings.jump_clear_height, walk_duration)
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
end

local create_roam_decider_step = function(settings)
return function(task_queue, mob, dtime)
	-- Re-enable following after a few seconds
	if mob._temp_custom_state.no_follow then
		mob._temp_custom_state.no_follow_timer = mob._temp_custom_state.no_follow_timer + dtime
		if mob._temp_custom_state.no_follow_timer > settings.no_follow_time then
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
			elseif (current.data.label == "follow player holding food" and not mob._temp_custom_state.closest_food_player) or
					(current.data.label == "hunt player" and not mob._temp_custom_state.closest_food_player) or
					(current.data.label == "follow mating partner" and not mob._temp_custom_state.closest_mating_partner) then
				rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				rp_mobs_mobs.add_halt_to_task_queue(task_queue, mob, nil, settings.idle_duration_min, settings.idle_duration_max)
			-- Update land movement (roam, standing, following)
			-- Note: The follow tasks are all considered to be land movement.
			-- There is no following while swimming!
			elseif current.data.label == "roam land" or current.data.label == "stand still" or
					current.data.label == "follow player holding food" or current.data.label == "follow mating partner" or
					current.data.label == "hunt player" then
				-- Abort when in damaging or liquid node
				if rp_mobs_mobs.is_damaging(mob._env_node.name) or rp_mobs_mobs.is_liquid(mob._env_node.name) then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)
				-- Abort and stop movement when walking towards of a cliff or other dangerous node
				elseif not rp_mobs_mobs.is_front_safe(mob, settings.fall_height, settings.max_fall_damage_add_percent_drop_on) and current.data.label ~= "stand still" then
					rp_mobs.end_current_task_in_task_queue(mob, task_queue)

					-- Rotate by 70° to 180° left or right
					local sign = math.random(0, 1)
					local yawplus = math.random(70, 180)/360 * (math.pi*2)
					local yaw = mob.object:get_yaw() + yawplus
					if sign == 1 then
						yaw = -yaw
					end
					rp_mobs_mobs.add_halt_to_task_queue(task_queue, mob, yaw, settings.idle_duration_min, settings.idle_duration_max)


					-- Disable following for a few seconds if mob just avoided a danger
					if current.data.label == "follow player holding food" or current.data.label == "follow mating partner" or current.data.label == "hunt player" then
						mob._temp_custom_state.no_follow = true
						mob._temp_custom_state.no_follow_timer = 0
					end
				-- Follow player or mating partner
				elseif (mob._temp_custom_state.closest_mating_partner or mob._temp_custom_state.closest_food_player) and not mob._temp_custom_state.no_follow then
					local target, task_label
					-- If horny, following mating partner
					if mob._horny and mob._temp_custom_state.closest_mating_partner then
						if mob._temp_custom_state.closest_mating_partner:get_luaentity() then
							target = mob._temp_custom_state.closest_mating_partner
							task_label = "follow mating partner"
						end
					end
					if mob._temp_custom_state.closest_food_player then
						-- Hunt player
						if settings.hunt_players then
							local player = minetest.get_player_by_name(mob._temp_custom_state.closest_food_player)
							if player then
								target = player
								task_label = "hunt player"
							end
						-- Follow player holding food only if not horny
						elseif not mob._horny then
							local player = minetest.get_player_by_name(mob._temp_custom_state.closest_food_player)
							if player then
								target = player
								task_label = "follow player holding food"
							end
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
						local speed
						if task_label == "hunt player" then
							speed = settings.hunt_speed or settings.walk_speed
						else
							speed = settings.walk_speed
						end
						local mt_follow = rp_mobs.microtasks.walk_straight_towards(speed, "object", target, true, settings.follow_reach_distance, settings.jump_strength, settings.jump_clear_height, settings.follow_give_up_time)
						if task_label == "hunt player" then
							mt_follow.start_animation = "run"
						else
							mt_follow.start_animation = "walk"
						end
						rp_mobs.add_microtask_to_task(mob, mt_follow, task)
						local dogfight = false
						-- Dogfight, if enabled in settings
						if settings.dogfight and task_label == "hunt player" then
							local mt_attack = rp_mobs_mobs.create_dogfight_microtask(settings.dogfight_range, settings.dogfight_toolcaps, settings.dogfight_interval)
							rp_mobs.add_microtask_to_task(mob, mt_attack, task)
						end
						if not settings.dogfight then
							local mt_sleep = rp_mobs.microtasks.sleep(math.random(settings.idle_duration_min, settings.idle_duration_max)/1000)
							mt_sleep.start_animation = "idle"
							rp_mobs.add_microtask_to_task(mob, mt_sleep, task)
						end
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
end

--[[ settings = {
	idle_duration_min: Random idle duration in ms (minimum)
	idle_duration_max: Random idle duration in ms (maximum)
	find_land_duration_min: Random duration of finding land when on water, in ms (minimum)
	find_land_duration_max: Random duration of finding land when on water, in ms (maximum)
	find_safe_land_duration_min: Duration in ms to find safe land (non-damaging nodes) (minimum)
	find_safe_land_duration_max: Duration in ms to find safe land (non-damaging nodes) (maximum)
	walk_speed: How fast it walks
	walk_duration_min: Random walk duration in ms (minimum)
	walk_duration_max: Random walk duration in ms (maximum)
	liquid_rise_speed: How fast it rises in a lquid
	jump_strength: How strong it jumps
	jump_clear_height: Up to how many nodes high it will try to jump to higher land
	fall_height: Maximum fall height
	max_fall_damage_add_percent_drop_on: When mob is about to decide to fall
		on a block, this is the maximum fall_damage_add_percent group value
		this node is allowed to have. Otherwise, the mob will avoid this node.
	follow_reach_distance: When the mob is this far away from a follow target,
		or closer, the target is supposed to be "reached" and the mob stops walking.
	follow_give_up_time: Stop following after this many seconds (if not reached first)
	no_follow_time: If mob stops following due to danger, this is is the time (in ms)
		that the mob will not follow anything after that happened.
]]

rp_mobs_mobs.task_queue_land_animal_roam = function(settings)
	local roam_decider_empty = create_roam_decider_empty(settings)
	local roam_decider_step = create_roam_decider_step(settings)
	local tq = rp_mobs.create_task_queue(roam_decider_empty, roam_decider_step)
	return tq
end
