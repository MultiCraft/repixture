# API for the Repixture HUD [`rp_hud`]

## HUD flags handling

When your Repixture mod wants to touch HUD flags (like hotbar, wielditem,
zoom), it is **forbidden** to call `player:hud_set_flags` directly.
Instead, HUD flags are handled by so-called semaphores.
(Calling `player:hud_get_flags` is OK.)

This mod uses binary semaphores.

Multiple mods can specify whether they want to allow or forbid a certain
HUD flag. Semaphores can be in two states: true (allow) or false (forbid).
If *any* semaphore assigned to a HUD flag forbids it, the HUD flag will
not be shown. If all semaphores allow the HUD flag, or no semaphores exist
for that HUD flag, the HUD flag will be shown.

Semaphores are also named with a `semaphore_id` in order to distinguish them.

By default, all HUD flags are true.

Use the following function to set a semaphore state:

## `rp_hud.set_hud_flag_semaphore(player, semaphore_id, hud_flag, semaphore_state)`

Set the semaphore for the given player and HUD flag to true or false.

Parameters:

* `player`: Player object for which this takes effect
* `semaphore_id`: Unique identifier for the semaphore. Use the form `"modname:name"`
* `hud_flag`: Which HUD flag to modify (see `hud_set_flags` in Luanti Lua API docs)
* `semaphore_state`: True if the semaphore allows the HUD flag, false if not.

### Notes

The `semaphore_id` is only unique per-player, per-HUD-flag.
So the same `semaphore_id` for two different HUD flags refer to two different
semaphores. The same is true for two different players.

If you set a semaphore to false (forbid) and never turn it back to
true, this disables that HUD flag forever.

### Example

To forbid the minimap HUD element, call:

```
rp_hud.set_hud_flag_semaphore(player, "example:minimap", "minimap", false)
```

To allow the minimap again, call:

```
rp_hud.set_hud_flag_semaphore(player, "example:minimap", "minimap", true)
```

If this was the only mod that touches the minimap HUD element, this
is the same as using `player:hud_set_flag({minimap=state})` with
`state` being `true` or `false`.

But if there are other mods that enable or disable the minimap at will,
the semaphore feature kicks in so the minimap will only be re-enabled when all
semaphores allow it.



## Other functions

This mod includes other public functions (see `init.lua`) but they are *not*
ready for mod use yet. Use at your own risk!
