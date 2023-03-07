--
-- Partial blocks node registrations
--
local S = minetest.get_translator("rp_partialblocks")

local pbp = "partialblocks_" -- partial blocks texture prefix for advanced textures

-- Stonelike materials

partialblocks.register_material(
   "cobble", S("Cobble Slab"), S("Cobble Stair"), "rp_default:cobble", {cracky=3}, false, nil, "w")

partialblocks.register_material(
   "stone", S("Stone Slab"), S("Stone Stair"), "rp_default:stone", {cracky=2}, false, nil, "w")

partialblocks.register_material(
   "sandstone", S("Sandstone Slab"), S("Sandstone Stair"), "rp_default:sandstone", {cracky=3}, false, nil, "w")

partialblocks.register_material(
   "brick", S("Brick Slab"), S("Brick Stair"), "rp_default:brick", {cracky=2}, false, nil, "w")

-- Woodlike

partialblocks.register_material(
   "wood", S("Wooden Slab"), S("Wooden Stair"), "rp_default:planks", {choppy = 3, oddly_breakable_by_hand = 3}, true, nil, "w")

partialblocks.register_material(
   "oak", S("Oak Slab"), S("Oak Stair"), "rp_default:planks_oak", {choppy = 3, oddly_breakable_by_hand = 3}, true, nil, "w")

partialblocks.register_material(
   "birch", S("Birch Slab"), S("Birch Stair"), "rp_default:planks_birch", {choppy = 3, oddly_breakable_by_hand = 3}, true, nil, "w")

-- Reed

partialblocks.register_material(
   "reed", S("Reed Slab"), S("Reed Stair"), "rp_default:reed_block", {snappy = 2, fall_damage_add_percent=-10}, true, nil, "w")

partialblocks.register_material(
   "dried_reed", S("Dried Reed Slab"), S("Dried Reed Stair"), "rp_default:dried_reed_block", {snappy = 2, fall_damage_add_percent=-15}, true, nil, "w")

partialblocks.register_material(
   "straw", S("Straw Slab"), S("Straw Stair"), "rp_farming:straw", {snappy = 3, fall_damage_add_percent=-15}, true, nil, "w")

partialblocks.register_material(
   "hay", S("Hay Slab"), S("Hay Stair"), "rp_default:hay", {snappy = 3, fall_damage_add_percent=-30}, true, nil, "w")

-- Frames

partialblocks.register_material(
   "frame", S("Frame Slab"), S("Frame Stair"), "rp_default:frame", {choppy = 2, oddly_breakable_by_hand = 1}, true, "a|"..pbp.."frame", "a|"..pbp.."frame")

-- The reinforced partialblocks have their level forced to 0, so are as hard to dig as the basenode. They're reinforced, after all.
partialblocks.register_material(
   "reinforced_frame", S("Reinforced Frame Slab"), S("Reinforced Frame Stair"), "rp_default:reinforced_frame", {choppy = 1, level = 0}, true, "a|"..pbp.."reinforced_frame", "a|"..pbp.."reinforced_frame")

partialblocks.register_material(
   "reinforced_cobble", S("Reinforced Cobble Slab"), S("Reinforced Cobble Stair"), "rp_default:reinforced_cobble", {cracky = 1, level = 0}, false, "a|"..pbp.."reinforced_cobbles", "a|"..pbp.."reinforced_cobbles")

-- Coal

partialblocks.register_material(
   "coal", S("Coal Slab"), S("Coal Stair"), "rp_default:block_coal", { cracky = 3 }, true, "a|"..pbp.."block_coal", "a|"..pbp.."block_coal")

-- Metal

partialblocks.register_material(
   "steel", S("Steel Slab"), S("Steel Stair"), "rp_default:block_steel", { cracky = 2 }, false, "a|"..pbp.."block_steel", "a|"..pbp.."block_steel")

partialblocks.register_material(
   "carbon_steel", S("Carbon Steel Slab"), S("Carbon Steel Stair"), "rp_default:block_carbon_steel", { cracky = 1 }, false, "a|"..pbp.."block_carbon_steel", "a|"..pbp.."block_carbon_steel")

partialblocks.register_material(
   "wrought_iron", S("Wrought Iron Slab"), S("Wrought Iron Stair"), "rp_default:block_wrought_iron", { cracky = 2, magnetic = 1 }, false, "a|"..pbp.."block_wrought_iron", "a|"..pbp.."block_wrought_iron")

partialblocks.register_material(
   "bronze", S("Bronze Slab"), S("Bronze Stair"), "rp_default:block_bronze", { cracky = 1 }, false, "a|"..pbp.."block_bronze", "a|"..pbp.."block_bronze")

partialblocks.register_material(
   "copper", S("Copper Slab"), S("Copper Stair"), "rp_default:block_copper", { cracky = 2 }, false, "a|"..pbp.."block_copper", "a|"..pbp.."block_copper")

partialblocks.register_material(
   "tin", S("Tin Slab"), S("Tin Stair"), "rp_default:block_tin", { cracky = 2 }, false, "a|"..pbp.."block_tin", "a|"..pbp.."block_tin")

partialblocks.register_material(
   "gold", S("Gold Slab"), S("Gold Stair"), "rp_gold:block_gold", { cracky = 2 }, false, "a|"..pbp.."block_gold", "a|"..pbp.."block_gold")

-- Compressed sandstone
local cs_stair_tiles = {
	"default_compressed_sandstone.png",
	"default_compressed_sandstone_top.png",
	"partialblocks_compressed_sandstone_stair.png^[transformFX",
	"partialblocks_compressed_sandstone_stair.png",
	"default_compressed_sandstone.png",
	"default_compressed_sandstone.png" }
partialblocks.register_material(
   "compressed_sandstone", S("Compressed Sandstone Slab"), S("Compressed Sandstone Stair"), "rp_default:compressed_sandstone", { cracky = 2 }, false, nil, cs_stair_tiles)

partialblocks.register_material(
   "reinforced_compressed_sandstone", S("Reinforced Compressed Sandstone Slab"), S("Reinforced Compressed Sandstone Stair"), "rp_default:reinforced_compressed_sandstone", { cracky = 2 }, false, "a|"..pbp.."reinforced_compressed_sandstone", "a|"..pbp.."reinforced_compressed_sandstone")
