+++
title = "Repixture Player Manual"
+++
## Preface

This manual explains the basics of Repixture. Here you learn how to install, setup and play Repixture and the basic rules of the game. This is not a walkthrough, however, so there are still plenty of things to discover for yourselves.

## Introduction

Welcome to <span class="concept">Repixture</span>! Repixture is a sandbox game for Minetest focusing on nature, survival and primitive technologies. The world is random and features mostly a temperate climate. Explore the world and gather resources to survive. Craft tools and things to build with, build shelter and later the buildings of your dreams. What you do in this world is up to you: Go mining for the mysterious lumien, forge the mightiest sword, trade with villagers, go farming, hunt for achievements, or whatever.

### Information for players familiar with Minetest Game, Minecraft, Terasology, etc.

If you know any of these games, you will find this game easy to pick up. Repixture is similar to these games and follows the same key principles.
If you’re familiar with Minetest in general, you’re already familiar with the basics.

Here’s what’s special in Repixture:

* Crafting: You have 4 crafting slots. You can put *stacked* items into them to select what you want to craft from a list. You don’t have to remember patterns anymore.
* You can craft everything everywhere. No crafting bench required.
* No hoes. Just place the <span class="item">seeds</span> on the ground.
* Plants grow differently on different grounds.
* <span class="item">Fiber</span> is an important crafting material, crafted from <span class="itemgroup">any green grass</span>
* <span class="itemgroup">Tools</span> are crafted from <span class="itemgroup">any wooden planks</span>, <span class="item">sticks</span> and <span>fiber</span>
* The game focuses on nature more than other games
* Progress in this game is intentionally slower, due to a low-tech paradigm
* No overpowered high-tech redstone contraptions, mesecons, or similar
* Skin customizer!
* Tools can be repaired by villagers … for a price
* <span class="item">Locked chests</span> can be lockpicked
* There are <span class="itemgroup">spears</span>
* <span class="itemgroup">Shears</span> have a special “fine cut” ability
* Rare <span class="item">jewels</span> to upgrade your tools
* No end boss. A true sandbox game

## Installation and setup

### Installation

To play Repixture, you must have Minetest installed. See the `README.md` text file for the required Minetest version.
The recommended method to install Repixture is by using the Minetest ContentDB. This is the “Content” tab in Minetest.

You can also install Repixture manually. Look up the Minetest documentation to learn how to install games manually.

### Setup / configuration

For the vanilla Repixture gameplay experience, Repixture needs several settings to be untouched (reset to defaults) in your Minetest configuration. If you want the official Repixture experience, please make sure the following Minetest settings are at the default value / removed from `minetest.conf`:

* Any player movement settings (Settings that start with “`movement_`”. Exception: `movement_speed_fast`)
* Time speed (`time_speed`)
* v7 mapgen parameters (Settings that start with “`mgv7_`”)
* Valleys map generator parameters (Settings that start with “`mgvalleys_`”)
* Biome settings (Settings that start with “`mg_biome_`”)

You can still alter these settings at will, but then it doesn’t count as the official Repixture experience anymore. ;-)

#### Game settings

The following settings are recognized in Repixture:

* Creative Mode (`creative_mode=true`): Enables the creative inventory which gives you infinite items.
* No damage (`enable_damage=false`): All players are immortal. No damage, no hunger, no drowning, no deaths. Doesn’t affect creatures.
* No hunger (`enable_hunger=false`): Hunger is disabled.

For more settings, go to the Minetest settings menu and look for the Repixture section.

## Starting the game

### A new world

Starting a world works like with any other game in Minetest. Enter a world name, select a map generator and settings, and off you go! The seed is value that will be used to calculate random things in the game. The same seed will generate the same world.

You can choose one of various map generators, like v7, carpathian, valleys, etc. For new players, v7 is recommended for new players, but other map generators also work fine and can be nice if you want to try out something new. Only v6 isn’t supported and can’t be selected.

