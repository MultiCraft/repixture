# API documentation for `rp_player_effects`

This mod is a safe way to change player physics while keeping
compatibility with other mods.

Effects change the player physics (walk speed/jump height/gravity, using
`player:set_physics_override` internally).
Each player can have any number of effects active at a time.

If two effects that affect the same physics attribute (like speed),
the values of all effects are multiplied.

E.g. if player X has two effects `sluggish` with `speed=0.3`
and `superspeed` with `speed=2.0`, then the effective player
speed will be `0.3 * 2.0 = 0.6` times of the normal speed.

**IMPORTANT:** In order for this mod to work, it is *forbidden*
for all mods except `rp_player_effects` to call
`player:set_physics_override` directly.

## Functions
### `player_effects.register_effect(ename, def)`

Adds a new effect that players can have.

* `ename`: Effect identifier (not translatable!)
* `def`: Effect definition. This is a table:
    * `title`: Player-facing effect name
    * `description`: Short (!) player-facing effect description
    * `duration`: Effect duration in seconds. If this time is over, the effect will be removed. Negative value = infinite. (default: 1)
    * `physics`: Table of player physics overrides. Supports `speed`, `jump` and `gravity`, same as in `player:set_physics_override`
    * `icon`: Optional effect icon for the HUD
    * `save`: If true, effect will be preserved on server shutdown.
              If false, effect will be gone on server shutdown. (default: true)

### `player_effects.get_registered_effect(ename)`

Returns the definition of the effect with the given identifier `ename`.
The definition is the same as in `player_effects.register_effect`.

### `player_effects.apply_effect(player, ename)`

Apply effect `ename` to player `player`. This applies the physics modifiers to
the player.
The effect will last for the duration as specified in the effect definition.
If the duration is infinite, the effect can be manually removed by
`player_effects.remove_effect`.

### `player_effects.remove_effect(player, ename)`

Instantly removes the effect `ename` from the player `player`.

This works for any effect.

### `player_effects.clear_effects(player)`

Removes all effects from `player`.

Be careful with this function as you might accidentally remove effects
from other mods you did not meant to remove.

Only call this function if you're absolutely sure.

