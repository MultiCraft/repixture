## Functions

This mod gives you the node sounds. You need these helper
functions to give nodes sounds.

### Basic function syntax

Every function returns a value that you can use to set the node's
`sounds` argument with. You can choose between stone, dirt, sand,
and other sounds. There is an optional argument `table` in which
you can override the default sound table returned by this
function. The syntax of this table is the same as for the node's
`sound` field in the node registration function, with the difference
that the keys included in this table will be the ones to override.

Examples:

    rp_sounds.node_sound_wood_defaults()

Returns a sound definition for wooden node sounds.



    rp_sounds.node_sound_dirt_defaults({
        footstep = {name="default_hard_footstep", gain=0.6}
    })

Returns a sound definition with dirt sounds, except the footstep
sound was changed to `default_hard_footstep`.


### List of functions

These are the available functions:

* `rp_sounds.node_sound_defaults(table)`: Default/fallback sounds
* `rp_sounds.node_sound_stone_defaults(table)`: Stone
* `rp_sounds.node_sound_dirt_defaults(table)`: Dirt
* `rp_sounds.node_sound_sand_defaults(table)`: Sand
* `rp_sounds.node_sound_wood_defaults(table)`: Wood, tree, etc.
* `rp_sounds.node_sound_leaves_defaults(table)`: Leaves
* `rp_sounds.node_sound_glass_defaults(table)`: Glass
* `rp_sounds.node_sound_snow_defaults(table)`: Snow
* `rp_sounds.node_sound_water_defaults(table)`: Water
