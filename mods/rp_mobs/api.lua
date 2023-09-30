-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true

	rp_mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

rp_mobs.drop_death_items = function(self, pos)
	if not pos then
		pos = self.object:get_pos()
	end
	local mobdef = rp_mobs.registered_mobs[self.name]
	if not mobdef then
		error("[rp_mobs] rp_mobs.drop_death_items was called on something that is not a registered mob! name="..tostring(self.name))
	end
	if mobdef.drops then
		for d=1, #mobdef.drops do
			minetest.add_item(pos, mobdef.drops[d])
		end
	end
end

rp_mobs.on_death_default = function(self, killer)
	rp_mobs.drop_death_items(self)
end

rp_mobs.init_physics = function(self)
	self._mob_acceleration = vector.zero()
	self._phys_acceleration = {}
	self._mob_velocity = vector.zero()
	self._phys_velocity = {}

	self._phys_acceleration_changed = false
	self._phys_velocity_changed = false
	self._mob_acceleration_changed = false
	self._mob_velocity_changed = false
end

rp_mobs.activate_gravity = function(self)
	for i=1, #self._phys_acceleration do
		local entry = self._phys_acceleration[i]
		if entry.name == "rp_mobs:gravity" then
			return
		end
	end
	table.insert(self._phys_acceleration, { name = "rp_mobs:gravity", vec = {x=0, y=-GRAVITY, z=0}})
	self._phys_acceleration_changed = true
end
rp_mobs.deactivate_gravity = function(self)
	for i=1, #self._phys_acceleration do
		local entry = self._phys_acceleration[i]
		if entry.name == "rp_mobs:gravity" then
			table.remove(self._phys_acceleration, i)
			self._phys_acceleration_changed = true
			return
		end
	end
end

rp_mobs.handle_physics = function(self)
	if not self._cmi_is_mob then
		local entname = self.name or "<UNKNOWN>"
		minetest.log("error", "[rp_mobs] rp_mobs.handle_physics was called on '"..entname.."' which is not a registered mob!")
	end
	if not self._phys_acceleration then
		local entname = self.name or "<UNKNOWN>"
		minetest.log("error", "[rp_mobs] rp_mobs.handle_physics was called on '"..entname.."' with uninitialized physics variables!")
	end
	if self._phys_acceleration_changed or self._mob_acceleration_changed then
		local acceleration = vector.zero()
		for i=1, #self._phys_acceleration do
			local entry = self._phys_acceleration[i]
			acceleration = vector.add(acceleration, entry.vec)
		end
		acceleration = vector.add(acceleration, self._mob_acceleration)
		self.object:set_acceleration(acceleration)

		self._phys_acceleration_changed = false
		self._mob_acceleration_changed = false
	end
	if self._phys_velocity_changed or self._mob_velocity_changed then
		local velocity = vector.zero()
		for i=1, #self._phys_velocity do
			local entry = self._phys_velocity[i]
			velocity = vector.add(velocity, entry.vec)
		end
		velocity = vector.add(velocity, self._mob_velocity)
		self.object:set_velocity(velocity)

		self._phys_velocity_changed = false
		self._mob_velocity_changed = false
	end
end

rp_mobs.init_tasks = function(self)
	self._tasks = rp_mobs.DoublyLinkedList()
end

rp_mobs.add_task = function(self, task)
	local handler = self._tasks:append(task)
	task.microTasks = rp_mobs.DoublyLinkedList()
	if task.generateMicroTasks then
		task:generateMicroTasks()
	end
end

rp_mobs.create_task = function(def)
	local task
	if def then
		task = table.copy(def)
	else
		task = {}
	end
	return task
end

rp_mobs.create_microtask = function(def)
	local mtask
	if def then
		mtask = table.copy(def)
	else
		mtask = {}
	end
	mtask.statedata = {}
	return mtask
end

rp_mobs.add_microtask_to_task  = function(self, microtask, task)
	return task.microTasks:append(microtask)
end

rp_mobs.handle_tasks = function(self)
	if not self._tasks then
		minetest.log("error", "[rp_mobs] rp_mobs.handle_tasks called before tasks were initialized!")
		return
	end
	local activeTaskEntry = self._tasks:getFirst()
	if not activeTaskEntry then
		return
	end
	local activeTask = activeTaskEntry.data

	local activeMicroTaskEntry = activeTask.microTasks:getFirst()
	if not activeMicroTaskEntry then
		self._tasks:remove(activeTaskEntry)
		return
	end

	local activeMicroTask = activeMicroTaskEntry.data
	if not activeMicroTask.singlestep and activeMicroTask:is_finished(self) then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		return
	end

	activeMicroTask:on_step(self)

	if activeMicroTask.singlestep then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		return
	end
end

rp_mobs.register_mob_item = function(mobname, invimg, desc)
	local place
	if not desc then
		desc = rp_mobs.registered_mobs[mobname].description
	end
	minetest.register_craftitem(mobname, {
		description = desc,
		inventory_image = invimg,
		groups = { spawn_egg = 1 },
		on_place = function(itemstack, placer, pointed_thing)
			local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
			if handled then
				return handled_itemstack
			end
			if pointed_thing.type == "node" then
				local pos = pointed_thing.above
				local pname = placer:get_player_name()
				if minetest.is_protected(pos, pname) and
						not minetest.check_player_privs(placer, "protection_bypass") then
					 minetest.record_protection_violation(pos, pname)
					 return itemstack
				end

				pos.y = pos.y + 0.5
				local mob = minetest.add_entity(pos, mobname)
				local ent = mob:get_luaentity()
				if ent.type ~= "monster" then
					-- set owner
					ent.owner = pname
					ent.tamed = true
				end
				 minetest.log("action", "[rp_mobs] "..pname.." spawns "..mobname.." at "..minetest.pos_to_string(pos, 1))
				if not minetest.is_creative_enabled(pname) then
					 itemstack:take_item()
				end
			end
			return itemstack
		end,
	})
end


-- TODO
rp_mobs.feed_tame = function()
end

-- TODO
rp_mobs.capture_mob = function()
end
