local S = minetest.get_translator("rp_signs")

dofile(minetest.get_modpath("rp_signs").."/aliases.lua")

-- Maximum number of characters on a sign text
local SIGN_MAX_TEXT_LENGTH = 500
-- Maximum size of text image in pixels
local SIGN_MAX_TEXT_WIDTH_PIXELS = 400
local SIGN_MAX_TEXT_HEIGHT_PIXELS = 228

-- Sign thickness in node units
local SIGN_THICKNESS = 1/16

-- Offset from text entity from sign node border
local TEXT_ENTITY_OFFSET = SIGN_THICKNESS + 1/128
local TEXT_ENTITY_OFFSET_STANDING = SIGN_THICKNESS/2 + 1/128

-- Maximum length for a texture string.
-- Hard limit to avoid running into issues with Minetest.
local MAX_TEXTURE_STRING_LENGTH = 64535

-- Text entity dimensions
local TEXT_ENTITY_WIDTH = 12/16
local TEXT_ENTITY_HEIGHT = 6/16

-- Required aspect ratio of text entity so that each glyph
-- pixel appears square. Prevents weird strecthing.
local TEXT_ENTITY_ASPECT_RATIO = TEXT_ENTITY_WIDTH / TEXT_ENTITY_HEIGHT

-- Special string for metadata key "image" to denote empty image.
-- Must not collide with base64 characters.
-- Note the empty string stands for an undefined/uninitialized
-- image.
local META_IMAGE_EMPTY = "!"


-- Load font
local font = unicode_text.hexfont({
	background_color = { 0, 0, 0, 0 }, --transparent
	-- Note: This color will be inverted on signs that are painted black
	foreground_color = { 0, 0, 0, 255 }, -- black
	scanline_order = "top-bottom",
	tabulator_size = 16,
	kerning = false,
})

local fontpath = minetest.get_modpath("rp_fonts").."/fontdata"
font:load_glyphs(io.lines(fontpath.."/unifont.hex"))
font:load_glyphs(io.lines(fontpath.."/unifont_upper.hex"))

local function make_text_texture(text, pos, front)
        if not text then
		return false
	end
	local set_meta = function(front, image, h, w)
		local meta = minetest.get_meta(pos)
		if front then
			meta:set_string("image", image)
			meta:set_int("image_h", h)
			meta:set_int("image_w", w)
		else
			meta:set_string("image_back", image)
			meta:set_int("image_back_h", h)
			meta:set_int("image_back_w", w)
		end
	end
	if text == "" then
		local meta = minetest.get_meta(pos)
		set_meta(front, META_IMAGE_EMPTY, 0, 0)
		return true
	end
        local pixels
        local success, pixels = pcall(function()
                return font:render_text(text) --this often crashes on unexpected input
        end)
        if success and pixels then
		local height = #pixels
		local width
		if height == 0 then
			-- 0-height image = empty image
			set_meta(front, META_IMAGE_EMPTY, 0, 0)
			return false
		else
			width = #pixels[1]
		end
		if width == 0 then
			-- 0-width image = empty image
			set_meta(front, META_IMAGE_EMPTY, 0, 0)
			return false
		end

		local convert_pixels = function(ipixels)
			local newpixels = {}
			for y=1, #ipixels do
				local linepixels = ipixels[y]
				for x=1, #linepixels do
					local pixel = linepixels[x]
					local colorspec = { b = pixel[1], g = pixel[2], r = pixel[3], a = pixel[4] }
					table.insert(newpixels, colorspec)
				end
			end
			return newpixels
		end
		pixels = convert_pixels(pixels)

                local image = minetest.encode_png(width, height, pixels)
                local encoded_string = minetest.encode_base64(image)
		set_meta(front, encoded_string, height, width)
                return true
        else
		minetest.log("error", "[rp_signs] Error when calling render_text for: "..tostring(text).." (error: "..tostring(pixels)..")")
		return false
	end
end

