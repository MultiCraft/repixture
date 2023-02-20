-- Special partial blocks crafting recipes.
-- Note: The regular crafting recipes are automatically registered
-- by the API.

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

-- Reed cooking
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


