# API for `rp_farming`

This allows mods to register new plants for farming. Beware, this API is a bit clunky.

Every farming plant must have 4 nodes, one for each stage from 1 to 4.
Stage 1 is the first plant stage. It also acts as a seed item.
Stage 4 is the final stage.

The plants use node timers to grow. The time for the plant to grow fully determined by `grow_time`, which is a worst-case time. The actual time will most likely be lower than that due to random chance, picking a time randomly between half of `grow_time` and `grow_time`. Additionally, rain and fertilizer can further cut down the effective growth time because they will cause the plant to grow by one extra step each.

## Functions

### `farming.register_plant(name, def)`

Registers a plant. Before you can call this function, you need to manually have registered 4 plant nodes with a name of the form `name .. "_<stage>"` before calling this. `stage` must be between 1 to 4. Stage 1 is also the placable seed.

This function then will automatically add placement handlers and node timers to your nodes. You **must not** set `on_timer`, `on_construct` or `on_place` in these nodes.

Arguments:

* `name`: Plant ID. Must be of the form `<mod_name>:<plant_name>`
* `def`: A definition table with these fields:
    * `grow_time`: The worst-case growing time to grow the plant from stage 1 to the final stage
    * `grows_near`: The node must be near to one of these nodes in this list (can also use `group:<groupname>`)
    * `growing_distance`: Maximum permissible distance from a `grows_near` node
    * `grows_on`: List of nodenames on which the plant can grow (can also use `group:<groupname>`)
    * `light_min`: Minimum required light level to grow
    * `light_max`: Minimum required light level to grow


### `farming.next_state(pos, plant_name)`

Makes the plant at `pos` grow to its next stage, if possible.

* `pos`: Plant position
* `plant_name`: Plant ID (as provided by `farming.register_plant`)

## Functions for internal use only

There are some functions that `rp_farming` uses internally only. You should not call them. For documentation purposes,
they are documented here anyway.

## `farming.grow_plant(pos, name)`

Grows the farm plant. Only for internal use by `rp_farming`.

## `farming.begin_growing_plant(pos)`

Initialize the node timers of the farming plant at pos. Only for internal use by `rp_farming`.

## `farming.place_plant(itemstack, placer, pointed_thing)`

Internal farming plant placement handler. Will be automatically assigned to the seed / stage 1 node. Only for internal use by `rp_farming`.
