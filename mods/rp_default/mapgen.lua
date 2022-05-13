
--
-- Mapgen
--

-- Uncomment this to cut a big portion of ground out for visualizing ore spawning

--[[
local function on_generated(minp, maxp, blockseed)
   for x = minp.x, maxp.x do
      if x > 0 then
         return
      end

      for z = minp.z, maxp.z do
         if z > -16 and z < 16 then
            for y = minp.y, maxp.y do
               minetest.remove_node({x = x, y = y, z = z})
            end
         end
      end
   end
end

minetest.register_on_generated(on_generated)
--]]

-- Aliases for map generator outputs

minetest.register_alias("mapgen_stone", "rp_default:stone")
minetest.register_alias("mapgen_desert_stone", "rp_default:sandstone")
minetest.register_alias("mapgen_desert_sand", "rp_default:sand")
minetest.register_alias("mapgen_sandstone", "rp_default:sandstone")
minetest.register_alias("mapgen_sandstonebrick", "rp_default:compressed_sandstone")
minetest.register_alias("mapgen_cobble", "rp_default:cobble")
minetest.register_alias("mapgen_gravel", "rp_default:gravel")
minetest.register_alias("mapgen_mossycobble", "rp_default:cobble")
minetest.register_alias("mapgen_dirt", "rp_default:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_sand", "rp_default:sand")
minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_snowblock", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_ice", "rp_default:water_source")
minetest.register_alias("mapgen_tree", "rp_default:tree")
minetest.register_alias("mapgen_leaves", "rp_default:leaves")
minetest.register_alias("mapgen_apple", "rp_default:apple")
minetest.register_alias("mapgen_jungletree", "rp_default:tree_birch")
minetest.register_alias("mapgen_jungleleaves", "rp_default:leaves_birch")
minetest.register_alias("mapgen_junglegrass", "rp_default:tall_grass")
minetest.register_alias("mapgen_pine_tree", "rp_default:tree_oak")
minetest.register_alias("mapgen_pine_needles", "rp_default:leaves_oak")

minetest.register_alias("mapgen_water_source", "rp_default:water_source")
minetest.register_alias("mapgen_river_water_source", "rp_default:river_water_source")

minetest.register_alias("mapgen_lava_source", "rp_default:water_source")

--[[ BIOMES ]]

minetest.clear_registered_biomes()

local mg_name = minetest.get_mapgen_setting("mg_name")

local UNDERGROUND_Y_MAX = -200
local ORCHARD_Y_MIN = 20
local SWAMP_Y_MAX = 7

local register_ocean_and_beach = function(biomename, node_ocean, beach_depth, node_beach)
	local orig_biome = minetest.registered_biomes[biomename]
	if not orig_biome then
		return
	end
	local newdef = table.copy(orig_biome)
	newdef.name = biomename .. " Ocean"
	newdef.node_top = node_ocean or "rp_default:sand"
	newdef.node_filler = newdef.node_top
	newdef.y_min = UNDERGROUND_Y_MAX + 1

	if beach_depth and beach_depth > 0 then
		newdef.y_max = orig_biome.y_min - beach_depth - 1
	else
		newdef.y_max = orig_biome.y_min - 1
	end
	minetest.register_biome(newdef)

	if beach_depth and beach_depth > 0 then

		local newdef2 = table.copy(orig_biome)
		newdef2.name = biomename .. " Beach"
		newdef2.node_top = node_beach or "rp_default:sand"
		newdef2.node_filler = newdef2.node_top
		newdef2.y_min = orig_biome.y_min - beach_depth
		newdef2.y_max = orig_biome.y_min - 1
		minetest.register_biome(newdef2)
	end
end

if mg_name ~= "v6" then

minetest.register_biome(
{
      name = "Marsh",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:dirt",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 2,
      y_max = SWAMP_Y_MAX,

      heat_point = 91,
      humidity_point = 96,
})
register_ocean_and_beach("Marsh", "rp_default:dirt", 2, "rp_default:sand")
default.set_biome_info("Marsh", "grassy")

