local S = minetest.get_translator("rp_signs")

dofile(minetest.get_modpath("rp_signs").."/aliases.lua")

-- Maximum number of characters on a sign text
local SIGN_MAX_TEXT_LENGTH = 500

-- Sign thickness in node units
local SIGN_THICKNESS = 1/16


local function crop_text(txt)
	if not txt then
		return ""
	end
	return rp_unicode_text.utf8.crop_text(txt, SIGN_MAX_TEXT_LENGTH)
end

-- Formspec pages for sign (different background textures)
local sign_pages = {}
local register_sign_page = function(id, node_names)
	local page_name = "rp_signs:"..id

	local form = rp_formspec.default.version
        form = form .. "size[8.5,4.5]"
	form = form .. rp_formspec.default.boilerplate
	form = form .. "background[0,0;8.5,4.5;ui_formspec_bg_"..id..".png]"
	rp_formspec.register_page(page_name, form)

	for n=1, #node_names do
		sign_pages[node_names[n]] = page_name
	end
end

-- Returns true if check_pos is in front of a horizontal sign
-- (standing, hanging or sideways).
-- Returns false otherwise.
local is_pos_in_front_of_sign = function(sign_pos, sign_node, check_pos)
	local p2 = sign_node.param2 % 4
	local side = minetest.get_item_group(sign_node.name, "sign_side") ~= 0
	if side then
		p2 = (p2 - 1) % 4
	end
	-- X axis
	if p2 == 1 and check_pos.x < sign_pos.x then
		return false
	elseif p2 == 3 and check_pos.x >= sign_pos.x then
		return false
	-- Z axis
	elseif p2 == 0 and check_pos.z < sign_pos.z then
		return false
	elseif p2 == 2 and check_pos.z >= sign_pos.z then
		return false
	end
	return true
end

-- Show formspec of sign at pos.
-- * pos: Sign formspec
-- * read_only: true if the text can not be edited
-- * player_pos: Position of player to look at sign
--   (used to select front or back side of sign)
local get_sign_formspec = function(pos, read_only, player_pos)
	local node = minetest.get_node(pos)
	local write_front = true
	if player_pos then
		write_front = is_pos_in_front_of_sign(pos, node, player_pos)
	end
	local pagename = sign_pages[node.name]
	local form
	if pagename then
		form = rp_formspec.get_page(pagename)
		form = form .. "set_focus[text;true]"
		local meta = minetest.get_meta(pos)
		local text, elem
		if write_front then
			text = meta:get_string("text")
			elem = "text"
		else
			text = meta:get_string("text_back")
			elem = "text_back"
		end
		if read_only then
			elem = ""
		end
		form = form .. "textarea[0.5,1;7.5,1.5;"..elem..";;"..minetest.formspec_escape(text).."]"
		if not read_only then
			form = form .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
		end
	else
		minetest.log("warning", "[rp_signs] No formspec page for sign at "..minetest.pos_to_string(pos, 0)..". Fallback to rp_formspec:field")
		form = rp_formspec.get_page("rp_formspec:field")
	end
	return form
end

local refresh_sign = function(meta, node)
	-- Clear the node formspec from older versions; the formspec is now sent manually
	meta:set_string("formspec", "")

	-- Add sign infotext
	if meta:get_string("text") ~= "" then
		meta:set_string("infotext", S('"@1"', meta:get_string("text"):trim()))
	end
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", "")
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "sign_text_white_unpainted") == 1 then
		meta:set_int("white_text", 1)
	end
	refresh_sign(meta, node)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 14) ~= "rp_signs:sign_" then
		return
	end
	local coords = string.sub(formname, 15)
	local x, y, z = string.match(coords, "([0-9-]+)_([0-9-]+)_([0-9-]+)")
	local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
	if not pos or not pos.x or not pos.y or not pos.z then
		return
	end

	local text, write_front
	if fields.text then
		text = fields.text
		write_front = true
	elseif fields.text_back then
		text = fields.text_back
		write_front = false
	else
		return
	end

	-- Check if there's actually a sign at pos
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "sign") == 0 then
		return
	end

	-- Check protection
	if minetest.is_protected(pos, player:get_player_name()) and
			not minetest.check_player_privs(player, "protection_bypass") then
		minetest.record_protection_violation(pos, player:get_player_name())
		return
	end

	local meta = minetest.get_meta(pos)
	if write_front then
		meta:set_string("text", text)
	else
		meta:set_string("text_back", text)
	end

	minetest.sound_play({name="rp_default_write_sign", gain=0.2}, {pos=pos, max_hear_distance=16}, true)
	minetest.log("action", "[rp_signs] " .. (player:get_player_name() or "")..
		-- Note: Don't show written sign text in log to prevent log flooding
		" wrote something to a sign at "..minetest.pos_to_string(pos))

	local infotext = text:trim()
	if infotext == "" then
		meta:set_string("infotext", "")
	else
		meta:set_string("infotext", S('"@1"', infotext))
	end
