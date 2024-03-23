rp_mobs_mobs = {}

-- Shared functions
dofile(minetest.get_modpath("rp_mobs_mobs").."/shared.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/movement.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/attack.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/land_roam.lua")

-- Mobs: Animals
dofile(minetest.get_modpath("rp_mobs_mobs").."/boar.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/sheep.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/skunk.lua")

-- Mobs: Monsters
dofile(minetest.get_modpath("rp_mobs_mobs").."/walker.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/mineturtle.lua")

-- Mob: Villager
dofile(minetest.get_modpath("rp_mobs_mobs").."/villager.lua")

-- Other
dofile(minetest.get_modpath("rp_mobs_mobs").."/crafts.lua")
dofile(minetest.get_modpath("rp_mobs_mobs").."/achievements.lua")
