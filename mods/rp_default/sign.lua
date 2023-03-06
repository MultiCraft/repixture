local S = minetest.get_translator("rp_default")

local SIGN_MAX_TEXT_LENGTH = 500

-- Formspec pages for sign (different background textures)
local sign_pages = {}
local register_sign_page = function(id, node_names)
	local page_name = "rp_default:"..id

	local form = "size[8.5,5]"
	form = form .. rp_formspec.default.bg
	form = form .. "background[0,0;8.5,4.5;ui_formspec_bg_"..id..".png]"
	form = form .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
	form = form .. "set_focus[text;true]"
	form = form .. "field[1,1.75;7,0;text;;${text}]"
	rp_formspec.register_page(page_name, form)

	for n=1, #node_names do
		sign_pages[node_names[n]] = page_name
	end
end

default.refresh_sign = function(meta, node)
	local pagename = sign_pages[node.name]
	local page
	if pagename then
		page = rp_formspec.get_page(pagename)
	else
		page = rp_formspec.get_page("rp_formspec:field")
	end
	meta:set_string("formspec", page)

	local text = meta:get_string("text")
	-- Show sign text in quotation marks
	meta:set_string("infotext", S('"@1"', text))
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", "")
	local node = minetest.get_node(pos)
	default.refresh_sign(meta, node)
end
local on_receive_fields = function(pos, formname, fields, sender)
	if fields.text == nil then return end
	if minetest.is_protected(pos, sender:get_player_name()) and
			not minetest.check_player_privs(sender, "protection_bypass") then
		minetest.record_protection_violation(pos, sender:get_player_name())
		return itemstack
	end
	local meta = minetest.get_meta(pos)
	local text = fields.text
	if string.len(text) > SIGN_MAX_TEXT_LENGTH then
		text = string.sub(text, 1, SIGN_MAX_TEXT_LENGTH)
	end
	minetest.log("action", "[rp_default] " .. (sender:get_player_name() or "")..
					" wrote \""..text.."\" to sign at "..
					minetest.pos_to_string(pos))
	meta:set_string("text", text)
	-- Show sign text in quotation marks
	meta:set_string("infotext", S('"@1"', text))

	default.write_name(pos, meta:get_string("text"))
end
local on_destruct = function(pos)
	default.write_name(pos, "")
end

local function register_sign(id, def)
	minetest.register_node("rp_default:"..id, {
		description = def.description,
		_tt_help = S("Write a short message"),
		drawtype = "nodebox",
		tiles = {def.tile},
		inventory_image = def.inv_image,
		wield_image = def.inv_image,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		node_box = {
			type = "wallmounted",
			wall_top = {-0.5+(1/16), 0.5, -0.5+(4/16), 0.5-(1/16), 0.5-(1/16), 0.5-(4/16)},
			wall_bottom = {-0.5+(1/16), -0.5, -0.5+(4/16), 0.5-(1/16), -0.5+(1/16), 0.5-(4/16)},
			wall_side = {-0.5, -0.5+(4/16), -0.5+(1/16), -0.5+(1/16), 0.5-(4/16), 0.5-(1/16)},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,attached_node = 1, sign=1, creative_decoblock = 1},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_default:"..id)
		end,
		on_construct = on_construct,
		on_receive_fields = on_receive_fields,
		on_destruct = on_destruct,
		on_place = function(itemstack, placer, pointed_thing)
			-- Boilerplace to handle pointed node's rightclick handler
			if not placer or not placer:is_player() then
				return itemstack
			end
			if pointed_thing.type ~= "node" then
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]
			if def and def.on_rightclick and
				((not placer) or (placer and not placer:get_player_control().sneak)) then
				return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
					pointed_thing) or itemstack
			end


			if pointed_thing.under.y == pointed_thing.above.y then
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end

			local r90 = false
				local yaw = placer:get_look_horizontal()
			if not ((yaw > (1/4)*math.pi and yaw < (3/4)*math.pi) or (yaw > (5/4)*math.pi and yaw < (7/4)*math.pi)) then
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end
			local r90sign = ItemStack("rp_default:"..id.."_r90")
			r90sign = minetest.item_place_node(r90sign, placer, pointed_thing)
			if r90sign:is_empty() then
				itemstack:take_item()
			end
			return itemstack
		end,
	})

	minetest.register_node("rp_default:"..id.."_r90", {
		drawtype = "nodebox",
		tiles = {"("..def.tile..")^[transformR90"},
		inventory_image = "("..def.inv_image..")^[transformR90",
		wield_image = "("..def.inv_image..")^[transformR90",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		node_box = {
			type = "wallmounted",
			wall_top = {-0.5+(4/16), 0.5, -0.5+(1/16), 0.5-(4/16), 0.5-(1/16), 0.5-(1/16)},
			wall_bottom = {-0.5+(4/16), -0.5, -0.5+(1/16), 0.5-(4/16), -0.5+(1/16), 0.5-(1/16)},
			wall_side = {-0.5, -0.5+(1/16), -0.5+(4/16), -0.5+(1/16), 0.5-(1/16), 0.5-(4/16)},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,attached_node = 1, sign=1, not_in_creative_inventory=1},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_default:"..id)
		end,
		on_construct = on_construct,
		on_receive_fields = on_receive_fields,
		on_destruct = on_destruct,
		drop = "rp_default:"..id,
	})

	register_sign_page(id, {"rp_default:"..id, "rp_default:"..id.."_r90"})
end

local sounds_wood_sign = rp_sounds.node_sound_planks_defaults({
	footstep = {},
	dig = { name = "rp_sounds_dig_wood", pitch = 1.5, gain = 0.5 },
	dug = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.7 },
	fall = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.6 },
	place = { name = "rp_sounds_place_planks", pitch = 1.4, gain = 0.9 },
})

register_sign("sign", {
	description = S("Wooden Sign"),
	tile = "default_sign.png",
	inv_image = "default_sign_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_oak", {
	description = S("Oak Sign"),
	tile = "rp_default_sign_oak.png",
	inv_image = "rp_default_sign_oak_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_birch", {
	description = S("Birch Sign"),
	tile = "rp_default_sign_birch.png",
	inv_image = "rp_default_sign_birch_inventory.png",
	sounds = sounds_wood_sign,
})
