# Developer information

This file explains information to document the code of Repixture and information for people
wanting to develop or mod Repixture.

Note the focus of Repixture is not to be a "base for modding", but to be a standalone
game in its own right. That having said, Repixture also doesn't actively oppose
modding.

## Core development

### Testing

There are some hidden testing/debug settings. Add them into `minetest.conf` to activate:

* `rp_testing_enable=true`: Enables Testing Mode. Performs some simple benchmarks on startup
  (See the log file / console) and also enables testing the validity of crafting
  recipes, gold trades, and more (printing errors if any errors were found).
  This also enables a few helper chat commands (see `/help`).
* `hunger_debug=true`: Enables Hunger Debug. This displays the internal hunger values on
  the screen.

To disable the settings, set them to `false` again.

## Some modding rules

* Crafting recipes (except cooking and fuel recipes) **MUST**
  be registered through `rp_crafting`.
* Modifying player physics (like running speed)
  **MUST** be done via `rp_player_effects`.
  Calling `set_physics_override` directly is **FORBIDDEN**.

## Mod APIs

Some mods provide APIs to interact with. Check out the respective mod directories for a
file named `API.md`.

Mods with documented APIs:

* `rp_armor`: Armor information
* `rp_achievements`: Add and trigger achievements
* `rp_bed`: Get, set and unset (re)spawn position
* `rp_crafting`: Add crafting recipes
* `rp_default`: Sapling helpers, biome information
* `rp_door`: Add doors
* `rp_drop_items_on_die`: You only need this mod if you added an inventory list to the player
                          and you want its contents to be dropped on death.
* `rp_farming`: Add farmable plants
* `rp_formspec`: Build formspecs and inventory pages
* `rp_goodies`: Fill container nodes with random loot
* `rp_hunger`: Get and set hunger
* `rp_item_drop`: Add a function to simulate an item drop
* `rp_itemshow`: Needed when your item needs a custom appearance in the item frame / item showcase
* `rp_jewels`: Register jeweled tools, and more
* `rp_localize`: Localize numbers
* `rp_locks`: Get info about lockable nodes
* `rp_partialblocks`: Register partial blocks (slabs, stairs)
* `rp_player`: Player model handling, model animation, textures
* `rp_player_effects`: Add player effects (required if you want to modify player physics)
* `rp_sounds`: Node sounds
* `rp_util`: Helper functions for Repixture
* `rp_tnt`: Ignite and blow up TNT, also spawn TNT-less explosions
* `rp_wielditem`: Custom rotation of item in hand in 3rd person view (in case it looks awkward)
* `tt`: Custom tooltips

Beware: Calling functions that are not documented are NOT guaranted to be stable
in future versions, so use them with care.

## Groups

A reference of all groups used in this game can be found in `DEV_GROUPS.md`.

## Player Manual

The source files for the player manual are contained in `manual_generator`.
The actual manual is generated from these files.
See the README.md file inside this directory for details.
