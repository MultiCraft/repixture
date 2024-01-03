local S = minetest.get_translator("rp_paint")

rp_paint = {}

local COLOR_NAMES = {
	S("White"), S("Gray"), S("Black"), S("Red"), S("Orange"), S("Tangerine"), S("Yellow"), S("Lime"), S("Green"), S("Bluegreen"), S("Turquoise"), S("Cyan"), S("Skyblue"), S("Azure Blue"), S("Blue"), S("Violet"), S("Magenta"), S("Redviolet"), S("Hot Pink"),
}

rp_paint.COLOR_COUNT = #COLOR_NAMES

rp_paint.COLOR_WHITE = 1
rp_paint.COLOR_GRAY = 2
rp_paint.COLOR_BLACK = 3
rp_paint.COLOR_RED = 4
rp_paint.COLOR_ORANGE = 5
rp_paint.COLOR_TANGERINE = 6
rp_paint.COLOR_YELLOW = 7
rp_paint.COLOR_LIME = 8
rp_paint.COLOR_GREEN = 9
rp_paint.COLOR_BLUEGREEN = 10
rp_paint.COLOR_TURQUOISE = 11
rp_paint.COLOR_CYAN = 12
rp_paint.COLOR_SKYBLUE = 13
rp_paint.COLOR_AZURE_BLUE = 14
rp_paint.COLOR_BLUE = 15
rp_paint.COLOR_VIOLET = 16
rp_paint.COLOR_MAGENTA = 17
rp_paint.COLOR_REDVIOLET = 18
rp_paint.COLOR_HOT_PINK = 19

local FACEDIR_COLOR_WHITE = 0
local FACEDIR_COLOR_GRAY = 1
local FACEDIR_COLOR_RED = 2
local FACEDIR_COLOR_ORANGE = 3
local FACEDIR_COLOR_YELLOW = 4
local FACEDIR_COLOR_GREEN = 5
local FACEDIR_COLOR_BLUE = 6
local FACEDIR_COLOR_VIOLET = 7

local facedir_color_map = {
	[rp_paint.COLOR_WHITE] = FACEDIR_COLOR_WHITE,
	[rp_paint.COLOR_GRAY] = FACEDIR_COLOR_GRAY,
	[rp_paint.COLOR_BLACK] = FACEDIR_COLOR_GRAY,
	[rp_paint.COLOR_RED] = FACEDIR_COLOR_RED,
	[rp_paint.COLOR_ORANGE] = FACEDIR_COLOR_ORANGE,
	[rp_paint.COLOR_TANGERINE] = FACEDIR_COLOR_ORANGE,
	[rp_paint.COLOR_YELLOW] = FACEDIR_COLOR_YELLOW,
	[rp_paint.COLOR_LIME] = FACEDIR_COLOR_YELLOW,
	[rp_paint.COLOR_GREEN] = FACEDIR_COLOR_GREEN,
	[rp_paint.COLOR_BLUEGREEN] = FACEDIR_COLOR_GREEN,
	[rp_paint.COLOR_TURQUOISE] = FACEDIR_COLOR_GREEN,
	[rp_paint.COLOR_CYAN] = FACEDIR_COLOR_BLUE,
	[rp_paint.COLOR_SKYBLUE] = FACEDIR_COLOR_BLUE,
	[rp_paint.COLOR_AZURE_BLUE] = FACEDIR_COLOR_BLUE,
	[rp_paint.COLOR_BLUE] = FACEDIR_COLOR_BLUE,
	[rp_paint.COLOR_VIOLET] = FACEDIR_COLOR_VIOLET,
	[rp_paint.COLOR_MAGENTA] = FACEDIR_COLOR_VIOLET,
	[rp_paint.COLOR_REDVIOLET] = FACEDIR_COLOR_RED,
	[rp_paint.COLOR_HOT_PINK] = FACEDIR_COLOR_RED,
}

local BRUSH_USES = 550

