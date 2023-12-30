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

local BRUSH_USES = 100

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

		-- Get color from paint bucket
		if node.name == "rp_paint:bucket" then
			local color = bit.rshift(node.param2, 2)
			if color > rp_paint.COLOR_COUNT or color < 0 then
				-- Invalid paint bucket color!
				return
			end
			local imeta = itemstack:get_meta()
			imeta:set_int("palette_index", color)
			minetest.sound_play({name="rp_paint_brush_dip", gain=0.3}, {pos=pos, max_hear_distance = 8}, true)
			return itemstack
		end

		-- Paint paintable node (if not paintable, fail)
		local paintable = minetest.get_item_group(node.name, "paintable")
		if paintable == 0 then
			return
		end

		if paintable == 2 then
			node.name = node.name .. "_painted"
			minetest.swap_node(pos, node)
		end
		local def = minetest.registered_nodes[node.name]

		local imeta = itemstack:get_meta()
		local color = imeta:get_int("palette_index")
		if color > rp_paint.COLOR_COUNT then
			color = 0
		end
		if def.paramtype2 == "color" then
			node.param2 = color
		elseif def.paramtype2 == "color4dir" then
			local rot = node.param2 % 4
			node.param2 = color*4 + rot
		elseif def.paramtype2 == "colorwallmounted" then
			local rot = node.param2 % 8
			node.param2 = color*8 + rot
		elseif def.paramtype2 == "colorfacedir" then
			-- TODO
			return
		else
			-- Node coloring is unsupported. Do nothing
			return
		end

		local can_paint = true
		if def._on_paint then
			can_paint = def._on_paint(pointed_thing.under, node.param2)
			if can_paint == nil then
				can_paint = true
			end
		end
		if can_paint then
			minetest.swap_node(pointed_thing.under, node)
			minetest.sound_play({name="rp_paint_brush", gain=0.4}, {pos=pos, max_hear_distance = 8}, true)

			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear_by_uses(BRUSH_USES)
			end
		end
		minetest.sound_play({name="rp_paint_brush_paint", gain=0.2}, {pos = pos, max_hear_distance = 8}, true)
		return itemstack
	end,
	groups = { disable_repair = 1 },
})

minetest.register_node("rp_paint:bucket", {
	description = S("Paint Bucket"),
	_tt_help = "Use to change paint color",

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
		fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
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
		local rot = node.param2 % 4
		local color = bit.rshift(node.param2, 2)
		color = color + 1
		if color >= rp_paint.COLOR_COUNT then
			color = 0
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