Note: The “singlenode” map generator is special as the world is completely empty. This one only makes sense if you use Repixture in combination with mod that generates a special world (like Skyblock).

## Controls

Repixture uses the same control scheme as Minetest. Walking, jumping, etc. works the usual way. Remember you can always change or lookup the key bindings in the settings and/or pause menu of Minetest.

Repixture recognizes the following game-related controls offered by Minetest:

* <kbd>Look around</kbd>
* <kbd>Left</kbd> / <kbd>Right</kbd> / <kbd>Forwards</kbd> / <kbd>Backwards</kbd>
* <kbd>Jump</kbd>
* <kbd>Sneak</kbd> (also unmounts you on boats)
* <kbd>Drop item</kbd>
* <kbd>Punch</kbd> (see below)
* <kbd>Place</kbd> (see below)
* <kbd>Minimap</kbd> (only works if you carry a <span class="item">map</span> or you’re in Creative Mode)
* <kbd>Inventory</kbd>
* <kbd>Select item in hotbar</kbd>

All keys do what they say. The <kbd>Jump</kbd> and <kbd>Sneak</kbd> keys also move you up and down in liquids and blocks that can be climbed, as usual. Note there’s a Minetest setting `aux1_descends` that can alter this behavior.

For clarity, here’s what happens if you use the <kbd>Place</kbd> or <kbd>Punch</kbd> key:

* <kbd>Place</kbd>: Place the wielded item _or_ use/interact with the pointed thing, if possible (e.g. open a chest).
* <kbd>Sneak</kbd> + <kbd>Place</kbd>: Place the wielded item. Won’t interact with the pointed thing.
* <kbd>Punch</kbd>: Use the item in your hand. Depending on the item, this can mean: Punching (default use), mine block, eat (if it’s food), trigger the item’s special function, and other things

The <kbd>Aux1</kbd> control is unused in Repixture.

Hint: In Repixture, many items can be placed, even if they don’t seem like it. Just try to place stuff and see what happens!

## Interface
### Game screen

On the game screen you see the following things:

![Game screen](./assets/images/screenshots/screen.png)

1. **Crosshair** (in the center): Shows where you’re looking at. Normally, the crosshair is white, but if you’re looking at a dynamic object or living being, the crosshair will turn black
2. **Health bar** (heart symbols): Indicates your health points
3. **Food bar** (bread symbols): Indicates your food points
4. **Breath bar** (bubble symbols above the food bar, not shown): Indicates your breath while diving. Not shown when you have full breath
5. **Hotbar** (slots at the bottom): Shows items from your inventory that you can wield. A square marks the wielded item
6. **Wielded item** (bottom right): This is your hand or the item you’re currently wielding
7. **Minimap** (top right): A map of the world. Hidden by default, so you must enable with the <kbd>Minimap</kbd> key. This only works if you have a <span class="item">map</span> in your inventory or you’re in Creative Mode
8. **Item name** (above the bars, not shown): At this position the short name of the wielded item is shown. It appears briefly when you switch items
9. **Info text** (left side): If you’re pointing something special or something that has some text associated with it, a short text will appear here

### Inventory screen

The <span class="concept">inventory</span> screen shows your inventory as well as some other useful stuff. The inventory is opened and closed with the <kbd>Inventory</kbd> key. You can also close the inventory with <kbd>Esc</kbd> on PC.

#### Inventory basics

![Inventory menu](./assets/images/screenshots/inventory_basic.png)

The inventory screen is organized in <span class="concept">pages</span>. The tabs on the left side, shown on the screenshot at the number (1), let you switch the page. The screenshot shows that we’re on the Crafting page right now.

Some pages, like the Crafting page, show your inventory (2). The inventory is where you store and move your items. The top row represents your hotbar, i.e. the items you can actually use while exploring the world.

The next sections explain every page.

#### Crafting page

![Crafting menu](./assets/images/screenshots/inventory_crafting.png)

