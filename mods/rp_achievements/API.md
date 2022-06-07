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

* `name`: Achievement identifier (no translation allowed!)
* `def`: Achievement definition. This is a table:
    * `title`: Title, as shown to the player (default: same as `name`)
    * `description`: Short (!) description that tells the player what to do to get the achievement
      crafting output identifier as provided to the `rp_crafting` mod)
    * `icon`: Optional icon (texture name)
    * `item_icon`: Optional icon (texture name)
    * Additional fields depending on the type (see below)

If neither `icon` nor `item_icon` are present, this mod will pick an icon automatically
by using the item icon of `dignode`, `placenode` or `craftitem`. If those fields
are not present, or use groups, a generic trophy icon will be used instead.

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

