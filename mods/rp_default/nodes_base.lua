
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
      groups = {cracky = 2, stone = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:lump_sulfur",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:stone_with_graphite",
   {
      description = S("Stone with Graphite"),
      tiles = {"default_stone.png^default_mineral_graphite.png"},
      groups = {cracky = 2, stone = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:sheet_graphite",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:stone_with_coal",
   {
      description = S("Stone with Coal"),
      tiles = {"default_stone.png^default_mineral_coal.png"},
      groups = {cracky = 2, stone = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:lump_coal",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:stone_with_iron",
   {
      description = S("Stone with Iron"),
      tiles = {"default_stone.png^default_mineral_iron.png"},
      groups = {cracky = 2, stone = 1, magnetic = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:lump_iron",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:stone_with_tin",
   {
      description = S("Stone with Tin"),
      tiles = {"default_stone.png^default_mineral_tin.png"},
      groups = {cracky = 1, stone = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:lump_tin",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:stone_with_copper",
   {
      description = S("Stone with Copper"),
      tiles = {"default_stone.png^default_mineral_copper.png"},
      groups = {cracky = 1, stone = 1, ore = 1, pathfinder_hard = 1},
      drop = "rp_default:lump_copper",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

-- Stonelike

minetest.register_node(
   "rp_default:stone",
   {
      description = S("Stone"),
      tiles = {"default_stone.png"},
      groups = {cracky = 2, stone = 1, pathfinder_hard = 1},
      drop = "rp_default:cobble",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:cobble",
   {
      description = S("Cobble"),
      tiles = {"default_cobbles.png"},
      stack_max = 240,
      groups = {cracky = 3, stone = 1, pathfinder_hard = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      is_ground_content = false,
      _rp_blast_resistance = 2,
})

minetest.register_node(
   "rp_default:reinforced_cobble",
   {
      description = S("Reinforced Cobble"),
      tiles = {"default_reinforced_cobbles.png"},
      is_ground_content = false,
      groups = {cracky = 1, stone = 1, pathfinder_hard = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 6,
})

minetest.register_node(
   "rp_default:gravel",
   {
      description = S("Gravel"),
      tiles = {"default_gravel.png"},
      groups = {crumbly = 2, falling_node = 1, gravel = 1, pathfinder_spiky = 1},
      sounds = rp_sounds.node_sound_gravel_defaults(),
})

-- Material blocks

minetest.register_node(
   "rp_default:block_coal",
   {
      description = S("Coal Block"),
      tiles = {"default_block_coal.png"},
      groups = {cracky = 3, pathfinder_spiky = 1},
      sounds = rp_sounds.node_sound_coal_defaults(),
      _rp_blast_resistance = 1,
})

local make_metal_sounds = function(pitch)
	local sounds = rp_sounds.node_sound_metal_defaults()
	if sounds.footstep then
		sounds.footstep.pitch = pitch
	end
	if sounds.dig then
		sounds.dig.pitch = pitch
	end
	if sounds.dug then
		sounds.dug.pitch = pitch
	end
	if sounds.place then
		sounds.place.pitch = pitch
	end
	return sounds
end

minetest.register_node(
   "rp_default:block_wrought_iron",
   {
      description = S("Wrought Iron Block"),
      tiles = {"default_block_wrought_iron.png"},
      groups = {cracky = 2, magnetic = 1, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_WROUGHT_IRON),
      is_ground_content = false,
      _rp_blast_resistance = 8,
})

minetest.register_node(
   "rp_default:block_steel",
   {
      description = S("Steel Block"),
      tiles = {"default_block_steel.png"},
      groups = {cracky = 2, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_STEEL),
      is_ground_content = false,
      _rp_blast_resistance = 9,
})

minetest.register_node(
   "rp_default:block_carbon_steel",
   {
      description = S("Carbon Steel Block"),
      tiles = {"default_block_carbon_steel.png"},
      groups = {cracky = 1, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_CARBON_STEEL),
      is_ground_content = false,
      _rp_blast_resistance = 9.25,
})

minetest.register_node(
   "rp_default:block_bronze",
   {
      description = S("Bronze Block"),
      tiles = {"default_block_bronze.png"},
      groups = {cracky = 1, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_BRONZE),
      is_ground_content = false,
      _rp_blast_resistance = 9.5,
})

minetest.register_node(
   "rp_default:block_copper",
   {
      description = S("Copper Block"),
      tiles = {"default_block_copper.png"},
      groups = {cracky = 2, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_COPPER),
      is_ground_content = false,
      _rp_blast_resistance = 7,
})

minetest.register_node(
   "rp_default:block_tin",
   {
      description = S("Tin Block"),
      tiles = {"default_block_tin.png"},
      groups = {cracky = 2, pathfinder_hard = 1},
      sounds = make_metal_sounds(default.METAL_PITCH_TIN),
      is_ground_content = false,
      _rp_blast_resistance = 8.5,
})

-- Soil

minetest.register_node(
   "rp_default:dirt",
   {
      description = S("Dirt"),
      tiles = {"default_dirt.png"},
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, fall_damage_add_percent = -5, pathfinder_crumbly = 1},
      sounds = rp_sounds.node_sound_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_dirt",

      _on_grow = function(pos, node, grower)
         local above = vector.offset(pos, 0, 1, 0)
         local anode = minetest.get_node(above)
         if anode.name == "air" then
            local growername = grower and grower:get_player_name()
            if growername and minetest.is_protected(above, growername) and not minetest.check_player_privs(grower, "protection_bypass") then
               minetest.record_protection_violation(above, growername)
               return false
            end
         end

         local biomedata = minetest.get_biome_data(pos)
         local biome = minetest.get_biome_name(biomedata.biome)
         if default.is_dry_biome(biome) then
            minetest.set_node(pos, {name="rp_default:dirt_with_dry_grass"})
         else
            minetest.set_node(pos, {name="rp_default:dirt_with_grass"})
         end
      end,
})

minetest.register_node(
   "rp_default:dry_dirt",
   {
      description = S("Dry Dirt"),
      tiles = { "default_dry_dirt.png" },
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, dry_dirt = 1, plantable_dry = 1, fall_damage_add_percent = -10, pathfinder_crumbly = 1},
      sounds = rp_sounds.node_sound_dry_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_dry_dirt",
})

minetest.register_node(
   "rp_default:swamp_dirt",
   {
      description = S("Swamp Dirt"),
      tiles = { "default_swamp_dirt.png" },
      stack_max = 240,
      groups = {crumbly = 3, soil = 1, dirt = 1, swamp_dirt = 1, plantable_wet = 1, fall_damage_add_percent = -10, pathfinder_crumbly = 1},
      sounds = rp_sounds.node_sound_swamp_dirt_defaults(),
      _fertilized_node = "rp_default:fertilized_swamp_dirt",

      _on_grow = function(pos)
         minetest.set_node(pos, {name="rp_default:dirt_with_swamp_grass"})
      end,
})

local function grow_grass_on_dirt(newnode)
   return function(pos, node, grower)
      local above = vector.offset(pos, 0, 1, 0)
      local anode = minetest.get_node(above)
      if anode.name == "air" then
         local growername = grower and grower:get_player_name()
         if growername and minetest.is_protected(above, growername) and not minetest.check_player_privs(grower, "protection_bypass") then
            minetest.record_protection_violation(above, growername)
            return false
         end
         minetest.set_node(above, newnode)
      else
         return false
      end
   end
end

minetest.register_node(
   "rp_default:dirt_with_dry_grass",
   {
      description = S("Dirt with Dry Grass"),
      tiles = {
	 { name = "rp_default_dry_grass_4x4.png", align_style = "world", scale = 4 },
	 "default_dirt.png",
         "default_dirt.png^default_dry_grass_side.png"
      },
      groups = {crumbly = 3, soil = 1, dirt = 1, normal_dirt = 1, plantable_soil = 1, grass_cover = 1, pathfinder_fibrous = 1,
                fall_damage_add_percent = -5},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:dirt"}, rarity = 1},
	    {items = {"rp_default:dry_grass 4"}, rarity = 12},
	    {items = {"rp_default:dry_grass 2"}, rarity = 6},
	    {items = {"rp_default:dry_grass 1"}, rarity = 2},
	 }
      },
      sounds = rp_sounds.node_sound_dirt_defaults({
         footstep = { name = "rp_sounds_footstep_grass", gain = 1.0 },
      }),
      _fertilized_node = "rp_default:fertilized_dirt",
      _on_grow = grow_grass_on_dirt({name="rp_default:dry_grass"}),
      _on_degrow = function(pos)
         minetest.set_node(pos, {name="rp_default:dirt"})
      end,
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
                fall_damage_add_percent = -10, pathfinder_fibrous = 1},
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:swamp_dirt"}, rarity = 1},
	    {items = {"rp_default:swamp_grass 6"}, rarity = 14},
	    {items = {"rp_default:swamp_grass 3"}, rarity = 7},
	    {items = {"rp_default:swamp_grass 2"}, rarity = 3},
	 }
      },
      sounds = rp_sounds.node_sound_swamp_dirt_defaults({
         footstep = { name = "rp_sounds_footstep_swamp_grass", gain = 1.0 },
      }),
      _fertilized_node = "rp_default:fertilized_swamp_dirt",
      _on_grow = grow_grass_on_dirt({name="rp_default:swamp_grass"}),
      _on_degrow = function(pos)
         minetest.set_node(pos, {name="rp_default:swamp_dirt"})
      end,
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
                fall_damage_add_percent = -5, pathfinder_fibrous = 1},
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
      sounds = rp_sounds.node_sound_dirt_defaults({
         footstep = { name = "rp_sounds_footstep_grass", gain = 1.0 },
      }),
      _fertilized_node = "rp_default:fertilized_dirt",
      _on_grow = grow_grass_on_dirt({name="rp_default:grass"}),
      _on_degrow = function(pos)
         minetest.set_node(pos, {name="rp_default:dirt"})
      end,
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
      groups = {crumbly = 3, path = 1, fall_damage_add_percent = -10, pathfinder_crumbly = 1},
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
      groups = {crumbly = 3, level = -1, path = 2, slab = 2, creative_decoblock = 1, fall_damage_add_percent = -10, pathfinder_crumbly = 1},
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
      groups = {crumbly = 3, path = 1, creative_decoblock = 1, fall_damage_add_percent = -10, pathfinder_crumbly = 1},
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
      groups = {cracky = 2, paintable = 2, pathfinder_hard = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 2,
})
minetest.register_node(
   "rp_default:brick_painted",
   {
      description = S("Painted Brick Block"),
      tiles = {{name="rp_default_brick_paintable.png"}},
      overlay_tiles = {{name="rp_default_brick_paintable_overlay.png",color="white"}},
      use_texture_alpha = "blend",
      is_ground_content = false,
      groups = {cracky = 2, paintable = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, pathfinder_hard = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      paramtype2 = "color",
      palette = "rp_paint_palette_256.png",
      drop = "rp_default:brick",
      _rp_blast_resistance = 2,
})

-- Sand

minetest.register_node(
   "rp_default:sand",
   {
      description = S("Sand"),
      tiles = {"default_sand.png"},
      groups = {crumbly = 3, falling_node = 1, sand = 1, plantable_sandy = 1, fall_damage_add_percent = -10, pathfinder_soft = 1},
      sounds = rp_sounds.node_sound_sand_defaults(),
      _fertilized_node = "rp_default:fertilized_sand",
})

minetest.register_node(
   "rp_default:sandstone",
   {
      description = S("Sandstone"),
      tiles = {"default_sandstone.png"},
      groups = {crumbly = 2, cracky = 3, sandstone = 1, pathfinder_hard = 1},
      drop = "rp_default:sand 2",
      sounds = rp_sounds.node_sound_stone_defaults({
         dug = {name="rp_sounds_dug_stone", gain=0.9, pitch=1.4},
         dig = {name="rp_sounds_dig_stone", gain=0.5, pitch=1.4},
      }),
      _rp_blast_resistance = 0.5,
})

minetest.register_node(
   "rp_default:compressed_sandstone",
   {
      description = S("Compressed Sandstone"),
      tiles = {"default_compressed_sandstone_top.png", "default_compressed_sandstone_top.png", "default_compressed_sandstone.png"},
      groups = {cracky = 2, sandstone = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults({
         dug = {name="rp_sounds_dug_stone", gain=0.9, pitch=1.2},
         dig = {name="rp_sounds_dig_stone", gain=0.5, pitch=1.2},
      }),
      _rp_blast_resistance = 1,
})

minetest.register_node(
   "rp_default:reinforced_compressed_sandstone",
   {
      description = S("Reinforced Compressed Sandstone"),
      tiles = {"rp_default_reinforced_compressed_sandstone.png"},
      groups = {cracky = 2, sandstone = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults({
         dug = {name="rp_sounds_dug_stone", gain=0.9, pitch=1.2},
         dig = {name="rp_sounds_dig_stone", gain=0.5, pitch=1.2},
      }),
      _rp_blast_resistance = 6,
})

-- Glass

minetest.register_node(
   "rp_default:glass",
   {
      description = S("Glass"),
      drawtype = "glasslike_framed_optional",
      tiles = {"default_glass_frame.png", "default_glass.png"},
      use_texture_alpha = "clip",
      paramtype = "light",
      sunlight_propagates = true,
      groups = {cracky = 3,oddly_breakable_by_hand = 2, glass=1, paintable=2, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_glass_defaults(),
      drop = "rp_default:glass",
      _rp_blast_resistance = 0.2,
})
minetest.register_node(
   "rp_default:glass_painted",
   {
      description = S("Painted Glass"),
      drawtype = "glasslike_framed_optional",
      palette = "rp_paint_palette_256.png",
      paramtype2 = "color",
      tiles = {"rp_default_glass_semi.png^default_glass_frame.png", "rp_default_glass_semi.png^default_glass.png"},
      -- HACK: This is a workaround to fix the coloring of the crack overlay
      overlay_tiles = {{name="rp_textures_blank_paintable_overlay.png",color="white"}},
      use_texture_alpha = "blend",
      paramtype = "light",
      sunlight_propagates = true,
      groups = {cracky = 3,oddly_breakable_by_hand = 2, glass=1, paintable=1, not_in_creative_inventory=1, not_in_craft_guide = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_glass_defaults(),
      drop = "rp_default:glass",
      _rp_blast_resistance = 0.2,
})



-- Planks

local planks = {
   { "planks", "default_wood.png", "rp_default_wood_painted.png", S("Wooden Planks"), S("Painted Wooden Planks") },
   { "planks_oak", "default_wood_oak.png", "rp_default_wood_oak_painted.png", S("Oak Planks"), S("Painted Oak Planks") },
   { "planks_birch", "default_wood_birch.png", "rp_default_wood_birch_painted.png", S("Birch Planks"), S("Painted Birch Planks") },
   { "planks_fir", "rp_default_wood_fir.png", "rp_default_wood_fir_painted.png", S("Fir Planks"), S("Painted Fir Planks"), "rp_paint_palette_256l.png" },
}
for p=1, #planks do
   local id = planks[p][1]
   local tex = planks[p][2]
   local tex_paint = planks[p][3]
   local desc = planks[p][4]
   local desc_paint = planks[p][5]
   local palette = planks[p][6] or "rp_paint_palette_256.png"

   minetest.register_node(
      "rp_default:"..id,
      {
         description = desc,
         tiles = {tex},
         groups = {planks = 1, wood = 1, choppy = 3, oddly_breakable_by_hand = 3, paintable = 2, pathfinder_hard = 1},
         is_ground_content = false,
         sounds = rp_sounds.node_sound_planks_defaults(),
         _rp_blast_resistance = 0.5,
   })
   minetest.register_node(
      "rp_default:"..id.."_painted",
      {
         description = desc_paint,
         tiles = {tex_paint},
         -- HACK: This is a workaround to fix the coloring of the crack overlay
         overlay_tiles = {{name="rp_textures_blank_paintable_overlay.png",color="white"}},
         groups = {planks = 1, wood = 1, choppy = 3, oddly_breakable_by_hand = 3, paintable = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, pathfinder_hard = 1},
         is_ground_content = false,
         sounds = rp_sounds.node_sound_planks_defaults(),

         palette = palette,
         drop = "rp_default:"..id,
         paramtype2 = "color",
         _rp_blast_resistance = 0.5,
   })
end

-- Frames

minetest.register_node(
   "rp_default:frame",
   {
      description = S("Frame"),
      tiles = {"default_frame.png"},
      groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, paintable = 2, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      _rp_blast_resistance = 0.75,
})
minetest.register_node(
   "rp_default:frame_painted",
   {
      description = S("Painted Frame"),
      tiles = {"rp_default_frame_painted.png"},
      -- HACK: This is a workaround to fix the coloring of the crack overlay
      overlay_tiles = {{name="rp_textures_blank_paintable_overlay.png",color="white"}},
      paramtype2 = "color",
      palette = "rp_paint_palette_256.png",
      groups = {wood = 1, choppy = 2, oddly_breakable_by_hand = 1, paintable = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      drop = "rp_default:frame",
      _rp_blast_resistance = 0.75,
})

minetest.register_node(
   "rp_default:reinforced_frame",
   {
      description = S("Reinforced Frame"),
      tiles = {"default_reinforced_frame.png"},
      groups = {wood = 1, choppy = 1, paintable = 2, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      _rp_blast_resistance = 5,
})
minetest.register_node(
   "rp_default:reinforced_frame_painted",
   {
      description = S("Painted Reinforced Frame"),
      tiles = {"rp_default_reinforced_frame_painted.png"},
      overlay_tiles = {{name="rp_default_reinforced_frame_overlay.png",color="white"}},
      paramtype2 = "color",
      palette = "rp_paint_palette_256.png",
      groups = {wood = 1, choppy = 1, paintable = 1, not_in_creative_inventory = 1, not_in_craft_guide = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      drop = "rp_default:reinforced_frame",
      _rp_blast_resistance = 5,
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
      groups = {snappy=2, fall_damage_add_percent=-10, pathfinder_fibrous=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_grass_defaults(),
      _rp_blast_resistance = 0.5,
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
      groups = {snappy=2, fall_damage_add_percent=-15, pathfinder_fibrous=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_straw_defaults(),
      _rp_blast_resistance = 0.5,
})

-- Hay
minetest.register_node(
   "rp_default:hay",
   {
      description = S("Hay"),
      tiles = {
	     "rp_default_hay.png",
      },
      groups = {snappy=3, fall_damage_add_percent=-30, pathfinder_fibrous= 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_grass_defaults({
         footstep = { name = "rp_default_footstep_hay", gain = 1.0 },
         place = { name = "rp_default_place_hay", gain = 1.0 },
         dig = { name = "rp_default_dig_hay", gain = 0.5 },
         dug = { name = "rp_default_dig_hay", gain = 1.0, pitch = 0.8 },
      }),
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
      floodable = true,
      on_flood = function(pos, oldnode)
         minetest.add_item(pos, "rp_default:rope")
         util.dig_down(pos, oldnode, nil, "rp_default:rope")
      end,
      after_dig_node = function(pos, node, metadata, digger)
         util.dig_down(pos, node, digger)
      end,

})

