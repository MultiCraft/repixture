local S = minetest.get_translator("rp_itemshow")

local BASE_ITEM_SIZE = 1/3

local ROTATE_SPEED = 1 -- speed at which the entity rotates
local DEFAULT_ROTATE_DIR = -1 -- clockwise
-- Clockwise because dropped item rotate counter-clockwise,
-- so the 'itemshow' entities rotate the other way by
-- default

local FACEDIR = {}
FACEDIR[0] = {x = 0, y = 0, z = 1}
FACEDIR[1] = {x = 1, y = 0, z = 0}
FACEDIR[2] = {x = 0, y = 0, z = -1}
FACEDIR[3] = {x = -1, y = 0, z = 0}

-- functions

local remove_item = function(pos, node, dry_run)
	local objs = nil
	local objects_found = false
	if node.name == "rp_itemshow:frame" or
			minetest.get_item_group(node.name, "item_showcase") == 1 then
		objs = minetest.get_objects_inside_radius(pos, 0.5)
	end
	if objs then
		for _, obj in ipairs(objs) do
			if obj and obj:get_luaentity() then
				local ent = obj:get_luaentity()
				local name = ent.name
				local nodename = ent._nodename
				if name == "rp_itemshow:item" and nodename == node.name then
					objects_found = true
					if dry_run then
						return objects_found
					else
						obj:remove()
					end
				end
			end
		end
	end
	return objects_found
end

local update_item = function(pos, node, check_item)
	local objects_found = remove_item(pos, node, check_item)
	if check_item and objects_found then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("main", 1)
	if not stack:is_empty() then
		if node.name == "rp_itemshow:frame" then
			local posad = FACEDIR[node.param2]
			if not posad then return end
			local def = minetest.registered_items[stack:get_name()]
			local offset = def._rp_itemshow_offset or vector.new(0,0,0)
			pos.x = pos.x + posad.x * 6.5 / 16 + posad.x * offset.x
			pos.y = pos.y + posad.y * 6.5 / 16 + offset.y
			pos.z = pos.z + posad.z * 6.5 / 16 + posad.z * offset.z
		elseif minetest.get_item_group(node.name, "item_showcase") == 1 then
			-- no pos change, put in center of node
		end
		local e = minetest.add_entity(pos,"rp_itemshow:item")
		if e then
			local lua = e:get_luaentity()
			if lua then
				local dir = DEFAULT_ROTATE_DIR
				if node.param2 == 1 then
					dir = -dir
				end
				lua:_configure(stack:get_name(), node.name, dir)
			end
		end
		if e and node.name == "rp_itemshow:frame" then
			local yaw = math.pi * 2 - node.param2 * math.pi / 2
			e:set_yaw(yaw)
		end
	end
end

local drop_item = function(pos, node, creative)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local item = inv:get_stack("main", 1)
	local dropped = false
	if not item:is_empty() then
		if creative then
			-- Don't drop item
		elseif node.name == "rp_itemshow:frame" then
			local ent = minetest.add_item(pos, item)
			if ent and ent:get_luaentity() then
				-- Set initial yaw of entity according to frame rotation
				local yaw = minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2))
				ent:set_yaw(yaw)
			end
			dropped = true
		elseif minetest.get_item_group(node.name, "item_showcase") == 1 then
			minetest.add_item({x=pos.x, y=pos.y+0.75, z=pos.z}, item)
			dropped = true
		end
		inv:set_stack("main", 1, "")
	end
	remove_item(pos, node)
	return dropped
end


local on_rightclick = function(pos, node, clicker, itemstack)
	if not itemstack then return end
	local name = clicker:get_player_name()
	if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, "protection_bypass") then
		minetest.record_protection_violation(pos, name)
		return itemstack
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local creative = minetest.is_creative_enabled(name)
	if not inv:get_stack("main", 1):is_empty() then
		drop_item(pos, node, creative)
		minetest.sound_play({name="rp_itemshow_take_item", gain=0.5}, {pos=pos}, true)
	else
		if itemstack:is_empty() then
			return itemstack
		end
		local put_itemstack = ItemStack(itemstack)
		put_itemstack:set_count(1)
		inv:set_stack("main", 1, put_itemstack)
		update_item(pos, node)
		minetest.sound_play({name="rp_itemshow_put_item", gain=0.5}, {pos=pos}, true)
		if not creative then
			itemstack:take_item()
		end
		return itemstack
	end
end

-- Entity for displayed item

