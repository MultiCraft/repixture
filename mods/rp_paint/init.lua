local S = minetest.get_translator("rp_paint")

local GRAVITY = tonumber(minetest.settings:get("movement_gravity") or 9.81)

local BRUSH_USES = 11100 -- number of times a brush can be used before breaking
local BRUSH_PAINTS = 111 -- number of times a brush can paint before running out

local BUCKET_HEIGHT_ABOVE_ZERO = 5/16
local BUCKET_RADIUS = 6/16
local BUCKET_LEVELS = 9 -- number of possible "paint levels" in the paint bucket (not counting the empty state)
local BUCKET_FLOWER_ADD = 3 -- number of paint levels added by a single flower

rp_paint = {}

local COLOR_NAMES = {
	S("White"), S("Gray"), S("Black"), S("Red"), S("Orange"), S("Amber"), S("Yellow"), S("Lime"), S("Green"), S("Bluegreen"), S("Turquoise"), S("Cyan"), S("Skyblue"), S("Azure Blue"), S("Blue"), S("Violet"), S("Magenta"), S("Redviolet"), S("Hot Pink"),
}

local COLOR_HEXCODES = {
	"#FFFFFF", -- white
	"#A9A9A9", -- gray
	"#545454", -- black
	"#DE4646", -- red
	"#DE7246", -- orange
	"#DEAB46", -- amber
	"#DFDF46", -- yellow
	"#9DDE46", -- lime
	"#63DE46", -- green
	"#46DE63", -- bluegreen
	"#46DE9D", -- turquiose
	"#46DED7", -- cyan
	"#46ABDE", -- skyblue
	"#4672DE", -- azure blue
	"#4646DE", -- blue
	"#8E46DE", -- violet
	"#D746DE", -- magenta
	"#DE46AB", -- redviolet
	"#DE4671", -- hot pink
}

rp_paint.COLOR_COUNT = #COLOR_NAMES

rp_paint.COLOR_WHITE = 1
rp_paint.COLOR_GRAY = 2
rp_paint.COLOR_BLACK = 3
rp_paint.COLOR_RED = 4
rp_paint.COLOR_ORANGE = 5
rp_paint.COLOR_AMBER = 6
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
	[rp_paint.COLOR_AMBER] = FACEDIR_COLOR_ORANGE,
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

local change_bucket_level = function(pos, node, level_change)
	local paint_level = minetest.get_item_group(node.name, "paint_bucket")
	if paint_level <= 0 then
		return 0
	end
	paint_level = paint_level - 1
	local old_paint_level = paint_level
	level_change = math.floor(level_change)
	paint_level = paint_level + level_change
	paint_level = math.max(0, math.min(BUCKET_LEVELS, paint_level))
	if paint_level >= BUCKET_LEVELS then
		node.name = "rp_paint:bucket"
	else
		node.name = "rp_paint:bucket_"..paint_level
	end
	if old_paint_level == paint_level then
		-- No level change
		return 0
	end
	minetest.swap_node(pos, node)
	if paint_level == 0 then
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Paint Bucket (Empty)"))
	elseif old_paint_level == 0 and paint_level > 0 then
		local meta = minetest.get_meta(pos)
		local color = bit.rshift(node.param2, 2)
		meta:set_string("infotext", S("Paint Bucket (@1)", COLOR_NAMES[color+1]))
	end
	-- Return actual level change
	return paint_level - old_paint_level
end

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
	if not color or color < 1 or color > rp_paint.COLOR_COUNT then
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
		if def._after_paint then
			def._after_paint(pos)
		end
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
				local can_unpaint = true
				local newnode = {name=newname, param2=param2}
				if olddef._on_unpaint then
					can_unpaint = olddef._on_unpaint(pos, newnode)
					if can_unpaint == nil then
						can_unpaint = true
					end
				end

				if can_unpaint then
					minetest.swap_node(pos, newnode)
					if olddef._after_unpaint then
						olddef._after_unpaint(pos)
					end
					return true
				end
			end
		end
	end
	return false
end

