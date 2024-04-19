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
		farmer = S("Hi! I'm a farmer. I sell farming goods."),
		tavernkeeper = S("Hi! I'm a tavernkeeper. I trade with assorted goods."),
		blacksmith = S("Hi! I'm a blacksmith. I sell metal products."),
		butcher = S("Hi! I'm a butcher. Want to buy something?"),
		carpenter = S("Hi! I'm a carpenter. Making things out of wood is my job."),
	},
	trade = {
		S("If you want to trade, show me a trading book."),
	},
	happy = {
		S("Hello!"),
		S("Nice to see you."),
		S("Life is beautiful."),
		S("I feel good."),
		S("Have a nice day!"),
	},
	exhausted = {
		S("I'm not in a good mood."),
		S("I'm tired."),
		S("I need to rest."),
		S("Life could be better."),
	},
	hurt = {
		S("I don't feel so good."),
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

local function say(text, to_player)
	minetest.chat_send_player(to_player, S("Villager says: “@1”", text))
end

local function say_random(mtype, to_player)
	local r = math.random(1, #msgs[mtype])
	local text = msgs[mtype][r]
	say(text, to_player)
end

-- Make villager talk about an item to a player
-- * profession: Villager's profession
-- * iname: Item name (itemstring)
-- * name: Player name
local function talk_about_item(profession, iname, name)
	-- Fuel time / cooking hint by blacksmith
	if profession == "blacksmith" then
		-- First some hardcoded texts
		if iname == "rp_default:cactus" then
			say(S("Ah, a cactus. You'd be surprised how well they burn in a furnace."), name)
			return
		elseif iname == "rp_default:torch_dead" or iname == "rp_default:torch_weak" then
			say(S("You can quickly kindle it in the furnace."), name)
			return
		elseif iname == "rp_jewels:jewel_ore" then
			say(S("A truly amazing block!"), name)
			return
		elseif minetest.get_item_group(iname, "tree") > 0 then
			say(S("Trees are a classic furnace fuel, but you can also cook them to get coal lumps."), name)
			return
		end
		local cook = get_item_cooking_result(iname)
		local fuel = get_item_fuel_burntime(iname)
		if cook and not cook:is_empty() then
			local dname = cook:get_short_description()
			if fuel > 0 then
				say(S("You can cook it in the furnace to get: @1. But you can also use it as a furnace fuel.", dname), name)
			else
				say(S("Cook it in the furnace to get: @1.", dname), name)
			end
			return
		end

		if fuel > 0 then
			if fuel >= 180 then
				say(S("This is an amazing furnace fuel, it burns for a very, very, very long time."), name)
			elseif fuel >= 120 then
				say(S("This is a great furnace fuel, and it burns for a very, very long time."), name)
			elseif fuel >= 60 then
				say(S("This is a very good furnace fuel, and it burns for a very long time."), name)
			elseif fuel >= 30 then
				say(S("This is a good furnace fuel, it burns for a long time."), name)
			elseif fuel >= 20 then
				say(S("This is a nice furnace fuel."), name)
			elseif fuel >= 15 then
				say(S("You can use this as a furnace fuel, but it's meh."), name)
			elseif fuel >= 9 then
				say(S("You can use this as a furnace fuel, but it is gone quickly."), name)
			elseif fuel >= 3 then
				say(S("You can use this as a furnace fuel, but it is gone very quickly."), name)
			else
				say(S("You can theoretically use this as a furnace fuel, but it is gone almost instantly. You will need a large amount of these to cook anything."), name)
			end
			return
		end
	end

	if iname == "rp_gold:ingot_gold" then
		say_random("trade", name)
	elseif iname == "rp_jewels:serrated_broadsword" then
		if profession == "blacksmith" then
			say(S("I'm impressed! Your weapon is a true masterpiece."), name)
		else
			say_random("happy", name)
		end
	elseif iname == "rp_default:broadsword" then
		say(S("This is a mighty weapon, but have you considered upgrading it with jewels?"), name)
	elseif (minetest.get_item_group(iname, "sword") > 0) or (minetest.get_item_group(iname, "spear") > 0) then
		say(S("Offense is the best defense."), name)
	elseif minetest.get_item_group(iname, "is_armor") == 1 then
		say(S("If you equip a full set of armor made from the same material, you'll get a protection bonus."), name)
	elseif iname == "rp_default:bookshelf" then
		say(S("You can put anything inside a bookshelf, not just books."), name)
	elseif iname == "rp_default:fertilizer" then
		if profession == "farmer" then
			say(S("This makes seeds grow faster. Place the fertilizer on soil, then plant the seed on top of it."), name)
		else
			say(S("Sorry, I don't know how to use this. Maybe ask a farmer."), name)
		end
	elseif minetest.get_item_group(iname, "bucket") > 0 then
		if profession == "farmer" then
			say(S("Remember to put water near to your seeds."), name)
		else
			say_random("happy", name)
		end
	elseif minetest.get_item_group(iname, "nav_compass") == 1 then
		say(S("Try magnetizing it on iron."), name)
	elseif minetest.get_item_group(iname, "nav_compass") == 2 then
		local r = math.random(1,3)
		if r == 1 then
			say(S("If you use it on a cotton bale, it will point to the North again."), name)
		else
			say(S("If you use it on wool, it will point to the North again."), name)
		end
	elseif iname == "rp_nav:map" then
		say(S("We live in a lovely place, don't we?"), name)
	elseif iname == "mobs:lasso" then
		say(S("It's used to capture large animals."), name)
	elseif iname == "rp_locks:pick" then
		say(S("Why are you carrying this around? Do you want crack open our locked chests?"), name)
	elseif iname == "mobs:net" then
		say(S("It's used to capture small animals."), name)
	elseif iname == "rp_farming:wheat_1" then
		say(S("Every kid knows seeds need soil, water and sunlight."), name)
	elseif iname == "rp_farming:wheat" then
		if profession == "farmer" then
			say(S("Sheep love to eat wheat. Give them enough wheat and they'll multiply!"), name)
		else
			say(S("We use wheat to make flour and bake bread."), name)
		end
	elseif iname == "rp_farming:flour" then
		say(S("Put it in a furnace to bake tasty bread."), name)
	elseif iname == "rp_farming:cotton_1" then
		if profession == "farmer" then
			say(S("Did you know cotton seed not only grow on dirt, but also on sand? But it still needs water."), name)
		elseif profession == "carpenter" then
			say(S("If you have grown a cotton plant, try using scissors to perform a precise cut."), name)
		else
			say(S("Every kid knows seeds need soil, water and sunlight."), name)
		end
	elseif iname == "rp_farming:cotton" then
		say(S("This can be used to make cotton bales."), name)
	elseif iname == "rp_default:book" then
		say(S("A truly epic story!"), name)
	elseif iname == "rp_default:pearl" then
		if profession == "tavernkeeper" then
			say(S("Ooh, a shiny pearl! It's beautiful."), name)
		else
			say(S("I heard the tavernkeeper likes these."), name)
		end
	elseif minetest.get_item_group(iname, "sapling") > 0 then
		local r = math.random(1,3)
		if r == 1 then
			say(S("Just place it on the ground and it will grow after a while."), name)
		elseif r == 2 then
			say(S("If the sapling refuses to grow, make sure it has enough open space above it."), name)
		else
			say(S("Try placing it on different grounds. It might grow differently."), name)
		end
	elseif minetest.get_item_group(iname, "shears") > 0 then
		say(S("Use this to trim plants and get wool from sheep."), name)
	elseif iname == "rp_default:papyrus" then
		if profession == "farmer" then
				say(S("Papyrus grows best on fertilized swamp dirt."), name)
		elseif profession == "carpenter" then
				say(S("Papyrus likes to grow next to water."), name)
		elseif profession == "tavernkeeper" then
				say(S("The papyrus grows tall in the swamp. But it can grow even taller."), name)
		else
				say(S("When I was I kid, I always liked to climb on the papyrus."), name)
		end
	elseif iname == "rp_default:cactus" then
		if profession == "farmer" then
			say(S("Cacti grow best on sand. They are also a food source, if you're really desperate."), name)
		elseif profession == "tavernkeeper" then
			say(S("This is the secret ingredient for my special drink. But don't tell anyone!"), name)
		else
			say(S("Now what can you possibly do with a cactus? I don't know!"), name)
		end
	elseif iname == "jewels:jewel" then
		if profession == "blacksmith" then
			say(S("Jewels are great! If you have a jeweller's workbench, you can enhance your tools."), name)
		else
			say(S("Did you know we sometimes sell jewels?"), name)
		end
	elseif iname == "rp_lumien:crystal_off" then
		say(S("This looks like it could be a good wall decoration."), name)
	elseif iname == "rp_default:torch_dead" then
		say(S("It’s burned out. Use flint and steel to kindle it."), name)
	elseif iname == "rp_default:torch_weak" then
		say(S("With flint and steel you could stabilize the flame."), name)
	elseif iname == "rp_default:torch" then
		say(S("Let’s light up some caves!"), name)
	elseif iname == "rp_default:flower" then
		say(S("A flower? I love flowers! Let's make the world bloom!"), name)
	elseif iname == "rp_default:flint_and_steel" then
		if minetest.settings:get_bool("tnt_enable", true) then
			say(S("You can use this to light up torches and bonfires and ignite TNT."), name)
		else
			say(S("You can use this to light up torches and bonfires."), name)
		end
	elseif iname == "rp_tnt:tnt" then
		if minetest.settings:get_bool("tnt_enable", true) then
			say(S("TNT needs to be ignited by a flint and steel."), name)
		else
			say(S("For some reason, TNT can't be ignited. Strange."), name)
		end
	elseif iname == "rp_fire:bonfire" then
		say(S("You need flint and steel to light the fire. But don't walk into the flame!"), name)
	elseif iname == "rp_bed:bed_foot" then
		if profession == "carpenter" then
			say(S("Isn't it stressful to carry this heavy bed around?"), name)
		else
			say(S("Sleeping makes the night go past in the blink of an eye."), name)
		end
	elseif iname == "rp_default:lump_bronze" then
		-- Classic parody of Friedrich Schiller’s “Das Lied von der Glocke” (works best in German)
		say(S("Hole in dirt, put bronze in. Bell’s complete, bim, bim, bim!"), name)
	elseif iname == "rp_default:apple" then
		say(S("Apples are so tasty!"), name)
	elseif iname == "rp_default:acorn" then
		if profession == "farmer" then
			say(S("Boars love to eat acorns! If you feed enough of these to them, they will multiply."), name)
		else
			say(S("Apples are so tasty!"), name)
		end
	elseif iname == "rp_default:reed_block" then
		say(S("Did you try to dry it in the furnace?"), name)
	elseif minetest.get_item_group(iname, "airweed") > 0 then
		if profession == "carpenter" then
			say(S("Airweed is an underwater plant with little capsules filled with air. Use it underwater to release air bubbles and catch some breath."), name)
		elseif profession == "butcher" then
			say(S("If you use the airweed plant, you will catch some breath. Other people near the plant will also benefit."), name)
		elseif profession == "tavernkeeper" then
			say(S("Airweed is very useful, but it can't give you breath from your hand. You must place it on the ground first."), name)
		elseif profession == "farmer" then
			say(S("You can multiply airweed with fertilizer."), name)
		else
			say(S("Airweed needs a moment to refill after you used it. The time it needs depends on the surface."), name)
		end
	elseif iname == "rp_default:alga" then
		if profession == "farmer" then
			say(S("If you fertilize the ground, an alga will grow higher."), name)
		elseif profession == "tavernkeeper" then
			say(S("The tallest algae always grow on alga blocks."), name)
		elseif profession == "carpenter" then
			say(S("If an alga tries to grow but something blocks its path, it'll stop growing, even if the barrier is removed later."), name)
		else
			say(S("Algae grow underwater in different heights."), name)
		end
	elseif iname == "rp_default:vine" then
		if profession == "farmer" then
			say(S("Place it at the ceiling and watch it grow."), name)
		elseif profession == "carpenter" then
			say(S("If you want the vine to stops growing, make a precise cut using scissors."), name)
		else
			say(S("It's climbing time!"), name)
		end
	elseif iname == "rp_default:dirt" then
		if profession == "farmer" then
			say(S("Many wild plants as well as wheat and cotton grow on dirt, but they grow better when it's fertilized."), name)
		else
			say(S("You're dirty!"), name)
		end
	elseif iname == "rp_default:swamp_dirt" then
		if profession == "farmer" then
			say(S("Swamp dirt is really interesting. The famous swamp oak grows on it, and papyrus also grows exceptionally well."), name)
		else
			say(S("Disgusting!"), name)
		end
	elseif iname == "rp_default:dry_dirt" then
		if profession == "farmer" then
			say(S("Not much grows on dry dirt."), name)
		else
			say(S("This dirt is as dry as my jokes."), name)
		end
	elseif iname == "rp_default:sand" then
		if profession == "farmer" then
			say(S("You can use sand to grow cacti."), name)
		else
			say(S("Be careful not to let it fall on your head!"), name)
		end

	elseif minetest.get_item_group(iname, "stone") > 0 then
		if profession == "butcher" then
			say(S("This is like my ex-lover's heart. Made out of stone."), name)
		else
			say_random("happy", name)
		end
	elseif minetest.get_item_group(iname, "food") > 0 then
		say(S("Stay healthy!"), name)
	else
		local r = math.random(1,3)
		if r == 1 then
			say_random("trade", name)
		elseif r == 2 then
			say(msgs.villager[profession], name)
		else
			say_random("happy", name)
		end
	end
end

return {
	say = say,
	say_random = say_random,
	talk_about_item = talk_about_item,
}
