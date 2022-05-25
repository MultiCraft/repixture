# API for `rp_hunger`

This API contains a few simple functions to get and set the hunger values
of players.

## How hunger works

Each player has a hunger level from 0 to `hunger.MAX_HUNGER`
and a saturation level from 0 to `hunger.MAX_SATURATION`.

The hunger level is the player-facing hunger level shown
by a statbar. Player loses health when it reaches 0,
food increases the hunger level.

The saturation level is a hidden value. The saturation level
goes down over time and for performing various tasks like
digging or building. It increases by eating food. When
saturation is 0, the player will slowly have their
hunger level reduced.

## Functions

### `hunger.get_hunger(playername)`
Returns the current hunger level for `playername`.
Returns `nil` if hunger is disabled.

### `hunger.get_saturation(playername)`
Returns the current saturation level for `playername`.
Returns `nil` if hunger is disabled.

### `hunger.set_saturation(playername, saturation)`
Sets the current saturation level for `playername` to `saturation`.

The value will automatically be capped it out of bounds.

If hunger is disabled, this function does nothing.

### `hunger.set_hunger(playername, hungr)`
Sets the current hunger level for `playername` to `hungr`.

The value will automatically be capped it out of bounds.

If hunger is disabled, this function does nothing.

## Special variables

### `hunger.MAX_HUNGER`

A number which stands for the maximum possible hunger level,
Read-only!

### `hunger.MAX_SATURATION`

A number which stands for the maximum possible saturation level,
Read-only!

