# API for `rp_armor`

There are several helper functions for armor.

## The armor slots

This mod adds a number of armor slots to the player inventory into
the inventory list `"armor"`. The mod handles this inventory list
automatically and changes the player’s armor groups accordingly.

You *can* make changes to this inventory list yourself, but you
*must* make sure only valid items are added and you also *must*
call `armor.update` after every change.

## Armor piercing of nodes

By default, armor also protects from damage taken by nodes
(`damage_per_second`).
But the effectiveness of armor can be reduced by adding the
group `armor_piercing` to the node.

Its rating ranges from 1 to 100 and modifies the effectiveness
of armor protecting from this node in percent. If the armor
effectiveness is reduced, it's as if the player had worn a weaker
armor.

Examples:
* `50`: Armor is 50% less effective
* `100`: Armor has no effect, player takes full damage

Negative values are ignored.

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

### `armor.get_armor_protection(player)

Returns the current armor protection of the given player, given as percentage points.

Returns `<full>, <base>, <bonus>`, where:

* `<full>`: Effective armor protection (base+bonus)
* `<base>`: Sum of armor protection from armor pieces
* `<bonus>`: Protection bonus

## Tables

### `armor.slots`

A list which contains the available armor slot identifiers, starting with the first one.
The first identifier correspons to the first inventory list slot, the second name to the
second slot, etc.

### `armor.slot_names`

A list of human-readable armor slot names, in the same order as `armor.slots`.