local function has_duplicate_entity(pos)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	local count = 0
	local sign_hash = minetest.hash_node_position(pos)
	local front_count, back_count = 0, 0
        for _, v in pairs(objects) do
		local ent = v:get_luaentity()
		if ent and ent.name == "rp_signs:sign_text" and ent._sign_pos then
			local ent_hash = minetest.hash_node_position(ent._sign_pos)
			if ent_hash and sign_hash == ent_hash then
				if ent._front == false then
					back_count = back_count + 1
				else
					front_count = front_count + 1
				end
				if front_count >= 2 or back_count >= 2 then
					return true
				end
			end
		end
	end
	return false
end

local function get_text_entity_raw(pos, get_both, force_remove)
        local objects = minetest.get_objects_inside_radius(pos, 0.5)
        local front_entity, back_entity
	local sign_hash = minetest.hash_node_position(pos)
        for _, v in pairs(objects) do
                local ent = v:get_luaentity()
                if ent and ent.name == "rp_signs:sign_text" and ent._sign_pos then
			local ent_hash = minetest.hash_node_position(ent._sign_pos)
			if ent_hash and sign_hash == ent_hash then
				if force_remove == true then
					v:remove()
				else
					if ent._front == false then
						back_entity = v
					else
						front_entity = v
					end
					if get_both and front_entity and back_entity then
						break
					elseif not get_both then
						break
					end
				end
                        end
                end
        end
	if get_both then
		return front_entity, back_entity
	else
		return front_entity
	end
end

local function get_text_entity(pos, get_both)
	return get_text_entity_raw(pos, get_both, false)
end

local function remove_text_entities(pos)
	get_text_entity_raw(pos, nil, true)
end

