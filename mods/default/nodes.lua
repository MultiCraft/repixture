
--
-- Node definitions of simple, non-interactive nodes
--

local S = minetest.get_translator("default")

-- Ores

minetest.register_node(
   "default:stone_with_sulfur",
   {
      description = S("Stone with Sulfur"),
      tiles = {"default_stone.png^default_mineral_sulfur.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "default:lump_sulfur",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:stone_with_graphite",
   {
      description = S("Stone with Graphite"),
      tiles = {"default_stone.png^default_mineral_graphite.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "default:sheet_graphite",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:stone_with_coal",
   {
      description = S("Stone with Coal"),
      tiles = {"default_stone.png^default_mineral_coal.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "default:lump_coal",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:stone_with_iron",
   {
      description = S("Stone with Iron"),
      tiles = {"default_stone.png^default_mineral_iron.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "default:lump_iron",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:stone_with_tin",
   {
      description = S("Stone with Tin"),
      tiles = {"default_stone.png^default_mineral_tin.png"},
      groups = {cracky = 1, stone = 1, not_in_craft_guide = 1},
      drop = "default:lump_tin",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:stone_with_copper",
   {
      description = S("Stone with Copper"),
      tiles = {"default_stone.png^default_mineral_copper.png"},
      groups = {cracky = 1, stone = 1, not_in_craft_guide = 1},
      drop = "default:lump_copper",
      sounds = default.node_sound_stone_defaults(),
})

-- Stonelike

minetest.register_node(
   "default:stone",
   {
      description = S("Stone"),
      tiles = {"default_stone.png"},
      groups = {cracky = 2, stone = 1},
      drop = "default:cobble",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:cobble",
   {
      description = S("Cobble"),
      tiles = {"default_cobbles.png"},
      stack_max = 240,
      groups = {cracky = 3, stone = 1},
      sounds = default.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:reinforced_cobble",
   {
      description = S("Reinforced Cobble"),
      tiles = {"default_reinforced_cobbles.png"},
      is_ground_content = false,
      groups = {cracky = 1, stone = 1},
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:gravel",
   {
      description = S("Gravel"),
      tiles = {"default_gravel.png"},
      groups = {crumbly = 2, falling_node = 1},
      sounds = default.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_crunch_footstep", gain = 0.45},
      }),
})

-- Material blocks

minetest.register_node(
   "default:block_coal",
   {
      description = S("Coal Block"),
      tiles = {"default_block_coal.png"},
      groups = {cracky = 3, oddly_breakable_by_hand = 3},
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:block_wrought_iron",
   {
      description = S("Wrought Iron Block"),
      tiles = {"default_block_wrought_iron.png"},
      groups = {cracky = 2},
      sounds = default.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:block_steel",
   {
      description = S("Steel Block"),
      tiles = {"default_block_steel.png"},
      groups = {cracky = 2},
      sounds = default.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:block_carbon_steel",
   {
      description = S("Carbon Steel Block"),
      tiles = {"default_block_carbon_steel.png"},
      groups = {cracky = 1},
      sounds = default.node_sound_stone_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:block_bronze",
   {
      description = S("Bronze Block"),
      tiles = {"default_block_bronze.png"},
      groups = {cracky = 1},
      sounds = default.node_sound_stone_defaults(),
      is_ground_content = false,
})

-- Soil

minetest.register_node(
   "default:dirt",
   {
      description = S("Dirt"),
      tiles = {"default_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, normal_dirt = 1, plantable_soil = 1, fall_damage_add_percent = -5},
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:dry_dirt",
   {
      description = S("Dry Dirt"),
      tiles = {"default_dry_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dry_dirt = 1, plantable_dry = 1, fall_damage_add_percent = -10},
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:swamp_dirt",
   {
      description = S("Swamp Dirt"),
      tiles = {"default_swamp_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, swamp_dirt = 1, plantable_soil = 1, fall_damage_add_percent = -10},
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:dirt_with_dry_grass",
   {
      description = S("Dirt with Dry Grass"),
      tiles = {
         "default_dry_grass.png",
         "default_dirt.png",
         "default_dirt.png^default_dry_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, normal_dirt = 1, plantable_sandy = 1, grass_cover = 1,
                fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"default:dirt"}, rarity = 1},
	    {items = {"default:dry_grass 4"}, rarity = 12},
	    {items = {"default:dry_grass 2"}, rarity = 6},
	    {items = {"default:dry_grass 1"}, rarity = 2},
	 }
      },
      sounds = default.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.3},
      }),
})

minetest.register_node(
   "default:dirt_with_swamp_grass",
   {
      description = S("Dirt with Swamp Grass"),
      tiles = {
         "default_swamp_grass.png",
         "default_swamp_dirt.png",
         "default_swamp_dirt.png^default_swamp_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, swamp_dirt = 1, plantable_soil = 1, grass_cover = 1,
                fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"default:swamp_dirt"}, rarity = 1},
	    {items = {"default:swamp_grass 6"}, rarity = 14},
	    {items = {"default:swamp_grass 3"}, rarity = 7},
	    {items = {"default:swamp_grass 2"}, rarity = 3},
	 }
      },
      sounds = default.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.5},
      }),
})

minetest.register_node(
   "default:dirt_with_grass",
   {
      description = S("Dirt with Grass"),
      tiles = {
         "default_grass.png",
         "default_dirt.png",
         "default_dirt.png^default_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1,
                fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"default:dirt"}, rarity = 1},
	    {items = {"default:grass 10"}, rarity = 30},
	    {items = {"default:grass 3"}, rarity = 9},
	    {items = {"default:grass 2"}, rarity = 6},
	    {items = {"default:grass 1"}, rarity = 3},
	 }
      },
      sounds = default.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.4},
      }),
})

minetest.register_node(
   "default:dirt_with_grass_footsteps",
   {
      description = S("Dirt with Grass and Footsteps"),
      tiles = {"default_grass_footstep.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
      groups = {crumbly = 3, soil = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1, fall_damage_add_percent = -5, not_in_craft_guide = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"default:dirt"}, rarity = 1},
	    {items = {"default:grass 10"}, rarity = 30},
	    {items = {"default:grass 3"}, rarity = 9},
	    {items = {"default:grass 2"}, rarity = 6},
	    {items = {"default:grass 1"}, rarity = 3},
	 }
      },
      sounds = default.node_sound_dirt_defaults(
	 {
	    footstep = {name = "default_soft_footstep", gain = 0.4},
      }),
})