end)

local on_rightclick = function(pos, node, clicker, itemstack)
	if clicker and clicker:is_player() then
		local read_only = false
		-- Don't allow editing if protected
		if minetest.is_protected(pos, clicker:get_player_name()) and
				not minetest.check_player_privs(clicker, "protection_bypass") then
			read_only = true
		end

		local standing = minetest.get_item_group(node.name, "sign_standing") ~= 0
		local sideways = minetest.get_item_group(node.name, "sign_side") ~= 0
		local formspec
		-- Show sign formspec
		if standing or sideways then
			-- Double-sided
			formspec = get_sign_formspec(pos, read_only, clicker:get_pos())
		else
			-- Single-sided
			formspec = get_sign_formspec(pos, read_only)
		end
		local pos_id = tostring(pos.x).."_"..tostring(pos.y).."_"..tostring(pos.z)
		minetest.show_formspec(clicker:get_player_name(), "rp_signs:sign_"..pos_id, formspec)
	end
	return itemstack
end

local function register_sign(id, def)
	local stwc, stwu = 0, 0
	-- Value for group 'sign_text_white_colored';
	-- indicates the sign text is white on colored signs
	if def.text_white_on_colored then
		stwc = 1
	end
	-- Value for group 'sign_text_white_unpainted';
	-- indicates the sign text is white on unpainted signs
	if def.text_white_on_unpainted then
		stwu = 1
	end

	-- Wall sign.
	-- May also be placed on floor or ceiling.
	local sdef = {
		description = def.description,
		_tt_help = S("Write a short message"),
		drawtype = "nodebox",
		tiles = {def.tile, "("..def.tile_back..")^[transformR180", def.tile_side, def.tile_side, def.tile_side, def.tile_side},
		inventory_image = def.inv_image,
		wield_image = def.inv_image,
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		node_box = {
			type = "wallmounted",
			wall_top = {-0.5+SIGN_THICKNESS, 0.5, -0.5+(4/16), 0.5-SIGN_THICKNESS, 0.5-SIGN_THICKNESS, 0.5-(4/16)},
			wall_bottom = {-0.5+SIGN_THICKNESS, -0.5, -0.5+(4/16), 0.5-SIGN_THICKNESS, -0.5+SIGN_THICKNESS, 0.5-(4/16)},
			wall_side = {-0.5, -0.5+(4/16), -0.5+SIGN_THICKNESS, -0.5+SIGN_THICKNESS, 0.5-(4/16), 0.5-SIGN_THICKNESS},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, sign_text_white_unpainted=stwu, creative_decoblock = 1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_signs:"..id)
		end,
		on_construct = on_construct,
		node_placement_prediction = "",
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

			local nodedef = minetest.registered_nodes[node.name]
			local buildable_to = nodedef and nodedef.buildable_to
			local protcheck
			if buildable_to then
				protcheck = pointed_thing.under
			else
				protcheck = pointed_thing.above
			end
			if minetest.is_protected(protcheck, placer:get_player_name()) and
					not minetest.check_player_privs(placer, "protection_bypass") then
				minetest.record_protection_violation(protcheck, placer:get_player_name())
				return itemstack
			end

			local check_r90 = function(yaw)
				if (yaw > (1/4)*math.pi and yaw < (3/4)*math.pi) or (yaw > (5/4)*math.pi and yaw < (7/4)*math.pi) then
					return true
				else
					return false
				end
			end

			local fakestack = ItemStack(itemstack)
			local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under, pointed_thing.above))
			local look_yaw = placer:get_look_horizontal()
			local r90 = false
			if wdir == 0 or wdir == 1 then
				r90 = check_r90(look_yaw)
				if r90 then
					fakestack:set_name("rp_signs:"..id.."_r90")
				end
			end

			local place_pos
			itemstack, place_pos = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			if not place_pos then
				wdir = 1
				r90 = check_r90(look_yaw)
				if r90 then
					fakestack:set_name("rp_signs:"..id.."_r90")
				else
					fakestack:set_name("rp_signs:"..id)
				end
				itemstack, place_pos = minetest.item_place(fakestack, placer, pointed_thing, wdir)
			end
			if place_pos then
				-- Flip text on floor/ceiling sign depending on look direction
				if (r90 and (look_yaw > (5/4)*math.pi and look_yaw < (7/4)*math.pi)) or
						(not r90 and (look_yaw > math.pi/2) and (look_yaw < ((3*math.pi)/2))) then
					local signmeta = minetest.get_meta(place_pos)
					signmeta:set_int("textflip", 1)
				end

				rp_sounds.play_node_sound(place_pos, {name="rp_signs:"..id}, "place")
			else
				rp_sounds.play_place_failed_sound(placer)
			end
			itemstack:set_name("rp_signs:"..id)
			return itemstack
		end,
		on_rightclick = on_rightclick,
	}
	minetest.register_node("rp_signs:"..id, sdef)

	-- Wall sign, rotated by 90°.
	-- The 90° variant is only when placed on floor or ceiling to orient a different way.
	-- It should not be used at walls (despite its name).
	local sdef_r90 = {
		drawtype = "nodebox",
		tiles = {
			"("..def.tile..")^[transformR90",
			"("..def.tile_back..")^[transformR270",
			def.tile_side,
			def.tile_side,
			def.tile_side,
			def.tile_side,
		},
		inventory_image = "("..def.inv_image..")^[transformR90",
		wield_image = "("..def.inv_image..")^[transformR90",
		paramtype = "light",
		paramtype2 = "wallmounted",
		sunlight_propagates = true,
		walkable = false,
		node_box = {
			type = "wallmounted",
			wall_top = {-0.5+(4/16), 0.5, -0.5+SIGN_THICKNESS, 0.5-(4/16), 0.5-SIGN_THICKNESS, 0.5-SIGN_THICKNESS},
			wall_bottom = {-0.5+(4/16), -0.5, -0.5+SIGN_THICKNESS, 0.5-(4/16), -0.5+SIGN_THICKNESS, 0.5-SIGN_THICKNESS},
			wall_side = {-0.5, -0.5+SIGN_THICKNESS, -0.5+(4/16), -0.5+SIGN_THICKNESS, 0.5-SIGN_THICKNESS, 0.5-(4/16)},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, sign_r90=1, sign_text_white_unpainted=stwu, not_in_creative_inventory=1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_signs:"..id)
		end,
		on_construct = on_construct,
		on_destruct = on_destruct,
		on_blast = on_blast,
		on_rightclick = on_rightclick,
		drop = "rp_signs:"..id,
	}
	minetest.register_node("rp_signs:"..id.."_r90", sdef_r90)

	-- Standing sign
	local base_standing_wallbox = {-0.5+(1/16), -0.5+(4/16), -SIGN_THICKNESS/2, 0.5-(1/16), 0.5-(4/16), SIGN_THICKNESS/2}
	local ssdef = {
		description = def.description_standing,
		_tt_help = S("Write short messages (two sides)"),
		drawtype = "nodebox",
		tiles = {
			def.tile_side,
			def.tile_side,
			def.tile_side,
			def.tile_side,
			def.tile,
			def.tile,
		},
		inventory_image = def.inv_image_standing,
		wield_image = def.inv_image_standing,
		paramtype = "light",
		paramtype2 = "4dir",
		sunlight_propagates = true,
		walkable = false,
		node_box = {
			type = "fixed",
			fixed = {
				base_standing_wallbox,
				{ -1/16, -0.5, -SIGN_THICKNESS/2, 1/16, -0.5+(4/16), SIGN_THICKNESS/2 },
			},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 3, sign=1, sign_standing=1, sign_text_white_unpainted=stwu, creative_decoblock = 1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_signs:"..id.."_standing")
		end,
		on_construct = on_construct,
		on_destruct = on_destruct,
		on_blast = on_blast,
		node_placement_prediction = "",
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

			local nodedef = minetest.registered_nodes[node.name]
			local buildable_to = nodedef and nodedef.buildable_to
			local protcheck
			if buildable_to then
				protcheck = pointed_thing.under
			else
				protcheck = pointed_thing.above
			end

			if minetest.is_protected(protcheck, placer:get_player_name()) and
					not minetest.check_player_privs(placer, "protection_bypass") then
				minetest.record_protection_violation(protcheck, placer:get_player_name())
				return itemstack
			end

			local fakestack = ItemStack(itemstack)
			local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
			local p2

			-- Place different sign type depending on placement direction
			if dir.y == -1 then
				fakestack:set_name("rp_signs:"..id.."_standing")
			elseif dir.y == 1 then
				fakestack:set_name("rp_signs:"..id.."_hanging")
			else
				-- When placing sideways, the sign may either
				-- become a sideways sign, or standing.
				local stand = false
				-- If targeted node is buildable_to and floor is
				-- walkable, it becomes a standing sign because
				-- that's what the player probably meant.
				if buildable_to then
					local below = vector.offset(pointed_thing.under, 0, -1, 0)
					local node_below = minetest.get_node(below)
					local nodedef_below = minetest.registered_nodes[node_below.name]
					if nodedef_below and nodedef_below.walkable then
						fakestack:set_name("rp_signs:"..id.."_standing")
						stand = true
					end
				end
				-- Otherwise, place a sideways sign. This is usually the
				-- case when the wall was pointed *directly*.
				if not stand then
					fakestack:set_name("rp_signs:"..id.."_side")
					p2 = minetest.dir_to_fourdir(dir)
				end
			end

			local place_pos
			itemstack, place_pos = minetest.item_place(fakestack, placer, pointed_thing, p2)
			if not place_pos then
				fakestack:set_name("rp_signs:"..id.."_standing")
				itemstack, place_pos = minetest.item_place(fakestack, placer, pointed_thing)
			end
			if place_pos then
				rp_sounds.play_node_sound(place_pos, {name="rp_signs:"..id.."_standing"}, "place")
			else
				rp_sounds.play_place_failed_sound(placer)
			end
			itemstack:set_name("rp_signs:"..id.."_standing")
			return itemstack
		end,
		on_rightclick = on_rightclick,
		_after_paint = _after_paint,
		_after_unpaint = _after_unpaint,
	}

	-- Hanging sign.
	-- Same as standing sign, but attached at ceiling
	local shdef = table.copy(ssdef)
	shdef.description = nil
	shdef.inventory_image = nil
	shdef.wield_image = nil
	shdef.groups = table.copy(ssdef.groups)
	shdef.groups.attached_node = 4
	shdef.groups.sign_standing = 2
	shdef.node_box = {
		type = "fixed",
		fixed = {
			base_standing_wallbox,
			{ -1/16, 0.5-(4/16), -SIGN_THICKNESS/2, 1/16, 0.5, SIGN_THICKNESS/2 },
		},
	}
	shdef.drop = "rp_signs:"..id.."_standing"

	-- Sideways sign
	local stsdef = table.copy(ssdef)
	stsdef.description = nil
	stsdef.inventory_image = nil
	stsdef.wield_image = nil
	stsdef.tiles = {
		"("..def.tile_side..")^[transformR90",
		"("..def.tile_side..")^[transformR90",
		def.tile,
		def.tile,
		def.tile_side,
		def.tile_side,
	}
	stsdef.groups = table.copy(ssdef.groups)
	stsdef.groups.attached_node = 2
	stsdef.groups.sign_side = 1
	stsdef.groups.sign_standing = nil
	-- This nodebox is rotated 90° compared to the standing sign so that attaching to
	-- the wall works properly
	stsdef.node_box = {
		type = "fixed",
		fixed = {
			{ -SIGN_THICKNESS/2, -0.5+(4/16), -0.5+(1/16), SIGN_THICKNESS/2, 0.5-(4/16), 0.5-(1/16) },
			{ -SIGN_THICKNESS/2, -1/16, 0.5-(1/16), SIGN_THICKNESS/2, 1/16, 0.5 },
		},
	}
	stsdef.drop = "rp_signs:"..id.."_standing"

	minetest.register_node("rp_signs:"..id.."_standing", ssdef)
	minetest.register_node("rp_signs:"..id.."_hanging", shdef)
	minetest.register_node("rp_signs:"..id.."_side", stsdef)

	-- Wall sign, painted
	local sdef_p = table.copy(sdef)
	sdef_p.description = def.description_painted
	sdef_p.paramtype2 = "colorwallmounted"
	sdef_p.palette = def.palette_wall or "rp_paint_palette_32.png"
	sdef_p.groups.paintable = 1
	sdef_p.groups.not_in_creative_inventory = 1
	sdef_p.groups.sign_text_white_unpainted = nil
	sdef_p.groups.sign_text_white_colored = stwc
	sdef_p.tiles = {
		def.tile_painted,
		"("..def.tile_back_painted..")^[transformR180",
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
	}
	sdef_p.inventory_image = def.inv_image.."^[hsl:0:-100:0"
	sdef_p.wield_image = def.inv_image.."^[hsl:0:-100:0"
	sdef_p.drop = "rp_signs:"..id
	sdef_p._rp_paint_particle_pos = "cube_inside"
	minetest.register_node("rp_signs:"..id.."_painted", sdef_p)

	-- Wall sign, rotated by 90°, painted
	local sdef_r90_p = table.copy(sdef_r90)
	sdef_r90_p.paramtype2 = "colorwallmounted"
	sdef_r90_p.palette = def.palette_wall or "rp_paint_palette_32.png"
	sdef_r90_p.groups.paintable = 1
	sdef_r90_p.groups.sign_r90 = 1
	sdef_r90_p.groups.sign_text_white_unpainted = nil
	sdef_r90_p.groups.sign_text_white_colored = stwc
	sdef_r90_p.tiles = {
		"("..def.tile_painted..")^[transformR90",
		"("..def.tile_back_painted..")^[transformR270",
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
	}
	sdef_r90_p.inventory_image = "("..def.inv_image..")^[transformR90^[hsl:0:-100:0"
	sdef_r90_p.wield_image = "("..def.inv_image..")^[transformR90^[hsl:0:-100:0"
	sdef_r90_p.drop = "rp_signs:"..id
	sdef_r90_p._rp_paint_particle_pos = "cube_inside"
	minetest.register_node("rp_signs:"..id.."_r90_painted", sdef_r90_p)

	-- Standing sign, painted
	local ssdef_p = table.copy(ssdef)
	ssdef_p.description = def.description_standing_painted
	ssdef_p.paramtype2 = "color4dir"
	ssdef_p.palette = def.palette_stand or "rp_paint_palette_64.png"
	ssdef_p.groups.paintable = 1
	ssdef_p.groups.sign_standing = 1
	ssdef_p.groups.not_in_creative_inventory = 1
	ssdef_p.groups.sign_text_white_unpainted = nil
	ssdef_p.groups.sign_text_white_colored = stwc
	ssdef_p.tiles = {
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_painted,
		def.tile_painted,
	}
	ssdef_p.inventory_image = "("..def.inv_image_standing..")^[hsl:0:-100:0"
	ssdef_p.wield_image = "("..def.inv_image_standing..")^[hsl:0:-100:0"
	ssdef_p.drop = "rp_signs:"..id.."_standing"
	ssdef_p._rp_paint_particle_pos = "cube_inside"
	minetest.register_node("rp_signs:"..id.."_standing_painted", ssdef_p)

	-- Hanging sign, painted
	local shdef_p = table.copy(shdef)
	shdef_p.description = nil
	shdef_p.paramtype2 = "color4dir"
	shdef_p.palette = def.palette_stand or "rp_paint_palette_64.png"
	shdef_p.groups.paintable = 1
	shdef_p.groups.sign_standing = 2
	shdef_p.groups.not_in_creative_inventory = 1
	shdef_p.groups.sign_text_white_unpainted = nil
	shdef_p.groups.sign_text_white_colored = stwc
	shdef_p.tiles = {
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_side_painted,
		def.tile_painted,
		def.tile_painted,
	}
	shdef_p.inventory_image = nil
	shdef_p.wield_image = nil
	shdef_p.drop = "rp_signs:"..id.."_standing"
	shdef_p._rp_paint_particle_pos = "cube_inside"
	minetest.register_node("rp_signs:"..id.."_hanging_painted", shdef_p)

	-- Sideways sign, painted
	local stsdef_p = table.copy(stsdef)
	stsdef_p.description = nil
	stsdef_p.paramtype2 = "color4dir"
	stsdef_p.palette = def.palette_stand or "rp_paint_palette_64.png"
	stsdef_p.groups.paintable = 1
	stsdef_p.groups.not_in_creative_inventory = 1
	stsdef_p.groups.sign_text_white_unpainted = nil
	stsdef_p.groups.sign_text_white_colored = stwc
	stsdef_p.tiles = {
		"("..def.tile_side_painted..")^[transformR90",
		"("..def.tile_side_painted..")^[transformR90",
		def.tile_painted,
		def.tile_painted,
		def.tile_side_painted,
		def.tile_side_painted,
	}
	stsdef_p.inventory_image = nil
	stsdef_p.wield_image = nil
	stsdef_p.drop = "rp_signs:"..id.."_standing"
	stsdef_p._rp_paint_particle_pos = "cube_inside"
	minetest.register_node("rp_signs:"..id.."_side_painted", stsdef_p)

	register_sign_page(id, {
		"rp_signs:"..id,
		"rp_signs:"..id.."_r90",
		"rp_signs:"..id.."_painted",
		"rp_signs:"..id.."_r90_painted",
		"rp_signs:"..id.."_standing",
		"rp_signs:"..id.."_standing_painted",
		"rp_signs:"..id.."_hanging",
		"rp_signs:"..id.."_hanging_painted",
		"rp_signs:"..id.."_side",
		"rp_signs:"..id.."_side_painted",
	})
end



minetest.register_entity("rp_signs:sign_text", {
	on_activate = function(self)
		self.object:remove()
	end,
})

local sounds_wood_sign = rp_sounds.node_sound_planks_defaults({
	footstep = {},
	dig = { name = "rp_sounds_dig_wood", pitch = 1.5, gain = 0.5 },
	dug = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.7 },
	fall = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.6 },
	place = { name = "rp_sounds_place_planks", pitch = 1.4, gain = 0.9 },
})

