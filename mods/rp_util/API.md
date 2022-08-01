# Function documentation for `rp_util`

## `util.sort_pos(pos1, pos2)`

Given two positions `pos1` and `pos2`, returns the two positions,
but the one with the lower coordinates comes first.



## `util.fixlight(pos1, pos2)`

Repair most lighting between positions `pos1` and `pos2`.



## `util.nodefunc(pos1, pos2, nodes, func, nomanip)`

Call a function `func` for every node of a single type in a given area.

Parameters:

* `pos1`: First corner of area
* `pos2`: Second corner of area
* `nodes`: List of node names (supports `group:<groupname>` syntax)
* `func` Function to be called. Will be called for every positon
         between `pos1` and `pos2` with the argument `pos`
* `nomanip`: If true, will not use VoxelManip (default: false)



## `util.remove_area(pos1, pos2, nomanip)`

Remove every node between `pos1` and `pos2`.

Parameters:

* `pos1`: First corner of area
* `pos2`: Second corner of area
* `nomanip`: If true, will not use VoxelManip (default: false)



## `util.areafunc(pos1, pos2, func, nomanip)`

Call a function `func` for every node in a given area.

Parameters:

* `pos1`: First corner of area
* `pos2`: Second corner of area
* `func` Function to be called. Will be called for every positon
         between `pos1` and `pos2` with the argument `pos`
* `nomanip`: If true, will not use VoxelManip (default: false)



## `util.reconstruct(pos1, pos2, nomanip)`

Force a re-construction of a number of pre-defined node types (like chests)
in an area, for fixing missing metadata in schematics.
This means, `on_construct` for these nodes will be called.

Parameters:

* `pos1`: First corner of area
* `pos2`: Second corner of area
* `nomanip`: If true, will not use VoxelManip (default: false)



## `util.choice(tab, pr)`

Returns a random index of the given table.

Parameters:

* `tab`: Table with choices (in list form)
* `pr`: PseudoRandom object (optional)



## `util.choice_element(tab, pr)`

Returns a random element of the given table.
2nd return value is index of chosen element.
Returns `nil` if table is empty.

Parameters:

* `tab`: Table with choices (in list form)
* `pr`: PseudoRandom object (optional)



## `util.dig_up(pos, node, digger)`

Dig the node above `pos` if nodename is equal to `node.name`.
`digger` is a player object that will be treated as
the 'digger' of said nodes.



## `util.dig_down(pos, node, digger)`

Dig the node below `pos` if nodename is equal to `node.name`.
`digger` is a player object that will be treated as
the 'digger' of said nodes.



## `util.pointed_thing_to_place_pos(pointed_thing, top)`

Helper function to determine the correct position when
the player places a "plantlike" node like a sapling.
The goal is the node will end up on top of a "floor"
node when possible, while also taking `buildable_to`
into account.

Takes a `pointed_thing` from a `on_place` callback or similar.
* `pointed_thing`: A pointed thing
* `top`: (optional): If true, is for plant placement at ceiling
  instead (default: false)

Returns `<place_in>, <place_on>` if successful, `nil` otherwise
* `place_in`: Where the node is suggested to be placed
* `place_on`: Directly below `place_in`



## `util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)`

Use this function for the `on_place` handler of tools and similar items
that are supposed to do something special when "placing" them on
a node. This makes sure the `on_rightclick` handler of the node
takes precedence, unless the player held down the sneak key.

Parameters: Same as the `on_place` of nodes.

Returns `<handled>, <handled_itemstack>`.

* `<handled>`: true if the function handled the placement. Your `on_place` handler should return <handled_itemstack>.
             false if the function did not handle the placement. Your on_place handler can proceed normally.
* `<handled_itemstack>`: Only set if `<handled>` is true. Contains the itemstack you should return in your
                       on_place handler

Recommended usage is by putting this boilerplate code at the beginning of your function:

    local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
    if handled then
        return handled_itemstack
    end



## `util.handle_node_protection(player, pointed_thing)`

Check if `pointed_thing` is protected, if `player` is the "user" of that thing,
and does the protection violation handling if needed.
Returns `true` if it was protected (and protection dealt with), `false` otherwise.
Always returns `false` for non-nodes.



## `util.is_water_source_or_waterfall(pos)`

Returns `true` if node at given pos is water AND either a source or a "waterfall"
(water flowing downwards)
