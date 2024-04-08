-- item_entity mod

local nav_mod = minetest.get_modpath("rp_nav") ~= nil

-- Distance from player to item
-- below which the item magnet kicks in
-- and starts attracting the item.
local ITEM_MAGNET_ACTIVE_DISTANCE = 1.5

-- Distance from player to item
-- below which the player's item magnet
-- will collect the item into the inventory.
local ITEM_MAGNET_COLLECT_DISTANCE = 0.5

-- Distance above ground at which players
-- will collect items
local ITEM_MAGNET_HAND_HEIGHT = 0.5

-- Movement speed at which the item
-- magnet attracts items
local ITEM_MAGNET_ATTRACT_SPEED = 5

local function add_item_death_particle(ent)
	minetest.add_particle({
		pos = ent.object:get_pos(),
		size = 3,
		texture = "rp_builtin_item_die.png",
	})
end

-- If item_entity_ttl is not set, enity will have default life time
-- Setting it to -1 disables the feature

local time_to_live = tonumber(minetest.settings:get("item_entity_ttl")) or 900
local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81


minetest.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
		visual = "wielditem",
		visual_size = {x = 0.15, y = 0.15},
		textures = {""},
		is_visible = false,
		pointable = false,
	},

	itemstring = "",
	moving_state = true,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out = nil,
	force_out_start = nil,
	item_magnet_timer = 0,
	item_magnet = false, -- set by other mod that implements item magnet

	set_item = function(self, item)
		local stack = ItemStack(item or self.itemstring)
		self.itemstring = stack:to_string()
		if self.itemstring == "" then
			-- item not yet known
			return
		end

		-- If item definition mentions a canonical item, use this item
		-- for the itemstack used by the entity instead.
		local def = stack:get_definition()
		if def and def._rp_canonical_item then
			stack:set_name(def._rp_canonical_item)
			self.itemstring = stack:to_string()
		end

		-- Backwards compatibility: old clients use the texture
		-- to get the type of the item
		local itemname = stack:is_known() and stack:get_name() or "unknown"

                -- Hand and specially marked items are not allowed in entity form
		if itemname ~= nil and ((itemname == "") or (minetest.get_item_group(itemname, "no_item_drop") == 1)) then
			self.object:remove()
			return
		end

		local max_count = stack:get_stack_max()
		local count = math.min(stack:get_count(), max_count)
		local size = 0.2 + 0.1 * (count / max_count) ^ (1 / 3)
		local def = minetest.registered_items[itemname]
		local glow = def and def.light_source and
			math.floor(def.light_source / 2 + 0.5)

		local size_bias = 1e-3 * math.random() -- small random bias to counter Z-fighting
		local c = {-size, -size, -size, size, size, size}
		self.object:set_properties({
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = size + size_bias, y = size + size_bias},
			collisionbox = c,
			automatic_rotate = math.pi * 0.5 * 0.2 / size,
			wield_item = self.itemstring,
			glow = glow,
		})

		-- cache for usage in on_step
		self._collisionbox = c
	end,

	get_staticdata = function(self)
		return minetest.serialize({
			itemstring = self.itemstring,
			age = self.age,
			dropped_by = self.dropped_by
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.age = (data.age or 0) + dtime_s
				self.dropped_by = data.dropped_by
			end
		else
			self.itemstring = staticdata
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -gravity, z = 0})
		self._collisionbox = self.initial_properties.collisionbox
		self:set_item()
	end,

	try_merge_with = function(self, own_stack, object, entity)
		if self.age == entity.age then
			-- Can not merge with itself
			return false
		end

		local stack = ItemStack(entity.itemstring)
		local name = stack:get_name()
		if own_stack:get_name() ~= name or
				own_stack:get_meta() ~= stack:get_meta() or
				own_stack:get_wear() ~= stack:get_wear() or
				own_stack:get_free_space() == 0 then
			-- Can not merge different or full stack
			return false
		end

		local count = own_stack:get_count()
		local total_count = stack:get_count() + count
		local max_count = stack:get_stack_max()

		if total_count > max_count then
			return false
		end
		-- Merge the remote stack into this one

		local pos = object:get_pos()
		pos.y = pos.y + ((total_count - count) / max_count) * 0.15
		self.object:move_to(pos)

		self.age = 0 -- Handle as new entity
		own_stack:set_count(total_count)
		self:set_item(own_stack)

		entity.itemstring = ""
		object:remove()
		return true
	end,

	enable_physics = function(self)
		if not self.physical_state then
			self.physical_state = true
			self.object:set_properties({physical = true})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=-gravity, z=0})
		end
	end,

	disable_physics = function(self)
		if self.physical_state then
			self.physical_state = false
			self.object:set_properties({physical = false})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		end
	end,

	on_step = function(self, dtime, moveresult)
		self.age = self.age + dtime
		if time_to_live > 0 and self.age > time_to_live then
			self.itemstring = ""
			self.object:remove()
			return
		end
                if not self.item_magnet_timer then
			self.item_magnet_timer = 0
		end
		if self.item_magnet_timer >= 0 then
			self.item_magnet_timer = self.item_magnet_timer - dtime
		end

		local pos = self.object:get_pos()
		local node = minetest.get_node_or_nil(pos)

		-- Destroy item in 'destroys_items' nodes (unless the item has the 'immortal_item' group set)
		if node and minetest.get_item_group(node.name, "destroys_items") == 1 then
			if minetest.get_item_group(ItemStack(self.itemstring):get_name(), "immortal_item") == 0 then
				if minetest.get_item_group(node.name, "lava") ~= 0 or minetest.get_item_group(node.name, "fire") ~= 0 then
					minetest.sound_play("builtin_item_lava", {pos = pos, gain = 0.45})
				end
				add_item_death_particle(self)
				minetest.log("action", "[rp_builtin_item] Item entity destroyed in item-destroying node at "..minetest.pos_to_string(pos))
				self.object:remove()
			return
			end
		end

		-- Item magnet: Attract item to closest living player
		local object = self.object
		local objects_around = minetest.get_objects_inside_radius(self.object:get_pos(), ITEM_MAGNET_ACTIVE_DISTANCE)
		local closest_dist = math.huge
		local closest_player = nil
		local playerpos
		for o=1, #objects_around do
			local player = objects_around[o]
			if player:is_player() then
				playerpos = player:get_pos()
				playerpos.y = playerpos.y + ITEM_MAGNET_HAND_HEIGHT
				if vector.distance(playerpos, pos) < closest_dist and player:get_hp() > 0 then
					closest_dist = vector.distance(playerpos, pos)
					closest_player = player
				end
			end
		end

		local lua = object:get_luaentity()

		if object == nil or lua == nil or lua.itemstring == nil then
			return
		end

		-- Item magnet handling
		local len, vec
		if closest_player then
			vec = {
				x = playerpos.x - pos.x,
				y = playerpos.y - pos.y,
				z = playerpos.z - pos.z
			}
			len = vector.length(vec)
		end
		if closest_player ~= nil and lua.item_magnet_timer <= 0 and len < ITEM_MAGNET_ACTIVE_DISTANCE then
			local inv = closest_player:get_inventory()
			local luastack = ItemStack(lua.itemstring)
			-- Activate item magnet
			if inv and inv:room_for_item("main", luastack) then
				if len >= ITEM_MAGNET_COLLECT_DISTANCE then
					-- Attract item to player
					vec = vector.divide(vec, len) -- It's a normalize but we have len yet (vector.normalize(vec))

					vec.x = vec.x*ITEM_MAGNET_ATTRACT_SPEED
					vec.y = vec.y*ITEM_MAGNET_ATTRACT_SPEED
					vec.z = vec.z*ITEM_MAGNET_ATTRACT_SPEED

					object:set_velocity(vec)
					self:disable_physics()
					self.item_magnet = true
					return
				else
					-- Player collects item if close enough
					if inv:room_for_item("main", luastack) then
						if minetest.is_creative_enabled(closest_player:get_player_name()) then
							if not inv:contains_item("main", luastack, true) and not util.contains_item_canonical(inv, "main", luastack) then
								inv:add_item("main", luastack)
							end
						else
							inv:add_item("main", luastack)
						end

						if lua.itemstring ~= "" then
							minetest.sound_play(
								"builtin_item_pickup",
								{
									pos = pos,
									gain = 0.3,
									max_hear_distance = 16
							}, true)
						end

						-- Notify nav mod of inventory change
						if nav_mod and lua.itemstring == "rp_nav:map" then
							nav.map.update_hud_flags(closest_player)
						end

						lua.itemstring = ""
						object:remove()
						return
					end
					return
				end
			end
		else
			-- Deactivate item magnet if out of range
			if lua.item_magnet then
				self:enable_physics()
				lua.item_magnet = false
				return
			end
		end

		-- Force item out of solid nodes
		if self.force_out then
			-- This code runs after the entity got a push from the is_stuck code.
			-- It makes sure the entity is entirely outside the solid node
			local c = self._collisionbox
			local s = self.force_out_start
			local f = self.force_out
			local ok = (f.x > 0 and pos.x + c[1] > s.x + 0.5) or
				(f.y > 0 and pos.y + c[2] > s.y + 0.5) or
				(f.z > 0 and pos.z + c[3] > s.z + 0.5) or
				(f.x < 0 and pos.x + c[4] < s.x - 0.5) or
				(f.z < 0 and pos.z + c[6] < s.z - 0.5)
			if ok then
				-- Item was successfully forced out
				self.force_out = nil
				self:enable_physics()
				return
			end
		end

		if not self.physical_state then
			return -- Don't do anything
		end

		assert(moveresult,
			"Collision info missing, this is caused by an out-of-date/buggy mod or game")

		if not moveresult.collides then
			-- future TODO: items should probably decelerate in air
			return
		end

		-- Push item out when stuck inside solid node
		local is_stuck = false
		local snode = minetest.get_node_or_nil(pos)
		if snode then
			local sdef = minetest.registered_nodes[snode.name] or {}
			is_stuck = (sdef.walkable == nil or sdef.walkable == true)
				and (sdef.collision_box == nil or sdef.collision_box.type == "regular")
				and (sdef.node_box == nil or sdef.node_box.type == "regular")
		end

		if is_stuck then
			local shootdir
			local order = {
				{x=1, y=0, z=0}, {x=-1, y=0, z= 0},
				{x=0, y=0, z=1}, {x= 0, y=0, z=-1},
			}

			-- Check which one of the 4 sides is free
			for o = 1, #order do
				local cnode = minetest.get_node(vector.add(pos, order[o])).name
				local cdef = minetest.registered_nodes[cnode] or {}
				if cnode ~= "ignore" and cdef.walkable == false then
					shootdir = order[o]
					break
				end
			end
			-- If none of the 4 sides is free, check upwards
			if not shootdir then
				shootdir = {x=0, y=1, z=0}
				local cnode = minetest.get_node(vector.add(pos, shootdir)).name
				if cnode == "ignore" then
					shootdir = nil -- Do not push into ignore
				end
			end

			if shootdir then
				-- Set new item moving speed accordingly
				local newv = vector.multiply(shootdir, 3)
				self:disable_physics()
				self.object:set_velocity(newv)

				self.force_out = newv
				self.force_out_start = vector.round(pos)
				return
			end
		end

		node = nil -- ground node we're colliding with
		if moveresult.touching_ground then
			for _, info in ipairs(moveresult.collisions) do
				if info.axis == "y" then
					node = minetest.get_node(info.node_pos)
					break
				end
			end
		end

		-- Slide on slippery nodes
		local def = node and minetest.registered_nodes[node.name]
		local keep_movement = false

		if def then
			local slippery = minetest.get_item_group(node.name, "slippery")
			local vel = self.object:get_velocity()
			if slippery ~= 0 and (math.abs(vel.x) > 0.1 or math.abs(vel.z) > 0.1) then
				-- Horizontal deceleration
				local factor = math.min(4 / (slippery + 4) * dtime, 1)
				self.object:set_velocity({
					x = vel.x * (1 - factor),
					y = 0,
					z = vel.z * (1 - factor)
				})
				keep_movement = true
			end
		end

		if not keep_movement then
			self.object:set_velocity({x=0, y=0, z=0})
		end

		if self.moving_state == keep_movement then
			-- Do not update anything until the moving state changes
			return
		end
		self.moving_state = keep_movement

		-- Only collect items if not moving
		if self.moving_state then
			return
		end
		-- Collect the items around to merge with
		local own_stack = ItemStack(self.itemstring)
		if own_stack:get_free_space() == 0 then
			return
		end
		local objects = minetest.get_objects_inside_radius(pos, 1.0)
		for k, obj in pairs(objects) do
			local entity = obj:get_luaentity()
			if entity and entity.name == "__builtin:item" then
				if self:try_merge_with(own_stack, obj, entity) then
					own_stack = ItemStack(self.itemstring)
					if own_stack:get_free_space() == 0 then
						return
					end
				end
			end
		end
	end,
})
