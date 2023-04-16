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
* If `_rp_canonical_item` is set in the item definition, this item (itemname) will
  be used for the entity instead when it spawns. Useful when an item has multiple
  variants ike a compass

## Licensing
Credits: Originally by Minetest developers (from the `builtin` part of Minetest)
with tweaks by Kaadmy and Wuzzy.

Source code license: LGPLv2.1
Sound license: CC BY-SA 4.0
License of rp_builtin_item_die.png: LGPLv2.1 (same as smoke_puff.png from Minetest)
