# API for `rp_item_drop`

This mod offers one function:

## `item_drop.drop_item(pos, itemstack)`

Spawns an item entity at about `pos`.
A bit of randomness to the initial position and velocity
is added to the entity.

If you don't want this behavior, just call `minetest.add_item`
instead.

Parameters:

* `pos`: Center position 
* `itemstack`: An ItemStack or itemstring to use
