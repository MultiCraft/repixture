# API for `rp_player`

Allows to register player models and change the current player model, animation and textures.
The mod itself registers a default model with name `character.b3d`.

**IMPORTANT**: If you attach or detach the player, you **MUST** update `rp_player.player_attached`
(see below).

The following functions are available:

## Functions
### `rp_player.player_register_model(name, def)`

Register a player model.

Params:
* `name`: File name of the model, and also the model identifier for other functions
* `def`: Model definition table (see below)

The model definition table has the following form (the default value is
written right of the equals sign, if any):

```
{
   animation_speed = 30,           -- Default animation speed, in keyframes per second
   textures = {"character.png"},   -- Default array of textures
   animations = { -- Table of animations
      -- [anim_name] = {
      --   x = <start_frame>,
      --   y = <end_frame>,
      --   collisionbox = <model collisionbox>, -- (optional)
      --   eye_height = <model eye height>,     -- (optional)
      --   -- suspend client side animations while this one is active (optional)
      --   override_local = <true/false>
      -- },
   },
   -- Default object properties, see lua_api.txt:
   visual_size = {x = 1, y = 1},
   collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
   stepheight = 0.6,
   eye_height = 1.47
}
```

For the `animations` table, the following animation names (`anim_name`) are available:

* `stand`: Stand
* `lay`: Lay on ground
* `walk`: Walk
* `mine`: Mine/punch
* `walk_mine`: Walk and mine/punch at the same time
* `sit`: Sit

All animations except `sit` are strictly mandatory.
`sit` is used by boats and other mods so it should be added as well.


### `rp_player.player_set_model(player, model_name)`

Set the currently used model of `player` to `model_name`.
Must have been registered with `rp_player.player_register_model` before.

### `rp_player.player_get_textures(player)

Returns the current player textures (table).

Calling this function before player textures have been set (either
directly or indirectly from the model definition) is an error.

### `rp_player.player_set_textures(player, textures)`

Sets the player's textures to `textures` (table).
If `nil`, the default from the model definition is used.

### `rp_player.player_get_animation(player)`

Returns the animation data for `player`. Return value is a table of this form:

```
{
	model = <player model name>,
	textures = <textures list>,
	animation = <current animation>,
}
```

Any of the fields of the returned table may be `nil`.

### `rp_player.player_set_animation(player, anim_name, speed)`

Set the current animation for `player` to `anim_name` with
animation speed `speed` (in keyframes per second).
If speed is `nil`, the default from the model definition is used.
`anim_name` is an animation type (see `rp_player.player_register_model`).

### `rp_player.globalstep(dtime, ...)`

This is the function called by the globalstep that controls player animations.
You can override this to replace the globalstep with your own implementation.

It receives all arguments that `minetest.register_globalstep()` passes.
 
## Tables

### `rp_player.player_attached`

This is a table indexed by player names containing attachment info for connected players.
The value is either `true` or `false`. `true` means the player is attached to something.

If the value for a given player is set to true, the default player animations
(walking, digging, ...) will no longer be updated, and knockback from damage is
prevented for that player.

Example of usage: A mod sets a player's value to true when attached to a vehicle

You **MUST** update the `true`/`false` value whenever you attach or detach the player.

### `rp_player.registered_models[model_name]`

This table contains all registered models, indexed by the model file name
that was used when it was registered. The table values are the model definition tables.
