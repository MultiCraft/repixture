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
local HOR_SPEED_CHANGE_RATE = 1.5
local YAW_CHANGE_RATE = 0.2

local register_boat = function(name, def)
	local itemstring = "rp_boats:"..name
	if not def.attach_offset then
		def.attach_offset = {x=0, y=0, z=0}
	end
	if not def.float_offset then
		def.float_offset = 0
	end

	minetest.register_entity(itemstring, {
		physical = true,
		collide_with_objects = true,
		visual = "mesh",

		collisionbox = def.collisionbox,
		selectionbox = def.selectionbox,
		textures = def.textures,
		mesh = def.mesh,

		_state = STATE_FALLING,
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

			local curvel = self.object:get_velocity()
			local v = curvel * math.sign(self._horvel)
			self._horvel = math.sqrt(v.x ^ 2 + v.z ^ 2)

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
					local buyoy = def.float_offset
					local buyoy_anti = 1 - buyoy
					if frac < buyoy_anti - 0.01 and frac > buyoy then
						self._state = STATE_FLOATING_UP
					elseif frac > buyoy_anti + 0.01 or frac <= buyoy then
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
			local moved = false
			if self._driver then
				if not self._driver:is_player() then
					self._driver = nil
				else
					local ctrl = self._driver:get_player_control()
					if ctrl.left and not ctrl.right then
						yaw = yaw + YAW_CHANGE_RATE * dtime
						self.object:set_yaw(yaw)
					elseif ctrl.right and not ctrl.left then
						yaw = yaw - YAW_CHANGE_RATE * dtime
						self.object:set_yaw(yaw)
					end
					if self._state == STATE_FLOATING or self._state == STATE_FLOATING_UP or self._state == STATE_FLOATING_DOWN then
						if ctrl.up and not ctrl.down then
							v = math.min(MAX_HOR_SPEED, v + HOR_SPEED_CHANGE_RATE * dtime)
							moved = true
						elseif ctrl.down and not ctrl.up then
							v = math.max(-MAX_HOR_SPEED, v - HOR_SPEED_CHANGE_RATE * dtime)
							moved = true
						end
					end
				end
			end

			-- Slow down boat if not moved by driver
			if not moved then
				local drag = dtime * math.sign(v) * (0.01 + 0.1 * v * v)
				if math.abs(v) <= math.abs(drag) then
					v = 0
				else
					v = v - drag
				end
			end
			if math.abs(v) < 0.001 then
				v = 0
			end

			self._horvel = v
			local get_horvel = function(v, yaw)
				local x = -math.sin(yaw) * v
				local z = math.cos(yaw) * v
				return {x=x, y=0, z=z}
			end
			horvel = get_horvel(v, yaw)
			do
				if self._state == STATE_FALLING then
					vertacc = {x=0, y=-GRAVITY, z=0}
					vertvel = {x=0, y=curvel.y, z=0}
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
		end,
		on_rightclick = function(self, clicker)
			if clicker and clicker:is_player() then
				local cname = clicker:get_player_name()
				if self._driver and self._driver == clicker then
					-- Detach driver
					local driver = self._driver
					self._driver:set_detach()
					-- Put driver slightly above the boat
					local dpos = vector.add(vector.new(0, 0.8, 0), self.object:get_pos())
					minetest.after(0.1, function(param)
						if not param.driver or not param.driver:is_player() then
							return
						end
						param.driver:set_pos(param.pos)
					end, {driver=driver, pos=dpos})
				else
					if clicker:get_attach() == nil then
						minetest.log("action", "[rp_boats] "..cname.." attaches to boat at "..minetest.pos_to_string(self.object:get_pos(),1))
						self._driver = clicker
						rp_player.player_attached[cname] = true
						self._driver:set_attach(self.object, "", def.attach_offset, {x=0,y=0,z=0}, true)
					end
				end
			end
		end,
		on_detach_child = function(self, child)
			if child and child == self._driver then
				local cname = child:get_player_name()
				minetest.log("action", "[rp_boats] "..cname.." detaches from boat at "..minetest.pos_to_string(self.object:get_pos(),1))
				rp_player.player_attached[cname] = false
				self._driver = nil
			end
		end,
		on_death = function(self, killer)
			minetest.log("action", "[rp_boats] Boat dies at "..minetest.pos_to_string(self.object:get_pos(),1))
			-- Drop boat item (except in Creative Mode)
			if killer and killer:is_player() and minetest.is_creative_enabled(killer:get_player_name()) then
				return
			end
			minetest.add_item(self.object:get_pos(), itemstring)
		end,
	})

	minetest.register_craftitem(itemstring, {
		description = def.description,
		liquids_pointable = true,
		groups = { boat = 1 },
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			local pos1 = pointed_thing.above
			local node1 = minetest.get_node(pos1)
			local ndef1 = minetest.registered_nodes[node1.name]
			local pos2 = pointed_thing.under
			local node2 = minetest.get_node(pos2)
			local ndef2 = minetest.registered_nodes[node2.name]
			local place_pos = table.copy(pos1)
			if pos1.x == pos2.x and pos1.z == pos2.z and ndef2.liquidtype ~= "none" then
				place_pos = vector.add(place_pos, {x=0, y=-def.float_offset, z=0})
			end
			if ndef1 and not ndef1.walkable then
				local ent = minetest.add_entity(place_pos, itemstring)
				if ent then
					ent:set_yaw(placer:get_look_horizontal())
					minetest.log("action", "[rp_boats] "..placer:get_player_name().." spawns rp_boats:"..name.." at "..minetest.pos_to_string(place_pos, 1))
					if not minetest.is_creative_enabled(placer:get_player_name()) then
						itemstack:take_item()
					end
				end
			end
			return itemstack
		end,
	})
end

-- Log floats
local log_floats = {
	{ "wood", S("Wood Log Float"), "rp_default:tree" },
	{ "birch", S("Birch Log Float"), "rp_default:tree_birch" },
	{ "oak", S("Oak Log Float"), "rp_default:tree_oak" },
}
for l=1,#log_floats do
	local id = log_floats[l][1]
	register_boat("log_float_"..id, {
		description = log_floats[l][2],
		float_offset = 0.3,
		attach_offset = { x=0, y=1, z=0 },
		collisionbox = { -0.49, -0.49, -0.49, 0.45, 0.49, 0.49 },
		selectionbox = { -1, -0.501, -1, 1, 0.501, 1 },
		inventory_image = "rp_boats_boat_log_"..id.."_item.png",
		wield_image = "rp_boats_boat_log_"..id.."_item.png",
		textures = {
			"rp_boats_boat_log_"..id.."_side.png",
			"rp_boats_boat_log_"..id.."_end.png",
			"rp_boats_boat_log_"..id.."_inner_side.png",
			"rp_boats_boat_log_"..id.."_inner_end.png",
			"rp_boats_boat_log_"..id.."_inner.png",
			"rp_boats_boat_log_"..id.."_side.png",
		},
		mesh = "rp_boats_log_float.obj",
	})
	crafting.register_craft({
		output = "rp_boats:log_float_"..id,
		items = {
			log_floats[l][3] .. " 2",
		},
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:boat",
	burntime = 30,
})

