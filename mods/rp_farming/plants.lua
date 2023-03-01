
--
-- Plants
--

farming.register_plant(
   "rp_farming:wheat",
   {
      grow_time = 600,
      grows_near = {"group:water"},
      growing_distance = 3,
      grows_on = {"group:plantable_soil"},
      light_min = 8,
      light_max = 15,
   }
)

farming.register_plant(
   "rp_farming:potato",
   {
      grow_time = 650,
      grows_near = {"group:water"},
      growing_distance = 2,
      grows_on = {"group:plantable_soil", "group:plantable_wet"},
      light_min = 8,
      light_max = 15,
      sound_seed_place = { name = "rp_farming_place_nonseed", gain = 0.4 }
   }
)

farming.register_plant(
   "rp_farming:carrot",
   {
      grow_time = 500,
      grows_near = {"group:water"},
      growing_distance = 4,
      grows_on = {"group:plantable_dry"},
      light_min = 12,
      light_max = 15,
      sound_seed_place = { name = "rp_farming_place_nonseed", gain = 0.4 }
   }
)

farming.register_plant(
   "rp_farming:asparagus",
   {
      grow_time = 800,
      grows_near = {"group:water"},
      growing_distance = 1,
      grows_on = {"group:plantable_wet"},
      light_min = 8,
      light_max = 15,
   }
)

farming.register_plant(
   "rp_farming:cotton",
   {
      grow_time = 780,
      grows_near = {"group:water"},
      growing_distance = 4,
      grows_on = {"group:plantable_soil", "group:plantable_sandy", "group:plantable_dry"},
      light_min = 12,
      light_max = 15,
   }
)