-- This special biome has the giant birch trees and is
-- limited to a very specific height.
-- It has no equivalent biome above or below.
minetest.register_biome(
   {
      name = "Deep Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 30,
      y_max = 40,

      heat_point = 49,
      humidity_point = 33,
})
default.set_biome_info("Deep Forest", "grassy")

minetest.register_biome(
   {
      name = "Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 200,

      heat_point = 48,
      humidity_point = 34,
})
register_ocean_and_beach("Forest", "rp_default:sand")
default.set_biome_info("Forest", "grassy")

minetest.register_biome(
   {
      name = "Grove",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 3,
      y_max = 32000,

      heat_point = 45,
      humidity_point = 19,
})
register_ocean_and_beach("Grove", "rp_default:sand")
default.set_biome_info("Grove", "grassy")

minetest.register_biome(
   {
      name = "Wilderness",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 3,
      y_max = 32000,

      heat_point = 76,
      humidity_point = 30,
})
register_ocean_and_beach("Wilderness", "rp_default:sand")
default.set_biome_info("Wilderness", "grassy")

-- Note: Grassland is below Orchard
minetest.register_biome(
   {
      name = "Grassland",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 3,
      y_max = ORCHARD_Y_MIN - 1,

      heat_point = 71,
      humidity_point = 52,
})
register_ocean_and_beach("Grassland", "rp_default:sand")
default.set_biome_info("Grassland", "grassy")

-- Note: Orchard is the 'highland' version of Grassland
minetest.register_biome(
   {
      name = "Orchard",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = ORCHARD_Y_MIN,
      y_max = 32000,

      heat_point = 71,
      humidity_point = 52,
})
default.set_biome_info("Orchard", "grassy")

-- Note: Shrubbery is below Chaparral
minetest.register_biome(
   {
      name = "Shrubbery",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 55,

      heat_point = 107,
      humidity_point = 45,
})
register_ocean_and_beach("Shrubbery", "rp_default:sand")
default.set_biome_info("Shrubbery", "grassy")

-- Note: High biome. This is the highland version of Shrubbery
minetest.register_biome(
   {
      name = "Chaparral",

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 56,
      y_max = 32000,

      heat_point = 107,
      humidity_point = 45,
})
default.set_biome_info("Chaparral", "savannic")

minetest.register_biome(
   {
      name = "Savanna",

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 2,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 2,
      y_max = 55,

      heat_point = 101,
      humidity_point = 25,
})
register_ocean_and_beach("Savanna", "rp_default:sand")
default.set_biome_info("Savanna", "savannic")

minetest.register_biome(
   {
      name = "Desert",

      node_top = "rp_default:sand",
      node_filler = "rp_default:sandstone",
      node_riverbed = "rp_default:sand",
      node_dungeon = "rp_default:sandstone",

      depth_filler = 8,
      depth_top = 3,
      depth_riverbed = 6,

      y_min = 1,
      y_max = 32000,

      heat_point = 112,
      humidity_point = 32,
})
register_ocean_and_beach("Desert", "rp_default:sand")
default.set_biome_info("Desert", "desertic")

minetest.register_biome(
   {
      name = "Wasteland",

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:sandstone",
      node_riverbed = "rp_default:sandstone",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 32000,

      heat_point = 95,
      humidity_point = 0,
})
register_ocean_and_beach("Wasteland", "rp_default:dry_dirt", 5, "rp_default:gravel")
default.set_biome_info("Wasteland", "drylandic")

minetest.register_biome(
   {
      name = "Rocky Dryland",

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 3,
      y_max = 32000,

      heat_point = 79,
      humidity_point = 1,
})
register_ocean_and_beach("Rocky Dryland", "rp_default:gravel")
default.set_biome_info("Rocky Dryland", "drylandic")

minetest.register_biome(
   {
      name = "Wooded Dryland",

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = 32000,

      heat_point = 78,
      humidity_point = 9,
})
register_ocean_and_beach("Wooded Dryland", "rp_default:dry_dirt")
default.set_biome_info("Wooded Dryland", "drylandic")