local function get_signdata(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if not def or minetest.get_item_group(node.name, "sign") == 0 then
		return
	end
	-- The sign_r90 group marks the sign as being rotated by 90°.
	-- TODO: It should be replaced later with the new Minetest wallmounted
	-- extensions.
	local r90 = minetest.get_item_group(node.name, "sign_r90") == 1
	local g_standing = minetest.get_item_group(node.name, "sign_standing")
	local standing = g_standing == 1 or g_standing == 2
	local sideways = minetest.get_item_group(node.name, "sign_side") == 1
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text")
	local text_back = meta:get_string("text_back")
	local image = meta:get_string("image")
	local image_w = meta:get_int("image_w")
	local image_h = meta:get_int("image_h")
	local image_back = meta:get_string("image_back")
	local image_back_w = meta:get_int("image_back_w")
	local image_back_h = meta:get_int("image_back_h")
	local yaw, pitch, spos, spos_back
	if standing then
		-- Standing or hanging sign
		local dir = minetest.fourdir_to_dir(node.param2)
		yaw = minetest.dir_to_yaw(dir)
		pitch = 0
		spos = vector.add(pos, vector.multiply(dir, TEXT_ENTITY_OFFSET_STANDING))
		spos_back = vector.subtract(pos, vector.multiply(dir, TEXT_ENTITY_OFFSET_STANDING))
	elseif sideways then
		-- Sideways sign
		local dir = minetest.fourdir_to_dir(node.param2)
		dir = vector.rotate_around_axis(dir, vector.new(0, 1, 0), math.pi/2)
		yaw = minetest.dir_to_yaw(dir)
		pitch = 0
		spos = vector.add(pos, vector.multiply(dir, TEXT_ENTITY_OFFSET_STANDING))
		spos_back = vector.subtract(pos, vector.multiply(dir, TEXT_ENTITY_OFFSET_STANDING))
	else
		local dir = minetest.wallmounted_to_dir(node.param2)
		if dir.y >= 1 then
			-- Ceiling sign
			local textflip = meta:get_int("textflip") == 1
			pitch = math.pi/2
			if r90 then
				if textflip then
					yaw = -math.pi/2
				else
					yaw = math.pi/2
				end
			else
				if textflip then
					yaw = math.pi
				else
					yaw = 0
				end
			end
			spos = vector.offset(pos, 0, 0.5 - TEXT_ENTITY_OFFSET, 0)
		elseif dir.y <= -1 then
			-- Floor sign
			local textflip = meta:get_int("textflip") == 1
			pitch = -math.pi/2
			if r90 then
				if textflip then
					yaw = -math.pi/2
				else
					yaw = math.pi/2
				end
			else
				if textflip then
					yaw = math.pi
				else
					yaw = 0
				end
			end
			spos = vector.offset(pos, 0, -0.5 + TEXT_ENTITY_OFFSET, 0)
		else
			-- Wall sign
			yaw = minetest.dir_to_yaw(dir)
			pitch = 0
			spos = vector.add(pos, dir * (0.5 - TEXT_ENTITY_OFFSET))
		end
	end
	return {
		text = text,
		text_back = text_back,
		pitch = pitch,
		yaw = yaw,
		node = node,
		text_pos = spos,
		text_pos_back = spos_back,
		image = image,
		image_w = image_w,
		image_h = image_h,
		image_back = image_back,
		image_back_w = image_back_w,
		image_back_h = image_back_h,
	}
end

local function update_sign(pos, text_front, text_back)
        local data = get_signdata(pos)
        if not data then
		return
	end
	if not text_front then
		text_front = data.text
	end
	if not text_back then
		text_back = data.text_back
	end
	if not text_front or not text_back then
		make_text_texture("", pos, false)
		make_text_texture("", pos, true)
		remove_text_entities(pos)
		return
	end
	if text_front == "" and text_back == "" then
		make_text_texture("", pos, false)
		make_text_texture("", pos, true)
		remove_text_entities(pos)
		return
	end

	-- Check if we can write to both sides of the sign
	local node = minetest.get_node(pos)
	local g_standing = minetest.get_item_group(node.name, "sign_standing")
	local standing = g_standing == 1 or g_standing == 2
	local sideways = minetest.get_item_group(node.name, "sign_side") == 1
	-- Standing, hanging and sideways signs are writable both sides
	local both_sides = standing or sideways

        local front_entity, back_entity = get_text_entity(pos, both_sides)

	local spawn_entity = function(pos, front)
		-- Spawn entity
		local sdata = {
			-- We need to provide the entity the hash of the sign
			-- node position to which this entity belongs to.
			-- An entity without associated sign node is invalid.
			sign_pos_hash = minetest.hash_node_position(pos),
			front = front,
		}
		local staticdata = minetest.serialize(sdata)
		local text_pos
		if front then
			text_pos = data.text_pos
		else
			text_pos = data.text_pos_back
		end
                local entity = minetest.add_entity(text_pos, "rp_signs:sign_text", staticdata)
                if not entity or not entity:get_pos() then
			return
		end
		return entity
	end
	if not front_entity then
		front_entity = spawn_entity(pos, true)
                if not front_entity then
			return
		end
	end
	if both_sides and not back_entity then
		back_entity = spawn_entity(pos, false)
                if not back_entity then
			return
		end
	end

	-- Regenerate image if not initialized yet
	local gen_fails = 0
        if data.image == "" then
                if make_text_texture(text_front, pos, true) then
                        data = get_signdata(pos)
                else
			gen_fails = gen_fails + 1
                end
        end
        if both_sides and data.image_back == "" then
                if make_text_texture(text_back, pos, false) then
                        data = get_signdata(pos)
                else
			gen_fails = gen_fails + 1
                end
        end
	if (not both_sides and gen_fails >= 1) or (both_sides and gen_fails >= 2) then
		remove_text_entities(pos)
		return
	end

	local generate_texture_string = function(front, invert_color)
		local image, image_h, image_w
		if front then
			image = data.image
			image_h = data.image_h
			image_w = data.image_w
		else
			image = data.image_back
			image_h = data.image_back_h
			image_w = data.image_back_w
		end
		local invert_str = ""
		if invert_color then
			invert_str = "^[invert:rgb"
		end
		if image == nil or image == META_IMAGE_EMPTY or image == "" then
			-- Empty image
			return "blank.png", false
		elseif (image_w > SIGN_MAX_TEXT_WIDTH_PIXELS) or (image_h > SIGN_MAX_TEXT_HEIGHT_PIXELS) then
			-- If the image is soo large it starts to become near-unreadable,
			-- we will display a special 'gibberish' texture instead.
			return "rp_default_sign_gibberish.png"..invert_str, false
		else
			-- This will render the PNG from the provided image data
			local tex = "[png:"..image..invert_str

			-- If texture string is very long, replace it with a special gibberish texture.
			-- Minetest has a length limit for object texture strings. Minetest
			-- does not like if when it is exceeded. So we create a warning.
			if string.len(tex) > MAX_TEXTURE_STRING_LENGTH then
				return "rp_default_sign_gibberish.png"..invert_str, false
			end

			-- Everything is OK
			return tex, true
		end
	end
	-- Invert the color if the sign text is white.
	-- This assumes the default text color is black.
	local invert_color
	do
		local meta = minetest.get_meta(pos)
		invert_color = meta:get_int("white_text") == 1
	end
        local imagestr_front, change_ratio_front = generate_texture_string(true, invert_color)
        local imagestr_back, change_ratio_back = generate_texture_string(false, invert_color)

	local get_effective_size = function(width, height, change_ratio)
		if not height or not width then
			return
		end
		if height <= 0 or width <= 0 then
			return
		end
		local ewidth, eheight
		if change_ratio then
			local ratio = width/height
			-- Adjust entity height or width so that the aspect ratio of
			-- TEXT_ENTITY_ASPECT_RATIO is preserved to avoid ugly stretching
			-- of the font.
			if ratio < TEXT_ENTITY_ASPECT_RATIO then
				ewidth = TEXT_ENTITY_WIDTH * (ratio / TEXT_ENTITY_ASPECT_RATIO)
				eheight = TEXT_ENTITY_HEIGHT
			else
				ewidth = TEXT_ENTITY_WIDTH
				eheight = TEXT_ENTITY_HEIGHT / (ratio / TEXT_ENTITY_ASPECT_RATIO)
			end
		else
			ewidth = TEXT_ENTITY_WIDTH
			eheight = TEXT_ENTITY_HEIGHT
		end
		return ewidth, eheight
	end

	local ewidth_front, eheight_front = get_effective_size(data.image_w, data.image_h, change_ratio_front)

	if both_sides then

		front_entity:set_rotation({x=data.pitch, y=data.yaw+math.pi, z=0})
		back_entity:set_rotation({x=data.pitch, y=data.yaw, z=0})

		local ewidth_back, eheight_back = get_effective_size(data.image_back_w, data.image_back_h, change_ratio_back)
		if not ewidth_front then
			imagestr_front = "blank.png"
		end
		if not ewidth_back then
			imagestr_back = "blank.png"
		end

		-- Text appears on both sides
		front_entity:set_properties({
			textures = {
				"blank.png", imagestr_front,
			},
			visual_size = { x = ewidth_front, y = eheight_front, z = SIGN_THICKNESS+1/128 },
		})
		back_entity:set_properties({
			textures = {
				"blank.png", imagestr_back,
			},
			visual_size = { x = ewidth_back, y = eheight_back, z = SIGN_THICKNESS+1/128 },
		})
	else
		front_entity:set_rotation({x=data.pitch, y=data.yaw, z=0})

		if not ewidth_front then
			remove_text_entities(pos)
			return
		end

		front_entity:set_properties({
			visual = "upright_sprite",
			textures = {
				"blank.png",
				imagestr_front,
			},
			visual_size = { x = ewidth_front, y = eheight_front },
		})
	end
        return
end

local function crop_text(txt)
	if not txt then
		return ""
	end
	return unicode_text.utf8.crop_text(txt, SIGN_MAX_TEXT_LENGTH)
end

-- Formspec pages for sign (different background textures)
local sign_pages = {}
local register_sign_page = function(id, node_names)
	local page_name = "rp_signs:"..id

	local form = rp_formspec.default.version
        form = form .. "size[8.5,4.5]"
	form = form .. rp_formspec.default.boilerplate
	form = form .. "background[0,0;8.5,4.5;ui_formspec_bg_"..id..".png]"
	form = form .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
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

local get_sign_formspec = function(pos, player_pos)
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
		form = form .. "textarea[0.5,1;7.5,1.5;"..elem..";;"..minetest.formspec_escape(text).."]"
	else
		minetest.log("warning", "[rp_signs] No formspec page for sign at "..minetest.pos_to_string(pos, 0)..". Fallback to rp_formspec:field")
		form = rp_formspec.get_page("rp_formspec:field")
	end
	return form
end

local refresh_sign = function(meta, node)
	-- Clear the node formspec from older versions; the formspec is now sent manually
	meta:set_string("formspec", "")

	-- Remove sign infotext
	meta:set_string("infotext", "")
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", "")
	local node = minetest.get_node(pos)
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

	-- Write text
	local meta = minetest.get_meta(pos)
	text = crop_text(text)
	if text ~= "" then
		local made = make_text_texture(text, pos, write_front)
		if made then
			if write_front then
				local text_back = meta:get_string("text_back")
				update_sign(pos, text, text_back)
			else
				local text_front = meta:get_string("text")
				update_sign(pos, text_front, text)
			end
		else
			return
		end
	else
		make_text_texture("", pos, write_front)
		local text_front = meta:get_string("text")
		local text_back = meta:get_string("text_back")
		update_sign(pos, text_front, text_back)
	end

	if write_front then
		meta:set_string("text", text)
	else
		meta:set_string("text_back", text)
	end

	minetest.sound_play({name="rp_default_write_sign", gain=0.2}, {pos=pos, max_hear_distance=16}, true)
	minetest.log("action", "[rp_signs] " .. (player:get_player_name() or "")..
		-- Note: Don't show written sign text in log to prevent log flooding
		" wrote something to a sign at "..minetest.pos_to_string(pos))
	meta:set_string("infotext", "")
end)

