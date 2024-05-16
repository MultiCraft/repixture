minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_wood",
	burntime = 6,
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_birch",
	burntime = 6,
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_oak",
	burntime = 6,
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_wood_standing",
	burntime = 6,
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_birch_standing",
	burntime = 6,
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign_oak_standing",
	burntime = 6,
})

crafting.register_craft({
	output = "rp_signs:sign_wood 2",
	items = {
		"rp_default:planks",
		"rp_default:fiber 2",
		"rp_default:stick 2",
	}
})
crafting.register_craft({
	output = "rp_signs:sign_birch 2",
	items = {
		"rp_default:planks_birch",
		"rp_default:fiber 2",
		"rp_default:stick 2",
	}
})
crafting.register_craft({
	output = "rp_signs:sign_oak 2",
	items = {
		"rp_default:planks_oak",
		"rp_default:fiber 2",
		"rp_default:stick 2",
	}
})
crafting.register_craft({
	output = "rp_signs:sign_wood_standing",
	items = {
		"rp_signs:sign_wood",
		"rp_default:stick",
	}
})
crafting.register_craft({
	output = "rp_signs:sign_birch_standing",
	items = {
		"rp_signs:sign_birch",
		"rp_default:stick",
	}
})
crafting.register_craft({
	output = "rp_signs:sign_oak_standing",
	items = {
		"rp_signs:sign_oak",
		"rp_default:stick",
	}
})
