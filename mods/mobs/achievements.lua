
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
})

local peaceful_only = minetest.settings:get_bool("only_peaceful_mobs") or false

if not peaceful_only then
    achievements.register_achievement(
       "bomb_has_been_defused",
       {
          title = S("Bomb has Been Defused!"),
          description = S("Kill a mine turtle."),
          times = 1,
    })
end

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

achievements.register_achievement(
   "smalltalk",
   {
      title = S("Smalltalk"),
      description = S("Visit a village and have a friendly chat with a villager."),
      times = 1,
})
