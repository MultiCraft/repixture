-- Minimum theoretical sunlight level required for birds to sing
local BIRDS_MIN_LIGHT = 10

-- Register default ambiances

ambiance.register_ambiance("rp_ambiance:birds_leaves", {
   length = 5.0,
   chance = 4,
   file = "ambiance_birds_robin",
   dist = 8,
   nodename = "rp_default:leaves",
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      -- Birds only sing in nodes that are close to sunlight.
      -- This ensures birds won't sing in the caves without
      -- needing a hardcoded (and ugly) Y check.
      if not ambiance.is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if ambiance.is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:birds_leaves_birch", {
   length = 8.0,
   chance = 6,
   file = "ambiance_birds_cold",
   dist = 8,
   nodename = "rp_default:leaves_birch",
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if ambiance.is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:birds_leaves_oak", {
   length = 5.0,
   chance = 4,
   file = "ambiance_birds_blackbird",
   dist = 8,
   nodename = "rp_default:leaves_oak",
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      -- bit of overlap into crickets
      if ambiance.is_in_timeofday_range(tod, 5640, 18360) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:owl_birch", {
   length = 5.0,
   chance = 10,
   file = "ambiance_whoot_owl",
   dist = 8,
   nodename = "rp_default:leaves_birch",
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      if ambiance.is_in_timeofday_range(tod, 20000, 4000) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:owl_oak", {
   length = 5.0,
   chance = 5,
   file = "ambiance_tawny_owl",
   dist = 8,
   gain = 0.9,
   nodename = "rp_default:leaves_oak",
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_indirect(pos, BIRDS_MIN_LIGHT) then
         return false
      end

      local tod = minetest.get_timeofday()
      if ambiance.is_in_timeofday_range(tod, 20000, 4000) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:crickets", {
   length = 6.0,
   chance = 15,
   file = "ambiance_crickets",
   dist = 8,
   gain = 0.15,
   nodename = {"group:normal_grass", "group:dry_grass"},
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_direct(pos) then
         return false
      end

      local tod = minetest.get_timeofday()
      if ambiance.is_in_timeofday_range(tod, 18000, 6000) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:cricket_mountain", {
   length = 0.5,
   chance = 100,
   file = "ambiance_cricket_mountain",
   dist = 8,
   nodename = {"group:dry_leaves", "group:dry_grass"},
   can_play = function(pos)
      if ambiance.weather_available() then
         if ambiance.get_weather_lagged() ~= "clear" then
            return false
         end
      end

      if not ambiance.is_sky_exposed_direct(pos, true) then
         return false
      end

      local tod = minetest.get_timeofday()
      if ambiance.is_in_timeofday_range(tod, 6000, 18000) then
         return true
      end

      return false
   end,
})



ambiance.register_ambiance("rp_ambiance:frog", {
   length = 0.5,
   chance = 64,
   pitch_min = -10,
   pitch_max = 10,
   file = "ambiance_frog",
   dist = 16,
   nodename = "group:swamp_grass",
   can_play = function(pos)
      if not ambiance.is_sky_exposed_direct(pos) then
         return false
      end

      local tod = minetest.get_timeofday()
      if ambiance.is_in_timeofday_range(tod, 19200, 4800) then
         return true
      end

      return false
   end,
})

ambiance.register_ambiance("rp_ambiance:flowing_water", {
   length = 2.6,
   chance = 1,
   file = "ambiance_water",
   dist = 16,
   gain = 0.08,
   nodename = "group:flowing_water",
   can_play = function(pos)
      -- Flowing water can only make noise when it's next to any non-solid non-water node
      local neighbors = {
         vector.new(0,0,-1),
         vector.new(0,0,1),
         vector.new(0,-1,0),
         vector.new(0,1,0),
         vector.new(-1,0,0),
         vector.new(1,0,0),
      }
      for n=1, #neighbors do
         local node = minetest.get_node(vector.add(pos, neighbors[n]))
         local def = minetest.registered_nodes[node.name]
         if def and not def.walkable and minetest.get_item_group(node.name, "water") == 0 then
            return true
         end
      end
      return
   end,
})

