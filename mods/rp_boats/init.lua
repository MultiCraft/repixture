local S = minetest.get_translator("rp_boats")

local STATE_FALLING = 1 -- free fall
local STATE_SINKING = 2 -- inside a liquid and sinking
local STATE_FLOATING = 3 -- floating on liquid, stable
local STATE_FLOATING_UP = 4 -- floating on liquid, correcting upwards
local STATE_FLOATING_DOWN = 5 -- floating on liquid, correcting downwards
local STATE_ON_GROUND = 6 -- on solid ground

local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81 --gravity
local LIQUID_SINK_SPEED = 1 -- how fast the boat will sink inside a liquid
local FLOAT_UP_SPEED = 0.1 -- how fast the boat will move upwards if slightly below liquid surface
local FLOAT_DOWN_SPEED = -FLOAT_UP_SPEED -- how fast the boat will move downwards if slightly above liquid surface

local DRAG_FACTOR = 0.1 -- How fast the boat will slow down
local DRAG_FACTOR_HIGH = 1 -- Higher slow down rate when not swimming/floating
local DRAG_CONSTANT = 0.01
local DRAG_CONSTANT_HIGH = 0.1

local is_water = function(nodename)
	local def = minetest.registered_nodes[nodename]
	if not def then
		return false
	end
	if def.liquidtype ~= "none" and minetest.get_item_group(nodename, "water") ~= 0 then
		return true
	end
	return false
end

local set_driver = function(self, driver, orig_collisionbox)
	self._driver = driver
	local colbox = table.copy(orig_collisionbox)

	-- Add player height to boat collisionbox top Y
	-- so the player will also collide.
	local dcolbox = driver:get_properties().collisionbox
	colbox[5] = colbox[5] + (dcolbox[5] - dcolbox[2])
	local props = self.object:get_properties()
	props.collisionbox = colbox
	self.object:set_properties(props)
end

local unset_driver = function(self, orig_collisionbox)
	self._driver = nil
	local colbox = table.copy(orig_collisionbox)
	local props = self.object:get_properties()
	props.collisionbox = colbox
	self.object:set_properties(props)
end

-- Returns false if not enough space to mount boat at pos
local check_space = function(pos, player, side, top)
   local tiny = 0.01
   local side = side - tiny
   local bottom = -tiny
   local top = top + tiny

   local offsets = {
           -- Format: { Xmin, Ymin, Zmin, Xmax, Ymax, Zmax }
           -- middle vertical ray
           { 0, bottom, 0, 0, top, 0 },
           -- for testing the 4 vertical edges of the collisionbox
           { -side, bottom, -side, -side, top, -side },
           { -side, bottom,  side, -side, top,  side },
           {  side, bottom, -side,  side, top, -side },
           {  side, bottom,  side,  side, top,  side },
   }
   -- Finally check the rays
   for i=1, #offsets do
      local off_start = vector.new(offsets[i][1], offsets[i][2], offsets[i][3])
      local off_end = vector.new(offsets[i][4], offsets[i][5], offsets[i][6])
      local ray_start = vector.add(pos, off_start)
      local ray_end = vector.add(pos, off_end)
      local ray = minetest.raycast(ray_start, ray_end, false, false)
      local on_ground_only = true
      local collide = false
      while true do
         local thing = ray:next()
         if not thing then
            break
         end
         if thing.type == "node" then
            local node = minetest.get_node(thing.under)
            local def = minetest.registered_nodes[node.name]
            if def and def.walkable then
               return false
            end
         end
      end
   end
   return true
