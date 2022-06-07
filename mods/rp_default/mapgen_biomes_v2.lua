--
-- Mapgen
--

local S = minetest.get_translator("rp_default")

--[[ BIOMES ]]

minetest.clear_registered_biomes()

local mg_name = minetest.get_mapgen_setting("mg_name")

local register_underwater_and_beach = function(biomename, node_underwater, beach_depth, node_beach)
	local orig_biome = minetest.registered_biomes[biomename]
	if not orig_biome then
		return
	end
	local newdef = table.copy(orig_biome)
	local orig_description = orig_biome._description or biomename
	newdef.name = biomename .. " Underwater"
	newdef._description = S("@1 Underwater", orig_description)
	newdef.node_top = node_underwater or "rp_default:sand"
	newdef.node_filler = newdef.node_top
	newdef.y_min = default.UNDERGROUND_Y_MAX + 1

	if beach_depth and beach_depth > 0 then
		newdef.y_max = orig_biome.y_min - beach_depth - 1
	else
		newdef.y_max = orig_biome.y_min - 1
	end
	minetest.register_biome(newdef)

	if beach_depth and beach_depth > 0 then

		local newdef2 = table.copy(orig_biome)
		newdef2.name = biomename .. " Beach"
		newdef2._description = S("@1 Beach", orig_description)
		newdef2.node_top = node_beach or "rp_default:sand"
		newdef2.node_filler = newdef2.node_top
		newdef2.y_min = orig_biome.y_min - beach_depth
		newdef2.y_max = orig_biome.y_min - 1
		minetest.register_biome(newdef2)
	end
end

if mg_name ~= "v6" then