minetest.register_biome(
   {
      name = "Savannic Wasteland",

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:sandstone",
      node_riverbed = "rp_default:gravel",

      depth_filler = 2,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 32000,

      heat_point = 94,
      humidity_point = 14,
})
register_ocean_and_beach("Savannic Wasteland", "rp_default:sand")
default.set_biome_info("Savannic Wasteland", "savannic")

minetest.register_biome(
   {
      name = "Thorny Shrubs",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 200,

      heat_point = 76,
      humidity_point = 15,
})
register_ocean_and_beach("Thorny Shrubs", "rp_default:sand")
default.set_biome_info("Thorny Shrubs", "grassy")

minetest.register_biome(
   {
      name = "Mystery Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = 200,

      heat_point = 18,
      humidity_point = 2,
})
register_ocean_and_beach("Mystery Forest", "rp_default:dirt")
default.set_biome_info("Mystery Forest", "grassy")

minetest.register_biome(
   {
      name = "Poplar Plains",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = 32000,

      heat_point = 47,
      humidity_point = 0,
})
register_ocean_and_beach("Poplar Plains", "rp_default:dirt")
default.set_biome_info("Poplar Plains", "grassy")

minetest.register_biome(
   {
      name = "Baby Poplar Plains",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 32000,

      heat_point = 58,
      humidity_point = 9,
})
register_ocean_and_beach("Baby Poplar Plains", "rp_default:sand")
default.set_biome_info("Baby Poplar Plains", "grassy")

minetest.register_biome(
   {
      name = "Tall Birch Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 32000,

      heat_point = 6,
      humidity_point = 14,
})
register_ocean_and_beach("Tall Birch Forest", "rp_default:sand")
default.set_biome_info("Tall Birch Forest", "grassy")

minetest.register_biome(
   {
      name = "Birch Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 32000,

      heat_point = 18,
      humidity_point = 15,
})
register_ocean_and_beach("Birch Forest", "rp_default:sand")
default.set_biome_info("Birch Forest", "grassy")

minetest.register_biome(
   {
      name = "Oak Shrubbery",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 1,
      y_max = 32000,

      heat_point = 37,
      humidity_point = 55,
})
register_ocean_and_beach("Oak Shrubbery", "rp_default:dirt")
default.set_biome_info("Oak Shrubbery", "grassy")

minetest.register_biome(
   {
      name = "Oak Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 5,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 1,
      y_max = 32000,

      heat_point = 22,
      humidity_point = 52,
})
register_ocean_and_beach("Oak Forest", "rp_default:sand")
default.set_biome_info("Oak Forest", "grassy")

minetest.register_biome(
   {
      name = "Tall Oak Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = 32000,

      heat_point = 10,
      humidity_point = 43,
})
register_ocean_and_beach("Tall Oak Forest", "rp_default:sand")
default.set_biome_info("Tall Oak Forest", "grassy")

minetest.register_biome(
   {
      name = "Dense Oak Forest",

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 1,
      y_max = 32000,

      heat_point = 0,
      humidity_point = 43,
})
register_ocean_and_beach("Dense Oak Forest", "rp_default:sand")
default.set_biome_info("Dense Oak Forest", "grassy")

-- Equivalent to Pixture's original 'Swamp' biome
minetest.register_biome(
   {
      name = "Swamp Meadow",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 1,
      y_max = SWAMP_Y_MAX,

      heat_point = 62,
      humidity_point = 93,
})
register_ocean_and_beach("Swamp Meadow", "rp_default:dirt", 5, "rp_default:swamp_dirt")
default.set_biome_info("Swamp Meadow", "swampy")

minetest.register_biome(
   {
      name = "Mixed Swamp",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 1,
      y_max = SWAMP_Y_MAX,

      heat_point = 36,
      humidity_point = 87,
})
register_ocean_and_beach("Mixed Swamp", "rp_default:dirt", 5, "rp_default:swamp_dirt")
default.set_biome_info("Mixed Swamp", "swamp")

