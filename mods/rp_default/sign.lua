local S = minetest.get_translator("rp_default")

-- Maximum number of characters on a sign
local SIGN_MAX_TEXT_LENGTH = 500
-- Compression method for text entity texture
local COMPMETHOD = "deflate"

-- Sign thickness in node units
local SIGN_THICKNESS = 1/16

-- Offset from text entity from sign node border
local TEXT_ENTITY_OFFSET = SIGN_THICKNESS + 1/64

-- Special string for metadata key "image" to denote empty image.
-- Must not collide with base64 characters.
-- Note the empty string stands for an undefined/uninitialized
-- image.
local META_IMAGE_EMPTY = "!"


-- Load font
local font = unicode_text.hexfont({
        background_color = { 0, 0, 0, 0 }, --transparent
        foreground_color = { 0, 0, 0, 255 }, -- black
        kerning = false,
   }
)
local fontpath = minetest.get_modpath("rp_default").."/fontdata"
font:load_glyphs(
	io.lines(fontpath.."/unifont.hex")
)
font:load_glyphs(
	io.lines(fontpath.."/unifont_upper.hex")
)
font:load_glyphs(
	io.lines(fontpath.."/plane00csur.hex")
)
font:load_glyphs(
	io.lines(fontpath.."/plane0Fcsur.hex")
)

local function crop_utf8_text(txt)
        local bytes = 1
        local str = ""
        local chars = 0
        local final_string = ""
        for i = 1, txt:len() do
                local byte = txt:sub(i, i)
                if bytes ~= 1 then
                        bytes = bytes - 1
                        str = str .. byte
                        if bytes == 1 then
                                if chars < SIGN_MAX_TEXT_LENGTH then
                                        final_string = final_string .. str
                                        chars = chars + 1
                                else
                                        break
                                end
                                str = ""
                        end
                else
                        local octal = string.format('%o', string.byte(byte))
                        -- Remove leading zeroes
                        -- TODO: find out if it's needed (works without it)
                        if octal:find("^0") ~= nil then
                                octal = octal:sub(2, octal:len())
                        elseif octal:find("^00") ~= nil then
                                octal = octal:sub(3, octal:len())
                        end
                        -- Four bytes
                        if octal:find("^36") ~= nil or octal:find("^37") ~= nil then
                                bytes = 4
                                str = str .. byte
                        -- Three bytes
                        elseif octal:find("^34") ~= nil or octal:find("^35") ~= nil then
                                bytes = 3
                                str = str .. byte
                        -- Two bytes
                        elseif octal:find("^33") ~= nil or octal:find("^32") ~= nil or octal:find("^31") ~= nil or octal:find("^30") ~= nil then
                                bytes = 2
                                str = str .. byte
                        -- Assume everything else is one byte
                        else
                                bytes = 1
                                str = ""
                                if chars < SIGN_MAX_TEXT_LENGTH then
                                        final_string = final_string .. byte
                                        chars = chars + 1
                                else
                                        break
                                end
                        end
                end
        end
        return final_string
end

local function make_text_texture(text, pos)
        if not text then
		return false
	end
	if text == "" then
		local meta = minetest.get_meta(pos)
		meta:set_string("image", META_IMAGE_EMPTY)
		return true
	end
        local pixels
        local success, pixels = pcall(function()
                return font:render_text(text) --this often crashes on unexpected input
        end)
        if success and pixels then
                local image = tga_encoder.image(pixels)
                image.pixel_depth = 32
                image:encode({
                        colormap = {},
                        compression = 'RLE',
                        color_format = 'B8G8R8A8'
                })
                local meta = minetest.get_meta(pos)
                local compressed_string = minetest.encode_base64(minetest.compress(minetest.encode_base64(image.data), COMPMETHOD))
                meta:set_string("image", compressed_string)
                return true
        else
		minetest.log("error", "[rp_default] Error when calling render_text for: "..tostring(text).." (error: "..tostring(pixels)..")")
		return false
	end
end

