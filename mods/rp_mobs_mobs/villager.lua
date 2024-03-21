-- Villager

local S = minetest.get_translator("rp_mobs_mobs")

-- How many different trades a villager offers 
local TRADES_COUNT = 4
-- Time after which to heal 1 HP (in seconds)
local HEAL_TIME = 7.0

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

local villager_types = {
	{ "farmer", S("Farmer") },
	{ "tavernkeeper", S("Tavern Keeper") },
	{ "blacksmith", S("Blacksmith") },
	{ "butcher", S("Butcher") },
	{ "carpenter", S("Carpenter") },
}

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
	}
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
-- * villager_type: Villager type
-- * iname: Item name (itemstring)
-- * name: Player name
local function talk_about_item(villager_type, iname, name)
	-- Fuel time / cooking hint by blacksmith
	if villager_type == "blacksmith" then
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
		if villager_type == "blacksmith" then
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
		say(S("You can put anything inside a bookshelf, not just books.", name))
	elseif iname == "rp_default:fertilizer" then
		if villager_type == "farmer" then
			say(S("This makes seeds grow faster. Place the fertilizer on soil, then plant the seed on top of it."), name)
		else
			say(S("Sorry, I don't know how to use this. Maybe ask a farmer."), name)
		end
	elseif minetest.get_item_group(iname, "bucket") > 0 then
		if villager_type == "farmer" then
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
		if villager_type == "farmer" then
			say(S("Sheep love to eat wheat. Give them enough wheat and they'll multiply!"), name)
		else
			say(S("We use wheat to make flour and bake bread."), name)
		end
	elseif iname == "rp_farming:flour" then
		say(S("Put it in a furnace to bake tasty bread."), name)
	elseif iname == "rp_farming:cotton_1" then
		if villager_type == "farmer" then
			say(S("Did you know cotton seed not only grow on dirt, but also on sand? But it still needs water."), name)
		elseif villager_type == "carpenter" then
			say(S("If you have grown a cotton plant, try using scissors to perform a precise cut."), name)
		else
			say(S("Every kid knows seeds need soil, water and sunlight."), name)
		end
	elseif iname == "rp_farming:cotton" then
		say(S("This can be used to make cotton bales.", name))
	elseif iname == "rp_default:book" then
		say(S("A truly epic story!"), name)
	elseif iname == "rp_default:pearl" then
		if villager_type == "tavernkeeper" then
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
		if villager_type == "farmer" then
				say(S("Papyrus grows best on fertilized swamp dirt."), name)
		elseif villager_type == "carpenter" then
				say(S("Papyrus likes to grow next to water."), name)
		elseif villager_type == "tavernkeeper" then
				say(S("The papyrus grows tall in the swamp. But it can grow even taller."), name)
		else
				say(S("When I was I kid, I always liked to climb on the papyrus."), name)
		end
	elseif iname == "rp_default:cactus" then
		if villager_type == "farmer" then
			say(S("Cacti grow best on sand. They are also a food source, if you're really desperate."), name)
		elseif villager_type == "tavernkeeper" then
			say(S("This is the secret ingredient for my special drink. But don't tell anyone!"), name)
		else
			say(S("Now what can you possibly do with a cactus? I don't know!"), name)
		end
	elseif iname == "jewels:jewel" then
		if villager_type == "blacksmith" then
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
		if villager_type == "carpenter" then
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
		if villager_type == "farmer" then
			say(S("Boars love to eat acorns! If you feed enough of these to them, they will multiply."), name)
		else
			say(S("Apples are so tasty!"), name)
		end
	elseif iname == "rp_default:reed_block" then
		say(S("Did you try to dry it in the furnace?"), name)
	elseif minetest.get_item_group(iname, "airweed") > 0 then
		if villager_type == "carpenter" then
			say(S("Airweed is an underwater plant with little capsules filled with air. Use it underwater to release air bubbles and catch some breath."), name)
		elseif villager_type == "butcher" then
			say(S("If you use the airweed plant, you will catch some breath. Other people near the plant will also benefit."), name)
		elseif villager_type == "tavernkeeper" then
			say(S("Airweed is very useful, but it can't give you breath from your hand. You must place it on the ground first."), name)
		elseif villager_type == "farmer" then
			say(S("You can multiply airweed with fertilizer."), name)
		else
			say(S("Airweed needs a moment to refill after you used it. The time it needs depends on the surface."), name)
		end
	elseif iname == "rp_default:alga" then
		if villager_type == "farmer" then
			say(S("If you fertilize the ground, an alga will grow higher."), name)
		elseif villager_type == "tavernkeeper" then
			say(S("The tallest algae always grow on alga blocks.", name))
		elseif villager_type == "carpenter" then
			say(S("If an alga tries to grow but something blocks its path, it'll stop growing, even if the barrier is removed later.", name))
		else
			say(S("Algae grow underwater in different heights."), name)
		end
	elseif iname == "rp_default:vine" then
		if villager_type == "farmer" then
			say(S("Place it at the ceiling and watch it grow."), name)
		elseif villager_type == "carpenter" then
			say(S("If you want the vine to stops growing, make a precise cut using scissors."), name)
		else
			say(S("It's climbing time!"), name)
		end
	elseif iname == "rp_default:dirt" then
		if villager_type == "farmer" then
			say(S("Many wild plants as well as wheat and cotton grow on dirt, but they grow better when it's fertilized."), name)
		else
			say(S("You're dirty!"), name)
		end
	elseif iname == "rp_default:swamp_dirt" then
		if villager_type == "farmer" then
			say(S("Swamp dirt is really interesting. The famous swamp oak grows on it, and papyrus also grows exceptionally well."), name)
		else
			say(S("Disgusting!"), name)
		end
	elseif iname == "rp_default:dry_dirt" then
		if villager_type == "farmer" then
			say(S("Not much grows on dry dirt."), name)
		else
			say(S("This dirt is as dry as my jokes."), name)
		end
	elseif iname == "rp_default:sand" then
		if villager_type == "farmer" then
			say(S("You can use sand to grow cacti."), name)
		else
			say(S("Be careful not to let it fall on your head!"), name)
		end

	elseif minetest.get_item_group(iname, "stone") > 0 then
		if villager_type == "butcher" then
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
			say(msgs.villager[villager_type], name)
		else
			say_random("happy", name)
		end
	end
