# Repixture Mobs API: Task Templates

This document contains additional information about the Repixture Mobs API.
It contains task template functions for common use cases so we don't have to
start from zero for every mob.

See `API.md` for the main document and a general description of the task
system.

## Microtask templates

A microtask template is a function that returns a microtask that you can
then use to insert in a task. All microtask templates are part of the
`rp_mobs.microtasks` table.

### How to use

You simply call one of the template functions with the required parameters
(if any) to get a microtask returned. You then can insert this microtask
like any other microtask in a task.

Minimal example for doing nothing for 3 seconds (we assume that `mob`
is a mob object reference and `task_queue` is a task queue):

```
local task = rp_mobs.create_task({label="do nothing"})
local microtask = rp_mobs.microtasks.sleep(3)
rp_mobs.add_microtask_to_task(mob, task, microtask)
rp_mobs.add_task_to_task_queue(task_queue, task)
```

Also, all microtasks come with a 'finish' condition. If this condition is met,
the microtask is finished and removed from the task, continuing the processing
with the next microtask (if any).

## Microtask template reference

### `rp_mobs.microtasks.move_straight(move_vector, yaw, drag, max_timer)`

Move in a straight line on any axis.

Parameters:

* `move_vector`: velocity vector to target.
* `yaw`: look direction in radians
* `drag`: (optional) if set as a vector, will adjust the velocity smoothly towards the target
   velocity, with higher axis values leading to faster change. If unset, will set
   velocity instantly. If drag is 0 or very small on an axis, this axis will see no velocity change
* `max_timer`: automatically finish microtask after this many seconds (nil = infinite)

Finish condition: If the time runs out (if set with `max_timer`), otherwise does not finish
on its own.

### `rp_mobs.microtasks.walk_straight(walk_speed, yaw, jump, jump_clear_height, stop_at_object_collision, max_timer)`

Walk in a straight horizontal line (on the XZ plane), will jump if hitting a node obstacle and `jump~=nil`.

It's recommended the mob is subject to gravity.

NOTE: You **MUST** call `rp_mobs.scan_environment` in the entity's `on_step` function every step for this to work.

Parameters:

* `walk_speed`: How fast to walk
* `yaw`: walk direction in radians
* `jump`: jump strength if mob needs to jump or nil if no jumping
* `jump_clear_height`: how many nodes to jump up at most
* `stop_at_object_collision`: stop walking if colliding with object
* `max_timer`: automatically finish microtask after this many seconds (nil = infinite)

Finish condition: If the time runs out (if set with `max_timer`) or collides with
and object if `stop_at_object_collision` is true.

### `rp_mobs.microtasks.walk_straight_towards(walk_speed, target_type, target, set_yaw, reach_distance, jump, jump_clear_height, stop_at_reached, stop_at_object_collision, max_timer)`

Walk in a straight horizontal line (on the XZ plane) towards a position or object,
will jump if hitting node obstacle and `jump~=nil`.

It's recommended the mob is subject to gravity.

NOTE: You **MUST** call `rp_mobs.scan_environment` in the entity's `on_step` function every step for this to work.

Parameters:

* `walk_speed`: How fast to walk
* `target_type`: "pos" (position) or "object"
* `target`: target, depending on `target_type`: position or object handle
* `set_yaw`: If true, will set mob's yaw to face target
* `reach_distance`: If mob is within this distance towards target, stop walking. If `nil`, has no effect
* `max_distance`: If mob is further away from target than this distance, stop walking. If `nil`, has no effect
* `jump`: jump strength if mob needs to jump or nil if no jumping
* `jump_clear_height`: how many nodes to jump up at most
* `stop_at_reached`: stop walking and finish if within `reach_distance` of target
* `stop_at_object_collision`: stop walking and finish if colliding with object
* `max_timer`: automatically finish microtask after this many seconds (nil = infinite)

Finish condition: If any of the following is true:
* When the time runs out (if `max_timer` was set)
* Target is within `reach_distance` of the mob and `stop_at_reached` is true
* Target is further away than `max_distance`
* When colliding with object if `stop_at_object_collision` is true

### `rp_mobs.microtasks.set_yaw(yaw)`

Set mob yaw instantly to `yaw`. Finishes instantly.

### `rp_mobs.microtasks.rotate_yaw_smooth(yaw, time)`

Change mob yaw linearly over time towards a target yaw.

Parameters:

* `yaw`: Target yaw in radians or `"random"` for random yaw
* `time`: How much time to use until the target yaw is reached (in ms)

Finish condition: When target yaw was reached (within a small tolerance).

### `rp_mobs.microtasks.autoyaw()`

Set the mob yaw based on the current velocity on the XZ coordinate plane.
If the mob velocity on this plane is zero or near-zero, yaw will
not be changed.

Finish condition: Finishes instantly.

### `rp_mobs.microtasks.sleep(time)`

Do nothing for the given `time` in seconds, then finishes.

### `rp_mobs.microtasks.set_acceleration(acceleration)`

Instantly set mob acceleration to the given `acceleration` parameter (a vector).

Finish condition: Finishes instantly.

### `rp_mobs.microtasks.pathfind_and_walk_to(target_pos, walk_speed, searchdistance, max_jump, max_drop)`

WARNING: This function isn't very accurate stable. Use at your own risk!

Make the mob find a path (using the A\* algorithm) towards `target_pos`,
then starts to walk that path.
This assumes the mob is bound to gravity. Jumping up and falling down a few blocks is
part of the pathfinding.

Parameters:

* `target_pos`: Target position
* `walk_speed`: How fast to walk
* `searchdistance`: How far (in nodes) from the mob's original position the pathfinder
  will search before stopping
* `max_jump`: Maximum allowed jump height (can be 0)
* `max_drop`: Maximum allowed fall height (can be 0)

Finish condition: When the mob has reached `target_pos` (within a small tolerance).
Also, finished instantly when no path was found.


