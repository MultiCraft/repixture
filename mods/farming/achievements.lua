local S = minetest.get_translator("farming")
--
-- Achievements
--

achievements.register_achievement(
   "farmer",
   {
      title = S("Farmer"),
      description = S("Plant 20 wheat seeds."),
      times = 20,
      placenode = "farming:wheat_1",
   })

achievements.register_achievement(
   "master_farmer",
   {
      title = S("Master Farmer"),
      description = S("Plant 200 wheat seeds."),
      times = 200,
      placenode = "farming:wheat_1",
   })

achievements.register_achievement(
   "cotton_farmer",
   {
      title = S("Cotton Farmer"),
      description = S("Plant 10 cotton seeds."),
      times = 10,
      placenode = "farming:cotton_1",
   })

achievements.register_achievement(
   "master_cotton_farmer",
   {
      title = S("Master Cotton Farmer"),
      description = S("Plant 100 cotton seeds."),
      times = 100,
      placenode = "farming:cotton_1",
   })

default.log("achievements", "loaded")
