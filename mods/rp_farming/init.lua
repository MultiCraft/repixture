
--
-- Farming mod
-- By Kaadmy, for Pixture
--

farming = {}

dofile(minetest.get_modpath("rp_farming").."/api.lua")
dofile(minetest.get_modpath("rp_farming").."/nodes.lua")
dofile(minetest.get_modpath("rp_farming").."/plants.lua")
dofile(minetest.get_modpath("rp_farming").."/craft.lua")
dofile(minetest.get_modpath("rp_farming").."/achievements.lua")

default.log("mod:rp_farming", "loaded")