local BUCKET_HEIGHT_ABOVE_ZERO = 5/16
local BUCKET_RADIUS = 6/16

rp_paint.get_color = function(node)
	local color
	local def = minetest.registered_nodes[node.name]
	if not def then
		return nil
	end
	if def.paramtype2 == "color" then
		color = node.param2 + 1
	elseif def.paramtype2 == "color4dir" then
		color = math.floor(node.param2 / 4) + 1
	elseif def.paramtype2 == "colorwallmounted" then
		color = math.floor(node.param2 / 8) + 1
	elseif def.paramtype2 == "colorfacedir" then
		local pre_color = math.floor(node.param2 / 32) + 1
		color = facedir_color_map[pre_color] + 1
	end
	if color < 1 or color > rp_paint.COLOR_COUNT then
		return nil
	end
	return color
end

local get_param2_color = function(node, color)
	local def = minetest.registered_nodes[node.name]
	if not def then
		return nil
	end

	color = color-1

	if def.paramtype2 == "colorfacedir" then
		color = facedir_color_map[color+1]
	end
	if (not color) or color < 0 or color > rp_paint.COLOR_COUNT then
		color = 0
	end
	local new_param2
	if def.paramtype2 == "color" then
		new_param2 = color
	elseif def.paramtype2 == "color4dir" then
		local rot = node.param2 % 4
		new_param2 = color*4 + rot
	elseif def.paramtype2 == "colorwallmounted" then
		local rot = node.param2 % 8
		new_param2 = color*8 + rot
	elseif def.paramtype2 == "colorfacedir" then
		local rot = node.param2 % 32
		new_param2 = color*32 + rot
	else
		-- Node coloring is unsupported. Do nothing
		return nil
	end
	return new_param2
end

rp_paint.set_color = function(pos, color)
	local node = minetest.get_node(pos)
	local paintable = minetest.get_item_group(node.name, "paintable")
	if paintable == 0 then
		return
	end
	local def = minetest.registered_nodes[node.name]

	local can_paint = true

	if paintable == 2 then
		if def._rp_painted_node_name then
			node.name = def._rp_painted_node_name
		else
			node.name = node.name .. "_painted"
		end
	end
	local p2color = get_param2_color(node, color)
	node.param2 = p2color
	if def._on_paint then
		can_paint = def._on_paint(pos, p2color)
		if can_paint == nil then
			can_paint = true
		end
	end
	if can_paint then
		minetest.swap_node(pos, node)
		return true
	end
	return false
end

rp_paint.remove_color = function(pos)
	local node = minetest.get_node(pos)
	local paintable = minetest.get_item_group(node.name, "paintable")
	if paintable == 1 then
		local olddef = minetest.registered_nodes[node.name]
		if not olddef then
			return false
		end
		-- Check if there is an 'unpainted' version of the node
		if olddef._rp_unpainted_node_name or string.sub(node.name, -8, -1) == "_painted" then
			local newname
			if olddef._rp_unpainted_node_name then
				-- If name of unpainted node name was specified explicitly,
				-- use that one
				newname = olddef._rp_unpainted_node_name
			else
				-- Default: Remove "_painted" suffix
				newname = string.sub(node.name, 1, -9)
			end
			local newdef = minetest.registered_nodes[newname]
			if olddef and newdef then
				local param2 = 0
				if olddef.paramtype2 == "color4dir" then
					param2 = node.param2 % 4
				elseif olddef.paramtype2 == "colorwallmounted" then
					param2 = node.param2 % 8
				elseif olddef.paramtype2 == "colorfacedir" then
					param2 = node.param2 % 32
				end
				minetest.swap_node(pos, {name=newname, param2=param2})
				return true
			end
		end
	end
	return false
end