-- Paths

minetest.register_node(
   "default:dirt_path",
   {
      description = S("Dirt Path"),
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5-2/16, 0.5}
      },
      tiles = {"default_dirt.png"},
      groups = {crumbly = 3, path = 1, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:path_slab",
   {
      description = S("Dirt Path Slab"),
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -2/16, 0.5}
      },
      tiles = {"default_dirt.png"},
      groups = {crumbly = 3, slab = 2, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node(
   "default:heated_dirt_path",
   {
      description = S("Heated Dirt Path"),
      drawtype = "nodebox",
      paramtype = "light",
      light_source = 6,
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5-2/16, 0.5}
      },
      tiles = {"default_dirt.png"},
      groups = {crumbly = 3, path = 1, fall_damage_add_percent = -10},
      is_ground_content = false,
      sounds = default.node_sound_dirt_defaults(),
})

-- Brick

minetest.register_node(
   "default:brick",
   {
      description = S("Brick Block"),
      tiles = {"default_brick.png"},
      is_ground_content = false,
      groups = {cracky = 2},
      sounds = default.node_sound_stone_defaults(),
})

-- Sand

minetest.register_node(
   "default:sand",
   {
      description = S("Sand"),
      tiles = {"default_sand.png"},
      groups = {crumbly = 3, falling_node = 1, sand = 1, plantable_sandy = 1, fall_damage_add_percent = -10},
      sounds = default.node_sound_sand_defaults(),
})

minetest.register_node(
   "default:sandstone",
   {
      description = S("Sandstone"),
      tiles = {"default_sandstone.png"},
      groups = {crumbly = 2, cracky = 3, sandstone = 1},
      drop = "default:sand 2",
      sounds = default.node_sound_stone_defaults(),
})

