# API for `rp_farming`

This allows mods to register new plants for farming.

Every farming plant must have 4 nodes, one for each stage from 1 to 4.
Stage 1 is the first plant stage. It also acts as a seed item.
Stage 4 is the final stage.

The plants use node timers to grow. The time for the plant to grow fully determined by `grow_time`, which is a worst-case time. The actual time will most likely be lower than that due to random chance, picking a time randomly between half of `grow_time` and `grow_time`. Additionally, rain and fertilizer can further cut down the effective growth time because they will cause the plant to grow by one extra step each.

To add a new plant, the recommended method is to first call `farming.register_plant_nodes` and then `farming.register_plant`.

## Functions

### `farming.register_plant_nodes(name, def)

Registers nodes for a plant. One node is registered for each plant stage (1 to 4). It registers nodes with a name `<name>_<stage>"` for each stage.

The following texture files must be present:

* `<def.texture_prefix>_<stage>.png` for the plant texture (one for each stage)
* `<def.texture_prefix>_seed.png` for the seed inventory/wield image (for stage 1)

These are the arguments (note that most arguments are required):

* `name`. Plant ID. Must be for the form `<mod_name>:<plant_name>`
* `def`: A definition table with these fields:
   * `texture_prefix`: Prefix for all texures used by this plant. Recommended style: `"<mod_name>_<plant_name>"`
   * `description_stage_1`: Translatable description for the stage 1 node (this is the seed)
   * `tooltip_stage_1`: Translatable tooltip for the stage 1 node (describe here how the seed grows)
   * `description_general`: Description for other stage nodes (2-4). This string must have "@1" in it which will be replaced with the stage number.
     The recommended writing style is `"Whatever Plant (stage @1)"`.
   * `meshoptions`: If set, set the `paramtype2` to `"meshoptions"` and `place_param2` to the value of this argument
   * `drop_stages`: Optional. Table indexed by stage. Each of these keys has a value which is an optional node drop definition table.
   * `stage_extras`: Optional. Table indexed by stage numbers. Each of these keys has a table as a value. In that table, you can list
     things you would like to add to a node definition table for that stage, for example, adding `walkable = true`.
     If the default node definition already defines this field, it will be overwritten.
     You **must not** set `on_timer`, `on_construct` or `on_place` here!
   * `stage_extra_groups`: Optional. Table indexed by stage numbers. Each of these keys has a table as a value. This table is a
     groups table for nodes. These groups will be added to the corresponding nodes.
     If the default node definition already defines this group, it will be overwritten.

The nodes will be added to the following groups by default:

* `plant = 1`
* `farming_plant = 1`: Identifies nodes as a plant for this mod
* `plant_<name> = <stage>`: Identifies the plant type and stage
* `snappy = 3, handy = 2`: Digging groups
* `attached_node = 1`
* `not_in_creative_inventory = 1`: Added for non-stage 1 nodes
* `not_in_craft_guide = 1`: Added for non-stage 1 nodes

### `farming.register_plant(name, def)`

Registers a plant. Before you can call this function, you need to have registered the plant nodes (one for each stage). It is recommended to call `farming.register_plant_nodes` to do this.

But it's also possible to register the 4 plant nodes manually. If you want to do this, register them with a name of the form `<name>_<stage>"`; `stage` must be between 1 to 4. Stage 1 is also the placable seed. This function then will automatically add placement handlers and node timers to your nodes. You **must not** set `on_timer`, `on_construct` or `on_place` in these nodes.

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
