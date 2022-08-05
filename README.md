# Repixture

Repixture is a sandbox survival crafting game focusing on low-tech and
unique graphics and sounds.

This is a revival of Pixture 0.1.1, a game for Minetest 0.4.

## Version
3.4.1

Designed for use with Minetest 5.6.0 or later.

## Features

* Animals and monsters
* Villages and trading
* Upgradable tools via jeweling
* Hunger
* Custom inventories
* Armor
* Simplified crafting with crafting guide
* A variety of trees
* Weather
* Beds (skip the night)
* New and better player models
* Change your player appearance
* Achievements
* Multi-language support
* Creative Mode

## Project Notes

Repixture works for Minetest 5.0.0. It's a fork of Pixture 0.1.1.
The goal of Repixture is to make Pixture work properly in
latest Minetest versions and to fix bugs and improve usability.
The original gameplay of Pixture will be (mostly) preserved,
the focus lies on bugfixes and usability features.
There will be no major changes to gameplay.

## Compability notes
### Using old biomes from before version 3.0.0
Since Repixture 3.0.0, the game uses a completely revamped biome
system. If you have a world that was created in an earlier
version and start it now, there will be biome discontinuities in
newly generated parts of the map, e.g. a Wasteland biome might
border in a straignt line to Grassland. This is not a bug, but
might look a bit strange.

If you want to prevent this, you can manually edit the world file
BEFORE starting Repixture.
Edit `map_meta.txt` in a text editor and add the line
`rp_biome_version = 1`.

## Credits

Repixture was started by Wuzzy. It's a fork of Pixture.

Pixture is Copyright (C) 2015-2017 [Kaadmy](https://github.com/kaadmy).

Pixture was inspired by [Kenney](http://kenney.nl)

### Core developers

* Wuzzy: Core development of Repixture
* Kaadmy: Core development of Pixture 2015-2017

### Textures

* Sounds in the `rp_default` mod are all by Kenney (CC0)
* All textures/models by Kaadmy, with some additions/changes by Wuzzy (CC BY-SA 4.0)
   * Exception: Seagrass by jp (CC0)

### Special thanks

* [Kenney](http://kenney.nl) for the inspiration, most of the aesthetic.

## Licenses

This game is free software, licensed 100% under free software licenses.

See *LICENSE.txt* or the links below for the full license texts.

- Media files: all licensed under CC BY-SA 4.0 or CC0, with one exception:
    - The exception: Sounds in the `rp_weather` mod are under GPLv2 (these sounds should be replaced later)
    - See per-mod READMEs for details
- Source code: all licensed under LGPLv2.1 (or later versions of the LGPL), or MIT License, see per-mod READMEs.

Links:
- CC BY-SA 4.0: <https://creativecommons.org/licenses/by-sa/4.0>
- CC0: <https://creativecommons.org/publicdomain/zero/1.0>
- GPLv2: <https://www.gnu.org/licenses/old-licenses/gpl-2.0>
- LGPLv2.1: <https://www.gnu.org/licenses/old-licenses/lgpl-2.1>
- MIT License: <https://mit-license.org/>
