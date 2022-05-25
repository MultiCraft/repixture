Repixture builtin item mod
==========================

Item entities for Repixture.

Adds the custom handling for item entities (dropped items) by overriding
`__builtin:item`. Item entities work similar to Minetest's builtin item entities.

Features:

* Basic physics (affected by gravity, collides)
* Supports the `item_entity_ttl` setting (auto-delete item after some time)
* Item magnet (player collects item automatically when close)
* Item is destroyed by lava, fire or nodes that deal damage with `damage_per_second`
* Notifies rp_nav when the map item was collected
* If the group `no_item_drop` is present in the item definition, or
  the item entity will be instantly deleted

## Licensing
Credits: Originally by PilzAdam (released under the name `builtin_item`),
then tweaked by Kaadmy for Pixture and then later Wuzzy for Repixture.

Source code license: LGPLv2.1
Media license: CC BY-SA 4.0
