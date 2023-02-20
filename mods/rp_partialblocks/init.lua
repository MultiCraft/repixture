--
-- Partial blocks mod
--

partialblocks = {}

dofile(minetest.get_modpath("rp_partialblocks").."/api.lua") -- API function(s)
dofile(minetest.get_modpath("rp_partialblocks").."/register.lua") -- node registrations
dofile(minetest.get_modpath("rp_partialblocks").."/crafts.lua") -- special crafting recipes
dofile(minetest.get_modpath("rp_partialblocks").."/aliases.lua") -- node aliases
