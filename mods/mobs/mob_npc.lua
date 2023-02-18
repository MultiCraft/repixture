
-- Npc by TenPlus1
-- Modded by KaadmY
local S = minetest.get_translator("mobs")

-- How many different trades an NPC offers
local NPC_TRADES_COUNT = 4

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

local npc_types = {
   { "farmer", S("Farmer") },
   { "tavernkeeper", S("Tavern Keeper") },
   { "blacksmith", S("Blacksmith") },
   { "butcher", S("Butcher") },
   { "carpenter", S("Carpenter") },
}

local msgs = {
    npc = {
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

for _, npc_type_table in pairs(npc_types) do
   local npc_type = npc_type_table[1]
   local npc_name = npc_type_table[2]
   mobs:register_mob(
      "mobs:npc_" .. npc_type,
      {
	 type = "npc",
	 mob_name = S("Villager"),
	 passive = false,
	 collides_with_objects = false,
	 damage = 3,
	 attack_type = "dogfight",
	 attacks_monsters = true,
	 hp_min = 10,
	 hp_max = 20,
	 breath_max = 11,
	 armor = 80,
	 collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	 visual = "mesh",
	 mesh = "mobs_npc.b3d",
	 drawtype = "front",
	 textures = {
	    {"mobs_npc1.png"},
	    {"mobs_npc2.png"},
	    {"mobs_npc3.png"},
	    {"mobs_npc4.png"},
	    {"mobs_npc5.png"},
	    {"mobs_npc6.png"},
	 },
	 makes_footstep_sound = true,
	 sounds = {},
	 walk_velocity = 2,
	 run_velocity = 3,
	 jump = true,
	 walk_chance = 50,
	 drops = {
	    {name = "rp_default:planks_oak",
	     chance = 1, min = 1, max = 3},
	    {name = "rp_default:apple",
	     chance = 2, min = 1, max = 2},
	    {name = "rp_default:axe_stone",
	     chance = 5, min = 1, max = 1},
	 },
	 water_damage = 0,
	 lava_damage = 2,
	 light_damage = 0,
	 group_attack = true,
	 follow = "rp_gold:ingot_gold",
	 view_range = 16,
	 owner = "",
	 animation = {
	    speed_normal = 30,
	    speed_run = 30,
	    stand_start = 0,
	    stand_end = 79,
	    walk_start = 168,
	    walk_end = 187,
	    run_start = 168,
	    run_end = 187,
	    punch_start = 200,
	    punch_end = 219,
	 },
         do_custom = function(self)
            -- Slowly heal NPC over time
            self.healing_counter = self.healing_counter + 1
            if self.healing_counter >= 7 then
               mobs:heal(self, 1)
               self.healing_counter = 0
            end
         end,
	 on_spawn = function(self)
            self.npc_type = npc_type
            self.healing_counter = 0
         end,
	 on_rightclick = function(self, clicker)
            local item = clicker:get_wielded_item()
            local name = clicker:get_player_name()

            -- Reject all interaction when hostile
            if self.attack and self.attack.player == clicker then
              say_random("hostile", name)
              return
            end

	    local npc_type = self.npc_type

            local iname = item:get_name()
            if npc_type ~= "blacksmith" and (minetest.get_item_group(iname, "sword") > 0 or minetest.get_item_group(iname, "spear") > 0) then
               say(S("Get this thing out of my face!"), name)
               return
            end

            achievements.trigger_achievement(clicker, "smalltalk")

            local hp = self.object:get_hp()
            do
               -- No trading if low health
               if hp < 5 then
                  say_random("hurt", name)
                  return
               end

               if not self.npc_trades or not self.npc_trade or not self.npc_trade_index then
                  self.npc_trades = {}
		  local possible_trades = table.copy(gold.trades[npc_type])
		  for t=1, NPC_TRADES_COUNT do
                     if #possible_trades == 0 then
                        break
                     end
                     local index = util.choice(possible_trades, gold.pr)
                     local trade = possible_trades[index]
                     table.insert(self.npc_trades, trade)
                     table.remove(possible_trades, index)
		  end
                  self.npc_trade_index = 1
		  if not self.npc_trade then
                     self.npc_trade = self.npc_trades[self.npc_trade_index]
                  end
		  minetest.log("action", "[mobs] NPC trades of NPC at "..minetest.pos_to_string(self.object:get_pos(), 1).." initialized")
               end

               if not gold.trade(self.npc_trade, npc_type, clicker, self, self.npc_trade_index, self.npc_trades) then
                   -- Good mood: Give hint or funny text
                   if hp >= self.hp_max-7 then

                      -- Fuel time / cooking hint by blacksmith
                      if npc_type == "blacksmith" then
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
			  if npc_type == "blacksmith" then
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
                          if npc_type == "farmer" then
                              say(S("This makes seeds grow faster. Place the fertilizer on soil, then plant the seed on top of it."), name)
                          else
                              say(S("Sorry, I don't know how to use this. Maybe ask a farmer."), name)
                          end
                      elseif minetest.get_item_group(iname, "bucket") > 0 then
                          if npc_type == "farmer" then
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
                          if npc_type == "farmer" then
                             say(S("Sheep love to eat wheat. Give them enough wheat and they'll multiply!"), name)
                          else
                             say(S("We use wheat to make flour and bake bread."), name)
                          end
                      elseif iname == "rp_farming:flour" then
                          say(S("Put it in a furnace to bake tasty bread."), name)
                      elseif iname == "rp_farming:cotton_1" then
                          if npc_type == "farmer" then
                              say(S("Did you know cotton seed not only grow on dirt, but also on sand? But it still needs water."), name)
                          elseif npc_type == "carpenter" then
                              say(S("If you have grown a cotton plant, try using scissors to perform a precise cut."), name)
                          else
                              say(S("Every kid knows seeds need soil, water and sunlight."), name)
                          end
                      elseif iname == "rp_farming:cotton" then
                          say(S("This can be used to make cotton bales.", name))
                      elseif iname == "rp_default:book" then
                          say(S("A truly epic story!"), name)
                      elseif iname == "rp_default:pearl" then
			  if npc_type == "tavernkeeper" then
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
                          if npc_type == "farmer" then
                              say(S("Papyrus grows best on fertilized swamp dirt."), name)
                          elseif npc_type == "carpenter" then
                              say(S("Papyrus likes to grow next to water."), name)
                          elseif npc_type == "tavernkeeper" then
                              say(S("The papyrus grows tall in the swamp. But it can grow even taller."), name)
                          else
                              say(S("When I was I kid, I always liked to climb on the papyrus."), name)
                          end
                      elseif iname == "rp_default:cactus" then
                          if npc_type == "farmer" then
                              say(S("Cacti grow best on sand. They are also a food source, if you're really desperate."), name)
                          elseif npc_type == "tavernkeeper" then
                              say(S("This is the secret ingredient for my special drink. But don't tell anyone!"), name)
                          else
                              say(S("Now what can you possibly do with a cactus? I don't know!"), name)
                          end
                      elseif iname == "jewels:jewel" then
                          if npc_type == "blacksmith" then
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
                          if npc_type == "carpenter" then
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
                          if npc_type == "farmer" then
                             say(S("Boars love to eat acorns! If you feed enough of these to them, they will multiply."), name)
                          else
                             say(S("Apples are so tasty!"), name)
                          end
                      elseif iname == "rp_default:reed_block" then
                          say(S("Did you try to dry it in the furnace?"), name)
                      elseif minetest.get_item_group(iname, "airweed") > 0 then
                          if npc_type == "carpenter" then
                             say(S("Airweed is an underwater plant with little capsules filled with air. Use it underwater to release air bubbles and catch some breath."), name)
                          elseif npc_type == "butcher" then
                             say(S("If you use the airweed plant, you will catch some breath. Other people near the plant will also benefit."), name)
                          elseif npc_type == "farmer" then
                             say(S("Airweed is very useful, but it can't give you breath from your hand. You must place it on the ground first."), name)
                          else
                             say(S("Airweed needs a moment to refill after you used it. The time it needs depends on the surface."), name)
                          end
                      elseif iname == "rp_default:alga" then
                          if npc_type == "farmer" then
                             say(S("If you fertilize the ground, an alga will grow higher."), name)
                          elseif npc_type == "tavernkeeper" then
                             say(S("The tallest algae always grow on alga blocks.", name))
                          elseif npc_type == "carpenter" then
                             say(S("If an alga tries to grow but something blocks its path, it'll stop growing, even if the barrier is removed later.", name))
                          else
                             say(S("Algae grow underwater in different heights."), name)
			  end
                      elseif iname == "rp_default:vine" then
                          if npc_type == "farmer" then
                             say(S("Place it at the ceiling and watch it grow."), name)
                          elseif npc_type == "carpenter" then
                             say(S("If you want the vine to stops growing, make a precise cut using scissors."), name)
                          else
                             say(S("It's climbing time!"), name)
                          end
                      elseif iname == "rp_default:dirt" then
                          if npc_type == "farmer" then
                             say(S("Many wild plants as well as wheat and cotton grow on dirt, but they grow better when it's fertilized."), name)
                          else
                             say(S("You're dirty!"), name)
                          end
                      elseif iname == "rp_default:swamp_dirt" then
                          if npc_type == "farmer" then
                             say(S("Swamp dirt is really interesting. The famous swamp oak grows on it, and papyrus also grows exceptionally well."), name)
                          else
                             say(S("Disgusting!"), name)
                          end
                      elseif iname == "rp_default:dry_dirt" then
                          if npc_type == "farmer" then
                             say(S("Not much grows on dry dirt."), name)
                          else
                             say(S("This dirt is as dry as my jokes."), name)
                          end
                      elseif iname == "rp_default:sand" then
                          if npc_type == "farmer" then
                             say(S("You can use sand to grow cacti."), name)
		          else
                             say(S("Be careful not to let it fall on your head!"), name)
                          end

                      elseif minetest.get_item_group(iname, "stone") > 0 then
                          if npc_type == "butcher" then
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
                             say(msgs.npc[npc_type], name)
                         else
                             say_random("happy", name)
                         end
                      end
                   elseif hp >= 5 then
                      say_random("exhausted", name)
                   else
                      say_random("hurt", name)
                   end
               end
            end
         end,
   })

   mobs:register_egg("mobs:npc_" .. npc_type, npc_name, "mobs_npc_"..npc_type.."_inventory.png")
end
