
--
-- Achievements
--
local S = minetest.get_translator("mobs")

achievements.register_achievement(
   "hunter",
   {
      title = S("Hunter"),
      description = S("Kill 5 animals for food."),
      times = 5,
})

achievements.register_achievement(
   "bomb_has_been_defused",
   {
      title = S("Bomb has Been Defused!"),
      description = S("Kill a mine turtle."),
      times = 1,
})

achievements.register_achievement(
   "ranger",
   {
      title = S("Ranger"),
      description = S("Capture a tame animal."),
      times = 1,
})

achievements.register_achievement(
   "best_friends_forever",
   {
      title = S("Best Friends Forever"),
      description = S("Tame an animal."),
      times = 1,
})