register_sign("sign_wood", {
	description = S("Wooden Wall Sign"),
	description_painted = S("Painted Wooden Wall Sign"),
	description_standing = S("Wooden Pole Sign"),
	description_standing_painted = S("Painted Pole Wooden Sign"),
	tile = "default_sign.png",
	tile_back = "rp_default_sign_back.png",
	tile_painted = "rp_default_sign_painted.png",
	tile_back_painted = "rp_default_sign_back_painted.png",
	tile_side = "rp_default_sign_side.png",
	tile_side_painted = "rp_default_sign_side_painted.png",
	inv_image = "default_sign_inventory.png",
	inv_image_standing = "rp_default_sign_standing_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_oak", {
	description = S("Oak Wall Sign"),
	description_painted = S("Painted Oak Wall Sign"),
	description_standing = S("Oak Pole Sign"),
	description_standing_painted = S("Painted Oak Pole Sign"),
	tile = "rp_default_sign_oak.png",
	tile_back = "rp_default_sign_oak_back.png",
	tile_painted = "rp_default_sign_oak_painted.png",
	tile_back_painted = "rp_default_sign_oak_back_painted.png",
	tile_side = "rp_default_sign_oak_side.png",
	tile_side_painted = "rp_default_sign_oak_side_painted.png",
	inv_image = "rp_default_sign_oak_inventory.png",
	inv_image_standing = "rp_default_sign_oak_standing_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_birch", {
	description = S("Birch Wall Sign"),
	description_painted = S("Painted Birch Wall Sign"),
	description_standing = S("Birch Pole Sign"),
	description_standing_painted = S("Painted Birch Pole Sign"),
	tile = "rp_default_sign_birch.png",
	tile_back = "rp_default_sign_birch_back.png",
	tile_painted = "rp_default_sign_birch_painted.png",
	tile_back_painted = "rp_default_sign_birch_back_painted.png",
	tile_side = "rp_default_sign_birch_side.png",
	tile_side_painted = "rp_default_sign_birch_side_painted.png",
	inv_image = "rp_default_sign_birch_inventory.png",
	inv_image_standing = "rp_default_sign_birch_standing_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_fir", {
	description = S("Fir Wall Sign"),
	description_painted = S("Painted Fir Wall Sign"),
	description_standing = S("Fir Pole Sign"),
	description_standing_painted = S("Painted Fir Pole Sign"),
	tile = "rp_default_sign_fir.png",
	tile_back = "rp_default_sign_fir_back.png",
	tile_painted = "rp_default_sign_fir_painted.png",
	tile_back_painted = "rp_default_sign_fir_back_painted.png",
	tile_side = "rp_default_sign_fir_side.png",
	tile_side_painted = "rp_default_sign_fir_side_painted.png",
	inv_image = "rp_default_sign_fir_inventory.png",
	inv_image_standing = "rp_default_sign_fir_standing_inventory.png",
	sounds = sounds_wood_sign,
	palette_wall = "rp_paint_palette_32l.png",
	palette_stand = "rp_paint_palette_64l.png",
	-- The fir sign is pretty dark, so we prefer a white text color
	text_white_on_unpainted = true,
	text_white_on_colored = true,
})

dofile(minetest.get_modpath("rp_signs").."/crafting.lua")

-- Update sign formspecs/infotexts
minetest.register_lbm({
	label = "Update signs",
	name = "rp_signs:update_signs_3_14_0_no_entity",
	nodenames = {"group:sign"},
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		refresh_sign(meta, node)
	end
})
