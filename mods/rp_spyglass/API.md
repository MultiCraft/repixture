# API for `rp_spyglass`

This mod provides the following functions:

## `rp_spyglass.is_spyglassing(player)`

Returns `true` if the given `player` (a player object) is currently
using a spyglass or `false` if not.

## `rp_spyglass.toggle_spyglass(player)`

Force `player` to toggle the spyglass screen.
If the player is not using the spyglass *and* wields a spyglass, the spyglass screen will activate.
If the player is using the spyglass, the spyglass screen will deactivate.
In any other situation, nothing happens.

## `rp_spyglass.deactivate_spyglass(player)`

Force `player` to deactivate the spyglass screen if it is currently active.
If it is not active, nothing happens.
