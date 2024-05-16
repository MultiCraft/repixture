# `rp_tnt` API

This file documents the functions available for developers in this mod.


## `tnt.burn(pos, igniter)`

Ignite TNT at `pos`.

* `pos`: Position of TNT node
* `igniter`: Optional player object of player who ignited it or `nil` if nobody/unknown

Note: The `igniter` is only used for logging purposes.



## `tnt.boom(pos, radius, sound, igniter)`

Blows up a TNT node.
This will remove the TNT node, cause an explosion at `pos`,
removes nodes around it, drops items, damages entities, spawns particles
and plays a sound effect.

Parameters:

* `pos`: Position of the TNT node. The TNT node is required!
* `radius`: Explosion radius (default: read from `tnt_radius` setting)
* `sound`: Sound name for explosion (default: `tnt_explode`)
* `igniter`: Optional player object of player who ignited it or `nil` if nobody/unknown


## [DEPRECATED] `tnt.boom_notnt(pos, radius, sound, remove_nodes, igniter)`

This function is deprecated. Use `rp_explosions.explode` instead.

Does an explosion.
Same as `tnt.boom` but works for non-TNT nodes as well. No TNT required.

Parameters:

* `pos`: Position of the explosion center.
* `radius`: Explosion radius (default: read from `tnt_radius` setting)
* `sound`: Sound name for explosion (default: `tnt_explode`)
* `remove_nodes`: If true, will remove nodes, otherwise won't. (default: false)
* `igniter`: Optional player object of player who ignited it or `nil` if nobody/unknown


## [DEPRECATED] `tnt.explode(pos, radius)`

This function is deprecated. Use `rp_explosions.explode` instead.

Low-level explosion.
Does a "raw" explosion that only removes nodes and drops items.
There are no particle effects, sounds, entity damage or anything else.
Useful if you want to customize the explosion effects.

* `pos`: Center of the explosion
* `radius`: Explosion radius (NO default value!)
