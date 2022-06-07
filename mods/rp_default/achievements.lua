if not minetest.get_modpath("rp_achievements") then
	return
end

local mg_name = minetest.get_mapgen_setting("mg_name")

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



-- Flower

achievements.register_achievement(
   "gardener",
   {
      title = S("Gardener"),
      description = S("Plant a flower."),
      times = 1,
      placenode = "rp_default:flower",
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


if mg_name ~= "v6" then
	-- Visit all biomes

	local biomes = default.get_main_biomes()
	local biomes_readable = {}
	for b=1, #biomes do
		local biome = minetest.registered_biomes[biomes[b]]
		if biome then
			biomes_readable[b] = biome._description
		end
	end

	achievements.register_achievement(
	   "find_all_biomes",
	   {
	      title = S("Explorer"),
	      description = S("Visit all land biomes."),
	      subconditions = biomes,
	      subconditions_readable = biomes_readable,
	      times = 0,
	})

	local timer = 0
	local BIOME_CHECK_TIME = 1
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < BIOME_CHECK_TIME then
			return
		end
		timer = 0

		local players = minetest.get_connected_players()
		for p=1, #players do
			local player = players[p]
			local biomedata = minetest.get_biome_data(player:get_pos())
			if biomedata then
				local biome = minetest.get_biome_name(biomedata.biome)
				local biomeinfo = default.get_biome_info(biome)
				if biomeinfo then
					local main_biome = biomeinfo.main_biome
					achievements.trigger_subcondition(player, "find_all_biomes", main_biome)
				end
			end
		end
	end)
end