minetest.register_biome(
   {
      name = "Swamp Forest",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 5,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 1,
      y_max = SWAMP_Y_MAX,

      heat_point = 12,
      humidity_point = 83,
})
register_ocean_and_beach("Swamp Forest", "rp_default:dirt", 5, "rp_default:swamp_dirt")
default.set_biome_info("Swamp Forest", "swampy")

minetest.register_biome(
   {
      name = "Dry Swamp",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = SWAMP_Y_MAX,

      heat_point = 0,
      humidity_point = 67,
})
register_ocean_and_beach("Dry Swamp", "rp_default:dirt", 5, "rp_default:dirt") -- force creation of beach sub-biome
default.set_biome_info("Dry Swamp", "swampy")

minetest.register_biome(
   {
      name = "Papyrus Swamp",

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 2,
      y_max = SWAMP_Y_MAX,

      heat_point = 49,
      humidity_point = 89,
})
register_ocean_and_beach("Papyrus Swamp", "rp_default:swamp_dirt", 2, "rp_default:sand")
default.set_biome_info("Papyrus Swamp", "swampy")

-- Special Underground biome
minetest.register_biome(
   {
      name = "Underground",

      y_min = -31000,
      y_max = UNDERGROUND_Y_MAX,

      heat_point = 50,
      humidity_point = 50,
})
default.set_biome_info("Underground", "undergroundy")

end

local function spring_ore_np(seed)
	return {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = seed or 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
end

-- Water

minetest.register_ore( -- Springs
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Grassland"},
      clust_scarcity = 26*26*26,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = 20,
      y_max          = 31000,
      noise_params   = spring_ore_np(),
})

minetest.register_ore( -- Pools
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Wilderness"},
      clust_scarcity = 32*32*32,
      clust_num_ores = 20,
      clust_size     = 6,
      y_min          = 10,
      y_max          = 30,
      noise_params   = spring_ore_np(),
})
if mg_name ~= "v6" then
minetest.register_ore( -- Swamp (big springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Papyrus Swamp", "Swamp Forest", "Swamp Meadow"},
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(13943),
})
minetest.register_ore( -- Swamp (medium springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Papyrus Swamp", "Swamp Forest", "Swamp Meadow"},
      clust_scarcity = 5*5*5,
      clust_num_ores = 8,
      clust_size     = 2,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(49494),
})

minetest.register_ore( -- Swamp (small springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Papyrus Swamp", "Swamp Forest", "Swamp Meadow"},
      clust_scarcity = 6*6*6,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(59330),
})

minetest.register_ore( -- Marsh
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      biomes         = {"Marsh"},
      clust_scarcity = 8*8*8,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(),
})

minetest.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:gravel",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Rocky Dryland"},
      clust_scarcity = 8*8*8,
      clust_size     = 8,
      y_min          = -31000,
      y_max          = 31000,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43400,
      },
})
minetest.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:stone",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Rocky Dryland"},
      clust_scarcity = 8*8*8,
      clust_size     = 7,
      y_min          = -31000,
      y_max          = 31000,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 13940,
      },
})

minetest.register_ore( -- Dry Swamp (dirt)
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt_with_grass",
      wherein        = {"rp_default:dirt_with_swamp_grass"},
      biomes         = {"Dry Swamp"},
      clust_scarcity = 3*3*3,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(13943),
})
minetest.register_ore( -- Dry Swamp (dirt)
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt",
      wherein        = {"rp_default:swamp_dirt"},
      biomes         = {"Dry Swamp"},
      clust_scarcity = 3*3*3,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 31000,
      noise_params   = spring_ore_np(13943),
})
minetest.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_default:dirt_with_dry_grass",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Savannic Wasteland"},
      clust_scarcity = 6*6*6,
      clust_size     = 6,
      clust_num_ores = 40,
      y_min          = 2,
      y_max          = 31000,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0.1,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 12449,
      },
})

minetest.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt_with_dry_grass",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Savannic Wasteland"},
      clust_scarcity = 7*7*7,
      clust_size     = 4,
      y_min          = 2,
      y_max          = 31000,
      noise_params = {
	      octaves = 2,
	      scale = 1,
	      offset = 0.2,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 12450,
      },
})

