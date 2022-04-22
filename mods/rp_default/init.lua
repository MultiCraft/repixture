-- Use 'default' table for this mod as API
-- instead of 'rp_default' to not disrupt old mods
-- depending on this (before version 1.5.3) too much.

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
   minetest.log(level, "Repixture ["..type.."] "..text)
end

function default.dumpvec(v)
   return v.x..":"..v.y..":"..v.z
end

minetest.nodedef_default.stack_max = 60
minetest.craftitemdef_default.stack_max = 60

function minetest.nodedef_default.on_receive_fields(pos, form_name, fields, player)
   default.ui.receive_fields(player, form_name, fields)
end

dofile(minetest.get_modpath("rp_default").."/formspec.lua")
dofile(minetest.get_modpath("rp_default").."/functions.lua")
dofile(minetest.get_modpath("rp_default").."/sounds.lua")

dofile(minetest.get_modpath("rp_default").."/nodes.lua") -- simple nodes
dofile(minetest.get_modpath("rp_default").."/torch.lua")
dofile(minetest.get_modpath("rp_default").."/furnace.lua")
dofile(minetest.get_modpath("rp_default").."/container.lua") -- chest and bookshelf
dofile(minetest.get_modpath("rp_default").."/sign.lua")

dofile(minetest.get_modpath("rp_default").."/craftitems.lua") -- simple craftitems
dofile(minetest.get_modpath("rp_default").."/bucket.lua")
dofile(minetest.get_modpath("rp_default").."/tools.lua")
dofile(minetest.get_modpath("rp_default").."/fertilizer.lua")

dofile(minetest.get_modpath("rp_default").."/crafting.lua")

dofile(minetest.get_modpath("rp_default").."/mapgen.lua")

dofile(minetest.get_modpath("rp_default").."/hud.lua")
dofile(minetest.get_modpath("rp_default").."/player.lua")
dofile(minetest.get_modpath("rp_default").."/model.lua")

dofile(minetest.get_modpath("rp_default").."/aliases.lua")

default.log("mod:default", "loaded")