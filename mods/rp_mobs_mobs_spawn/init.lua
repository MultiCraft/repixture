-- This file contains the spawning rules for the built-in Repixture mobs.
-- This mod has been separated from both rp_mobs and
-- rp_mobs_mobs to weaken the coupling

-- Boar
rp_mobs_spawn.register_spawn("rp_mobs_mobs:boar", {
	nodes = { "rp_default:dirt_with_grass" },
	max_light = minetest.LIGHT_MAX,
	min_light = 10,
	interval = 30,
	chance = 15000,
	active_object_limit = 1,
	active_object_limit_wider = 1,
})

-- Sheep
rp_mobs_spawn.register_spawn("rp_mobs_mobs:sheep", {
	nodes = { "rp_default:dirt_with_grass" },
	max_light = minetest.LIGHT_MAX,
	min_light = 7,
	interval = 30,
	chance = 12000,
	active_object_limit = 2,
	active_object_limit_wider = 2,
})

-- Skunk
rp_mobs_spawn.register_spawn("rp_mobs_mobs:skunk", {
	nodes = { "rp_default:dirt_with_grass" },
	max_light = minetest.LIGHT_MAX,
	min_light = 10,
	interval = 30,
	chance = 15000,
	active_object_limit = 1,
	active_object_limit_wider = 1,
	max_height = 50,
})


-- Mine Turtle
rp_mobs_spawn.register_spawn("rp_mobs_mobs:mineturtle", {
	nodes = { "rp_default:dirt_with_grass" },
	max_light = minetest.LIGHT_MAX,
	min_light = 5,
	interval = 30,
	chance = 200000,
	active_object_limit = 1,
	active_object_limit_wider = 1,
})

-- Walker
rp_mobs_spawn.register_spawn("rp_mobs_mobs:walker", {
	nodes = { "rp_default:dry_dirt", "rp_default:dirt_with_dry_grass" },
	max_light = minetest.LIGHT_MAX,
	min_light = 14,
	interval = 30,
	chance = 12000,
	active_object_limit = 1,
	active_object_limit_wider = 1,
})

