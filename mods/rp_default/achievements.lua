if not minetest.get_modpath("rp_achievements") then
	return
end

local S = minetest.get_translator("rp_default")

-- Digging wood

achievements.register_achievement(
   "timber",
   {
      title = S("Timber"),
      description = S("Dig a tree trunk."),
      times = 1,
      dignode = "group:tree",
      item_icon = "rp_default:tree",
})

-- Tools

achievements.register_achievement(
   "first_pickaxe",
   {
      title = S("My First Pickaxe"),
      description = S("Craft a pickaxe."),
      times = 1,
      craftitem = "group:pickaxe",
      item_icon = "rp_default:pick_wood",
})

achievements.register_achievement(
   "hardened_miner",
   {
      title = S("Hardened Miner"),
      description = S("Craft a carbon steel pickaxe."),
      times = 1,
      craftitem = "rp_default:pick_carbon_steel",
})

achievements.register_achievement(
   "off_to_battle",
   {
      title = S("Off to Battle"),
      description = S("Craft a broadsword."),
      times = 1,
      craftitem = "rp_default:broadsword",
})

-- Stone

achievements.register_achievement(
   "mineority",
   {
      title = S("Mineority"),
      description = S("Mine a stone."),
      times = 1,
      dignode = "rp_default:stone",
})

achievements.register_achievement(
   "smelting_room",
   {
      title = S("Smelting Room"),
      description = S("Craft a furnace."),
      times = 1,
      craftitem = "rp_default:furnace",
})



-- Biomes

achievements.register_achievement(
   "gardener",
   {
      title = S("Gardener"),
      description = S("Plant a flower."),
      times = 1,
      placenode = "rp_default:flower",
})

achievements.register_achievement(
   "welcome_to_the_mountains",
   {
      title = S("Dry Lands"),
      description = S("Collect dry grass."),
      times = 1,
      dignode = "rp_default:dry_grass",
})

achievements.register_achievement(
   "drain_the_swamp",
   {
      title = S("Drain the Swamp"),
      description = S("Dig some swamp dirt."),
      times = 1,
      dignode = "group:swamp_dirt",
      item_icon = "rp_default:swamp_dirt",
})

-- Farming

achievements.register_achievement(
   "fertile",
   {
      title = S("Fertile"),
      description = S("Craft a bag of fertilizer."),
      times = 1,
      craftitem = "rp_default:fertilizer",
})

-- Literature

achievements.register_achievement(
   "librarian",
   {
      title = S("Librarian"),
      description = S("Craft a bookshelf."),
      times = 1,
      craftitem = "rp_default:bookshelf",
})
