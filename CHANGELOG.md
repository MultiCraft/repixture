## 0.2.0
Meta:
- Rename to Pixture Revival

Cleanup:
- Add 5.0.0 support
- Only show possible crafting recipes in crafting menu
- Removed a lot of cruft:
    - fixlight command
    - uberspeed command
    - `player_skin` privilege
    - Forced teleportation when reaching 30000m
    - Welcome message and a ton of other chat spam
- Disable v6 mapgen
- Make statbars larger
- Rename most items
- Replace TNT sounds
- Limit text length in books and signs
- Improve slab and stair textures
- More item images to help keeping items apart

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

Features:
- Map item enables minimap when carried
- Show wielded item above hotbar
- Shift-click in inventories moves items fast
- Add rudimentary creative inventory (for testing)
- Villagers now talk when rightclicked
- Villagers refuse to trade when on low health or hostile
- Now slabs/stairs: bronze, wrought iron, carbon steel
- Add German translation

## 0.1.1

- Replace tree and some farming plant ABMs with node timers (existing growables
 will be reset to the same growing time a newly planted growable would be)
- Patch crafting to work with Minetest 0.4.16
- Modify backend code to use some new API syntax introduced with Minetest 0.4.16

## 0.1.0

- First stable release of Pixture, works with Minetest 0.4.15