rp_paint.scrape_color = function(pos)
	local scraped  = rp_paint.remove_color(pos)
	if scraped then
		local node = minetest.get_node(pos)
		local def = minetest.registered_nodes[node.name]
		if not def then
			return false
		end
		if def.sounds and def.sounds._rp_scrape then
			minetest.sound_play(def.sounds._rp_scrape, {pos=pos, max_hear_distance=8}, true)
		end
		return true
	end
	return false
end

minetest.register_tool("rp_paint:brush", {
	description = S("Paint Brush"),
	_tt_help = S("Changes color of paintable blocks").."\n"..S("Punch paint bucket to change brush color"),
	inventory_image = "rp_paint_brush.png",
	inventory_overlay = "rp_paint_brush_overlay.png",
	wield_image = "rp_paint_brush.png",
	wield_overlay = "rp_paint_brush_overlay.png",
	palette = "rp_paint_palette_256.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing == nil or pointed_thing.type ~= "node" then
			return
		end
		local pos = pointed_thing.under
		if minetest.is_protected(pos, user:get_player_name()) and
			not minetest.check_player_privs(user, "protection_bypass") then
			minetest.record_protection_violation(pos, user:get_player_name())
			return
		end
		local node = minetest.get_node(pos)

		local imeta = itemstack:get_meta()
		-- Get color from paint bucket
		if node.name == "rp_paint:bucket" then
			local color = bit.rshift(node.param2, 2)
			if color > rp_paint.COLOR_COUNT or color < 0 then
				-- Invalid paint bucket color!
				return
			end
			imeta:set_int("palette_index", color)
			minetest.sound_play({name="rp_paint_brush_dip", gain=0.3}, {pos=pos, max_hear_distance = 8}, true)
			return itemstack
		end

		-- Paint paintable node (if not paintable, fail)
		local color = imeta:get_int("palette_index") + 1
		local painted = rp_paint.set_color(pointed_thing.under, color)
		if painted then
			minetest.sound_play({name="rp_paint_brush_paint", gain=0.2}, {pos=pos, max_hear_distance = 8}, true)

			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear_by_uses(BRUSH_USES)
			end
		end
		return itemstack
	end,
	groups = { disable_repair = 1 },
})

