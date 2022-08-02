# API for `rp_locks`

This mod only has a few info functions for lockable nodes.

## Function reference

### `locks.is_owner(meta, player)`

Given a NodeMetaRef `meta` of a node, and a `player`,
returns `true` if `player` is considered the owner
of that node (in the context of this mod),
and `false` otherwise.

### `locks.has_owner(meta)`

Given a NodeMetaRef `meta` of a node, returns `true`
is this node has an owner. Returns `false` if the node is
owner-less instead.

### `locks.is_locked(meta, player)`

Given a NodeMetaRef `meta` of a node, and a `player`,
returns `true` if this node is considered to be currently
locked from the perspective of `player`, i.e.
if the player is unable to *currently* access this
node. Returns `false` if the node *is* accessible to the
player.

Note: A node being cracked open with the lockpick by `player`
makes the node temporarily “unlocked” for `player`.

