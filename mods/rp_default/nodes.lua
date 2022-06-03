
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
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_sulfur",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_graphite",
   {
      description = S("Stone with Graphite"),
      tiles = {"default_stone.png^default_mineral_graphite.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "rp_default:sheet_graphite",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_coal",
   {
      description = S("Stone with Coal"),
      tiles = {"default_stone.png^default_mineral_coal.png"},
      groups = {cracky = 2, stone = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_coal",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_iron",
   {
      description = S("Stone with Iron"),
      tiles = {"default_stone.png^default_mineral_iron.png"},
      groups = {cracky = 2, stone = 1, magnetic = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_iron",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_tin",
   {
      description = S("Stone with Tin"),
      tiles = {"default_stone.png^default_mineral_tin.png"},
      groups = {cracky = 1, stone = 1, not_in_craft_guide = 1},
      drop = "rp_default:lump_tin",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_default:stone_with_copper",
   {
      description = S("Stone with Copper"),
      tiles = {"default_stone.png^default_mineral_copper.png"},
      groups = {cracky = 1, stone = 1, not_in_craft_guide = 1},
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
      groups = {crumbly = 2, falling_node = 1},
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
      groups = {cracky = 3, oddly_breakable_by_hand = 3},
      sounds = rp_sounds.node_sound_wood_defaults(),
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
})

minetest.register_node(
   "rp_default:dry_dirt",
   {
      description = S("Dry Dirt"),
      tiles = {"default_dry_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, dry_dirt = 1, plantable_dry = 1, fall_damage_add_percent = -10},
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:swamp_dirt",
   {
      description = S("Swamp Dirt"),
      tiles = {"default_swamp_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, swamp_dirt = 1, plantable_soil = 1, fall_damage_add_percent = -10},
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:dirt_with_dry_grass",
   {
      description = S("Dirt with Dry Grass"),
      tiles = {
         "default_dry_grass.png",
         "default_dirt.png",
         "default_dirt.png^default_dry_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_sandy = 1, grass_cover = 1,
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
})

minetest.register_node(
   "rp_default:dirt_with_swamp_grass",
   {
      description = S("Swamp Dirt with Swamp Grass"),
      tiles = {
         "default_swamp_grass.png",
         "default_swamp_dirt.png",
         "default_swamp_dirt.png^default_swamp_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, swamp_dirt = 1, plantable_soil = 1, grass_cover = 1,
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
})

minetest.register_node(
   "rp_default:dirt_with_grass",
   {
      description = S("Dirt with Grass"),
      tiles = {
         "default_grass.png",
         "default_dirt.png",
         "default_dirt.png^default_grass_side.png"
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
})

-- Legacy node. TODO: Remove it
minetest.register_node(
   "rp_default:dirt_with_grass_footsteps",
   {
      description = S("Dirt with Grass and Footsteps"),
      tiles = {"default_grass_footstep.png", "default_dirt.png", "default_dirt.png^default_grass_side.png"},
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1, fall_damage_add_percent = -5, not_in_craft_guide = 1, not_in_creative_inventory = 1},
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
      tiles = {"default_dirt.png"},
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
      tiles = {"default_dirt.png"},
      groups = {crumbly = 3, slab = 2, fall_damage_add_percent = -10},
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
      tiles = {"default_dirt.png"},
      groups = {crumbly = 3, path = 1, fall_damage_add_percent = -10},
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

-- Saplings

minetest.register_node(
   "rp_default:sapling",
   {
      description = S("Sapling"),
      _tt_help = S("Grows into an apple tree"),
      drawtype = "plantlike",
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
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos)
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

minetest.register_node(
   "rp_default:sapling_oak",
   {
      description = S("Oak Sapling"),
      _tt_help = S("Grows into an oak tree"),
      drawtype = "plantlike",
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
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      sounds = rp_sounds.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos)
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

minetest.register_node(
   "rp_default:sapling_birch",
   {
      description = S("Birch Sapling"),
      _tt_help = S("Grows into a birch tree"),
      drawtype = "plantlike",
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
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos)
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

minetest.register_node(
   "rp_default:sapling_dry_bush",
   {
      description = S("Dry Bush Sapling"),
      _tt_help = S("Grows into a dry bush"),
      drawtype = "plantlike",
      tiles = {"default_sapling_dry_bush.png"},
      inventory_image = "default_sapling_dry_bush_inventory.png",
      wield_image = "default_sapling_dry_bush_inventory.png",
      paramtype = "light",
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-4/16, -0.5, -4/16, 4/16, 3/16, 4/16},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_defaults(),

      on_timer = function(pos)
         default.grow_sapling(pos)
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})



-- Trees

minetest.register_node(
   "rp_default:tree",
   {
      description = S("Tree"),
      tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
      groups = {choppy = 2,tree = 1,oddly_breakable_by_hand = 1},
      sounds = rp_sounds.node_sound_wood_defaults(),
})

minetest.register_node(
   "rp_default:tree_oak",
   {
      description = S("Oak Tree"),
      tiles = {"default_tree_oak_top.png", "default_tree_oak_top.png", "default_tree_oak.png"},
      groups = {choppy = 1, tree = 1, oddly_breakable_by_hand = 1},
      sounds = rp_sounds.node_sound_wood_defaults(),
})

minetest.register_node(
   "rp_default:tree_birch",
   {
      description = S("Birch Tree"),
      tiles = {"default_tree_birch_top.png", "default_tree_birch_top.png", "default_tree_birch.png"},
      groups = {choppy = 2, tree = 1, oddly_breakable_by_hand = 1},
      sounds = rp_sounds.node_sound_wood_defaults(),
})

-- Leaves

minetest.register_node(
   "rp_default:leaves",
   {
      description = S("Leaves"),
      _tt_help = S("Decays when not near a tree block"),
      drawtype = "allfaces_optional",
      tiles = {"default_leaves.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 3, fall_damage_add_percent = -10, leaves = 1, lush_leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"rp_default:sapling"},
	       rarity = 10,
	    },
	    {
	       items = {"rp_default:leaves"},
	    }
	 }
      },
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:leaves_oak",
   {
      description = S("Oak Leaves"),
      _tt_help = S("Decays when not near a tree block"),
      drawtype = "allfaces_optional",
      tiles = {"default_leaves_oak.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 4, fall_damage_add_percent = -5, leaves = 1, lush_leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"rp_default:sapling_oak"},
	       rarity = 10,
	    },
	    {
	       items = {"rp_default:leaves_oak"},
	    }
	 }
      },
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:leaves_birch",
   {
      description = S("Birch Leaves"),
      _tt_help = S("Decays when not near a tree block"),
      drawtype = "allfaces_optional",
      tiles = {"default_leaves_birch.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 6, fall_damage_add_percent = -5, leaves = 1, lush_leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"rp_default:sapling_birch"},
	       rarity = 10,
	    },
	    {
	       items = {"rp_default:leaves_birch"},
	    }
	 }
      },
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:dry_leaves",
   {
      description = S("Dry Leaves"),
      _tt_help = S("Decays when not near a tree block"),
      drawtype = "allfaces_optional",
      tiles = {"default_dry_leaves.png"},
      paramtype = "light",
      waving = 1,
      groups = {snappy = 3, leafdecay = 3, fall_damage_add_percent = -20, leaves = 1, dry_leaves = 1},
      drop = {
	 max_items = 1,
	 items = {
	    {
	       items = {"rp_default:sapling_dry_bush"},
	       rarity = 15,
	    },
	    {
	       items = {"rp_default:dry_leaves"},
	    },
	 }
      },
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Cacti

minetest.register_node(
   "rp_default:cactus",
   {
      description = S("Cactus"),
      _tt_help = S("Grows on sand"),
      _tt_food = true,
      _tt_food_hp = 2,
      _tt_food_satiation = 5,
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
      groups = {snappy = 2, choppy = 2, fall_damage_add_percent = 20, plant = 1, food = 2},
      sounds = rp_sounds.node_sound_wood_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_use = minetest.item_eat({hp = 2, sat = 5}),
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
      groups = {snappy = 3},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_down(pos, node, digger)
      end,
})

-- Papyrus

minetest.register_node(
   "rp_default:papyrus",
   {
      description = S("Papyrus"),
      _tt_help = S("Grows on sand or dirt near water"),
      drawtype = "nodebox",
      tiles = {"default_papyrus_repixture.png"},
      use_texture_alpha = "clip",
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
      groups = {snappy = 3, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
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

-- Fern

minetest.register_node(
   "rp_default:fern",
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
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, fern = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Flowers

minetest.register_node(
   "rp_default:flower",
   {
      description = S("Flower"),
      _tt_help = S("It looks beautiful"),
      drawtype = "nodebox",
      node_box = {
	 type = "fixed",
	 fixed = {-0.5, -0.5, -0.5, 0.5, -0.5 + (1 / 16), 0.5}
      },
      tiles = {"default_flowers.png", "default_flowers.png^[transformFY", "blank.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_flowers_inventory.png",
      wield_image = "default_flowers_inventory.png",
      paramtype = "light",
      sunlight_propagates = true,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, flower = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Grasses

minetest.register_node(
   "rp_default:swamp_grass",
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
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, swamp_grass = 1, green_grass = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:dry_grass",
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
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, dry_grass = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:grass",
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
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:tall_grass",
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
      drop = "rp_default:grass",
      paramtype = "light",
      waving = 1,
      walkable = false,
      buildable_to = true,
      floodable = true,
      groups = {snappy = 2, dig_immediate = 3, attached_node = 1, grass = 1, normal_grass = 1, green_grass = 1, plant = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      -- Trim tall grass with shears
      _on_trim = function(pos, node, player, itemstack)
          -- This turns it to a normal grass clump and drops one bonus grass clump
          minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
          minetest.set_node(pos, {name = "rp_default:grass"})

          item_drop.drop_item(pos, "rp_default:grass")

          -- Add wear
          if not minetest.is_creative_enabled(player:get_player_name()) then
             local def = itemstack:get_definition()
             itemstack:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
          end
          return itemstack
      end,
})

local function get_sea_plant_on_place(base, paramtype2)
return function(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
           return itemstack
	end

        -- Boilerplate to handle pointed node handlers
        local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
        if handled then
           return handled_itemstack
        end

	local player_name = placer:get_player_name()
        local undernode = minetest.get_node(pointed_thing.under)
	local underdef = minetest.registered_nodes[undernode.name]
	-- Grow leveled plantlike_rooted node by 1 "node length"
	if paramtype2 == "leveled" and underdef and underdef.paramtype2 == "leveled" and pointed_thing.under.y < pointed_thing.above.y and pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z then
           if minetest.is_protected(pointed_thing.under, player_name) or
                 minetest.is_protected(pointed_thing.above, player_name) then
              minetest.record_protection_violation(pointed_thing.under, player_name)
              return itemstack
           end
           local grown, top = default.grow_underwater_leveled_plant(pointed_thing.under, undernode)
           if grown then
              local snd = underdef.sounds.place
              if snd and top then
                 minetest.sound_play(snd, {pos = top}, true)
              end
              if not minetest.is_creative_enabled(player_name) then
                 itemstack:take_item()
              end
           end
           return itemstack
        end

        -- Find position to place plant at
        local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
        if place_in == nil then
           return itemstack
        end
        local floornode = minetest.get_node(place_floor)

        -- Check protection
        if minetest.is_protected(place_in, player_name) or
              minetest.is_protected(place_floor, player_name) then
           minetest.record_protection_violation(place_floor, player_name)
           return itemstack
        end

	local node_floor = minetest.get_node(place_floor)
	local def_floor = minetest.registered_nodes[node_floor.name]

	local name_in = minetest.get_node(place_in).name
	local def_in = minetest.registered_nodes[name_in]
	if not (minetest.get_item_group(name_in, "water") > 0 and def_in.liquidtype == "source") then
		return itemstack
	end

	if node_floor.name == "rp_default:dirt" then
		node_floor.name = "rp_default:"..base.."_on_dirt"
	elseif node_floor.name == "rp_default:swamp_dirt" then
		node_floor.name = "rp_default:"..base.."_on_swamp_dirt"
	elseif base == "alga" and node_floor.name == "rp_default:alga_block" then
		node_floor.name = "rp_default:"..base.."_on_alga_block"
	else
		return itemstack
	end

	def_floor = minetest.registered_nodes[node_floor.name]
	if def_floor and def_floor.place_param2 then
		node_floor.param2 = def_floor.place_param2
	end

	minetest.set_node(place_floor, node_floor)
        local snd = def_floor.sounds.place
        if snd then
           minetest.sound_play(snd, {pos = place_in}, true)
        end
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end
end

-- Seagrass


local register_seagrass = function(plant_id, selection_box, drop, append, basenode, basenode_tiles, _on_trim)
   minetest.register_node(
      "rp_default:"..plant_id.."_on_"..append,
      {
         drawtype = "plantlike_rooted",
	 selection_box = selection_box,
         collision_box = {
            type = "regular",
         },
         visual_scale = 1.15,
         tiles = basenode_tiles,
         special_tiles = {"rp_default_"..plant_id.."_clump.png"},
         inventory_image = "rp_default_"..plant_id.."_on_"..append..".png",
         wield_image = "rp_default_"..plant_id.."_on_"..append..".png",
         waving = 1,
         walkable = true,
         groups = {snappy = 2, dig_immediate = 3, grass = 1, seagrass = 1, green_grass = 1, plant = 1},
         sounds = rp_sounds.node_sound_leaves_defaults(),
	 node_dig_prediction = basenode,
         after_destruct = function(pos)
            local newnode = minetest.get_node(pos)
            if minetest.get_item_group(newnode.name, "seagrass") == 0 then
               minetest.set_node(pos, {name=basenode})
            end
         end,
	 _on_trim = _on_trim,
	 drop = drop,
   })
end
local register_seagrass_on = function(append, basenode, basenode_tiles)
   register_seagrass("seagrass",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 17/16, 0.5},
      }}, "rp_default:seagrass", append, basenode, basenode_tiles)

    -- Trim tall sea grass with shears
    local _on_trim = function(pos, node, player, itemstack)
       local param2 = node.param2
       -- This turns it to a normal sea grass clump and drops one bonus sea grass clump
       minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
       minetest.set_node(pos, {name = "rp_default:seagrass_on_"..append, param2 = param2})

       local dir = vector.multiply(minetest.wallmounted_to_dir(param2), -1)
       local droppos = vector.add(pos, dir)
       item_drop.drop_item(droppos, "rp_default:seagrass")

       -- Add wear
       if not minetest.is_creative_enabled(player:get_player_name()) then
          local def = itemstack:get_definition()
          itemstack:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
       end
       return itemstack
   end
   register_seagrass("tall_seagrass",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 1.5, 0.5},
      }}, "rp_default:seagrass", append, basenode, basenode_tiles, _on_trim)

end

minetest.register_craftitem("rp_default:tall_seagrass", {
   description = S("Tall Seagrass Clump"),
   _tt_help = S("Grows underwater on dirt or swamp dirt"),
   inventory_image = "rp_default_tall_seagrass_clump_inventory.png",
   wield_image = "rp_default_tall_seagrass_clump_inventory.png",
   on_place = get_sea_plant_on_place("tall_seagrass", "wallmounted"),
   groups = { green_grass = 1, seagrass = 1, plant = 1, grass = 1 },
})
minetest.register_craftitem("rp_default:seagrass", {
   description = S("Seagrass Clump"),
   _tt_help = S("Grows underwater on dirt or swamp dirt"),
   inventory_image = "rp_default_seagrass_clump_inventory.png",
   wield_image = "rp_default_seagrass_clump_inventory.png",
   on_place = get_sea_plant_on_place("seagrass", "wallmounted"),
   groups = { green_grass = 1, seagrass = 1, plant = 1, grass = 1 },
})

register_seagrass_on("dirt", "rp_default:dirt", {"default_dirt.png"})
register_seagrass_on("swamp_dirt", "rp_default:swamp_dirt", {"default_swamp_dirt.png"})

-- Alga
local register_alga_on = function(append, basenode, basenode_tiles, max_height)
   if not max_height then
      max_height = 15
   end
   minetest.register_node(
      "rp_default:alga_on_"..append,
      {
         drawtype = "plantlike_rooted",
	 selection_box = {
            type = "fixed",
	    fixed = {
               { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }, -- base
               { -6/16, 0.5, -6/16, 6/16, 1.5, 6/16 }, -- plant
	    },
	 },
         collision_box = {
            type = "regular",
         },
	 waving = 1,
	 paramtype2 = "leveled",
	 place_param2 = 16,
	 leveled_max = 16 * max_height,
         tiles = basenode_tiles,
         special_tiles = {{name="rp_default_alga.png", tileable_vertical=true}},
         inventory_image = "rp_default_alga_on_"..append..".png",
         wield_image = "rp_default_alga_on_"..append..".png",
         walkable = true,
         groups = {snappy = 2, dig_immediate = 3, alga = 1, plant = 1},
         sounds = rp_sounds.node_sound_leaves_defaults(),
	 node_dig_prediction = basenode,
	 drop = "rp_default:alga",
         after_destruct = function(pos)
            local newnode = minetest.get_node(pos)
            if minetest.get_item_group(newnode.name, "alga") == 0 then
               minetest.set_node(pos, {name=basenode})
            end
         end,
	 _on_trim = function(pos, node, player, itemstack)
            local param2 = node.param2
            if param2 <= 16 then
               return itemstack
            end
            local cut_height = math.floor((node.param2 - 16) / 16)
            -- This reduces the alga height
            minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
            minetest.set_node(pos, {name=node.name, param2=16})

            -- Add wear
            if not minetest.is_creative_enabled(player:get_player_name()) then
               local def = itemstack:get_definition()
               itemstack:add_wear(math.ceil(65536 / def.tool_capabilities.groupcaps.snappy.uses))
            end

	    -- Drop items
	    if cut_height < 1 then
               return itemstack
	    end
	    if not minetest.is_creative_enabled(player:get_player_name()) then
               local dir = vector.multiply(minetest.wallmounted_to_dir(param2), -1)
               local droppos = vector.new(pos, vector.new(0,1,0))
	       for i=1, cut_height do
	          droppos.y = pos.y + i
                  item_drop.drop_item(droppos, "rp_default:alga")
               end
            end
            return itemstack
         end,
   })
end

minetest.register_craftitem("rp_default:alga", {
   description = S("Alga"),
   _tt_help = S("Grows underwater on dirt or swamp dirt"),
   inventory_image = "rp_default_alga_inventory.png",
   wield_image = "rp_default_alga_inventory.png",
   on_place = get_sea_plant_on_place("alga", "leveled"),
   groups = { plant = 1, alga = 1 },
})

local alga_block_tiles = {
   "rp_default_alga_block_top.png",
   "rp_default_alga_block_top.png",
   "rp_default_alga_block_side.png",
}

register_alga_on("dirt", "rp_default:dirt", {"default_dirt.png"}, 5)
register_alga_on("swamp_dirt", "rp_default:swamp_dirt", {"default_swamp_dirt.png"}, 7)
register_alga_on("alga_block", "rp_default:alga_block", alga_block_tiles, 10)

-- Alga Block
minetest.register_node(
   "rp_default:alga_block",
   {
      description = S("Alga Block"),
      tiles = alga_block_tiles,
      groups = {snappy=2, fall_damage_add_percent=-10, slippery=2},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

-- Thistle

minetest.register_node(
   "rp_default:thistle",
   {
      description = S("Thistle"),
      _tt_help = S("Careful, it stings!"),
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
      groups = {snappy = 3, dig_immediate = 3, falling_node = 1, plant = 1, immortal_item = 1},
      sounds = rp_sounds.node_sound_leaves_defaults(),
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_up(pos, node, digger)
      end,
      on_flood = function(pos, oldnode, newnode)
         util.dig_up(pos, oldnode)
      end,
})

-- Returns an on_place function to handle placement of fruit.
-- Placing a "floor" version when placed on floor.
local create_on_place_fruit_function = function(fruitnode)
   return function(itemstack, placer, pointed_thing)
      -- Boilerplate to handle pointed node handlers
      local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
      if handled then
         return handled_itemstack
      end

      if pointed_thing.type ~= "node" then
         return itemstack
      end

      local pos = minetest.get_pointed_thing_position(pointed_thing)
      -- Check protection
      if minetest.is_protected(pos, placer:get_player_name()) and
              not minetest.check_player_privs(placer, "protection_bypass") then
          minetest.record_protection_violation(pos, placer:get_player_name())
          return itemstack
      end

      -- Place the "floor" node variant when placed on floor
      if pointed_thing.above.y > pointed_thing.under.y then
          itemstack:set_name(fruitnode.."_floor")
      end
      itemstack = minetest.item_place_node(itemstack, placer, pointed_thing)
      itemstack:set_name(fruitnode)
      return itemstack
   end
end

-- Food
--
minetest.register_node(
   "rp_default:apple",
   {
      description = S("Apple"),
      _tt_food = true,
      _tt_food_hp = 2,
      _tt_food_satiation = 10,
      drawtype = "nodebox",
      tiles = {"default_apple_top.png", "default_apple_bottom.png", "default_apple_side.png"},
      use_texture_alpha = "clip",
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
      on_place = create_on_place_fruit_function("rp_default:apple"),
      sounds = rp_sounds.node_sound_defaults(),
})

-- Same as apple, but with the nodebox on the "floor".
-- Nice for decoration.
minetest.register_node(
   "rp_default:apple_floor",
   {
      drawtype = "nodebox",
      tiles = {"default_apple_top.png", "default_apple_bottom.png", "rp_default_apple_floor_side.png"},
      use_texture_alpha = "clip",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-0.25, -0.5, -0.25, 0.25, 0, 0.25},
	    {-1/8, 0, -1/8, 1/8, 0.25, 1/8},
	 },
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {snappy = 3, handy = 2},
      sounds = rp_sounds.node_sound_defaults(),
      drop = "rp_default:apple",
})

minetest.register_node(
   "rp_default:acorn",
   {
      description = S("Acorn"),
      _tt_food = true,
      _tt_food_hp = 1,
      _tt_food_satiation = 5,
      drawtype = "nodebox",
      tiles = {"rp_default_acorn_top.png", "rp_default_acorn_bottom.png", "rp_default_acorn_side.png"},
      use_texture_alpha = "clip",
      inventory_image = "rp_default_acorn.png",
      wield_image = "rp_default_acorn.png",
      paramtype = "light",
      node_box = {
         type = "fixed",
         fixed = {
            {-1/16, 7/16, -1/16, 1/16, 0.5, 1/16}, -- cap top
            {-4/16, 6/16, -4/16, 4/16, 7/16, 4/16}, -- cap
            {-3/16, 1/16, -3/16, 3/16, 6/16, 3/16}, -- body top
            {-2/16, 0/16, -2/16, 2/16, 1/16, 2/16}, -- body bottom
         }
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {snappy = 3, handy = 3, leafdecay = 3, leafdecay_drop = 1, food = 2},
      on_use = minetest.item_eat({hp = 1, sat = 5}),
      on_place = create_on_place_fruit_function("rp_default:acorn"),
      sounds = rp_sounds.node_sound_defaults(),
})

minetest.register_node(
   "rp_default:acorn_floor",
   {
      drawtype = "nodebox",
      tiles = {"rp_default_acorn_top.png", "rp_default_acorn_bottom.png", "rp_default_acorn_floor_side.png"},
      use_texture_alpha = "clip",
      paramtype = "light",
      node_box = {
         type = "fixed",
         fixed = {
            {-1/16, -1/16, -1/16, 1/16, 0, 1/16}, -- cap top
            {-4/16, -2/16, -4/16, 4/16, -1/16, 4/16}, -- cap
            {-3/16, -7/16, -3/16, 3/16, -2/16, 3/16}, -- body top
            {-2/16, -8/16, -2/16, 2/16, -7/16, 2/16}, -- body bottom
         }
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {snappy = 3, handy = 3},
      sounds = rp_sounds.node_sound_defaults(),
      drop = "rp_default:acorn",
})


minetest.register_node(
   "rp_default:clam",
   {
      description = S("Clam"),
      _tt_food = true,
      _tt_food_hp = 4,
      _tt_food_satiation = 40,
      drawtype = "nodebox",
      tiles = {"default_clam.png"},
      use_texture_alpha = "clip",
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
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:clam"}, rarity = 1},
	    {items = {"rp_default:pearl"}, rarity = 60},
	    {items = {"rp_default:pearl"}, rarity = 20},
	 }
      },
      groups = {fleshy = 3, oddly_breakable_by_hand = 2, choppy = 3, attached_node = 1, food = 2},
      on_use = minetest.item_eat({hp = 4, sat = 40}),
      sounds = rp_sounds.node_sound_defaults(),

      -- Place node as the 'nopearl' clam to make sure the player can't
      -- place the same clam over and over again to farm pearls.
      node_placement_prediction = "rp_default:clam_nopearl",
      after_place_node = function(pos, placer, itemstack, pointed_thing)
         minetest.set_node(pos, {name="rp_default:clam_nopearl"})
      end,

})
-- Same as clam, except it never drops pearls.
-- To be used as node only, not for player inventory.
minetest.register_node(
   "rp_default:clam_nopearl",
   {
      drawtype = "nodebox",
      tiles = {"default_clam.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_clam_inventory.png^default_clam_nopearl_overlay.png",
      wield_image = "default_clam_inventory.png",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-3/16, -0.5, -3/16, 3/16, -6/16, 3/16},
	 },
      },
      drop = "rp_default:clam",
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {fleshy = 3, oddly_breakable_by_hand = 2, choppy = 3, attached_node = 1, not_in_creative_inventory = 1},
      sounds = rp_sounds.node_sound_defaults(),
})


-- Water

minetest.register_node(
   "rp_default:water_flowing",
   {
      description = S("Flowing Water"),
      drawtype = "flowingliquid",
      tiles = {"default_water.png"},
      special_tiles = {
	 {
	    name = "default_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      drop = "",
      paramtype = "light",
      sunlight_propagates = false,
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:water_flowing",
      liquid_alternative_source = "rp_default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a = 90, r = 40, g = 40, b = 100},
      groups = {water = 1, flowing_water = 1, liquid = 1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
})

minetest.register_node(
   "rp_default:water_source",
   {
      description = S("Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      sunlight_propagates = false,
      drop = "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 1,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:water_flowing",
      liquid_alternative_source = "rp_default:water_source",
      liquid_viscosity = default.WATER_VISC,
      post_effect_color = {a=90, r=40, g=40, b=100},
      groups = {water=1, liquid=1},
      sounds = rp_sounds.node_sound_water_defaults(),
})

minetest.register_node(
   "rp_default:river_water_flowing",
   {
      description = S("Flowing River Water"),
      drawtype = "flowingliquid",
      tiles = {"default_river_water.png"},
      special_tiles = {
	 {
	    name = "default_river_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_river_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:river_water_flowing",
      liquid_alternative_source = "rp_default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water=1, flowing_water = 1, river_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
})

minetest.register_node(
   "rp_default:river_water_source",
   {
      description = S("River Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_river_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_river_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },

      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 2,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:river_water_flowing",
      liquid_alternative_source = "rp_default:river_water_source",
      liquid_viscosity = default.RIVER_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 1,
      post_effect_color = {a=40, r=40, g=70, b=100},
      groups = {water = 1, river_water = 1, liquid = 1},
      sounds = rp_sounds.node_sound_water_defaults(),
})

minetest.register_node(
   "rp_default:swamp_water_flowing",
   {
      description = S("Flowing Swamp Water"),
      drawtype = "flowingliquid",
      tiles = {"default_swamp_water.png"},
      special_tiles = {
	 {
	    name = "default_swamp_water_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
	 {
	    name = "default_swamp_water_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 1.8}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      is_ground_content = false,
      liquidtype = "flowing",
      liquid_alternative_flowing = "rp_default:swamp_water_flowing",
      liquid_alternative_source = "rp_default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water=1, flowing_water = 1, swamp_water = 1, liquid=1, not_in_creative_inventory=1,},
      sounds = rp_sounds.node_sound_water_defaults(),
})

minetest.register_node(
   "rp_default:swamp_water_source",
   {
      description = S("Swamp Water Source"),
      drawtype = "liquid",
      tiles = {
	 {
	    name = "default_swamp_water_source_animated.png",
	    backface_culling = false,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
	 {
	    name = "default_swamp_water_source_animated.png",
	    backface_culling = true,
	    animation = {type = "vertical_frames", aspect_w= 16, aspect_h = 16, length = 0.8}
	 },
      },
      use_texture_alpha = "blend",
      drop= "",
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      drowning = 3,
      is_ground_content = false,
      liquidtype = "source",
      liquid_alternative_flowing = "rp_default:swamp_water_flowing",
      liquid_alternative_source = "rp_default:swamp_water_source",
      liquid_viscosity = default.SWAMP_WATER_VISC,
      liquid_renewable = false,
      liquid_range = 2,
      post_effect_color = {a=220, r=50, g=40, b=70},
      groups = {water = 1, swamp_water = 1, liquid = 1},
      sounds = rp_sounds.node_sound_water_defaults(),
})
