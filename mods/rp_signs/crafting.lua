minetest.register_craft({
	type = "fuel",
	recipe = "rp_signs:sign",
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

crafting.register_craft({
	output = "rp_signs:sign 2",
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


