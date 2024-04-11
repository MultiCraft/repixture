# API documentation for `rp_achievements`

## Introduction

Each achievement must have an unique `name` which is the internal identifier.
There are two types of achievements:

Trigger achievements and subcondition achievements.

Trigger achievements count the number of times they are triggered.
They are completed when the threshold of triggers has been met (`times`
parameter). Trigger achievements can be triggered automatically
or manually.

Subcondition achievements have a list of subconditions that must all
be triggered to complete the achievement. These achievements can
only be triggered manually.

## Functions

### `achievements.register_achievement(name, def)`

Registers an achievement.

* `name`: Achievement identifier. A string that uniquely identifies the achievement
          for functions and the `/achievement` chat command.
          The identifier “all” is not allowed. Translation is not allowed.
* `def`: Achievement definition. This is a table:
    * `title`: Title, as shown to the player (default: same as `name`)
    * `description`: Short (!) description that tells the player what to do to get the achievement
      crafting output identifier as provided to the `rp_crafting` mod)
    * `icon`: Optional icon (texture name). Should be 32×32 pixels
    * `item_icon`: Optional icon (item name)
    * `difficulty`: Optional difficulty rating of achievement (see below)
    * Additional fields depending on the type (see below)

If neither `icon` nor `item_icon` are present, this mod will pick an icon automatically
by using the item icon of `dignode`, `placenode` or `craftitem`. If those fields
are not present, or use groups, a generic trophy icon will be used instead.

#### Difficulty rating

The difficulty rating is a number between 0 and 11 (floats allowed). Lower = easier.
“Difficulty” is not just about skill, but also about time needed, complexity, amount of grinding, luck, etc.
So try to take all that into account. The rating is used only for sorting the achievements list, so easy
or early-game achievements show up at the top.

Rating the difficulty is very subjective. To keep the ratings at least somewhat consistent, use a number
in relation to the 10 reference achievements, listed below:

* 1: Timber (early-game item, almost instantly to get)
* 2: My First Pickaxe (first meaningful craft)
* 3: Mineority (first stone)
* 4: Metal Age (first furnace smelting)
* 5: True Navigator (requires advanced materials)
* 6: Bronze Skin (late-game metal required)
* 7: Jeweler (requires rare item)
* 8: True Mighty Weapon (requires many rare items)
* 9: Secret of Jewels (tricky to figure out)
* 10: Explorer (long grind)

Examples:
If an achievement is about as easy as Timber, give it a 1.
If it is easier, give it a number lower than 1.
If it is easier than Bronze Skin, but harder than True Navigator, give it a value between 5 and 6.

#### Trigger achievements

For trigger achievements, use these additional fields for `def`:

* `times`: How many times to trigger this achievement before awarding it (default: 1)
* `dignode`: Trigger achievement when this node has been dug
* `placenode`: Trigger achievement when this node has been placed
* `craftitem`: Trigger achievement when this item has been crafted

Both `dignode` and `placenode` support the `group:<groupname>` syntax to check
for digging/placing a node in a given group instead.

If neither `dignode`, `placenode`, nor `craftitem` are present, the achievement
will not be triggered automatically. You can always trigger an achievement
manually with `achievements.trigger_achievement`.

A trigger achievement must be triggered `times` times to be completed.

Note: Any item specified here **must** have been registered *before* registering
the achievement.

#### Subcondition achievements

For subconditoin achievements, use this additional field for `def`:

* `subconditions`: List of subcondition identifiers (as strings). Put all
  the required subconditions here. NOT translatable!
* `subconditions_readable`: Optional. List of subcondition names as shown
  to the player. The table keys must correspond with the keys in
  `subconditions`. If this field is missing, the GUI will use the IDs
  instead.

Use `achievements.trigger_subcondition` to mark a subcondition as complete.

### `achievements.trigger_achievement(player, name, times)`

Manually trigger an achievement once or multiple times.

* `player`: Player to trigger the achievement for
* `name`: Achievement identifier
* `times`: How many times to trigger the achievement (default: 1)

### `achievements.trigger_subcondition(player, name, subcondition)`

Mark a subcondition of an achievement as completed.

* `player`: Player to trigger the achievement subcondition for
* `name`: Achievement identifier
* `subcondition`: Identifier of subcondition to mark as complete

### `achievements.get_completion_status(player, name)`

Returns a player’s completion status for a  given achievement.
Possible return values:

* `achievements.ACHIEVEMENT_GOTTEN`: Achievement gotten
* `achievements.ACHIEVEMENT_IN_PROGRESS`: Not gotten, but at least one subcondition was met
* `achievements.ACHIEVEMENT_NOT_GOTTEN`: Not gotten, and no subconditions completedkb

Parameters:

* `player`: Player to check the achievement for
* `name`: Achievement identifier

### `achievements.register_subcondition_alias(name, old_subcondition_name, new_subcondition_name)`

Registers an alias for a subcondition identifier of an achievement. This essentially replaces
an old existing subcondition identifier with a new one.

Useful if for some reason you needed to change a subcondition identifier of an achievement
and still want to be backwards-compatible.

If you rename a subcondition without using an alias, then all players who have completed
that subcondition will lose it. By adding an alias, this allows players to still keep
it after an update.

Parameters:

* `name`: Achievement identifier
* `old_subcondition_name`: The old/legacy subcondition name you wish to replace
* `new_subcondition_name`: The new subcondition name you consider to be canonical now.

