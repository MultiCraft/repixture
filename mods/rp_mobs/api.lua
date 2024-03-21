local S = minetest.get_translator("rp_mobs")

-- If true, will write the task queues of mobs as their nametag
local TASK_DEBUG = false
local STATE_DEBUG = false

-- Default gravity that affects the mobs
local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

-- If true, then only peaceful mobs may spawn
local setting_peaceful_only = minetest.settings:get_bool("only_peaceful_mobs", false)

-- Time it takes for a mob to die
local DYING_TIME = 2

-- Default texture modifier when mob takes damage
local DAMAGE_TEXTURE_MODIFIER = "^[colorize:#df2222:180"

rp_mobs.GRAVITY_VECTOR = vector.new(0, -GRAVITY, 0)

rp_mobs.internal.add_persisted_entity_vars({
	"_custom_state",	-- table to store mob-specific state variables
	"_dying",		-- true if mob is currently dying (for animation)
	"_dying_timer",		-- time since mob dying started
	"_killer_player_name",	-- if mob was killed by a player, this contains their name. Otherwise nil
	"_textures_adult",	-- persisted textures of mob in adult state
	"_textures_child",	-- persisted textures of mob in child state
})

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
local mob_task_queues_to_string = function(mob)
	local str = ""
	local next_task_queue = mob._task_queues:iterator()
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
	return str
end
local mob_state_to_string = function(mob)
	local str = "Mob state:\n"
	str = str .. "* HP = "..mob.object:get_hp().."\n"
	local pevars = rp_mobs.internal.get_persisted_entity_vars()
	for p=1, #pevars do
		local var = pevars[p]
		local val = mob[var]
		local sval
		if type(val) == "number" then
			sval = string.format("%.1f", val)
		else
			sval = tostring(val)
		end
		str = str .. var .." = "..sval.."\n"
	end
	return str
end
local set_debug_nametag = function(mob)
	local str = ""
	if STATE_DEBUG then
		str = str .. mob_state_to_string(mob)
	end
	if TASK_DEBUG and not mob._dying then
		if STATE_DEBUG then
			str = str .. "\n"
		end
		str = str .. mob_task_queues_to_string(mob)
	end
	mob.object:set_properties({
		nametag = str,
	})
end

-- on_die callback function support
local registered_on_dies = {}
local trigger_on_die = function(mob, killer)
	local mobdef = rp_mobs.registered_mobs[mob.name]
	if not mobdef then
		error("[rp_mobs] trigger_on_die was called on something that is not a registered mob! name="..tostring(self.name))
	end
	for f=1, #registered_on_dies do
		local func = registered_on_dies[f]
		func(mob, killer)
	end
end

rp_mobs.register_on_die = function(callback)
	table.insert(registered_on_dies, callback)
end

-- Register mob

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	local initprop
	if def.entity_definition and def.entity_definition.initial_properties then
		initprop = def.entity_definition.initial_properties
	else
		initprop = {}
	end
	if not initprop.damage_texture_modifier then
		initprop.damage_texture_modifier = DAMAGE_TEXTURE_MODIFIER
	end
	mdef.entity_definition.initial_properties = initprop
	mdef.entity_definition._cmi_is_mob = true
	mdef.entity_definition._description = def.description
	mdef.entity_definition._tags = table.copy(def.tags or {})
	mdef.entity_definition._base_size = table.copy(initprop.visual_size or { x=1, y=1, z=1 })
	mdef.entity_definition._base_selbox = table.copy(initprop.selectionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false })
	mdef.entity_definition._base_colbox = table.copy(initprop.collisionbox or { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5})
	mdef.entity_definition._default_sounds = table.copy(def.default_sounds or {})
	mdef.entity_definition._animations = table.copy(def.animations or {})
	mdef.entity_definition._current_animation = nil
	mdef.entity_definition._dying = false
	mdef.entity_definition._dying_timer = 0
	if def.textures_child then
		mdef.entity_definition._textures_child = def.textures_child
	end
	mdef.entity_definition._textures_adult = initprop.textures
	if def.front_body_point then
		mdef.entity_definition._front_body_point = table.copy(def.front_body_point)
	end
	mdef.entity_definition._dead_y_offset = def.dead_y_offset

	rp_mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

