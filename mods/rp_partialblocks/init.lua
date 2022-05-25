
--
-- Partial blocks mod
--
local S = minetest.get_translator("rp_partialblocks")

partialblocks = {}

function partialblocks.register_material(name, desc_slab, desc_stair, node, groups, is_fuel, tiles_slab, tiles_stair)
   local nodedef = minetest.registered_nodes[node]

   if nodedef == nil then
      minetest.log("warning", "[rp_partialblocks] Cannot find node for partialblock: " .. node)

      return
   end

   -- Slab
   local tiles
   if tiles_slab then
      tiles = tiles_slab
   else
      tiles = nodedef.tiles
   end
   local groups_slab
   if not groups then
      groups_slab = table.copy(nodedef.groups)
   else
      groups_slab = table.copy(groups)
   end
   groups_slab.slab = 1

   minetest.register_node(
      "rp_partialblocks:slab_" .. name,
      {
	 tiles = tiles,
	 groups = groups_slab,
	 sounds = nodedef.sounds,

	 description = desc_slab,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	 },

	 paramtype = "light",
	 is_ground_content = nodedef.is_ground_content,

         on_place = function(itemstack, placer, pointed_thing)
            -- Slab on slab placement creates full block
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
               minetest.set_node(pos, {name = node})

	       if not minetest.is_creative_enabled(placer:get_player_name()) then
                   itemstack:take_item()
               end

            else
               itemstack = minetest.item_place(itemstack, placer, pointed_thing)
            end
            return itemstack
         end,
   })

   crafting.register_craft( -- Craft to slab
      {
	 output = "rp_partialblocks:slab_" .. name .. " 2",
	 items = {
	    node,
	 },
   })

   local full_node_burntime
   local output = minetest.get_craft_result({
      method = "fuel",
      width = 1,
      items = {node},
   })
   full_node_burntime = output.time

   if is_fuel then
      local burntime
      if full_node_burntime > 0 then
	      -- Burntime is 50% of the origin node (if a fuel recipe was available)
	      burntime = math.max(1, math.floor(output.time * 0.5))
      else
	      -- Fallback burntime
	      burntime = 7
      end
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "rp_partialblocks:slab_" .. name,
	    burntime = burntime,
      })
   end

   -- Stair

   local tiles
   if tiles_stair then
      tiles = tiles_stair
   else
      tiles = nodedef.tiles
   end

   local groups_stair
   if not groups then
      groups_stair = table.copy(nodedef.groups)
   else
      groups_stair = table.copy(groups)
   end
   groups_stair.stair = 1

   minetest.register_node(
      "rp_partialblocks:stair_" .. name,
      {
	 tiles = tiles,
	 groups = groups_stair,
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
	 is_ground_content = nodedef.is_ground_content,
   })

   crafting.register_craft( -- Craft to stair
      {
	 output = "rp_partialblocks:stair_" .. name,
	 items = {
            node,
	 },
   })

   if is_fuel then
      local burntime
      if full_node_burntime > 0 then
	      -- Burntime is 75% of the origin node (if a fuel recipe was available)
	      burntime = math.max(1, math.floor(output.time * 0.75))
      else
	      -- Fallback burntime
	      burntime = 7
      end
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "rp_partialblocks:stair_" .. name,
	    burntime = burntime,
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
   "cobble", S("Cobble Slab"), S("Cobble Stair"), "rp_default:cobble", {cracky=3}, false)

partialblocks.register_material(
   "stone", S("Stone Slab"), S("Stone Stair"), "rp_default:stone", {cracky=2}, false)

partialblocks.register_material(
   "sandstone", S("Sandstone Slab"), S("Sandstone Stair"), "rp_default:sandstone", {cracky=3}, false)

partialblocks.register_material(
   "brick", S("Brick Slab"), S("Brick Stair"), "rp_default:brick", {cracky=2}, false)

-- Woodlike

partialblocks.register_material(
   "wood", S("Wooden Slab"), S("Wooden Stair"), "rp_default:planks", {snappy = 3, choppy = 3, oddly_breakable_by_hand = 3}, true)

partialblocks.register_material(
   "oak", S("Oak Slab"), S("Oak Stair"), "rp_default:planks_oak", {snappy = 3, choppy = 3, oddly_breakable_by_hand = 3}, true)

partialblocks.register_material(
   "birch", S("Birch Slab"), S("Birch Stair"), "rp_default:planks_birch", {snappy = 3, choppy = 3, oddly_breakable_by_hand = 3}, true)

partialblocks.register_material(
   "reed", S("Reed Slab"), S("Reed Stair"), "rp_default:reed_block", {snappy = 2, fall_damage_add_percent=-10}, true)

partialblocks.register_material(
   "dried_reed", S("Dried Reed Slab"), S("Dried Reed Stair"), "rp_default:dried_reed_block", {snappy = 2, fall_damage_add_percent=-15}, true)

-- Frames

partialblocks.register_material(
   "frame", S("Frame Slab"), S("Frame Stair"), "rp_default:frame", {choppy = 2, oddly_breakable_by_hand = 1}, true, adv_slab_tex("rp_default:frame", "frame"), adv_stair_tex("rp_default:frame", "frame"))

