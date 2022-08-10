# `rp_formspec` API

The `rp_formspec` API provides functions to help building formspecs.
Note the mod adds tabs in the player inventory for things like
crafting, achievements, etc. This is hardcoded and support for
custom player inventory tabs is not possible yet.
The API is currently mostly for templates to ensure a consistent style
in the game.

## Formspec version

Formspec version 1 is used (sorry …).

## Recommended usage

Normally, you want to use one of the default pages below as a starting point,
then populate it with formspec elements. There are many helper functions
you should use for formspec elements (see below) to ensure a consistent
style.

Some rules:

* Inventory lists should be accompanied with one of the “itemslot” functions.
* For buttons, use one of the “button” functions.
* For item images, use one of the item functions.
* “tabs” attach to the left and right side.

## Formspec element functions

These functions are helper functions to generate a special formspec element.
Each of these return a string that can be inserted into a formspec string.

### `rp_formspec.get_itemslot_bg(x, y, w, h)`

Adds a 2D grid of background images for the background of
“normal” item slots. This needs to be used in combination
with `list[]` and the like; as `list[]` alone does *not*
add the item slot images.

* `x`, `y`: Top left position of the grid
* `w`: Width of the grid, number of slots horizontally
* `h`: Height of the grid; number of slots vertically

Use the same position and size as the `list[]` element.
Add this *after* the corresponding `list[]` element
in the formspec string.



### `rp_formspec.get_hotbar_itemslot_bg(x, y, w, h)`

Same as `rp_formspec.get_itemslot_bg`, but for item slots
that represent the player’s hotbar.



### `rp_formspec.get_output_itemslot_bg(x, y, w, h)`

Same as `rp_formspec.get_itemslot_bg`, but for item slots
that represent output slots.



### `rp_formspec.button(x, y, w, h, name, label, noclip, tooltip)`

Adds a button. When the button is pressed, the formspec
is not closed.

* `x`, `y`: Position
* `w`, `h`: Width and height
* `name`: Internal identifier
* `label`: Same as for `button[]` formspec element
* `noclip`: Same as for `button[]` formspec element
* `tooltip`: Tooltip (optional)



### `rp_formspec.button_exit(x, y, w, h, name, label, noclip, tooltip)`

Same as `rp_formspec.button`, but when this button is pressed,
the formspec is closed.



### `rp_formspec.image_button(x, y, w, h, name, image, tooltip)`

Adds a button with an image. When the button is pressed,
the formspec is not closed.

* `x`, `y`: Position
* `w`, `h`: Width and height
* `name`: Internal identifier
* `image`: Same as for `image_button[]` formspec element
* `noclip`: Same as for `image_button[]` formspec element
* `tooltip`: Tooltip (optional)



### `rp_formspec.tab(x, y, name, icon, tooltip, side)`

A sideways tab that is either at the left or right side.

* `x`, `y`: Position
* `name`: Internal identifier
* `icon`: Tab icon (texture file name)
* `tooltip`: Tooltip (optional)
* `side`: On which side to put the tab. `"left"` or `"right"`. Default: `"left"`



### `rp_formspec.fake_itemstack(x, y, itemstack)`

Adds an item image that shows the given itemstack.
A tooltip for the image will be added as well, showing
the item’s tooltip.

* `x`, `y`: Position
* `itemstack`: ItemStack to represent.



### `rp_formspec.fake_simple_itemstack(x, y, itemname, name)`

Adds an item image that shows the given item. Unlike
`rp_formspec.fake_itemstack`, this accepts an itemstring
instead of an itemstack.
A tooltip for the image will be added as well, showing `name`.

* `x`, `y`: Position
* `itemname`: Itemstring of the item to represent
* `name`: Internal name to use for the formspec element, also the tooltip



### `rp_formspec.fake_itemstack_any(x, y, itemstack, name)`

Convenience function that either uses `rp_formspec.fake_itemstack` or
`rp_formspec.item_group`.

`itemstack` is an ItemStack of the item to represent. If the item name
begins with `group:`, this stands for a group name and `rp_formspec.item_group`
is used. Otherwise, it is treated like a real item and `rp_formspec.fake_itemstack`
is used.

* `x`, `y`: Position
* `itemstack`: ItemStack of the item or group to represent
* `name`: Internal name to use for the formspec element iff it’s a group



### `rp_formspec.item_group(x, y, group, count, name)`

A symbol that represents an item group. Item groups use item images
to represent themselves but with a darkened background. Used by
the crafting guide. The group **must** exist in `rp_formspec.group_names`.

* `x`, `y`: Position
* `group`: Group name (must be supported)
* `count`: Item count to show (default: nothing to show)
* `name`: Internal identifier



## Pages

Pages are basically just named formspec strings that this mod remembers
and can be called later.
Pages can be used as templates, but this mod also uses some special
pages to build the player inventory.

### Built-in pages

This mod offers a few built-in pages for mods to use:

* `"rp_default:default"`: A simple empty formspec frame, about the size of an inventory. With tabs.
* `"rp_default:notabs"`: A simple empty formspec frame, about the size of an inventory. Without tabs.
* `"rp_default:2part"`: A page with two parts, separated by a horizontal line in the middle. With tabs.
* `"rp_default:notabs_2part"`: A page with two parts, separated by a horizontal line in the middle. Without tabs.
* `"rp_default:field"`: A small page containing a single text input field and a button “Write” (the text field ID is `"text"`)

“Tabs” here means whether the tabs for the player inventory pages like crafting, armor, achievements, etc.
are shown. Using a page with tabs is only recommended for the player inventory. Outside the
player inventory, these tabs are buggy.



### `rp_formspec.register_page(name, form)`

Registers a page with the identifier `name` and formspec string `form`.
`form` **must not** be the empty string.



### `rp_formspec.get_page(name)`

Returns the formspec string of the page by name `name`.
If the page does not exist, `""` is returned.



### `rp_formspec.registered_pages`

Table which lists all registered pages.

* Key: Page name
* Value: Formspec string of the page

Use `rp_formspec.get_page` to access a specific page! Read-only!



### `rp_formspec.current_page`

Table containing the current page for each connected player.

* Key: Player name
* Value: Name of current page or `nil` if none

Read-only!

## Other stuff

### `rp_formspec.default.bg`

A formspec string containing a `bgcolor[]` element with the default background color.
Read-only!



### `rp_formspec.group_defaults`

A table specifying items that represents groups, as an example.

* Key: The group identifier
* Value: Itemstring of item that represents this group

Used by `rp_formspec.item_group`. Read-only!



### `rp_formspec.group_names`

A table with user-readable group-names.

* Key: The group identifier
* Value: A table of form ` { <short_name>, <long_description>` }
    * `<short_name>`: User-facing name of the group. (Example: “Stone” for the `stone` group)
    * `<long_description>`: A description for the crafting guide, written in a style like “Any stone”

The short names and long descriptions should start with a capital letter in English.

Used by `rp_formspec.item_group`. Read-only!