local function get_text_entity(pos, force_remove)
        local objects = minetest.get_objects_inside_radius(pos, 0.5)
        local text_entity
        for _, v in pairs(objects) do
                local ent = v:get_luaentity()
                if ent and ent.name == "rp_default:sign_text" then
                        if force_remove == true then
                                v:remove()
                        else
                                text_entity = v
                                break
                        end
                end
        end
        return text_entity
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
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text")
	local image = meta:get_string("image")
	local yaw, pitch, spos
	local dir = minetest.wallmounted_to_dir(node.param2)
	if dir.y >= 1 then
		-- Ceiling sign
		pitch = math.pi/2
		if r90 then
			yaw = math.pi/2
		else
			yaw = math.pi
		end
		spos = vector.offset(pos, 0, 0.5 - TEXT_ENTITY_OFFSET, 0)
	elseif dir.y <= -1 then
		-- Floor sign
		pitch = -math.pi/2
		if r90 then
			yaw = math.pi/2
		else
			yaw = 0
		end
		spos = vector.offset(pos, 0, -0.5 + TEXT_ENTITY_OFFSET, 0)
	else
		-- Wall sign
		yaw = minetest.dir_to_yaw(dir)
		pitch = 0
		spos = vector.add(pos, dir * (0.5 - TEXT_ENTITY_OFFSET))
	end
	return {
		text = text,
		pitch = pitch,
		yaw = yaw,
		node = node,
		text_pos = spos,
		image = image,
	}
end

local function update_sign(pos, text)
        local data = get_signdata(pos)
        if not data then
		return
	end
	if not text then
		text = data.text
	end
	if not text then
		make_text_texture("", pos)
		get_text_entity(pos, true)
		return
	end
	if text == "" then
		make_text_texture("", pos)
		get_text_entity(pos, true)
		return
	end

        local text_entity = get_text_entity(pos)
        if not text_entity then
                text_entity = minetest.add_entity(data.text_pos, "rp_default:sign_text")
                if not text_entity or not text_entity:get_pos() then
			return
		end
        end

	-- Regenerate image if not initialized yet
        if data.image == "" then
                if make_text_texture(text, pos) then
                        data = get_signdata(pos)
                else
                        get_text_entity(pos, true)
                end
        end

	local encode = function()
		if data.image == nil or data.image == META_IMAGE_EMPTY then
			return "blank.png"
		else
			local decomp = minetest.decompress(minetest.decode_base64(data.image), COMPMETHOD)
			return "[png:"..decomp
		end
	end
        local success, imagestr = pcall(encode)
	if success and imagestr then
		text_entity:set_properties({
			textures = {
				-- only one side is written
				"blank.png",
				imagestr,
			},
		})
	else
		minetest.log("error", "[rp_default] Sign texture decompression failed: "..tostring(imagestr))
		get_text_entity(pos, true)
		return
	end
        text_entity:set_rotation({x=data.pitch, y=data.yaw, z=0})
        return
end

local function crop_text(txt)
        if not txt then
		return ""
	end
        local lines = txt:split("\n")
        local r = {}
        for k, line in ipairs(lines) do
                table.insert(r, crop_utf8_text(line))
        end
        return table.concat(r, "\n")
end




-- Formspec pages for sign (different background textures)
local sign_pages = {}
local register_sign_page = function(id, node_names)
	local page_name = "rp_default:"..id

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

local get_sign_formspec = function(pos)
	local node = minetest.get_node(pos)
	local pagename = sign_pages[node.name]
	local form
	if pagename then
		form = rp_formspec.get_page(pagename)
		form = form .. "set_focus[text;true]"
		local meta = minetest.get_meta(pos)
		local text = meta:get_string("text")
		form = form .. "textarea[0.5,1;7.5,1.5;text;;"..minetest.formspec_escape(text).."]"
	else
		minetest.log("warning", "[rp_default] No formspec page for sign at "..minetest.pos_to_string(pos, 0)..". Fallback to rp_formspec:field")
		form = rp_formspec.get_page("rp_formspec:field")
	end
	return form
end

default.refresh_sign = function(meta, node)
	-- Clear the node formspec from older versions; the formspec is now sent manually
	meta:set_string("formspec", "")

	-- Show sign text in quotation marks
	local text = meta:get_string("text")
	meta:set_string("infotext", S('"@1"', text))
end

