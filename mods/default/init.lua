--
-- Default mod
-- By Kaadmy, for Pixture
--

default = {}

default.SWAMP_WATER_VISC = 4

default.RIVER_WATER_VISC = 2

default.WATER_VISC = 1

default.LIGHT_MAX = 14

function default.log(text, type)
   local level = "action"
   if type == "loaded" then
     level = "info"
   end
   minetest.log(level, "Pixture ["..type.."] "..text)
end

function default.dumpvec(v)
   return v.x..":"..v.y..":"..v.z
end

minetest.nodedef_default.stack_max = 60
minetest.craftitemdef_default.stack_max = 60

function minetest.nodedef_default.on_receive_fields(pos, form_name, fields, player)
   default.ui.receive_fields(player, form_name, fields)
end

dofile(minetest.get_modpath("default").."/formspec.lua")
dofile(minetest.get_modpath("default").."/functions.lua")
dofile(minetest.get_modpath("default").."/sounds.lua")

dofile(minetest.get_modpath("default").."/nodes.lua") -- simple nodes
dofile(minetest.get_modpath("default").."/torch.lua")
dofile(minetest.get_modpath("default").."/furnace.lua")
dofile(minetest.get_modpath("default").."/container.lua") -- chest and bookshelf
dofile(minetest.get_modpath("default").."/sign.lua")

dofile(minetest.get_modpath("default").."/craftitems.lua") -- simple craftitems
dofile(minetest.get_modpath("default").."/bucket.lua")
dofile(minetest.get_modpath("default").."/tools.lua")
dofile(minetest.get_modpath("default").."/fertilizer.lua")

dofile(minetest.get_modpath("default").."/crafting.lua")

dofile(minetest.get_modpath("default").."/mapgen.lua")

dofile(minetest.get_modpath("default").."/hud.lua")
dofile(minetest.get_modpath("default").."/player.lua")
dofile(minetest.get_modpath("default").."/model.lua")

default.log("mod:default", "loaded")
