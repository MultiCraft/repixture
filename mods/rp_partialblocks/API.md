# Partialblocks API

This function lets you register partial blocks.

## `partialblocks.register_material(name, desc_slab, desc_stair, node, groups, is_fuel, tiles_slab, tiles_stair)`

Registers a new material as a partial block (slab and stair). This requires a base node (`node`) from which
the partial blocks will be derived.

This adds a stair, a slab and crafting recipes.

Parameters:

* `name`: Identifier for the material (without mod prefix)
* `desc_slab`: Item description of slab
* `desc_stair`: Item description of stair
* `node`: Name of the base node the new partial nodes will be based on (including recipes)
* `groups`: List of groups for the new nodes
* `is_fuel`: If true, partial blocks can be used as furnace fuel. (default: false)
* `tiles_slab`: Tiles definition for slab
    * Special: `nil` automatically creates tiles from the base node
    * Special: `"a|<texture_prefix>"` creates advanced textures for custom stair side texture.
               You must provide the texture file `<texture_prefix>_<name>_slab.png` for the slab side.
* `tiles_stair`: Tiles definition for stair
    * Special: `nil` automatically creates tiles from the base node
    * Special: `"a|<texture_prefix>"` creates advanced textures for custom stair top, bottom and side textures.
               You must provide the texture file `<texture_prefix>_<name>_stair.png` for the stair side AND
               `<texture_prefix>_<name>_slab.png` for the stair viewed from above.
    * Special: `"w"` automatically creates world-aligned textures
               from the first base node tile

If `is_fuel` is true, the burning time of the partial blocks is based on the burning
time of the base node. It’s 75% of the base node burn time for the stair and 50%
of the base node burn time for the slab.
If the base node is not a fuel, the burn time will be 7 seconds for both stair and slab.
