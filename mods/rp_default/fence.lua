local S = minetest.get_translator("rp_default")

-- Fence register function loosely based on Minetest Game 5.5.0 (LGPLv2.1)

local fence_collision_extra = 1/2
local function register_fence(name, def)
	local fence_texture = def.texture .. "^default_fence_overlay.png"

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
		connects_to = {"group:fence", "group:wood"},
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		tiles = {def.texture},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {},
                after_dig_node = function(pos, node, metadata, digger)
			default.dig_up(pos, node, digger)
                end,
	}
	for k, v in pairs(default_fields) do
		if def[k] == nil then
			def[k] = v
		end
	end

	-- Always add to the fence group, even if no group provided
	def.groups.fence = 1

	def.texture = nil
	def.material = nil

	minetest.register_node(name, def)
end

register_fence("rp_default:fence", {
	description = S("Wooden Fence"),
	texture = "default_wood.png",
	inventory_image = "default_fence.png",
	wield_image = "default_fence.png",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, fence = 1},
	sounds = rp_sounds.node_sound_wood_defaults()
})
register_fence("rp_default:fence_oak", {
	description = S("Oak Fence"),
	texture = "default_wood_oak.png",
	inventory_image = "default_fence_oak.png",
	wield_image = "default_fence_oak.png",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, fence = 1},
	sounds = rp_sounds.node_sound_wood_defaults()
})
register_fence("rp_default:fence_birch", {
	description = S("Birch Fence"),
	texture = "default_wood_birch.png",
	inventory_image = "default_fence_birch.png",
	wield_image = "default_fence_birch.png",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, fence = 1},
	sounds = rp_sounds.node_sound_wood_defaults()
})

default.log("fence", "loaded")