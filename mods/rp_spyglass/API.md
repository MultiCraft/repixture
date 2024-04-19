# API for `rp_spyglass`

With the provided functions, you can toggle the spyglass view and check whether
a player is using the spyglass.

## Warning: HUD flag switching

This mod touches the `"wielditem"` HUD flag. It will be disabled while the spyglass is active.
If your mod also wants to touch this HUD flag, don’t do it while the spyglass is active.
Check first if `rp_spyglass.is_spyglassing` returns `false`.

## Functions

### `rp_spyglass.is_spyglassing(player)`

Returns `true` if the given `player` (a player object) is currently
using a spyglass or `false` if not.

### `rp_spyglass.toggle_spyglass(player)`

Force `player` to toggle the spyglass screen.
If the player is not using the spyglass *and* wields a spyglass, the spyglass screen will activate.
If the player is using the spyglass, the spyglass screen will deactivate.
In any other situation, nothing happens.

### `rp_spyglass.deactivate_spyglass(player)`

Force `player` to deactivate the spyglass screen if it is currently active.
If it is not active, nothing happens.
