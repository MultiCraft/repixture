# API documentation of `rp_door`

The API allows you to register doors.

## Function reference

### `door.register_door(name, def)`

Registers a door. This will register multiple 'technical' nodes, one for the
top, the other for the bottom door segment, also each in 'open' and
'closed' state. These nodes are not supposed to be gotten by the player.
Also adds a craftitem (with identifier `name`) which the players can use.

* `name`: Door identifier / itemstring
* `def`: Door definition. This is a table with these fields:
    * `description`: Same as in node definition
    * `inventory_image`: Same as in node definition
    * `groups`: List of groups for door item. It is recommended to always add `door=1` here
    * `tiles_top`: Table of textures for the top door node. These fields are used:
        * 1: front/back
        * 2: side
        * 3: top (optional, falls back to side tile if nil)
    * `tiles_bottom`: Same as `tiles_top`, except for the bottom door node, and the third field is for the bottom
    * `overlay_tiles_top`: Same as `tiles_top` but for overlay textures (`overlay_tiles` in node definition) (optional)
    * `overlay_tiles_bottom`: Same as `tiles_bottom` but for overlay textures (optional)
    * `sounds`: Node sounds. Same syntax as for node definition
    * `sunlight`: If true, will set `sunlight_propagates` of door nodes to true
    * `sound_close_door`: Sound (SimpleSoundSpec) to play when door closes (optional, has a default sound)
    * `sound_open_door`: Sound (SimpleSoundSpec) to play when door opens (optional, has a default sound)
    * `sound_blocked`: Sound (SimpleSoundSpec) to play when the door cannot be opened/closed for some reason (optional, has a default sound)
    * `node_box_top`: Custom node box table for top door segment (optional)
    * `node_box_bottom`: Custom node box table for bottom door segment (optional)
    * `selection_box_top`: Custom selection box table for top door segment (optional)
    * `selection_box_bottom`: Custom selection box table for bottom door segment (optional)
    * `is_painted`: Set to true if this door is painted (see `rp_paint` mod)
    * `can_paint`: Set to true if this door can be painted (see `rp_paint` mod)
    * `can_unpaint`: Set to true if this door is painted and its color can be removed (see `rp_paint` mod)
    * `palette`: Palette for painted door (default: `"rp_paint_palette_64.png"`)
    * `_rp_blast_resistance`: Blast resistance of door nodes (see `rp_explosion` mod) (default: 0)

#### Painted doors

To register painted doors, mostly the same rules apply as for normal nodes. See the `rp_paint`
mod for details. The `tiles_*` and `overlay_tiles_*` fields in the door definition
correspond to `tiles` and `overlay_tiles` of the Luanti node definition and need
to be defined properly. Overlay tiles are optional.

What is new is that you *must* add the fields `is_painted`, `can_paint` and/or
`can_unpaint` to the door definition, depending on which of those is true, to
make the door work.

### `door.init_segment(pos, is_open)`
This initializes a door segment to set the correct internal state.

You only need this function is the door segment was generated
procedurally (e.g. via VManip or a schematic). Doors placed
by the player don't need this function.

This currently sets the correct hinge state which is required
for this mod to know about the open/close state.

* `pos`: Position of door segment
* `is_open`: (optional) `true` if this door segment is open,
             `false` otherwise (default: `false`)

### `door.toggle_door(pos)`

This opens or closes the door at pos.
If there is no valid door node at pos, nothing happens.

A door is valid if:

* It consists of two nodes (door segments), one top, one bottom
* Both door segments have a matching door type and state

Single door segments or mismatching door segments don't count as valid.

### `door.is_open(pos)`

Returns `true` is the node at pos is a segment of an open door,
returns `false` if it's a segment of a closed door.
Returns `nil` if the node is not a door segment.

The node does not have to be a part of a valid door.

### `door.get_free_axis(pos)`

Returns the horizontal axis that the door at pos *currently* can be moved through,
regardless of open/close state.
Returns `"x"` when you can move through on the X axis;
returns `"z"` when you can move through on the Z axis.

Returns `nil` if node is not a door.