minetest.register_entity("rp_itemshow:item",{
	hp_max = 1,
	visual = "wielditem",
	is_visible = false,
	visual_size = {x = BASE_ITEM_SIZE, y = BASE_ITEM_SIZE },
	pointable = false,
	physical = false,
	-- Extra fields used:
	-- * _nodename: Name of node this displayed item belongs to
	-- * _item: Itemstring of displayed item
	-- * _rotate_dir: Direction of entity rotation (for showcase)

	_configure = function(self, item, nodename, rotate_dir)
		local props = { is_visible = true }
		if item then
			self._item = item
			props.wield_item = self._item
		end
		if nodename then
			self._nodename = nodename
		end
		if rotate_dir then
			self._rotate_dir = rotate_dir
		end

		if self._nodename and self._nodename ~= "" then
			if minetest.get_item_group(self._nodename, "item_showcase") == 1 then
				if not self._rotate_dir then
					self._rotate_dir = DEFAULT_ROTATE_DIR
				end
				props.automatic_rotate = ROTATE_SPEED * self._rotate_dir
			end
		end

		if self._item then
			local def = minetest.registered_items[self._item]
			if def then
				local v
				if def._rp_itemshow_scale then
					v = def._rp_itemshow_scale
				else
					v = 1
					if def.wield_scale then
						v = v / def.wield_scale.x
					end
				end
				if v then
					v = v * BASE_ITEM_SIZE
					props.visual_size = { x = v, y = v }
				end
			end
		end

		self.object:set_properties(props)
	end,

	on_activate = function(self, staticdata)

		self.object:set_armor_groups({immortal=1})

		local nodename, item, rotate_dir
		if staticdata ~= nil and staticdata ~= "" then
			local data = staticdata:split(';')
			if data and data[1] and data[2] then
				nodename = data[1]
				item = data[2]
			end
			if data and data[3] then
				rotate_dir = tonumber(data[3]) or DEFAULT_ROTATE_DIR
			end

		end

		if item and item ~= "" then
			self:_configure(item, nodename, rotate_dir)
		end
	end,

	get_staticdata = function(self)
		if self._nodename ~= nil and self._item ~= nil then
			local data = self._nodename .. ';' .. self._item
			if self._rotate_dir ~= nil then
				data = data .. ";" .. self._rotate_dir
			end
			return data
		end
		return ""
	end,
})

-- nodes

minetest.register_node("rp_itemshow:frame",{
	description = S("Item Frame"),
	_tt_help = S("You can show off an item here"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-7/16, -7/16, 7/16, 7/16, 7/16, 0.5}
	},
	tiles = {
		"rp_itemshow_frame.png",
		"rp_itemshow_frame.png",
		"rp_itemshow_frame.png",
		"rp_itemshow_frame.png",
		"rp_itemshow_frame_back.png",
		"rp_itemshow_frame.png",
	},
	inventory_image = "rp_itemshow_frame_inventory.png",
	wield_image = "rp_itemshow_frame_inventory.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {
		choppy = 2, dig_immediate = 2, creative_decoblock = 1,
		-- So that placing a magnocompass on it will point
		-- the needle to the correct direction
		special_magnocompass_place_handling = 1},
	sounds = rp_sounds.node_sound_defaults(),
	is_ground_content = false,
	on_rotate = function(pos, node, user, mode, new_param2)
		if mode == screwdriver.ROTATE_AXIS then
			return false
		elseif mode == screwdriver.ROTATE_FACE then
			local newnode = table.copy(node)
			newnode.param2 = new_param2
			update_item(pos, newnode)
			return
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Item Frame"))
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,

	on_rightclick = on_rightclick,

	floodable = true,
	on_flood = function(pos)
		drop_item(pos, minetest.get_node(pos), minetest.is_creative_enabled(""))
		minetest.add_item(pos, "rp_itemshow:frame")
	end,

	on_destruct = function(pos)
		drop_item(pos, minetest.get_node(pos), minetest.is_creative_enabled(""))
	end,

	on_punch = function(pos, node, puncher)
		update_item(pos, node, true)
	end,
})

local function on_place_node_callbacks(place_to, newnode, placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy =
			{name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy =
			{name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer,
			oldnode_copy, itemstack, pointed_thing_copy)
	end
end

-- Item Showcase

minetest.register_node("rp_itemshow:showcase", {
	description = S("Item Showcase"),
	_tt_help = S("You can show off an item here"),
	drawtype = "glasslike",
	tiles = {"rp_itemshow_showcase.png"},
	use_texture_alpha = "clip",
	paramtype = "light",
	groups = { item_showcase = 1, cracky = 3, oddly_breakable_by_hand = 2, uses_canonical_compass = 1, creative_decoblock = 1 },
	sounds = rp_sounds.node_sound_glass_defaults(),
	is_ground_content = false,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Item Showcase"))
		local inv = meta:get_inventory()
		inv:set_size("main", 1)
	end,

	on_destruct = function(pos)
		drop_item(pos, minetest.get_node(pos), minetest.is_creative_enabled(""))
	end,

	on_rightclick = on_rightclick,

	on_punch = function(pos, node, puncher)
		update_item(pos, node, true)
	end,
})

-- automatically restore entities lost from frames/showcases
-- due to /clearobjects or similar

minetest.register_lbm({
	name = "rp_itemshow:respawn_entities",
	label = "Respawn entities of item frames and item showcases",
	nodenames = {"rp_itemshow:frame", "group:item_showcase"},
	run_at_every_load = true,
	action = function(pos, node)
		local num
		if node.name == "rp_itemshow:frame" then
			num = #minetest.get_objects_inside_radius(pos, 0.5)
		elseif minetest.get_item_group(node.name, "item_showcase") == 1 then
			pos.y = pos.y + 1
			num = #minetest.get_objects_inside_radius(pos, 0.5)
			pos.y = pos.y - 1
		end
		if num > 0 then
			return
		end
		update_item(pos, node)
	end
})

-- crafts

crafting.register_craft({
	output = "rp_itemshow:frame",
	items = { "rp_default:stick 8", "rp_default:paper", "rp_default:fiber 3" },
})
crafting.register_craft({
	output = "rp_itemshow:showcase",
	items = { "rp_default:glass", "rp_default:ingot_copper 4" },
})
