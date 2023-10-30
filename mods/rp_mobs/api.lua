-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

-- If true, will write the task queues of mobs as their nametag
local TASK_DEBUG = true

-- Default gravity that affects the mobs
local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

-- Interval (seconds) at which mobs MAY take node damage (damage_per_second)
local NODE_DAMAGE_TIME = 1.0
-- Interval (seconds) at which mobs MAY take drowning damage
local DROWNING_TIME = 2.0
-- Interval (seconds) at which mobs regenerate breath (if they have breath)
local REBREATH_TIME = 0.5

-- List of entity variables to store in staticdata
-- (so they are persisted when unloading)
local persisted_entity_vars = {}

-- Declare an entity variable name to be persisted on shutdown
-- (recommended only for internal rp_mobs use)
rp_mobs.add_persisted_entity_var = function(name)
	for i=1, #persisted_entity_vars do
		if persisted_entity_vars[i] == name then
			return
		end
	end
	table.insert(persisted_entity_vars, name)
end
-- Same as above, but for a list of variables
rp_mobs.add_persisted_entity_vars = function(names)
	for n=1, #names do
		rp_mobs.add_persisted_entity_var(names[n])
	end
end
rp_mobs.add_persisted_entity_var("_custom_state")

local microtask_to_string = function(microtask)
	return "Microtask: "..(microtask.label or "<UNNAMED>")
end
local task_to_string = function(task)
	local str = "Task: "..(task.label or "<UNNAMED>")
	local next_microtask = task.microTasks:iterator()
	local microtask = next_microtask()
	while microtask do
		str = str .. "\n* " .. microtask_to_string(microtask)
		microtask = next_microtask()
	end
	return str
end
local task_queue_to_string = function(task_queue)
	local str = ""
	local next_task = task_queue:iterator()
	local task = next_task()
	local first = true
	while task do
		if not first then
			str = str .. "\n"
		end
		str = str .. task_to_string(task)
		task = next_task()
		first = false
	end
	return str
end
local set_task_queue_as_nametag = function(self)
	local taskstr = task_queue_to_string(self._tasks)
	self.object:set_properties({
		nametag = taskstr,
	})
end

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true
	mdef.entity_definition._decider = def.decider
	mdef.entity_definition._description = def.description
	mdef.entity_definition._is_animal = def.is_animal
	mdef.entity_definition._base_size = table.copy(def.entity_definition.visual_size or { x=1, y=1, z=1 })
	mdef.entity_definition._base_selbox = table.copy(def.entity_definition.selectionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false })
	mdef.entity_definition._base_colbox = table.copy(def.entity_definition.collisionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5})
	mdef.entity_definition._dying = false

	rp_mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

rp_mobs.get_staticdata_default = function(self)
	local staticdata_table = {}
	for p=1, #persisted_entity_vars do
		local pvar = persisted_entity_vars[p]
		local pvalue = self[pvar]
		staticdata_table[pvar] = pvalue
	end
	local staticdata = minetest.serialize(staticdata_table)
	return staticdata
end

rp_mobs.restore_state = function(self, staticdata)
	local staticdata_table = minetest.deserialize(staticdata)
	if not staticdata_table then
		-- Default for empty/invalid staticdata
		self._custom_state = {}
		self._temp_custom_state = {}
		return
	end
	for k,v in pairs(staticdata_table) do
		self[k] = v
	end

	-- Make small if a child
	if self._child then
		rp_mobs.set_mob_child_size(self)
	end

	-- Make sure the custom state vars are always tables
	if not self._custom_state then
		self._custom_state = {}
	end
	if not self._temp_custom_state then
		self._temp_custom_state = {}
	end
end

rp_mobs.is_alive = function(mob)
	if not mob then
		return false
	elseif mob._dying then
		return false
	else
		return true
	end
end

rp_mobs.drop_death_items = function(self, pos)
	if not pos then
		pos = self.object:get_pos()
	end
	local mobdef = rp_mobs.registered_mobs[self.name]
	if not mobdef then
		error("[rp_mobs] rp_mobs.drop_death_items was called on something that is not a registered mob! name="..tostring(self.name))
	end
	if not self._child and mobdef.drops then
		for d=1, #mobdef.drops do
			minetest.add_item(pos, mobdef.drops[d])
		end
	end
	if self._child and mobdef.child_drops then
		for d=1, #mobdef.child_drops do
			minetest.add_item(pos, mobdef.child_drops[d])
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
	if not rp_mobs.is_alive(self) then
		return
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
	task.microTasks = rp_mobs.DoublyLinkedList()
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

rp_mobs.handle_tasks = function(self, dtime)
	if not self._tasks then
		minetest.log("error", "[rp_mobs] rp_mobs.handle_tasks called before tasks were initialized!")
		return
	end
	if not rp_mobs.is_alive(self) then
		return
	end
	local activeTaskEntry = self._tasks:getFirst()
	if not activeTaskEntry then
		if TASK_DEBUG then
			set_task_queue_as_nametag(self)
		end
		return
	end
	local activeTask = activeTaskEntry.data

	local activeMicroTaskEntry = activeTask.microTasks:getFirst()
	if not activeMicroTaskEntry then
		self._tasks:remove(activeTaskEntry)
		if TASK_DEBUG then
			set_task_queue_as_nametag(self)
		end
		return
	end

	local activeMicroTask = activeMicroTaskEntry.data
	if not activeMicroTask.singlestep and activeMicroTask:is_finished(self) then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		if TASK_DEBUG then
			set_task_queue_as_nametag(self)
		end
		return
	end

	activeMicroTask:on_step(self, dtime)

	if activeMicroTask.singlestep then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		if TASK_DEBUG then
			set_task_queue_as_nametag(self)
		end
		return
	end

	if TASK_DEBUG then
		set_task_queue_as_nametag(self)
	end
end

rp_mobs.decide = function(self)
	if not self._decider then
		return
	end
	if self._tasks:isEmpty() then
		self:_decider()
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

function rp_mobs.mob_sound(self, sound, keep_pitch)
	local pitch
	if not keep_pitch then
		if self.child then
			pitch = 1.5
		else
			pitch = 1.0
		end
		pitch = pitch + 0.0025 * math.random(-10,10)
	end
	minetest.sound_play(sound, {
		pitch = pitch,
		object = self.object,
	}, true)
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
	-- DEBUG
	minetest.add_particle({
		pos = vector.round(pos),
		expirationtime = 0.4,
		size = 6,
		texture = "heart.png^[brighten",
	})
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	self._node_damage_timer = self._node_damage_timer + dtime
	if self._node_damage_timer >= NODE_DAMAGE_TIME then
		if def and def.damage_per_second and def.damage_per_second > 0 then
			local hp = math.max(0, self.object:get_hp() - def.damage_per_second)
			self.object:set_hp(hp, { type = "node_damage" })
			if hp <= 0 then
				self._dying = true
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
				local hp = math.max(0, self.object:get_hp() - def.drowning)
				self.object:set_hp(hp, { type = "drown" })
				if hp <= 0 then
					self._dying = true
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

function rp_mobs.handle_environment_damage(self, dtime)
	rp_mobs.handle_node_damage(self, dtime)
	rp_mobs.handle_drowning(self, dtime)
end

-- Entity variables to persist:
rp_mobs.add_persisted_entity_vars({
	"_get_node_damage",	-- true when mob can take damage from nodes (damage_per_second)
	"_can_drown",		-- true when mob has breath and can drown in nodes with `drowning` attribute
	"_drowning_point",	-- The position offset that will be checked when doing the drowning check
	"_breath_max",		-- Maximum breath
	"_breath",		-- Current breath
})