-- 'lowland' version of Dense Grassland biome
minetest.register_biome(
{
      name = "Marsh",
      _description = S("Marsh"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:dirt",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 2,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 81,
      humidity_point = 80,
})
register_underwater_and_beach("Marsh", "rp_default:dirt", 2, "rp_default:sand")
default.set_biome_info("Marsh", "grassy")

-- 'highland' version of Marsh biome
minetest.register_biome(
{
      name = "Dense Grassland",
      _description = S("Dense Grassland"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:dirt",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = default.SWAMP_Y_MAX + 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 81,
      humidity_point = 80,
})
default.set_biome_info("Dense Grassland", "grassy")


-- This special biome has the giant birch trees and is
-- limited to a very specific height.
-- It has no equivalent biome above or below.
minetest.register_biome(
   {
      name = "Deep Forest",
      _description = S("Giga Birch Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 30,
      y_max = 40,

      heat_point = 29,
      humidity_point = 34,
})
default.set_biome_info("Deep Forest", "grassy")

minetest.register_biome(
   {
      name = "Forest",
      _description = S("Mixed Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 200,

      heat_point = 29,
      humidity_point = 36,
})
register_underwater_and_beach("Forest", "rp_default:sand")
default.set_biome_info("Forest", "grassy")

minetest.register_biome(
   {
      name = "Grove",
      _description = S("Grove"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 35,
      humidity_point = 19,
})
register_underwater_and_beach("Grove", "rp_default:sand")
default.set_biome_info("Grove", "grassy")

minetest.register_biome(
   {
      name = "Wilderness",
      _description = S("Wilderness"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 55,
      humidity_point = 24,
})
register_underwater_and_beach("Wilderness", "rp_default:sand")
default.set_biome_info("Wilderness", "grassy")

-- Note: Grassland is below Orchard
minetest.register_biome(
   {
      name = "Grassland",
      _description = S("Grassland"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 3,
      y_max = default.ORCHARD_Y_MIN - 1,

      heat_point = 55,
      humidity_point = 56,
})
register_underwater_and_beach("Grassland", "rp_default:sand")
default.set_biome_info("Grassland", "grassy")

-- Note: Orchard is the 'highland' version of Grassland
minetest.register_biome(
   {
      name = "Orchard",
      _description = S("Orchard"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = default.ORCHARD_Y_MIN,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 55,
      humidity_point = 56,
})
default.set_biome_info("Orchard", "grassy")

-- Note: Shrubbery is below Chaparral
minetest.register_biome(
   {
      name = "Shrubbery",
      _description = S("Shrubbery"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 55,

      heat_point = 76,
      humidity_point = 50,
})
register_underwater_and_beach("Shrubbery", "rp_default:sand")
default.set_biome_info("Shrubbery", "grassy")

-- Note: High biome. This is the highland version of Shrubbery
minetest.register_biome(
   {
      name = "Chaparral",
      _description = S("Chaparral"),

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 56,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 76,
      humidity_point = 50,
})
default.set_biome_info("Chaparral", "savannic")

minetest.register_biome(
   {
      name = "Savanna",
      _description = S("Savanna"),

      node_top = "rp_default:dirt_with_dry_grass",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 2,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 2,
      y_max = 55,

      heat_point = 77,
      humidity_point = 12,
})
register_underwater_and_beach("Savanna", "rp_default:sand")
default.set_biome_info("Savanna", "savannic")

minetest.register_biome(
   {
      name = "Wasteland",
      _description = S("Wasteland"),

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:sandstone",
      node_riverbed = "rp_default:sandstone",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 100,
      humidity_point = 0,
})
register_underwater_and_beach("Wasteland", "rp_default:dry_dirt", 5, "rp_default:gravel")
default.set_biome_info("Wasteland", "drylandic")

minetest.register_biome(
   {
      name = "Rocky Dryland",
      _description = S("Rocky Dryland"),

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 0,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 3,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 86,
      humidity_point = 7,
})
register_underwater_and_beach("Rocky Dryland", "rp_default:gravel")
default.set_biome_info("Rocky Dryland", "drylandic")

minetest.register_biome(
   {
      name = "Wooded Dryland",
      _description = S("Wooded Dryland"),

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:dry_dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 94,
      humidity_point = 10,
})
register_underwater_and_beach("Wooded Dryland", "rp_default:dry_dirt")
default.set_biome_info("Wooded Dryland", "drylandic")

minetest.register_biome(
   {
      name = "Savannic Wasteland",
      _description = S("Savannic Wasteland"),

      node_top = "rp_default:dry_dirt",
      node_filler = "rp_default:sandstone",
      node_riverbed = "rp_default:gravel",

      depth_filler = 2,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 80,
      humidity_point = 10,
})
register_underwater_and_beach("Savannic Wasteland", "rp_default:sand")
default.set_biome_info("Savannic Wasteland", "savannic")

minetest.register_biome(
   {
      name = "Thorny Shrubs",
      _description = S("Thorny Shrubs"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = 200,

      heat_point = 54,
      humidity_point = 0,
})
register_underwater_and_beach("Thorny Shrubs", "rp_default:sand")
default.set_biome_info("Thorny Shrubs", "grassy")

minetest.register_biome(
   {
      name = "Mystery Forest",
      _description = S("Mystery Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = 200,

      heat_point = 15,
      humidity_point = 0,
})
register_underwater_and_beach("Mystery Forest", "rp_default:dirt")
default.set_biome_info("Mystery Forest", "grassy")

minetest.register_biome(
   {
      name = "Poplar Plains",
      _description = S("Poplar Plains"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 100,
      humidity_point = 56,
})
register_underwater_and_beach("Poplar Plains", "rp_default:dirt")
default.set_biome_info("Poplar Plains", "grassy")

minetest.register_biome(
   {
      name = "Baby Poplar Plains",
      _description = S("Baby Poplar Plains"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 100,
      humidity_point = 42,
})
register_underwater_and_beach("Baby Poplar Plains", "rp_default:sand")
default.set_biome_info("Baby Poplar Plains", "grassy")

minetest.register_biome(
   {
      name = "Tall Birch Forest",
      _description = S("Tall Birch Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 0,
      humidity_point = 15,
})
register_underwater_and_beach("Tall Birch Forest", "rp_default:sand")
default.set_biome_info("Tall Birch Forest", "grassy")

minetest.register_biome(
   {
      name = "Birch Forest",
      _description = S("Birch Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:sand",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 2,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 14,
      humidity_point = 16,
})
register_underwater_and_beach("Birch Forest", "rp_default:sand")
default.set_biome_info("Birch Forest", "grassy")

minetest.register_biome(
   {
      name = "Oak Shrubbery",
      _description = S("Oak Shrubbery"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 3,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 33,
      humidity_point = 62,
})
register_underwater_and_beach("Oak Shrubbery", "rp_default:dirt")
default.set_biome_info("Oak Shrubbery", "grassy")

minetest.register_biome(
   {
      name = "Oak Forest",
      _description = S("Oak Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 5,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 32,
      humidity_point = 61,
})
register_underwater_and_beach("Oak Forest", "rp_default:sand")
default.set_biome_info("Oak Forest", "grassy")

minetest.register_biome(
   {
      name = "Tall Oak Forest",
      _description = S("Tall Oak Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 10,
      humidity_point = 52,
})
register_underwater_and_beach("Tall Oak Forest", "rp_default:sand")
default.set_biome_info("Tall Oak Forest", "grassy")

minetest.register_biome(
   {
      name = "Dense Oak Forest",
      _description = S("Dense Oak Forest"),

      node_top = "rp_default:dirt_with_grass",
      node_filler = "rp_default:dirt",
      node_riverbed = "rp_default:gravel",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 30,
      y_max = default.GLOBAL_Y_MAX,

      heat_point = 0,
      humidity_point = 52,
})
default.set_biome_info("Dense Oak Forest", "grassy")

-- Equivalent to Pixture's original 'Swamp' biome
minetest.register_biome(
   {
      name = "Swamp Meadow",
      _description = S("Swamp Meadow"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 2,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 54,
      humidity_point = 97,
})
register_underwater_and_beach("Swamp Meadow", "rp_default:swamp_dirt", 3, "rp_default:sand")
default.set_biome_info("Swamp Meadow", "swampy")

minetest.register_biome(
   {
      name = "Swamp Meadow Highland",
      _description = S("Swamp Meadow Highland"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = default.SWAMP_Y_MAX+1,
      y_max = default.SWAMP_HIGH_Y_MAX,

      heat_point = 54,
      humidity_point = 133,
})
default.set_biome_info("Swamp Meadow Highland", "swampy")

minetest.register_biome(
   {
      name = "Mixed Swamp",
      _description = S("Mixed Swamp"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 7,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 1,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 32,
      humidity_point = 92,
})
register_underwater_and_beach("Mixed Swamp", "rp_default:dirt", 5, "rp_default:swamp_dirt")
default.set_biome_info("Mixed Swamp", "swampy")

minetest.register_biome(
   {
      name = "Mixed Swamp Highland",
      _description = S("Mixed Swamp Highland"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = default.SWAMP_Y_MAX + 1,
      y_max = default.SWAMP_HIGH_Y_MAX,

      heat_point = 32,
      humidity_point = 133,
})
default.set_biome_info("Mixed Swamp Highland", "swampy")

minetest.register_biome(
   {
      name = "Swamp Forest",
      _description = S("Swamp Forest"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 5,
      depth_top = 1,
      depth_riverbed = 4,

      y_min = 1,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 11,
      humidity_point = 91,
})
register_underwater_and_beach("Swamp Forest", "rp_default:dirt", 5, "rp_default:swamp_dirt")
default.set_biome_info("Swamp Forest", "swampy")

minetest.register_biome(
   {
      name = "Swamp Forest Highland",
      _description = S("Swamp Forest Highland"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = default.SWAMP_Y_MAX + 1,
      y_max = default.SWAMP_HIGH_Y_MAX,

      heat_point = 11,
      humidity_point = 133,
})
default.set_biome_info("Swamp Forest Highland", "swampy")


minetest.register_biome(
   {
      name = "Dry Swamp",
      _description = S("Dry Swamp"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 6,
      depth_top = 1,
      depth_riverbed = 2,

      y_min = 1,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 83,
      humidity_point = 84,
})
register_underwater_and_beach("Dry Swamp", "rp_default:dirt", 3, "rp_default:swamp_dirt") -- force creation of beach sub-biome
default.set_biome_info("Dry Swamp", "swampy")

minetest.register_biome(
   {
      name = "Dry Swamp Highland",
      _description = S("Dry Swamp Highland"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 5,
      depth_top = 1,
      depth_riverbed = 1,

      y_min = default.SWAMP_Y_MAX + 1,
      y_max = default.SWAMP_HIGH_Y_MAX,

      heat_point = 83,
      humidity_point = 129,
})
default.set_biome_info("Dry Swamp Highland", "swampy")

minetest.register_biome(
   {
      name = "Papyrus Swamp",
      _description = S("Papyrus Swamp"),

      node_top = "rp_default:dirt_with_swamp_grass",
      node_filler = "rp_default:swamp_dirt",
      node_cave_liquid = "rp_default:swamp_water_source",
      node_riverbed = "rp_default:swamp_dirt",

      depth_filler = 4,
      depth_top = 1,
      depth_riverbed = 3,

      y_min = 1,
      y_max = default.SWAMP_Y_MAX,

      heat_point = 44,
      humidity_point = 98,
})
register_underwater_and_beach("Papyrus Swamp", "rp_default:swamp_dirt")
default.set_biome_info("Papyrus Swamp", "swampy")

-- Special Underground biome
minetest.register_biome(
   {
      name = "Underground",
      _description = S("Underground"),

      y_min = default.GLOBAL_Y_MIN,
      y_max = default.UNDERGROUND_Y_MAX,

      heat_point = 50,
      humidity_point = 50,
})
default.set_biome_info("Underground", "undergroundy")

end