minetest.register_node(
   "default:compressed_sandstone",
   {
      description = S("Compressed Sandstone"),
      tiles = {"default_compressed_sandstone_top.png", "default_compressed_sandstone_top.png", "default_compressed_sandstone.png"},
      groups = {cracky = 2, sandstone = 1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
})

-- Saplings

minetest.register_node(
   "default:sapling",
   {
      description = S("Sapling"),
      drawtype = "plantlike",
      visual_scale = 1.0,
      tiles = {"default_sapling.png"},
      inventory_image = "default_sapling_inventory.png",
      wield_image = "default_sapling_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, sapling = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos, "apple")
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

minetest.register_node(
   "default:sapling_oak",
   {
      description = S("Oak Sapling"),
      drawtype = "plantlike",
      visual_scale = 1.0,
      tiles = {"default_sapling_oak.png"},
      inventory_image = "default_sapling_oak_inventory.png",
      wield_image = "default_sapling_oak_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, sapling = 1},
      sounds = default.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos, "oak")
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

minetest.register_node(
   "default:sapling_birch",
   {
      description = S("Birch Sapling"),
      drawtype = "plantlike",
      visual_scale = 1.0,
      tiles = {"default_sapling_birch.png"},
      inventory_image = "default_sapling_birch_inventory.png",
      wield_image = "default_sapling_birch_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, sapling = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos, "birch")
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

-- Trees

minetest.register_node(
   "default:tree",
   {
      description = S("Tree"),
      tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
      groups = {choppy = 2,tree = 1,oddly_breakable_by_hand = 1},
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:tree_oak",
   {
      description = S("Oak Tree"),
      tiles = {"default_tree_oak_top.png", "default_tree_oak_top.png", "default_tree_oak.png"},
      groups = {choppy = 1, tree = 1, oddly_breakable_by_hand = 1},
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:tree_birch",
   {
      description = S("Birch Tree"),
      tiles = {"default_tree_birch_top.png", "default_tree_birch_top.png", "default_tree_birch.png"},
      groups = {choppy = 2, tree = 1, oddly_breakable_by_hand = 1},
      sounds = default.node_sound_wood_defaults(),
})

-- Leaves

minetest.register_node(
   "default:leaves",
   {
      description = S("Leaves"),
      drawtype = "allfaces_optional",
      visual_scale = 1.3,
      tiles = {"default_leaves.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 3, fall_damage_add_percent = -10, leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"default:sapling"},
	       rarity = 10,
	    },
	    {
	       items = {"default:leaves"},
	    }
	 }
      },
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:leaves_oak",
   {
      description = S("Oak Leaves"),
      drawtype = "allfaces_optional",
      visual_scale = 1.3,
      tiles = {"default_leaves_oak.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 4, fall_damage_add_percent = -5, leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"default:sapling_oak"},
	       rarity = 10,
	    },
	    {
	       items = {"default:leaves_oak"},
	    }
	 }
      },
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node( -- looks just like default oak leaves, except they decay much farther
   "default:leaves_oak_huge",
   {
      description = S("Oak Leaves (Huge)"),
      drawtype = "allfaces_optional",
      visual_scale = 1.3,
      tiles = {"default_leaves_oak.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 10, fall_damage_add_percent = -5, leaves = 1, not_in_creative_inventory = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"default:sapling_oak"},
	       rarity = 40,
	    },
	    {
	       items = {"default:leaves_oak"},
	       rarity = 10,
	    }
	 }
      },
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:leaves_birch",
   {
      description = S("Birch Leaves"),
      drawtype = "allfaces_optional",
      visual_scale = 1.3,
      tiles = {"default_leaves_birch.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 6, fall_damage_add_percent = -5, leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"default:sapling_birch"},
	       rarity = 10,
	    },
	    {
	       items = {"default:leaves_birch"},
	    }
	 }
      },
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:dry_leaves",
   {
      description = S("Dry Leaves"),
      drawtype = "allfaces_optional",
      visual_scale = 1.3,
      tiles = {"default_dry_leaves.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 3, fall_damage_add_percent = -20, leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"default:dry_leaves"},
	    },
	    {
	       items = {"default:dry_grass"},
	       rarity = 6,
	    }
	 }
      },
      sounds = default.node_sound_leaves_defaults(),
})

-- Cacti

minetest.register_node(
   "default:cactus",
   {
      description = S("Cactus"),
      drawtype = "nodebox",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/8), -0.5, -0.5+(1/8), 0.5-(1/8), 0.5, 0.5-(1/8)},
	    {-0.5, -0.5, -0.5+(1/3), 0.5, 0.5-(1/3), 0.5-(1/3)},
	    {-0.5+(1/3), -0.5, -0.5, 0.5-(1/3), 0.5-(1/3), 0.5},
	 },
      },
      selection_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/8), -0.5, -0.5+(1/8), 0.5-(1/8), 0.5, 0.5-(1/8)},
	 },
      },
      tiles = {"default_cactus_top.png", "default_cactus_top.png", "default_cactus_sides.png"},
      --	damage_per_second = 1,
      groups = {snappy = 2, choppy = 2, fall_damage_add_percent = 20, food = 2},
      sounds = default.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
      on_use = minetest.item_eat({hp = 2, sat = 5}),
})

