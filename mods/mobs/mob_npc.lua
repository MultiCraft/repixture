
-- Npc by TenPlus1
-- Modded by KaadmY
local S = minetest.get_translator("mobs")

local npc_types = {
   { "farmer", S("Farmer") },
   { "tavernkeeper", S("Tavern Keeper") },
   { "blacksmith", S("Blacksmith") },
   { "butcher", S("Butcher") },
}

local msgs = {
    npc = {
        farmer = S("Hi! I'm a farmer. I sell farming goods."),
        tavernkeeper = S("Hi! I'm a tavernkeeper. I trade with assorted goods."),
        blacksmith = S("Hi! I'm a blacksmith. I sell metal products."),
        butcher = S("Hi! I'm a butcher. Want to buy something?"),
    },
    trade = {
        S("If you want to trade, show me a trading book."),
    },
    full_already = {
        S("I don't want to eat anymore!"),
        S("I'm not hungry!"),
        S("I'm full already."),
        S("I don't want food right now."),
    },
    eat_full = {
        S("Ah, now I'm fully energized!"),
        S("Thanks, now I'm filled up."),
        S("Thank you, now I feel much better!"),
    },
    eat_normal = {
        S("Munch-munch!"),
        S("Yummies!"),
        S("Yum-yum!"),
        S("Chomp!"),
        S("Thanks!"),
    },
    hungry = {
        S("I could use a snack."),
        S("I'm a bit hungry."),
    },
    happy = {
        S("Hello!"),
        S("Nice to see you."),
        S("Life is beautiful."),
        S("I feel good."),
        S("Have a nice day!"),
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
	 armor = 80,
	 collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	 visual = "mesh",
	 mesh = "mobs_npc.b3d",
	 drawtype = "front",
	 textures = {
	    {"mobs_npc1.png"},
	    {"mobs_npc2.png"},
	 },
	 makes_footstep_sound = true,
	 sounds = {},
	 walk_velocity = 2,
	 run_velocity = 3,
	 jump = true,
	 walk_chance = 50,
	 drops = {
	    {name = "default:planks_oak",
	     chance = 1, min = 1, max = 3},
	    {name = "default:apple",
	     chance = 2, min = 1, max = 2},
	    {name = "default:axe_stone",
	     chance = 5, min = 1, max = 1},
	 },
	 water_damage = 0,
	 lava_damage = 2,
	 light_damage = 0,
	 follow = "gold:ingot_gold",
	 view_range = 15,
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
	 on_spawn = function(self)
            self.npc_type = npc_type
         end,
	 on_rightclick = function(self, clicker)
            local item = clicker:get_wielded_item()
            local name = clicker:get_player_name()

            -- Reject all interaction when hostile
            if self.attack and self.attack.player == clicker then
              say_random("hostile", name)
              return
            end

            -- Feed to heal npc

            local hp = self.object:get_hp()
            local iname = item:get_name()
            if iname == "mobs:meat" or iname == "mobs:pork"
            or iname == "farming:bread" or iname == "default:apple"
            or iname == "default:clam" then

               -- return if full health
               if hp >= self.hp_max then
                  say_random("full_already", name)
                  return
               end

               if iname == "default:apple" then
                   hp = hp + 1
               elseif iname == "default:clam" then
                   hp = hp + 2
               else
                   hp = hp + 4
               end
               if hp >= self.hp_max then
                   hp = self.hp_max
                   say_random("eat_full", name)
               else
                   say_random("eat_normal", name)
               end
               self.object:set_hp(hp)

               -- take item
               if not minetest.settings:get_bool("creative_mode") then
                  item:take_item()
                  clicker:set_wielded_item(item)
               end

               -- Right clicking with trading book trades
               -- Trading is done in the gold mod
            else
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
                      if iname ~= "" then
                          say_random("trade", name)
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
                      say_random("hungry", name)
                   else
                      say_random("hurt", name)
                   end
               end
            end
         end,
   })

   mobs:register_egg("mobs:npc_" .. npc_type, npc_name, "mobs_npc_"..npc_type.."_inventory.png")
end
