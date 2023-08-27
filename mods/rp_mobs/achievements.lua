
--
-- Achievements
--
local S = minetest.get_translator("mobs")

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