minetest.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_sulfur",
      wherein        = "rp_default:stone",
      biomes         = { "Rocky Dryland", "Wooded Dryland"},
      clust_scarcity = 9*9*9,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = -8,
      y_max          = 32,
})


end


--[[ DECORATIONS ]]
-- The decorations are roughly ordered by size;
-- largest decorations first.

-- Tree decorations

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      name = "rp_default:giga_birch_tree",
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.023,
      biomes = {"Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_giga_birch_tree.mts",
      rotation = "random",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tall_grove_tree.mts",
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.008,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_coniferlike_tree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.015,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_tall.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_layer_birch_2.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00075,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_candlestick.mts",
      y_min = -32000,
      y_max = 32000,
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0003,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_5x4.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x4.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_long.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_plus.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = -32000,
      y_max = 32000,
})



minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Dry Swamp"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_birch_cuboid_3x3_short.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00035,
      biomes = {"Orchard"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_big.mts",
      y_min = 15,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.007,
      biomes = {"Orchard"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = 10,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.000033,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00067,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = -32000,
      y_max = 32000,
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.009,
      biomes = {"Forest", "Deep Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0009,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0045,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0045,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2.mts",
      y_min = 1,
      y_max = 32000,
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.035,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_1.mts",
      y_min = 1,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.035,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree_big_2.mts",
      y_min = 1,
      y_max = 32000,
})



minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.0008,
      biomes = {"Mixed Swamp", "Mixed Swamp Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_oak.mts",
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Swamp Forest", "Swamp Forest Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_oak.mts",
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Swamp Forest", "Swamp Forest Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_birch.mts",
      y_min = 0,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Dry Swamp", "Dry Swamp Beach"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_swamp_birch.mts",
      y_min = 0,
      y_max = 32000,
})



local MYSTERY_FOREST_SPREAD = { x=500, y=500, z=500 }
local MYSTERY_FOREST_OFFSET = 0.001
local MYSTERY_FOREST_OFFSET_STAIRCASE = -0.001
local MYSTERY_FOREST_OFFSET_APPLES = -0.0005
local MYSTERY_FOREST_SCALE = 0.008

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_staircase_tree.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET_STAIRCASE,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_layer_birch.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
              scale = MYSTERY_FOREST_SCALE,
              offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_telephone_tree.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_telephone_tree_apples.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
	      scale = -MYSTERY_FOREST_SCALE,
	      offset = MYSTERY_FOREST_OFFSET_APPLES,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})




minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Mystery Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_cross_birch.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
              scale = MYSTERY_FOREST_SCALE,
              offset = MYSTERY_FOREST_OFFSET,
	      spread = MYSTERY_FOREST_SPREAD,
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 49204,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_large.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
              scale = 0.01,
              offset = -0.004,
	      spread = {x=50,y=50,z=50},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
              scale = 0.01,
              offset = -0.001,
	      spread = {x=50,y=50,z=50},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      fill_ratio = 0.0002,
      sidelen = 16,
      biomes = {"Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = 32000,
})

-- Small poplar tree blobs
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 8,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
              scale = 0.05,
	      offset = -0.032,
	      spread = {x=24,y=24,z=24},
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 94325,
      },
})

-- Occasional lonely poplars
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_poplar_small.mts",
      y_min = 1,
      y_max = 32000,
})


-- Bushes
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.00625,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush_big.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "0",
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Tall Birch Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_birch_bush.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Baby Poplar Plains"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = 0.001,
	      offset = -0.0000001,
	      spread = { x = 50, y = 50, z = 50 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 98421,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = -0.004,
	      offset = 0.002,
	      spread = { x = 82, y = 82, z = 82 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43905,
      },
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "0",
})

-- Wilderness apple trees: 50/50 split between
-- trees with apples and those without.
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree_empty.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Dry Swamp"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_apple_tree.mts",
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = -32000,
      y_max = 32000,
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0225,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0015,
      biomes = {"Tall Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_tree.mts",
      y_min = 1,
      y_max = 32000,
})



end

-- Cactus decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:sand"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Desert"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_cactus.mts",
      y_min = 10,
      y_max = 500,
      rotation = "random",
})

