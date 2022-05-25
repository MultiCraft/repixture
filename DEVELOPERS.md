# Developer information

This file explains information to document the code of Repixture and information for people
wanting to develop or mod Repixture.

Note the focus of Repixture is not to be a "base for modding", but to be a standalone
game in its own right. That having said, Repixture also doesn't actively oppose
modding.

## Some modding rules

* Crafting recipes (except cooking and fuel recipes) **MUST**
  be registered through `rp_crafting`.
* Modifying player physics (like running speed)
  **MUST** be done via `rp_player_effects`.

## Mod APIs

Some mods provide APIs to interact with. Check out the respective mod directories for a
file named `API.md`.

Mods with documented APIs:

* `rp_achievements`: Add and trigger achievements
* `rp_bed`: Get, set and unset (re)spwan position
* `rp_crafting`: Add crafting recipes
* `rp_default`: Sapling helpers, biome information
* `rp_door`: Add doors
* `rp_hunger`: Get and set hunger
* `rp_player_effects`: Add player effects (required if you want to modify player physics)
* `tt`: Custom tooltips

Beware: Calling functions that are not documented are NOT guaranted to be stable
in future versions, so use them with care.

## Groups

A reference of all groups used in this game can be found in `DEV_GROUPS.md`.
