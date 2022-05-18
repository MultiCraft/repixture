-- Use 'default' table for this mod as API
-- instead of 'rp_default' to not disrupt old mods
-- depending on this (before version 1.5.3) too much.

default = {}

default.SWAMP_WATER_VISC = 4

default.RIVER_WATER_VISC = 2

default.WATER_VISC = 1

default.LIGHT_MAX = 14

-- If a sapling is affected by fertilizer,
-- the growth timer is reduced by this
-- factor. E.g. if the timeout is 100s
-- and the factor is 0.1, the growth time
-- is reduced by 100s*0.1 = 10s.
default.SAPLING_FERTILIZER_TIME_BONUS_FACTOR = 0.1

minetest.nodedef_default.stack_max = 60
minetest.craftitemdef_default.stack_max = 60


--[[ This game uses biome versions to allow backwards-compability
of old maps. A biome version bump is neccessary whenever there's
a drastic change in biome heat/humidity point that would
lead to ugly discontinutities after a game update.

Version 1: Closest to the original Pixture game.
           Official biomes till game version 2.1.0
Version 2: Major biome update introducing tons of new biomes and
           removing the Desert and Gravel Beach. Introduced more
           swamp biomes, swamp highland, dry land biomes, shrubbery,
           oak forests, birch forests, "technical" ocean/beach biomes,
           Underground biome, and much more.
           Biome heat/humidity points of existing biomes had to be
           completely updated.
           Introduced in game version 2.2.0.
]]
local LATEST_BIOME_VERSION = 2
local bv = minetest.get_mapgen_setting("rp_biome_version")
if bv then
	default.biome_version = tonumber(default.biome_version)
end
if default.biome_version ~= 1 and default.biome_version ~= 2 then
	default.biome_version = LATEST_BIOME_VERSION
end

dofile(minetest.get_modpath("rp_default").."/functions.lua")

dofile(minetest.get_modpath("rp_default").."/nodes.lua") -- simple nodes
dofile(minetest.get_modpath("rp_default").."/torch.lua")
dofile(minetest.get_modpath("rp_default").."/furnace.lua")
dofile(minetest.get_modpath("rp_default").."/container.lua") -- chest and bookshelf
dofile(minetest.get_modpath("rp_default").."/sign.lua")
dofile(minetest.get_modpath("rp_default").."/fence.lua")
dofile(minetest.get_modpath("rp_default").."/ladder.lua")

dofile(minetest.get_modpath("rp_default").."/craftitems.lua") -- simple craftitems
dofile(minetest.get_modpath("rp_default").."/bucket.lua")
dofile(minetest.get_modpath("rp_default").."/tools.lua")
dofile(minetest.get_modpath("rp_default").."/fertilizer.lua")

dofile(minetest.get_modpath("rp_default").."/crafting.lua")
dofile(minetest.get_modpath("rp_default").."/achievements.lua")

dofile(minetest.get_modpath("rp_default").."/mapgen_core.lua")
dofile(minetest.get_modpath("rp_default").."/mapgen_biomes_v"..default.biome_version..".lua")
dofile(minetest.get_modpath("rp_default").."/mapgen_ores.lua")
dofile(minetest.get_modpath("rp_default").."/mapgen_deco.lua")

dofile(minetest.get_modpath("rp_default").."/aliases.lua")
