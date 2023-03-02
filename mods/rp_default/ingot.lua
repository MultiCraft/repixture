local S = minetest.get_translator("rp_default")

default.register_ingot = function(name, def)
	minetest.register_node(name, {
		description = def.description,
		groups = { craftitem = 1, ingot = 1, dig_immediate = 3, attached_node = 1 },
		inventory_image = def.texture,
		wield_image = def.texture,
		tiles = {
			def.tilesdef.top,
			def.tilesdef.bottom or def.tilesdef.top,
			def.tilesdef.side_short,
			def.tilesdef.side_short,
			def.tilesdef.side_long,
			def.tilesdef.side_long,
		},
		use_texture_alpha = "clip",

		walkable = false,
		is_ground_content = true,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = { -6/16, -0.5, -3/16, 6/16, -6/16, 3/16 },
		},
		paramtype = "light",
		paramtype2 = "facedir",
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, name)
		end,
		sounds = rp_sounds.node_sound_defaults(),
	})
end

local quicklist = {
	{ "steel", S("Steel Ingot") },
	{ "carbon_steel", S("Carbon Steel Ingot") },
	{ "copper", S("Copper Ingot") },
	{ "tin", S("Tin Ingot") },
	{ "bronze", S("Bronze Ingot") },
	{ "wrought_iron", S("Wrought Iron Ingot") },
}

for q=1, #quicklist do
	local id = quicklist[q][1]
	local desc = quicklist[q][2]
	default.register_ingot("rp_default:ingot_"..id, {
		description = desc,
		texture = "default_ingot_"..id..".png",
		tilesdef = {
			top = "rp_default_ingot_"..id.."_node_top.png",
			side_short = "rp_default_ingot_"..id.."_node_side_short.png",
			side_long = "rp_default_ingot_"..id.."_node_side_long.png",
		},
	})
end

