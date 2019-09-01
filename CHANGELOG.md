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
- Villagers now talk when rightclicked
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
