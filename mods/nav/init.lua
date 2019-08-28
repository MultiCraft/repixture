--
-- Nav mod
-- By Kaadmy, for Pixture
--

nav = {}

dofile(minetest.get_modpath("nav").."/waypoints.lua") -- TODO: Waypoint implenentation is a stub
dofile(minetest.get_modpath("nav").."/map.lua")
dofile(minetest.get_modpath("nav").."/compass.lua")

default.log("mod:nav", "loaded")
