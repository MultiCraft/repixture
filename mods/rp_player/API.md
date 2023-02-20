# API for `rp_player`

Allows to register player models and change the current player model, animation and textures.
The mod itself registers a default model with name `chracter.b3d`.

The following functions are available:

## Functions
### `rp_player.player_register_model(name, def)`

Register a player model.

Params:
* `name`: File name of the model, and also the model identifier for other functions
* `def`: Definition table:
    * `animation_speed`: Speed of all animations
    * `textures`: List of model textures
    * `animations`: List of bone animations
        * Index is animation type name:
            * `stand`: Stand
            * `lay`: Lay on ground
            * `walk`: Walk
            * `mine`: Mine/punch
            * `walk_mine`: Walk and mine/punch at the same time
            * `sit`: Sit
        * Value is a table of form `{ x = <start_frame>, y = <end_frame> }`

### `rp_player.player_set_model(player, model_name)`

Set the currently used model of `player` to `model_name`.
Must have been registered with `rp_player.player_register_model` before.

### `rp_player.player_get_textures(player)

Returns the current player textures (table).

### `rp_player.player_set_textures(player, textures)`

Sets the player's textures to `textures` (table).

### `rp_player.player_get_animation(player)`

Returns the animation data for `player`. Return value is a table of this form:

```
{
	model = <player model name>,
	textures = <textures list>,
	animation = <current animation>,
}
```

### `rp_player.player_set_animation(player, anim_name, speed)`

Set the current animation for `player` to `anim_name` with
animation speed `speed`. `anim_name` is an animation type
(see `rp_player.player_register_model`).
 
## Attachments

### `rp_player.player_attached`

This is a table indexed by player names containing attachment info for connected players.
The value is either `true` or `false`. `true` means the player is attached to something.

You **must** update the `true`/`false` value whenever you attach or detach the player.
