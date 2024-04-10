# `rp_formspec` API

The `rp_formspec` API provides functions to help building formspecs.
You can use this to get templates for making simple formspecs
and you can also register new pages/tabs.
There are also some functions for adding special
formspec elements, some of them are required.

## Compability note

This mod provides a reasonable formspec prepend so that formspecs
from mods that do not know about `rp_formspec` should still
be acceptable. However, they might not be fully in Repixture style.

Use mod if you want to make use Repixture-specific features.

## Formspec version

Formspec version 7 is used.

## Recommended usage

If you want to build a formspec that is unrelated to the player inventory
menu, you can register pages to act as templates and use the formspec
element functions to add the `rp_formspec`-specific formspec elements
to your formspec.

Things get more complicated if you want to add a page for the player inventory
menu (i.e. an invpage). First, you register a page with `rp_formspec.register_page`,
then you also need to call `rp_formspec.register_invpage` and
optionally `rp_formspec.register_invtab` for the tab. See the function
reference below for details.



## Pages

Pages are basically just named formspec strings that this mod remembers
and can be called later.
Pages can be used as templates, but they can also be “promoted” to invpages (see below).

### Built-in pages

This mod offers a few built-in pages for mods to use:

* `"rp_formspec:default"`: A simple empty formspec frame
* `"rp_formspec:2part"`: An empty frame with two parts, separated by a horizontal line in the middle
* `"rp_formspec:field"`: A small page containing a single text input field and a button “Write” (the text field ID is `"text"`)

Especially the first two are very useful for many pages. You can call `rp_formspec.get_page`
to get one of these and use the returned formspec string as a basis to add more elements
and register the result as a new page.

`rp_formspec:field` is useful for writable signs.



### `rp_formspec.register_page(name, form)`

Registers a page with the identifier `name` and formspec string `form`.
`form` must follow the following rules:

* Contains the `size[]` element
* Contains `rp_formspec.default.boilerplate` right after `size[]`


### `rp_formspec.get_page(name, with_invtabs)`

Returns the formspec string of the page by name `name`.
If the page does not exist, `""` is returned.

* `name`: Identifier
* `with_invtabs`: (optional) If true, invtabs (see below) will be attached to the page (default: false)
  This works for the built-in pages `rp_formspec_default` and
  `rp_formspec:2part`. Other pages are only guaranteed to work if they have
  the exact same size as these.



### `rp_formspec.registered_pages`

Table which lists all registered pages.

* Key: Page name
* Value: Formspec string of the page

Use `rp_formspec.get_page` to access a specific page! Read-only!



## Invpages and invtabs

“Invpages” is short for “inventory pages”. These are pages for the player inventory
menu that can be changed by the player with the little tab buttons (the “invtabs”).
An invpage is always based on a regular page, but it adds functionality specific
to the player inventory menu.

Invtabs are *not* automatically registered with an invpage, they must be
registered separately (if desired).

The player always has an “current invpage”, i.e. an invpage that is
currently active. The current invpage can be changed by the player with the
invtabs (if they exist), but it can also be changed with `rp_formspec.set_current_invpage`.

There is a built-in invpage called `rp_formspec:inventory` which only contains
the player inventory. This page is used as a fallback when no other invpage was
registered.

### `rp_formspec.register_invpage(name, def)`

Registers an invpage and associates it with a regular page.
This function **must** be called after a regular page of the same `name` was registered.
The regular page then *becomes* an invpage by doing this.

* `name`: Identifier for the invpage
* `def`: Definition table with these optional fields:
   * `get_formspec(player_name)`: (optional): This function gets called when the player
     with name `player_name` changes their current invpage to this one. It must
     return the full formspec string for this invpage. Hint: Call
     `rp_formspec.get_page(name, true)` for the static part, then append the
     dynamic part to that.
     If this function is not called, the formspec of the associated regular page is used.



### `rp_formspec.set_current_invpage(player, invpage)`

Set the current invpage of `player` to the invpage with the name `page`.
If the player is already at this invpage, the invpage is refreshed.



### `rp_formspec.get_current_invpage(player)`

Returns the name of the current invpage of `player`.



### `rp_formspec.refresh_invpage(player, invpage)`