end

local movement_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="stand still"})
	local yaw = math.random(0, 360) / 360 * (math.pi*2)
	local mt_yaw = rp_mobs.microtasks.set_yaw(yaw)
	rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.set_acceleration(rp_mobs.GRAVITY_VECTOR), task)
	rp_mobs.add_microtask_to_task(mob, mt_yaw, task)
	rp_mobs.add_microtask_to_task(mob, rp_mobs.microtasks.sleep(10), task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

local heal_decider = function(task_queue, mob)
	local mt_heal = rp_mobs.create_microtask({
		label = "regenerate health",
		on_start = function(self, mob)
			mob._custom_state.healing_timer = 0
		end,
		on_step = function(self, mob, dtime)
			-- Regrow wool
			-- Slowly heal over time
			mob._custom_state.healing_timer = mob._custom_state.healing_timer + dtime
			if mob._custom_state.healing_timer >= HEAL_TIME then
				rp_mobs.heal(mob, 1)
				mob._custom_state.healing_timer = 0
			end
		end,
		is_finished = function()
			return false
		end,
	})
	local task = rp_mobs.create_task({label="regenerate health"})
	rp_mobs.add_microtask_to_task(mob, mt_heal, task)
	rp_mobs.add_task_to_task_queue(task_queue, task)
end

local set_random_textures = function(mob)
	local r = math.random(1, 6)
	local tex = { "mobs_villager"..r..".png" }
	mob.object:set_properties({
		textures = tex,
	})
	mob._textures_adult = tex
end

for _, villager_type_table in pairs(villager_types) do
	local villager_type = villager_type_table[1]
	local villager_name = villager_type_table[2]

	rp_mobs.register_mob("rp_mobs_mobs:villager_"..villager_type, {
		description = villager_name,
		tags = { peaceful = 1 },
		drops = {
			{ name = "rp_default:planks_oak", chance = 1, min = 1, max = 3 },
			{ name = "rp_default:apple", chance = 2, min = 1, max = 2 },
			{ name = "rp_default:axe_stone", chance = 5, min = 1, max = 1 },
		},
		animations = {
			["idle"] = { frame_range = { x = 0, y = 79 }, default_frame_speed = 30 },
			["dead_static"] = { frame_range = { x = 0, y = 0 } },
			["walk"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
			["run"] = { frame_range = { x = 168, y = 187 }, default_frame_speed = 30 },
			["punch"] = { frame_range = { x = 200, y = 219 }, default_frame_speed = 30 },
		},
		front_body_point = vector.new(0, -0.6, 0.2),
		dead_y_offset = 0.6,
		default_sounds = {
			damage = "default_punch",
			death = "default_punch",
		},
		entity_definition = {
			initial_properties = {
				hp_max = 20,
				physical = true,
				collisionbox = { -0.35, -1.0, -0.35, 0.35, 0.77, 0.35},
				selectionbox = { -0.32, -1.0, -0.22, 0.32, 0.77, 0.22, rotate=true},
				visual = "mesh",
				mesh = "mobs_villager.b3d",
				-- Texture will be overridden on first spawn
				textures = { "mobs_villager1.png" },
				makes_footstep_sound = true,
				stepheight = 0.6,
			},
			get_staticdata = rp_mobs.get_staticdata_default,
			on_death = rp_mobs.on_death_default,
			on_punch = rp_mobs.on_punch_default,
			on_activate = function(self, staticdata)
				rp_mobs.init_mob(self)
				rp_mobs.restore_state(self, staticdata)
				if not self._textures_adult then
					set_random_textures(self)
				else
					self.object:set_properties({textures = self._textures_adult})
				end

				rp_mobs.init_fall_damage(self, true)
				rp_mobs.init_breath(self, true, {
					breath_max = 11,
					drowning_point = vector.new(0, 0.5, 0.1)
				})
				rp_mobs.init_node_damage(self, true, {
					node_damage_points={
						vector.new(0, -0.5, 0),
						vector.new(0, 0.5, 0),
					},
				})

				rp_mobs.init_tasks(self)
				local movement_task_queue = rp_mobs.create_task_queue(movement_decider)
				local heal_task_queue = rp_mobs.create_task_queue(heal_decider)
				rp_mobs.add_task_queue(self, movement_task_queue)
				rp_mobs.add_task_queue(self, heal_task_queue)

				self._villager_type = villager_type
			end,
			on_step = function(self, dtime, moveresult)
				rp_mobs.handle_dying(self, dtime)
				rp_mobs.scan_environment(self, dtime)
				rp_mobs.handle_environment_damage(self, dtime, moveresult)
				rp_mobs.handle_tasks(self, dtime, moveresult)
			end,
			on_rightclick = function(self, clicker)
				local item = clicker:get_wielded_item()
				local name = clicker:get_player_name()

				-- TODO: Reject all interaction when hostile
				if self.attack and self.attack.player == clicker then
					say_random("hostile", name)
					return
				end

				local villager_type = self._villager_type

				local iname = item:get_name()
				if villager_type ~= "blacksmith" and (minetest.get_item_group(iname, "sword") > 0 or minetest.get_item_group(iname, "spear") > 0) then
					say(S("Get this thing out of my face!"), name)
					return
				end

				achievements.trigger_achievement(clicker, "smalltalk")

				local hp = self.object:get_hp()
				local hp_max = self.object:get_properties().hp_max
				do
					-- No trading if low health
					if hp < 5 then
						say_random("hurt", name)
						return
					end

					if not self._trades or not self._trade or not self._trade_index then
						self._trades = {}
						local possible_trades = table.copy(gold.trades[villager_type])
						for t=1, TRADES_COUNT do
							if #possible_trades == 0 then
								break
							end
							local index = util.choice(possible_trades, gold.pr)
							local trade = possible_trades[index]
							table.insert(self._trades, trade)
							table.remove(possible_trades, index)
						end
						self._trade_index = 1
						if not self._trade then
							self._trade = self._trades[self._trade_index]
						end
						minetest.log("action", "[mobs] Villager trades of villager at "..minetest.pos_to_string(self.object:get_pos(), 1).." initialized")
					end

					if not gold.trade(self._trade, villager_type, clicker, self, self._trade_index, self._trades) then
						-- Good mood: Give hint or funny text
						if hp >= hp_max-7 then
							talk_about_item(villager_type, iname, name)
						elseif hp >= 5 then
							say_random("exhausted", name)
						else
							say_random("hurt", name)
						end
					end
				end
			end,
		},
	})

	rp_mobs.register_mob_item("rp_mobs_mobs:villager_" .. villager_type, "mobs_villager_"..villager_type.."_inventory.png")
end
