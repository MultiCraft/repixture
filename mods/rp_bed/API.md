# API documentation for `rp_bed`

This simple API allows setting some stuff related to (re)spawning
and also query info about the bed itself.

## Function reference

### `bed.get_spawn(player)`

Returns the current (re)spawn position of `player` or nil if if there is
none set.

### `bed.set_spawn(player, spawn_pos)`

Sets the bed (re)spawn position for `player`.
Returns true if spawn position was set and changed.
Returns false if spawn position was not changed because
it's already used by the player.


### `bed.unset_spawn(player)`

Clears the bed (re)spawn position of `player`. The player will respawn
according to the default Minetest rules.

### `bed.is_valid_bed(pos)`

Returns true if the node at `pos` is part of a valid bed.

A bed is valid if:

* It consists of 2 nodes, a 'head' and a 'foot'
* Both nodes 'connect' to each other to form a complete bed
* Both nodes have the same `param2`

Single 'bed' nodes (without a matching other piece) count as invalid.