partialblocks.register_material(
   "reinforced_frame", S("Reinforced Frame Slab"), S("Reinforced Frame Stair"), "rp_default:reinforced_frame", {choppy = 1}, true, adv_slab_tex("rp_default:reinforced_frame", "reinforced_frame"), adv_stair_tex("rp_default:reinforced_frame", "reinforced_frame"))

partialblocks.register_material(
   "reinforced_cobble", S("Reinforced Cobble Slab"), S("Reinforced Cobble Stair"), "rp_default:reinforced_cobble", {cracky = 1}, false, adv_slab_tex("rp_default:reinforced_cobble", "reinforced_cobbles"), adv_stair_tex("rp_default:reinforced_cobble", "reinforced_cobbles"))

-- Misc. blocks

partialblocks.register_material(
   "coal", S("Coal Slab"), S("Coal Stair"), "rp_default:block_coal", { cracky = 3 }, true, adv_slab_tex("rp_default:block_coal", "block_coal"), adv_stair_tex("rp_default:block_coal", "block_coal"))

partialblocks.register_material(
   "steel", S("Steel Slab"), S("Steel Stair"), "rp_default:block_steel", { cracky = 2 }, false, adv_slab_tex("rp_default:block_steel", "block_steel"), adv_stair_tex("rp_default:block_steel", "block_steel"))

partialblocks.register_material(
   "carbon_steel", S("Carbon Steel Slab"), S("Carbon Steel Stair"), "rp_default:block_carbon_steel", { cracky = 1 }, false, adv_slab_tex("rp_default:block_carbon_steel", "block_carbon_steel"), adv_stair_tex("rp_default:block_carbon_steel", "block_carbon_steel"))

partialblocks.register_material(
   "wrought_iron", S("Wrought Iron Slab"), S("Wrought Iron Stair"), "rp_default:block_wrought_iron", { cracky = 2, magnetic = 1 }, false, adv_slab_tex("rp_default:block_wrought_iron", "block_wrought_iron"), adv_stair_tex("rp_default:block_wrought_iron", "block_wrought_iron"))

partialblocks.register_material(
   "bronze", S("Bronze Slab"), S("Bronze Stair"), "rp_default:block_bronze", { cracky = 1 }, false, adv_slab_tex("rp_default:block_bronze", "block_bronze"), adv_stair_tex("rp_default:block_bronze", "block_bronze"))

partialblocks.register_material(
   "copper", S("Copper Slab"), S("Copper Stair"), "rp_default:block_copper", { cracky = 2 }, false, adv_slab_tex("rp_default:block_copper", "block_copper"), adv_stair_tex("rp_default:block_copper", "block_copper"))

partialblocks.register_material(
   "tin", S("Tin Slab"), S("Tin Stair"), "rp_default:block_tin", { cracky = 2 }, false, adv_slab_tex("rp_default:block_tin", "block_tin"), adv_stair_tex("rp_default:block_tin", "block_tin"))

partialblocks.register_material(
   "gold", S("Gold Slab"), S("Gold Stair"), "rp_gold:block_gold", { cracky = 2 }, false, adv_slab_tex("rp_gold:block_gold", "block_gold"), adv_stair_tex("rp_gold:block_gold", "block_gold"))

-- Recipes to craft metal and coal stairs/slabs back to ingots/lumps
-- at a small loss.
local mats = {
	{ "rp_default:lump_coal", "coal" },
	{ "rp_default:ingot_steel", "steel" },
	{ "rp_default:ingot_carbon_steel", "carbon_steel" },
	{ "rp_default:ingot_bronze", "bronze" },
	{ "rp_default:ingot_copper", "copper" },
	{ "rp_default:ingot_tin", "tin" },
	{ "rp_default:ingot_wrought_iron", "wrought_iron" },
	{ "rp_gold:ingot_gold", "gold" },
}
for m=1, #mats do
	local mat = mats[m]
	crafting.register_craft({
		output = mat[1] .." 4",
		items = { "rp_partialblocks:slab_" .. mat[2] },
	})
	crafting.register_craft({
		output = mat[1] .. " 6",
		items = { "rp_partialblocks:stair_" .. mat[2] },
	})
end

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_partialblocks:slab_dried_reed",
      recipe = "rp_partialblocks:slab_reed",
      cooktime = 5,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_partialblocks:stair_dried_reed",
      recipe = "rp_partialblocks:stair_reed",
      cooktime = 8,
})


local cs_stair_tiles = {
	"default_compressed_sandstone.png",
	"default_compressed_sandstone_top.png",
	"partialblocks_compressed_sandstone_stair.png^[transformFX",
	"partialblocks_compressed_sandstone_stair.png",
	"default_compressed_sandstone.png",
	"default_compressed_sandstone.png" }
partialblocks.register_material(
   "compressed_sandstone", S("Compressed Sandstone Slab"), S("Compressed Sandstone Stair"), "rp_default:compressed_sandstone", { cracky = 2 }, false, nil, cs_stair_tiles)

dofile(minetest.get_modpath("rp_partialblocks").."/aliases.lua")
