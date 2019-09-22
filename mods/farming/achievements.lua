local S = minetest.get_translator("farming")
--
-- Achievements
--

achievements.register_achievement(
   "farmer",
   {
      title = S("Farmer"),
      description = S("Plant a seed and watch it grow."),
      times = 1,
      placenode = "group:seed",
   })

achievements.register_achievement(
   "wheat_farmer",
   {
      title = S("Wheat Farmer"),
      description = S("Harvest a fully-grown wheat plant."),
      times = 1,
      placenode = "farming:wheat_4",
   })

achievements.register_achievement(
   "cotton_farmer",
   {
      title = S("Cotton Farmer"),
      description = S("Harvest a fully-grown cotton plant."),
      times = 1,
      placenode = "farming:cotton_4",
   })

default.log("achievements", "loaded")
