-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

-- If true, will write the task queues of mobs as their nametag
local TASK_DEBUG = true

-- Default gravity that affects the mobs
local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

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
	local str = "* Task: "..(task.label or "<UNNAMED>")
	local next_microtask = task.microTasks:iterator()
	local microtask = next_microtask()
	while microtask do
		str = str .. "\n** " .. microtask_to_string(microtask)
		microtask = next_microtask()
	end
	return str
end
local task_queue_to_string = function(task_queue)
	local str = ""
	local next_task = task_queue.tasks:iterator()
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
local set_task_queues_as_nametag = function(self)
	local str = ""
	local next_task_queue = self._task_queues:iterator()
	local task_queue = next_task_queue()
	local first = true
	local num = 1
	while task_queue do
		if not first then
			str = str .. "\n"
		end
		str = str .. "Task queue #" .. num .. ":\n"
		num = num + 1
		str = str .. task_queue_to_string(task_queue)
		task_queue = next_task_queue()
		first = false
	end
	self.object:set_properties({
		nametag = str,
	})
end

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true
	mdef.entity_definition._description = def.description
	mdef.entity_definition._is_animal = def.is_animal
	mdef.entity_definition._base_size = table.copy(def.entity_definition.visual_size or { x=1, y=1, z=1 })
	mdef.entity_definition._base_selbox = table.copy(def.entity_definition.selectionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false })
	mdef.entity_definition._base_colbox = table.copy(def.entity_definition.collisionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5})
	mdef.entity_definition._default_sounds = table.copy(def.default_sounds or {})
	mdef.entity_definition._animations = table.copy(def.animations or {})
	mdef.entity_definition._current_animation = nil
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
	rp_mobs.default_mob_sound(self, "death")
end

rp_mobs.on_punch_default = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if damage >= 1 then
		rp_mobs.default_mob_sound(self, "damage")
	else
		rp_mobs.default_mob_sound(self, "hit_no_damage")
	end
end

rp_mobs.damage = function(self, damage, reason, no_sound)
	if damage <= 0 then
		return false
	end
	local hp = self.object:get_hp()
	hp = math.max(0, hp - damage)
	self.object:set_hp(hp, reason)
	if hp <= 0 then
		if not no_sound then
			rp_mobs.mob_sound_default(self, "death")
		end
		self._dying = true
		return true
	else
		if not no_sound then
			rp_mobs.mob_sound_default(self, "damage")
		end
	end
	return false
end

rp_mobs.heal = function(self, heal, reason)
	local hp = self.object:get_hp()
	local hp_max = self.object:get_properties().hp_max
	hp = math.min(hp_max, hp + heal)
	self.object:set_hp(hp, reason)
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
	self._task_queues = rp_mobs.DoublyLinkedList()
	self._active_task_queue = nil
end

rp_mobs.create_task_queue = function(decider)
	return {
		tasks = rp_mobs.DoublyLinkedList(),
		decider = decider,
	}
end

rp_mobs.add_task_queue = function(self, task_queue)
	self._task_queues:append(task_queue)
end

rp_mobs.add_task_to_task_queue = function(task_queue, task)
	task_queue.tasks:append(task)
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
	if not self._task_queues then
		minetest.log("error", "[rp_mobs] rp_mobs.handle_tasks called before tasks were initialized!")
		return
	end
	if not rp_mobs.is_alive(self) then
		return
	end

	-- Trivial case: No task queues, nothing to do
	if self._task_queues:isEmpty() then
		return
	end

	-- Select next task queue
	if not self._active_task_queue_entry then
		self._active_task_queue_entry = self._task_queues:getFirst()
	else
		local nexxt = self._active_task_queue_entry.nextEntry
		if not nexxt then
			nexxt = self._task_queues:getFirst()
		end
		self._active_task_queue_entry = nexxt
	end
	if not self._active_task_queue_entry then
		return
	end

	local activeTaskQueue = self._active_task_queue_entry.data

	-- Run decider if active task queue is empty
	local activeTaskEntry
	if activeTaskQueue.tasks:isEmpty() then
		if activeTaskQueue.decider then
			activeTaskQueue:decider(self)
		end
	end
	activeTaskEntry = activeTaskQueue.tasks:getFirst()

	if not activeTaskEntry then
		-- No more microtasks: Set idle animation if it exists
		if self._animations and self._animations.idle then
			rp_mobs.set_animation(self, "idle")
		end
		if TASK_DEBUG then
			set_task_queues_as_nametag(self)
		end
		return
	end

	-- Handle current task of active task queue
	local activeTask = activeTaskEntry.data

	local activeMicroTaskEntry = activeTask.microTasks:getFirst()
	if not activeMicroTaskEntry then
		activeTaskQueue.tasks:remove(activeTaskEntry)
		if TASK_DEBUG then
			set_task_queues_as_nametag(self)
		end
		return
	end

	-- Remove microtask if completed
	local activeMicroTask = activeMicroTaskEntry.data
	if not activeMicroTask.singlestep and activeMicroTask:is_finished(self) then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		if TASK_DEBUG then
			set_task_queues_as_nametag(self)
		end
		return
	end

	-- Execute microtask

	-- Call on_start and set microtask animation before the first step
	if not activeMicroTask.has_started then
		if activeMicroTask.start_animation then
			rp_mobs.set_animation(self, activeMicroTask.start_animation)
		end
		if activeMicroTask.on_start then
			activeMicroTask:on_start(self)
		end
		activeMicroTask.has_started = true
	end

	-- on_step: The main microtask logic goes here
	activeMicroTask:on_step(self, dtime)

	-- If singlestep is set, finish microtask after its first and only step
	if activeMicroTask.singlestep then
		if activeMicroTask.on_end then
			activeMicroTask:on_end(self)
		end
		activeTask.microTasks:remove(activeMicroTaskEntry)
		if TASK_DEBUG then
			set_task_queues_as_nametag(self)
		end
		return
	end

	if TASK_DEBUG then
		set_task_queues_as_nametag(self)
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
		if self._child then
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

function rp_mobs.default_mob_sound(self, default_sound, keep_pitch)
	local sound = self._default_sounds[default_sound]
	if sound then
		rp_mobs.mob_sound(self, sound, keep_pitch)
	end
end

function rp_mobs.default_hurt_sound(self, keep_pitch)
	rp_mobs.default_mob_sound(self, "damage", keep_pitch)
end

function rp_mobs.set_animation(self, animation_name, animation_speed)
	local anim = self._animations[animation_name]
	if not anim then
		minetest.log("error", "[rp_mobs] set_animation for mob '"..tostring(self.name).."' called with unknown animation_name: "..tostring(animation_name))
		return
	end
	local anim_speed = animation_speed or anim.default_frame_speed
	if self._current_animation ~= animation_name then
		self._current_animation = animation_name
		self._current_animation_speed = anim_speed
		self.object:set_animation(anim.frame_range, anim_speed)
	elseif self._current_animation_speed ~= anim_speed then
		self.object:set_animation_frame_speed(anim_speed)
	end
end