-- Rope

minetest.register_node(
   "default:rope",
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
      groups = {snappy = 3},
      is_ground_content = false,
      sounds = default.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_down(pos, node, digger)
      end,
})

-- Papyrus

minetest.register_node(
   "default:papyrus",
   {
      description = S("Papyrus"),
      drawtype = "nodebox",
      tiles = {"default_papyrus.png"},
      inventory_image = "default_papyrus_inventory.png",
      wield_image = "default_papyrus_inventory.png",
      paramtype = "light",
      walkable = false,
      climbable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5+(2/16), -0.5, -0.5+(2/16), 0.5-(2/16), 0.5, 0.5-(2/16)}
      },
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(2/16), -0.5, -0.5+(2/16), -0.5+(4/16), 0.5, -0.5+(4/16)},
	    {0.5-(2/16), -0.5, -0.5+(2/16), 0.5-(4/16), 0.5, -0.5+(4/16)},
	    {-0.5+(2/16), -0.5, 0.5-(2/16), -0.5+(4/16), 0.5, 0.5-(4/16)},
	    {0.5-(2/16), -0.5, 0.5-(2/16), 0.5-(4/16), 0.5, 0.5-(4/16)},
	    {-1/16, -0.5, -1/16, 1/16, 0.5, 1/16},
	 }
      },
      groups = {snappy = 3},
      sounds = default.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

-- Glass

minetest.register_node(
   "default:glass",
   {
      description = S("Glass"),
      drawtype = "glasslike_framed_optional",
      tiles = {"default_glass_frame.png", "default_glass.png"},
      paramtype = "light",
      sunlight_propagates = true,
      groups = {snappy = 2,cracky = 3,oddly_breakable_by_hand = 2, glass=1},
      is_ground_content = false,
      sounds = default.node_sound_glass_defaults(),
})

-- Fences