Here you can craft, i.e. combine items to create new items.

Initially, this page is mostly empty with only the crafting slots (1) and the crafting guide button (5) visible.

To the left (1), you see 4 crafting slots. If you put one or multiple items into these slots (the order does not matter) and you can craft something useful from it, this will activate the crafting list (3), the recipe (2) and output preview (4).

Right from the crafting slots, the recipe is shown (2). This section has up to 4 item icons that tell you which items are required for crafting the currently selected recipe. Hover an icon with a cursor to learn what it is. If an item has a darkened background, that means other, similar items within the same group are accepted as well. For example, in this image, a <span class="item">grass clump</span> is shown but since the background is darkened this means that similar grass clumps will be accepted as well.

Right from the recipe is the recipe list (3). This list shows everything you can currently craft from the items in the crafting slots, in alphabetical order. If there is a number next to the item name, that’s the count of the resulting item. Select the item you want to craft and/or learn the recipe for. If you double click/double-tap something in the list, you will craft the item.

The crafting buttons labelled “1” and “10” are to the right (6). They let you craft the selected recipe 1 time, or 10 times. Note the “10” button also works even if you don’t have items for 10 crafts; in that case, you will craft it as many times as you can. All crafted items will appear your inventory into the first free slot. Crafting does *not* work when your inventory is full.

Finally, the black question mark button (5) toggles the crafting guide and the question mark will turn white. If the crafting guide is active, the recipe list will show every possible recipe, even those you can’t craft yet.

#### Armor

![Armor menu](./assets/images/screenshots/inventory_armor.png)

In this page you can view and equip armor, which protects you from some forms of damage.

If you have a helmet, chestplate or a pair of boots, simply put it into the matching slot to equip it. Move an item away from the armor slots to unequip it.

#### Achievements

![Achievements menu](./assets/images/screenshots/inventory_achievements.png)

This page shows all achievements you can get in this game and how many of them you have completed. Achievements are simple optional side tasks. See the section on Achievements below to learn more.

On the top left side (1), you see the name and symbol of the selected achievement. Right from that (2) there is a description telling you what you have to do to get it. At the right edge (3), the achievement state is shown. There are are 3 possible states: Missing, In progress and Gotten.

The big list (4) is the list of all achievements. This list is organized in 3 columns: Status icon, name and goal description. The following status icons are used:

* **Checkmark**: Achievement gotten (text will also be green)
* **Circle**: Achievement in progress (this icon is a pie diagram roughly showing the completion percentage)
* **No icon**: Achievement missing

At the bottom (5) the summary of your achievement progress is shown.

#### Player skins

![Player skins menu](./assets/images/screenshots/inventory_skins.png)

On this page you can look at and change your current player skin. Just click on a button to cycle through the style and color of something. You can also randomize everything with the “Random” button.

#### Creative Inventory

![Creative inventory](./assets/images/screenshots/inventory_creative.png)

This page is only available when Creative Mode is enabled. Here you can get (almost) all items for free. Note that some items that are too “technical” or items that might break the game if you have them are not visible here.

From the creative inventory (1), you can get (almost) all items for free. Just drag items from there into your own inventory. You cannot put items into the creative inventory.

The creative inventory does not fit on a single screen, so with the arrow buttons (3) and (4) you can change to the previous and next screen, respectively. (2) indicates the number of the current screen and the total number of screens.

The item slot with an “X” symbol (5) is the trash. Put items here to destroy them. Alternatively, you can <kbd>Sneak</kbd>+<kbd>Click</kbd> on an item in your inventory to trash it instantly.

### Other screens

Apart from the inventory, a few interactable blocks and creatures might open a screen as well. Most of these screens are rather simple and should be self-explanatory. If you see inventory slots, try putting items into them and see what happens. You can exit all screens with <kbd>Esc</kbd> (on PC).

In screens that show multiple inventories, you can press <kbd>Sneak</kbd>+<kbd>Click</kbd> on an item to exchange it instantly.

