
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
      item_icon = "mobs:meat_raw",
      difficulty = 3.3,
})

local peaceful_only = minetest.settings:get_bool("only_peaceful_mobs") or false

if not peaceful_only then
    achievements.register_achievement(
       "bomb_has_been_defused",
       {
          title = S("Bomb has Been Defused!"),
          description = S("Kill a mine turtle."),
          times = 1,
	  icon = "mobs_achievement_bomb_has_been_defused.png",
	  difficulty = 4.5,
    })
end

achievements.register_achievement(
   "ranger",
   {
      title = S("Gotcha!"),
      description = S("Capture a tame animal."),
      times = 1,
      item_icon = "mobs:lasso",
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

achievements.register_achievement(
   "shear_time",
   {
      title = S("Taking a Cut"),
      description = S("Shear a sheep."),
      times = 1,
      icon = "mobs_achievement_shear_time.png",
      difficulty = 4.8,
})

achievements.register_achievement(
   "smalltalk",
   {
      title = S("Smalltalk"),
      description = S("Have a friendly chat with a villager."),
      times = 1,
      icon = "mobs_achievement_smalltalk.png",
      difficulty = 3.4,
})