-- Rock decorations

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_rock.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_large_rock.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:stone", "rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_rock.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt", "rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_small_rock.mts",
      y_min = 1,
      y_max = 32000,
      rotation = "random",
})


-- Sulfur decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dry_dirt",
      sidelen = 16,
      fill_ratio = 0.005,
      biomes = {"Wasteland"},
      decoration = {"rp_default:stone_with_sulfur"},
      y_min = 2,
      y_max = 14,
})
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dry_dirt", "rp_default:stone"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      decoration = {"rp_default:stone_with_sulfur"},
      y_min = 2,
      y_max = 14,
})

-- Tiny tree decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_3layer.mts",
      y_min = 3,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_2layer.mts",
      y_min = 3,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0001,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_3layer.mts",
      y_min = 3,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.00025,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_tree_2layer.mts",
      y_min = 3,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.002,
      biomes = {"Rocky Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.003,
      biomes = {"Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_oak.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_tiny_birch.mts",
      y_min = 1,
      y_max = 32000,
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.0002,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_tiny_dry_tree.mts",
      y_min = 3,
      y_max = 32000,
})



-- Bush/shrub decorations

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0075,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.03,
      biomes = {"Dense Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Oak Forest"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_oak_bush_wide.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.005,
      biomes = {"Savanna", "Chaparral"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.0025,
      biomes = {"Savannic Wasteland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dry_dirt"},
      sidelen = 16,
      fill_ratio = 0.001,
      biomes = {"Rocky Dryland", "Wooded Dryland"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush_small.mts",
      y_min = 3,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_dry_grass"},
      sidelen = 16,
      fill_ratio = 0.06,
      biomes = {"Chaparral"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 0,
      y_max = 32000,
      rotation = "0",
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      biomes = {"Thorny Shrubs"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 5,
      y_max = 32000,
      rotation = "0",
      noise_params = {
	      octaves = 1,
	      scale = -0.004,
	      offset = -0.001,
	      spread = { x = 82, y = 82, z = 82 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 493421,
      },
})


minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0003,
      biomes = {"Oak Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_normal_bush_small.mts",
      y_min = 1,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.006,
      biomes = {"Shrubbery"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default")
         .. "/schematics/rp_default_normal_bush_small.mts",
      y_min = 1,
      y_max = 32000,
})



minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.004,
      biomes = {"Grove"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0004,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_dry_bush.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})
minetest.register_decoration(
   {
      deco_type = "schematic",
      place_on = {"rp_default:dirt_with_grass"},
      sidelen = 16,
      fill_ratio = 0.0036,
      biomes = {"Wilderness"},
      flags = "place_center_x, place_center_z",
      schematic = minetest.get_modpath("rp_default") .. "/schematics/rp_default_bush.mts",
      y_min = 3,
      y_max = 32000,
      rotation = "0",
})



-- Thistle decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.024,
      biomes = {"Wilderness"},
      decoration = {"rp_default:thistle"},
      height = 2,
      y_min = -32000,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dirt_with_grass", "rp_default:dry_dirt"},
      sidelen = 4,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:thistle"},
      height = 2,
      y_min = -32000,
      y_max = 32000,
      noise_params = {
	      octaves = 2,
	      scale = 1,
	      offset = -0.5,
	      spread = { x = 12, y = 12, z = 12 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43905,
      },
})
end
-- Papyrus decorations

-- Beach papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:dirt", "rp_default:dirt_with_grass"},
      spawn_by = {"rp_default:water_source", "rp_default:water_flowing"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland Ocean", "Grassland", "Forest Ocean", "Forest", "Wilderness Ocean", "Wilderness", "Birch Forest Ocean", "Tall Birch Forest Ocean", "Marsh Beach"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      y_max = 3,
      y_min = 0,
})

-- Grassland papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:dirt_with_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Grassland", "Marsh", "Forest", "Deep Forest", "Wilderness", "Baby Poplar Plains"},
      decoration = {"rp_default:papyrus"},
      height = 2,
      height_max = 3,
      y_max = 30,
      y_min = 4,
})


