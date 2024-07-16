local S = minetest.get_translator("rp_decor")

minetest.register_node("rp_decor:barrel", {
	description = S("Barrel"),
	tiles = {"rp_decor_barrel_top.png", "rp_decor_barrel_top.png", "rp_decor_barrel_sides.png"},
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	groups = { choppy = 2, level = -1, creative_decoblock = 1, flammable = 2, furniture = 1, pathfinder_hard = 1 },
	sounds = rp_sounds.node_sound_planks_defaults(),
	_rp_blast_resistance = 1,
})

crafting.register_craft({
	output = "rp_decor:barrel",
	items = {
		"group:planks 6",
		"rp_default:fiber 4",
		"rp_default:ingot_wrought_iron",
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "rp_decor:barrel",
	burntime = 20,
})
