# Repixture Mobs API

This is the API documentation for the Repixture Mobs API. This is the document
you want to read if you want to develop your own Repixture mobs.

## Core concepts

### Mobs

In this mod, a "mob" refers a non-player entity with added capabilities like a task queue. Mobs can be used to implement things like animals or monsters.

### Tasks, microtasks and task queues

The heart of this mod are tasks. A task is a single defined goal that a mob has to achieve in some manner. Every task can either succeed or fail. Tasks include high-level goals such as "find and eat food", "flee from the player", "kill the player", "roam randomly", etc.

Additionally, every task consists of a number of microtasks. These are intended for more low-level and simple activities such as "go to point XYZ", "jump", "attack in direction A". Microtasks are executed sequentially and can either succeed or fail. If a microtask fails, the task it is part of will end. If all microtasks in a task have finished, the task also ends.

To use tasks, they must be initialized by calling `rp_mobs.init_tasks` in `on_activate` and be handled (i.e. executed) every step by calling `rp_mobs.handle_tasks` in `on_step`.

Finally, task queues organize the execution of tasks. A task queue is a sequence of tasks that get executed in order. Tasks get automatically removed from the queue once finished. Task queues also optionally have a number of decider function which are called to determine which tasks to add next.

A mob can have any number of task queues active at a time. While tasks and microtasks are executed sequentially, task queues run in parallel.

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

This mod doesn't handle physics. Just use Minetest’s built-in functions like `set_velocity` and `set_acceleration`.

There’s one exception: Gravity. This mod provides a default gravity vector at `rp_mobs.GRAVITY_VECTOR`.

To activate gravity for a mob, you use the `set_acceleration` microtask template (see the section about task templates).

### Registering a mob
You add (register) a mob via `rp_mobs.register_mob`. Mob definitions in this API are very low-level and similar to typical entity definitions in Minetest. You still have to provide a full entity definition via `entity_definition` including the callback functions like `on_activate` and `on_rightclick`.

You're supposed to use the Repixture Mob API functionality by inserting the various helper functions into the callbacks like `on_step` and `on_activate` where appropriate.

A template for a minimal mob looks like this:

	rp_mobs.register_mob("MOBNAME", {
		description = "MOB DESCRIPTION",
		drops = { ADD_YOUR_DROPS_HERE },
		entity_definition = {
			initial_properties = {
				-- Add the initial entity properties here
				-- e.g. physical, hp_max, textures, etc.
			},
			on_activate = function(self, staticdata)
				rp_mobs.init_mob(self)
				rp_mobs.restore_state(self, staticdata)
				rp_mobs.init_tasks(self)
			end,
			on_step = function(self, dtime, moveresult)
				rp_mobs.handle_dying(self, dtime, moveresult)
				rp_mobs.handle_tasks(self, dtime, moveresult)
			end,
			get_staticdata = rp_mobs.get_staticdata_default,
			on_death = rp_mobs.on_death_default,
			on_punch = rp_mobs.on_punch_default,
		},
	})

## Data structures

This section defines the data structures used in the functions below.

### Task

A task is just a table. It can have the following fields:

* `label`: Brief string explaining what the task does. Only for debug
* `task_queue`: Read-only reference to the task queue this task is part of or nil.
  Will be set automatically when the task is added to a task queue.

Tasks can be created with `rp_mobs.create_task`.

The task's microtasks are stored internally. Use `rp_mobs.add_microtask_to_task`
to add a microtask to a task.

### Microtask

A microtask is a table with the following fields:

* `label`: Same as for tasks
* `on_step`: Called every step of the mob. Handle the microtask behavior here
* `is_finished`: Must returns `<finished>, <success>`
  `<finished>` must be `true` once the microtask is finished.
  `<success>` (optional) can be set when the microtask finished to either `true`
  if it *successfully* finishes (default) or `false` if it finishes in failure
* `on_end`: Called when the microtask has ended. Useful for cleaning up state
* `on_start`: Called when the microtask has begun. Called just before `on_step`
* `singlestep`: If true, this microtask will run for only 1 step and automatically finishes (default: false)
* `statedata`: Table containing data that can be modified and read at runtime
* `task`: Read-only reference to the task this microtask is part of, or nil.
  Will be set automatically when it is added to a task

Every microtask needs to have `on_step` and either `is_finished` or `singlestep = true`.
All other fields are optional. It is not allowed to add any fields not listed above.

`is_finished`, `on_end` and `on_start` have parameters `self, mob` with `self` being
a reference to the microtask table itself and `mob` being the mob object that is affected.