local on_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("text", "")
	local node = minetest.get_node(pos)
	default.refresh_sign(meta, node)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 16) ~= "rp_default:sign_" then
		return
	end
	local coords = string.sub(formname, 17)
	local x, y, z = string.match(coords, "([0-9-]+)_([0-9-]+)_([0-9-]+)")
	local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
	if not pos or not pos.x or not pos.y or not pos.z then
		return
	end

	if not fields.text then
		return
	end
	-- Check protection
	if minetest.is_protected(pos, player:get_player_name()) and
			not minetest.check_player_privs(player, "protection_bypass") then
		minetest.record_protection_violation(pos, player:get_player_name())
		return itemstack
	end

	-- Write text
	local meta = minetest.get_meta(pos)
	local text = fields.text
	text = crop_text(text)
	if text ~= "" then
		local texture = make_text_texture(text, pos)
		if texture then
			update_sign(pos, text)
		else
			return
		end
	else
		meta:set_string("image", META_IMAGE_EMPTY)
		get_text_entity(pos, true)
	end

	meta:set_string("text", text)

	minetest.sound_play({name="rp_default_write_sign", gain=0.2}, {pos=pos, max_hear_distance=16}, true)
	minetest.log("action", "[rp_default] " .. (player:get_player_name() or "")..
					" wrote \""..text.."\" to sign at "..
					minetest.pos_to_string(pos))
	-- Show sign text in quotation marks
	meta:set_string("infotext", S('"@1"', text))

	default.write_name(pos, meta:get_string("text"))
end)

local on_destruct = function(pos)
	default.write_name(pos, "")
	get_text_entity(pos, true)
end

local on_rightclick = function(pos, node, clicker, itemstack)
	if clicker and clicker:is_player() then
		-- Don't allow editing if protected
		if minetest.is_protected(pos, clicker:get_player_name()) and
				not minetest.check_player_privs(clicker, "protection_bypass") then
			minetest.record_protection_violation(pos, clicker:get_player_name())
			return itemstack
		end

		-- Show sign formspec
		local formspec = get_sign_formspec(pos)
		local pos_id = tostring(pos.x).."_"..tostring(pos.y).."_"..tostring(pos.z)
		minetest.show_formspec(clicker:get_player_name(), "rp_default:sign_"..pos_id, formspec)
	end
	return itemstack
end

