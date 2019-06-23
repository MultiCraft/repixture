
--
-- Map handling
--

-- Items

minetest.register_craftitem(
   "nav:map",
   {
      description = "Map",
      inventory_image = "nav_inventory.png",
      wield_image = "nav_inventory.png",
      stack_max = 1,
})

-- Crafting

crafting.register_craft(
   {
      output = "nav:map",
      items = {
         "default:stick 6",
         "default:paper 3",
      }
})


-- Achievements

achievements.register_achievement(
   "navigator",
   {
      title = "Navigator",
      description = "Craft a map",
      times = 1,
      craftitem = "nav:map",
})

default.log("map", "loaded")
