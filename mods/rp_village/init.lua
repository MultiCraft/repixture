--
-- Villages mod
-- By Kaadmy, for Pixture
--

village = {}

village.min_size = 2 -- Min chunk gen iterations
village.max_size = 6 -- Max chunk gen iterations

-- Closest distance a village will spawn from another village
village.min_spawn_dist = 512

local mapseed = minetest.get_mapgen_setting("seed")
village.pr = PseudoRandom(mapseed)

dofile(minetest.get_modpath("rp_village") .. "/names.lua")
dofile(minetest.get_modpath("rp_village") .. "/generate.lua")
dofile(minetest.get_modpath("rp_village") .. "/mapgen.lua")

default.log("mod:rp_village", "loaded")
