# `player_api` Compability Layer API

The player API can register player models and update the player's appearance.

## Should I use this mod?

If you want to handle player stuff from external mods, the answer is usually yes.
If you need some advanced Repixture-specific features, you may depend
on `rp_player` instead.

This mod is the Repixture implementation of `player_api` originally from Minetest Game.
It is API-compatible with Minetest Game's `player_api` from Minetest Game 5.8.0.
Technically, it is just a wrapper around `rp_player`, provided for compability.

## Function reference

The following functions are available:

* `player_api.globalstep(dtime, ...)`
	* The function called by the globalstep that controls player animations.
	  You can override this to replace the globalstep with your own implementation.
	* Receives all args that `minetest.register_globalstep()` passes

* `player_api.register_model(name, def)`
	* Register a new model to be used by players
	* `name`: model filename such as "character.x", "foo.b3d", etc.
	* `def`: see [#Model definition]
	* Saved to `player_api.registered_models`

* `player_api.registered_models[name]`
	* Get a model's definition
	* `name`: model filename
	* See [#Model definition]

* `player_api.set_model(player, model_name)`
	* Change a player's model
	* `player`: PlayerRef
	* `model_name`: model registered with `player_api.register_model`

* `player_api.set_animation(player, anim_name, speed)`
	* Applies an animation to a player if speed or `anim_name` differ from the currently playing animation
	* `player`: PlayerRef
	* `anim_name`: name of the animation
	* `speed`: keyframes per second. If nil, the default from the model def is used

* `player_api.set_textures(player, textures)`
	* Sets player textures
	* `player`: PlayerRef
	* `textures`: array of textures. If nil, the default from the model def is used

* `player_api.set_textures(player, index, texture)`
	* Sets one of the player textures
	* `player`: PlayerRef
	* `index`: Index into array of all textures
	* `texture`: the texture string

* `player_api.get_animation(player)`
	* Returns a table containing fields `model`, `textures` and `animation`
	* Any of the fields of the returned table may be nil
	* `player`: PlayerRef

* `player_api.player_attached`
	* A table that maps a player name to a boolean
	* If the value for a given player is set to true, the default player animations
	  (walking, digging, ...) will no longer be updated, and knockback from damage is
	  prevented for that player
	* Example of usage: A mod sets a player's value to true when attached to a vehicle

## Model definition

	{
		animation_speed = 30,           -- Default animation speed, in keyframes per second
		textures = {"character.png"},   -- Default array of textures
		animations = {
			-- [anim_name] = {
			--   x = <start_frame>,
			--   y = <end_frame>,
			--   collisionbox = <model collisionbox>, -- (optional)
			--   eye_height = <model eye height>,     -- (optional)
			--   -- suspend client side animations while this one is active (optional)
			--   override_local = <true/false>
			-- },
			stand = ..., lay = ..., walk = ..., mine = ..., walk_mine = ..., -- required animations
			sit = ... -- used by boats and other MTG mods
		},
		-- Default object properties, see lua_api.txt
		visual_size = {x = 1, y = 1},
		collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
		stepheight = 0.6,
		eye_height = 1.47
	}
