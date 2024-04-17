# `rp_paint` developer documentation

`rp_paint` allows players to make nodes paintable with the paint brush.

The mod has a palette of 19 colors. Nodes with `paramtype2="colorfacedir"`
support a subset of that palette with 8 colors.

By default, no nodes are paintable. They can be made paintable by altering the node definition.

## How to make a node paintable

There are two types of paintable nodes: Intrinsic and extrinsic.

An intrinsically paintable node is a node when the node itself already
comes in a default “painted” state when placed. The color is thus always
stored in the node itself via param2. These nodes are always considered
painted. They can’t be scraped by an axe.

Extrinsically painted nodes are nodes that have a “neutral”/“unpainted” state.
This method requires an additional painted node to be registered.
Extrinsically painted nodes can be scraped off by any axe.

By convention, all paintable nodes *MUST* drop in a “neutral” state, that is
with their color metadata erased. This is why adding the `drop` field is
a requirement. The reason for that the player must not have the painted nodes
in inventory to reduce inventory clutter.

### Intrinsically painted nodes

Follow these steps to make an intrinsically painted node:

1. Add the `paintable = 1` group
2. Set the `tiles` and optionally `overlay_tiles` as you wish (see Minetest Lua API documentation)
3. Add the field `palette` (see below)
4. Set `paramtype2` to `"color"`, `"color4dir"`, `"colorwallmounted"` or `"colorfacedir"`
5. Add the field `drop = "<name of this node>"`

### Extrinsically painted nodes

To make an extrinsically painted node, you actually need two nodes: An unpainted node, and a painted node.

For the unpainted node:

1. Add the `paintable = 2` group
2. Choose the tiles/textures to be of a “neutral” color (whatever that means to you)
3. Add the field `drop = "<name of this node>"`

For the painted node:

1. Use the same nodename as the unpainted node, but append `_paintable`
2. Add the groups `paintable = 1`, `not_in_creative_inventory = 1` and `not_in_craft_guide = 1`
3. Set the `tiles` and optionally `overlay_tiles` as you wish (see Minetest Lua API documentation)
4. Add the field `palette` (see below)
4. Set `paramtype2` to `"color"`, `"color4dir"`, `"colorwallmounted"` or `"colorfacedir"`
6. Add the field `drop = "<name of the unpainted node>"`
7. (optional) Add `_rp_paint_particle_node` if needed (see `rp_paint.scrape_color`)

Alternatively to step 1, you may also choose a custom node name for the painted node,
but then you must also do this:

1. Choose any name you like for the painted and unpainted node
2. Add the field `_rp_painted_node_name` to the unpainted node. The value is the name of the painted node
3. Add the field `_rp_unpainted_node_name` to the painted node. The value is the name of the unpainted node

It is recommended to stick with the default naming convention unless a custom name is neccessary
for technical reasons (e.g. if you must obey the naming convention of a different mod).

### Palettes

Depending on the `paramtype2` you use for the node, you must pick one of various palettes
by setting the `palette` field of the node definition accordingly:

* `"color"`: `"rp_paint_palette_256.png"`
* `"color4dir"`: `"rp_paint_palette_64.png"`
* `"colorwallmounted"`: `"rp_paint_palette_32.png"`
* `"colorfacedir"`: `"rp_paint_palette_8.png"`

There are also a desaturated palette variants:

* `"color"`: `"rp_paint_palette_256d.png"`
* `"color4dir"`: `"rp_paint_palette_64d.png"`
* `"colorwallmounted"`: `"rp_paint_palette_32d.png"`
* `"colorfacedir"`: `"rp_paint_palette_8d.png"`

Most palettes support the full 19 colors, but the palette for
`"colorfacedir"` only contains 8 colors. When these nodes
are painted with a color the node doesn’t support,
the mod will pick a color from the 8 color palette
that is close to brush color.

## `_on_paint` callback

Paintable nodes can optionally have a `_on_paint` function in their definition.
It is called whenever the node is about to be painted (but before the
actual painting).

This function has the signature `(pos, new_param2)` where `pos` is
the node position and `new_param2` is the new param2 value that is
about to be set for this node.

This function must return a boolean value: `true` if painting is allowed
or `false` to disallow/deny the painting.

## `_on_unpaint` callback

Same as `_on_paint` but will be called when a painted node is about
to get its color removed and return to its “neutral”/uncolored state.

This function has the signature `(pos, newnode)` where `pos` is the
node position and `node` is the node table of the new node.

## Functions

The color of nodes can be set and gotten programmatically by using
a color ID (see below).

### `rp_paint.get_color(node)`

Returns the color ID of a given node (`node` is given in node table form)
or `nil` if node has an invalid color or can’t be painted.

### `rp_paint.set_color(pos, color)`

Attempts to sets the color of the node at `pos` to the given color ID,
as if using a paint brush. Returns `true` if successful or `false`
on failure.

Note that for nodes with `paramtype2="colorfacedir"`, an approximate
color might be chosen.

### `rp_paint.remove_color(pos)`

Removes color of a paintable node at `pos`, returning it to its
“neutral”/unpainted state.
Returns `true` on success, `false` on failure or if node was not painted
or if node does not support an unpainted state.

### `rp_paint.scrape_color(pos)`

Same as `rp_paint.remove_color`, but will also play a “scraping-off”
sound effect (`_rp_scrape`) and show a particle effect.

The recommended use case for this function is tools.

By default, the particles will be based on the node itself by adding
`node = <the node that was scraped>` to the particle spawner
definition. This looks good for most nodes but sometimes it doesn’t.

Add `_rp_paint_particle_node` to the node definition of a painted
node to specify a different node (as string) to base the
particle effect on. If set to `false`, there will be no scraping
particles.
(Example: `_rp_paint_particle_node = "rp_default:planks_painted"`)

### Color IDs

Each color has an unique numeric ID. The following IDs are available:

* `rp_paint.COLOR_WHITE`
* `rp_paint.COLOR_GRAY`
* `rp_paint.COLOR_BLACK`
* `rp_paint.COLOR_RED`
* `rp_paint.COLOR_ORANGE`
* `rp_paint.COLOR_AMBER`
* `rp_paint.COLOR_YELLOW`
* `rp_paint.COLOR_LIME`
* `rp_paint.COLOR_GREEN`
* `rp_paint.COLOR_BLUEGREEN`
* `rp_paint.COLOR_TURQUOISE`
* `rp_paint.COLOR_CYAN`
* `rp_paint.COLOR_SKYBLUE`
* `rp_paint.COLOR_AZURE_BLUE`
* `rp_paint.COLOR_BLUE`
* `rp_paint.COLOR_VIOLET`
* `rp_paint.COLOR_MAGENTA`
* `rp_paint.COLOR_REDVIOLET`
* `rp_paint.COLOR_HOT_PINK`

The colors white, gray, red, orange, yellow, green, blue and violet
are supported by `paramtype2="colorfacedir"`.