minetest.register_node("rp_paint:bucket", {
	description = S("Paint Bucket"),
	_tt_help = S("Use place key to change color").."\n"..S("Point at left/right part to get previous/next color"),

	drawtype = "mesh",
	mesh = "rp_default_bucket.obj",
	tiles = {
		{name="rp_paint_bucket_node_side_1.png",backface_culling=true,color="white"},
		{name="rp_paint_bucket_node_side_2.png",backface_culling=true,color="white"},
		{name="rp_paint_bucket_node_top_handle.png",backface_culling=true,color="white"},
		{name="rp_paint_bucket_node_bottom_inside.png",backface_culling=true,color="white"},
		{name="rp_paint_bucket_node_bottom_outside.png",backface_culling=true,color="white"},
		"rp_paint_bucket_node_paint.png",
	},
	overlay_tiles = {
		"","","","","","rp_paint_bucket_node_paint.png",
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "color4dir",
	palette = "rp_paint_palette_64.png",
	is_ground_content = false,
	selection_box = {
		type = "fixed",
		fixed = { -BUCKET_RADIUS, -0.5, -BUCKET_RADIUS, BUCKET_RADIUS, BUCKET_HEIGHT_ABOVE_ZERO, BUCKET_RADIUS },
	},
	sounds = rp_sounds.node_sound_metal_defaults(),
	walkable = false,
	floodable = true,
	on_flood = function(pos, oldnode, newnode)
		minetest.add_item(pos, "rp_paint:bucket")
	end,

	inventory_image = "rp_paint_bucket.png",
	wield_image = "rp_paint_bucket.png",
	wield_scale = {x=1,y=1,z=2},
	groups = { bucket = 3, tool = 1, dig_immediate = 3, attached_node = 1 },
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Paint Bucket (@1)", COLOR_NAMES[1]))
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		-- Switch color on rightclick
		if not pointed_thing or util.handle_node_protection(clicker, pointed_thing) then
			return
		end
		-- "direction" of color change (1 = next color, -1 = previous color)
		local direction = 1
		if clicker and clicker:is_player() then
			local props = clicker:get_properties()
			local eye_pos = clicker:get_pos()
			eye_pos.y = eye_pos.y + props.eye_height
			eye_pos = vector.add(eye_pos, clicker:get_eye_offset())
			local lookdir = clicker:get_look_dir()
			local handrange = minetest.registered_items[""].range
			lookdir = vector.multiply(lookdir, handrange+1)
			local look_pos = vector.add(eye_pos, lookdir)
			-- do a raycast from the player to the look direction,
			-- using the hand range + 1 as vector length.
			-- (+1 serves as a small buffer)
			-- With this method we can find the precise click location.
			local rc = Raycast(eye_pos, look_pos, false, false)
			local exact_pos
			for rpt in rc do
				if rpt.type == "node" then
					local rptn = minetest.get_node(rpt.under)
					if rptn.name == node.name then
						exact_pos = rpt.intersection_point
						break
					end
				end
			end

			local fine_pos = exact_pos
			-- Fallback if raycast didn't find our paint bucket for some reason
			if not fine_pos then
				fine_pos = minetest.pointed_thing_to_face_pos(clicker, pointed_thing)
				minetest.log("warning", "[rp_paint] "..clicker:get_player_name().." rightclicked paint bucket at "..minetest.pos_to_string(pos).." but the raycast failed to find it. Using less accurate fallback to find click position")
			end
			-- Depending on what was clicked and where the player stood, the paint bucket
			-- will choose either the next or previous color.
			-- Basically, if you click the left side of the face, the previous color
			-- will be selected, and the right side gets you the next color.
			-- The side textures should have subtle engraved small arrows
			if pointed_thing.above.y ~= pointed_thing.under.y then
				local cpos = clicker:get_pos()
				local xdist = math.abs(pos.x-cpos.x)
				local zdist = math.abs(pos.z-cpos.z)
				if xdist > zdist then
					if cpos.x < pos.x then
						if fine_pos.z > pos.z then
							direction = -1
						end
					else
						if fine_pos.z < pos.z then
							direction = -1
						end
					end
				else
					if cpos.z < pos.z then
						if fine_pos.x < pos.x then
							direction = -1
						end
					else
						if fine_pos.x > pos.x then
							direction = -1
						end
					end
				end
			else
				if pointed_thing.above.z < pointed_thing.under.z and fine_pos.x < pos.x then
					direction = -1
				elseif pointed_thing.above.z > pointed_thing.under.z and fine_pos.x > pos.x then
					direction = -1
				elseif pointed_thing.above.x < pointed_thing.under.x and fine_pos.z > pos.z then
					direction = -1
				elseif pointed_thing.above.x > pointed_thing.under.x and fine_pos.z < pos.z then
					direction = -1
				end

			end
		end
		local rot = node.param2 % 4
		local color = bit.rshift(node.param2, 2)
		color = color + direction
		if color >= rp_paint.COLOR_COUNT then
			color = 0
		elseif color < 0 then
			color = rp_paint.COLOR_COUNT - 1
		end
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Paint Bucket (@1)", COLOR_NAMES[color+1]))
		node.param2 = color*4 + rot
		minetest.swap_node(pos, node)
		minetest.sound_play({name="rp_paint_bucket_select_color", gain=0.15}, {pos = pos}, true)
	end,
	-- Erase node metadata (e.g. palette_index) on drop
	drop = "rp_paint:bucket",
})

crafting.register_craft({
	output = "rp_paint:bucket",
	items = {
		"rp_default:ingot_tin 5",
		"rp_default:flower 4",
	},
})


crafting.register_craft({
	output = "rp_paint:brush",
	items = {
		"rp_default:stick",
		"rp_farming:cotton 3",
	},
})
