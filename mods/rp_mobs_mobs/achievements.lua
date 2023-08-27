-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

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