## Gameplay

### Summary

This is very a rough overview of how to play the game:

* **Survival**: You’re mortal, so watch your health, breath and food bars. If these meters go empty, that’s bad. Avoid damage, don’t drown and eat regularly (select food item and press <kbd>Punch</kbd>)
* **Mine**: Punch blocks to break them, then pick them up. Many blocks break with your bare hand, but hard blocks like stone require you to wield a tool
* **Build**: Place items and blocks on the ground to build things. Many items can be placed!
* **Craft**: Combine items in your crafting menu in the inventory to create new tools, blocks and other items
* **Armor up**: Equip armor to become harder to kill
* **Fight**: Obtain a weapon or attack bare-handed by punching. Wait between attacks to deal more damage
* **Explore and discover**: Explore the world and discover more items, creatures and biomes to learn more about how the world works
* **Achieve**: Complete the optional achievements in the game for fun and/or bragging rights

The following sections explain how each of these things work in detail.

### Survival

Unless you have disabled damage for your world, knowing how to survive is key. Here are the basic <span class="concept">rules of survival</span>:

* You have 20 health points. 1 half heart represents 1 health point.
* You have 20 food points. 1 half bread represents 1 food point.
* You have 10 breath points. 1 bubble represents 1 breath point.

#### Health points

<span class="concept">Health points</span> indicate your life. They are represented by the heart icons on the screen. If they fall to 0, you die and drop all items. Death is *not* a "game over", as this is a sandbox game. You can just respawn. If you have used a <span class="item">bed</span> before, you will appear at its position again, if it is safe to do so. Otherwise, you will spawn somewhere close to the center of the world (usually).

You lose health by taking damage. You can take damage from falling, getting hit, drowning, starving, traps, and more. You will slowly regenerate health over time by being sated (i.e. have many food points). If hunger is disabled in the settings, you will always regenerate health.

You can reduce damage from hits and traps by equipping armor.

#### Food points

<span class="concept">Food points</span> are represented by the bread icons on your screen. They slowly decrease over time and when your doing things that make you hungry (like mine, build, swim, etc.). You have to eat food to keep your food points full. Food points are important to survival. If your food bar is empty (0 breads), you’re starving will take starvation damage over time. On the other hand, if you have 8 bread icons or more, you will slowly regenerate health over time.

An advanced mechanic of hunger is <span class="concept">satiation</span>. Satiation is similar to food points, i.e. it decreases over time and increases by eating, but you don’t know how satiated you are. Satiation keeps your food points stable for a longer time, especially if you have full satiation. If you eat food, there is a sound and particle effect. But if you have become fully sated (i.e. 100% satiation), the sound and particle effect slightly change. If you see (or hear) this special effect, this means you have reached 100% satiation.

You can always eat, even if you’re full and sated, but there is no additional benefit and the food is wasted.

#### Breath points

<span class="concept">Breath points</span> indicate your breath. They are represented by the bubble icons on your screen. The bubbles are only shown while you are losing breath, otherwise they are hidden.

You will lose breath points while diving in water and possibly other liquids. Otherwise, you’ll quickly regain breath. There are other ways to regain breath. If you have 0 breath points, you will take drowning damage. The amount of drowning damage you take depends on the type of liquid. The rule of thumb is, the “dirtier” the liquid, the more harmful it is to drown in.

You lose breath once every 2 seconds. You’ll take drowning damage at the same rate.


### Mining

<span class="concept">Mining</span> is when you punch blocks until they break and (hopefully) drop as item.

You start with an empty hand, but many blocks, including <span class="itemgroup">dirt</span>, <span class="itemgroup">sand</span>, <span class="itemgroup">gravel</span> and even <span class="itemgroup">tree trunks</span> break by just punching them. It just takes a while.
Some other blocks, like <span class="itemgroup">stone</span>, only break with the correct tool, so this is why you need crafting.
Once a block has broken, it will drop as an item. Just walk to the block to collect it in your inventory.
In the inventory menu, you can move your items around.

