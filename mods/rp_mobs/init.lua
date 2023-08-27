rp_mobs = {}

local path = minetest.get_modpath("rp_mobs")

-- Mob API

dofile(path.."/api.lua")

-- Mob items and crafts

dofile(path.."/crafts.lua")

-- Achievements

dofile(path.."/achievements.lua")

-- 'Gonna Feed 'em All' achievement
dofile(path.."/achievements_feed.lua")
