
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
      grow_time = 600,
      grows_near = {"group:water"},
      growing_distance = 2,
      grows_on = {"group:plantable_soil"},
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
      grows_on = {"group:plantable_sandy", "group:plantable_soil", "group:plantable_dry"},
      light_min = 12,
      light_max = 15,
   }
)
