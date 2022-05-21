# Group reference

This file is developer documentation that documents all the non-special groups (i.e. not special according to
`lua_api.txt`) used in this game.

## Item groups

This is the list of all groups used for items. Note: If no number/rating is specified, use 1 as rating.

## Interactive item groups
* `not_in_creative_inventory`: Item won't show up in Creative Inventory
* `not_in_craft_guide`: Item won't show up in crafting guide
* `no_item_drop`: This item can't exist as a dropped item on the ground. When dropping it, it is deleted instantly
* `immortal_item`: In entity form, this item withstands damage and won't be destroyed by nodes that deal damage

### Tools
* `axe`: Axe
* `shears`: Shears
* `shovel`: Shovel
* `sword`: Sword
* `spear`: Spear
* `supertool`: Super tool, i.e. a powerful tool for Creative Mode use only
* `sheep_cuts`: For shears. Rating specifies how often it can shear sheep

## Armor
* `is_armor`: Item is an armor piece
* `armor`: Item is an armor piece and rating specifies armor percentage
* `armor_material`: Rating specifies armor material; number is assigned dynamically. Equal number means equal material.
* `armor_slot`: Rating says which slot the armor piece belongs to: 1 = Helmet, 2 = Chestplate, 3 = Boots

### Other item categorizations
* `stick`: Stick
* `bucket`: Any bucket
* `bucket_water`: Bucket with water
* `food`: Can be eaten by player. Rating: 2 = eatable, 3 = drinkable, 1 = unknown food type
* `nav_compass`: Compass. Rating: 1 = normal compass, 2 = magnocompass
* `spawn_egg`: Item that spawns mobs



## Node groups

This is the list of all groups used for nodes. Note: If no number/rating is specified, use 1 as rating.

### Digging groups
* `choppy`: Can be dug by brute force, like wood
* `cracky`: Hard material like stone
* `crumbly`: Soft material like dirt
* `snappy`: Can be dug with fine tools like shears
* `fleshy`: Node represents some kind of (semi-)living organism, so it can be "dug" easily by weapons
* `handy`: Can be dug with bare hand
* `oddly_breakable_by_hand`: Can be dug with bare hand, but for nodes where it seems unrealistic

### Interactive node groups:
* `soil`: For blocks that allow several plants to grow
* `leafdecay`: Node decays if not close to a `tree` group node (max. distance = rating).
               Decaying will destroy the node and release the item drop except dropping itself.
* `leafdecay_drop`: Must be used in combination with `leafdecay`.
                    Decaying will release the item drop, and it can even drop itself.
* `magnetic`: Node is magnetic and can magnetize stuff (like compass)
* `unmagnetic`: Node is "unmagnetic", this means it can de-magnetize stuff
* `locked`: Node is considered to be locked

### Node categorization

* `dirt`: Any dirt (with or without cover)
* `normal_dirt`: Any "normal" common dirt found in most temperate biomes (i.e. not swamp dirt or dry dirt) (with or without cover)
* `dry_dirt`: Any dry dirt (with or without cover)
* `swamp_dirt`: Any swamp dirt (with or without cover)
* `grass_cover`: This node is covered with grass

* `grass`: Any grass clump
* `green_grass`: Any grass clump that is lush (“green”)
* `normal_grass`: "Normal" grass clump
* `dry_grass`: Dry grass clump
* `swamp_grass`: Swamp grass clump

* `plant`: Any node that is a plant
* `farming_plant`: Any plant used for farming
* `plant_cotton`: Cotton plant (rating = growth stage)
* `plant_wheat`: Wheat plant (rating = growth stage)
* `sapling`: Sapling
* `fern`: Fern
* `flower`: Flower
* `seed`: Seed

* `leaves`: Any leaves
* `dry_leaves`: Dry leaves
* `lush_leaves`: Any non-dry leaves

* `plantable_dry`: You can plant farming plants on it and this node is considered to be dry
* `plantable_sandy`: You can plant farming plants on it and this node is considered to be made out of sand
* `plantable_soil`: You can plant farming plants on it and this node is considered to be "normal" soil
* `plantable_fertilizer`: This node is fertilized

#### Shaped

* `slab`: Slab
* `stair`: Stair
* `path`: A path node like the Dirt Path
* `door`: Any door
* `door_wood`: Wooden door
* `fence`: Fence
* `sign`: Sign
* `bed`: Bed segment
* `torch`: Torch

### Node material groups (used for full nodes only):

* `planks`: Wooden planks
* `wood`: Made out of wood
* `tree`: Tree trunks
* `stone`: Stone
* `sand`: Sand
* `sandstone`: Sandstone
* `glass`: Glass
* `fuzzy`: Wool, cotton bale, etc.

### Liquids
* `liquid`: Any liquid
* `water`: Any water
* `flowing_water`: Flowing water
* `river_water`: Any river water
* `swamp_water`: Any swamp water

### Unused node groups

* `flammable`



## Damage groups

This is the list of damage groups.

* `fleshy`: This is the damage group used for everything that takes damage.
