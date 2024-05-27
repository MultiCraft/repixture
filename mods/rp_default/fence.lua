local S = minetest.get_translator("rp_default")

-- Fence register function loosely based on Minetest Game 5.5.0 (LGPLv2.1)

local FENCE_COLLISION_EXTRA = 1/2
local function register_fence(name, def)
	local default_fields = {
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {-1/8, -1/2, -1/8, 1/8, 1/2, 1/8},
			connect_front = {{-1/16,  3/16, -1/2,   1/16,  5/16, -1/8 },
				         {-1/16, -5/16, -1/2,   1/16, -3/16, -1/8 }},
			connect_left =  {{-1/2,   3/16, -1/16, -1/8,   5/16,  1/16},
				         {-1/2,  -5/16, -1/16, -1/8,  -3/16,  1/16}},
			connect_back =  {{-1/16,  3/16,  1/8,   1/16,  5/16,  1/2 },
				         {-1/16, -5/16,  1/8,   1/16, -3/16,  1/2 }},
			connect_right = {{ 1/8,   3/16, -1/16,  1/2,   5/16,  1/16},
				         { 1/8,  -5/16, -1/16,  1/2,  -3/16,  1/16}}
		},
		collision_box = {
			type = "connected",
			fixed = {-1/8, -1/2, -1/8, 1/8, 1/2 + FENCE_COLLISION_EXTRA, 1/8},
			connect_front = {-1/8, -1/2, -1/2,  1/8, 1/2 + FENCE_COLLISION_EXTRA, -1/8},
			connect_left =  {-1/2, -1/2, -1/8, -1/8, 1/2 + FENCE_COLLISION_EXTRA,  1/8},
			connect_back =  {-1/8, -1/2,  1/8,  1/8, 1/2 + FENCE_COLLISION_EXTRA,  1/2},
			connect_right = { 1/8, -1/2, -1/8,  1/2, 1/2 + FENCE_COLLISION_EXTRA,  1/8}
		},
		connects_to = {"group:fence", "group:fence_gate", "group:wood", "group:tree"},
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		tiles = {def.texture_top, def.texture_top, def.texture_side},
		-- HACK: This is a workaround to fix the coloring of the crack overlay
		overlay_tiles = {{name="rp_textures_blank_paintable_overlay.png",color="white"}},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
                after_dig_node = function(pos, node, metadata, digger)
			util.dig_up(pos, node, digger)
                end,
		drop = name,
	}
	for k, v in pairs(default_fields) do
		if def[k] == nil then
			def[k] = v
		end
	end


	-- Always add to the fence group, even if no group provided
	def.groups.fence = 1
	def.groups.creative_decoblock = 1
	def.groups.paintable = 2

	def.texture = nil
	def.material = nil
	local description_painted = def.description_painted
	def.description_painted = nil

	minetest.register_node(name, def)

	local def_painted = table.copy(def)
	def_painted.groups = table.copy(def.groups)
	def_painted.groups.paintable = 1
	def_painted.groups.not_in_creative_inventory = 1
	def_painted.description = description_painted
	def_painted.paramtype2 = "color"
	def_painted.palette = "rp_paint_palette_256.png"
	def_painted.tiles = {def.texture_top_painted, def.texture_top_painted, def.texture_side_painted}
	def_painted.inventory_image = def.inventory_image.."^[hsl:0:-100:0"
	def_painted.wield_image = def.wield_image.."^[hsl:0:-100:0"
	local name_painted = name .. "_painted"
	minetest.register_node(name_painted, def_painted)
end

