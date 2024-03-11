local DEFAULT_ADD_CHILD_GROW_TIMER = 20

-- Entity variables to persist:
rp_mobs.add_persisted_entity_vars({
	"_tame_level", -- Tame level. Increases when a mob was fed; used to trigger taming
	"_horny_level", -- Horny level. Increases when an adult mob was fed; used to trigger breeding
	"_tamed", -- true if mob is tame
})
--[[ NOT persisted variables:
	_last_feeder: Name of the player who last fed the mob, used for achievement
]]


local feed_handling = function(mob, feeder_name, food_points, food_till_tamed, food_till_horny, add_child_grow_timer) -- Check if a mob is fed
	-- Increase tame and horny level
	if not mob._tamed then
		mob._tame_level = (mob._tame_level or 0) + food_points
	end
	if not mob._child and not mob._horny then
		mob._horny_level = (mob._horny_level or 0) + food_points
	end

	-- Remember name of feeder for achievements
	if feeder_name then
		mob._last_feeder = feeder_name
	end

	-- Tame mob if threshold was reached
	if food_till_tamed and mob._tame_level >= food_till_tamed then
		mob._tame_level = 0

		if (not mob._tamed) and feeder_name ~= nil then
			mob._tamed = true

			local feeder = minetest.get_player_by_name(feeder_name)
			if feeder and feeder:is_player() then
				achievements.trigger_achievement(feeder, "best_friends_forever")
			end
		end
	end

	-- Make children grow quicker
	if mob._child and add_child_grow_timer then
		mob._child_grow_timer = mob._child_grow_timer + add_child_grow_timer
	end

	-- Make mob horny if threshold was reached
	if not mob._child and not mob._horny and food_till_horny and mob._horny_level >= food_till_horny and mob._horny_timer == 0 then
		mob._horny_level = 0

		rp_mobs.make_horny(mob, true)
	end
end

-- Let a player feed a mob with their wielded item and optionally tame it and make it horny
-- * mob: The mob that is fed
-- * feeder: Player who feeds the mob
-- * allowed_foods: List of allowed food items
-- * food_till_tamed: How many food points the mob needs until it is tamed (nil = no taming)
-- * food_till_horny: How many food points the mob needs until it becomes horny (nil = no horny)
-- * add_child_growth_timer: (optional) By how many seconds the child growth timer is increased (default: 20)
-- * effect: (optional) true to show particle effects, false otherwise (default: true)
-- * eat_sound: (optional) Name of sound to play for the mob eating (default: "mobs_eat")
rp_mobs.feed_tame_breed = function(mob, feeder, allowed_foods, food_till_tamed, food_till_horny, add_child_grow_timer, effect, eat_sound)
	if not rp_mobs.is_alive(mob) then
		return false
	end
	if not add_child_grow_timer then
		add_child_grow_timer = DEFAULT_ADD_CHILD_GROW_TIMER
	end

	local fed_item = nil
	local fed_itemstring = nil
	local feeder_name = nil

	if feeder and feeder:is_player() then
		fed_item = feeder:get_wielded_item()
		fed_itemstring = fed_item:get_name()
		feeder_name = feeder:get_player_name()
	end

	local can_eat = false
	local food_points
	for f=1, #allowed_foods do
		if allowed_foods[f] == fed_itemstring then
			can_eat = true
			-- TODO: Add custom food points
			food_points = 1
			break
		end
	end

	if can_eat then
		if feeder_name ~= nil then
			-- Take item
			if not minetest.is_creative_enabled(feeder_name) then
				fed_item:take_item()
				feeder:set_wielded_item(fed_item)
			end

	 		-- Update achievement
			local entdef = minetest.registered_entities[mob.name]
			if entdef and entdef._is_animal == true then
				achievements.trigger_subcondition(feeder, "gonna_feed_em_all", mob.name)
			end

		end

		if eat_sound == nil then
			rp_mobs.default_mob_sound(mob, "eat", true)
		else
			rp_mobs.mob_sound(mob, eat_sound, true)
		end

		if effect ~= false then
			local mobpos = mob.object:get_pos()
			minetest.add_particlespawner(
			{
				amount = 10,
				time = 0.1,
				minpos = {x = mobpos.x - 0.1, y = mobpos.y - 0.1, z = mobpos.z - 0.1},
				maxpos = {x = mobpos.x + 0.1, y = mobpos.y + 0.1, z = mobpos.z + 0.1},
				minvel = {x = -1, y = -1, z = -1},
				maxvel = {x = 1, y = 0, z = 1},
				minacc = {x = 0, y = 6, z = 0},
				maxacc = {x = 0, y = 1, z = 0},
				minexptime = 0.5,
				maxexptime = 1,
				minsize = 0.5,
				maxsize = 2,
				texture = {
					name = "rp_hud_particle_eatpuff.png",
					scale_tween = { 1, 0, start = 0.75 },
				},
			})
		end

		feed_handling(mob, feeder_name, food_points, food_till_tamed, food_till_horny, add_child_grow_timer)

		return true
	else
		return false
	end
end
