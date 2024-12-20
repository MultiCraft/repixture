# Developer information

This file explains information to document the code of Repixture and information for people
wanting to develop or mod Repixture.

Note the focus of Repixture is not to be a “base for modding”, but to be a standalone
game in its own right. That having said, Repixture also doesn’t actively oppose
modding.

## Translation

Repixture wants to be translated in many languages. As a translator, just go to
<https://translate.codeberg.org/projects/repixture/> and start contributing!
All you need is an account on Codeberg.org.

Usually, all translations will be included in the next release.

From the developer’s point of view, maintaining the translations requires some extra
work. See `DEV_TRANSLATION_WORKFLOW.md` for details.

## Testing

There are some hidden testing/debug settings. Add them into `minetest.conf` to activate:

* `rp_testing_enable=true`: Enables Testing Mode. Performs some simple benchmarks on startup
  (See the log file / console) and also enables testing the validity of crafting
  recipes, gold trades, and more (printing errors if any errors were found).
  This also enables a few helper chat commands (see `/help`).
* `hunger_debug=true`: Enables Hunger Debug. This displays the internal hunger values on
  the screen.

To disable the settings, set them to `false` again.

## Some modding rules

There are some simple but important rules when it comes to coding or modding for Repixture.
They must be followed at all times:

* Crafting recipes (except cooking and fuel recipes) **MUST** be registered through `rp_crafting`.
* Modifying player physics (like running speed) **MUST** be done via `rp_player_effects`.
  Calling `set_physics_override` directly is **FORBIDDEN**.
* If you attach or detach the player, you **MUST** update `rp_player.player_attached`.
* Modifying HUD flags (like `"wielditem"`) **MUST** be done via `rp_hud`.
  Calling `hud_set_flags` directly is **FORBIDDEN**.
* Changing the sky (`set_sky`, `set_sun`, `set_moon`, `set_clouds`, `set_stars`)
  outside of the `rp_sky` mod is **FORBIDDEN**.

## Mod APIs

Some mods provide APIs to interact with. Check out the respective mod directories for a
file named `API.md`.

Mods with documented APIs:

* `player_api`: Player model handling, model animation, textures (see also `rp_player`)
* `rp_armor`: Armor information and registration
* `rp_achievements`: Add and trigger achievements
* `rp_bed`: Get, set and unset (re)spawn position; query bed info
* `rp_crafting`: Add crafting recipes
* `rp_death_messages`: Customize death messages
* `rp_default`: Sapling helpers, biome information
* `rp_door`: Add doors
* `rp_drop_items_on_die`: You only need this mod if you added an inventory list to the player
                          and you want its contents to be dropped on death.
* `rp_farming`: Add farmable plants
* `rp_formspec`: Build formspecs and inventory pages
* `rp_goodies`: Fill container nodes with random loot
* `rp_hud`: Allow and forbid HUD flags here
* `rp_hunger`: Get and set hunger
* `rp_item_drop`: Add a function to simulate an item drop
* `rp_itemshow`: Needed when your item needs a custom appearance in the item frame / item showcase
* `rp_jewels`: Register jeweled tools, and more
* `rp_localize`: Localize numbers
* `rp_locks`: Get info about lockable nodes
* `rp_mobs`: Add mobs (animals, monsters)
* `rp_moon`: Get moon phase
* `rp_music`: Add or remove tracks; start/stop/toggle a music player
* `rp_paint`: Add paintable nodes; set/remove paint of node
* `rp_partialblocks`: Register partial blocks (slabs, stairs)
* `rp_pathfinder`: Advanced pathfinding
* `rp_player`: Same as `player_api`, but with extra features specific to Repixture. Only use this if
               you need those extra features or for internal Repixture development.
               Otherwise, use `player_api`.
* `rp_player_effects`: Add player effects (required if you want to modify player physics)
* `rp_sounds`: Node sounds
* `rp_spyglass`: Spyglass
* `rp_util`: Helper functions for Repixture
* `rp_tnt`: Ignite and blow up TNT, also spawn TNT-less explosions
* `rp_wielditem`: Custom rotation of item in hand in 3rd person view (in case it looks awkward)
* `tt`: Custom tooltips

Beware: Calling functions that are declared experimental, or not documented
are NOT guaranteed to be stable in future versions, so use them with care.

## Groups

A reference of all groups used in this game can be found in `DEV_GROUPS.md`.

## Player Manual

The source files for the player manual are contained in `manual_generator`.
The actual manual is generated from these files.
See the README.md file inside this directory for details.
