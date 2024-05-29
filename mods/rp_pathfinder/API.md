# `rp_pathfinder` API

This file explains how to use the `rp_pathfinder` pathfinder. You use it
by calling `rp_pathfinder.find_path`.

## `rp_pathfinder.find_path(pos1, pos2, searchdistance, options, timeout)`

Finds the shortest path to walk on between two positions, using the A* algorithm.
Walks on 'walkable' nodes while avoiding 'blocked' nodes and simulates
jumps and drops (like a player would do). There are many options to customize
the search.

Nodes that are 'walkable' and have node damage are considered 'blocked'.

By default, the search walks through nodes along the 4 cardinal directions,
does not check for height clearance, ignores climbable nodes, `disable_jump`
restrictions and does not cut corners.

### Parameters

* `pos1`: start position
* `pos2`: target position
* `searchdistance`: maximum distance from the search positions to search in.
   In detail: Path must be completely inside a cuboid. The minimum
   `searchdistance` of 1 will confine search between `pos1` and `pos2`.
   Larger values will increase the size of this cuboid in all directions.
* `options`: Table to specify pathfinding options (each of these is optional):
	* `max_jump`: Maximum allowed nodes to jump (default: 0)
	* `max_drop`: Maximum allowed nodes to fall (default: 0)
	* `climb`: If true, can climb climbable nodes up and down (default: false)
	* `respect_climb_restriction`: If true, will respect `disable_jump` and `disable_descend`
          at climbable nodes (default: true)
	* `respect_disable_jump`: If true, can't jump at nodes with `disable_jump` group (default: false)
	* `clear_height`: How many consecutive nodes stacked on top of each other need
          to be 'passable' at each path position. At 1 (default), can walk through any 1-node high
          hole in the wall, at 2, the holes need to be at least 2 nodes tall, and so on. Useful
          to find paths for tall mobs.
	* `handler_walkable`: A function that takes a node table and returns
          true if the node can be walked on top
          (default: all nodes with `walkable=true` are walkable)
	* `handler_blocking`: A function that takes a node table and returns
          true if the node shall block the path
          (default: same as `handler_walkable`)
	* `handler_climbable`: A function that takes a node table and returns
          true if the node is considered climable
          (default: if `climbing` field of node is true)
	* `get_floor_cost`: Function that takes a node table and returns
           the cost (a number) of walking _on_ the given node. The villager searches
           for the path with the lowest total cost. By default, the cost is 1
           for all nodes. The function _MUST NOT_ return a negative cost!
	* `use_vmanip`: If true, nodes will be queried using a LuaVoxelManip;
	  otherwise, `minetest.get_node` will be used. Required for async
	  usage.
	* `vmanip`: Only neccessary for asyn usage. Optionally pass a
	  pre-generated LuaVoxelManip object for the corresponding `pos1`,
	  `pos2` and `searchdistance` arguments. Use the return value of
	  `rp_pathfinder.get_voxelmanip_for_path` here.
	  If this is `nil` and `use_vmanip` is `true`, the LuaVoxelManip object will
	  be generated on the fly.
* `timeout`: Abort search if pathfinder ran for longer than this time (in seconds)

### Return value

On success, returns a list of positions of the path.

On failure, returns `nil, <reason>`, where `<reason>` is one of:

* `"no_path"`: No path exists within the searched area
* `"pos1_blocked"`: The node at `pos1` is blocked
* `"pos2_blocked"`: The node at `pos2` is blocked
* `"pos1_too_high"`: The node at `pos1` is too high above the floor
* `"path_complexity_reached"`: The path search became too complex
* `"timeout"`: Search was aborted because the time ran out

### Asynchronous usage

By default, this function can not be called in an async environment because it keeps calling `minetest.get_node`,
which is not permitted. To use the pathfinder asynchronously, you need to do the following:

* Register `init.lua` of this mod with `minetest.register_async_dofile`
* In the global environment, call `rp_pathfinder.get_voxelmanip_for_path`
  and store the return value
* For the `options` of `rp_pathfinder.find_path` set `use_vmanip=true`
  and `vmanip=<the previously stored value>`
* In the async environment, call `rp_pathfinder.find_path`
* Note: `pos1`, `pos2` and `searchdistance` **MUST** be equal for both function calls

### Performance notes

This function is less performant than the built-in `A*` pathfinder from Minetest,
but it has more features.

For long-distance destinations, calling this function asynchronously is a good idea so the lowered
performance doesn't lock up the server.


## `rp_pathfinder.get_voxelmanip_for_path(pos1, pos2, searchdistance)`

Returns a LuaVoxelManip object for a path between `pos1` and `pos2` and the given
`searchdistance`. Required function for asynchronous usage.

The parameters mean the same as for `rp_pathfinder.find_path`.
