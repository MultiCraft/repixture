--
-- Nav mod
-- By Kaadmy, for Pixture
--

nav = {}

dofile(minetest.get_modpath("rp_nav").."/waypoints.lua") -- TODO: Waypoint implenentation is a stub
dofile(minetest.get_modpath("rp_nav").."/map.lua")
dofile(minetest.get_modpath("rp_nav").."/compass.lua")

default.log("mod:rp_nav", "loaded")
