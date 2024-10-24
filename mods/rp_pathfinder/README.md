# Advanced Pathfinder for Repixture (`rp_pathfinder`)

This mod provides an advanced pathfinding algorithm that finds
an optimal path between two positions in the world. It uses the
`A*` search algorithm.

It has more features than the built-in pathfinder of Luanti,
but it is also less performant. It was created to aid mobs (creatures,
animals, monsters) to walk through their world.

Features:

* `A*` search algorithm
* Simulate walking, jumping and falling
* Simulate climbing (optional)
* Respect `disable_jump` and `disable_descend` restrictions (optional)
* Check height clearance (useful for tall mobs)
* Specify which nodes can be walked on, and which ones should be avoided

See `API.md` to learn how to use it.

## Licensing

This mod is free software, released under the terms of the MIT License.
See `LICENSE.txt`.
