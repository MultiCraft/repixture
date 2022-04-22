
-- Npc by TenPlus1
-- Modded by KaadmY
local S = minetest.get_translator("mobs")

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
	 follow = "gold:ingot_gold",
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
               local hp = self.object:get_hp()
               hp = math.min(20, hp + 1)
               self.object:set_hp(hp)
               local hp = self.object:get_hp()
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

            local iname = item:get_name()
            if minetest.get_item_group(iname, "sword") > 0 or minetest.get_item_group(iname, "spear") > 0 or iname == "rp_default:thistle" then
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

               if not self.npc_trade then
                  self.npc_trade = util.choice_element(
                     gold.trades[self.npc_type], gold.pr)
               end

               if not gold.trade(self.npc_trade, self.npc_type, clicker) then
                   if hp >= self.hp_max-7 then
                      if iname == "gold:ingot_gold" then
                          say_random("trade", name)
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
                          else
                              say(S("Every kid knows seeds need soil, water and sunlight."), name)
                          end
                      elseif iname == "rp_default:book" then
                          say(S("A truly epic story!"), name)
                      elseif iname == "rp_default:pearl" then
                          say(S("Ooh, a shiny pearl! Unfortunately, I don't know what it's good for."), name)
                      elseif minetest.get_item_group(iname, "sapling") > 0 then
                          say(S("Place it on the ground in sunlight and it will grow to a tree."), name)
                      elseif minetest.get_item_group(iname, "shears") > 0 then
                          say(S("Use this to trim plants and get wool from sheep."), name)
                      elseif iname == "rp_default:papyrus" then
                          if npc_type == "farmer" then
                              say(S("Papyrus likes to grow next to water."), name)
                          else
                              say(S("When I was I kid, I always liked to climb on the papyrus."), name)
                          end
                      elseif iname == "rp_default:cactus" then
                          if npc_type == "farmer" then
                              say(S("Cacti like to grow on sand. They are also a food source, if you're really desperate."), name)
                          elseif npc_type == "blacksmith" then
                              say(S("Ah, a cactus. You'd be surprised how well they burn in a furnace."), name)
                          else
                              say(S("Now what can you possibly do with a cactus? I don't know!"), name)
                          end
                      elseif iname == "jewels:jewel" then
                          if npc_type == "blacksmith" then
                             say(S("Jewels are great! If you have a jeweller's workbench, you can enhance your tools."), name)
                          else
                             say(S("Did you know we sometimes sell jewels?"), name)
                          end
                      elseif iname == "lumien:crystal_off" then
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
                             say(S("You can use this to light up torches and ignite TNT."), name)
                          else
                             say(S("You can use this to light up torches."), name)
                          end
                      elseif iname == "rp_tnt:tnt" then
                          if minetest.settings:get_bool("tnt_enable", true) then
                             say(S("TNT needs to be ignited by a flint and steel."), name)
                          else
                             say(S("For some reason, TNT can't be ignited. Strange."), name)
                          end
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
                          if npc_type == "farmer" then
                             say(S("Boars love to eat apples, too! If you feed enough of these to them, they will multiply."), name)
                          else
                             say(S("Apples are so tasty!"), name)
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