-- Swamp papyrus
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:swamp_dirt", "rp_default:dirt_with_swamp_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.30,
      biomes = {"Mixed Swamp"},
      decoration = {"rp_default:papyrus"},
      height = 3,
      height_max = 4,
      y_max = 31000,
      y_min = -100,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:swamp_dirt", "rp_default:dirt_with_swamp_grass"},
      spawn_by = {"group:water"},
      num_spawn_by = 1,
      sidelen = 16,
      fill_ratio = 0.60,
      biomes = {"Papyrus Swamp"},
      decoration = {"rp_default:papyrus"},
      height = 4,
      height_max = 4,
      y_max = 31000,
      y_min = -100,
})

-- Flower decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Grassland", "Wilderness", "Orchard", "Baby Poplar Plains", "Birch Forest"},
      decoration = {"rp_default:flower"},
      y_min = -32000,
      y_max = 32000,
})

-- Grass decorations

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.18,
      biomes = {"Grassland", "Orchard", "Swamp Meadow", "Baby Poplar Plains", "Poplar Plains", "Shrubbery", "Oak Shrubbery", "Thorny Shrubs", "Dry Swamp"},
      decoration = {"rp_default:grass"},
      y_min = 10,
      y_max = 32000,
})
end

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_swamp_grass",
      sidelen = 16,
      fill_ratio = 0.04,
      biomes = {"Mixed Swamp", "Dry Swamp", "Swamp Papyrus", "Swamp Forest"},
      decoration = {"rp_default:swamp_grass"},
      y_min = 1,
      y_max = 31000,
})
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_swamp_grass",
      sidelen = 16,
      fill_ratio = 0.016,
      biomes = {"Swamp Meadow"},
      decoration = {"rp_default:swamp_grass"},
      y_min = 1,
      y_max = 31000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_dry_grass",
      sidelen = 16,
      fill_ratio = 0.07,
      biomes = {"Desert", "Savanna", "Chaparral", "Savannic Wasteland"},
      decoration = {"rp_default:dry_grass"},
      y_min = 10,
      y_max = 500,
})

if mg_name ~= "v6" then
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Forest", "Deep Forest", "Birch Forest", "Tall Birch Forest", "Oak Forest", "Dense Oak Forest", "Tall Oak Forest", "Mystery Forest"},
      decoration = {"rp_default:grass"},
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.08,
      biomes = {"Forest", "Marsh", "Grove", "Shrubbery", "Oak Shrubbery"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.15,
      biomes = {"Deep Forest", "Tall Oak Forest"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.05,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:tall_grass"},
      y_min = 0,
      y_max = 32000,
})
minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.1,
      biomes = {"Thorny Shrubs"},
      decoration = {"rp_default:grass"},
      y_min = 0,
      y_max = 32000,
})

end

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.16,
      biomes = {"Wilderness", "Thorny Shrubs"},
      decoration = {"rp_default:grass"},
      y_min = -32000,
      y_max = 32000,
})

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.12,
      biomes = {"Wilderness", "Thorny Shrubs"},
      decoration = {"rp_default:tall_grass"},
      y_min = -32000,
      y_max = 32000,
})

-- Fern decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = "rp_default:dirt_with_grass",
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Wilderness", "Grove", "Tall Oak Forest", "Mystery Forest"},
      decoration = {"rp_default:fern"},
      y_min = -32000,
      y_max = 32000,
})

-- Clam decorations

minetest.register_decoration(
   {
      deco_type = "simple",
      place_on = {"rp_default:sand", "rp_default:gravel"},
      sidelen = 16,
      fill_ratio = 0.02,
      biomes = {"Grassland Ocean", "Wasteland Beach", "Forest Ocean", "Wilderness Ocean", "Grove Ocean", "Thorny Shrubs Ocean", "Birch Forest Ocean", "Tall Birch Forest Ocean", "Savanna Ocean", "Rocky Dryland Ocean", "Savannic Wasteland Ocean", "Desert Ocean", "Baby Poplar Plains"},
      decoration = {"rp_default:clam"},
      y_min = 0,
      y_max = 1,
})