Because the hand is pretty weak, you eventually want to have mining tools. Tools allow you to break more blocks, and faster. You can either craft them or find them by other means.

The basic mining tools of Repixture are:

* <span class="itemgroup">Pickaxe</span>: For <span class="itemgroup">stone</span>
* <span class="itemgroup">Shovel</span>: For <span class="itemgroup">dirt</span> <span class="itemgroup">sand</span>, <span class="itemgroup">gravel</span>
* <span class="itemgroup">Axe</span>: For <span class="itemgroup">tree trunks</span>, <span class="itemgroup">wood-based blocks</span>
* <span class="itemgroup">Shears</span>: For <span class="itemgroup">leaves</span>, <span class="itemgroup">small plants</span>
* <span class="itemgroup">Spear</span>: Rarely used as a digging tool because it’s a weapon. But a few small blocks that can be pierced break faster using spears

### Building

<span class="concept">Building</span> is when you <span class="concept">place</span> blocks or items on the ground. Building is very simple, just select an item in your hotbar and press <kbd>Place</kbd>.

Not all blocks can be placed everywhere. If you or something else is in the way, you can’t place. Some blocks can only be placed in a certain way. Usually, a special sound is played in this case.

If you press <kbd>Place</kbd> while looking at a block that can be interacted with, like a chest, you do *not* build but instead use that block instead. To build a block anyway in this case, hold down <kbd>Sneak</kbd> before you press <kbd>Place</kbd>.

### Crafting

<span class="concept">Crafting</span> is the combination of 1 or more items to create a new item. You can only craft in the inventory menu. See the section “Crafting” above to learn how the crafting page works.

Follow these steps to craft anything:

1. Put items you want to combine into the 4 crafting slots
2. Select your wanted item from the list
3. Push the “1” or “10” button to craft this many times

Hint: Important items for early items are <span class="item">fiber</span>, <span class="itemgroup">wooden planks</span> and <span class="item">sticks</span>. You can always use the crafting guide (“?” button) to get a full list of all recipes.

### Armor

If you equip <span class="concept">armor</span>, and you’ll take less damage from direct punches and traps. Armor does not protect you from *all* types of damage, however (e.g. drowning damage still deals full damage).

3 types of armor fit on your body: <span class="itemgroup">Helmet</span>, <span class="itemgroup">chestplate</span> and <span class="itemgroup">boots</span>.

You can equip armor in your inventory menu in the “Armor” tab. Alternatively, just wield the armor and press <kbd>Punch</kbd>. If you have already a piece of armor of the same type equipped, you will switch out your armor.

Each piece of armor has a certain <span class="concept">protection</span> value which reduces damage by a certain percentage. So for example, if you equip a helmet with 5% protection, you will take 5% less damage. Protection adds up: If you have a helmet with 10% protection and a chestplate with 10% protection, your total protection will be 20%.

<span class="concept">Protection bonus</span>: If you have all armor slots equipped and each piece of armor is made of the same material, you get a +10% protection bonus.


### Fighting

Combat is very simple: You just <span class="concept">punch</span> your enemy with the <kbd>Punch</kbd>. Your target must be in range. If the crosshair turns black, then a target is in range.

The basic weapons are:

* <span class="itemgroup">Swords</span>: Mighty and strong, but very slow
* <span class="itemgroup">Spears</span>: Pretty good and pretty fast
* <span class="itemgroup">Tools</span>: Weak but better than hand
* <span class="itemgroup">Hand</span>: Weapon of last resort. Fast but only deals 1 damage

Creatures and other players have health points just like you and they’ll take damage just like you. The stronger your weapon, the more damage you do. If you attack with an item that has no attack damage in its tooltip, it usually will be treated as if you have punched with the hand. Note with some items, such as food, punching is impossible, as the <kbd>Punch</kbd> key instead _uses_ the item.