rp_mobs.get_staticdata_default = function(self)
	local staticdata_table = {}
	local pevars = rp_mobs.internal.get_persisted_entity_vars()
	for p=1, #pevars do
		local pvar = pevars[p]
		local pvalue = self[pvar]
		staticdata_table[pvar] = pvalue
	end
	local staticdata = minetest.serialize(staticdata_table)
	return staticdata
end

rp_mobs.has_tag = function(mob, tag_name)
	return mob._tags[tag_name] == 1
end

rp_mobs.mobdef_has_tag = function(mobname, tag_name)
	local mobdef = rp_mobs.registered_mobs[mobname]
	if not mobdef or not mobdef.entity_definition or not mobdef.entity_definition._tags then
		return false
	end
	return mobdef.entity_definition._tags[tag_name] == 1
end

local flip_over_collisionbox = function(box, is_child, y_offset)
	local off
	if is_child then
		off = y_offset / 2
	else
		off = y_offset
	end
	-- Y
	box[2] = box[2] + off
	box[5] = box[2] + (box[6] - box[3])
	return box
end

local get_dying_boxes = function(mob)
	local props = mob.object:get_properties()
	local colbox = props.collisionbox
	if not mob._dead_y_offset then
		minetest.log("warning", "[rp_mobs_mobs] No dead_y_offset specified for mob '"..mob.name.."'!")
	end
	colbox = flip_over_collisionbox(colbox, mob._child, mob._dead_y_offset or 0)
	local selbox = props.selectionbox
	return colbox, selbox
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

	if self._child then
		rp_mobs.set_mob_child_properties(self)
	end
	if self._dying then
		local colbox, selbox = get_dying_boxes(self)
		self.object:set_properties({
			collisionbox = colbox,
			selectionbox = selbox,
			damage_texture_modifier = "",
			makes_footstep_sound = false,
		})
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

local get_drops = function(droptable)
	local to_drop = {}
	for d=1, #droptable do
		local drop = droptable[d]
		if type(drop) == "string" then
			table.insert(to_drop, drop)
		elseif type(drop) == "table" then
			local rnd = math.random(1, drop.chance)
			if rnd == 1 then
				local count = math.random(drop.min, drop.max)
				if count > 0 then
					drop = drop.name .. " "..count
					table.insert(to_drop, drop)
				end
			end
		else
			minetest.log("error", "[rp_mobs] Invalid drop in mob drop table: "..tostring(drop))
		end
	end
	return to_drop
end

rp_mobs.spawn_mob_drop = function(pos, item)
	local obj = minetest.add_item(pos, item)
	if obj then
		obj:set_velocity({
			x = math.random(-100, 100)/100,
			y = 5,
			z = math.random(-100, 100)/100
		})
	end
	return obj
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
		local drops = get_drops(mobdef.drops)
		for d=1, #drops do
			rp_mobs.spawn_mob_drop(pos, drops[d])
		end
	end
	if self._child and mobdef.child_drops then
		local drops = get_drops(mobdef.child_drops)
		for d=1, #drops do
			rp_mobs.spawn_mob_drop(pos, drops[d])
		end
	end
	if mobdef.drop_func then
		local drop_func_drops = mobdef.drop_func(self)
		for d=1, #drop_func_drops do
			rp_mobs.spawn_mob_drop(pos, drop_func_drops[d])
		end
	end
end

local get_mob_death_particle_radius = function(self)
	local colbox = self._base_colbox
	local x,y,z
	x = colbox[4]-colbox[1]
	y = colbox[5]-colbox[2]
	z = colbox[6]-colbox[3]
	local radius = x
	if y > radius then
		radius = y
	end
	if z > radius then
		radius = z
	end
	return radius
