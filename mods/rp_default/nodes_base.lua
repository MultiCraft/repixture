
--
-- Node definitions of simple, non-interactive nodes
--

local S = minetest.get_translator("rp_default")

-- Ores

minetest.register_node(
   "rp_default:stone_with_sulfur",
   {
      description = S("Stone with Sulfur"),
      tiles = {"default_stone.png^default_mineral_sulfur.png"},
      groups = {cracky = 2, stone = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_sulfur",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_graphite",
   {
      description = S("Stone with Graphite"),
      tiles = {"default_stone.png^default_mineral_graphite.png"},
      groups = {cracky = 2, stone = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:sheet_graphite",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_coal",
   {
      description = S("Stone with Coal"),
      tiles = {"default_stone.png^default_mineral_coal.png"},
      groups = {cracky = 2, stone = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_coal",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_iron",
   {
      description = S("Stone with Iron"),
      tiles = {"default_stone.png^default_mineral_iron.png"},
      groups = {cracky = 2, stone = 1, magnetic = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_iron",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_tin",
   {
      description = S("Stone with Tin"),
      tiles = {"default_stone.png^default_mineral_tin.png"},
      groups = {cracky = 1, stone = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_tin",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_copper",
   {
      description = S("Stone with Copper"),
      tiles = {"default_stone.png^default_mineral_copper.png"},
      groups = {cracky = 1, stone = 1, ore = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_copper",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

-- Stonelike

minetest.register_node(
   "rp_default:stone",
   {
      description = S("Stone"),
      tiles = {"default_stone.png"},
      groups = {cracky = 2, stone = 1},
      drop = "rp_default:cobble",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:cobble",
   {
      description = S("Cobble"),
      tiles = {"default_cobbles.png"},
      stack_max = 240,
      groups = {cracky = 3, stone = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:reinforced_cobble",
   {
      description = S("Reinforced Cobble"),
      tiles = {"default_reinforced_cobbles.png"},
      is_ground_content = false,
      groups = {cracky = 1, stone = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:gravel",
   {
      description = S("Gravel"),
      tiles = {"default_gravel.png"},
      groups = {crumbly = 2, falling_node = 1, gravel = 1},
      sounds = rp_sounds.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_crunch_footstep", gain = 0.45},
      }),
})

-- Material blocks

minetest.register_node(
   "rp_default:block_coal",
   {
      description = S("Coal Block"),
      tiles = {"default_block_coal.png"},
      groups = {cracky = 3},
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:block_wrought_iron",
   {
      description = S("Wrought Iron Block"),
      tiles = {"default_block_wrought_iron.png"},
      groups = {cracky = 2, magnetic = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:block_steel",
   {
      description = S("Steel Block"),
      tiles = {"default_block_steel.png"},
      groups = {cracky = 2},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:block_carbon_steel",
   {
      description = S("Carbon Steel Block"),
      tiles = {"default_block_carbon_steel.png"},
      groups = {cracky = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:block_bronze",
   {
      description = S("Bronze Block"),
      tiles = {"default_block_bronze.png"},
      groups = {cracky = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:block_copper",
   {
      description = S("Copper Block"),
      tiles = {"default_block_copper.png"},
      groups = {cracky = 2},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "rp_default:block_tin",
   {
      description = S("Tin Block"),
      tiles = {"default_block_tin.png"},
      groups = {cracky = 2},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
})

-- Soil

minetest.register_node(
   "rp_default:dirt",
   {
      description = S("Dirt"),
      tiles = {"default_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, fall_damage_add_percent = -5},
      sounds = rp_sounds.node_sound_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_dirt",
})

minetest.register_node(
   "rp_default:dry_dirt",
   {
      description = S("Dry Dirt"),
      tiles = { "default_dry_dirt.png" },
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, dry_dirt = 1, plantable_dry = 1, fall_damage_add_percent = -10},
      sounds = rp_sounds.node_sound_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_dry_dirt",
})

minetest.register_node(
   "rp_default:swamp_dirt",
   {
      description = S("Swamp Dirt"),
      tiles = { "default_swamp_dirt.png" },
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, swamp_dirt = 1, plantable_wet = 1, fall_damage_add_percent = -10},
      sounds = rp_sounds.node_sound_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_swamp_dirt",
})

minetest.register_node(
   "rp_default:dirt_with_dry_grass",
   {
      description = S("Dirt with Dry Grass"),
      tiles = {
	 { name = "rp_default_dry_grass_4x4.png", align_style = "world", scale = 4 },
	 "default_dirt.png",
         "default_dirt.png^default_dry_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1,
                fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:dirt"}, rarity = 1},
	    {items = {"rp_default:dry_grass 4"}, rarity = 12},
	    {items = {"rp_default:dry_grass 2"}, rarity = 6},
	    {items = {"rp_default:dry_grass 1"}, rarity = 2},
	 }
      },
      sounds = rp_sounds.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.3},
      }),
      _fertilized_node = "rp_default:fertilized_dirt",
})

minetest.register_node(
   "rp_default:dirt_with_swamp_grass",
   {
      description = S("Swamp Dirt with Swamp Grass"),
      tiles = {
	 { name = "rp_default_swamp_grass_4x4.png", align_style = "world", scale = 4 },
	 "default_swamp_dirt.png",
         "default_swamp_dirt.png^default_swamp_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, swamp_dirt = 1, plantable_wet = 1, grass_cover = 1,
                fall_damage_add_percent = -10, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:swamp_dirt"}, rarity = 1},
	    {items = {"rp_default:swamp_grass 6"}, rarity = 14},
	    {items = {"rp_default:swamp_grass 3"}, rarity = 7},
	    {items = {"rp_default:swamp_grass 2"}, rarity = 3},
	 }
      },
      sounds = rp_sounds.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.5},
      }),
      _fertilized_node = "rp_default:fertilized_swamp_dirt",
})

minetest.register_node(
   "rp_default:dirt_with_grass",
   {
      description = S("Dirt with Grass"),
      tiles = {
	 { name = "rp_default_grass_4x4.png", align_style = "world", scale = 4 },
	 "default_dirt.png",
	 "default_dirt.png^default_grass_side.png",
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1,
                fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:dirt"}, rarity = 1},
	    {items = {"rp_default:grass 10"}, rarity = 30},
	    {items = {"rp_default:grass 3"}, rarity = 9},
	    {items = {"rp_default:grass 2"}, rarity = 6},
	    {items = {"rp_default:grass 1"}, rarity = 3},
	 }
      },
      sounds = rp_sounds.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.4},
      }),
      _fertilized_node = "rp_default:fertilized_dirt",
})

-- Paths

minetest.register_node(
   "rp_default:dirt_path",
   {
      description = S("Dirt Path"),
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5-2/16, 0.5}
      },
      tiles = { "default_dirt.png" },
      groups = {crumbly = 3, path = 1, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:path_slab",
   {
      description = S("Dirt Path Slab"),
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -2/16, 0.5}
      },
      tiles = { "default_dirt.png" },
      groups = {crumbly = 3, path = 2, slab = 2, creative_decoblock = 1, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_dirt_defaults(),
      on_place = function(itemstack, placer, pointed_thing)
         -- Path slab on path slab placement creates full dirt path block
         if not (pointed_thing.above.y > pointed_thing.under.y) then
            itemstack = minetest.item_place(itemstack, placer, pointed_thing)
            return itemstack
         end
         local pos = pointed_thing.under
         local shift = false
         if placer:is_player() then
            -- Place node normally when sneak is pressed
            shift = placer:get_player_control().sneak
         end
         if (not shift) and minetest.get_node(pos).name == itemstack:get_name()
         and itemstack:get_count() >= 1 then
            minetest.set_node(pos, {name = "rp_default:dirt_path"})

            if not minetest.is_creative_enabled(placer:get_player_name()) then
                itemstack:take_item()
            end

         else
            itemstack = minetest.item_place(itemstack, placer, pointed_thing)
         end
         return itemstack
      end,
})

minetest.register_node(
   "rp_default:heated_dirt_path",
   {
      description = S("Glowing Dirt Path"),
      drawtype = "nodebox",
      paramtype = "light",
      light_source = 6,
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5-2/16, 0.5}
      },
      tiles = { "default_dirt.png" },
      groups = {crumbly = 3, path = 1, creative_decoblock = 1, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

-- Brick

minetest.register_node(
   "rp_default:brick",
   {
      description = S("Brick Block"),
      tiles = {"default_brick.png"},
      is_ground_content = false,
      groups = {cracky = 2},
      sounds = rp_sounds.node_sound_stone_defaults(),
})

-- Sand

minetest.register_node(
   "rp_default:sand",
   {
      description = S("Sand"),
      tiles = {"default_sand.png"},
      groups = {crumbly = 3, falling_node = 1, sand = 1, plantable_sandy = 1, fall_damage_add_percent = -10},
      sounds = rp_sounds.node_sound_sand_defaults(),
      _fertilized_node = "rp_default:fertilized_sand",
})

minetest.register_node(
   "rp_default:sandstone",
   {
      description = S("Sandstone"),
      tiles = {"default_sandstone.png"},
      groups = {crumbly = 2, cracky = 3, sandstone = 1},
      drop = "rp_default:sand 2",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:compressed_sandstone",
   {
      description = S("Compressed Sandstone"),
      tiles = {"default_compressed_sandstone_top.png", "default_compressed_sandstone_top.png", "default_compressed_sandstone.png"},
      groups = {cracky = 2, sandstone = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:reinforced_compressed_sandstone",
   {
      description = S("Reinforced Compressed Sandstone"),
      tiles = {"rp_default_reinforced_compressed_sandstone.png"},
      groups = {cracky = 2, sandstone = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults(),
})

-- Glass

minetest.register_node(
   "rp_default:glass",
   {
      description = S("Glass"),
      drawtype = "glasslike_framed_optional",
      tiles = {"default_glass_frame.png", "default_glass.png"},
      paramtype = "light",
      sunlight_propagates = true,
      groups = {snappy = 2,cracky = 3,oddly_breakable_by_hand = 2, glass=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_glass_defaults(),
})


-- Planks

minetest.register_node(
   "rp_default:planks",
   {
      description = S("Wooden Planks"),
      tiles = {"default_wood.png"},
      groups = {planks = 1, wood = 1, snappy = 3, choppy = 3, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

minetest.register_node(
   "rp_default:planks_oak",
   {
      description = S("Oak Planks"),
      tiles = {"default_wood_oak.png"},
      groups = {planks = 1, wood = 1, snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

minetest.register_node(
   "rp_default:planks_birch",
   {
      description = S("Birch Planks"),
      tiles = {"default_wood_birch.png"},
      groups = {planks = 1, wood = 1, snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

-- Frames

minetest.register_node(
   "rp_default:frame",
   {
      description = S("Frame"),
      tiles = {"default_frame.png"},
      groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

minetest.register_node(
   "rp_default:reinforced_frame",
   {
      description = S("Reinforced Frame"),
      tiles = {"default_reinforced_frame.png"},
      groups = {wood = 1, choppy = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
})

-- Reed
minetest.register_node(
   "rp_default:reed_block",
   {
      description = S("Reed Block"),
      tiles = {
	     "rp_default_reed_block_top.png",
	     "rp_default_reed_block_top.png",
	     "rp_default_reed_block_side.png",
      },
      groups = {snappy=2, fall_damage_add_percent=-10},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
})
minetest.register_node(
   "rp_default:dried_reed_block",
   {
      description = S("Dried Reed Block"),
      tiles = {
	     "rp_default_dried_reed_block_top.png",
	     "rp_default_dried_reed_block_top.png",
	     "rp_default_dried_reed_block_side.png",
      },
      groups = {snappy=2, fall_damage_add_percent=-15},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Hay
minetest.register_node(
   "rp_default:hay",
   {
      description = S("Hay"),
      tiles = {
	     "rp_default_hay.png",
      },
      groups = {snappy=3, fall_damage_add_percent=-30},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Rope

minetest.register_node(
   "rp_default:rope",
   {
      description = S("Rope"),
      drawtype = "nodebox",
      tiles = {"default_rope.png"},
      inventory_image = "default_rope_inventory.png",
      wield_image = "default_rope_inventory.png",
      paramtype = "light",
      walkable = false,
      climbable = true,
      sunlight_propagates = true,
      node_box = {
	 type = "fixed",
	 fixed = {-1/16, -0.5, -1/16, 1/16, 0.5, 1/16},
      },
      groups = {snappy = 3, creative_decoblock = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_down(pos, node, digger)
      end,
})

