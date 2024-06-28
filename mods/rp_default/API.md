## Functions

### `default.is_sapling_growing(pos)`

Returns true if node at pos is a sapling and
the sapling growth timer is activated.

### `default.begin_growing_sapling(pos)`
Start the sapling grow timer of the sapling at pos.
Returns true on success or false if it was not a sapling.

### `default.grow_sapling(pos)`
If there's a sapling node at `pos`, will grow it into
a tree instantly, if it has enough space.
Returns true on success.

### `default.toggle_fence_gate(pos)`
If there's a fence gate node at `pos`,
it will be opened when it's closed, or
it will be closed when it's opened.

Returns true on success.

## Functions for builtin biomes

This mod adds all the core biomes for this game. There are some helper functions
to get some information related to the core biomes. Note that the
following functions only work for the biomes from this mod, not for 
other biomes.

### `default.get_core_biomes()`
Returns a list of names with all builtin biomes.

### `default.get_main_biomes()`
Returns a list of names with all main layer biomes registered for this game.
This means, there will be no sub-biomes like underwater or beach biomes.

### `default.set_biome_info`
For internal use of this mod only.

### `default.get_biome_info(biomename)`
Returns metadata for a builtin biome. Returns a table with these fields:

* `main_biome`: Name of the main biome (useful if you have an underwater or beach biome variant)
* `layer`: "main" for the core biome, "underwater" and "beach" for the special Underwater and Beach variants
* `class`: Biome class. A rough categorization of this biome. One of:
  `"grassy"`, `"savannic"`, `"drylandic"`, `"swampy"`, `"desertic"`, `"undergroundy"`
* `is_dry`: True if biome is considered dry (e.g. for dry grass)
* `dirt_blob`: Name of dirt ore node or nil to suppress generation
* `sand_blob`: Name of sand ore node or nil to suppress generation
* `gravel_blob`: Name of gravel ore node or nil to suppress generation

Note: `dirt_blob`, `sand_blob` and `gravel_blob` are used to create ores after all builtin
biomes were created. These fields are useless for biomes from
external mods.

### `default.is_dry_biome(biomename)`
Returns true if the given biome is considered to be
a 'dry' biome (e.g. for dry grass). Custom or unknown
biomes are never dry.


