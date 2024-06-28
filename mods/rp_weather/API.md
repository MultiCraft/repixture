# `rp_weather` API

## Weather types

The following weather types are available:

* `"clear"`
* `"storm"`

## Functions

The following functions are available:

### `weather.get_weather()`

Returns the current weather as a string.

### `weather.get_previous_weather()`

Returns the weather that was active before the current one, as a string.

### `weather.is_node_rainable(pos)`

Returns `true` is position `pos` is in a place in which it could rain into;
returns `false` otherwise.
 
### `weather.weather_last_changed_before()`

Returns the time at which the weather was changed before, in microseconds.
Returns `nil` if weather was never changed in this session.

### `weather.register_on_weather_change(callback)`

Register a function `callback` that will be called after the weather has changed.

* Function signature: `callback(old_weather, new_weather)`
* Parameters:
  * `old_weather`: Name of weather before the change
  * `new_weather`: Name of weather after the change
