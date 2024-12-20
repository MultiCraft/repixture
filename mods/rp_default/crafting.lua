--
-- Crafting/creation
--

-- Cooking

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:torch_weak",
      recipe = "rp_default:torch_dead",
      cooktime = 1,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:torch",
      recipe = "rp_default:torch_weak",
      cooktime = 4,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:glass",
      recipe = "rp_default:sand",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_coal",
      recipe = "group:tree",
      cooktime = 4,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:stone",
      recipe = "rp_default:cobble",
      cooktime = 6,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:dried_reed_block",
      recipe = "rp_default:reed_block",
      cooktime = 10,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_copper",
      recipe = "rp_default:stone_with_copper",
      cooktime = 6,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_sulfur",
      recipe = "rp_default:stone_with_sulfur",
      cooktime = 6,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_coal",
      recipe = "rp_default:stone_with_coal",
      cooktime = 6,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_iron",
      recipe = "rp_default:stone_with_iron",
      cooktime = 6,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:lump_tin",
      recipe = "rp_default:stone_with_tin",
      cooktime = 6,
})
minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:sheet_graphite",
      recipe = "rp_default:stone_with_graphite",
      cooktime = 6,
})


-- Metal smelting

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_wrought_iron",
      recipe = "rp_default:lump_iron",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_tin",
      recipe = "rp_default:lump_tin",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_copper",
      recipe = "rp_default:lump_copper",
      cooktime = 3,
})

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_default:ingot_bronze",
      recipe = "rp_default:lump_bronze",
      cooktime = 6,
})

-- Fuels

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:stick",
      burntime = 1,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:leaves",
      burntime = 1,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:dry_grass",
      burntime = 1,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:fern",
      burntime = 2,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:hay",
      burntime = 3,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:papyrus",
      burntime = 2,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:reed_block",
      burntime = 10,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:dried_reed_block",
      burntime = 12,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:ladder",
      burntime = 5,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:rope",
      burntime = 5,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:planks",
      burntime = 9,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:bucket",
      burntime = 8,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:pick_wood",
      burntime = 15,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:spear_wood",
      burntime = 12,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:axe_wood",
      burntime = 15,
})
minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:shovel_wood",
      burntime = 12,
})







minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:torch",
      burntime = 7,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:sapling",
      burntime = 4,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:cactus",
      burntime = 10,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:fence",
      burntime = 8,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:frame",
      burntime = 13,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:reinforced_frame",
      burntime = 17,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "group:tree",
      burntime = 20,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:chest",
      burntime = 25,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:lump_coal",
      burntime = 30,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:block_coal",
      burntime = 270,
})

--
-- Recipes
--

-- Autogenerated tools

local tool_types = {
   pick = {
      wood = "group:planks 3",
      stone = "group:stone 3",
      wrought_iron = "rp_default:ingot_wrought_iron 3",
      steel = "rp_default:ingot_steel 3",
      carbon_steel = "rp_default:ingot_carbon_steel 3",
      bronze = "rp_default:ingot_bronze 3",
   },
   shovel = {
      wood = "group:planks 3",
      stone = "group:stone 3",
      wrought_iron = "rp_default:ingot_wrought_iron 3",
      steel = "rp_default:ingot_steel 3",
      carbon_steel = "rp_default:ingot_carbon_steel 3",
      bronze = "rp_default:ingot_bronze 3",
   },
   axe= {
      wood = "group:planks 3",
      stone = "group:stone 3",
      wrought_iron = "rp_default:ingot_wrought_iron 3",
      steel = "rp_default:ingot_steel 3",
      carbon_steel = "rp_default:ingot_carbon_steel 3",
      bronze = "rp_default:ingot_bronze 3",
   },
   spear = {
      wood = "group:planks 2",
      stone = "group:stone 2",
      wrought_iron = "rp_default:ingot_wrought_iron 2",
      steel = "rp_default:ingot_steel 2",
      carbon_steel = "rp_default:ingot_carbon_steel 2",
      bronze = "rp_default:ingot_bronze 2",
   },
}

for tool_name, tool_type in pairs(tool_types) do
   for material_name, material_item in pairs(tool_type) do
      crafting.register_craft(
         {
            output = "rp_default:" .. tool_name .. "_" .. material_name,
            items = {
               material_item,
               "rp_default:fiber 4",
               "rp_default:stick 3",
            }
      })
   end
end

-- Broadsword

crafting.register_craft(
   {
      output = "rp_default:broadsword",
      items = {
         "rp_default:ingot_steel 4",
         "rp_default:fiber 5",
         "rp_default:stick 2",
      }
})

