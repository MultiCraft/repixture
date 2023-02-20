This tiny mod lets you know when a player got a new item.
This mod is currently not recommended to be used outside of Repixture yet.

Its only function is:

## `rp_checkitem.register_on_got_item(item, callback)`

Registers the function `callback(player)` as an callback for when a player got
or has an item. `callback` might be called repeatedly.

* `item`: Raw item name of item to check for (no `ItemStack` or item count)
* `callback(player)`: Function that is called if `player` has the item

NOTE: `callback` is currently very limited. It might not be called instantly,
depending on how the item got into the player inventory, and it might not
always recognize a gotten item if it was too briefly in the inventory.
Only when the player held on to the item for at least 10 seconds, `callback` is
guaranteed to be called. This behavior might be improved in later versions.

