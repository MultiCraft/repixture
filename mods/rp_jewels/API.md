# API for `rp_jewels`

You can register jeweled tools here. A jeweled tool is a tool that is a variant
from another tool. Jeweled tools must always be based on another tool.
It is allowed to register a jeweled tool that is already jeweled.
It is also possible to register multiple jeweled tools that are based
on the same original tool. In that case, the jeweler’s workbench will
pick a random jeweled tool.

Internally, jeweled tools are always distinct items with their own itemname.
So if the player jewels their tool on the jeweler’s workbench, they technically
get a different item back.

## Function reference

This is the only function:

### `jewels.register_jewel(toolname, new_toolname, def)`

Registers a jeweled tool.

Arguments:

* `toolname`: Itemname of the original tool to base the jeweled tool on.
* `new_toolname`: Itemname of the new jeweled tool
* `def`: Definition table of the jeweled tool. Fields:
    * `overlay`: Texture to overlay on the tool texture. Check out
                 the textures directory of this mod for some default
                 overlay textures, or create your own.
                 (default overlay: `"jewels_jeweled_handle.png"`)
    * `overlay_wield`: Optional texture to overlay on the tool’s wield image.
                       Use this is the wield image must differ from
                       the inventory image.
                       (default: Same as `overlay`)
    * `description`: Item description. Don’t use more than 1 line.
    * `stats`: Tool stats table. These say how the jeweled tool differs
               from the original’s `tool_capabilities`. All numbers
               are added to the original value. Both positive and
               negative values are supported. Table fields:
        * `digspeed`: Added to tool’s dig time (higher value = slower)
        * `maxlevel`: `maxlevel` modifier (higher = higher maxlevel)
        * `maxdrop`: `max_drop_level` modifier (higher = higher `max_drop_level`)
        * `uses`: Modifies number of uses (higher = more uses)
        * `fleshy`: Punch damage modifier (higher = more damage)
        * `range`: Pointing range modifier (higher = higher range)

#### Tool naming convention

You should always set a custom `description` for the jeweled tool.

For the `description`, most jeweled tools in this mod use a description
of the form “[adjective] Jewel [orignal tool name]”, with the adjective
describing what is special about this tool.

Example: “Swift Jewel Bronze Pickaxe” is a jeweled bronze pickaxe
that digs faster than the original.

The following adjectives are commonly used:

* “Swift”: lower dig speed
* “Harming”: more damage
* “Durable”: more uses
* “Ranged”: higher range

This is a simple yet effective naming scheme to create unique names
large number of jeweled tools.

You might want to follow this convention for your own jeweled tools
to keep consistency, but this is just a guideline; you can always
choose names however you like.



## Registration tables

Registered jeweled tools are stored in read-only lookup tables, indexed by itemstring:

* `jewels.registered_jewels`: Indexed by the itemstring of jeweled tool, contains the
    definition tables as provided in `jewels.register_jewel`
* `jewels.registered_jewel_defs`: Indexed by original tool itemstrings. The
    value is a list of jeweled tool definitions for tools that you could get
    when jeweling this tool
* `jewels.registered_jewel_parents`: Indxed by jeweled tool itemstrings, the value
    for each key is a table containing info about the “parent” (i.e. original)
    tool that the jeweled tool is based on. Each value is a table with the
    fields `name` (=itemstring) and `stats` (same as in `jewels.register_jewel`)

