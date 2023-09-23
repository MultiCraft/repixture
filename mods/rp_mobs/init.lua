rp_mobs = {}

local path = minetest.get_modpath("rp_mobs")

-- Helper data structure for tasks
dofile(path.."/doubly_linked_list.lua")

-- Mob API

dofile(path.."/api.lua")
dofile(path.."/task_templates.lua")

-- Mob items and crafts

dofile(path.."/crafts.lua")

-- Achievements

dofile(path.."/achievements.lua")

-- 'Gonna Feed 'em All' achievement
dofile(path.."/achievements_feed.lua")
