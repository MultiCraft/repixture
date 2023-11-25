# Repixture Mobs API

NOTE: This API is EXPERIMENTAL and subject to change! Use at your own risk.

## Core concepts

### Mobs

In this mod, a "mob" refers a non-player entity with added capabilities like physics and a task queue. Mobs can be used to implement things like animals or monsters.

### Tasks, microtasks and task queues

The heart of this mod are tasks. A task is a single defined goal that a mob has to achieve in some manner. Every task can either succeed or fail. Tasks include high-level goals such as "find and eat food", "flee from the player", "kill the player", "roam randomly", etc.

Additionally, every task consists of a number of microtasks. These are intended for more low-level and simple activities such as "go to point XYZ", "jump", "attack in direction A".

To use tasks, they must be initialized by calling `rp_mobs.init_tasks` in `on_activate` and be handled (i.e. executed) every step by calling `rp_mobs.handle_tasks` in `on_step`.

Finally, task queues organize the execution of tasks. A task queue is a sequence of tasks that get executed in order. Tasks get automatically removed from the queue once finished. Task queues also optionally have a `decider` function which is called every time the task queue is empty.

A mob can have any number of task queues active at a time. While tasks and microtasks are executed sequentially, task queues run in parrallel.

Task queues, tasks and microtask form a tree-like structure, like so:

    Task queue 1
    |
    `- Task 1
       |
       `- Microtask 1
       `- Microtask 2
    |
    `- Task 2
       `- Microtask 1
       `- Microtask 2

So on the top level, you have task queues, which consist of tasks, which in turn consist of microtasks.

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
			on_activate = function(self)
				rp_mobs.init_physics(self)
				rp_mobs.init_tasks(self)
			end,
			on_step = function(self, dtime)
				rp_mobs.handle_physics(self)
				rp_mobs.handle_tasks(self, dtime)
				rp_mobs.decide(self)
			end,
			on_death = rp_mobs.on_death_default,
		},
	})

## Data structures

This section defines the data structures used in the functions below.

### Task

A task is just a table. You can optionally define this field:

* `label`: Brief string explaining what the task does. Only for debug

Tasks can be created with `rp_mobs.create_task`.

The task's microtasks are stored internally. Use `rp_mobs.add_microtask_to_task`
to add a microtask to a task.

### Microtask

A microtask is a table with the following fields:

* `label`: Same as for tasks
* `on_step`: Called every step of the mob. Handle the microtask behavior here
* `on_finished`: Return true if the microtask is complete, false otherwise
* `on_end`: Called when the microtask has ended. Useful for cleaning up state
* `on_start`: Called when the microtask has begun. Called just before `on_step`
* `singlestep`: If true, this microtask will run for only 1 step and automatically succeeds (default: false)
* `statedata`: Table containing data that can be modified and read at runtime

Every microtask needs to have `on_step` and either `on_finished` or `singlestep = true`.
All other fields are optional. It is not allowed to add any fields not listed above.

`on_finished`, `on_end` and `on_start` have parameters `self, mob` with `self` being
a reference to the microtask table itself and `mob` being the mob object that is affected.

`on_step` has the parameters `self, mob, dtime`, where `dtime` is the time in seconds
that have passed since it was last called, or 0 on the firt call (like for the entity
`on_step` function).

The `statedata` field can be used to associate arbitrary data with the microtask in
order to preserve some state. You may read and write to it in functions
like `on_step`.

Microtasks can be created with `rp_mobs.create_microtask`.

## Optional common functionality

This mod is designed to hardcode as little into mobs as possible. However, there are still a lot
of utility functions that implement basic mob functionality that most, if not all mobs
should have and they can used by mobs to share the same code.

Nearly every behavior needs to be used *explicity*, however. So there is no node damage
by default, no drowning by default, etc. This section explains the common functionality.

### Node damage

Node damage enables the mob being vulnerable to nodes with the `damage_per_second` field.
If you want your mob to use this, add `rp_mobs.init_node_damage` to `on_activate`
and `rp_mobs.handle_node_damage` to `on_step`. Read the documentation of these
functions to learn more about how the node damage mechanic works.

Node damage can be temporarily disabled during the mob’s lifetime by setting the
entity field `_get_node_damage` to false.

