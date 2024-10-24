# Mobs API for Repixture

## About

This mod allows the creation of mobs. Mobs are moving creatures that players can
interact with. This includes animals and monsters.

It was created for Repixture from scratch to bring some life to the game.
It does not contain any mobs itself, but only the technical framework for it.

## Features

* Introduces a 'task queue' system allowing mobs to do stuff in sequence and in parallel
* Resembles player properties: health, fall damage, node damage, drowning and more
* Feeding, taming and breeding (for animals)
* Child mobs
* Lasso and net to capture mobs as item
* Built-in minimal death effect
* Flexible modular design so mobs only use the features they need; almost everything is optional
* Behavior templates for commonly-used primitive behaviors

## Priorities

There are many mob mods for Luanti, but Repixture has its own brand-new mob API
specifically created for Repixture. The priorities of the Repixture Mobs API are:

* Flexibility: The API should not restrict what mobs can do
* Performance: Inefficient algorithms are avoided like the plague
* Useful functions: The API offers enough built-in functions so developers don't
  have to start from zero for every mob
* Repixture-centered: Mod is tailored towards Repixture

## For developers

See API.md for the API documentation for developers.

## Credits and licensing

Media file license: CC BY-SA 4.0
* mobs_capture_succeed.ogg: by Wuzzy, CC0
* mobs_lasso_swing.ogg: by CrossCut Games, CC0
* mobs_swing.ogg: by CrossCut Games, CC0
* mobs_lasso_swing_hit_hit.ogg: CC0
* mobs_lasso_swing_hit_swing.ogg: CC0
* mobs_swing_hit_hit.ogg: CC0
* mobs_swing_hit_swing.ogg: CC0

Source code license: LGPLv2.1 or later
