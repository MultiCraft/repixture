# Repixture Mobs API

NOTE: This API is EXPERIMENTAL and subject to change! Use at your own risk.

## Core concepts

### Mobs

In this mod, a "mob" refers a non-player entity with added capabilities like physics and a task queue. Mobs can be used to implement things like animals or monsters.

### Tasks, microtasks and the task queue

The heart of this mod are tasks. A task is a single defined goal that a mob has to achieve in some manner. Every task can either succeed or fail. Tasks are organized in a task queue. Normally, mobs try to complete tasks in the order they appear in the queue. Tasks include high-level goals such as "find and eat food", "flee from the player", "kill the player", "roam randomly", etc.

Additionally, every task consists of a number of microtasks. These are intended for more low-level and simple activities such as "go to point XYZ", "jump", "attack in direction A".

To use tasks, they must be initialized by calling `rp_mobs.init_tasks` in `on_activate` and be handled by calling `rp_mobs.handle_tasks` in `on_step`.

### Physics and movement

Physical forces and the mob's desired movements are separated. Physical forces like gravity always affect the mob, no matter where it actually wants to move (if at all). On top of physics, mobs have a desired movement.

So instead of setting the entity acceleration and velocity directly, you're supposed to set the physical forces and desired mob movements as vectors; this mod will then do the final calculation step for you.

To use the physics system, you must initialize it first by calling `rp_mobs.init_physics` in `on_activate` and then let this mob handle the physics for you in `rp_mobs_handle_physics` in `on_step`. You also must never call builtin functions `set_velocity` and `set_acceleration` directly; you only change vectors.

### Registering a mob
You add (register) a mob via `rp_mobs.register_mob`. Mob definitions in this API are very low-level and similar to typical entity definitions in Minetest. You still have to provide a full entity definition via `entity_definition` including the callback functions like `on_activate` and `on_rightclick`.

You're supposed to use the Repixture Mob API functionality by inserting the various helper functions into the callbacks like `on_step` and `on_activate` where appropriate.

You can use the following template:

	rp_mobs.register_mob("MOBNAME", {
		description = "MOB DESCRIPTION",
		drops = { ADD_YOUR_DROPS_HERE },
		entity_definition = {
			-- Add 
			on_activate = function(self)
				rp_mobs.init_physics(self)
				rp_mobs.init_tasks(self)
			end,
			on_step = function(self, dtime)
				rp_mobs.handle_physics(self)
				rp_mobs.handle_tasks(self)
			end,
			on_death = rp_mobs.on_death_default,
		},
	})

## Data structures

This section defines the data structures used in the functions below.

### Task

A task is just a table. You can optionally define this field:

* `label`: Brief string explaining what the task does. Only for debug

The task's microtasks are stored internally. Use `rp_mobs.add_microtask_to_task` to add a new one.

### Microtask

A microtask is a table with the following fields:

* `label`: Same as for tasks
* `on_step`: Called every step of the mob. Handle the microtask behavior here
* `on_finished`: Return true if the microtask is complete, false otherwise
* `on_end`: Called when the task has ended. Useful for cleaning up state
* `singlestep`: If true, this microtask will run for only 1 step and automatically succeeds (default: false)

Every microtask needs to have `on_step` and either `on_finished` or `singlestep = true`.
The `on_*` functions have parameters `self, mob` with self being a reference to the
microtask table itself and `mob` being the mob object that is affected.

## Function reference

### `rp_mobs.register_mob(mobname, def)`

Register a mob with the entity identifier `mobname` and definition `def`.
The mob definition will be stored under `rp_mobs.registered_mobs[mobname]`.
The field `_cmi_is_mob=true` will be set automatically for all mobs and can be used to check whether any given entity is a mob.

`def` is a definition table with the following optional fields:

* `description`: Short mob name used for display purposes
* `drops`: Table of itemstrings to be dropped when the mob dies
* `entity_definition`: Entity definition table

### `rp_mobs.drop_death_items(mob, pos)`

Make mob `mob` drop its death items at pos.

### `rp_mobs.init_physics(mob)`

Initialize and enable the mob physics system for mob `mob`.
This is supposed to go into `on_activate` of the entity definition.
This function **must** be called before any other physics-related function.

### `rp_mobs.handle_physics(mob)`

Update the mob physics for a single mob step. Required for the mob physics to work.
This is supposed to go into `on_step` of the entity definition. It must be called every step.

### `rp_mobs.activate_gravity(mob)`

Activate gravity for mob.

### `rp_mobs.deactivate_gravity(mob)`

Deactivate gravity for mob.

### `rp_mobs.init_tasts(mob)`

Initialize the task and microtask queues for the mob.
This is supposed to go into `on_activate` of the entity definition.
This function **must** be called before any other task-related function is called.

### `rp_mobs.handle_tasks(mob)`

Handle the tasks, microtasks and the task queue of the mob for a single step. Required for the task system to work.
This is supposed to go into `on_step` of the entity definition. It must be called every step.

### `rp_mobs.add_task(mob, task)`

Add a task `task` to the mob's task queue.

### `rp_mobs.add_microtask_to_task(mob, microtask, task)`

Add the microtask `microtask` to the specified `task`.

### `rp_mobs.register_mob_item(mobname, invimg, desc)`

Registers an item representing a mob. It can be used by players to spawn
the mob by placing it. This item is also used when a mob is captured.

* `mobname`: Mob identifier
* `invimg`: Inventory image texture
* `desc`: Description for inventory

### `rp_mobs.on_death_default(mob, killer)`

The default handler for `on_death` of the mob's entity definition.
It must be set explicitly for every mob, unless you want to have a custom death handling.
Currently, the default death handler just drops the mob death items.

Set `on_death = rp_mobs.on_death_default` to use the default death behavior.

## Default callback handlers

* `on_death`: `rp_mobs.on_death_default`
