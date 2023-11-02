-- Functions related to mob damage

-- Interval (seconds) at which mobs MAY take node damage (damage_per_second)
local NODE_DAMAGE_TIME = 1.0
-- Interval (seconds) at which mobs MAY take drowning damage
local DROWNING_TIME = 2.0
-- Interval (seconds) at which mobs regenerate breath (if they have breath)
local REBREATH_TIME = 0.5
-- Minimum Y fall height before starting to take fall damage
local FALL_DAMAGE_HEIGHT = 5



function rp_mobs.init_breath(self, can_drown, def)
	if self._can_drown ~= nil then
		return
	end
	self._can_drown = can_drown
	self._breath_max = def.breath_max
	self._breath = def.breath_max
	self._drowning_point = def.drowning_point
end
function rp_mobs.init_node_damage(self, get_node_damage)
	if self._get_node_damage ~= nil then
		return
	end
	self._get_node_damage = get_node_damage
end
function rp_mobs.init_fall_damage(self, get_fall_damage)
	if self._get_fall_damage ~= nil then
		return
	end
	self._get_fall_damage = get_fall_damage
	if not self._standing_y then
		self._standing_y = self.object:get_pos().y
	end
end

function rp_mobs.handle_node_damage(self, dtime)
	if not self._get_node_damage then
		return
	end

	if not rp_mobs.is_alive(self) then
		return
	end
	if not self._node_damage_timer then
		self._node_damage_timer = 0.0
	end

	local pos = self.object:get_pos()
	pos.y = pos.y - 0.5
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	self._node_damage_timer = self._node_damage_timer + dtime
	if self._node_damage_timer >= NODE_DAMAGE_TIME then
		if def and def.damage_per_second and def.damage_per_second > 0 then
			if rp_mobs.damage(self, def.damage_per_second, { type = "node_damage" }) then
				return
			end
		end
		self._node_damage_timer = 0.0
	end
end

-- Rotate vector `vec` around yaw (in radians)
local function rotate_vector_yaw(vec, yaw)
	local sy = math.sin(-yaw)
	local cy = math.cos(yaw)
	local rotated_vector = vector.new()
	rotated_vector.x = sy * vec.z
	rotated_vector.y = vec.y
	rotated_vector.z = -sy * vec.x + cy * vec.z
	return rotated_vector
end

function rp_mobs.handle_drowning(self, dtime)
	if not self._can_drown then
		return
	end
	if not rp_mobs.is_alive(self) then
		return
	end
	if not self._drowning_timer then
		self._drowning_timer = 0.0
	end
	if not self._rebreath_timer then
		self._rebreath_timer = 0.0
	end

	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()
	local drowning_point = self._drowning_point or vector.zero()
	drowning_point = rotate_vector_yaw(drowning_point, yaw)
	pos = vector.add(pos, drowning_point)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		-- No breath change in ignore
		return
	end
	local def = minetest.registered_nodes[node.name]

	-- Reduce breath and deal damage if 0
	if def and def.drowning and def.drowning > 0 then
		self._drowning_timer = self._drowning_timer + dtime
		if self._drowning_timer >= DROWNING_TIME then
			self._breath = math.max(0, self._breath - 1)
			if self._breath <= 0 then
				if rp_mobs.damage(self, def.drowning, { type = "drown" }) then
					return
				end
			end
			self._drowning_timer = 0.0
		end
		self._rebreath_timer = 0.0
	-- Catch breath again in non-drowning node
	elseif def and def.drowning and def.drowning == 0 then
		self._rebreath_timer = self._rebreath_timer + dtime
		if self._rebreath_timer >= REBREATH_TIME then
			self._breath = math.min(self._breath_max, self._breath + 1)
			self._rebreath_timer = 0.0
		end
		self._drowning_timer = 0.0
	end
end

function rp_mobs.handle_fall_damage(self, dtime, moveresult)
	if not self._get_fall_damage then
		return
	end
	if not rp_mobs.is_alive(self) then
		return
	end

	local mob_fall_factor = 1
	local armor = self.object:get_armor_groups()
	-- Apply mob’s fall_damage_add_percent modifier
	if armor.fall_damage_add_percent then
		mob_fall_factor = 1 + armor.fall_damage_add_percent/100
	end
	local is_immortal = armor.immortal ~= nil and armor.immortal ~= 0
	if moveresult.collides then
		local collisions = moveresult.collisions
		for c=1, #collisions do
			local collision = collisions[c]
			local old_v = collision.old_velocity
			local new_v = collision.new_velocity
			local speed_diff = vector.subtract(new_v, old_v)

			-- We only care about floor collision
			if (not (speed_diff.y < 0 or old_v.y >= 0)) then

				-- Apply node’s fall_damage_add_percent modifier
				local node_fall_factor = 1.0
				if collision.type == "node" then
					local node = minetest.get_node(collision.node_pos)
					local g = minetest.get_item_group(node.name, "fall_damage_add_percent")
					if g ~= 0 then
						node_fall_factor = 1 + g/100
					end
				end

				-- Calculate final fall damage modifier
				local pre_factor = mob_fall_factor * node_fall_factor

				-- Fall damage is based on fall height. When falling at least the
				-- FALL_DAMAGE_HEIGHT, mob may take 1 damage per extra node fallen
				local y_diff = self._standing_y - self.object:get_pos().y

				-- Apply damage modifier
				y_diff = y_diff * pre_factor

				if (y_diff >= FALL_DAMAGE_HEIGHT and (not is_immortal) and pre_factor > 0) then
					local damage_f = y_diff - FALL_DAMAGE_HEIGHT
					local damage = math.floor(math.min(damage_f + 0.5, 65535))
					if damage > 0 then
						if rp_mobs.damage(self, damage, { type = "fall" }) then
							return
						end
					end
				end
			end
		end
	end
	if moveresult.touching_ground then
		self._standing_y = self.object:get_pos().y
	end
end

function rp_mobs.handle_environment_damage(self, dtime, moveresult)
	rp_mobs.handle_fall_damage(self, dtime, moveresult)
	rp_mobs.handle_node_damage(self, dtime)
	rp_mobs.handle_drowning(self, dtime)
end


-- Entity variables to persist:
rp_mobs.add_persisted_entity_vars({
	"_get_node_damage",	-- true when mob can take damage from nodes (damage_per_second)
	"_get_fall_damage",	-- true when mob can take fall damage
	"_standing_y",		-- Y coordinate when mob was standing on ground. Internally used for fall damage calculations
	"_can_drown",		-- true when mob has breath and can drown in nodes with `drowning` attribute
	"_drowning_point",	-- The position offset that will be checked when doing the drowning check
	"_breath_max",		-- Maximum breath
	"_breath",		-- Current breath
})


