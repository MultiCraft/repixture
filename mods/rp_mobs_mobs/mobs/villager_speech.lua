local S = minetest.get_translator("rp_mobs_mobs")

local get_item_fuel_burntime = function(itemstring)
	local input = {
		method = "fuel",
		items = { itemstring },
	}
	local res = minetest.get_craft_result(input)
	return res.time
end
local get_item_cooking_result = function(itemstring)
	local input = {
		method = "cooking",
		items = { itemstring },
	}
	local res = minetest.get_craft_result(input)
	return res.item
end

local msgs = {
	villager = {
		farmer = S("Hi! I’m a farmer. I sell farming goods."),
		tavernkeeper = S("Hi! I’m a tavernkeeper. I trade with assorted goods."),
		blacksmith = S("Hi! I’m a blacksmith. I sell metal products."),
		butcher = S("Hi! I’m a butcher. Want to buy something?"),
		carpenter = S("Hi! I’m a carpenter. Making things out of wood is my job."),
	},
	trade = {
		S("If you want to trade, show me a trading book."),
	},
	no_worksite = {
		farmer = S("I want to work on a field of crops."),
		tavernkeeper = S("Did you see a barrel nearby? I need one for work."),
		blacksmith = S("I need a furnace to do my work, but I can’t find any."),
		butcher = S("I wanted to cook some meat, but I can’t find a furnace."),
		carpenter = S("It would be nice if we had a library."),
	},
	no_bed = {
		S("I’m grumpy because I can’t find my bed."),
		S("Have you seen a free bed somewhere?"),
		S("I need a place to sleep."),
	},
	happy = {
		S("Hello!"),
		S("Nice to see you."),
		S("Life is beautiful."),
		S("I feel good."),
		S("Have a nice day!"),
	},
	exhausted = {
		S("I’m not in a good mood."),
		S("I’m tired."),
		S("I need to rest."),
		S("Life could be better."),
	},
	hurt = {
		S("I don’t feel so good."),
		S("I ... I am hurt."),
		S("I feel weak."),
		S("My head hurts."),
		S("I have a bad day today."),
	},
	hostile = {
		S("Screw you!"),
	},
	annoying_weapon = {
		S("Get this thing out of my face!")
	},
}

local function say(text, to_player, villager_name)
	if villager_name and villager_name ~= "" then
		minetest.chat_send_player(to_player, S("@1 says: “@2”", villager_name, text))
	else
		minetest.chat_send_player(to_player, S("Villager says: “@1”", text))
	end
end

