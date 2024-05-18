local S = minetest.get_translator("rp_default")

-- Fence register function loosely based on Minetest Game 5.5.0 (LGPLv2.1)

local fence_collision_extra = 1/2
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
			fixed = {-1/8, -1/2, -1/8, 1/8, 1/2 + fence_collision_extra, 1/8},
			connect_front = {-1/8, -1/2, -1/2,  1/8, 1/2 + fence_collision_extra, -1/8},
			connect_left =  {-1/2, -1/2, -1/8, -1/8, 1/2 + fence_collision_extra,  1/8},
			connect_back =  {-1/8, -1/2,  1/8,  1/8, 1/2 + fence_collision_extra,  1/2},
			connect_right = { 1/8, -1/2, -1/8,  1/2, 1/2 + fence_collision_extra,  1/8}
		},
		connects_to = {"group:fence", "group:wood", "group:tree"},
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

	local palette = def.palette
	def.palette = nil
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
	def_painted.palette = palette or "rp_paint_palette_256.png"
	def_painted.tiles = {def.texture_top_painted, def.texture_top_painted, def.texture_side_painted}
	def_painted.inventory_image = def.inventory_image.."^[hsl:0:-100:0"
	def_painted.wield_image = def.wield_image.."^[hsl:0:-100:0"
	local name_painted = name .. "_painted"
	minetest.register_node(name_painted, def_painted)
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
register_fence("rp_default:fence_fir", {
	description = S("Fir Fence"),
	description_painted = S("Painted Fir Fence"),
	texture_side = "rp_default_fence_fir_side.png",
	texture_top = "rp_default_fence_fir_top.png",
	texture_side_painted = "rp_default_fence_fir_side_painted.png",
	texture_top_painted = "rp_default_fence_fir_top_painted.png",
	inventory_image = "rp_default_fence_fir.png",
	wield_image = "rp_default_fence_fir.png",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, level = -2, fence = 1},
	sounds = sounds_wood_fence,
	palette = "rp_paint_palette_256l.png"
})
