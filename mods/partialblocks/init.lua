
--
-- Partial blocks mod
-- By Kaadmy, for Pixture
--
local S = minetest.get_translator("partialblocks")

partialblocks = {}

function partialblocks.register_material(name, desc_slab, desc_stair, node, is_fuel)
   local nodedef = minetest.registered_nodes[node]

   if nodedef == nil then
      minetest.log("warning", "Cannot find node for partialblock: " .. node)

      return
   end

   -- Slab

   minetest.register_node(
      "partialblocks:slab_" .. name,
      {
	 tiles = nodedef.tiles,
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

   minetest.register_node(
      "partialblocks:stair_" .. name,
      {
	 tiles = nodedef.tiles,
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
   "frame", S("Frame Slab"), S("Frame Stair"), "default:frame", true)

partialblocks.register_material(
   "reinforced_frame", S("Reinforced Frame Slab"), S("Reinforced Frame Stair"), "default:reinforced_frame", true)

partialblocks.register_material(
   "reinforced_cobble", S("Reinforced Cobble Slab"), S("Reinforced Cobble Stair"), "default:reinforced_cobble", false)

-- Misc. blocks

partialblocks.register_material(
   "coal", S("Coal Slab"), S("Coal Stair"), "default:block_coal", false)

partialblocks.register_material(
   "steel", S("Steel Slab"), S("Steel Stair"), "default:block_steel", false)

partialblocks.register_material(
   "compressed_sandstone", S("Compressed Sandstone Slab"), S("Compressed Sandstone Stair"), "default:compressed_sandstone", false)

default.log("mod:partialblocks", "loaded")