local function register_sign(id, def)
	local sdef = {
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
			wall_top = {-0.5+SIGN_THICKNESS, 0.5, -0.5+(4/16), 0.5-SIGN_THICKNESS, 0.5-SIGN_THICKNESS, 0.5-(4/16)},
			wall_bottom = {-0.5+SIGN_THICKNESS, -0.5, -0.5+(4/16), 0.5-SIGN_THICKNESS, -0.5+SIGN_THICKNESS, 0.5-(4/16)},
			wall_side = {-0.5, -0.5+(4/16), -0.5+SIGN_THICKNESS, -0.5+SIGN_THICKNESS, 0.5-(4/16), 0.5-SIGN_THICKNESS},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, creative_decoblock = 1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_default:"..id)
		end,
		on_construct = on_construct,
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
		on_rightclick = on_rightclick,
	}
	minetest.register_node("rp_default:"..id, sdef)

	local sdef_r90 = {
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
			wall_top = {-0.5+(4/16), 0.5, -0.5+SIGN_THICKNESS, 0.5-(4/16), 0.5-SIGN_THICKNESS, 0.5-SIGN_THICKNESS},
			wall_bottom = {-0.5+(4/16), -0.5, -0.5+SIGN_THICKNESS, 0.5-(4/16), -0.5+SIGN_THICKNESS, 0.5-SIGN_THICKNESS},
			wall_side = {-0.5, -0.5+SIGN_THICKNESS, -0.5+(4/16), -0.5+SIGN_THICKNESS, 0.5-SIGN_THICKNESS, 0.5-(4/16)},
		},
		groups = {choppy = 3,oddly_breakable_by_hand=2,level=-4,attached_node = 1, sign=1, sign_r90=1, not_in_creative_inventory=1, paintable = 2},
		is_ground_content = false,
		sounds = def.sounds,
		floodable = true,
		on_flood = function(pos)
			minetest.add_item(pos, "rp_default:"..id)
		end,
		on_construct = on_construct,
		on_destruct = on_destruct,
		on_rightclick = on_rightclick,
		drop = "rp_default:"..id,
	}
	minetest.register_node("rp_default:"..id.."_r90", sdef_r90)

	local sdef_p = table.copy(sdef)
	sdef_p.description = def.description_painted
	sdef_p.paramtype2 = "colorwallmounted"
	sdef_p.palette = "rp_paint_palette_32.png"
	sdef_p.groups.paintable = 1
	sdef_p.groups.not_in_creative_inventory = 1
	sdef_p.tiles = { def.tile_painted }
	sdef_p.inventory_image = def.inv_image.."^[hsl:0:-100:0"
	sdef_p.wield_image = def.inv_image.."^[hsl:0:-100:0"
	sdef_p.drop = "rp_default:"..id
	minetest.register_node("rp_default:"..id.."_painted", sdef_p)

	local sdef_r90_p = table.copy(sdef_r90)
	sdef_r90_p.paramtype2 = "colorwallmounted"
	sdef_r90_p.palette = "rp_paint_palette_32.png"
	sdef_r90_p.groups.paintable = 1
	sdef_r90_p.groups.sign_r90 = 1
	sdef_r90_p.tiles = { "("..def.tile_painted..")^[transformR90" }
	sdef_r90_p.inventory_image = "("..def.inv_image..")^[transformR90^[hsl:0:-100:0"
	sdef_r90_p.wield_image = "("..def.inv_image..")^[transformR90^[hsl:0:-100:0"
	sdef_r90_p.drop = "rp_default:"..id
	minetest.register_node("rp_default:"..id.."_r90_painted", sdef_r90_p)

	register_sign_page(id, {"rp_default:"..id, "rp_default:"..id.."_r90", "rp_default:"..id.."_painted", "rp_default:"..id.."_r90_painted"})
end

minetest.register_lbm({
        label = "Restore sign text entities",
        name = "rp_default:restore_sign_entities",
        nodenames = {"group:sign"},
        run_at_every_load = true,
        action = function(pos)
                update_sign(pos)
        end
})

minetest.register_entity("rp_default:sign_text", {
        initial_properties = {
                pointable = false,
                visual = "upright_sprite",
                -- Textures must be updated after entity was spawned
                textures = {"blank.png", "blank.png"},
                physical = false,
                collide_with_objects = false,
                visual_size = {x = 12/16, y = 6/16, z = 12/16},
        },
        on_activate = function(self)
		self.object:set_armor_groups({ immortal = 1 })

		-- Remove entity if no matching sign node
		local pos = self.object:get_pos()
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "sign") == 0 then
			self.object:remove()
			minetest.log("action", "[rp_default] Removed orphan sign text entity at "..minetest.pos_to_string(pos, 1))
			return
		end
        end,
})

local sounds_wood_sign = rp_sounds.node_sound_planks_defaults({
	footstep = {},
	dig = { name = "rp_sounds_dig_wood", pitch = 1.5, gain = 0.5 },
	dug = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.7 },
	fall = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.6 },
	place = { name = "rp_sounds_place_planks", pitch = 1.4, gain = 0.9 },
})

register_sign("sign", {
	description = S("Wooden Sign"),
	description_painted = S("Painted Wooden Sign"),
	tile = "default_sign.png",
	tile_painted = "rp_default_sign_painted.png",
	inv_image = "default_sign_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_oak", {
	description = S("Oak Sign"),
	description_painted = S("Painted Oak Sign"),
	tile = "rp_default_sign_oak.png",
	tile_painted = "rp_default_sign_oak_painted.png",
	inv_image = "rp_default_sign_oak_inventory.png",
	sounds = sounds_wood_sign,
})
register_sign("sign_birch", {
	description = S("Birch Sign"),
	description_painted = S("Painted Birch Sign"),
	tile = "rp_default_sign_birch.png",
	tile_painted = "rp_default_sign_birch_painted.png",
	inv_image = "rp_default_sign_birch_inventory.png",
	sounds = sounds_wood_sign,
})