end

rp_mobs.on_death_default = function(self, killer)
	local radius = get_mob_death_particle_radius(self)
	local pos = self.object:get_pos()
	minetest.add_particlespawner({
		amount = 16,
		time = 0.02,
		pos = {
			min = vector.subtract(pos, radius / 2),
			max = vector.add(pos, radius / 2),
		},
		vel = {
			min = vector.new(-1, 0, -1),
			max = vector.new(1, 2, 1),
		},
		acc = vector.zero(),
		exptime = { min = 0.4, max = 0.8 },
		size = { min = 8, max = 12 },
		drag = vector.new(1,1,1),
		-- TODO: Move particle to particle mod
		texture = {
			name = "rp_mobs_death_smoke_anim_1.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
			name = "rp_mobs_death_smoke_anim_2.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
			name = "rp_mobs_death_smoke_anim_1.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
			name = "rp_mobs_death_smoke_anim_2.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
		},
	})
	minetest.sound_play({name="rp_sounds_disappear", gain=0.4}, {pos=pos, max_hear_distance=12}, true)
	rp_mobs.drop_death_items(self)
end

rp_mobs.on_punch_default = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if self._dying then
		return true
	end
	if not damage then
		return
	end
	if self.object:get_hp() - damage <= 0 then
		-- This punch kills the mob
		rp_mobs.die(self, puncher)
		return true
	end
	-- Play default punch/damage sound
	if damage >= 1 then
		rp_mobs.default_mob_sound(self, "damage")
	else
		rp_mobs.default_mob_sound(self, "punch_no_damage")
	end
end

rp_mobs.damage = function(self, damage, no_sound, damager)
	if damage <= 0 or self._dying then
		return false
	end
	local hp = self.object:get_hp()
	hp = math.max(0, hp - damage)
	if hp <= 0 then
		rp_mobs.die(self, damager)
		return true
	else
		self.object:set_hp(hp)
		if not no_sound then
			rp_mobs.default_mob_sound(self, "damage")
		end
	end
	return false
end

rp_mobs.heal = function(self, heal)
	if heal <= 0 then
		return false
	end
	if not rp_mobs.is_alive(self) then
		return false
	end
	local hp = self.object:get_hp()
	local hp_max = self.object:get_properties().hp_max
	hp = math.min(hp_max, hp + heal)
	self.object:set_hp(hp)
	return true
end

rp_mobs.init_tasks = function(self)
	self._task_queues = rp_mobs.DoublyLinkedList()
	self._active_task_queue = nil
end

rp_mobs.init_mob = function(self)
	if setting_peaceful_only and not rp_mobs.has_tag(self, "peaceful") then
		self.object:remove()
		minetest.log("action", "[mobs] Hostile mob '"..self.name.."' removed at "..minetest.pos_to_string(self.object:get_pos(), 1).." (only peaceful mobs allowed)")
		return
	end
end

