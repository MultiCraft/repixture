# Group reference

This file is developer documentation that documents all the non-special groups (i.e. not special according to
`lua_api.txt`) used in this game.

## Item groups

This is the list of all groups used for items. Note: If no number/rating is specified, use 1 as rating.

## Interactive item groups
* `not_in_creative_inventory`: Item won't show up in Creative Inventory
* `not_in_craft_guide`: All recipes that have this item as output will be hidden from the
   crafting guide, even if the resources are in the input slots. The item can still be crafted
   when the crafting guide is disabled (assuming there's a recipe). Useful for items that are
   "secretly craftable" and for rather "technical" items that would pollute the crafting guide.
* `no_item_drop`: This item can't exist as a dropped item on the ground. When dropping it, it is deleted instantly
* `immortal_item`: In entity form, this item withstands damage and won't be destroyed by nodes with `destroys_items` group

## Creative categorization
These groups are mainly used for a better item sorting in Creative Mode.

* `node`: Add this group for items that are considered nodes *in a gameplay* sense.
          Rarely needed, use this for items that are technically not nodes themselves, but they behave like
          placable nodes from the player-point of view. Example: Door craftitems.
          Implied if it was registered with `minetest.register_node`.
* `tool`: Add this group for items that are considered tools *in a gameplay* sense.
          That’s an item that the player can use to perform a direct action, like digging, igniting blocks.
          Implied if item was registered with `minetest.register_tool`.
* `craftitems`: Add this group for items that are considered craftitems *in a gameplay* sense.
          That’s an item that is neither a node nor tool. Usually for items only used for crafting with
          no inherent direct use.
          Implied if it was registered with `minetest.register_craftitem`.

* `creative_decoblock`: Classifies nodes as "decorative node". This is for non-full cubes except slabs and stairs

### Tools
* `axe`: Axe
* `shears`: Shears
* `shovel`: Shovel
* `sword`: Sword
* `spear`: Spear
* `weapon`: Weapon (item that is *primarily* used for attacks)
* `supertool`: Super tool, i.e. a powerful tool for Creative Mode use only
* `sheep_cuts`: For shears. Rating specifies how often it can shear sheep
* `can_scrape`: Tool is capable of scraping off paint
    * `can_scrape=2`: ... with “punch” key
    * `can_scrape=3`: ... with “place” key
    * `can_scrape=1`: ... by some other or undefined method

## Armor
* `is_armor`: Item is an armor piece
* `armor`: Item is an armor piece and rating specifies armor percentage
* `armor_material`: Rating specifies armor material; number is assigned dynamically. Equal number means equal material.
* `armor_slot`: Rating says which slot the armor piece belongs to: 1 = Helmet, 2 = Chestplate, 3 = Boots

### Other item categorizations
* `stick`: Stick
* `bucket`: Any bucket
* `bucket_water`: Bucket with water
* `paint_bucket`: Paint bucket. Rating is paint level (1 = empty, 2-10: contains paint)
* `paint_bucket_not_full`: Paint bucket that isn’t full
* `food`: Can be eaten by player. Rating: 2 = eatable, 3 = drinkable, 1 = unknown food type
* `nav_compass`: Compass. Rating: 1 = normal compass, 2 = magnocompass
* `spawn_egg`: Item that spawns mobs
* `book`: Book. Rating: 1 = unspecific book, 2 = writable book
* `mineral_lump`: A lump of a mineral, like coal lump, iron lump, etc.
* `mineral_natural`: A mineral item that occurs naturally (NOT the ore!)
* `mineral_artificial`: A mineral item that does not occur naturally (e.g. bronze lump)
* `ingot`: Ingot
* `boat`: Boat



## Node groups

This is the list of all groups used for nodes. Note: If no number/rating is specified, use 1 as rating.

### Digging groups

These groups determine digging times:

* `choppy`: Can be dug by brute force, like wood
* `cracky`: Hard material like stone
* `crumbly`: Soft material like dirt
* `snappy`: Can be dug with fine tools like shears
* `fleshy`: Node represents some kind of (semi-)living organism, so it can be "dug" easily by weapons
* `handy`: Can be easily dug by the hand (fast)
* `oddly_breakable_by_hand`: Can be dug by the hand, but it's awkward (slow)

**NOTE**: If you use `handy` or `oddly_breakable_by_hand` in combination with
any of the other digging groups, make sure dig times of the weakest tool are
still faster than with the hand (test this in-game to make sure).
Also, never use `handy` and `oddly_breakable_by_hand` at the same time.

### Pathfinder groups

These groups very roughly categorize nodes for pathfinding. Specifically,
the cost function in the `rp_pathfinder` mod. The groups
are based on how the node would "feel" when you're barefoot.
The pathfinder can use the groups to use preferences for paths.
It’s not restricted to these groups, however, as the groups are intentionally
very broad.

It is recommended that every walkable node has at least one pathfinder
group. Non-walkable nodes don't need this.

* `pathfinder_crumbly`: Floor gives in (dirt, etc.)
* `pathfinder_fibrous`: Fiber- or plant-based floor (grass, leaves, ...)
* `pathfinder_spiky`: Somewhat spiky floor with sharp edges (cactus, gravel, ...)
* `pathfinder_thin`: Block has a very thin walking surface (door, ...)
* `pathfinder_hard`: Generic hard floor (stone, wood, ...)
* `pathfinder_soft`: Generic soft floor (sand, cotton, ...)

### Interactive node groups:
* `soil`: For blocks that allow several plants to grow
* `leafdecay`: Node decays if not close to a `tree` group node (max. distance = rating).
               Decaying will destroy the node and release the item drop except dropping itself.
* `leafdecay_drop`: Must be used in combination with `leafdecay`.
                    Decaying will release the item drop, and it can even drop itself.
* `magnetic`: Node is magnetic and can magnetize stuff (like compass)
* `unmagnetic`: Node is "unmagnetic", this means it can de-magnetize stuff
* `locked`: Node is considered to be locked
* `container`: Node has an inventory to store item(s)
* `react_on_rain`: Node does something when it rains; the `rp_weather` mod will call `_rp_on_rain(pos, node)` in random intervals
* `react_on_rain_hf`: Same as above, but callback is called with higher frequency
* `interactive_node`: Node can be interacted with (excluding pure container nodes)
* `no_spawn_allowed_on`: If set, players can not (initially) spawn on this block
* `spawn_allowed_in`: If set, players can spawn into this block (note: this group is ignored for the 'air' and 'ignore' nodes)
* `destroys_items`: If set, node will destroy any item that is inside this node (unless the item has `immortal_item` set)
* `armor_piercing`: Reduces armor effectiveness (in %) if node deals `damage_per_second` damage. See `rp_armor` for details.
* `uses_canonical_compass`: This is used for nodes that can carry a compass. If this group is set, the compass will be
                            added to the node in "canonical" form, i.e. the needle always faces upwards. Otherwise,
                            the compass needle is adjusted according to the node position and rotation (wallmounted/facedir).
* `special_magnocompass_node_handling=1`: Node will handle placing a magno compass in a special way (see `rp_nav`)
* `seed`: A farming item that can be planted on the ground to spawn a plant that will grow over time.
          Usually this is a seed, but it does not have to be.
* `paintable=1`: Node is paintable and is in “painted” state (see `rp_paint` for details)
* `paintable=2`: Node is paintable and is in “unpainted” state (see `rp_paint` for details)
* `_attached_node_top=1`: Node attaches to the top of another node or itself. If the node above disappears, the node itself detaches
* `_attached_node_bottom=1`: Node attaches to the bottom of another node or itself. If the node below disappears, the node itself detaches

#### Note about the `_attached_node_*` groups

These groups are a more specialized variant of the built-in `attached_node` group.

They are specifically designed for nodes that vertically stack and attach to each other, like vines or thistles.
The unique thing about these groups is that breaking the support of this node will cause a cascade.
Unlike `attached_node`, they also work if the node is not `walkable`. Use these groups when a standard
`attached_node` does not suffice.

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

* `plant`: Any node that is a plant (also for rooted plants)
* `rooted_plant`: Node is a plant/full block hybrid using `plantlike_rooted` drawtype
* `farming_plant`: Any plant used for farming
* `plant_cotton`: Cotton plant (rating = growth stage)
* `plant_wheat`: Wheat plant (rating = growth stage)
* `sapling`: Sapling
* `fern`: Fern
* `flower`: Flower
* `seagrass`: Seagrass
* `airweed`: Airweed
* `airweed_inert`: Airweed that is 'inert' (i.e. bubbles are not ready)
* `airweed_full`: Airweed that is 'full' (i.e. bubbles are ready)
* `alga`: Alga
* `clam`: Clam

* `leaves`: Any leaves
* `dry_leaves`: Dry leaves
* `lush_leaves`: Any non-dry leaves

* `furniture`: Any piece of furniture, including workstations (e.g.: bed, chest, furnace, jeweller's workbench)
* `item_showcase`: Item showcase
* `chest`: Chest (1=not locked, 2=with lock)
* `furnace`: Furnace (1=inactive, 2=active)

* `spikes`: Spikes

* `plantable_dry`: You can plant farming plants on it and this node is considered to be dry
* `plantable_wet`: You can plant farming plants on it and this node is considered to be wet
* `plantable_sandy`: You can plant farming plants on it and this node is considered to be made out of sand
* `plantable_soil`: You can plant farming plants on it and this node is considered to be "normal" soil
* `plantable_fertilizer`: This node is fertilized

#### Shaped

* `slab`: Slab (1 = normal slab, 2 = path slab)
* `stair`: Stair
* `path`: A path node like the Dirt Path (1 = normal path, 2 = path slab)
* `door`: Any door
* `door_wood`: Wooden door
* `door_state`: Door segment, internal state (1 or 2) (see `rp_door` mod)
* `door_position`: Door segment, position (1 = bottom, 2 = top)
* `fence`: Fence. Fence nodes MUST have a collisionbox height of 1.5
* `fence_gate`: Fence gate (1 = closed, 2 = open). Fence gate nodes MUST have a collisionbox height of 1.5
* `sign`: Sign
* `bed`: Bed segment
* `torch`: Torch

### Node material groups (used for full nodes only):

* `planks`: Wooden planks
* `wood`: Made out of wood
* `tree`: Tree trunks
* `stone`: Stone
* `ore`: Ore
* `sand`: Sand
* `gravel`: Gravel
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
