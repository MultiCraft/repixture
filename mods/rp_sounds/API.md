## Functions

This mod gives you the node sounds. You need these helper
functions to give nodes sounds.

### Node sound functions

These functions are functions for the node's `sounds` table.

#### Basic syntax

Every node sound function returns a value that you can use to set the node's
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


#### List of node sound functions

These are the available functions:

* `rp_sounds.node_sound_defaults(table)`: Default/fallback sounds (use when nothing else fits)
* `rp_sounds.node_sound_small_defaults(table)`: Generic sound for small objects
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
* `rp_sounds.node_sound_grass_defaults(table)`: Grass and grass-like/soft plants
* `rp_sounds.node_sound_plant_defaults(table)`: Small plant, slightly harder/“woody” than grass
* `rp_sounds.node_sound_straw_defaults(table)`: Straw
* `rp_sounds.node_sound_glass_defaults(table)`: Glass
* `rp_sounds.node_sound_crystal_defaults(table)`: Crystal
* `rp_sounds.node_sound_fuzzy_defaults(table)`: Fuzzy, soft surface (like wool, cotton, bedsheet)
* `rp_sounds.node_sound_water_defaults(table)`: Water
* `rp_sounds.node_sound_snow_defaults(table)`: Snow (incomplete, not recommended)

### Helper functions

#### `rp_sounds.play_place_failed_sound(player)`

Play the default `place_failed` sound (when placement of a node/item fails)
for `player`. If `player` is not a player, nothing is played.

This function is useful if you want to handle a node placement manually
and want to fail the placement of a node. The rule of thumb is to play this
when you manually make node placement fail, *except* when it was because
of a protection violation Then no sound should be played.
(We expect protection handing to be done by the protection mod.)

#### `rp_sounds.play_node_sound(pos, node, soundtype)`

Convenience function that plays a node sound of the node `node`
at `pos`, taken from the node’s `sounds` table.

* `pos`: Position to play sound at
* `node`: Node table of the node to take the sounds from
* `soundtype`: The type of sound (name from the node definition’s `sounds` table, e.g. `"place"`, `"dig"`, etc.)

If the node or soundtype is unknown, no sound is played.
