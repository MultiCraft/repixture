# Goodies API

The API allows you to fill nodes that have an inventory with random items.

## Functions

### `goodies.fill(pos, ctype, pr, listname, keepchance)`

First, decides to either remove or keep the node at `pos`
by random chance. If the node is kept, it will be filled with
random treasure. The target node must have an inventory
for this to work.

If the node has the meta key `locked` is a number > 0,
the goodies are more valuable.

Parameters:

* `pos`: Position of the node
* `ctype`: A identifier for the type of treasuer to use.
           See “Available treasure types” below.
* `pr`: A PseudoRandom object used for pseudo-randomness
* `listname`: Name of the inventory list to put items into
* `keepchance`: Chance the node will be kept (i.e. not removed),
                stated in `1/keepchance`. If 1, node is never removed.

How `keepchance` works: a virtual `keepchance`-sided dice with the numbers
from 1 to `keepchance` will be rolled.
If a 1 is rolled, the node is kept, otherwise the node is removed.

Note: If the container node is below a falling node and has been selected
for removal, it will be replaced by a copy of the falling node or
wooden planks in order to prevent the falling node to float.

## Available treasure types

These are the possible goodie types, usable for the `ctype` argument above:

* `"FURNACE_SRC"`: Source slot of furnace
* `"FURNACE_FUEL"`: Fuel slot of furnace
* `"FURNACE_DST"` Output slot of furnace
* `"forge"`: Forge building
* `"tavern"`: Tavern building
* `"house"`: Dwelling house

In the source code, you can find the definitions in `goodies.types`.