local function register_fence_gate(name, def)
	local gate_id_closed = name .. "_closed"
	local gate_id_open = name .. "_open"
	local gate_id_closed_painted = name .. "_closed_painted"
	local gate_id_open_painted = name .. "_open_painted"

	local sound_open = def.sound_open or "rp_default_fence_gate_wood_open"
	local sound_close = def.sound_close or "rp_default_fence_gate_wood_close"
	local sound_gain_open = def.sound_gain_open or 0.3
	local sound_gain_close = def.sound_gain_close or 0.3
	local description_painted = def.description_painted
	def.sound_open = nil
	def.sound_close = nil
	def.sound_sound_gain_open = nil
	def.sound_sound_gain_close = nil
	def.description_painted = nil

	local function toggle_gate(pos, node)
		local is_open = minetest.get_item_group(node.name, "fence_gate") == 2
		local is_painted = minetest.get_item_group(node.name, "paintable") == 1
		local new_id
		if is_open then
			minetest.sound_play(sound_close, {gain = sound_gain_close, max_hear_distance = 10, pos = pos}, true)
			if is_painted then
				new_id = gate_id_closed_painted
			else
				new_id = gate_id_closed
			end
			minetest.set_node(pos, {name=new_id, param1=node.param1, param2=node.param2})
		else
			minetest.sound_play(sound_open, {gain = sound_gain_open, max_hear_distance = 10, pos = pos}, true)
			if is_painted then
				new_id = gate_id_open_painted
			else
				new_id = gate_id_open
			end
			minetest.set_node(pos, {name=new_id, param1=node.param1, param2=node.param2})
		end
	end

	local def_open = table.copy(def)
	local default_fields_open = {
		walkable = false,
		paramtype = "light",
		drawtype = "nodebox",
		paramtype2 = "4dir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1/16, -6/16, 0.5, 1/16}, -- left end
				{6/16, -0.5, -1/16, 0.5, 0.5, 1/16}, -- right end
				{-0.5, 2/16, 1/16, -6/16, 5/16, 0.5}, -- top left x
				{-0.5, -5/16, 1/16, -6/16, -2/16, 0.5}, -- bottom left x
				{6/16, 2/16, 1/16, 0.5, 5/16, 0.5},   -- top right x
				{6/16, -5/16, 1/16, 0.5, -2/16, 0.5}, -- bottom right x
				{-0.5, -2/16, 6/16, -6/16, 2/16, 0.5},  -- middle left
				{6/16, -2/16, 0.5, 0.5, 2/16, 6/16},  -- middle right
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -1/16, -6/16, 0.5, 1/16}, -- left end
				{6/16, -0.5, -1/16, 0.5, 0.5, 1/16}, -- right end
				{-6/16, -5/16, -1/16, 6/16, 5/16, 1/16}, -- gate
			}
		},
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		tiles = {def.texture_top, def.texture_top, def.texture_side, def.texture_side, def.texture_front},
		-- HACK: This is a workaround to fix the coloring of the crack overlay
		overlay_tiles = {{name="rp_textures_blank_paintable_overlay.png",color="white"}},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
		drop = gate_id_closed,
		on_rightclick = function(pos, node, clicker)
			toggle_gate(pos, node)
		end,
	}
	for k, v in pairs(default_fields_open) do
		if def_open[k] == nil then
			def_open[k] = v
		end
	end

	def_open.description = nil
	def_open.groups.fence_gate = 2
	def_open.groups.creative_decoblock = 1
	def_open.groups.not_in_creative_inventory = 1
	def_open.groups.paintable = 2

	def_open.texture = nil
	def_open.material = nil

	minetest.register_node(gate_id_open, def_open)

	-- Closed fence gate
	local def_closed = table.copy(def_open)
	def_closed.walkable = true
	def_closed.node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -1/16, -6/16, 0.5, 1/16}, -- left end
			{6/16, -0.5, -1/16, 0.5, 0.5, 1/16}, -- right end
			{-2/16, -5/16, -1/16, 2/16, 5/16, 1/16}, -- middle
			{-0.5, 2/16, -1/16, -2/16, 5/16, 1/16}, -- top -z
			{-0.5, -5/16, -1/16, -2/16, -2/16, 1/16}, -- bottom -z
			{2/16, 2/16, -1/16, 0.5, 5/16, 1/16},  -- top +z
			{2/16, -5/16, -1/16, 0.5, -2/16, 1/16}, -- bottom +z
		}
	}
	def_closed.collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -3/16, -2/16, 0.5, 0.5 + FENCE_COLLISION_EXTRA, 2/16},
		}
	}
	def_closed.selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -1/16, -6/16, 0.5, 1/16}, -- left end
			{6/16, -0.5, -1/16, 0.5, 0.5, 1/16}, -- right end
			{-6/16, -5/16, -1/16, 6/16, 5/16, 1/16}, -- gate
		}
	}
	def_closed.description = def.description
	def_closed.groups.fence_gate = 1
	def_closed.groups.not_in_creative_inventory = nil
	minetest.register_node(gate_id_closed, def_closed)


	local def_open_painted = table.copy(def_open)
	def_open_painted.groups = table.copy(def_open.groups)
	def_open_painted.groups.paintable = 1
	def_open_painted.description = nil
	def_open_painted.paramtype2 = "color4dir"
	def_open_painted.palette = "rp_paint_palette_64.png"
	def_open_painted.tiles = {def.texture_top_painted, def.texture_top_painted, def.texture_side_painted, def.texture_side_painted, def.texture_front_painted}
	def_open_painted.inventory_image = nil
	def_open_painted.wield_image = nil
	minetest.register_node(gate_id_open_painted, def_open_painted)

	local def_closed_painted = table.copy(def_closed)
	def_closed_painted.groups = table.copy(def_closed.groups)
	def_closed_painted.groups.paintable = 1
	def_closed_painted.groups.not_in_creative_inventory = 1
	def_closed_painted.description = description_painted
	def_closed_painted.paramtype2 = "color4dir"
	def_closed_painted.palette = "rp_paint_palette_64.png"
	def_closed_painted.tiles = {def.texture_top_painted, def.texture_top_painted, def.texture_side_painted, def.texture_side_painted, def.texture_front_painted}
	def_closed_painted.inventory_image = def.inventory_image.."^[hsl:0:-100:0"
	def_closed_painted.wield_image = def.wield_image.."^[hsl:0:-100:0"
	minetest.register_node(gate_id_closed_painted, def_closed_painted)
