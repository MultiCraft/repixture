local S = minetest.get_translator("rp_default")

default.register_ingot = function(name, def)
	local groups = { craftitem = 1, ingot = 1, dig_immediate = 3, attached_node = 1 }
	if def.groups then
		for group, rating in pairs(def.groups) do
			groups[group] = rating
		end
	end
	minetest.register_node(name, {
		description = def.description,
		groups = groups,
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
		sounds = rp_sounds.node_sound_defaults({
			place = { name = "rp_default_place_ingot", gain = 0.5, pitch = def.pitch },
			dug = { name = "rp_default_dug_ingot", gain = 0.5, pitch = def.pitch },
			fall = { name = "rp_default_fall_ingot", gain = 0.35, pitch = def.pitch },
			dig = {},
			footstep = {},
		}),
	})
end

local quicklist = {
	-- ID, description, pitch, magnetic
	{ "steel", S("Steel Ingot"), default.METAL_PITCH_STEEL },
	{ "carbon_steel", S("Carbon Steel Ingot"), default.METAL_PITCH_CARBON_STEEL },
	{ "copper", S("Copper Ingot"), default.METAL_PITCH_COPPER },
	{ "tin", S("Tin Ingot"), default.METAL_PITCH_TIN },
	{ "bronze", S("Bronze Ingot"), default.METAL_PITCH_BRONZE },
	{ "wrought_iron", S("Wrought Iron Ingot"), default.METAL_PITCH_WROUGHT_IRON, true },
}

for q=1, #quicklist do
	local id = quicklist[q][1]
	local desc = quicklist[q][2]
	local pitch = quicklist[q][3]
	local magnetic = quicklist[q][4]
	local groups
	if magnetic then
		groups = { magnetic = 1 }
	end
	default.register_ingot("rp_default:ingot_"..id, {
		description = desc,
		texture = "default_ingot_"..id..".png",
		tilesdef = {
			top = "rp_default_ingot_"..id.."_node_top.png",
			side_short = "rp_default_ingot_"..id.."_node_side_short.png",
			side_long = "rp_default_ingot_"..id.."_node_side_long.png",
		},
		pitch = pitch,
		groups = groups,
	})
end

