rp_mobs_mobs = {}

-- Crafting stuff
dofile(minetest.get_modpath("rp_mobs_mobs").."/crafts.lua")

-- Animals
dofile(minetest.get_modpath("rp_mobs_mobs").."/boar.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/sheep.lua")

-- Monsters (TODO)

-- Dummy mob used only for testing
dofile(minetest.get_modpath("rp_mobs_mobs").."/dummy.lua")

-- Other
dofile(minetest.get_modpath("rp_mobs_mobs").."/achievements.lua")