Regenerates the formspec for the `invpage` of player.
Call this whenever you need to report to `rp_formspec`
the formspec of an invpage had some changes (i.e. new
elements).
For example, on an achievements page, when the list
of achievments has changed.

Note: The invpage is automatically rebuilt when the current
invpage is selected manually.


### `rp_formspec.register_invtab(name, def)`

Registers an invtab and associates it with an invpage.
`name` must be the name of an invpage that already exists.

* `name`: Identifier for the invtab/invpage
* `def`: Definition table with these fields:
    * `icon`: Tab icon
    * `tooltip`: Tooltip when hovering the tab

Note: It is allowed to register an invpage without an invtab.
In that case, it can only be reached by a function call.



### `rp_formspec.set_invtab_order(order)`

Overrides the order in which the invtabs are shown, starting
with the top tab.

* `order`: List of invtab IDs to order.

`order` can contain unknown invtab IDs, they will be ignored.
Any invtab not listed in `order` will be added at the end
in a non-predictable order.

If this function is called multiple times, the last
time this function is called is the one that actually
takes effect. If you want to override the order set
by another mod, depend on this mod first.



### `rp_formspec.registered_invpages`

Table which lists all registered invpages.

* Key: Invpage name
* Value: Definition table

Read-only!


### `rp_formspec.registered_invtabs`

Table which lists all registered invtabs.

* Key: Invtab name
* Value: Definition table

Read-only!



## Formspec element functions

These functions are helper functions to generate a special formspec element.
Each of these return a string that can be inserted into a formspec string.

Some rules:

* Inventory lists should be accompanied with one of the “itemslot” functions.
* For buttons, use one of the “button” functions.
* For item images, use one of the item functions.
* “tabs” attach to the left and right side.

### `rp_formspec.get_itemslot_bg(x, y, w, h, count)`

Adds a 2D grid of background images for the background of
“normal” item slots. This needs to be used in combination
with `list[]` and the like; as `list[]` alone does *not*
add the item slot images.

* `x`, `y`: Top left position of the grid
* `w`: Width of the grid, number of slots horizontally
* `h`: Height of the grid; number of slots vertically
* `count`: (optional) Limit the number of slots by `count`

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
* `w`: Button width. Only 1, 2 and 3 are supported.
* `h`: Button height. 1 gives the best results; other heights can cause stretching
* `name`: Internal identifier
* `label`: Same as for `button[]` formspec element
* `noclip`: Unused legacy argument
* `tooltip`: Tooltip (optional)

Note the button will includes a bit of margin and is a bit smaller
than the given width, so the clickable button area is a little bit
larger than the visible button. Press F5 in the formspec to
reveal the clickable area.

### `rp_formspec.button_exit(x, y, w, h, name, label, noclip, tooltip)`

Same as `rp_formspec.button`, but when this button is pressed,
the formspec is closed.



### `rp_formspec.image_button(x, y, w, h, name, image, tooltip)`

Adds a button with an image. When the button is pressed,
the formspec is not closed.

* `x`, `y`: Position
* `w`: Button width. 1, 2 and 3 are fully supported, other widths might be weirdly stretched
* `h`: Button height
* `name`: Internal identifier
* `image`: Same as for `image_button[]` formspec element
* `noclip`: Same as for `image_button[]` formspec element
* `tooltip`: Tooltip (optional)



### `rp_formspec.tab(x, y, name, icon, tooltip, side)`

A sideways tab that is either at the left or right side.
(Note: Internally, this is a button.)

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



## Other features

### `rp_formspec.default.boilerplate`

A formspec string that **must** be added to every inventory page
right after the `size[]` element.
It contains a `no_prepend[]` and other information required for
Repixture formspecs to work.



### `rp_formspec.default.player_inventory`

A formspec string that contains the player inventory as well
as its default position.
Useful to create pages that want to include the player
inventory.



### `rp_formspec.default.version`

A formspec string that contains the current `formspec_version[]`
element used by `rp_formspec`.



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



## Legacy

### `rp_formspec.default.bg`

Legacy string formspec containing info about the formspec background.
As this is no longer needed, this contains the empty string.
You can safely remove it from scripts.


