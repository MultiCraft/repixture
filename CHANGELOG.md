## 0.2.0
Meta:
- Rename to Pixture Revival

Cleanup:
- Add 5.0.0 support
- Remove a lot of cruft:
    - fixlight command
    - uberspeed command
    - `player_skin` privilege
    - Forced teleportation when reaching 30000m in any direction
    - Welcome message and other chat spam
    - Make fast mode fast again
- Disable v6 mapgen
- Make statbars larger
- Rename most items
- Replace TNT sounds

Bugfixes:
- Fix duplicate achievement name
- Fix incorrect trades
- Fix rocks floating on water in wasteland
- Remove server settings in settingtypes.txt that caused a lot of conflicts

Features:
- Map item enables minimap when carried
- Add rudimentary creative inventory (for testing)
- Show wielded item above hotbar
- Villagers now talk when rightclicked
- Villagers refuse to trade when on low health or hostile
- Add German translation

## 0.1.1

- Replace tree and some farming plant ABMs with node timers (existing growables
 will be reset to the same growing time a newly planted growable would be)
- Patch crafting to work with Minetest 0.4.16
- Modify backend code to use some new API syntax introduced with Minetest 0.4.16

## 0.1.0

- First stable release of Pixture, works with Minetest 0.4.15
