local S = minetest.get_translator("rp_mobs")


--
-- Achievements
--

achievements.register_achievement(
   "hunter",
   {
      -- Note: This achievement only counts animals that
      -- have at least one food item in their drop table
      -- (no matter how unlikely).
      title = S("Hunter"),
      description = S("Kill an animal for food."),
      times = 1,
      icon = "mobs_achievement_hunter.png",
      difficulty = 3.3,
})

achievements.register_achievement(
   "ranger",
   {
      title = S("Gotcha!"),
      description = S("Capture a tame animal."),
      times = 1,
      item_icon = "rp_mobs:lasso",
      difficulty = 5.3,
})

achievements.register_achievement(
   "best_friends_forever",
   {
      title = S("Best Friends Forever"),
      description = S("Tame an animal."),
      times = 1,
      icon = "mobs_achievement_best_friends_forever.png",
      difficulty = 5.05,
})

achievements.register_achievement(
   "wonder_of_life",
   {
      title = S("Wonder of Life"),
      description = S("Get two animals to breed."),
      times = 1,
      icon = "mobs_achievement_wonder_of_life.png",
      difficulty = 5.1,
})


rp_mobs.register_on_die(function(mob, killer)
	local drops_food = false
	local drops
	if not mob or not mob.name then
		return
	end
	local mobdef = rp_mobs.registered_mobs[mob.name]
	if not mobdef then
		return
	end
	if not mob._child and mobdef.drops then
		drops = mobdef.drops
	elseif mob._child and mobdef.child_drops then
		drops = mobdef.child_drops
	end
	if drops then
		for _,drop in ipairs(drops) do
			local item
			if type(drop) == "table" then
				item = drop.name
			elseif type(drop) == "string" then
				item = drop
			end
			if minetest.get_item_group(item, "food") ~= 0 then
				drops_food = true
				break
			end
		end
	end
	if drops_food and killer ~= nil and killer:is_player() and rp_mobs.has_tag(mob, "animal") then
		achievements.trigger_achievement(killer, "hunter")
	end
end)
