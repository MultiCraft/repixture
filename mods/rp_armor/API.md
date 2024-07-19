# API for `rp_armor`

There are several helper functions for armor, plus,
you can register your own armor set.

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

### `armor.register_armor_set(mod_name, material_id, def)`

Registers a full set of armor. The armor items will be registered as:

    <mod_name>:<material_id>_<armor_piece>

Where `<mod_name>` and `<material_id>` are provided by you and
`<armor_piece>` is either `helmet`, `chestplate` or `boots`.

By default, the following crafting recipes will be added:

* Helmet: 5 times `def.craftitem`
* Chestplate: 8 times `def.craftitem`
* Boots: 6 times `def.craftitem`

This function requires the following texture files to be present:

* `<prefix>_<armor_piece>_<material_id>_inventory.png`: Inventory and wield image for each armor piece
* `<prefix>_<armor_piece>_<material_id>_hud.png`: HUD image for each armor piece
* `<prefix>_<armor_piece>_<material_id>.png`: Texture of armor piece overlaid on player model

Where `<prefix>` must be defined in the parameters.

Function parameters:

* `mod_name`: Mod name for item identifiers. Should be the same as the mod registering the armor.
* `material_id`: Material identifier. Also used for item identifiers.
* `def`: Armor definition. A table with these fields:
   * `craftitem`: item used for crafting recipes (or nil to don’t register crafting recipes)
   * `descriptions`: list of descriptions for each armor piece (in this order: helmet, chestplate, boots)
   * `protections`: list of protection percentages for each piece (same order as for descriptions).
                    can also be specified as a single number, which defines protection for all pieces.
   * `inventory_image_prefix`: prefix for inventory image file name (e.g. `"armor"`)
   * `full_suit_bonus`: bonus protection percentage points for wearing full suit (default: 0)
   * `sound_equip`: name of sound to be played when equipping (default: `"rp_armor_equip_metal"`)
   * `sound_unequip`: name of sound to be played when unequipping (default: `"rp_armor_unequip_metal"`)
   * `sound_pitch`: sound pitch for all sounds (default: 1)

Hint: Look in `register.lua` to see how this function works in practice.



## Tables

### `armor.slots`

A list which contains the available armor slot identifiers, starting with the first one.
The first identifier corresponds to the first inventory list slot, the second name to the
second slot, etc.

### `armor.slot_names`

A list of human-readable armor slot names, in the same order as `armor.slots`.
