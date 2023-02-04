local S = minetest.get_translator("rp_boats")

local STATE_FALLING = 1 -- free fall
local STATE_SINKING = 2 -- inside a liquid and sinking
local STATE_FLOATING = 3 -- floating on liquid, stable
local STATE_FLOATING_UP = 4 -- floating on liquid, correcting upwards
local STATE_FLOATING_DOWN = 5 -- floating on liquid, correcting downwards
local STATE_ON_GROUND = 6 -- on solid ground

local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81
local LIQUID_SINK_SPEED = 1
local FLOAT_UP_SPEED = 0.1
local FLOAT_DOWN_SPEED = -FLOAT_UP_SPEED

local MAX_HOR_SPEED = 6
local HOR_SPEED_CHANGE_RATE = 0.075
local YAW_CHANGE_RATE = 0.01

local register_boat = function(name, def)
	minetest.register_entity("rp_boats:"..name, {
		physical = true,
		collide_with_objects = true,
		collisionbox = { -0.49, -0.49, -0.49, 0.45, 0.49, 0.49 },
		selectionbox = { -1, -0.501, -1, 1, 0.501, 1 },
		textures = {
			"default_tree.png^[transformR90",
			"default_tree_top.png",
			"default_tree.png",
			"default_tree.png",
			"default_wood.png",
			"default_tree.png^[transformR90",
		},
		visual = "mesh",
		mesh = "rp_boats_log_float.obj",

		_state = STATE_FALLING,
		_last_state = nil,
		_driver = nil,
		_horvel = 0,

		on_activate = function(self, staticdata, dtime_s)
			local data = minetest.deserialize(staticdata)
			if data then
				self._state = data._state or STATE_FALLING
				self._horvel = data._horvel or 0
			end
		end,
		get_staticdata = function(self)
			local data = {
				_state = self._state,
				_horvel = self._horvel,
			}
			return minetest.serialize(data)
		end,
		on_step = function(self, dtime, moveresult)
			local mypos = self.object:get_pos()
			local mynode = minetest.get_node(mypos)
			local mydef = minetest.registered_nodes[mynode.name]
			local mypos_below = vector.add(mypos, {x=0,y=-1,z=0})
			local mynode_below = minetest.get_node(mypos_below)
			local mydef_below = minetest.registered_nodes[mynode_below.name]
			local mypos_above = vector.add(mypos, {x=0,y=1,z=0})
			local mynode_above = minetest.get_node(mypos_above)
			local mydef_above = minetest.registered_nodes[mynode_above.name]

			-- Update boat state (for Y movement)
			if mydef and mydef_below and mydef_above then
				if moveresult.collides and moveresult.touching_ground then
					-- stuck in solid node
					--self._state = STATE_ON_GROUND
				elseif mydef.liquidtype ~= "none" then
					self._state = STATE_SINKING
				elseif mydef_below.liquidtype ~= "none" then
					local yvel = 0
					local frac = mypos.y % 1
					local BUYOY = 0.7
					local BUYOY_ANTI = 1 - BUYOY
					if frac < BUYOY - 0.01 and frac > BUYOY_ANTI then
						self._state = STATE_FLOATING_UP
					elseif frac > BUYOY + 0.01 or frac <= BUYOY_ANTI then
						self._state = STATE_FLOATING_DOWN
					else
						self._state = STATE_FLOATING
					end
				elseif not mydef.walkable and not mydef_below.walkable then
					self._state = STATE_FALLING
				end
			else
				self._state = STATE_ON_GROUND
			end

			-- Boat controls

			local horvel = {x=0, y=0, z=0}
			local vertvel = {x=0, y=0, z=0}
			local vertacc = {x=0, y=0, z=0}

			local yaw = self.object:get_yaw()
			local v = self._horvel
			if self._driver then
				if not self._driver:is_player() then
					self._driver = nil
				end
				local ctrl = self._driver:get_player_control()
				if ctrl.left and not ctrl.right then
					yaw = yaw + YAW_CHANGE_RATE
					self.object:set_yaw(yaw)
				elseif ctrl.right and not ctrl.left then
					yaw = yaw - YAW_CHANGE_RATE
					self.object:set_yaw(yaw)
				end
				if ctrl.up and not ctrl.down then
					v = math.min(MAX_HOR_SPEED, v + HOR_SPEED_CHANGE_RATE)
				elseif ctrl.down and not ctrl.up then
					v = math.max(-MAX_HOR_SPEED, v - HOR_SPEED_CHANGE_RATE)
				end
			end
			local get_horvel = function(v, yaw)
				local x = -math.sin(yaw) * v
				local z = math.cos(yaw) * v
				return {x=x, y=0, z=z}
			end
			horvel = get_horvel(v, yaw)
			self._horvel = v

			do --if self._state ~= self._last_state or self._last_state == nil then
				if self._state == STATE_FALLING then
					vertacc = {x=0, y=-GRAVITY, z=0}
					vertvel = {x=0, y=0, z=0}
				elseif self._state == STATE_SINKING then
					vertacc = {x=0, y=0, z=0}
					vertvel = {x=0, y=-LIQUID_SINK_SPEED, z=0}
				elseif self._state == STATE_ON_GROUND then
					vertacc = {x=0, y=0, z=0}
					vertvel = {x=0, y=0, z=0}
				elseif self._state == STATE_FLOATING then
					vertacc = {x=0, y=0, z=0}
					vertvel = {x=0, y=0, z=0}
				elseif self._state == STATE_FLOATING_UP then
					vertacc = {x=0, y=0, z=0}
					vertvel = {x=0, y=FLOAT_UP_SPEED, z=0}
				elseif self._state == STATE_FLOATING_DOWN then
					vertacc = {x=0, y=0, z=0}
					vertvel = {x=0, y=FLOAT_DOWN_SPEED, z=0}
				end
			end
			self.object:set_acceleration(vertacc)
			self.object:set_velocity(vector.add(horvel, vertvel))

			self._last_state = self._state

			self.object:set_properties({nametag="state="..self._state.."\n"..
			"mynode_above="..mynode_above.name.."\n"..
			"mynode="..mynode.name.."\n"..
			"mynode_below="..mynode_below.name.."\n"..
			"frac="..(mypos.y%1).."\n"..
			"ground="..tostring(moveresult.collides and moveresult.touching_ground)})
		end,
		on_rightclick = function(self, clicker)
			if clicker and clicker:is_player() then
				if self._driver and self._driver == clicker then
					minetest.log("action", "[rp_boats] "..clicker:get_player_name().." attaches to boat at "..minetest.pos_to_string(self.object:get_pos(),1))
					self._driver:set_detach()
					self._driver = nil
				else
					if clicker:get_attach() == nil then
						minetest.log("action", "[rp_boats] "..clicker:get_player_name().." detaches from boat at "..minetest.pos_to_string(self.object:get_pos(),1))
						self._driver = clicker
						self._driver:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0}, true)
					end
				end
			end
		end,
		on_death = function(self, killer)
			minetest.log("action", "[rp_boats] Boat dies at "..minetest.pos_to_string(self.object:get_pos(),1))
			-- Drop boat item (except in Creative Mode)
			if killer and killer:is_player() and minetest.is_creative_enabled(killer:get_player_name()) then
				return
			end
			minetest.add_item(self.object:get_pos(), "rp_boats:boat")
		end,
	})
end

-- Dummy test boat
register_boat("log_float", {})

minetest.register_craftitem("rp_boats:log_float", {
	description = S("Log Float"),
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end
		local pos = pointed_thing.above
		pos = vector.add(pos, {x=0, y=-0.3, z=0})
		local def = minetest.get_node(pos)
		if def and not def.walkable then
			local ent = minetest.add_entity(pos, "rp_boats:log_float")
			if ent then
				ent:set_yaw(placer:get_look_horizontal())
				minetest.log("action", "[rp_boats] "..placer:get_player_name().." spawns boat at "..minetest.pos_to_string(pos,1))
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end
		end
		return itemstack
	end,
})

crafting.register_craft({
	output = "rp_boats:log_float",
	items = {
		"rp_default:tree 2",
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "rp_boats:log_float",
	burntime = 30,
})
