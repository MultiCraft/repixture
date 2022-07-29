local S = minetest.get_translator("rp_farming")
--
-- Achievements
--

achievements.register_achievement(
   "farmer",
   {
      title = S("Farmer"),
      -- "crop" as in "usable plant" / "plant for farming"
      description = S("Plant a crop."),
      times = 1,
      placenode = "group:seed",
      item_icon = "rp_farming:wheat_1",
   })

