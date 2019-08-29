
--
-- Partial blocks mod
-- By Kaadmy, for Pixture
--
local S = minetest.get_translator("partialblocks")

partialblocks = {}

function partialblocks.register_material(name, desc_slab, desc_stair, node, is_fuel, tiles_slab, tiles_stair)
   local nodedef = minetest.registered_nodes[node]

   if nodedef == nil then
      minetest.log("warning", "Cannot find node for partialblock: " .. node)

      return
   end

   -- Slab
   local tiles
   if tiles_slab then
      tiles = tiles_slab
   else
      tiles = nodedef.tiles
   end

   minetest.register_node(
      "partialblocks:slab_" .. name,
      {
	 tiles = tiles,
	 groups = nodedef.groups,
	 sounds = nodedef.sounds,

	 description = desc_slab,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	 },

	 paramtype = "light",

         on_rightclick = function(pos, _, _, itemstack, _)
            if minetest.get_node(pos).name == itemstack:get_name()
            and itemstack:get_count() >= 1 then
               minetest.set_node(pos, {name = node})

               itemstack:take_item()

               return itemstack
            end
         end,
   })

   crafting.register_craft( -- Craft to
      {
	 output = "partialblocks:slab_" .. name,
	 items = {
	    node,
	 },
   })

   if is_fuel then
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "partialblocks:slab_" .. name,
	    burntime = 7,
      })
   end

   -- Stair

   local tiles
   if tiles_stair then
      tiles = tiles_stair
   else
      tiles = nodedef.tiles
   end

   minetest.register_node(
      "partialblocks:stair_" .. name,
      {
	 tiles = tiles,
	 groups = nodedef.groups,
	 sounds = nodedef.sounds,

	 description = desc_stair,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {
	       {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	       {-0.5, 0, 0, 0.5, 0.5, 0.5},
	    },
	 },

	 paramtype = "light",
	 paramtype2 = "facedir",
   })

   crafting.register_craft( -- Craft to
      {
	 output = "partialblocks:stair_" .. name,
	 items = {
            node,
	 },
   })

   if is_fuel then
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "partialblocks:stair_" .. name,
	    burntime = 7,
      })
   end
end

local adv_slab_tex = function(name, texname)
	local t1 = minetest.registered_nodes[name].tiles[1]
	local t2 = "partialblocks_"..texname.."_slab.png"
	return { t1, t1, t2 }
end
local adv_stair_tex = function(name, texname)
	local t1 = minetest.registered_nodes[name].tiles[1]
	local t2 = "partialblocks_"..texname.."_stair.png"
	local t3 = "partialblocks_"..texname.."_slab.png"
	return { t3, t1, t2.."^[transformFX", t2, t1, t3 }
end

-- Stonelike materials

partialblocks.register_material(
   "cobble", S("Cobble Slab"), S("Cobble Stair"), "default:cobble", false)

partialblocks.register_material(
   "stone", S("Stone Slab"), S("Stone Stair"), "default:stone", false)

partialblocks.register_material(
   "brick", S("Brick Slab"), S("Brick Stair"), "default:brick", false)

-- Woodlike

partialblocks.register_material(
   "wood", S("Wooden Slab"), S("Wooden Stair"), "default:planks", true)

partialblocks.register_material(
   "oak", S("Oak Slab"), S("Oak Stair"), "default:planks_oak", true)

partialblocks.register_material(
   "birch", S("Birch Slab"), S("Birch Stair"), "default:planks_birch", true)

-- Frames

partialblocks.register_material(
   "frame", S("Frame Slab"), S("Frame Stair"), "default:frame", true, adv_slab_tex("default:frame", "frame"), adv_stair_tex("default:frame", "frame"))

partialblocks.register_material(
   "reinforced_frame", S("Reinforced Frame Slab"), S("Reinforced Frame Stair"), "default:reinforced_frame", true, adv_slab_tex("default:reinforced_frame", "reinforced_frame"), adv_stair_tex("default:reinforced_frame", "reinforced_frame"))

partialblocks.register_material(
   "reinforced_cobble", S("Reinforced Cobble Slab"), S("Reinforced Cobble Stair"), "default:reinforced_cobble", false, adv_slab_tex("default:reinforced_cobble", "reinforced_cobbles"), adv_stair_tex("default:reinforced_cobble", "reinforced_cobbles"))

-- Misc. blocks

partialblocks.register_material(
   "coal", S("Coal Slab"), S("Coal Stair"), "default:block_coal", false, adv_slab_tex("default:block_coal", "block_coal"), adv_stair_tex("default:block_coal", "block_coal"))

partialblocks.register_material(
   "steel", S("Steel Slab"), S("Steel Stair"), "default:block_steel", false, adv_slab_tex("default:block_steel", "block_steel"), adv_stair_tex("default:block_steel", "block_steel"))

local cs_stair_tiles = {
	"default_compressed_sandstone.png",
	"default_compressed_sandstone_top.png",
	"partialblocks_compressed_sandstone_stair.png^[transformFX",
	"partialblocks_compressed_sandstone_stair.png",
	"default_compressed_sandstone.png",
	"default_compressed_sandstone.png" }
partialblocks.register_material(
   "compressed_sandstone", S("Compressed Sandstone Slab"), S("Compressed Sandstone Stair"), "default:compressed_sandstone", false, nil, cs_stair_tiles)

default.log("mod:partialblocks", "loaded")