end

local sounds_wood_fence = rp_sounds.node_sound_planks_defaults({
	footstep = { name = "rp_sounds_footstep_wood", pitch = 1.2 },
	dig = { name = "rp_sounds_dig_wood", pitch = 1.2, gain = 0.5 },
	dug = { name = "rp_sounds_dug_planks", pitch = 1.2, gain = 0.7 },
	place = { name = "rp_sounds_place_planks", pitch = 1.2, gain = 0.9 },
})

register_fence("rp_default:fence", {
	description = S("Wooden Fence"),
	description_painted = S("Painted Wooden Fence"),
	texture_side = "rp_default_fence_side.png",
	texture_top = "rp_default_fence_top.png",
	texture_side_painted = "rp_default_fence_side_painted.png",
	texture_top_painted = "rp_default_fence_top_painted.png",
	inventory_image = "default_fence.png",
	wield_image = "default_fence.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})
register_fence_gate("rp_default:fence_gate", {
	description = S("Wooden Fence Gate"),
	description_painted = S("Painted Wooden Fence Gate"),
	texture_front = "rp_default_fence_gate_front.png",
	texture_side = "rp_default_fence_gate_side.png",
	texture_top = "rp_default_fence_gate_top.png",
	texture_front_painted = "rp_default_fence_gate_front_painted.png",
	texture_side_painted = "rp_default_fence_gate_side_painted.png",
	texture_top_painted = "rp_default_fence_gate_top_painted.png",
	inventory_image = "rp_default_fence_gate.png",
	wield_image = "rp_default_fence_gate.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence_gate = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})

register_fence("rp_default:fence_oak", {
	description = S("Oak Fence"),
	description_painted = S("Painted Oak Fence"),
	texture_side = "rp_default_fence_oak_side.png",
	texture_top = "rp_default_fence_oak_top.png",
	texture_side_painted = "rp_default_fence_oak_side_painted.png",
	texture_top_painted = "rp_default_fence_oak_top_painted.png",
	inventory_image = "default_fence_oak.png",
	wield_image = "default_fence_oak.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})
register_fence_gate("rp_default:fence_gate_oak", {
	description = S("Oak Fence Gate"),
	description_painted = S("Painted Oak Fence Gate"),
	texture_front = "rp_default_fence_gate_oak_front.png",
	texture_side = "rp_default_fence_gate_oak_side.png",
	texture_top = "rp_default_fence_gate_oak_top.png",
	texture_front_painted = "rp_default_fence_gate_oak_front_painted.png",
	texture_side_painted = "rp_default_fence_gate_oak_side_painted.png",
	texture_top_painted = "rp_default_fence_gate_oak_top_painted.png",
	inventory_image = "rp_default_fence_gate_oak.png",
	wield_image = "rp_default_fence_gate_oak.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence_gate = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})

register_fence("rp_default:fence_birch", {
	description = S("Birch Fence"),
	description_painted = S("Painted Birch Fence"),
	texture_side = "rp_default_fence_birch_side.png",
	texture_top = "rp_default_fence_birch_top.png",
	texture_side_painted = "rp_default_fence_birch_side_painted.png",
	texture_top_painted = "rp_default_fence_birch_top_painted.png",
	inventory_image = "default_fence_birch.png",
	wield_image = "default_fence_birch.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})
register_fence_gate("rp_default:fence_gate_birch", {
	description = S("Birch Fence Gate"),
	description_painted = S("Painted Birch Fence Gate"),
	texture_front = "rp_default_fence_gate_birch_front.png",
	texture_side = "rp_default_fence_gate_birch_side.png",
	texture_top = "rp_default_fence_gate_birch_top.png",
	texture_front_painted = "rp_default_fence_gate_birch_front_painted.png",
	texture_side_painted = "rp_default_fence_gate_birch_side_painted.png",
	texture_top_painted = "rp_default_fence_gate_birch_top_painted.png",
	inventory_image = "rp_default_fence_gate_birch.png",
	wield_image = "rp_default_fence_gate_birch.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence_gate = 1},
	sounds = sounds_wood_fence,
	_rp_blast_resistance = 0.5,
})
