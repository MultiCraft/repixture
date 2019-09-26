## 1.0.0
- Fix villages sometimes digging too aggressively into land
- Change clothing color of villagers
- "Drain the swamp" achievement now recognizes any swamp dirt
- Placing villages now requires new "maphack" privilege
- Add basic protection support
- Mobs now have breath and drown instead of taking direct water damage
- Animals that spawn in villages are tamed
- Mobs don't despawn near players
- Add sound for placing blocks

## 0.6.0
- Most mobs now take damage from blocks
- Change graphite ore texture
- New mob damage particle
- More things get dug instantly in Creative Mode
- Add 3 shears: steel shears, carbon steel shears, bronze shears (+ jeweled variants)
- Shears can now dig leaves and other plant-like blocks
- Trading: Make chest cheaper
- Trimming cotton with shears now adds wear
- Various minor text changes here and there

## 0.5.0
- Villagers: Add carpenter profession
- Villagers: Re-balance trades a bit
- Villagers: Add a number of new messages, commenting on the stuff you carry
- Villagers now group-attack
- Tweak stuff in village chests
- Generate locked chests in villages
- Limit number of music players per village to 1
- Fade in/out weather sounds; don't play rain sound underwater
- Remove unused snowstorm weather
- Save weather status when quitting game
- Fix mob punch sound not always played
- New sounds: Skunk, jewelling, placing/taking water, lockpicking, hungry
- Improve mob sounds
- Jewelling: Fix "range" bonus not working
- Complete overhaul of achievements: Remove all "grindy" achievements, change requirements for existing achievements to be more specific, add new achievements
- Locked chests: Display "cracked" state in info text
- Locked chests can now be ownerless
- Lockpicks no longer try to pick already cracked chests
- Improve the quality of ambient sounds a bit, add swamp ambience at night
- Make trader form less confusing
- Torches and music players drop as items when flooded
- Make lasso texture look more dry

## 0.4.4
- Fix achievements screen sometimes not properly updated
- Fix weird attachment behaviour of apples
- Fix crafting menu selection sometimes annoyingly jumping around after craft
- Hand can no longer dig stone and other “hard” blocks

## 0.4.3
- Game renamed from “Pixture Revival” to “Repixture”

## 0.4.2
- Fix crashes related to mobs
- Fix dropped items refusing to fall when block below is dug
- Fix buggy HP bars above player heads
- Make wielditem functional again
- Clarify license information
- Add screenshot

## 0.4.1
- Jewels generate again
- Increase hand range in Creative Mode
- Dry grass, music player, saplings and farming plants are now floodable
- Villages: Don't place lanterns in dead-end roads
- Make villager spawning more reliable

## 0.4.0
- Fix another crash in villages mod
- Sneaking now protects you from falling down edge of blocks
- Grass clumps will now spread slowly
- Clams will appear slowly at sand and gravel beaches
- Swamp grass clump now can be used to craft fiber (1:1)

## 0.3.2
- Fix crash when farming plants tries to grow in rain
- Fix undiggable slabs
- Villages no longer aggressively cut into trees or terrain
- Few minor village structure improvements and fixes
- Fix villagers spawning on same spot
- Fix farming plants not growing under certain circumstances
- Fix fertilizer acting incorrectly on various types of dirt
- Fix some grass covers not disappearing when covered
- Dirt grows a dry grass cover in dry biomes (instead of normal grass cover)
- Swamp dirt grows a swamp grass cover in swamp biomes
- Dry dirt now has an unique appearance

## 0.3.1
- Fix mobs failing to die when drowning
- Clams no longer drop pearls

## 0.3.0
Improvements:
- Village land generation improvements
- Minor improvements to a few village structures
- Dying mobs now make sounds
- Add descriptions for all important settings
- Expose more settings in the settings menu
- Turn dirt with grass to dirt below slabs and stairs
- Oak trees now generate

Cleanup:
- Clean up achievements descriptions
- More items are kept when placed in Creative Mode
- Disabling TNT no longer removes TNT from the game, instead it replaces it with defused TNT
- Removed mods: `pm`, `player_list`
- Show message when trying to spawn hostile mob when it's disabled
- Prevent sleep if not enough space
- Kick player out of bed when re-joining
- Restrict villages to grasslands

Bugfixes:
- Disable some achievements when they are unobtainable due to settings
- Fix crash in `player_skins` mod
- Fix invalid water bucket stacks sometimes appearing in village chests
- Fix furnace/chest facing the wrong way in forge house
- Fix overlapping dirt path slab
- Fix broken achievements: place seeds, place lumien crystals, kill mobs
- Fix mobs never dropping anything
- Fix inventory menu not updating when changing skin via chat command

## 0.2.0
Meta:
- Rename game to Pixture Revival

Cleanup:
- Game now works on Minetest 5.0.0
- Game no longer works in earlier Minetest versions
- Rework the terribly inconvenient crafting system
    - Show only the possible crafts by default
    - Add button to show all possible crafts again
    - Group slots will be highlighted
    - Item tooltips appear instantly
- Removed a lot of cruft:
    - `fixlight` command (is now part of Minetest)
    - `uberspeed` command (instead, default fast speed is made faster)
    - `player_skin` privilege (needlessly complicated)
    - Forced teleportation when reaching 30000m (an ugly hack)
    - Welcome message and a ton of other chat spam (just annoying)
- Disable v6 mapgen
- Make statbars larger
- Rename some items
- Replace TNT sounds
- Limit text length in books and signs
- Improve slab and stair textures
- More unique item images to help keeping items apart

Bugfixes:
- Fix crash when using lockpick in air
- Fix bed being destroyed when placed in invalid place
- Prevent going to bed while moving
- Fix bucket spawning another bucket when using
- Fix lockpick trying to pick everything
- Fix duplicate achievement name
- Fix incorrect trades
- Fix rocks floating on water in wasteland
- Remove server settings in settingtypes.txt that caused a lot of conflicts
- Fix floating thistle after being flooded
- Fix fertilizer sometimes destroying blocks
- Make some objects non-pointable when it doesn't make sense to point them

Features:
- Add creative inventory and support for Creative Mode
- Shift-click in inventories moves items fast
- Map item enables minimap when carried, the old unfinished map window is gone
- Show wielded item above hotbar
- Villagers now talk when right-clicked
- Villagers refuse to trade when on low health or hostile
- More slabs/stairs: bronze, wrought iron, carbon steel
- Add German translation

## 0.1.1

- Replace tree and some farming plant ABMs with node timers (existing growables
 will be reset to the same growing time a newly planted growable would be)
- Patch crafting to work with Minetest 0.4.16
- Modify backend code to use some new API syntax introduced with Minetest 0.4.16

## 0.1.0

- First stable release of Pixture, works with Minetest 0.4.15
