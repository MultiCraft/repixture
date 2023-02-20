= Safe Spawning Mod for Repixture =
This mod checks the position of the player after the initial spawn (not respawn).
If the position is unsafe, the mod tries to relocate the player to a safer position.

This mod is a workaround for Minetest sometimes picking a bad spawn position
because Minetest’s spawn algorithm sucks (as of Minetest version 5.5.1).
This mod fixes that. For Repixture, this mod was created due
to a low chance of the player spawning in a thistle.

## Limitations

This mod is only for the first spawn, not respawning. So Minetest still might
put the player at an unlucky position on a respawn.

## Credits

Author: Wuzzy
License: MIT License