local function say_random(mtype, to_player, villager_name)
	local r = math.random(1, #msgs[mtype])
	local text = msgs[mtype][r]
	say(text, to_player, villager_name)
end

-- Make villager do some smalltalk, talking about life and such. This
-- assumes the villager is neither hostile nor badly hurt.

-- Parameters:
-- * profession: Villager's profession
-- * name: Player name
-- * villager_name: Villager name (nil if unnamed)
-- * has_worksite: true if villager does have a valid worksite
-- * has_bed: true if villager does have a bed
local function smalltalk(profession, name, villager_name, has_worksite, has_bed)
	if not has_bed then
		-- Complain about missing bed
		say_random("no_bed", name, villager_name)
	elseif not has_worksite then
		-- Complain about missing worksite
		say(msgs.no_worksite[profession], name, villager_name)
	else
		local r = math.random(1,3)
		if r == 1 then
			-- Tell player how to trade
			say_random("trade", name, villager_name)
		elseif r == 2 then
			-- Tell player how to trade
			say(msgs.villager[profession], name, villager_name)
		else
			-- Happy talk
			say_random("happy", name, villager_name)
		end
	end
end

-- Make villager talk about an item to a player, if the player
-- wields something interesting. No talk if no interesting
-- item is wielded.
--
-- Parameters:
-- * profession: Villager's profession
-- * iname: Item name (itemstring)
-- * name: Player name
-- * villager_name: Villager name (nil if unnamed)
-- * has_worksite: true if villager does have a valid worksite
-- * has_bed: true if villager does have a bed
--
-- Returns true if villager has talked, false otherwise.
local function talk_about_item(profession, iname, name, villager_name, has_worksite, has_bed)
	local talked = true
	local vn = villager_name

	-- Talk about missing home bed if player happens to wield a bed
	if not has_bed then
		if iname == "rp_bed:bed_foot" then
			if profession == "blacksmith" then
				say(S("I need this bed. Please place it somewhere. I promise I won’t abuse it as furnace fuel!"), name, vn)
			else
				say(S("Can you please put this bed down for me?"), name, vn)
			end
			return true
		else
			-- No item hints as long there's no bed
			return false
		end
	end
	-- Talk about missing worksite block if player happens to wield such a block
	if not has_worksite then
		if profession == "carpenter" and iname == "rp_default:bookshelf" then
			say(S("Beautiful bookshelf you have there! Can you please place it somewhere where I can reach it? It’s so fascinating …"), name, vn)
		elseif profession == "farmer" and iname == "rp_farming:potato_1" then
			say(S("I know this sounds strange but: Can you please plant some potatoes for me? I want to start a farm but I can’t decide where."), name, vn)
		elseif profession == "farmer" and iname == "rp_farming:carrot_1" then
			say(S("I know this is a weird request but: Can you please plant some carrots for me? I want to start a farm but I can’t decide where."), name, vn)
		elseif profession == "farmer" and minetest.get_item_group(iname, "seed") ~= 0 then
			say(S("I know this sounds awkward but: Can you please plant some crops for me? I want to start a farm but I can’t decide where."), name, vn)
		elseif (profession == "butcher" or profession == "blacksmith") and iname == "rp_default:furnace" then
			say(S("You got a furnace! Please place it somewhere so I can do my work."), name, vn)
		elseif profession == "tavernkeeper" and iname == "rp_decor:barrel" then
			say(S("This is exactly what I need! Can you please put the barrel on the floor for me?"), name, vn)
		else
			-- No item hints as long there's no worksite block
			return false
		end
		return true
	end

	-- Fuel time / cooking hint by blacksmith
	if profession == "blacksmith" then
		-- First some hardcoded texts
		if iname == "rp_default:cactus" then
			say(S("Ah, a cactus. You’d be surprised how well they burn in a furnace."), name, vn)
			return true
		elseif iname == "rp_default:torch_dead" or iname == "rp_default:torch_weak" then
			say(S("You can quickly kindle it in the furnace."), name, vn)
			return true
		elseif iname == "rp_jewels:jewel_ore" then
			say(S("A truly amazing block!"), name, vn)
			return true
		elseif minetest.get_item_group(iname, "tree") > 0 then
			say(S("Trees are a classic furnace fuel, but you can also cook them to get coal lumps."), name, vn)
			return true
		end
		local cook = get_item_cooking_result(iname, vn)
		local fuel = get_item_fuel_burntime(iname, vn)
		if cook and not cook:is_empty() then
			local dname = cook:get_short_description()
			if fuel > 0 then
				say(S("You can cook it in the furnace to get: @1. But you can also use it as a furnace fuel.", dname), name, vn)
			else
				say(S("Cook it in the furnace to get: @1.", dname), name, vn)
			end
			return true
		end

		if fuel > 0 then
			if fuel >= 180 then
				say(S("This is an amazing furnace fuel, it burns for a very, very, very long time."), name, vn)
			elseif fuel >= 120 then
				say(S("This is a great furnace fuel, and it burns for a very, very long time."), name, vn)
			elseif fuel >= 60 then
				say(S("This is a very good furnace fuel, and it burns for a very long time."), name, vn)
			elseif fuel >= 30 then
				say(S("This is a good furnace fuel, it burns for a long time."), name, vn)
			elseif fuel >= 20 then
				say(S("This is a nice furnace fuel."), name, vn)
			elseif fuel >= 15 then
				say(S("You can use this as a furnace fuel, but it’s meh."), name, vn)
			elseif fuel >= 9 then
				say(S("You can use this as a furnace fuel, but it is gone quickly."), name, vn)
			elseif fuel >= 3 then
				say(S("You can use this as a furnace fuel, but it is gone very quickly."), name, vn)
			else
				say(S("You can theoretically use this as a furnace fuel, but it is gone almost instantly. You will need a large amount of these to cook anything."), name, vn)
			end
			return true
		end
	end

	if iname == "rp_gold:ingot_gold" then
		say_random("trade", name, vn)
	elseif iname == "rp_jewels:serrated_broadsword" then
		if profession == "blacksmith" then
			say(S("I’m impressed! Your weapon is a true masterpiece."), name, vn)
		else
			say_random("happy", name, vn)
		end
	elseif iname == "rp_default:broadsword" then
		say(S("This is a mighty weapon, but have you considered upgrading it with jewels?"), name, vn)
	elseif (minetest.get_item_group(iname, "sword") > 0) or (minetest.get_item_group(iname, "spear") > 0) then
		say(S("Offense is the best defense."), name, vn)
	elseif minetest.get_item_group(iname, "is_armor") == 1 then
		say(S("If you equip a full set of armor made from the same material, you’ll get a protection bonus."), name, vn)
	elseif iname == "rp_default:bookshelf" then
		if profession == "carpenter" then
			say(S("This block is so fascinating …"), name, vn)

		else
			say(S("You can put anything inside a bookshelf, not just books."), name, vn)
		end
	elseif iname == "rp_default:fertilizer" then
		if profession == "farmer" then
			say(S("This makes seeds grow faster. Place the fertilizer on soil, then plant the seed on top of it."), name, vn)
		else
			say(S("Sorry, I don’t know how to use this. Maybe ask a farmer."), name, vn)
		end
	elseif minetest.get_item_group(iname, "bucket") > 0 then
		if profession == "farmer" then
			say(S("Remember to put water near to your seeds."), name, vn)
		else
			say_random("happy", name, vn)
		end
	elseif minetest.get_item_group(iname, "nav_compass") == 1 then
		say(S("Try magnetizing it on iron."), name, vn)
	elseif minetest.get_item_group(iname, "nav_compass") == 2 then
		local r = math.random(1,3)
		if r == 1 then
			say(S("If you use it on a cotton bale, it will point to the North again."), name, vn)
		else
			say(S("If you use it on wool, it will point to the North again."), name, vn)
		end
	elseif iname == "rp_nav:map" then
		say(S("We live in a lovely place, don’t we?"), name, vn)
	elseif iname == "mobs:lasso" then
		say(S("It’s used to capture large animals."), name, vn)
	elseif iname == "rp_locks:pick" then
		say(S("Why are you carrying this around? Do you want crack open our locked chests?"), name, vn)
	elseif iname == "mobs:net" then
		say(S("It’s used to capture small animals."), name, vn)
	elseif iname == "rp_farming:wheat_1" then
		say(S("Every kid knows seeds need soil, water and sunlight."), name, vn)
	elseif iname == "rp_farming:cotton_1" then
		if profession == "farmer" then
			say(S("Did you know cotton seed not only grow on dirt, but also on sand? But it still needs water."), name, vn)
		elseif profession == "carpenter" then
			say(S("If you have grown a cotton plant, try using scissors to perform a precise cut."), name, vn)
		else
			say(S("Every kid knows seeds need soil, water and sunlight."), name, vn)
		end
	elseif iname == "rp_farming:wheat" then
		if profession == "farmer" then
			say(S("Sheep love to eat wheat. Give them enough wheat and they’ll multiply!"), name, vn)
		else
			say(S("We use wheat to make flour and bake bread."), name, vn)
		end
	elseif iname == "rp_farming:flour" then
		say(S("Put it in a furnace to bake tasty bread."), name, vn)
	elseif iname == "rp_farming:cotton" then
		say(S("This can be used to make cotton bales."), name, vn)
	elseif iname == "rp_default:book" then
		say(S("A truly epic story!"), name, vn)
	elseif iname == "rp_default:pearl" then
		if profession == "tavernkeeper" then
			say(S("Ooh, a shiny pearl! It’s beautiful."), name, vn)
		else
			say(S("I heard the tavernkeeper likes these."), name, vn)
		end
	elseif minetest.get_item_group(iname, "sapling") > 0 then
		local r = math.random(1,3)
		if r == 1 then
			say(S("Just place it on the ground and it will grow after a while."), name, vn)
		elseif r == 2 then
			say(S("If the sapling refuses to grow, make sure it has enough open space above it."), name, vn)
		else
			say(S("Try placing it on different grounds. It might grow differently."), name, vn)
		end
	elseif minetest.get_item_group(iname, "shears") > 0 then
		say(S("Use this to trim plants and get wool from sheep."), name, vn)
	elseif iname == "rp_default:papyrus" then
		if profession == "farmer" then
				say(S("Papyrus grows best on fertilized swamp dirt."), name, vn)
		elseif profession == "carpenter" then
				say(S("Papyrus likes to grow next to water."), name, vn)
		elseif profession == "tavernkeeper" then
				say(S("The papyrus grows tall in the swamp. But it can grow even taller."), name, vn)
		else
				say(S("When I was I kid, I always liked to climb on the papyrus."), name, vn)
		end
	elseif iname == "rp_default:cactus" then
		if profession == "farmer" then
			say(S("Cacti grow best on sand. They are also a food source, if you’re really desperate."), name, vn)
		elseif profession == "tavernkeeper" then
			say(S("This is the secret ingredient for my special drink. But don’t tell anyone!"), name, vn)
		else
			say(S("Now what can you possibly do with a cactus? I don’t know!"), name, vn)
		end
	elseif iname == "jewels:jewel" then
		if profession == "blacksmith" then
			say(S("Jewels are great! If you have a jeweller’s workbench, you can enhance your tools."), name, vn)
		else
			say(S("Did you know we sometimes sell jewels?"), name, vn)
		end
	elseif iname == "rp_lumien:crystal_off" then
		say(S("This looks like it could be a good wall decoration."), name, vn)
	elseif iname == "rp_default:torch_dead" then
		say(S("It’s burned out. Use flint and steel to kindle it."), name, vn)
	elseif iname == "rp_default:torch_weak" then
		say(S("With flint and steel you could stabilize the flame."), name, vn)
	elseif iname == "rp_default:torch" then
		say(S("Let’s light up some caves!"), name, vn)
	elseif iname == "rp_default:flower" then
		say(S("A flower? I love flowers! Let’s make the world bloom!"), name, vn)
	elseif iname == "rp_default:flint_and_steel" then
		if minetest.settings:get_bool("tnt_enable", true) then
			say(S("You can use this to light up torches and bonfires and ignite TNT."), name, vn)
		else
			say(S("You can use this to light up torches and bonfires."), name, vn)
		end
	elseif iname == "rp_tnt:tnt" then
		if minetest.settings:get_bool("tnt_enable", true) then
			say(S("TNT needs to be ignited by a flint and steel."), name, vn)
		else
			say(S("For some reason, TNT can’t be ignited. Strange."), name, vn)
		end
	elseif iname == "rp_fire:bonfire" then
		say(S("You need flint and steel to light the fire. But don’t walk into the flame!"), name, vn)
	elseif iname == "rp_bed:bed_foot" then
		if profession == "carpenter" then
			say(S("Isn’t it stressful to carry this heavy bed around?"), name, vn)
		else
			say(S("Sleeping makes the night go past in the blink of an eye."), name, vn)
		end
	elseif iname == "rp_default:lump_bronze" then
		-- Classic parody of Friedrich Schiller’s “Das Lied von der Glocke” (works best in German)
		say(S("Hole in dirt, put bronze in. Bell’s complete, bim, bim, bim!"), name, vn)
	elseif iname == "rp_default:apple" then
		say(S("Apples are so tasty!"), name, vn)
	elseif iname == "rp_default:acorn" then
		if profession == "farmer" then
			say(S("Boars love to eat acorns! If you feed enough of these to them, they will multiply."), name, vn)
		else
			say(S("Apples are so tasty!"), name, vn)
		end
	elseif iname == "rp_default:reed_block" then
		say(S("Did you try to dry it in the furnace?"), name, vn)
	elseif iname == "rp_default:furnace" then
		if (profession == "butcher" or profession == "blacksmith") then
			if profession == "butcher" then
				say(S("Meat tastes best when it’s cooked."), name, vn)
			elseif profession == "blacksmith" then
				say(S("Raw metals aren’t going to smelt themselves!"), name, vn)
			end
		else
			say(S("Furnaces are so versatile, they not just smelt ores, but cook foods as well!"), name, vn)
		end
	elseif minetest.get_item_group(iname, "airweed") > 0 then
		if profession == "carpenter" then
			say(S("Airweed is an underwater plant with little capsules filled with air. Use it underwater to release air bubbles and catch some breath."), name, vn)
		elseif profession == "butcher" then
			say(S("If you use the airweed plant, you will catch some breath. Other people near the plant will also benefit."), name, vn)
		elseif profession == "tavernkeeper" then
			say(S("Airweed is very useful, but it can’t give you breath from your hand. You must place it on the ground first."), name, vn)
		elseif profession == "farmer" then
			say(S("You can multiply airweed with fertilizer."), name, vn)
		else
			say(S("Airweed needs a moment to refill after you used it. The time it needs depends on the surface."), name, vn)
		end
	elseif iname == "rp_default:alga" then
		if profession == "farmer" then
			say(S("If you fertilize the ground, an alga will grow higher."), name, vn)
		elseif profession == "tavernkeeper" then
			say(S("The tallest algae always grow on alga blocks."), name, vn)
		elseif profession == "carpenter" then
			say(S("If an alga tries to grow but something blocks its path, it’ll stop growing, even if the barrier is removed later."), name, vn)
		else
			say(S("Algae grow underwater in different heights."), name, vn)
		end
	elseif iname == "rp_default:vine" then
		if profession == "farmer" then
			say(S("Place it at the ceiling and watch it grow."), name, vn)
		elseif profession == "carpenter" then
			say(S("If you want the vine to stop growing, make a precise cut using scissors."), name, vn)
		else
			say(S("It’s climbing time!"), name, vn)
		end
	elseif iname == "rp_default:dirt" then
		if profession == "farmer" then
			say(S("Many wild plants as well as wheat and cotton grow on dirt, but they grow better when it’s fertilized."), name, vn)
		else
			say(S("You’re dirty!"), name, vn)
		end
	elseif iname == "rp_default:swamp_dirt" then
		if profession == "farmer" then
			say(S("Swamp dirt is really interesting. The famous swamp oak grows on it, and papyrus also grows exceptionally well."), name, vn)
		else
			say(S("Disgusting!"), name, vn)
		end
	elseif iname == "rp_default:dry_dirt" then
		if profession == "farmer" then
			say(S("Not much grows on dry dirt."), name, vn)
		else
			say(S("This dirt is as dry as my jokes."), name, vn)
		end
	elseif iname == "rp_default:sand" then
		if profession == "farmer" then
			say(S("You can use sand to grow cacti."), name, vn)
		else
			say(S("Be careful not to let it fall on your head!"), name, vn)
		end
	elseif iname == "rp_default:fern" then
		if profession == "farmer" then
			say(S("Fern is used to craft fertilizer. Fern spreads on fertilized dirt."))
		else
			say(S("Fern is used to craft fertilizer."))
		end
	elseif iname == "rp_decor:barrel" then
		if profession == "tavernkeeper" then
			say(S("I use a barrel for the work at the tavern."), name, vn)
		else
			say(S("The tavernkeeper uses the barrel to do their work."), name, vn)
		end
	elseif minetest.get_item_group(iname, "stone") > 0 then
		if profession == "butcher" then
			say(S("This is like my ex-lover’s heart. Made out of stone."), name, vn)
		else
			say_random("happy", name, vn)
		end
	elseif minetest.get_item_group(iname, "food") > 0 then
		say(S("Stay healthy!"), name, vn)
	else
		talked = false
	end
	return talked
end

return {
	say = say,
	say_random = say_random,
	talk_about_item = talk_about_item,
	smalltalk = smalltalk,
}
