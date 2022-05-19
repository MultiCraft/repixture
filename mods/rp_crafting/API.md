# API for `rp_crafting`

This is the API documentation for `rp_crafting`. This describes
how new crafting recipes are added in Lua.

The main function to use is `crafting.register_craft`.

## Function reference
### `crafting.register_craft(def)`

Registers a crafting recipe. 
`def` is a definition table with these fields:

* `output`: Itemstring of the output item
* `items`: List of itemstrings that act as input. Inputs allow
   groups with the `group:<groupname>` syntax.

All crafting recipes have to follow some rules:
* There can only be one output itemstack per recipe
* No more than `crafting.MAX_INPUTS` input itemstacks (see `api.lua`)
* There can't be two recipes with the exact same output (e.g. itemname + count)
* All of the specified items must have been registered before
  registering the recipe.

### `crafting.register_on_craft(func)`

Registers a callback function `func(output, player)`
This function is called whenever `player` crafts something
leading to `output`.

Note this function is called multiple times for crafting the same thing
multiple times.

### Other functions

You might notice there are other functions in this mod, but they are
not part of the official API and should not be used outside this mod.

## `crafting.registered_crafts`

This is a table which contains all registered crafting recipes. It is indexed
by the output itemstring and the values are tables with this field:

* `items`: List of input items (same as `crafting.register_craft`)