rp_paint.add_scrape_particles = function(pos, oldnode, direction)
	local olddef = minetest.registered_nodes[oldnode.name]
	if not olddef then
		return false
	end
	local ptype = olddef._rp_paint_particle_pos
	local rpos = table.copy(pos)
	-- Spawn particles where we scrape
	local offset1, offset2
	local SQ = 0.48 -- "radius" of square
	local H1 = 0.48 -- min. distance from node
	local H2 = 0.49 -- max. distance from node
	if ptype == "cube_inside" then
		offset1 = {x=-SQ, y=-SQ, z=-SQ}
		offset2 = {x=SQ, y=SQ, z=SQ}
		rpos = vector.subtract(rpos, direction)
	elseif direction.y > 0 then
		offset1 = {x=-SQ, y=-H2, z=-SQ}
		offset2 = {x=SQ, y=-H1, z=SQ}
	elseif direction.y < 0 then
		offset1 = {x=-SQ, y=H1, z=-SQ}
		offset2 = {x=SQ, y=H2, z=SQ}
	elseif direction.x > 0 then
		offset1 = {x=-H2, y=-SQ, z=-SQ}
		offset2 = {x=-H1, y=SQ, z=SQ}
	elseif direction.x < 0 then
		offset1 = {x=H1, y=-SQ, z=-SQ}
		offset2 = {x=H2, y=SQ, z=SQ}
	elseif direction.z < 0 then
		offset1 = {x=-SQ, y=-SQ, z=H1}
		offset2 = {x=SQ, y=SQ, z=H2}
	elseif direction.z > 0 then
		offset1 = {x=-SQ, y=-SQ, z=-H2}
		offset2 = {x=SQ, y=SQ, z=-H1}
	else
		offset1 = {x=0, y=0, z=0}
		offset2 = {x=0, y=0, z=0}
	end
	local particle_node
	if olddef._rp_paint_particle_node == false then
		-- Don't spawn particle
		return true
	elseif olddef._rp_paint_particle_node ~= nil then
		local defnode = {name = olddef._rp_paint_particle_node, param2 = oldnode.param2}
		local color = rp_paint.get_color(oldnode)
		if not color then
			minetest.log("error", "[rp_paint] When scraping off color of a node, rp_paint.get_color() for "..oldnode.name.." returned nil!")
			color = 0
		end
		local p2 = get_param2_color(defnode, color)
		particle_node = {name = olddef._rp_paint_particle_node, param2 = p2}
	else
		particle_node = oldnode
	end
	local minpos, maxpos
	if ptype == "flat_under" then
		rpos = vector.subtract(rpos, direction)
		minpos = vector.add(rpos, offset1)
		maxpos = vector.add(rpos, offset2)
	else
		minpos = vector.add(rpos, offset1)
		maxpos = vector.add(rpos, offset2)
	end
	minetest.add_particlespawner({
		amount = math.random(10, 20),
		time = 0.1,
		minpos = minpos,
		maxpos = maxpos,
		minvel = {x=-0.2, y=0, z=-0.2},
		maxvel = {x=0.2, y=2, z=0.2},
		minacc = {x=0, y=-GRAVITY, z=0},
		maxacc = {x=0, y=-GRAVITY, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.9,
		maxsize = 1.0,
		collisiondetection = true,
		vertical = false,
		node = particle_node,
	})
	return true
end

rp_paint.scrape_color = function(pos, pointed_thing)
	local oldnode = minetest.get_node(pos)
	local olddef = minetest.registered_nodes[oldnode.name]
	if not olddef then
		return false
	end
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
		if pointed_thing and pointed_thing.type == "node" then
			-- Spawn particles where we scrape
			local particlepos = pointed_thing.above
			local direction = { x=0, y=0, z=0 }
			if pointed_thing.above.y > pointed_thing.under.y then
				direction.y = 1
			elseif pointed_thing.above.y < pointed_thing.under.y then
				direction.y = -1
			elseif pointed_thing.above.x > pointed_thing.under.x then
				direction.x = 1
			elseif pointed_thing.above.x < pointed_thing.under.x then
				direction.x = -1
			elseif pointed_thing.above.z > pointed_thing.under.z then
				direction.z = 1
			elseif pointed_thing.above.z < pointed_thing.under.z then
				direction.z = -1
			end
			rp_paint.add_scrape_particles(particlepos, oldnode, direction)
		end
		return true
	end
	return false
end

local function set_brush_image(itemstack)
	local item_meta = itemstack:get_meta()
	local color_uses = item_meta:get_int("color_uses")
	color_uses = math.max(0, math.min(BRUSH_PAINTS, color_uses))
	if color_uses == 0 then
		-- Brush without paint
		item_meta:set_string("inventory_image", "")
		item_meta:set_string("wield_image", "")
		item_meta:set_string("inventory_overlay", "")
		item_meta:set_string("wield_overlay", "")
		return itemstack
	end
	local ratio = color_uses / BRUSH_PAINTS
	local rem
	if ratio > 0.83333 then
		rem = 0
	elseif ratio > 0.66667 then
		rem = 1
	elseif ratio > 0.50000 then
		rem = 2
	elseif ratio > 0.33333 then
		rem = 3
	elseif ratio > 0.16667 then
		rem = 4
	else
		rem = 5
	end

	local color = item_meta:get_int("_palette_index") + 1
	local hexcode = COLOR_HEXCODES[color] or "#FFFFFF"

	local mask
	if rem > 0 then
		mask = "^[mask:rp_paint_brush_overlay_mask_"..rem..".png"
	else
		mask = ""
	end
	local image = "rp_paint_brush_overlay.png^(rp_paint_brush.png"..mask.."^[multiply:"..hexcode..")"

	item_meta:set_string("inventory_image", image)
	item_meta:set_string("wield_image", image)
	item_meta:set_string("inventory_overlay", "")
	item_meta:set_string("wield_overlay", "")
	return itemstack
end

minetest.register_tool("rp_paint:brush", {
	description = S("Paint Brush"),
	_tt_help = S("Paints blocks").."\n"..S("Punch paint bucket to pick color"),
	inventory_image = "rp_paint_brush_overlay.png",
	wield_image = "rp_paint_brush_overlay.png",
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

		-- Dip brush in water bucket to remove paint
		if minetest.get_item_group(node.name, "bucket_water") == 1 then
			imeta:set_int("color_uses", 0)
			set_item_image(imeta, "")
			minetest.sound_play({name="rp_paint_brush_dip", gain=0.3, pitch=1.5}, {pos=pos, max_hear_distance = 8}, true)
			return itemstack
		end

		-- Dip brush in paint bucket to get paint
		if minetest.get_item_group(node.name, "paint_bucket") > 1 then
			local color = bit.rshift(node.param2, 2)
			if color > rp_paint.COLOR_COUNT or color < 0 then
				-- Invalid paint bucket color!
				return
			end
			if not minetest.is_creative_enabled(user:get_player_name()) then
				-- Reduce amount of paint in bucket
				change_bucket_level(pos, node, -1)
			end
			imeta:set_int("_palette_index", color)
			imeta:set_int("color_uses", BRUSH_PAINTS)

			local hexcode = COLOR_HEXCODES[color+1] or "#FFFFFF"
			set_item_image(imeta, "rp_paint_brush_overlay.png^(rp_paint_brush.png^[multiply:"..hexcode..")")

			minetest.sound_play({name="rp_paint_brush_dip", gain=0.3}, {pos=pos, max_hear_distance = 8}, true)
			return itemstack
		end

		-- Paint paintable node (brush needs to have paint and node must be paintable)
		local color = imeta:get_int("_palette_index")
		local color_uses = imeta:get_int("color_uses")
		if color_uses <= 0 then
			-- Not enough paint on brush: do nothing
			set_item_image(imeta, "")
			minetest.sound_play({name="rp_paint_brush_fail", gain=0.5}, {pos=pos, max_hear_distance=8}, true)
			return itemstack
		end
		local painted = rp_paint.set_color(pointed_thing.under, color)
		if painted then
			minetest.sound_play({name="rp_paint_brush_paint", gain=0.2}, {pos=pos, max_hear_distance = 8}, true)

			if minetest.get_modpath("rp_achievements") then
				achievements.trigger_achievement(user, "colorful_world")
			end

			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear_by_uses(BRUSH_USES)
				color_uses = color_uses - 1
				imeta:set_int("color_uses", color_uses)
			end

			color_uses = math.max(0, math.min(BRUSH_PAINTS, color_uses))

			-- Update paint brush image to show the amount of paint left
			if color_uses <= 0 then
				set_item_image(imeta, "")
			else
				local ratio = color_uses / BRUSH_PAINTS
				local rem
				if ratio > 0.83333 then
					rem = 0
				elseif ratio > 0.66667 then
					rem = 1
				elseif ratio > 0.50000 then
					rem = 2
				elseif ratio > 0.33333 then
					rem = 3
				elseif ratio > 0.16667 then
					rem = 4
				else
					rem = 5
				end

				local color = imeta:get_int("_palette_index") + 1
				local hexcode = COLOR_HEXCODES[color] or "#FFFFFF"

				local mask
				if rem > 0 then
					mask = "^[mask:rp_paint_brush_overlay_mask_"..rem..".png"
				else
					mask = ""
				end
				local istr = "rp_paint_brush_overlay.png^(rp_paint_brush.png"..mask.."^[multiply:"..hexcode..")"
				set_item_image(imeta, istr)
			end
		else
			minetest.sound_play({name="rp_paint_brush_fail", gain=0.5}, {pos=pos, max_hear_distance=8}, true)
		end
		return itemstack
	end,
	groups = { disable_repair = 1 },
})

local on_bucket_construct = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", S("Paint Bucket (@1)", COLOR_NAMES[1]))
end
local bucket_flower_add = function(pos, node, clicker, itemstack, pointed_thing)
	if itemstack and itemstack:get_name() == "rp_default:flower" then
		if change_bucket_level(pos, node, BUCKET_FLOWER_ADD) ~= 0 then
			minetest.sound_play({name="rp_paint_bucket_select_color", gain=0.20, pitch=0.7}, {pos = pos}, true)
			if clicker and clicker:is_player() and not minetest.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
				return true, itemstack
			end
		end
		return true, itemstack
	end
	return false, itemstack
end
local on_bucket_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	if not pointed_thing or util.handle_node_protection(clicker, pointed_thing) then
		return
	end
	-- ++ If holding a flower, add paint level ++
	local flower_used, itemstack = bucket_flower_add(pos, node, clicker, itemstack, pointed_thing)
	if flower_used then
		return itemstack
	end

	-- ++ Switch color on rightclick ++

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
end

local on_bucket_construct_empty = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("infotext", S("Paint Bucket (Empty)"))
end
local on_bucket_rightclick_empty = function(pos, node, clicker, itemstack, pointed_thing)
	if not pointed_thing or util.handle_node_protection(clicker, pointed_thing) then
		return
	end

	-- ++ If holding a flower, add paint level ++
	local flower_used, itemstack = bucket_flower_add(pos, node, clicker, itemstack, pointed_thing)
	if flower_used then
		return itemstack
	end
end
local on_bucket_use = function(itemstack, user, pointed_thing)
	-- When using paint bucket as an item:
	-- pick up paint from paint bucket or place paint
	-- into paint bucket
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
	local pb = minetest.get_item_group(node.name, "paint_bucket")
	if pb < 1 then
		return
	end
	local target_paint_level = pb - 1
	local my_paint_level = minetest.get_item_group(itemstack:get_name(), "paint_bucket") - 1

	if my_paint_level <= 0 then
		-- Using empty bucket: pick up paint from pointed bucket, if possible
		if target_paint_level <= 0 then
			return
		end
		local change = change_bucket_level(pos, node, -target_paint_level)
		if change ~= 0 then
			if target_paint_level == BUCKET_LEVELS then
				itemstack:set_name("rp_paint:bucket")
			else
				itemstack:set_name("rp_paint:bucket_"..target_paint_level)
			end
			minetest.sound_play({name="rp_paint_bucket_select_color", gain=0.20, pitch=0.7}, {pos = pos}, true)
			return itemstack
		end
	else
		-- Using bucket with paint: put paint into pointed bucket
		target_paint_level = target_paint_level + my_paint_level
		local change = change_bucket_level(pos, node, my_paint_level)
		if change > 0 then
			my_paint_level = my_paint_level - change
			itemstack:set_name("rp_paint:bucket_"..my_paint_level)
			minetest.sound_play({name="rp_paint_bucket_select_color", gain=0.20, pitch=0.7}, {pos = pos}, true)
			return itemstack
		end
	end
end

for i=0, BUCKET_LEVELS do
	local id, desc, tt, mesh, img, nici, pbnf, ws, overlay, painttile, paintover, construct, rightclick, use, stack_max
	local paint_level = i + 1
	if i == 0 then
		-- empty bucket
		id = "rp_paint:bucket_"..i
		desc = S("Paint Bucket")
		mesh = "rp_paint_bucket_empty.obj"
		rightclick = on_bucket_rightclick_empty
		construct = on_bucket_construct_empty
		pbnf = 1
	elseif i == BUCKET_LEVELS then
		-- full bucket
		id = "rp_paint:bucket"
		desc = S("Paint Bucket with Paint")
		mesh = "rp_paint_bucket_m0.obj"
		ws = {x=1,y=1,z=2}
		rightclick = on_bucket_rightclick
		construct = on_bucket_construct
	else
		-- bucket with other paint level
		id = "rp_paint:bucket_"..i
		local m = BUCKET_LEVELS-i
		desc = S("Paint Bucket with Paint")
		mesh = "rp_paint_bucket_m"..m..".obj"
		nici = 1
		pbnf = 1
		rightclick = on_bucket_rightclick
		construct = on_bucket_construct
	end
	img = "rp_paint_bucket_inv_"..i..".png"
	if i > 0 then
		tt = S("Use place key to change color").."\n"..S("Point at left/right part to get previous/next color").."\n"..S("Refill with flowers")
		paintover = "([combine:16x16:0,"..i.."=rp_paint_bucket_node_inside_paint_overlay.png\\^[transformFY)^[mask:(rp_paint_bucket_node_inside_paint_overlay_mask.png^[transformFY)"
		painttile = "rp_paint_bucket_node_paint.png"
		stack_max = 1
	else
		tt = S("Fill with flowers to get paint")
		paintover = ""
		painttile = "blank.png"
		stack_max = 10
	end
	use = on_bucket_use

	minetest.register_node(id, {
		description = desc,
		_tt_help = tt,
		stack_max = stack_max,

		drawtype = "mesh",
		mesh = mesh,
		tiles = {
			{name="rp_paint_bucket_node_side_1.png",backface_culling=true,color="white"},
			{name="rp_paint_bucket_node_side_2.png",backface_culling=true,color="white"},
			{name="rp_paint_bucket_node_top_handle.png",backface_culling=true,color="white"},
			{name="rp_paint_bucket_node_bottom_inside.png",backface_culling=true,color="white"},
			{name="rp_paint_bucket_node_bottom_outside.png",backface_culling=true,color="white"},
			painttile,
		},
		overlay_tiles = {
			"","","",paintover,"","",
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

		inventory_image = img,
		wield_image = img,
		wield_scale = ws,
		groups = { bucket = 3, paint_bucket = paint_level, paint_bucket_not_full = pbnf, tool = 1, dig_immediate = 3, attached_node = 1, not_in_creative_inventory = nici },
		on_construct = construct,
		on_rightclick = rightclick,
		on_use = use,
		-- Erase metadata like palette_index on drop
		drop = id,
	})
end

-- Empty paint bucket
crafting.register_craft({
	output = "rp_paint:bucket_0",
	items = {
		"rp_default:ingot_tin 5",
	},
})

-- Fill any paint bucket at any non-full paint level with 3 flowers
-- (If the bucket is non-empty, this recipe is more wasteful
-- than placing flowers into the paint bucket node. This is intended.)
crafting.register_craft({
	output = "rp_paint:bucket",
	items = {
		"group:paint_bucket_not_full",
		"rp_default:flower 3",
	},
})

crafting.register_craft({
	output = "rp_paint:brush",
	items = {
		"rp_default:stick",
		"rp_farming:cotton 3",
	},
})

if minetest.get_modpath("rp_achievements") then
	achievements.register_achievement("colorful_world", {
		title = S("Colorful World"),
		description = S("Paint a block."),
		times = 1,
		icon = "rp_paint_achievement_paint_the_world.png",
		difficulty = 5.4,
	})
end

rp_item_update.register_item_update("rp_paint:brush", function(itemstack)
	local item_meta = itemstack:get_meta()
	local pi = item_meta:get_int("palette_index")
	local color
	if pi > 0 then
		item_meta:set_int("palette_index", 0)
		item_meta:set_int("_palette_index", pi)
	end
	itemstack = set_brush_image(itemstack)
	return itemstack
end)

