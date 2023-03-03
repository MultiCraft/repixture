local S = minetest.get_translator("rp_default")

-- Saplings

local snd_sapling = rp_sounds.node_sound_grass_defaults()

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
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = snd_sapling,

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
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      sounds = snd_sapling,

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
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = snd_sapling,

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
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      selection_box = {
	 type = "fixed",
	 fixed = {-4/16, -0.5, -4/16, 4/16, 3/16, 4/16},
      },
      groups = {snappy = 2, handy = 1, attached_node = 1, plant = 1, sapling = 1},
      is_ground_content = false,
      sounds = snd_sapling,

      on_timer = function(pos)
         default.grow_sapling(pos)
      end,

      on_construct = function(pos)
         default.begin_growing_sapling(pos)
      end,

      on_place = default.place_sapling,
})

local snd_tree = rp_sounds.node_sound_wood_defaults({
   footstep = { name = "rp_sounds_footstep_wood", gain = 0.7, pitch = 0.8 },
})

-- Trees

minetest.register_node(
   "rp_default:tree",
   {
      description = S("Tree"),
      tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
      groups = {choppy = 2,tree = 1,oddly_breakable_by_hand = 1},
      sounds = snd_tree,
})

minetest.register_node(
   "rp_default:tree_oak",
   {
      description = S("Oak Tree"),
      tiles = {"default_tree_oak_top.png", "default_tree_oak_top.png", "default_tree_oak.png"},
      groups = {choppy = 2, tree = 1, oddly_breakable_by_hand = 1},
      sounds = snd_tree,
})

minetest.register_node(
   "rp_default:tree_birch",
   {
      description = S("Birch Tree"),
      tiles = {"default_tree_birch_top.png", "default_tree_birch_top.png", "default_tree_birch.png"},
      groups = {choppy = 2, tree = 1, oddly_breakable_by_hand = 1},
      sounds = snd_tree,
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
      _rp_hunger_food = 2,
      _rp_hunger_sat = 10,
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
      on_flood = function(pos)
         minetest.add_item(pos, "rp_default:apple")
      end,
      groups = {snappy = 3, handy = 2, leafdecay = 3, leafdecay_drop = 1, food = 2},
      on_use = minetest.item_eat(0),
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
      on_flood = function(pos)
         minetest.add_item(pos, "rp_default:apple")
      end,
      groups = {snappy = 3, handy = 3},
      sounds = rp_sounds.node_sound_defaults(),
      drop = "rp_default:apple",
})


local sounds_acorn = rp_sounds.node_sound_defaults({
   place = {name = "rp_default_place_nut", gain = 0.5 },
   dug = {name = "rp_default_dug_nut", gain = 0.4 },
   footstep = {},
})

minetest.register_node(
   "rp_default:acorn",
   {
      description = S("Acorn"),
      _rp_hunger_food = 1,
      _rp_hunger_sat = 5,
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
      on_flood = function(pos)
         minetest.add_item(pos, "rp_default:acorn")
      end,
      groups = {snappy = 3, handy = 3, leafdecay = 3, leafdecay_drop = 1, food = 2},
      on_use = minetest.item_eat(0),
      on_place = create_on_place_fruit_function("rp_default:acorn"),
      sounds = sounds_acorn,
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
      on_flood = function(pos)
         minetest.add_item(pos, "rp_default:acorn")
      end,
      groups = {snappy = 3, handy = 3},
      sounds = sounds_acorn,
      drop = "rp_default:acorn",
})