local on_destruct = function(pos)
	remove_text_entities(pos)
end

local on_blast = function(pos)
	-- Forces on_destruct to be called,
	-- so the entity is cleaned up.
	minetest.remove_node(pos)
end

local on_rightclick = function(pos, node, clicker, itemstack)
	if clicker and clicker:is_player() then
		-- Don't allow editing if protected
		if minetest.is_protected(pos, clicker:get_player_name()) and
				not minetest.check_player_privs(clicker, "protection_bypass") then
			minetest.record_protection_violation(pos, clicker:get_player_name())
			return itemstack
		end

		local standing = minetest.get_item_group(node.name, "sign_standing") ~= 0
		local sideways = minetest.get_item_group(node.name, "sign_side") ~= 0
		local formspec
		-- Show sign formspec
		if standing or sideways then
			-- Double-sided
			formspec = get_sign_formspec(pos, clicker:get_pos())
		else
			-- Single-sided
			formspec = get_sign_formspec(pos)
		end
		local pos_id = tostring(pos.x).."_"..tostring(pos.y).."_"..tostring(pos.z)
		minetest.show_formspec(clicker:get_player_name(), "rp_signs:sign_"..pos_id, formspec)
	end
	return itemstack
end

-- Change text color to white when painted white
local _after_paint = function(pos)
	local node = minetest.get_node(pos)
	local color = rp_paint.get_color(node)
	local meta = minetest.get_meta(pos)
	local white_text = meta:get_int("white_text")
	if color == rp_paint.COLOR_BLACK then
		if white_text == 1 then
			return
		end
		meta:set_int("white_text", 1)
	else
		if white_text == 0 then
			return
		end
		meta:set_int("white_text", 0)
	end
	local text_front = meta:get_string("text")
	local text_back = meta:get_string("text_back")
	update_sign(pos, text_front, text_back)