`on_step` has the parameters `self, mob, dtime, moveresult`, where `dtime` is the time in
seconds that have passed since it was last called, or 0 on the first call (like for the entity
`on_step` function), and `moveresult` is the `moveresult` of the entity `on_step`
function (only available if `physical=true` in the entity definition, otherwise it'll be `nil`).

The normal order of execution of the callbacks is as follows: `on_start` is called once
right after the microtask started. Then, in a a loop, first `is_finished` and then
`on_step` is called. If `is_finished` returned `false`, the microtask immediately
finishes (skipping the next `on_step`), causing `on_end` to get called.

In case of a `singlestep` microtask, the execution order is simply `on_start`,
`on_step` (once) and `on_end`. `is_finished` is not called.

When a microtask finishes, it either ends in success or failure. The default
is success. Setting the `success` return value of `is_finished` to `false` will
finish the microtask in failure. If a microtask finished in failure, the task
it contains will end, skipping the remaining microtasks. `singlestep` microtasks always end
in success.

The `statedata` field can be used to associate arbitrary data with the microtask in
order to preserve some state. You may read and write to it in functions
like `on_step`.

Microtasks can be created with `rp_mobs.create_microtask`.

## Subsystems

Subsystems implement core mob features. The task handling is also a subsystem.

Each subsystem is enabled by adding both a `handle_*` function in `on_step`
and an `init_*` function in `on_activate`. Some subsystems only require
one of these functions.

The `handle_*` function in `on_step` **must** be called on *every* step.
Failing to do so leads to undefined behavior.

For example, to enable the Tasks subsystem, call `rp_mobs.init_tasks` in `on_activate`
of the mob entity definition, and `rp_mobs.handle_tasks` in `on_step`. See the
function reference for details.

Some subsystems are mandatory (see overview below).

### Subsystem overview

This overview is a list of all subsystems and the required functions you need to call:

    Subsystem   | on_activate function     | on_step function
    ------------+--------------------------+----------------------------
    Core*       | rp_mobs.init_mob         | **
    Tasks*      | rp_mobs.init_tasks       | rp_mobs.handle_tasks
    Dying       | **                       | rp_mobs.handle_dying
    Node damage | rp_mobs.init_node_damage | rp_mobs.handle_node_damage***
    Fall damage | rp_mobs.init_fall_damage | rp_mobs.handle_fall_damage***
    Breath      | rp_mobs.init_breath      | rp_mobs.handle_breath***
    Breeding    | **                       | rp_mobs.handle_breeding
    
    *   = mandatory
    **  = no function required
    *** = can be replaced with rp_mobs.handle_environment_damage

### Core subsystem

The core subsystem must always be added to the mob. It does initialization
work that is mandatory for all mobs. Add `rp_mobs.init_mob` to the beginning
of the `on_activate` function.

### Dying

An entity “dies” in Minetest when its HP reaches 0, which instantly removes it and
triggers the `on_death` function.

We do not like instant removal so this subsystem provides a simple graphical death
effect and delay. This flips over the mob and calls a special `dying_step`
function every step. This function is used by the mob to handle death physics stuff.

While dying, no tasks or microtasks are run.
The mob is still visible but all player interactions are disabled. After a short
delay, the mob disappears in a cloud of dust by setting the HP to 0,
causing `on_death` to be called.

To use this subsystem, add `rp_mobs.handle_dying` into `on_step`.

**IMPORTANT**: You also must follow a restriction: Never call `set_hp` to
damage the mob. Instead, punch the mob with the built-in `punch` function
or call `rp_mobs.damage`.

Internally, this subsystem works by storing a variable for the mob to hold
the dead/alive state. It can be queried with `rp_mobs.is_alive`.
When the mob has received fatal damage, the HP remains at 1 but the mob
counts as dead.

If this subsystem is not used, the mob will instantly disappear when the HP reaches 0.
But `on_death` is still called because this is built-in by Minetest.

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

### Breath

The breath subsystem enables breath and a drowning mechanic. This makes mobs take
drowning damage when inside a particular node.

If you want your mob to use this, add `rp_mobs.init_breath` to `on_activate`
and `rp_mobs.handle_drowning` in `on_step`. Read the documentation of these
functions to learn more about the drowning mechanic in general.

The drowning status can also be changed during the mob’s lifetime in `on_step`
by manipulating the mob fields (see the mob field reference).

### Breeding

Breeding will make mobs mate and create offspring. To enable, call
`rp_mobs.handle_breeding` in `on_step`. You also need to add the tag
`"child_exists"` to the mob definition.

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

* `_tamed`: `true` if mob is tame
* `_tame_level`: tame level. Starts at 0 and increases for any food given, used to trigger taming
* `_horny_level`: 'horny' level. Starts at 0 and increases for any food given to an adult, used to trigger horny mode
* `_child`: `true` if mob is a child
* `_horny`: `true` if mob is “horny”. If another horny mob is nearby, they will mate and spawn a child soon
* `_pregnant`: `true` if mob is pregnant and about to spawn a child

### Textures

NOTE: You must update these whenever you want to change a mob's texture. If the mob does not use a custom
child texture, `_textures_child` can be skipped.

* `_textures_adult`: Stores a copy of the current mob textures table for the mob in adult form
* `_textures_child`: Stores a copy of the current mob textures table for the mob in child form

### Damage

* `_get_node_damage`: `true` when mob can take damage from nodes (`damage_per_second`) (default: false)
* `_get_fall_damage`: `true` when mob can take fall damage (default: false)
* `_can_drown`: `true` when mob has breath and can drown in nodes with `drowning` attribute (default: false)
* `_drowning_point`: See `rp_mobs.init_breath`.
* `_node_damage_points`: See `rp_mobs_init_node_damage`.
* `_breath_max`: Maximum breath (ignored if `_can_drown` isn’t true)
* `_breath`: Current breath (ignored if `_can_drown` isn’t true)

Please note:
You *must* call `rp_mobs.init_node_damage` before you touch the `_get_node_damage` field.
You *must* call `rp_mobs.init_breath` before you touch the breath/drowning fields.

### Internal use

A bunch of fields are meant for internal use by `rp_mobs`. Do not change them. Reading them is fine.

* `_cmi_is_mob`: Always `true`. Indicates the entity is a mob
* `_child_grow_timer`: time the mob has been a child (seconds)
* `_horny_timer`: time the mob has been horny (seconds)
* `_breed_check_timer`: timer for the breed check (seconds)
* `_pregnant_timer`: time the mob has been pregnant (seconds)
* `_last_feeder`: Name of the last player who fed the mob
* `_dying`: Is `true` when mob is currently dying and about to be removed
* `_dying_timer`: time the mob has been in the dying state (seconds)

## Function reference

### Registrations

#### `rp_mobs.register_mob(mobname, def)`

Register a mob with the entity identifier `mobname` and definition `def`.
The mob definition will be stored under `rp_mobs.registered_mobs[mobname]`.
The field `_cmi_is_mob=true` will be set automatically for all mobs and can be used to check whether any given entity is a mob.

`def` is a definition table with the following optional fields:

* `description`: Mob name used for display purposes (can be translated)
* `entity_definition`: Entity definition table. Put everything in here that is also used
                       for normal entities (`on_step`, `on_activate`, `initial_properties`, etc.).
  * It may also contain this custom function:
    * `_on_capture(self, capturer)`: Called when a mob capture is attempted by capturer (a player).
                                     Triggered by `rp_mobs.call_on_capture`
* `drops`: Items to drop (see 'Drop table' below) on death when mob dies as adult (default: empty table)
* `child_drops`: Items to drop when mob dies as child (default: empty table)
* `drop_func(self)`: (optional) Called when mob is dropping its death drop items. Must return table of items to drop.
                     These items are dropped on top of the items in `drops` and `child_drops`.
                     This function **must not** manipulate the mob in any way.
* `default_sounds`: Table of default sound names to play automatically on built-in events. Sounds will be played by `rp_mobs.default_mob_sound`
  * `death`: When mob dies
  * `damage`: When mob takes non-fatal damage
  * `punch_no_damage`: When mob was punched but took no damage
  * `eat`: When mob eats something (this has a default sound)
  * `call`: Occasional mob call (only played manually)
  * `horny`: When mob becomes horny
  * `give_birth`: When mob gives birth to a child
* `front_body_point`: A point of the front side of the mob, specified as offset vector from the mob position.
    Used to "see" forwards to detect dangerous land (cliffs, damaging blocks, etc.)
    Should be on the front face of the mob model and roughly in the center of that side.
* `path_check_point`: A point that is used to compare the position to the path goal position,
    specified as offset vector from the mob position. This point is used to check whether a path point
    has been 'reached' for the `follow_path*` microtask templates.
* `dead_y_offset`: Y offset of collisionbox when mob is in 'dying' state. Set this to
                   a number so that the mob lies on top of the ground (it should neither
                   float nor be inside the ground)
* `textures_child`: If set, this will be the mob texture for the mob as a child. Same syntax as `textures`
                    of the entity definition. Adult mobs will use `textures`
* `animations`: Table of available mob animations
  * The keys are string identifies for each animation, like `"walk"`
  * The values are tables with the following fields:
    * `frame_range`: Same as `frame_range` in `object:set_animation`
    * `default_frame_speed`: Default `frame_speed` (from `object:set_animation`) when this animation is played
  * Built-in animations are:
    * `"idle"`: Played when mob has nothing to do (empty task queue)
    * `"dead_static"`: Played when mob is dead (there normally should be no animation, just a static frame)
* `tags`: Table of tags.
  * Tags are arbitrary strings used to logically categorize the mob.
  * The table keys are tag names and value for each key must always be 1.
  * You can check if a mob has a tag with `rp_mobs.has_tag` or `rp_mobs.mobdef_has_tag`.
  * Built-in tag names:
    * `"animal"`: This mob is an animal. Some items and achievements check for this tag
    * `"peaceful"`: Mob is considered 'peaceful' towards players if unprovoked. It normally leaves
      the player alone. Peaceful mobs may still turn hostile when provoked.
      Mobs that start hostile towards the player do not count as peaceful.
      If the setting `spawn_peaceful_only` is enabled, only mobs with this tag can spawn.
    * `"child_exists"`: Mob has a functional child version. This tag is only
      for informing other mobs; it does not have an effect in the `rp_mobs` code
  * Example: `tags = { animal = 1, peaceful = 1, exploder = 1 }`
      * A peaceful animal, plus a custom `"exploder"` tag.

##### Drop table

For the arguments `drops` and `child_drops`, two types of values are supported:

1. List of itemstrings: Will drop every item in this list
2. List of drop probabilities: Will drop items by a given chance
    * `name`: Technical itemname
    * `chance`: Chance given in 1/`chance` for this item to drop
    * `min`: Minimum item count when it drops
    * `max`: Maximum item count when it drops

#### `rp_mobs.register_mob_item(mobname, invimg, desc, on_create_capture_item)`

Registers an item representing a mob. It can be used by players to spawn
the mob by placing it. This item is also used when a mob is captured.

The mob item may contain metadata to store the mob's HP and internal state
of the mob.

* `mobname`: Mob identifier
* `invimg`: Inventory image texture
* `desc`: Description for inventory
* `on_create_capture_item`: (optional) Function is called with arguments
   `mob, itemstack` when mob has been captured and is becoming an itemstack.
   You can use this function to modify the itemstack's metadata, e.g. to
   use a item image override if the mob can have different appearances.
   **Must** return an itemstack for the itemstack that is *actually* created.

#### `rp_mobs.register_capture_tool(itemname, definition)`

Registers an *existing* tool as a capture tool.

* `itemname`: Item name of the item that captures
* `definition`: A table with these fields:
    * `uses`: Number of uses before the tool breaks. 0 = unlimited
    * `sound`: (optional) Name of sound that plays when “swinging” the tool
    * `sound_gain`: (optional) Gain of that sound (as in `SimpleSoundSpec`)
    * `sound_max_hear_distance`: (optional) `max_hear_distance` of that sound (as in `SimpleSoundSpec`)

This mod comes with a lasso (`rp_mobs:lasso`) and a net (`rp_mobs:net`) by default.



### Default entity handlers

These functions should be set as the callback functions of the mob entity.
The code will usually look like this:

```
get_staticdata = rp_mobs.get_staticdata_default,	-- required
on_death = rp_mobs.on_death_default,			-- optional, custom handler recommended
on_punch = rp_mobs.on_punch_default,			-- optional
```

#### `rp_mobs.get_staticdata_default(mob)`

The default handler for `get_staticdata` of the mob's entity definition.
This will handle the staticdata of the mob for you. All the mob's internal
information will be stored including the `_custom_state`.
`_temp_custom_state` will be discarded.

This function *must* be set explicitly for every mob.

Set `get_staticdata = rp_mobs.get_staticdata_default` to use this.

#### `rp_mobs.on_death_default(mob, killer)`

The default handler for `on_death` of the mob's entity definition.
It should be set explicitly for every mob, unless you want to have a custom death handling.
Currently, the default death handler just drops the mob death items.

Set `on_death = rp_mobs.on_death_default` to use the default death behavior.

Remember that `on_death` is a built-in Minetest event, so it is triggered even
if the mob doesn't use the 'Dying' subsystem.

#### `rp_mobs.on_punch_default(mob, puncher, time_from_last_punch, tool_capabilities, dir, damage)`

Default `on_punch` handler of mob. Set this function to `on_punch`. The arguments are the same as for `on_punch`.

This will play a the `damage` sound if the mob took damage, otherwise, `hit_no_damage` is played (if the sound exists).



### `on_activate` functions

These are functions to be used in the `on_activate` handler to initialize certain subsystems, like tasks.

Calling `rp_mobs.init_mob`, `rp_mobs.restore_state` and `rp_mobs.init_tasks` in `on_activate` are required, but everything else is optional depending on your needs.

#### `rp_mobs.init_mob(mob)`

This initializes the mob and does initialization work in order to do things that
are required for all mobs.

This function **must** be called in `on_activate` before any other mob-related function.

#### `rp_mobs.restore_state(mob, staticdata)`

This will restore the mob's state data from the given `staticdata` in `on_activate`.

This *must* be called in `on_activate` before any other mob-related function except
`rp_mobs.init_mob`.

#### `rp_mobs.init_tasks(mob)`

Initialize the task and microtask queues for the mob.
This is supposed to go into `on_activate` of the entity definition.

This *must* be called in `on_activate` before any other mob-related function except
`rp_mobs.init_mob` and `rp_mobs.restore_state`.

#### `rp_mobs.init_breath(mob, can_drown, def)`

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

#### `rp_mobs.init_node_damage(mob, get_node_damage, def)`

Initializes the node damage mechanic for the given mob,
activating damage from nodes with `damage_per_second`.
If you want the mob to have this, put this into `on_activate`.

Node damage is dealt by checking one or more "node damage
points" for a node with node damage. By default, the mob
position (`get_pos()`) is checked.

Negative damage heals the mob.

If this is the first time the function is called, the
associated entity fields will be initialized. On subsequent
calls, this function does nothing because the fields are already
initialized.

Parameters:

* `mob`: The mob
* `get_node_damage`: If `true`, mob will receive damage from nodes
* `def`: A table with the following field:
	* `node_damage_points`: Optional list of position offset vectors that will be checked
		when doing the node damage check. Each vector is an offset from the
		mob position (`get_pos()`). If any of the checked positions has a
		node with a non-zero `damage_per_second`, then the node with the highest
		such value will be the damage dealt.
		Default: no offset

Recommendations:

It is strongly recommended you always explicitly define the node damage point(s).

For small mobs, one node damage point is sufficient.
For large mobs (that usually occupy a space much larger than 1 node),
multiple points should be used.
Each damage point should be inside the mob's "body" and be roughly centered.
Use as few points as possible for performance reasons, and don't put them
too close to each other.

#### `rp_mobs.init_fall_damage(mob, get_fall_damage)`

Initializes the fall damage for the given mob,
If you want the mob to have this, put this into `on_activate`.

If this is the first time the function is called, the
associated entity fields will be initialized. On subsequent
calls, this function does nothing because the fields are already
initialized.

Parameters:

* `self`: The mob
* `get_fall_damage`: If `true`, mob will receive fall damage



### Subsystems: `on_step` handlers

These are functions you need to call in the `on_step` callback function of the mob entity in order for a subsystem to work properly.
Each of these functions assumes the corresponding `rp_mobs.init_*` function (if any) has been called before.

#### `rp_mobs.handle_tasks(mob, dtime, moveresult)`

Handle the task queues, tasks, microtasks of the mob for a single step. Required for the task system to work.
This is supposed to go into `on_step` of the entity definition. It must be called every step.

`dtime` and `moveresult` must be passed from the arguments of the same name of the entity’s `on_step`.

#### `rp_mobs.handle_dying(self, dtime, moveresult, dying_step)`

Handles the dying state of the mob if the mob has been killed. If the internal mob state
`_dying` is true, the dying effect is applied and the mob gets removed after a short delay,
triggering the `on_death` callback. It is recommended to put this function before
any other `rp_mobs` subsystem calls.

See the section about the “Dying” subsystem for details.

Parameters:

* `self`: Reference to mob object
* `dtime`: Same as for the entity’s `on_step`
* `moveresult`: Same as for the entity’s `on_step`
* `dying_step`: Optional function with signature `self, dtime, moveresult`
  that is called every step while the mob is in *dying* state

#### `rp_mobs.handle_node_damage(mob, dtime)`

Handles node damage for the mob if the entity
field `_get_node_damage` is `true`. Node damage is taken
when the mob is inside any node with a non-zero `damage_per_second`.
Negative damage heals the mob.

See `rp_mobs.init_node_damage` for details on how the mod
determines when the mob is inside such a node.

Must be called in the `on_step` function in every step.
`dtime` is the `dtime` argument of `on_step`.

#### `rp_mobs.handle_fall_damage(mob, dtime, moveresult)`

Handles fall damage for the mob if the entity field
`_get_fall_damage` is `true`.

Fall damage is calculated differently than for
players and there is no guarantee the calculation
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

#### `rp_mobs.handle_drowning(mob, dtime)`

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
must be inside the collisionbox, otherwise the mob
might regain breath when touching a wall.
The drowning point will automatically be rotated with the
mob’s yaw.

Must be called in the `on_step` function in every step.
`dtime` is the `dtime` argument of `on_step`.

#### `rp_mobs.handle_environment_damage(mob, dtime, moveresult)`

Handle all environment damages. This is is the same as calling:

* `rp_mobs.handle_fall_damage`
* `rp_mobs.handle_node_damage`
* `rp_mobs.handle_drowning`

Must be called in `on_step` every step.
`mob` is the mob. The `dtime` and `moveresult` arguments are the same as for `on_step`.



### Task functions

This section contains the functions to create tasks, microtasks and task queues and to add them to the mob.

See also `rp_mobs.init_tasks` and `rp_mobs.handle_tasks`.

#### `rp_mobs.create_task_queue(empty_decider, step_decider, start_decider)`

Create a task queue object and returns it. The arguments are
optional decider functions.

In these decider functions you can update the task queue by adding new
tasks to it. Avoid complex and slow algorithms here!

* `empty_decider(task_queue, mob)`: called when the task queue is empty
* `step_decider(task_queue, mob, dtime)`: called at every server step
* `start_decider(task_queue, mob)`: called right after the task queue starts

The function arguments are:

* `task_queue`: Reference to task queue on which the decider is run on.
                You can modify it at will.
* `mob`: Reference to mob object
* `dtime`: Time in seconds the last time the step decider was called (from `on_step`)

If decider argument is nil, nothing will be done for that event.

#### `rp_mobs.create_task(def)`

Create a task according to the specified `def` table. See the data structure above for the possible table fields.

Returns the task.

#### `rp_mobs.create_microtask(def)`

Create a microtask according to the specified `def` table. See the data structure above for the possible table fields.
The `statedata` field will always be initialized as an empty table.

Returns the microtask.

Note this only creates it in memory. To actually execute it, you have to add
it to a task with `rp_mobs.add_microtask_to_task` and then execute
the task.

#### `rp_mobs.add_task_queue(mob, task_queue)`

Add a task queue to the given mob.

#### `rp_mobs.add_task_to_task_queue(task, task_queue)`

Add a task `task` to the given task queue object. Will also initialize the `task_queue` field of `task`.

#### `rp_mobs.add_microtask_to_task(mob, microtask, task)`

Add the microtask `microtask` to the specified `task`. Will also initialize the `task` field of `microtask`.

#### `rp_mobs.end_current_task_in_task_queue(mob, task_queue)`

Ends the currently active task in the given `task_queue` of `mob`.
If the task queue is empty, nothing happens.

#### `rp_mobs.clear_task_queue(mob, task_queue)`

Remove all tasks in the given `task_queue`.



### Task template functions

This mod comes with a number of template functions for common microtasks like walking. See `API_TEMPLATES.md` for a reference.



### Breeding functions

#### `rp_mobs.feed_tame_breed(mob, feeder, allowed_foods, food_till_tamed, food_till_horny, add_child_grow_timer, effect, eat_sound)`

Requires the Breeding subsystem.

Let the player `feeder` feed the `mob` with their wielded item and optionally cause the mob to become tame and become horny.
Should be called in `on_rightclick`.

* `mob`: The mob that is fed
* `feeder`: Player who feeds the mob
* `allowed_foods`: List of allowed food items, where each entry must be a table with these fields:
    * `name`: item name of food item
    * `points` optional food points to add to mob when eaten, defaults to `_rp_hunger_food`
       of item definition, and if that one is nil, too, defaults to 1
* `food_till_tamed`: How many food points the mob needs until it is tamed (if nil, can't be tamed by food)
* `food_till_horny`: How many food points the adult mob needs until it becomes horny (if nil, can't be made horny by food)
* `add_child_growth_timer`: (optional) If mob is a child, by how many seconds the child growth timer is increased (default: `20`)
* `effect`: (optional) `true` to show particle effects, `false` otherwise (default: `true`)
* `eat_sound`: (optional) Name of sound to play (default: `"mobs_eat"`)

#### `rp_mobs.make_horny(mob, force)`

Make mob horny, if possible.

#### `rp_mobs.make_unhorny(mob)`

Disable mob being horny.



### Children functions

These function handle the child/adult status of the mob.

#### `rp_mobs.turn_into_adult(mob)`

Turns the mob into an adult.

#### `rp_mobs.turn_into_child(mob)`

Turns the mob into a child.
IMPORTANT: You *must* check whether the mob has the `"child_exists"` tag before calling this.
Don't call this function if the mob does not have this tag.

#### `rp_mobs.advance_child_growth(mob, dtime)`

Advance the child growth timer of the given mob by dtime (in seconds) and turn it into an adult once the time has passed.
Should be added into the `on_step` function of the mob if you want children to grow up. If children must not grow up automatically, don't add this function.



### Capturing functions

#### `rp_mobs.attempt_capture = function(mob, capturer, capture_chances, force_take, replace_with)`

Attempt to capture mob by capturer (a player). This requires a mob to have a mob available as
an item (see `rp_mobs.register_mob_items`), unless `replace_with` is set.

It is recommended to put this function in the `_on_capture` field of the mob’s entity definition.

A mob capture may or may not succeed. A mob capture succeeds if all of these are true:

1. The wielded item is in `capture_chances`
2. The random capture chance succeeds
3. The mob is tamed _or_ `force_take` is `true`
4. The mob is not a child

If successful, `capturer` will get the mob in item form and it will wear out the wielded tool
(exception: no wear in Creative Mode). `capturer` might receive a message. If the mob
was horny, the mob will stop being horny.

The created mob item stores the internal mob state and HP so it will be restored
when the mob is being placed again.

Parameters:

* `mob`: The mob to capture
* `capturer`: Player trying to capture
* `capture_changes`: Table defining which items can capture and their chance to capture:
    * key: itemname, e.g. `"rp_mobs:net"`
    * value: capture chance, specified as `1/value`. e.g. value 5 is a 1/5 chance.
* `force_take`: (optional) If `true`, can capture non-tamed mob
* `replace_with`: (optional) Give this item instead of the registered mob item.
                  If `nil` (default), gives the registered mob item.

#### `rp_mobs.call_on_capture(mob, capture)`

Handle the mob’s capturing logic by calling the `_on_capture` function of the mob’s entity definition. This function *must* exist.

It is recommended to put this into `on_rightclick`, if you want this mob to be capturable.



### Animation functions

#### `rp_mobs.set_animation(mob, animation_name, animation_speed)`

Set the animation for the given mob. The animation name is set in the mob definition in `_animations`. The name *must* exist in this table.

* `mob`: Mob object
* `animation_name`: Name of the animation to play, as specified in mob definition
* `animation_speed`: (optional): Override the default frame speed of the animation

This function handles the animation internals for you. If you call this function with the same animation name and speed twice in a row, nothing happens; no unnecessary network traffic is generated. If you call the function twice in row with the same animation name but a different frame speed, only the animation speed is updated the animation does not restart. In all other cases, the animation is set and started from the beginning.



### Sound functions

#### `rp_mobs.mob_sound(mob, sound, keep_pitch)`

Plays a sound for the given mob. The pitch will be slightly randomized. Child mobs have a 50% higher pitch.

* `mob`: Mob to play sound for
* `sound`: A `SimpleSoundSpec`
* `keep_pitch`: If `true`, pitch will not be randomized and not be affected by child status

#### `rp_mobs.default_mob_sound(mob, default_sound, keep_pitch)`

Plays a default mob sound for the given mob. Default sounds are specified in `rp_mobs.register_mob`. The pitch will be slightly randomized. Child mobs have a 50% higher pitch.

* `mob`: Mob to play sound for
* `default_sound`: Name of a default mob sound, like `"damage"`
* `keep_pitch`: If `true`, pitch will not be randomized and not be affected by child status

#### `rp_mobs.default_hurt_sound(mob, keep_pitch)`

Make a mob play its “hurt” sound. The pitch will be slightly randomized. Child mobs have a 50% higher pitch.

* `mob`: Mob to play sound for
* `keep_pitch`: If `true`, pitch will not be randomized and not be affected by child status



### Nametag functions

The nametag is a HUD text above the head of the mob.

#### `rp_mobs.set_nametag(mob, nametag)`

Set nametag text of mob to `nametag`.

#### `rp_mobs.get_nametag(mob)`

Get nametag text of `mob`.



### Event functions

#### `rp_mobs.register_on_die(callback)`

Registers a function `callback(mob, killer)` where `mob` is a mob reference and `killer`
is an object reference to the mob killer (or nil if there's no killer).

The function `callback` will be called when a mob has entered the 'dying' state, i.e.
lying on the side but not disappeared yet.

This is useful to trigger kill-related achievements but it could be used
for other reasons.

NOTE: This function differs from `on_death` in the entity definition. This callback
triggers when the mob enters the 'dying' state, while `on_death` triggers when
the entity is being *actually* removed.

IMPORTANT: Due to the implementation details, `on_death` will *not* provide
the correct `killer` argument.



### Utility functions

#### `rp_mobs.is_alive(mob)`

Returns `true` if the given mob is alive, false otherwise. `mob` *must* be a mob.

#### `rp_mobs.heal(mob, heal)`

Adds `heal` HP to mob. `heal` must not be negative.

#### `rp_mobs.damage(mob, damage, no_sound, damager)`

Removes `damage` HP from mob, optionally playing the mob's `"damage"` sound. `damage` must not be negative. If the mob HP reaches 0, the mob dies.
`damager` is an optional object that damaged the mob (used for Hunter achievement).

If `no_sound` is true, then no damage sound will be played.

It is recommended to damage a mob only with this function instead of calling `mob:set_hp` directly in order to ensure consistency across mobs.

#### `rp_mobs.die(mob, killer)`

Kill the mob by putting it into the 'dying' state.
`killer` is an optional object that killed the mob (used for Hunter achievement).

See the section about the “Dying” subsystem for details.

#### `rp_mobs.drop_death_items(mob, pos)`

Make mob `mob` drop its death items at `pos`, as if it had died.

This does not kill the mob.

#### `rp_mobs.spawn_mob_drop(pos, item)`

Spawns an mob drop at `pos`. A mob drop is an item stack “dropped”
by a mob, usually on death, but it may also be used on other events.

`item` is an itemstring or `ItemStack`

The difference from `minetest.add_item` is that it adds some random velocity
so this is the recommended function to make a mob drop something.

#### `rp_mobs.has_tag(mob, tag_name)`

Returns true if mob has the given `tag_name` or false if not.

See `rp_mobs.register_mob` for for info about tags.

#### `rp_mobs.mobdef_has_tag(mob_name, tag_name)

Return true if the mob definition for the mob with the given `mob_name` exists
and has a tag with the given `tag_name`. Returns false otherwise.

See `rp_mobs.register_mob` for for info about tags.

#### `rp_mobs.scan_environment(mob, dtime, y_offset)`

Call this function for a mob at every step in an `on_step` handler
to regularly check for nodes nearby the mob, so that other functions
don't have to call `minetest.get_node` over and over again.

After this function was called, the mob will have the following fields added which you can read from:

* `_env_node`: Node table of the node at the mob position.
* `_env_node_floor`: Same as `_env_node`, but for exactly 1 node below the mob position

These fields should only be read from, not written to.

Parameters:

* `mob`: Mob object
* `dtime`: `dtime` from `on_step`
* `y_offset`: Y offset of roughly the "center point" of the mob,
  relative to the mob position (`get_pos()`)

#### `rp_mobs.drag(mob, dtime, drag, drag_axes)`

Slow mob down for the specified drag vector at the specified drag axes.
The drag vector specifies on each axis how much the mob slows down.

This will call `set_velocity` directly.

Parameters:

* `mob`: Mob object
* `dtime`: `dtime` from `on_step`
* `drag`: Drag vector. Higher number = faster slowdown.
* `drag_axes`: List of axes to which apply drag for (`"x"`, `"y"`, `"z"`).
  Other axes will be ignored.

## Appendix

### Glossary

* Mob: Non-player entity with added capabilities
* Task queue: Sequence of tasks a mob will execute in order; can run in parallel
* Task: A sequence of microtasks a mob will execute in order; can’t run in parallel
* Microtask: A simple function a mob will execute every step until a goal condition is met
* Decider: A function that is called in order to determine what to do next in a task queue
* Subsystem: An implementation of core mob features; must be enabled with special functions
* Tag: A simple property that can be assigned to mobs. Used to categorize mobs
* Breed: Bringing two mobs of the same kind together with food to create a child mob
* Tame: A mob eventually becomes tame when it has been fed. Tame mobs behave differently


### Why yet another Mob API?

If you know the Minetest community, you might have noticed there are a lot of Mob APIs around.
So why introduce another one?

The reason is that I (Wuzzy) was dissatisfied with the current mod situation.

The mob mods that existed went into one of two extremes:

The one extreme is Mobs Redo, hardcoding a lot of features into the core mod, but
this created unmaintainable spaghetti code, made it hard to actually customize the mobs apart
from changing some parameters. This usually was also quite wasteful since mobs executed
code they didn't need. Repixture previously used an ancient fork for Mobs Redo.
But the upside of Mobs Redo was that it was very easy to add lots of new mobs, but they
couldn't differ that much.

The other extreme is mobkit. This mod basically wanted to do away with all the hardcoded
behavior and instead give the developer more freedom.
This approach sounded good at first but the problem was that mobkit offered so
little in useful features that you basically still had to start from (almost) zero
to re-implement common features that the mod should have already given you.
This defeats the point of an API.
Other mods that looked promising disappointed me because they are very poorly documented,
making them useless for productive development.

Since none of the available options were satisfying, I've finally decided to create
my own mobs API, which should allow me to add a diverse set of mobs relatively
easy.

I want to have a middle ground between offering many useful built-in features
and flexibility. Performance and documentation are also very important.

#### How this mod aims to reach these goals

The core of this mod is the 'task queue' system. This system serves two
purposes: First, to allow mobs to execute tasks in a certain order, one
after another. This idea was directly inspired by 'The Sims'. In this
game, the sims (the characters you control) also have queue of tasks.
This should allow to add complex tasks that require multiple steps.

Second, and more importantly, mobs can have multiple task queues at
once, each of which will be run in parallel. This was loosely
inspired by multitasking of operating systems.

Parallelization helps greatly improve performance and flexibility,
and it simplifies many complex things. For example, a mob can now
continuously scan its surroundings for enemies while still moving
around. The code for both tasks can be cleanly separated.

Another core concept in this mod is modularization. While this mod
offers built-in high-level features such as drowning, fall damage, breeding
and more, almost everything is optional. Features need to be explicitly
enabled for a mob before they are used. So mobs can only use the
features they need, which is again good for performance and
flexibility.
