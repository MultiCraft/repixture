# API documentation for `rp_achievements`

## Introduction

Each achievement must have an unique `name` which is the internal identifier.
Achievements can get triggered manually with `achievements.trigger_achievement`,
or automatically. Achievements get awarded when they have been triggered
enough, as specified by `times` in the achievements definition.

## Functions

### `achievements.register_achievement(name, def)`

Registers an achievement.

* `name`: Achievement identifier (no translation allowed!)
* `def`: Achievement definition. This is a table:
    * `title`: Title, as shown to the player (default: same as `name`)
    * `description`: Short (!) description that tells the player what to do to get the achievement
    * `times`: How many times to trigger this achievement before awarding it (default: 1)
    * `dignode`: Trigger achievement when this node has been dug
    * `placenode`: Trigger achievement when this node has been placed
    * `craftitem`: Trigger achievement when this item has been crafted (needs to match
      crafting output identifier as provided to the `rp_crafting` mod)
    * `icon`: Optional icon (texture name)
    * `item_icon`: Optional icon (texture name)

Both `dignode` and `placenode` support the `group:<groupname>` syntax to check
for digging/placing a node in a given group instead.

If neither `dignode`, `placenode`, nor `craftitem` are present, the achievement
will not be triggered automatically. You can always trigger an achievement
manually with `achievements.trigger_achievement`.

If neither `icon` nor `item_icon` are present, this mod will pick an icon automatically
by using the item icon of `dignode`, `placenode` or `craftitem`. If those fields
are not present, or use groups, a generic trophy icon will be used instead.

Note: Any item specified in `def` *must* have been registered before registering
the achievement.

### `achievements.trigger_achievement(player, name, times)`

Manually trigger an achievement once or multiple times.

* `name`: Achievement identifier
* `player`: Player to trigger the achievement for
* `times`: How many times to trigger the achievement (default: 1)
