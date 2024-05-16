Crafting mod
============
By Kaadmy and Wuzzy, for Repixture.

Custom crafting method, uses a list of possible items to craft instead of a grid
recipe. This mod provides an API for adding crafting recipes, see `API.md`.

This mod itself does *not* register any recipes itself, it is a mod for other
mods to rely on.

Like in typical Minetest, crafting recipes have a number of input items and a single
output item. It is similar to Minetest's shapeless recipes.
But unlike typical Minetest, it is possible to provide item stacks
in each item slot; the player doesn't have to spread out multiple items across
multiple input slots. E.g. if a crafting recipe needs 64 wool, then you don't
need 64 slots with 1 wool each, but only 1 slot with 64 wool.
Also, recipe collisions are *not* possible. It *is* possible for two recipes
with identical input items to co-exist as the player selects the recipe from a list.

This mod does not support other crafting methods like cooking or furnace fuels.

## License
Source code license: LGPLv2.1 or later