end

-- Revert to black text color when removing color
local _after_unpaint = function(pos)
	local meta = minetest.get_meta(pos)
	local white_text = meta:get_int("white_text")
	if white_text == 0 then
		return
	end
	meta:set_int("white_text", 0)
	local text_front = meta:get_string("text")
	local text_back = meta:get_string("text_back")
	update_sign(pos, text_front, text_back)
end

local function register_sign(id, def)
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
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, creative_decoblock = 1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_signs:"..id)
		end,
		on_construct = on_construct,
		on_destruct = on_destruct,
		on_blast = on_blast,
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


			-- Wall sign
			if pointed_thing.under.y == pointed_thing.above.y then
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end

			-- Floor or ceiling sign

			local r90 = false
			local yaw = placer:get_look_horizontal()
			if (yaw > (1/4)*math.pi and yaw < (3/4)*math.pi) or (yaw > (5/4)*math.pi and yaw < (7/4)*math.pi) then
				r90 = true
			end
			local sign_itemstack
			if r90 then
				sign_itemstack = ItemStack("rp_signs:"..id.."_r90")
			else
				sign_itemstack = ItemStack(itemstack)
				sign_itemstack:set_count(1)
			end
			local signpos
			sign_itemstack, signpos = minetest.item_place_node(sign_itemstack, placer, pointed_thing)
			if not signpos then
				return itemstack
			end
			if sign_itemstack:is_empty() then
				itemstack:take_item()
			end

			if (r90 and (yaw > (5/4)*math.pi and yaw < (7/4)*math.pi)) or
					(not r90 and (yaw > math.pi/2) and (yaw < ((3*math.pi)/2))) then
				local signmeta = minetest.get_meta(signpos)
				signmeta:set_int("textflip", 1)
			end
			return itemstack
		end,
		on_rightclick = on_rightclick,
		_after_paint = _after_paint,
		_after_unpaint = _after_unpaint,
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
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, sign_r90=1, not_in_creative_inventory=1, paintable = 2},
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
		_after_paint = _after_paint,
		_after_unpaint = _after_unpaint,
		drop = "rp_signs:"..id,
	}
	minetest.register_node("rp_signs:"..id.."_r90", sdef_r90)

	-- Standing sign
	local base_standing_wallbox = {-0.5+(1/16), -0.5+(4/16), -SIGN_THICKNESS/2, 0.5-(1/16), 0.5-(4/16), SIGN_THICKNESS/2}
	local ssdef = {
		description = def.description_standing,
		_tt_help = S("Write a short message"),
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
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 3, sign=1, sign_standing=1, creative_decoblock = 1, paintable = 2},
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

			local idef = itemstack:get_definition()
			-- Placed on floor or ceiling: Standing or hanging sign
			if pointed_thing.under.y ~= pointed_thing.above.y then
				local sign_itemstack
				sign_itemstack = ItemStack(itemstack)
				if pointed_thing.above.y > pointed_thing.under.y then
					sign_itemstack:set_name("rp_signs:"..id.."_standing")
				else
					sign_itemstack:set_name("rp_signs:"..id.."_hanging")
				end
				sign_itemstack:set_count(1)
				local signpos
				sign_itemstack, signpos = minetest.item_place_node(sign_itemstack, placer, pointed_thing)
				if not signpos then
					rp_sounds.play_place_failed_sound(placer)
					return itemstack
				end
				if sign_itemstack:is_empty() then
					itemstack:take_item()
				end

				if idef and idef.sounds and idef.sounds.place then
					minetest.sound_play(idef.sounds.place, {pos = pointed_thing.above}, true)
				end
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end

			-- Placed at wall: sideway sign
			local sign_itemstack
			sign_itemstack = ItemStack(itemstack)
			sign_itemstack:set_name("rp_signs:"..id.."_side")
			sign_itemstack:set_count(1)
			local signpos
			local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
			local fourdir = minetest.dir_to_fourdir(dir)
			sign_itemstack, signpos = minetest.item_place_node(sign_itemstack, placer, pointed_thing, fourdir)
			if not signpos then
				rp_sounds.play_place_failed_sound(placer)
				return itemstack
			end
			if sign_itemstack:is_empty() then
				itemstack:take_item()
			end

			-- Node sound
			if idef and idef.sounds and idef.sounds.place then
				minetest.sound_play(idef.sounds.place, {pos = pointed_thing.above}, true)
			end
			return minetest.item_place_node(itemstack, placer, pointed_thing)
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
	sdef_p.palette = "rp_paint_palette_32.png"
	sdef_p.groups.paintable = 1
	sdef_p.groups.not_in_creative_inventory = 1
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
	minetest.register_node("rp_signs:"..id.."_painted", sdef_p)

	-- Wall sign, rotated by 90°, painted
	local sdef_r90_p = table.copy(sdef_r90)
	sdef_r90_p.paramtype2 = "colorwallmounted"
	sdef_r90_p.palette = "rp_paint_palette_32.png"
	sdef_r90_p.groups.paintable = 1
	sdef_r90_p.groups.sign_r90 = 1
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
	minetest.register_node("rp_signs:"..id.."_r90_painted", sdef_r90_p)

	-- Standing sign, painted
	local ssdef_p = table.copy(ssdef)
	ssdef_p.description = def.description_standing_painted
	ssdef_p.paramtype2 = "color4dir"
	ssdef_p.palette = "rp_paint_palette_64.png"
	ssdef_p.groups.paintable = 1
	ssdef_p.groups.sign_standing = 1
	ssdef_p.groups.not_in_creative_inventory = 1
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
	minetest.register_node("rp_signs:"..id.."_standing_painted", ssdef_p)

	-- Hanging sign, painted
	local shdef_p = table.copy(shdef)
	shdef_p.description = nil
	shdef_p.paramtype2 = "color4dir"
	shdef_p.palette = "rp_paint_palette_64.png"
	shdef_p.groups.paintable = 1
	shdef_p.groups.sign_standing = 2
	shdef_p.groups.not_in_creative_inventory = 1
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
	minetest.register_node("rp_signs:"..id.."_hanging_painted", shdef_p)

	-- Sideways sign, painted
	local stsdef_p = table.copy(stsdef)
	stsdef_p.description = nil
	stsdef_p.paramtype2 = "color4dir"
	stsdef_p.palette = "rp_paint_palette_64.png"
	stsdef_p.groups.paintable = 1
	stsdef_p.groups.not_in_creative_inventory = 1
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
	initial_properties = {
		pointable = false,
		visual = "upright_sprite",
		-- Initialize textures with a special 'loading' image to
		-- catch mistakes and errors early.
		-- This makes entity visible in case it appears somewhere where
		-- it shouldn't or it fails to be updated.
		-- The textures should be immediately updated after the entity
		-- was spawned, so the player should normally not see them
		-- except maybe in case of extreme lag.
		textures = {"rp_default_text_entity_loading.png", "rp_default_text_entity_loading.png"},
		physical = false,
		collide_with_objects = false,
		visual_size = {x = TEXT_ENTITY_WIDTH, y = TEXT_ENTITY_HEIGHT },
        },
        on_activate = function(self, staticdata)
		self.object:set_armor_groups({ immortal = 1 })

		local data
		if staticdata then
			data = minetest.deserialize(staticdata)
		end
		local node_pos, front
		if data and data.sign_pos_hash then
			node_pos = minetest.get_position_from_hash(data.sign_pos_hash)
		end
		if data and data.front ~= nil then
			front = data.front
		end
		self._front = front

		local node
		if node_pos then
			node = minetest.get_node(node_pos)
			self._sign_pos = node_pos

			-- Remove entity if it's a duplicate
			if has_duplicate_entity(self._sign_pos) then
				local pos = self.object:get_pos()
				self.object:remove()
				minetest.log("action", "[rp_signs] Removed duplicate sign text entity at "..minetest.pos_to_string(pos, 1))
				return
			end
		end

		-- Remove entity if no matching sign node
		if not node or minetest.get_item_group(node.name, "sign") == 0 then
			local pos = self.object:get_pos()
			self.object:remove()
			minetest.log("action", "[rp_signs] Removed orphan sign text entity at "..minetest.pos_to_string(pos, 1))
			return
		end
        end,
	get_staticdata = function(self)
		local data = {}
		if self._sign_pos then
			local hash = minetest.hash_node_position(self._sign_pos)
			-- Remember the position of the sign this entity belongs to
			data.sign_pos_hash = hash
		end
		if self._front ~= nil then
			data.front = self._front
		end
		local str = minetest.serialize(data)
		return str
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

dofile(minetest.get_modpath("rp_signs").."/crafting.lua")

minetest.register_lbm({
        label = "Restore sign text entities",
        name = "rp_signs:restore_sign_entities",
        nodenames = {"group:sign"},
        run_at_every_load = true,
        action = function(pos)
                update_sign(pos)
        end
})

-- Update sign formspecs/infotexts
minetest.register_lbm({
	label = "Update signs",
	name = "rp_signs:update_signs_3_14_0",
	nodenames = {"group:sign"},
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		refresh_sign(meta, node)
	end
})