minetest.register_node(
   "default:fence",
   {
      description = S("Wooden Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood.png^default_fence_overlay.png"},
      inventory_image = "default_fence.png",
      wield_image = "default_fence.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, fence = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

minetest.register_node(
   "default:fence_oak",
   {
      description = S("Oak Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood_oak.png^default_fence_overlay.png"},
      inventory_image = "default_fence_oak.png",
      wield_image = "default_fence_oak.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 1, choppy = 1, oddly_breakable_by_hand = 1, fence = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

minetest.register_node(
   "default:fence_birch",
   {
      description = S("Birch Fence"),
      drawtype = "fencelike",
      tiles = {"default_wood_birch.png^default_fence_overlay.png"},
      inventory_image = "default_fence_birch.png",
      wield_image = "default_fence_birch.png",
      paramtype = "light",
      collision_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 1.0, 0.4},
      },
      groups = {snappy = 1, choppy = 1, oddly_breakable_by_hand = 1, fence = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
})

-- Ladder

minetest.register_node(
   "default:ladder",
   {
      description = S("Ladder"),
      drawtype = "nodebox",
      tiles = {
         "default_ladder_sides.png",
         "default_ladder_sides.png",
         "default_ladder_sides.png",
         "default_ladder_sides.png",
         "default_ladder_sides.png",
         "default_ladder.png"
      },
      inventory_image = "default_ladder_inventory.png",
      wield_image = "default_ladder_inventory.png",
      paramtype = "light",
      paramtype2 = "facedir",
      walkable = false,
      climbable = true,
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5+(1/16), -0.5, 0.5, -0.5+(4/16), 0.5, 0.5-(2/16)},
	    {0.5-(1/16), -0.5, 0.5, 0.5-(4/16), 0.5, 0.5-(2/16)},
	    {-0.5+(4/16), 0.5-(3/16), 0.5, 0.5-(4/16), 0.5-(5/16), 0.5-(1/16)},
	    {-0.5+(4/16), -0.5+(3/16), 0.5, 0.5-(4/16), -0.5+(5/16), 0.5-(1/16)}
	 }
      },
      selection_box = {
	 type = "fixed",
	 fixed = {
	    {-0.5, -0.5, 0.5, 0.5, 0.5, 0.5-(2/15)}
	 }
      },
      groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

-- Planks

minetest.register_node(
   "default:planks",
   {
      description = S("Wooden Planks"),
      tiles = {"default_wood.png"},
      groups = {planks = 1, wood = 1, snappy = 3, choppy = 3, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:planks_oak",
   {
      description = S("Oak Planks"),
      tiles = {"default_wood_oak.png"},
      groups = {planks = 1, wood = 1, snappy = 2, choppy = 2, oddly_breakable_by_hand = 3},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:planks_birch",
   {
      description = S("Birch Planks"),
      tiles = {"default_wood_birch.png"},
      groups = {planks = 1, wood = 1, snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

-- Frames

minetest.register_node(
   "default:frame",
   {
      description = S("Frame"),
      tiles = {"default_frame.png"},
      is_ground_content = false,
      groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

minetest.register_node(
   "default:reinforced_frame",
   {
      description = S("Reinforced Frame"),
      tiles = {"default_reinforced_frame.png"},
      is_ground_content = false,
      groups = {wood = 1, choppy = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
})

-- Fern

minetest.register_node(
   "default:fern",
   {
      description = S("Fern"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_fern.png"},
      inventory_image = "default_fern_inventory.png",
      wield_image = "default_fern_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, fern = 1},
      sounds = default.node_sound_leaves_defaults(),
})

-- Flowers

minetest.register_node(
   "default:flower",
   {
      description = S("Flower"),
      drawtype = "nodebox",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + (1 / 16), 0.5}
      },
      tiles = {"default_flowers.png"},
      inventory_image = "default_flowers_inventory.png",
      wield_image = "default_flowers_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, flower = 1},
      sounds = default.node_sound_leaves_defaults(),
})

-- Grasses

minetest.register_node(
   "default:swamp_grass",
   {
      description = S("Swamp Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_swamp_grass_clump.png"},
      inventory_image = "default_swamp_grass_clump_inventory.png",
      wield_image = "default_swamp_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, swamp_grass = 1, green_grass = 1},
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:dry_grass",
   {
      description = S("Dry Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_dry_grass_clump.png"},
      inventory_image = "default_dry_grass_clump_inventory.png",
      wield_image = "default_dry_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, dry_grass = 1},
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:grass",
   {
      description = S("Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_grass_clump.png"},
      inventory_image = "default_grass_clump_inventory.png",
      wield_image = "default_grass_clump_inventory.png",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1},
      sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node(
   "default:tall_grass",
   {
      description = S("Tall Grass Clump"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
      },
      visual_scale = 1.15,
      tiles = {"default_grass_clump_tall.png"},
      inventory_image = "default_grass_clump_tall_inventory.png",
      wield_image = "default_grass_clump_tall_inventory.png",
      drop = "default:grass",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1},
      sounds = default.node_sound_leaves_defaults(),
})

-- Thistle

minetest.register_node(
   "default:thistle",
   {
      description = S("Thistle"),
      drawtype = "plantlike",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, 0.5, 6/16}
      },
      tiles = {"default_thistle.png"},
      inventory_image = "default_thistle_inventory.png",
      wield_image = "default_thistle_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      damage_per_second = 1,
      groups = {snappy = 3, dig_immediate = 3, falling_node = 1},
      sounds = default.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         default.dig_up(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
         default.dig_up(pos, oldnode)
      end,
})

-- Food

minetest.register_node(
   "default:apple",
   {
      description = S("Apple"),
      drawtype = "nodebox",
      visual_scale = 1.0,
      tiles = {"default_apple_top.png", "default_apple_bottom.png", "default_apple_side.png"},
      inventory_image = "default_apple.png",
      wield_image = "default_apple.png",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	    {-1/8, 0.25, -1/8, 1/8, 0.5, 1/8},
	 },
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {snappy = 3, handy = 2, leafdecay = 3, leafdecay_drop = 1, food = 2},
      on_use = minetest.item_eat({hp = 2, sat = 10}),
      sounds = default.node_sound_defaults(),
})

minetest.register_node(
   "default:clam",
   {
      description = S("Clam"),
      drawtype = "nodebox",
      tiles = {"default_clam.png"},
      inventory_image = "default_clam_inventory.png",
      wield_image = "default_clam_inventory.png",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-3/16, -0.5, -3/16, 3/16, -6/16, 3/16},
	 },
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      -- TODO: Enable the drop code below, when the pearl is useful.
      -- The pearl is currently useless.
      --[[drop = {
	 max_items = 3,
	 items = {
	    {items = {"default:clam"}, rarity = 1},
	    {items = {"default:pearl"}, rarity = 60},
	    {items = {"default:pearl"}, rarity = 20},
	 }
      },]]
      groups = {fleshy = 3, oddly_breakable_by_hand = 2, choppy = 3, attached_node = 1, food = 2},
      on_use = minetest.item_eat({hp = 4, sat = 40}),
      sounds = default.node_sound_defaults(),
})

-- Water

minetest.register_node(
   "default:water_flowing",
   {
      description = S("Flowing Water"),
      drawtype = "flowingliquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    image = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    image = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      drop = "",
      alpha = default.WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      liquidtype = "flowing",
      liquid_alternative_flowing = "default:water_flowing",
      liquid_alternative_source = "default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a = 90, r = 40, g = 40, b = 100},
      groups = {water = 1, flowing_water = 1, liquid = 1, not_in_creative_inventory=1,},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:water_source",
   {
      description = S("Water Source"),
      drawtype = "liquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    image = "default_water.png",
	    backface_culling = false,
	 },
      },
      drop = "",
      alpha = default.WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      liquidtype = "source",
      liquid_alternative_flowing = "default:water_flowing",
      liquid_alternative_source = "default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a=90, r=40, g=40, b=100},
      groups = {water=1, liquid=1},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:river_water_flowing",
   {
      description = S("Flowing River Water"),
      drawtype = "flowingliquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    image = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    image = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      drop= "",
      alpha = default.RIVER_WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      liquidtype = "flowing",
      liquid_alternative_flowing = "default:river_water_flowing",
      liquid_alternative_source = "default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water=1, flowing_water = 1, river_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:river_water_source",
   {
      description = S("River Water Source"),
      drawtype = "liquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    image = "default_water.png",
	    backface_culling = false,
	 },
      },
      drop= "",
      alpha = default.RIVER_WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      liquidtype = "source",
      liquid_alternative_flowing = "default:river_water_flowing",
      liquid_alternative_source = "default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water = 1, river_water = 1, liquid = 1},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:swamp_water_flowing",
   {
      description = S("Flowing Swamp Water"),
      drawtype = "flowingliquid",
      tiles = {"default_swamp_water.png"},
      special_tiles = {
	 {
	    image = "default_swamp_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
	 {
	    image = "default_swamp_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
      },
      drop= "",
      alpha = default.SWAMP_WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      liquidtype = "flowing",
      liquid_alternative_flowing = "default:swamp_water_flowing",
      liquid_alternative_source = "default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water=1, flowing_water = 1, swamp_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

minetest.register_node(
   "default:swamp_water_source",
   {
      description = S("Swamp Water Source"),
      drawtype = "liquid",
      tiles = {"default_swamp_water.png"},
      special_tiles = {
	 {
	    image = "default_swamp_water.png",
	    backface_culling = false,
	 },
      },
      drop= "",
      alpha = default.SWAMP_WATER_ALPHA,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      liquidtype = "source",
      liquid_alternative_flowing = "default:swamp_water_flowing",
      liquid_alternative_source = "default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water = 1, swamp_water = 1, liquid = 1},
      sounds = default.node_sound_water_defaults(),
      is_ground_content = false,
})

default.log("nodes", "loaded")
