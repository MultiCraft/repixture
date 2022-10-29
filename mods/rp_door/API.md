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
    * `tiles_top`: Table of textures for the top door node. The first field is the front/back, the second field is top/bottom/side
    * `tiles_bottom`: Same as `tiles_top`, except for the bottom door node
    * `sounds`: Node sounds. Same as of node definition
    * `sunlight`: If true, will set `sunlight_propagates` of door nodes to true
    * `sound_close_door`: Sound to play when door closes (optional, has a default sound)
    * `sound_open_door`: Sound to play when door opens (optional, has a default sound)
    * `sound_blocked`: Sound to play when the door cannot be opened/closed for some reason (optional, has a default sound)
    * `node_box_top`: Custom node box table for top door segment (optional)
    * `node_box_bottom`: Custom node box table for bottom door segment (optional)
    * `selection_box_top`: Custom selection box table for top door segment (optional)
    * `selection_box_bottom`: Custom selection box table for bottom door segment (optional)

