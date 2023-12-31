# `rp_paint` developer documentation

`rp_paint` allows players to make nodes paintable with the paint brush.

The mod has a palette of 19 colors. Nodes with `paramtype2="colorfacedir"`
support a subset of that palette with 8 colors.

By default, no nodes are paintable. They can be made paintable by altering the node definition.

## How to make a node paintable

There are two methods to make a node paintable: Directly and indirectly.

The direct method is used when the node itself already comes in a default “painted” state
when placed. The color is thus always stored in the node itself via param2.
This is the simpler method.

The indirect method is used when the node has a “neutral”/“unpainted” state.
This method requires an additional “companion” node to be registered.

By convention, all paintable nodes *MUST* drop in a “neutral” state, that is
with their color metadata erased. This is why adding the `drop` field is
a requirement.

### Direct method

Follow these steps to make a node paintable directly:

1. Add the `paintable = 1` group
2. Set the `tiles` and optionally `overlay_tiles` as you wish (see Minetest Lua API documentation)
3. Add the field `palette` (see below)
4. Set `paramtype2` to `"color"`, `"color4dir"`, `"colorwallmounted"` or `"colorfacedir"`
5. Add the field `drop = "<name of this node>"`

### Indirect method

To make a node paintable indirectly, you need two nodes: An unpainted node, and a painted node.

For the unpainted node:

1. Add the `paintable = 2` group
2. Choose the tiles/textures to be of a “neutral” color (whatever that means to you)
3. Add the field `drop = "<name of this node>"`

For the painted node:

1. Use the same nodename as the unpainted node, but append `_paintable`
2. Add the groups `paintable = 1` and `not_in_creative_inventory = 1`
3. Set the `tiles` and optionally `overlay_tiles` as you wish (see Minetest Lua API documentation)
4. Add the field `palette` (see below)
4. Set `paramtype2` to `"color"`, `"color4dir"`, `"colorwallmounted"` or `"colorfacedir"`
6. Add the field `drop = "<name of the unpainted node>"`

### Palettes

Depending on the `paramtype2` you use for the node, you must pick one of various palettes.

* `"color"`: `rp_paint_palette_256.png`
* `"color4dir"`: `rp_paint_palette_64.png`
* `"colorwallmounted"`: `rp_paint_palette_32.png`
* `"colorfacedir"`: `rp_paint_palette_8.png`

There are also a desaturated palette variants:

* `"color"`: `rp_paint_palette_256d.png`
* `"color4dir"`: `rp_paint_palette_64d.png`
* `"colorwallmounted"`: `rp_paint_palette_32d.png`
* `"colorfacedir"`: `rp_paint_palette_8d.png`

Most palette support the full 19 colors, but the palette for
`"colorfacedir"` only contains 8 colors. When these nodes
are painted with a color the node doesn’t support,
the mod will pick a close fallback color.

## `_on_paint` callback

Paintable nodes can optionally have a `_on_paint` function in their definition.
It is called whenever the node is about to be painted (but before the
actual painting).

This function has the signature `(pos, new_param2)` where `pos` is
the node position and `new_param2` is the new param2 value that is
about to be set for this node.

This function must return a boolean value: `true` if painting is allowed
or `false` to disallow/deny the painting.

## Setting and getting color

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

### Color IDs

Each color has an unique numeric ID. The following IDs are available:

* `rp_paint.COLOR_WHITE`
* `rp_paint.COLOR_GRAY`
* `rp_paint.COLOR_BLACK`
* `rp_paint.COLOR_RED`
* `rp_paint.COLOR_ORANGE`
* `rp_paint.COLOR_TANGERINE`
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
