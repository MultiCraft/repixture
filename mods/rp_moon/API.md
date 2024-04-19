# `rp_moon` API

## How moon phases work

Internally, the moon phase is directly derivied from
the current game day (`minetest.get_day_count()`) plus
a random offset that is specific to the world seed.

So on day 0, the moon start with any random phase.

The moon phase is read-only.

## Function reference

### `rp_moon.get_moon_phase()`

Returns current moon phase (0-3).

* 0 = Full Moon
* 1 = Waning Half Moon
* 2 = New Moon
* 3 = Waxing Half Moon

### `rp_moon.update_moon()`

Updates the moon for all players.
You should call this function after the the time of day
has been changed in order for the moon phase to be updated
instantly.
It is not neccessary to call this function for any other reason.