--[[ ORES ]]

-- Graphite ore

minetest.register_ore( -- Common above sea level mainly
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 9*9*9,
      clust_num_ores = 8,
      clust_size     = 8,
      y_min          = -8,
      y_max          = 32,
})

minetest.register_ore( -- Slight scattering deeper down
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 6,
      clust_size     = 8,
      y_min          = -31000,
      y_max          = -32,
})

-- Coal ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 10*10*10,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = 32,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 8,
      y_min          = -40,
      y_max          = -32,
})

minetest.register_ore( -- Deep ore sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 26,
      clust_size     = 12,
      y_min          = -130,
      y_max          = -120,
})

-- Iron ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 12*12*12,
      clust_num_ores = 4,
      clust_size     = 3,
      y_min          = -31000,
      y_max          = -8,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 20,
      clust_size     = 12,
      y_min          = -32,
      y_max          = -24,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 17,
      clust_size     = 6,
      y_min          = -80,
      y_max          = -60,
})

-- Tin ore

minetest.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 14*14*14,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = -31000,
      y_max          = -100,
})

minetest.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = -150,
      y_max          = -140,
})

-- Copper ore

minetest.register_ore( -- Begin sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 12,
      clust_size     = 5,
      y_min          = -90,
      y_max          = -80,
})

minetest.register_ore( -- Rare even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 10,
      clust_size     = 5,
      y_min          = -31000,
      y_max          = -90,
})

minetest.register_ore( -- Large clusters
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 22,
      clust_size     = 10,
      y_min          = -230,
      y_max          = -180,
})

-- Small gravel blobs
minetest.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:gravel",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = -31000,
	y_max          = 31000,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 58943,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})

-- Small sand blobs
minetest.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:sand",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 40,
	clust_size     = 4,
	y_min          = -31000,
	y_max          = 31000,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 38943,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})


-- Dirt, Dry Dirt and Swamp Dirt blobs.
-- These get generated depending on the biome.
-- The following code is to generate the list
-- of biomes that include either dirt, dry dirt or swamp dirt.

-- Returns a list of biomes that use the specified nodename
-- as its dirt blob, by using the data from
-- default.get_biome_info.
-- * nodename: A name of the node (a dirt node)
local get_dirt_biomes = function(nodename)
	local biomes = default.get_core_biomes()
	local out_biomes = {}
	for b=1, #biomes do
		local biome_info = default.get_biome_info(biomes[b])
		-- Add biome to list iff it uses the specified node as dirt blob
		if biome_info.dirt_blob ~= nil and biome_info.dirt_blob == nodename then
			table.insert(out_biomes, biomes[b])
		end
	end
	return out_biomes
end

local dirt_biomes = get_dirt_biomes("rp_default:dirt")
local dry_dirt_biomes = get_dirt_biomes("rp_default:dry_dirt")
local swamp_dirt_biomes = get_dirt_biomes("rp_default:swamp_dirt")

minetest.log("verbose", "[rp_default] List of builtin biomes with Dirt blobs: "..dump(dirt_biomes))
minetest.log("verbose", "[rp_default] List of builtin biomes with Dry Dirt blobs: "..dump(dry_dirt_biomes))
minetest.log("verbose", "[rp_default] List of builtin biomes with Swamp Dirt blobs: "..dump(swamp_dirt_biomes))

local np_dirtlike = {
	offset  = 0,
	scale   = 1,
	spread  = {x=150, y=150, z=150},
	seed    = 98943,
	octaves = 3,
	persist = 0.5,
	lacunarity = 2,
	flags = "defaults",
}

minetest.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = -31000,
	y_max          = 31000,
	biomes         = dirt_biomes,
	noise_params   = np_dirtlike,
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:dry_dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = -31000,
	y_max          = 31000,
	biomes         = dry_dirt_biomes,
	noise_params   = np_dirtlike,
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:swamp_dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = -31000,
	y_max          = 31000,
	biomes         = swamp_dirt_biomes,
	noise_params   = np_dirtlike,
})

