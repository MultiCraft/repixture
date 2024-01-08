# Partialblocks API

This function lets you register partial blocks.

## `partialblocks.register_material(name, desc_slab, desc_stair, node, groups, is_fuel, tiles_slab, tiles_stair, overlay_tiles_slab, overlay_tiles_stair)`

Registers a new material as a partial block (slab and stair). This requires a base node (`node`) from which
the partial blocks will be derived.

This adds a stair, a slab and crafting recipes. If the base node is paintable, the new nodes will be paintable
as well.

Parameters:

* `name`: Identifier for the material (without mod prefix)
* `desc_slab`: Item description of slab
* `desc_stair`: Item description of stair
* `node`: Name of the base node the new partial nodes will be based on (including recipes)
* `groups`: List of groups for the new nodes (see note about groups below)
* `is_fuel`: If true, partial blocks can be used as furnace fuel. (default: false)
* `tiles_slab`: Tiles definition for slab
    * Special: `nil` automatically creates tiles from the base node
    * Special: `"a|<texture_prefix>"` creates advanced textures for custom stair side texture.
               You must provide the texture file `<texture_prefix>_<name>_slab.png` for the slab side.
    * Special: `"A|<texture_prefix>"` same as before, but will wrap the special tiles into
               `{name = <texture>, color="white"}` (useful for overlays of painted blocks)
* `tiles_stair`: Tiles definition for stair
    * Special: `nil` automatically creates tiles from the base node
    * Special: `"a|<texture_prefix>"` creates advanced textures for custom stair top, bottom and side textures.
               You must provide the texture file `<texture_prefix>_<name>_stair.png` for the stair side AND
               `<texture_prefix>_<name>_slab.png` for the stair viewed from above.
    * Special: `"A|<texture_prefix>"` same as before, but will wrap the special tiles into
               `{name = <texture>, color="white"}` (useful for overlays of painted blocks)
    * Special: `"w"` automatically creates world-aligned textures
               from the first base node tile
* `overlay_tiles_slab`: Overlay tiles definition for slab (same syntax as for `tiles_slab`)
* `overlay_tiles_stair`: Overlay tiles definition for stair (same syntax as for `tiles_stair`)

### Additional notes

When `name` ends with `_painted`, that’s a special case that triggers several
painting routines in the code. Only use this for indirectly painted nodes (see below).

The groups `slab=1` and `stair=1` will always be added to the new slab and stair
nodes, respectively.

By default, the `level` group rating of the new nodes will be set to a value 1 lower than
the base node’s level (but never lower than -32767), in order to make the new nodes easier to dig.
If `level` was explicitly specified in the `groups` parameter (i.e. is not `nil`),
that group rating will be used instead. This also applies for `level=0`.

If `is_fuel` is true, the burning time of the partial blocks is based on the burning
time of the base node. It’s 75% of the base node burn time for the stair and 50%
of the base node burn time for the slab.
If the base node is not a fuel, the burn time will be 7 seconds for both stair and slab.

### Painting

Painted nodes are supported (see `rp_paint` documentation to learn the basics).

To add directly painted stairs and slabs, just add `painted=1` to the groups.

To add indirectly painted stairs and slab, call this function twice, once for the unpainted version
and once for the painted version.

For the unpainted version, you must add the group `painted=2`.

For the painted version, you must append `_painted` to the `name`, add the groups `painted=1` and
`not_in_creative_inventory=1`.

Also, you might need to tweak the tiles definitions if the default ones don’t work.
