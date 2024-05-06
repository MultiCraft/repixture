# `rp_death_messages` API

Although this mod comes with a few built-in death messages,
if you add new ways for players to die, you probably want
to customize the death messages.


## Custom node damage death messages

If the player dies due to node damage (via `damage_per_second`),
a default death message will be shown telling the player was killed by a block,
but it doesn't tell which one or how.

The death messages for nodes can be customized by adding a custom node
field to the node definition.

It is strongly recommended that every node with `damage_per_second` does this.

Set `_rp_node_death_message` to a list of strings, each string is
a possible death message. On death, a random message will be shown.

The strings **must not** be translated in the list; instead
the mod will call the translation function for you. Instead,
use the "no-op" translation marker for the strings.

### Example

```
-- Translation boilerplate
local S = minetest.get_translator("example")

-- No-op translation marker
local NS = function(s) return s end

minetest.register_node("example:spikes", {
	description = S("Spikes"),
	damage_per_second = 4,

	-- ... other node definition fields omitted

	_rp_node_death_message = {
		NS("You were impaled by spikes."),
		NS("Spikes have killed you."),
	},
})
```



## Custom punch and `set_hp` death messages

You can set a custom death message for death by `set_hp` and
punches. This is done by calling the following function:

### `rp_death_messages.player_damage(player, message)`

Specify a custom death message to send when you're about to
damage a player via `set_hp` or a punch.
Must be called directly **before** damaging a player.

If the damage will kill the player, the player will receive the
message in chat, unless:

1) The message has timed out,
2) Another message has been sent closer to the death, in
which case that message takes precedence.

If the player does not die within 0.1 seconds after this
function was called, the message will time out and is
discarded.

Note you don't need to check if the HP change would kill the player;
the function will do this for you.

Parameters:

* `player`: Player object that is about to receive damage.
* `message`: Message to show to player in case of death (can be translated)

### Example

This example gives the player 1 damage due to starvation.
If this kills the player, the death message "You starved to death." will be shown.

```
rp_death_messages.player_damage(player, "You starved to death.")
player:set_hp(player:get_hp() - 1, { type = "set_hp", from = "mod" })
```

