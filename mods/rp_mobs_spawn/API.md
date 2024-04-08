# Repixture Mobs Spawning API

This mod is for regularily spawning mobs in the world over time.
If you want to spawn mobs in a more controlled way, use the `rp_mobs` API instead.

NOTE: This mod is EXPERIMENTAL and may change at any time.
Use at your own risk!

## Function reference

### `rp_mobs_spawn.register_spawn(name, params)`

Adds a new mob spawning rule for a given mob. Mobs will then randomly spawn
on a certain set of nodes under given light conditions and Y height.

Note that mob spawning may be restricted by certain mob settings.

* `name`: Entity name of mob
* `params`: Spawning parameter table. These fields are used:
	* `nodes`: Table of node names the mob can spawn on. `group:` syntax is supported
	* `neighbors`: (optional) If specified, this is a list of nodes a node
	  must be a neighbor of in order to allow spawning. (default: `nil`)
	* `interval`: A chance to spawn every this many seconds
	* `chance`: Spawn chance in `1/chance`
	* `active_object_limit`: If the total number of active objects in the chosen mapchunk
	  exceeds this number, the mob will not spawn in that mapchunk
	* `active_object_limit_wider`: If the total number of active objects in the chosen mapchunk
	  plus all 26 neighboring mapchunks exceeds this number, the mob will not spawn in that mapchunk
	* `min_light`: (optional) Minimum allowed light level for spawning (default: 0)
	* `max_light`: (optional) Maximum allowed light level for spawning (default: `minetest.LIGHT_MAX`)
	* `min_height`: (optional) Minimum allowed Y level to spawn in (default: map limit)
	* `max_height`: (optional) Maximum allowed Y level to spawn in (default: map limit)

