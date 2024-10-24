# `player_api` compatibility layer for Repixture

This mod is the Repixture implementation of `player_api` originally from Minetest Game.
It is API-compatible with Minetest Game's `player_api` from Minetest Game 5.8.0.
Technically, it is just a wrapper around `rp_player`, provided for compatibility.

Mod developers can use this mod to handle player-related stuff and should be enough
for most purposes.

For advanced player model features specific to Repixture, you may use `rp_player` instead

## Credits

The API documentation is copied from from Minetest Game 5.8.0.
originally by celeron55, Perttu Ahola <celeron55@gmail.com> (LGPLv2.1+),
continued by Luanti developers and contributors (LGPLv2.1+),
changed for Repixture by Wuzzy (LGPLv2.1+).

Everything else written by Wuzzy (LGPLv2.1+).
