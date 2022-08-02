# API for `rp_armor`

There are several helper functions for armor.

## The armor slots

This mod adds a number of armor slots to the player inventory into
the inventory list `"armor"`. The mod handles this inventory list
automatically and changes the player’s armor groups accordingly.

You *can* make changes to this inventory list yourself, but you
*must* make sure only valid items are added and you also *must*
call `armor.update` after every change.

## Functions

### `armor.is_armor(itemname)`

Returns `true` if the given item is an armor piece, `false` otherwise.


### `armor.is_slot(itemname, slot)`

Given an item (with `itemname`) and a armor slot name (see `armor.slots`),
checks if the item is an armor piece that belongs into that armor slot.
Returns `true` if the check passes, `false` otherwise.

#### Examples

`armor.is_slot("rp_armor:chestplate_bronze", "chestplate"` returns `true`.
`armor.is_slot("rp_armor:helmet_steel", "boots"` returns `false`.
`armor.is_slot("rp_default:apple, "helmet"` returns `false`.


### `armor.get_formspec(name)`

Returns the armor formspec string for the player with name `name`.
This player **must** be online.


### `armor.get_base_skin(player)`

Returns the regular skin (=texture) for `player` without the armor. Is a string.


### `armor.update(player)`

This function **must** be called whenever the armor inventory of `player` has been changed.



## Tables

### `armor.slots`

A list which contains the available armor slot names, starting with the first one.
The first name correspons to the first inventory list slot, the second name to the
second slot, etc.