end

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
		hp_max = def.hp_max or 4,

		_state = STATE_FALLING,
		_driver = nil,
		_speed = 0,

		on_activate = function(self, staticdata, dtime_s)
			local data = minetest.deserialize(staticdata)
			if data then
				self._state = data._state or STATE_FALLING
				self._speed = data._speed or 0
			end
		end,
		get_staticdata = function(self)
			local data = {
				_state = self._state,
				_speed = self._speed,
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
			local v = curvel * math.sign(self._speed)
			self._speed = math.sqrt(v.x ^ 2 + v.z ^ 2)

			-- Update boat state (for Y movement)
			if mydef and mydef_below and mydef_above then
				if moveresult.collides and moveresult.touching_ground then
					-- No-op
				elseif mydef.liquidtype ~= "none" and is_water(mynode.name) then
					self._state = STATE_SINKING
				elseif mydef_below.liquidtype ~= "none" and is_water(mynode_below.name) then
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
			local v = self._speed
			local moved = false
			if self._driver then
				if not self._driver:is_player() then
					unset_driver(self, def.collisionbox)
				else
					local ctrl = self._driver:get_player_control()
					if ctrl.left and not ctrl.right then
						yaw = yaw + def.yaw_change_rate * dtime
						self.object:set_yaw(yaw)
					elseif ctrl.right and not ctrl.left then
						yaw = yaw - def.yaw_change_rate * dtime
						self.object:set_yaw(yaw)
					end
					if self._state == STATE_FLOATING or self._state == STATE_FLOATING_UP or self._state == STATE_FLOATING_DOWN then
						if ctrl.up and not ctrl.down then
							v = math.min(def.max_speed, v + def.speed_change_rate * dtime)
							moved = true
						elseif ctrl.down and not ctrl.up then
							v = math.max(-def.max_speed, v - def.speed_change_rate * dtime)
							moved = true
						end
					end
				end
			end

			-- Slow down boat if not moved by driver
			if not moved then
				local f, c
				if self._state ~= STATE_FLOATING and self._state ~= STATE_FLOATING_UP and self._state ~= STATE_FLOATING_DOWN then
					-- Higher slow down rate when not floating on liquid
					f = DRAG_FACTOR_HIGH
					c = DRAG_CONSTANT_HIGH
				else
					f = DRAG_FACTOR
					c = DRAG_CONSTANT
				end
				local drag = dtime * math.sign(v) * (c + f * v * v)
				if math.abs(v) <= math.abs(drag) then
					v = 0
				else
					v = v - drag
				end
			end
			if math.abs(v) < 0.001 then
				v = 0
			end

			self._speed = v
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
				if self._driver then
					if self._driver == clicker then
						-- Detach driver
						local driver = self._driver
						self._driver:set_detach()
						-- Put driver slightly above the boat
						local dpos = vector.add(vector.new(0, def.detach_offset_y, 0), self.object:get_pos())
						minetest.after(0.1, function(param)
							if not param.driver or not param.driver:is_player() then
								return
							end
							param.driver:set_pos(param.pos)
						end, {driver=driver, pos=dpos})
					end
				else
					if clicker:get_attach() == nil then
						local pos = self.object:get_pos()
						if not check_space(pos, clicker, 0.49, 2) then
							minetest.chat_send_player(
								clicker:get_player_name(),
								minetest.colorize("#FFFF00", S("Not enough space to enter!")))
							return
						end
						minetest.log("action", "[rp_boats] "..cname.." attaches to boat at "..minetest.pos_to_string(self.object:get_pos(),1))
						set_driver(self, clicker, def.collisionbox)
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
				unset_driver(self, def.collisionbox)
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
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
			if damage >= 1 then
				-- TODO: Add custom sound
				minetest.sound_play({name = "default_dig_hard"}, {pos=self.object:get_pos()}, true)
			end
		end,
	})

	minetest.register_craftitem(itemstring, {
		description = def.description,
		_tt_help = def._tt_help,
		liquids_pointable = true,
		groups = { boat = 1 },
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		on_place = function(itemstack, placer, pointed_thing)
			-- Boilerplace to handle pointed node's rightclick handler
			if not placer or not placer:is_player() then
				return itemstack
			end
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			local pos1 = pointed_thing.above
			local node1 = minetest.get_node(pos1)
			local ndef1 = minetest.registered_nodes[node1.name]
			local pos2 = pointed_thing.under
			local node2 = minetest.get_node(pos2)
			local ndef2 = minetest.registered_nodes[node2.name]
			if ndef2 and ndef2.on_rightclick and
			((not placer) or (placer and not placer:get_player_control().sneak)) then
				return ndef2.on_rightclick(pointed_thing.under, node2, placer, itemstack,
					pointed_thing) or itemstack
			end

			-- Get place position
			local place_pos = table.copy(pos1)
			if pos1.x == pos2.x and pos1.z == pos2.z and ndef2 and ndef2.liquidtype ~= "none" and minetest.get_item_group(node2.name, "fake_liquid") == 0 then
				place_pos = vector.add(place_pos, {x=0, y=-def.float_offset, z=0})
			end
			if ndef1 and not ndef1.walkable then
				-- Place boat
				local ent = minetest.add_entity(place_pos, itemstring)
				if ent then
					-- TODO: Add custom sound
					minetest.sound_play({name = "default_place_node_hard"}, {pos=place_pos}, true)
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

-- Register boats
local log_boats = {
	{ "wood", S("Wood Log Boat"), "rp_default:tree" },
	{ "birch", S("Birch Log Boat"), "rp_default:tree_birch" },
	{ "oak", S("Oak Log Boat"), "rp_default:tree_oak" },
}
for l=1, #log_boats do
	local id = log_boats[l][1]
	register_boat("log_boat_"..id, {
		description = log_boats[l][2],
		_tt_help = S("Water vehicle"),
		collisionbox = { -0.49, -0.49, -0.49, 0.49, 0.49, 0.49 },
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
		mesh = "rp_boats_log_boat.obj",
		hp_max = 4,

		float_offset = 0.3,
		attach_offset = { x=0, y=0, z=0 },
		max_speed = 3.8,
		speed_change_rate = 1.5,
		yaw_change_rate = 0.2,
		detach_offset_y = 0.8,
	})
	crafting.register_craft({
		output = "rp_boats:log_boat_"..id,
		items = {
			log_boats[l][3] .. " 2",
		},
	})
end

local rafts = {
	{ "wood", S("Wood Raft"), "rp_default:planks" },
	{ "birch", S("Birch Raft"), "rp_default:planks_birch" },
	{ "oak", S("Oak Raft"), "rp_default:planks_oak" },
}
for r=1, #rafts do
	local id = rafts[r][1]
	register_boat("raft_"..id, {
		description = rafts[r][2],
		_tt_help = S("Water vehicle"),
		collisionbox = { -0.74, -0.3, -0.74, 0.74, 0.1, 0.74 },
		selectionbox = { -1, -0.301, -1, 1, 0.101, 1 },
		inventory_image = "rp_boats_boat_raft_"..id.."_item.png",
		wield_image = "rp_boats_boat_raft_"..id.."_item.png",
		textures = {
			"rp_boats_boat_raft_"..id..".png",
			"rp_boats_boat_raft_"..id..".png",
			"rp_boats_boat_raft_"..id..".png",
			"rp_boats_boat_raft_"..id..".png",
			"rp_boats_boat_raft_"..id..".png",
			"rp_boats_boat_raft_"..id..".png",
		},
		mesh = "rp_boats_raft.obj",
		hp_max = 4,

		float_offset = 0.4,
		attach_offset = { x=0, y=1, z=0 },
		max_speed = 6,
		speed_change_rate = 1.5,
		yaw_change_rate = 0.6,
		detach_offset_y = 0.2,
	})
	crafting.register_craft({
		output = "rp_boats:raft_"..id,
		items = {
			rafts[r][3] .. " 8",
			"rp_default:fiber 10",
			"rp_default:stick 5",
		},
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:boat",
	burntime = 30,
})

