local S = minetest.get_translator("rp_mobs")

local animals = {}
local animal_names = {}

minetest.register_on_mods_loaded(function()
	for mobname, mobdef in pairs(rp_mobs.registered_mobs) do
		if rp_mobs.mobdef_has_tag(mobname, "animal") then
			local subcondition_name = mobname
			table.insert(animals, subcondition_name)
			if mobdef.entity_definition and mobdef.entity_definition._description then
				table.insert(animal_names, mobdef.entity_definition._description)
			else
				table.insert(animal_names, mobname)
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

	-- Subcondition aliases for mobs from Repixture version 3.12.1 and earlier
	-- to ensure backwards-compability
	achievements.register_subcondition_alias("gonna_feed_em_all", "mobs:boar", "rp_mobs_mobs:boar")
	achievements.register_subcondition_alias("gonna_feed_em_all", "mobs:skunk", "rp_mobs_mobs:skunk")
	achievements.register_subcondition_alias("gonna_feed_em_all", "mobs:sheep", "rp_mobs_mobs:sheep")
end)