Punching has a <span class="concept">cooldown</span>. If the weapon is still "swinging back" to its original position and you punch again, you will deal reduced damage (which can be 0). So to deal full damage, you have to wait until the weapon in your hand went back to its original position. Whether you deal quick and weak blows, or slowly deal full blows, the choice is up to you.


### Creatures

You will find some <span class="concept">creatures</span> roaming the world. Most are peaceful, while some will attack you on sight. Like you, creatures have health points and breath points, so they can take damage and die. You can interact with certain creatures by pressing the <kbd>Place</kbd> key while looking at them. If you hold an item in your hand, you will use or give this item. Not all creatures can be interacted with that way. When a creature dies, it usually will <span class="concept">drop</span> some items.

#### Monsters

<span class="concept">Monsters</span> are always hostile and attack you on sight. You have to either fight back or escape to survive. Different monsters have different attack strategies, so watch out!

#### Animals

<span class="concept">Animals</span> are mostly peaceful creatures that usually roam the land aimlessly. There are both adult and baby animals and there are several special things you can do with animals.

##### Feeding and taming

Each animal has a favourite food and you have to find out what it is. If you happen to hold the animal’s favourite food in your hand, it will follow you. To <span class="concept">feed</span> an animal, give it its favourite food. Feeding an animal will heal it. Baby animals will also become adults faster. If the animal is adult and has been fed lots of food, it will become <span class="concept">tame</span>.

##### Breeding

Animals can be <span class="concept">bred</span> to create offspring. To breed 2 adult animals, repeatedly feed them with something they like to eat until they are tame and heart particles appear for both of them. Now bring the two animals together and soon offspring will appear. It’s a new baby animal and it will grow to become an adult eventually. Baby animals can not be bred.

##### Capturing

If you have a <span class="item">net</span> or a <span class="item">lasso</span>, you can <span class="concept">capture</span> adult animals and turn them into items. Once captured, you can place them into the world again whenever you like. Animals need to be tame (i.e. have been fed before) before capturing is possible. The size of the animal also matters, the success rate differs whether you use a net or a lasso. Only tame adult animals can be captured.

#### Villagers

<span class="item">Villagers</span> live in villages. You can <span class="item">talk</span> to them with <kbd>Place</kbd> and they will tell you something about about themselves or the item in your hand. Try asking different villagers for different answers. Villagers like to trade with gold. A few villagers might even <span class="concept">repair</span> your tools.

### Explore and discover

Now you should have a grasp of the basic things you can do. There are a few other special things you can do. You should now be able to discover them on your own.
Explore the world, craft more items and try them out. Have fun! The crafting guide is your friend.

If you have a new strange item, look at its tooltip in your inventory for a more detailed explanation. If there is no such hint, it usually means the item is only important for crafting or trading (or both).

In general, you use items by pressing <kbd>Punch</kbd> (if they are usable). Many items can also be placed as decoration.

A few blocks in the game are interactable. You interact with a block by looking and it and pressing the <kbd>Punch</kbd> key. Examples for interactable blocks are <span class="item">chests</span> and <span class="item">furnaces</span>.

### Achievements

<span class="concept">Achievements</span> are simple optional goals to give you a small symbolic award for completing tasks. Achievements range from very easy to challenging. Completing achievements has no purpose other than bragging rights, there is no gameplay advantage for completing them. Completing all achievements is also not the same as “completing the game”, as this game has no final goal.

If you have gotten an achievement, you will be able to look at its image in the achievements inventory page (see above).

You can see the list of achievements in your inventory menu. Most achievements have a simple (but not necessarily) easy goal. A few achievements are complex and have multiple sub-goals. Select an achievement to see details, its image (if you’ve gotten it) and your progress. Complex achievements will also show the list of sub-goals you’ve already completed.

By default, completing an achievement will show a chat message visible only to you, but in the game settings this behavior can be changed to announce this to all players on the server.


## Other concepts

### Player skins

