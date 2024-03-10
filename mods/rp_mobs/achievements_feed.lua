-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

local animals = {}
local animal_names = {}

minetest.register_on_mods_loaded(function()
	for k,v in pairs(minetest.registered_entities) do
		if v._cmi_is_mob and v._is_animal then
			table.insert(animals, k)
			if v._description then
				table.insert(animal_names, v._description)
			else
				table.insert(animal_names, k)
			end
		end
	end

	achievements.register_achievement(
		"gonna_feed_em_all", {
			title = S("Gonna Feed ’em All"),
			description = S("Feed an animal of each species once."),
			times = 0,
			subconditions = animals,
			subconditions_readable = animal_names,
			icon = "mobs_achievement_gonna_feed_em_all.png",
			difficulty = 6.6,
		}
	)
end)