rp_mobs.create_task_queue = function(empty_decider, step_decider)
	return {
		tasks = rp_mobs.DoublyLinkedList(),
		empty_decider = empty_decider,
		step_decider = step_decider,
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

rp_mobs.end_current_task_in_task_queue = function(mob, task_queue)
	local first = task_queue.tasks:getFirst()
	if first then
		task_queue.tasks:remove(first)
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

rp_mobs.handle_tasks = function(self, dtime, moveresult)
	if not self._task_queues then
		minetest.log("error", "[rp_mobs] rp_mobs.handle_tasks called before tasks were initialized!")
		return
	end
	if not rp_mobs.is_alive(self) then
		if TASK_DEBUG or STATE_DEBUG then
			set_debug_nametag(self)
		end
		return
	end

	-- Trivial case: No task queues, nothing to do
	if self._task_queues:isEmpty() then
		return
	end

	local active_task_queue_entry = self._task_queues:getFirst()
	while active_task_queue_entry do

		local task_queue_done = false

		local activeTaskQueue = active_task_queue_entry.data

		-- Run empty decider if active task queue is empty
		local activeTaskEntry
		if activeTaskQueue.tasks:isEmpty() then
			if activeTaskQueue.empty_decider then
				activeTaskQueue:empty_decider(self)
			end
		end

		-- Run step decider
		if activeTaskQueue.step_decider then
			activeTaskQueue:step_decider(self, dtime)
		end

		activeTaskEntry = activeTaskQueue.tasks:getFirst()

		if not activeTaskEntry then
			-- No more microtasks: Set idle animation if it exists
			if self._animations and self._animations.idle then
				rp_mobs.set_animation(self, "idle")
			end
			task_queue_done = true
		end

		-- Handle current task of active task queue
		local activeTask
		if activeTaskEntry then
			activeTask = activeTaskEntry.data
		end
		local activeMicroTaskEntry

		if not task_queue_done then
			activeMicroTaskEntry = activeTask.microTasks:getFirst()
			if not activeMicroTaskEntry then
				activeTaskQueue.tasks:remove(activeTaskEntry)
				if TASK_DEBUG or STATE_DEBUG then
					set_debug_nametag(self)
				end
				task_queue_done = true
			end
		end

		-- Remove microtask if completed
		local activeMicroTask
		if not task_queue_done then
			activeMicroTask = activeMicroTaskEntry.data
			if not activeMicroTask.has_started and activeMicroTask.on_start then
				activeMicroTask:on_start(self)
			end
			if not activeMicroTask.singlestep and activeMicroTask:is_finished(self) then
				if activeMicroTask.on_end then
					activeMicroTask:on_end(self)
				end
				activeTask.microTasks:remove(activeMicroTaskEntry)
				task_queue_done = true
			end
		end

		-- Execute microtask

		-- Set microtask animation before the first step
		if not task_queue_done and not activeMicroTask.has_started then
			if activeMicroTask.start_animation then
				rp_mobs.set_animation(self, activeMicroTask.start_animation)
			end
			activeMicroTask.has_started = true
		end

		-- on_step: The main microtask logic goes here
		if not task_queue_done then
			activeMicroTask:on_step(self, dtime, moveresult)
		end

		-- If singlestep is set, finish microtask after its first and only step
		if not task_queue_done and activeMicroTask.singlestep then
			if activeMicroTask.on_end then
				activeMicroTask:on_end(self)
			end
			activeTask.microTasks:remove(activeMicroTaskEntry)
			task_queue_done = true
		end

		-- Select next task queue
		local nexxt = active_task_queue_entry.nextEntry
		active_task_queue_entry = nexxt
		if not active_task_queue_entry then
			break
		end
	end

	if TASK_DEBUG or STATE_DEBUG then
		set_debug_nametag(self)
	end
end

rp_mobs.die = function(self, killer)
	if not rp_mobs.is_alive(self) then
		return
	end

	trigger_on_die(self, killer)

	if killer and killer:is_player() and not self._killer_player_name then
		self._killer_player_name = killer:get_player_name()
	end

	-- Set HP to 1 and _dying to true.
	-- This indicates the mob is currently dying.
	-- We can't set HP to 0 yet because that would insta-remove
	-- the mob (and thus skip the 'dying' delay and animation)
	self.object:set_hp(1)
	self._dying = true
	self._dying_timer = 0

	rp_mobs.default_mob_sound(self, "death")
	rp_mobs.set_animation(self, "dead_static")

	local colbox, selbox = get_dying_boxes(self)
	if self._dead_y_offset and self._dead_y_offset < 0 then
		local repos = self.object:get_pos()
		local y = math.abs(self._dead_y_offset)
		repos = vector.offset(repos, 0, y, 0)
		self.object:set_pos(repos)
	end
	self.object:set_properties({
		collisionbox = colbox,
		selectionbox = selbox,
		damage_texture_modifier = "",
		makes_footstep_sound = false,
	})

	-- Set roll
	local roll = math.pi/2
	local rot = self.object:get_rotation()
	rot.z = roll
	self.object:set_rotation(rot)
end

rp_mobs.handle_dying = function(self, dtime)
	if rp_mobs.is_alive(self) then
		return
	end

	-- Make mob come to a halt
	local realvel = self.object:get_velocity()
	local targetvel = vector.zero()
	targetvel.y = realvel.y
	local drag = vector.new(0.05, 0, 0.05)
	local MOVE_SPEED_MAX_DIFFERENCE = 0.01
	for _, axis in pairs({"x","z"}) do
		if math.abs(realvel[axis]) > MOVE_SPEED_MAX_DIFFERENCE then
			if realvel[axis] > targetvel[axis] then
				targetvel[axis] = math.max(0, realvel[axis] - drag[axis])
			else
				targetvel[axis] = math.min(0, realvel[axis] + drag[axis])
			end
		end
	end

	self.object:set_velocity(targetvel)

	-- Trigger final death when timer runs out
	self._dying_timer = self._dying_timer + dtime
	if self._dying_timer >= DYING_TIME then
		self.object:set_hp(0)
	end
end

rp_mobs.register_mob_item = function(mobname, invimg, desc, on_create_capture_item)
	local place
	if not desc then
		desc = rp_mobs.registered_mobs[mobname].description
	end
	local entdef = minetest.registered_entities[mobname]
	if not entdef then
		minetest.log("error", "[rp_mobs] rp_mobs.register_mob_item was called for mob '"..mobname.."' but it doesn't exist!")
		return
	end
	minetest.register_craftitem(mobname, {
		description = desc,
		inventory_image = invimg,
		groups = { spawn_egg = 1 },
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			if setting_peaceful_only and not rp_mobs.mobdef_has_tag(mobname, "peaceful") then
				if placer and placer:is_player() then
					local pname = placer:get_player_name()
					minetest.chat_send_player(pname, minetest.colorize("#FFFF00", S("Hostile mobs are disabled!")))
				end
				return itemstack
			end
			local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
			if handled then
				return handled_itemstack
			end
			if pointed_thing.type == "node" then
				local pos = pointed_thing.above
				local pname = placer:get_player_name()
				-- Can't violate protection
				if minetest.is_protected(pos, pname) and
						not minetest.check_player_privs(placer, "protection_bypass") then
					 minetest.record_protection_violation(pos, pname)
					 return itemstack
				end

				-- Can't place into solid or unknown node
				local pnode = minetest.get_node(pos)
				local pdef = minetest.registered_nodes[pnode.name]
				if not pdef or pdef.walkable then
					rp_sounds.play_place_failed_sound(placer)
					return itemstack
				end

				-- Get HP and staticdata from metadata
				local imeta = itemstack:get_meta()
				local hp = imeta:get_int("hp")
				local staticdata = imeta:get_string("staticdata")

				-- Spawn mob
				pos.y = pos.y + 0.5
				local mob = minetest.add_entity(pos, mobname, staticdata)
				local ent = mob:get_luaentity()
				if hp > 0 then
					mob:set_hp(hp)
				end

				-- Finalize
				minetest.log("action", "[rp_mobs] "..pname.." spawns "..mobname.." at "..minetest.pos_to_string(pos, 1))
				if not minetest.is_creative_enabled(pname) then
					 itemstack:take_item()
				end
			end
			return itemstack
		end,
		_on_create_capture_item = on_create_capture_item,
	})
end

rp_mobs.mob_sound = function(self, sound, keep_pitch)
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

rp_mobs.default_mob_sound = function(self, default_sound, keep_pitch)
	local sound = self._default_sounds[default_sound]
	if sound then
		rp_mobs.mob_sound(self, sound, keep_pitch)
	end
end

rp_mobs.default_hurt_sound = function(self, keep_pitch)
	rp_mobs.default_mob_sound(self, "damage", keep_pitch)
end

rp_mobs.set_animation = function(self, animation_name, animation_speed)
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

