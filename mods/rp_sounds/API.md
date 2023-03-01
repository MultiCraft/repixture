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
        footstep = {name="rp_sounds_footstep_grass", gain=0.6}
    })

Returns a sound definition with dirt sounds, except the footstep
sound was changed to `rp_sounds_footstep_grass`.


### List of functions

These are the available functions:

* `rp_sounds.node_sound_defaults(table)`: Default/fallback sounds (use when nothing else fits)
* `rp_sounds.node_sound_stone_defaults(table)`: Stone
* `rp_sounds.node_sound_coal_defaults(table)`: Coal, or a similar hard and "crunchy" block
* `rp_sounds.node_sound_dirt_defaults(table)`: Dirt (normal)
* `rp_sounds.node_sound_dry_dirt_defaults(table)`: Dry Dirt
* `rp_sounds.node_sound_swamp_dirt_defaults(table)`: Swamp Dirt
* `rp_sounds.node_sound_sand_defaults(table)`: Sand
* `rp_sounds.node_sound_gravel_defaults(table)`: Gravel
* `rp_sounds.node_sound_wood_defaults(table)`: Wood, generic
* `rp_sounds.node_sound_plank_defaults(table)`: Wood, planks
* `rp_sounds.node_sound_leaves_defaults(table)`: Leaves
* `rp_sounds.node_sound_grass_defaults(table)`: Grass
* `rp_sounds.node_sound_straw_defaults(table)`: Straw
* `rp_sounds.node_sound_glass_defaults(table)`: Glass
* `rp_sounds.node_sound_fuzzy_defaults(table)`: Fuzzy, soft surface (like wool, cotton, bedsheet)
* `rp_sounds.node_sound_snow_defaults(table)`: Snow
* `rp_sounds.node_sound_water_defaults(table)`: Water