A <span class="concept">player skin</span> is a style of your body and clothes, and each element can be changed individually. Every player starts with a random player skin. You can change your player skin at will in the player inventory. Player skins have no gameplay effect.

### Creative Mode

<span class="concept">Creative Mode</span> must be enabled before starting the game and applies to all players. In Creative Mode, players get infinite items, basically. In particular, Creative Mode does the following:

* Activate the creative inventory page
* Items you place or use stay in your inventory
* Blocks you mine *usually* do not drop as an item (so the world won’t get polluted with items)
* Tools never wear
* You can always use the minimap without items
* You can also enable the radar mode for the minimap
* Zooming is possible with the <kbd>Zoom</kbd> key

Note: Damage is *not* automatically disabled by Creative Mode. Damage is toggled by a separate setting.

### Commands

Like in many other Minetest games, several <span class="concept">server commands</span> are available which allow you to do some special things via the chat. Most of these commands are considered cheating and require privileges. Commands work like in other games for Minetest. Look up the Minetest help for details. Say `/help` in chat for a list of available commands.

Here are some noteworthy commands (all of these need some privilege):

* `/hp`: Set health points
* `/hunger`: Set hunger level
* `/weather`: Set weather
* `/achievements`: Set achievements

### Online multiplayer

This game can be played in multiplayer, too. Keep in mind: Without any modifications, multiplayer Repixture is a free-for-all, meaning that everyone could attack and grief everyone else. It depends on the players if they live in peace together or turn the world into a war zone. The game will not stop them.

Nothing is completely safe from attacks. Not even <span class="item">locked chests</span> are safe because of <span class="item">lockpicks</span>.

Repixture supports the protection system of Minetest but it doesn’t enforce protection itself. This protection system allows the players to protect a piece of land for themselves so that other players cannot dig or build here. This is popular in servers where you want to show off creative buildings. If you want protection for Repixture, install a protection mod of your choice in Minetest.

Whatever you do with your Repixture server is up to you, of course, just keep the gameplay implications in mind.

In multiplayer, you can see the name as well as the health bar of every player above their head. The health bar can be disabled in the settings.



## Compatibility notes

In this technical section some information is provided about compatibility with mods and older versions of Repixture is provided.

### Compatibility with mods

While mods are not the main focus of Repixture, Repixture is still very moddable, thanks to Minetest’s powerful Lua API. However, not every mod for Minetest is automatically compatible with Repixture. If you want to try out a mod, remember to check the dependencies.

Two types of mods in general should work with Repixture:

* Mods that were explicitly developed for Repixture
* Generic mods that don’t depend on a particular game

Mods that were created specifically for different game only, like Minetest Game, will probably not work.

If you’re a mod developer, reading the text file `DEVELOPERS.md` in the Repixture directory is highly recommended.

### Using old biomes from before version 3.0.0

Since Repixture 3.0.0, the game uses a completely revamped biome system. If you have a world that was created in an earlier version and start it now, there will be biome discontinuities in newly generated parts of the map, e.g. a Wasteland biome might border in a straight line to Grassland. This is not a bug, but might look a bit strange.

If you want to prevent this, you can manually edit the world file *before* starting Repixture. Edit `map_meta.txt` in a text editor and add the line `rp_biome_version = 1`.

### Compatibility with Pixture worlds

Repixture aims to be compatible with Pixture worlds. You can manually convert an old Pixture world to a Repixture world.

Here’s how to do it: In your Minetest user directory, look into “worlds”, then look for the directory with your world’s name. Before you do anything, make a backup copy of this folder, just in case. Then open the file “`world.mt`” in this directory with a text editor. Look for the line that says “gameid = pixture”. Replace it with “gameid = repixture”. Now your world should appear when you select Repixture.


## Further reading

See `README.md` in the Repixture directory (usually in `games/repixture` in the Minetest directory) for general information about the game, about licensing and credits.

For more information about Minetest, go to <https://www.minetest.net/>.
