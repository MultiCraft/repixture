# luabidi

Lua implementation of the Unicode Bidirectional Algorithm (UAX #9).

Based on the original source code on GitHub: https://github.com/deepakjois/luabidi

Minimal modifications had been made to the code to make
it compatible with Minetest.

## How to use

Given a table `codepoints` containing numbers that are all valid Unicode codepoints,
`bidi.get_visual_reordering(codepoints)` will return a new table
that are ordered in such a way that the Unicode Bidirectional Algorithm
has affected them.

```
local reordered_codepoints = bidi.get_visual_reordering(codepoints)
```

There are other functions as well, read the source code comments
in `bidi.lua` for exact information.

## Credits

* Original author: Deepak Jois <deepak.jois@gmail.com>
* License: MIT License (see LICENSE_luabidi.txt)
