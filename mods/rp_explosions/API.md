# `rp_explosions`
This mod provides helper functions to create explosions.

## Blast resistance

This mod expects nodes to specify a blast resistance value. The higher it is, the harder
it is for the node to break by explosions.

To specify the blast resistance, add `_rp_blast_resistance = <number>` to the node definition.

The default blast resistance is 0. At blast resistance 1000000 or higher, the node becomes indestructible.

## `rp_explosions.explode(pos, strength, info, puncher)`
* `pos`: position, initial position of the explosion
* `strength`: number, radius of the explosion
* `info`: table, contains these optional fields:
    * `drop_chance`: number, if specified becomes the drop chance of all nodes in the explosion (default: 1.0 / strength)
    * `max_blast_resistance`: integer, if specified the explosion will treat all non-indestructible nodes as having a blast resistance of no more than this value
    * `sound`: bool, if true, the explosion will play a sound (default: true)
    * `particles`: bool, if true, the explosion will create particles (default: true)
    * `griefing`: bool, if true, the explosion will destroy nodes (default: true)
    * `grief_protected`: bool, if true, the explosion will also destroy nodes which have been protected (default: false)
    * `death_message`: string. If set, will send this as a custom death message to all players who get killed. Can be translated. (default: "You were caught in an explosion" (translated)).
* `puncher`: (optional) entity, will be used as source for damage done by the explosion

## Entity knockback

By default, entities do not suffer knockback from explosions. It has to be activated manually.
To activate knockback, add `_rp_explosions_knockback = true` to the entity definition in
`minetest.register_entity`.
