if not minetest.get_modpath("rp_achievements") then
	return
end

local mg_name = minetest.get_mapgen_setting("mg_name")

local S = minetest.get_translator("rp_default")

-- Digging wood

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 1
   "timber",
   {
      title = S("Timber"),
      description = S("Dig a tree trunk."),
      times = 1,
      dignode = "group:tree",
      item_icon = "rp_default:tree",
      difficulty = 1,
})

-- Tools

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 2
   "first_pickaxe",
   {
      title = S("My First Pickaxe"),
      description = S("Craft a pickaxe."),
      times = 1,
      craftitem = "group:pickaxe",
      item_icon = "rp_default:pick_wood",
      difficulty = 2,
})

achievements.register_achievement(
   "hardened_miner",
   {
      title = S("Hardened Miner"),
      description = S("Craft a carbon steel pickaxe."),
      times = 1,
      craftitem = "rp_default:pick_carbon_steel",
      difficulty = 5.9,
})

achievements.register_achievement(
   "off_to_battle",
   {
      title = S("Off to Battle"),
      description = S("Craft a weapon."),
      times = 1,
      craftitem = "group:weapon",
      item_icon = "rp_default:spear_wrought_iron",
      difficulty = 2.1,
})

-- Stone

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 3
   "mineority",
   {
      title = S("Mineority"),
      description = S("Mine a stone."),
      times = 1,
      dignode = "rp_default:stone",
      difficulty = 3,
})

achievements.register_achievement(
   "smelting_room",
   {
      title = S("Smelting Room"),
      description = S("Craft a furnace."),
      times = 1,
      craftitem = "rp_default:furnace",
      difficulty = 3.1,
})

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 4
   "metal_age",
   {
      title = S("Metal Age"),
      description = S("Put a mineral and some fuel in a furnace to smelt an ingot."),
      times = 1,
      item_icon = "rp_default:ingot_wrought_iron",
      difficulty = 4,
})

-- Farming

achievements.register_achievement(
   "fertile",
   {
      title = S("Fertile"),
      description = S("Use fertilizer to fertilize the ground."),
      times = 1,
      item_icon = "rp_default:fertilizer",
      difficulty = 4.2,
})

achievements.register_achievement(
   "mega_papyrus",
   {
      title = S("Overgrowth"),
      description = S("Grow a papyrus to its maximum height, then harvest it."),
      times = 1,
      icon = "rp_default_achievement_mega_papyrus.png",
      difficulty = 4.3,
})

-- Literature

achievements.register_achievement(
   "librarian",
   {
      title = S("Librarian"),
      description = S("Craft a bookshelf."),
      times = 1,
      craftitem = "rp_default:bookshelf",
      difficulty = 4.2,
})

-- Plant all saplings

do
	local saplings = {}
	local saplings_readable = {}
	for k,v in pairs(minetest.registered_nodes) do
		if minetest.get_item_group(k, "sapling") > 0 then
			table.insert(saplings, k)
			table.insert(saplings_readable, v.description)
		end
	end

	achievements.register_achievement("forester",
	{
		title = S("Forester"),
		description = S("Plant one of every sapling."),
		times = 0,
		icon = "rp_default_achievement_forester.png",
		subconditions = saplings,
		subconditions_readable = saplings_readable,
		difficulty = 5.6,
	})
end

if mg_name ~= "v6" then
	-- Visit all biomes

	local main_biomes = default.get_main_biomes()
	local biomes = {}
	local biomes_readable = {}
	for b=1, #main_biomes do
		local biomename = main_biomes[b]
                local binfo = default.get_biome_info(biomename)
		if binfo and binfo.class ~= "undergroundy" then
			local biome = minetest.registered_biomes[biomename]
			if biome then
				table.insert(biomes, biomename)
				table.insert(biomes_readable, biome._description)
			end
		end
	end

	achievements.register_achievement(
           -- REFERENCE ACHIEVEMENT 10
	   "find_all_biomes",
	   {
	      title = S("Explorer"),
	      description = S("Visit all surface biomes."),
	      subconditions = biomes,
	      subconditions_readable = biomes_readable,
	      times = 0,
	      item_icon = "rp_armor:boots_steel",
              difficulty = 10,
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

minetest.register_on_mods_loaded(function()
	if not minetest.get_modpath("rp_checkitem") then
		return
	end

	local minerals = {}
	local minerals_readable = {}
	for k,v in pairs(minetest.registered_items) do
		if minetest.get_item_group(k, "mineral_natural") == 1 then
			table.insert(minerals, k)
			table.insert(minerals_readable, ItemStack(k):get_short_description())
		end
	end

	-- Achievement for collecting all minerals that generate naturally in the world
	-- (e.g. coal lump, iron lump, etc.).
	achievements.register_achievement(
	"find_all_minerals",
	{
		title = S("A Complete Collection"),
		description = S("Obtain one of each minerals."),
		subconditions = minerals,
		subconditions_readable = minerals_readable,
		times = 0,
		icon = "rp_default_achievement_find_all_minerals.png",
		difficulty = 6.5,
	})

	for m=1, #minerals do
		rp_checkitem.register_on_got_item(minerals[m], function(player)
			achievements.trigger_subcondition(player, "find_all_minerals", minerals[m])
		end)
	end
end)