### Fall damage

Fall damage hurts the mob when it hits the ground too hard.
The fall damage calculation works differently than for players (see
`rp_mobs.handle_fall_damage` for details.

To enable fall damage , add `rp_mobs.init_fall_damage` in `on_activate` and
`rp_mobs.handle_fall_damage` in `on_step`.

### Breath / drowning

Drowning makes mobs take drowning damage when inside a particular node.

If you want your mob to use this, add `rp_mobs.init_breath` to `on_activate`
and `rp_mobs.handle_drowning` in `on_step`. Read the documentation of these
functions to learn more about the drowning mechanic in general.

The drowning status can also be changed during the mob’s lifetime in `on_step`
by manipulating the drowning fields (see the mob field reference).

### Breeding

Breeding will make mobs mate and create offspring. To enable, add
`rp_mobs.handle_breeding` in `on_step`.

In particular, to breed, two adult mobs of the same type need to be “horny” and close
to each other. Then, a random mob of the pair gets pregnant and will soon
spawn a child mob. The child mob will grow to an adult after some time.

There are two ways to make a mob horny:

1. Call `rp_mobs.feed_tame_breed` in `on_rightclick` (i.e. player gives mob enough food)
2. Call `rp_mobs.make_horny` to instantly make the mob horny

Only adults should be horny.


## Mob field reference

Mob entities use a bunch of custom fields. You may read and edit them at runtime.
These fields are available:

### Status

* `_cmi_is_mob`: Always `true`. Indicates the entity is a mob. Do not touch
* `_dying`: Is `true` when mob is currently dying and about to be removed
* `_tamed`: `true` if mob is tame
* `_tb_level`: tame/breed level. Starts at 0 and increases for any food given, used to trigger taming/breeding
* `_child`: `true` if mob is a child
* `_horny`: `true` if mob is “horny”. If another horny mob is nearby, they will mate and spawn a child
* `_pregnant`: `true` if mob is pregnant and about to spawn a child

### Damage

* `_get_node_damage`: `true` when mob can take damage from nodes (`damage_per_second`) (default: false)
* `_get_fall_damage`: `true` when mob can take fall damage (default: false)
* `_can_drown`: `true` when mob has breath and can drown in nodes with `drowning` attribute (default: false)
* `_drowning_point`: See `rp_mobs.init_breath`.
* `_breath_max`: Maximum breath (ignored if `_can_drown` isn’t true)
* `_breath`: Current breath (ignored if `_can_drown` isn’t true)

Please note:
You *must* call `rp_mobs.init_node_damage` before you touch the `_get_node_damage` field.
You *must* call `rp_mobs.init_breath` before you touch the breath/drowning fields.

### Internal use

A bunch of fields are meant for internal use by `rp_mobs`. Do not change them.

* `_child_grow_timer`: time the mob has been a child (seconds)
* `_horny_timer`: time the mob has been horny (seconds)
* `_breed_check_timer`: timer for the breed check (seconds)
* `_pregnant_timer`: time the mob has been pregnant (seconds)
* `_last_feeder`: Name of the last player who fed the mob

## Function reference

### `rp_mobs.register_mob(mobname, def)`

Register a mob with the entity identifier `mobname` and definition `def`.
The mob definition will be stored under `rp_mobs.registered_mobs[mobname]`.
The field `_cmi_is_mob=true` will be set automatically for all mobs and can be used to check whether any given entity is a mob.

`def` is a definition table with the following optional fields:

* `description`: Short mob name used for display purposes
* `drops`: Table of itemstrings to be dropped when the mob dies as an adult (default: empty table)
* `child_drops`: Table of itemstrings to be dropped when the mob dies as a child (default: empty table)
* `default_sounds`: Table of default sound names to play automatically on built-in events. Sounds will be played by `rp_mobs.default_mob_sound`
    * `death`: When mob dies
    * `damage`: When mob takes damage
    * `eat`: When mob eats (not yet implemented)
* `entity_definition`: Entity definition table. It may contain this custom fucntion:
    * `_on_capture(self, capturer)`: Called when a mob capture is attempted by capturer (a player).
                                     Triggered by `rp_mobs.handle_capture`

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

### `rp_mobs.create_task_queue(decider)`

Create a task queue object and returns it. `decider` is an
optional function with signature `decider(task_queue, mob)` that is
called whenever the task queue is empty.
In this function you can update the task queue by adding new
tasks to it. Avoid complex and slow algorithms here!

### `rp_mobs.add_task_to_task_queue(task, task_queue)`

Add a task `task` to the given task queue object.

### `rp_mobs.add_task_queue(mob, task_queue)`

Add a task queue to the given mob.

### `rp_mobs.create_task(def)`

Create a task according to the specified `def` table. See the data structure above for the possible table fields.

Returns the task.

### `rp_mobs.create_microtask(def)`

Create a microtask according to the specified `def` table. See the data structure above for the possible table fields.
The `statedata` field will always be initialized as an empty table.

Returns the microtask.

Note this only creates it in memory. To actually execute it, you have to add
it to a task with `rp_mobs.add_microtask_to_task` and then execute
the task.


### `rp_mobs.add_microtask_to_task(mob, microtask, task)`

Add the microtask `microtask` to the specified `task`.

### `rp_mobs.handle_tasks(mob)`

Handle the task queues, tasks, microtasks of the mob for a single step. Required for the task system to work.
This is supposed to go into `on_step` of the entity definition. It must be called every step.

### `rp_mobs.register_mob_item(mobname, invimg, desc)`

Registers an item representing a mob. It can be used by players to spawn
the mob by placing it. This item is also used when a mob is captured.

* `mobname`: Mob identifier
* `invimg`: Inventory image texture
* `desc`: Description for inventory

### `rp_mobs.init_breath(mob, can_drown, def)`

Initializes the breath and drowning mechanic for the given mob.
If you want the mob to have this, put this into `on_activate`.

If this is the first time the function is called, drowning and
associated entity fields will be initialized. On subsequent calls,
this function does nothing because the fields are already
initialized.

* `self`: The mob
* `can_drown`: If `true`, drowning is possible, otherwise, it is not.
* `def`: A table with the following fields:
	* `breath_max`: Maximum (and initial) breath points. Positive number
	* `drowning_point`: Optional position offset vector that will be checked when doing
		the drowning check. It’s an offset from the mob position (`get_pos()`). If the
		node at the drowning point is a drowning node, the mob can drown.
		Default: no offset

### `rp_mobs.init_node_damage(self, get_node_damage)`

Initializes the node damage mechanic for the given mob,
activating damage from nodes with `damage_per_second`.
If you want the mob to have this, put this into `on_activate`.

If this is the first time the function is called, the
associated entity fields will be initialized. On subsequent
calls, this function does nothing because the fields are already
initialized.

Parameters:

* `self`: The mob
* `get_node_damage`: If `true`, mob will receive damage from nodes

### `rp_mobs.init_fall_damage(self, get_fall_damage)`

Initializes the fall damage for the given mob,
If you want the mob to have this, put this into `on_activate`.

If this is the first time the function is called, the
associated entity fields will be initialized. On subsequent
calls, this function does nothing because the fields are already
initialized.

Parameters:

* `self`: The mob
* `get_fall_damage`: If `true`, mob will receive fall damage

### `rp_mobs.attempt_capture = function(mob, capturer, capture_chances, force_take, replace_with)`

Attempt to capture mob by capturer (a player). This requires a mob to have a mob available as
an item (see `rp_mobs.register_mob_items`), unless `replace_with` is set.

It is recommended to put this function in the `_on_capture` field of the mob’s entity definition.

A mob capture may or may not succeed. A mob capture succeeds if all of these are true:

1. The wielded item is in `capture_chances`
2. The random capture chance succeeds
3. The mob is tamed _or_ `force_take` is `true`

If successful, `capturer` will get the mob in item form and it will wear out the wielded tool
(exception: no wear in Creative Mode). `capturer` might receive a message.

Parameters:

* `mob`: The mob to capture
* `capturer`: Player trying to capture
* `capture_changes`: Table defining which items can capture and their chance to capture:
    * key: itemname, e.g. `"rp_mobs:net"`
    * value: capture chance, specified as `1/value`. e.g. value 5 is a 1/5 chance.
* `force_take`: (optional) If `true`, can capture non-tamed mob
* `replace_with`: (optional) Give this item instead of the registered mob item.
                  If `nil` (default), gives the registered mob item.

### `rp_mobs.handle_capture(mob, capture)`

Handle the mob’s capturing logic. This will call the `_on_capture` function of the mob’s
entity definition. This function *must* exist.

It is recommended to put this into `on_rightclick`, if you want this mob to be capturable.

### `rp_mobs.handle_node_damage(mob, dtime)`

Handles node damage for the mob if the entity
field `_get_node_damage` is `true`. Node damage is taken
in nodes with a non-zero `damage_per_second`.

In the current implementation, only the mob position is checked,
other nodes are ignored. This behavior may change in the future.

Checks if the mob is standing in a damaging node and if yes, damage it.
Otherwise, no damage will be taken.

Must be called in the `on_step` function in every step.
`dtime` is the `dtime` argument of `on_step`.

### `rp_mobs.handle_fall_damage(mob, dtime, moveresult)`

Handles fall damage for the mob if the entity field
`_get_fall_damage` is `true`.

Fall damage is calculated differently than for
players and there is no guarante the calculation
algorithm will be forwards-compatible. It increases
linearly with the fall height. Fall damage is further-
more modified by the `add_fall_damage_percent` group
if falling on a node. Adding the armor group
`add_fall_damage_percent` will also modify the
fall damage the mob will receive (like for players,
see `lua_api.md`).

This function must be called in the `on_step` function
in every step. `dtime` and `moveresult` are the same as
in `on_step`.

### `rp_mobs.handle_drowning(mob, dtime)`

Handles breath and drowning damage for the mob
if the entity field `_can_drown` is `true`.

Mob drowning is meant to closely reflect player drowning.

This function requires that `rp_mobs.init_breath` has
been called in `on_activate` before.

Technically, this function checks if the mob’s drowning
point  is inside a node with a non-zero non-nil `drowning`
field. If this is the case, the internal `_breath` will
be reduced in a regular interval. If `_breath` reaches zero,
the mob will take damage equal to the node’s `drowning` value.
If the mob is in a non-drowning node, it will regain
breath up to `_breath_max`.
In `"ignore"` nodes, breath will not be changed.

By default, the mob position will be checked to determine
which node is checked for the `drowning` field. If
`_drowning_point` is set, is must be a vector added to
the mob position to check a different position. This
is usually where the mob’s “head” is. The drowning point
should be inside the collisionbox, otherwise the mob
might regain breath when touching a wall.
The drowning point will automatically be rotated with the
mob’s yaw.

Must be called in the `on_step` function in every step.
`dtime` is the `dtime` argument of `on_step`.

### `rp_mobs.handle_environment_damage(mob, dtime, moveresult)`

Handle all environment damages. This is is the same as
calling:

* `rp_mobs.handle_fall_damage`
* `rp_mobs.handle_node_damage`
* `rp_mobs.handle_drowning`

Must be called in `on_step` every step.
`mob` is the mob. The `dtime` and `moveresult`
arguments are the same as for `on_step`.

### `rp_mobs.on_death_default(mob, killer)`

The default handler for `on_death` of the mob's entity definition.
It must be set explicitly for every mob, unless you want to have a custom death handling.
Currently, the default death handler just drops the mob death items.

Set `on_death = rp_mobs.on_death_default` to use the default death behavior.

### `rp_mobs.register_capture_tool(itemname, definition)`

Registers an *existing* tool as a capture tool.

* `itemname`: Item name of the item that captures
* `definition`: A table with these fields:
    * `uses`: Number of uses before the tool breaks. 0 = unlimited
    * `sound`: (optional) Name of sound that plays when “swinging” the tool
    * `sound_gain`: (optional) Gain of that sound (as in `SimpleSoundSpec`)
    * `sound_max_hear_distance`: (optional) `max_hear_distance` of that sound (as in `SimpleSoundSpec`)

### `rp_mobs.is_alive(mob)`

Returns true if the given mob is alive, false otherwise. `mob` *must* be a mob.

## Default callback handlers

* `on_death`: `rp_mobs.on_death_default`