-- Shears

crafting.register_craft(
   {
      output = "rp_default:shears",
      items = {
         "rp_default:ingot_wrought_iron 2",
         "rp_default:fiber 2",
         "rp_default:stick 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:shears_steel",
      items = {
         "rp_default:ingot_steel 2",
         "rp_default:fiber 2",
         "rp_default:stick 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:shears_carbon_steel",
      items = {
         "rp_default:ingot_carbon_steel 2",
         "rp_default:fiber 2",
         "rp_default:stick 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:shears_bronze",
      items = {
         "rp_default:ingot_bronze 2",
         "rp_default:fiber 2",
         "rp_default:stick 2",
      }
})

-- Minerals

crafting.register_craft(
   {
      output = "rp_default:ingot_steel 2",
      items = {
         "rp_default:sheet_graphite",
         "rp_default:ingot_wrought_iron 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:ingot_carbon_steel 2",
      items = {
         "rp_default:sheet_graphite 2",
         "rp_default:ingot_wrought_iron 7",
      }
})

crafting.register_craft(
   {
      output = "rp_default:ingot_bronze 2",
      items = {
         "rp_default:ingot_tin 2",
         "rp_default:ingot_copper 5",
      }
})

-- Items

crafting.register_craft(
   {
      output = "rp_default:rope 2",
      items = {
         "rp_default:dry_grass 3",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fiber 3",
      items = {
         "rp_default:leaves 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fiber",
      items = {
         "group:green_grass",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fiber",
      items = {
         "rp_default:vine 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:stick 4",
      items = {
         "group:planks",
      }
})

crafting.register_craft(
   {
      output = "rp_default:flint 2",
      items = {
         "rp_default:gravel",
      }
})

crafting.register_craft(
   {
      output = "rp_default:paper",
      items = {
         "rp_default:papyrus 3",
      }
})

crafting.register_craft(
   {
      output = "rp_default:reed_block",
      items = {
         "rp_default:swamp_grass 3",
         "rp_default:papyrus 9",
      }
})

crafting.register_craft(
   {
      output = "rp_default:hay",
      items = {
         "rp_default:dry_grass 9",
      }
})

crafting.register_craft(
   {
      output = "rp_default:alga_block",
      items = {
         "rp_default:alga 9",
      }
})

crafting.register_craft(
   {
      output = "rp_default:flint_and_steel",
      items = {
         "rp_default:ingot_steel",
         "rp_default:fiber",
         "rp_default:flint",
      }
})

crafting.register_craft(
   {
      output = "rp_default:bucket",
      items = {
         "rp_default:stick 2",
         "rp_default:fiber 4",
         "group:planks 5",
      }
})

-- Stone nodes

crafting.register_craft(
   {
      output = "rp_default:gravel",
      items = {
         "rp_default:cobble",
      }
})

crafting.register_craft(
   {
      output = "rp_default:brick 2",
      items = {
         "group:soil 5",
         "rp_default:gravel 4",
      }
})

-- Block nodes

crafting.register_craft(
   {
      output = "rp_default:block_wrought_iron",
      items = {
         "rp_default:ingot_wrought_iron 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_wrought_iron 9",
      items = {
         "rp_default:block_wrought_iron",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_steel",
      items = {
         "rp_default:ingot_steel 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_steel 9",
      items = {
         "rp_default:block_steel",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_carbon_steel",
      items = {
         "rp_default:ingot_carbon_steel 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_carbon_steel 9",
      items = {
         "rp_default:block_carbon_steel",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_bronze",
      items = {
         "rp_default:ingot_bronze 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_bronze 9",
      items = {
         "rp_default:block_bronze",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_copper",
      items = {
         "rp_default:ingot_copper 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_copper 9",
      items = {
         "rp_default:block_copper",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_tin",
      items = {
         "rp_default:ingot_tin 9",
      }
})
crafting.register_craft(
   {
      output = "rp_default:ingot_tin 9",
      items = {
         "rp_default:block_tin",
      }
})

crafting.register_craft(
   {
      output = "rp_default:block_coal",
      items = {
         "rp_default:lump_coal 9",
      }
})
crafting.register_craft(
   {
	   output = "rp_default:lump_coal 9",
      items = {
         "rp_default:block_coal",
      }
})

-- Path nodes

crafting.register_craft(
   {
      output = "rp_default:dirt_path",
      items = {
         "rp_default:path_slab 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:dirt_path 8",
      items = {
         "group:soil 3",
         "rp_default:gravel 6",
      }
})

crafting.register_craft(
   {
      output = "rp_default:path_slab 2",
      items = {
         "rp_default:dirt_path",
      }
})

crafting.register_craft(
   {
      output = "rp_default:heated_dirt_path",
      items = {
         "rp_default:dirt_path",
         "rp_default:ingot_wrought_iron",
      }
})

-- Wood nodes

crafting.register_craft(
   {
      output = "rp_default:planks 4",
      items = {
         "rp_default:tree",
      }
})

crafting.register_craft(
   {
      output = "rp_default:planks_oak 4",
      items = {
         "rp_default:tree_oak",
      }
})

crafting.register_craft(
   {
      output = "rp_default:planks_birch 4",
      items = {
         "rp_default:tree_birch",
      }
})

crafting.register_craft(
   {
      output = "rp_default:planks_fir 4",
      items = {
         "rp_default:tree_fir",
      }
})


-- Frame nodes

crafting.register_craft(
   {
      output = "rp_default:frame",
      items = {
         "rp_default:fiber 8",
         "rp_default:stick 6",
         "group:planks",
      }
})

crafting.register_craft(
   {
      output = "rp_default:reinforced_frame",
      items = {
         "rp_default:fiber 8",
         "rp_default:stick 6",
         "rp_default:frame",
      }
})

crafting.register_craft(
   {
      output = "rp_default:reinforced_cobble",
      items = {
         "rp_default:fiber 8",
         "rp_default:stick 6",
         "rp_default:cobble",
      }
})

crafting.register_craft(
   {
      output = "rp_default:reinforced_compressed_sandstone",
      items = {
         "rp_default:fiber 8",
         "rp_default:stick 6",
         "rp_default:compressed_sandstone",
      }
})

-- Fence nodes

crafting.register_craft(
   {
      output = "rp_default:fence 4",
      items = {
         "rp_default:planks",
         "rp_default:stick 4",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_oak 4",
      items = {
         "rp_default:planks_oak",
         "rp_default:stick 4",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_birch 4",
      items = {
         "rp_default:planks_birch",
         "rp_default:stick 4",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_fir 4",
      items = {
         "rp_default:planks_fir",
         "rp_default:stick 4",
         "rp_default:fiber 4",
      }
})

crafting.register_craft({
      output = "rp_default:fence_gate_closed 2",
      items = {
         "rp_default:planks",
         "rp_default:stick 6",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_gate_oak_closed 2",
      items = {
         "rp_default:planks_oak",
         "rp_default:stick 6",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_gate_birch_closed 2",
      items = {
         "rp_default:planks_birch",
         "rp_default:stick 6",
         "rp_default:fiber 4",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fence_gate_fir_closed 2",
      items = {
         "rp_default:planks_fir",
         "rp_default:stick 6",
         "rp_default:fiber 4",
      }
})

-- Misc nodes

crafting.register_craft(
   {
      output = "rp_default:torch 2",
      items = {
         "rp_default:lump_coal",
         "rp_default:stick",
         "rp_default:fiber",
      }
})

crafting.register_craft(
   {
      output = "rp_default:torch_weak 2",
      items = {
         "rp_default:stick",
         "rp_default:fiber",
      }
})

crafting.register_craft(
   {
      output = "rp_default:ladder 2",
      items = {
         "rp_default:stick 5",
         "rp_default:fiber 2",
      }
})

-- Tool nodes (chests, furnaces)

crafting.register_craft(
   {
      output = "rp_default:chest",
      items = {
         "rp_default:stick 12",
         "rp_default:fiber 8",
         "group:planks 6",
      }
})

crafting.register_craft(
   {
      output = "rp_default:furnace",
      items = {
         "rp_default:torch",
         "group:stone 6",
      }
})

-- Sand nodes

crafting.register_craft(
   {
      output = "rp_default:sandstone",
      items = {
         "rp_default:sand 2",
      }
})

crafting.register_craft(
   {
      output = "rp_default:compressed_sandstone",
      items = {
         "rp_default:sandstone 2",
      }
})

-- Agriculture nodes

crafting.register_craft(
   {
      output = "rp_default:fertilizer",
      items = {
         "rp_default:fern 4",
         "rp_default:fiber 3",
      }
})

crafting.register_craft(
   {
      output = "rp_default:fertilizer 2",
      items = {
         "rp_default:lump_sulfur 3",
         "rp_default:fiber 3",
      }
})
