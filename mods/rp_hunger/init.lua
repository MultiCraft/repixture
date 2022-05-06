--
-- Hunger mod
-- originally from Nodetest
-- Tweaked by Kaadmy and Wuzzy, for Repixture
--

local S = minetest.get_translator("rp_hunger")

hunger = {}

-- If enabled, show advanced player hunger values
local HUNGER_DEBUG = false

-- Maximum possible hunger value
local MAX_HUNGER = 20

-- Maximum possible saturation value
local MAX_SATURATION = 100

-- Player heals if hunger is equal to or greater than this value
local HUNGER_HEAL_LEVEL = 16

-- Player starves (takes damage) if hunger is equal to or lower than this value
local HUNGER_STARVE_LEVEL = 0

-- Check if player needs healing every this number of hunger steps (see hunger_step setting below)
-- E.g. if hunger_step is 3.0 and this value is 5, player can be healed every 15 seconds (3*5).
local HEAL_EVERY_N_HEALTH_STEPS = 5

-- Warng the player about being hungry if hunger level drops to one of these values
local HUNGER_WARNING_1 = 5 -- first warning
local HUNGER_WARNING_2 = 3 -- second warning, must be lower than the first one

-- Player speed penalty when eating (speed multiplier)
local EATING_SPEED = 0.6
-- How long the speed penalty applies, in seconds
local EATING_SPEED_DURATION = 2.0

-- Per-player userdata

hunger.userdata = {}

local particlespawners = {}
local player_step = {}
local player_health_step = {}

local player_bar = {}
local player_debughud = {}

local hunger_file = minetest.get_worldpath() .. "/hunger.dat"
local saving = false

-- Seconds per hunger update, 2.0 is slightly fast
local timer_interval = tonumber(minetest.settings:get("hunger_step")) or 3.0
timer_interval = math.max(0.0, timer_interval)
local timer = 0

local function save_hunger()
   local f = io.open(hunger_file, "w")

   for name, data in pairs(hunger.userdata) do
      f:write(data.hunger .. " " .. data.saturation .. " " .. name .. "\n")
   end

   io.close(f)

   saving = false
end

local function delayed_save()
   if not saving then
      saving = true

      minetest.after(40, save_hunger)
   end
end

local function load_hunger()
   local f = io.open(hunger_file, "r")
   if f then
      repeat
	 local hnger = f:read("*n")
	 local sat = f:read("*n")
	 local name = f:read("*l")

	 if name == nil or sat == nil then
            break
         end

	 name = name:sub(2)

         if not hunger.userdata[name] then
            hunger.userdata[name] = {
               hunger = MAX_HUNGER,
               active = 0,
               moving = 0,
               saturation = 0,
            }
         end

         if hnger then
            hunger.userdata[name].hunger = hnger
         end
         if sat then
            hunger.userdata[name].saturation = sat
         end

      until f:read(0) == nil
      io.close(f)
   else
      save_hunger()
   end
end

local function on_load()
   load_hunger()
end

local function on_shutdown()
   save_hunger()
end

function hunger.update_bar(player)
   if not player then
      return
   end

   local name = player:get_player_name()

   if HUNGER_DEBUG then
      if player_debughud[name] then
          local text = "Hunger Debug:\n"
          if minetest.settings:get_bool("hunger_enable", true) then
             text = text .. "hunger = " .. tostring(hunger.userdata[name].hunger) .. "\n"
             text = text .. "saturation = " .. tostring(hunger.userdata[name].saturation) .. "\n"
             text = text .. "moving = " .. tostring(hunger.userdata[name].moving) .. "\n"
             text = text .. "active = " .. tostring(hunger.userdata[name].active) .. "\n"
             text = text .. "step = " .. tostring(player_step[name]) .. "\n"
          else
             text = text .. "<hunger disabled>\n"
	  end
          text = text .. "health_step = " .. tostring(player_health_step[name])
          player:hud_change(player_debughud[name], "text", text)
      else
         player_debughud[name] = player:hud_add(
	 {
	    hud_elem_type = "text",
            position = {x=0.75,y=1.0},
            text = "",
            number = 0xFFFFFFFF,
            alignment = {x=-1, y=-1},
	    scale = {x=100, y=100},
            size = {x=1, y=1},
            offset = {x=-32, y=-32},
            z_index = 1,
         })
      end
      if minetest.settings:get_bool("hunger_enable", true) == false then
         return
      end
   end

   if player_bar[name] then
      player:hud_change(player_bar[name], "number", hunger.userdata[name].hunger)
   else
      player_bar[name] = player:hud_add(
	 {
	    hud_elem_type = "statbar",
	    position = {x=0.5,y=1.0},
	    text = "hunger.png",
	    text2 = "hunger.png^[colorize:#666666:255",
	    number = hunger.userdata[name].hunger,
	    item = MAX_HUNGER,
	    dir = 0,
	    size = {x=24, y=24},
	    offset = {x=16, y=-(48+24+24)},
            z_index = 1,
      })
   end
end

local function on_dignode(pos, oldnode, player)
   if not player then
      return
   end

   local name = player:get_player_name()
   if not hunger.userdata[name] then
      return
   end
   hunger.userdata[name].active = hunger.userdata[name].active + 2
   if HUNGER_DEBUG then
      hunger.update_bar(player)
   end
end

local function on_placenode(pos, node, player)
   if not player then
      return
   end

   local name = player:get_player_name()

   hunger.userdata[name].active = hunger.userdata[name].active + 2
   if HUNGER_DEBUG then
      hunger.update_bar(player)
   end
end

local function on_joinplayer(player)
   local name = player:get_player_name()

   if not hunger.userdata[name] then
      hunger.userdata[name] = {
         hunger = MAX_HUNGER,
         active = 0,
         moving = 0,
         saturation = 0,
      }
   end

   hunger.update_bar(player)
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   player_bar[name] = nil
   player_debughud[name] = nil
   hunger.userdata[name] = nil
end

local function on_respawnplayer(player)
   local name = player:get_player_name()

   hunger.userdata[name].hunger = MAX_HUNGER
   hunger.userdata[name].saturation = 0
   hunger.userdata[name].active = 0
   hunger.userdata[name].moving = 0
   player_step[name] = 0
   player_health_step[name] = 0
   hunger.update_bar(player)

   delayed_save()
end

local function on_respawnplayer_nohunger(player)
   local name = player:get_player_name()
   player_health_step[name] = 0

   if HUNGER_DEBUG then
      hunger.update_bar(player)
   end
end

local function on_item_eat(hpdata, replace_with_item, itemstack,
                           player, pointed_thing)
   if not player then return end
   if not hpdata then return end

   local hp_change = 0
   local saturation = 2

   if type(hpdata) == "number" then
      hp_change = hpdata
   else
      hp_change = hpdata.hp
      saturation = hpdata.sat
   end

   local name = player:get_player_name()

   hunger.userdata[name].hunger = hunger.userdata[name].hunger + hp_change


   hunger.userdata[name].hunger = math.min(MAX_HUNGER, hunger.userdata[name].hunger)
   hunger.userdata[name].saturation = math.min(MAX_SATURATION, hunger.userdata[name].saturation
                                                  + saturation)

   local headpos  = player:get_pos()

   headpos.y = headpos.y + 1
   minetest.sound_play("hunger_eat", {pos = headpos, max_hear_distance = 8, object=player}, true)

   particlespawners[name] = minetest.add_particlespawner(
      {
         amount = 10,
         time = 0.1,
         minpos = {x = headpos.x - 0.3, y = headpos.y - 0.3, z = headpos.z - 0.3},
         maxpos = {x = headpos.x + 0.3, y = headpos.y + 0.3, z = headpos.z + 0.3},
         minvel = {x = -1, y = -1, z = -1},
         maxvel = {x = 1, y = 0, z = 1},
         minacc = {x = 0, y = 6, z = 0},
         maxacc = {x = 0, y = 1, z = 0},
         minexptime = 0.5,
         maxexptime = 1,
         minsize = 0.5,
         maxsize = 2,
         texture = "magicpuff.png"
   })

   minetest.after(0.15, function(name)
         if particlespawners[name] then
                 minetest.delete_particlespawner(particlespawners[name])
         end
   end, name)

   player_effects.apply_effect(player, "hunger_eating")

   hunger.update_bar(player)
   delayed_save()

   if not minetest.is_creative_enabled(name) then
       itemstack:take_item(1)
   end

   return itemstack
end

-- Healing routine for on_globalstep below
-- Heals player if this function was called enough times
-- (HEAL_EVERY_N_HEALTH_STEPS to be precise)
-- and player has a high enough hunger value (HUNGER_HEAL_LEVEL).
-- * player: Player to heal
-- * phunger: current player hunger. Can be nil, then hunger will be ignored
local function health_step(player, phunger)
   local name = player:get_player_name()
   if player_health_step[name] == nil then
      player_health_step[name] = 0
   end

   player_health_step[name] = player_health_step[name] + 1
   local hp = player:get_hp()
   if player_health_step[name] >= HEAL_EVERY_N_HEALTH_STEPS then
      player_health_step[name] = HEAL_EVERY_N_HEALTH_STEPS
      if hp > 0 and hp < minetest.PLAYER_MAX_HP_DEFAULT and (phunger == nil or phunger >= HUNGER_HEAL_LEVEL) then
         player_health_step[name] = 0
         player:set_hp(hp+1)
      end
   end
end

local function on_globalstep(dtime)
   timer = timer + dtime

   if timer < timer_interval then
      return
   end

   timer = 0

   for _,player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      local controls = player:get_player_control()
      local moving = 0

      if controls.up or controls.down or controls.left or controls.right then
         moving = moving + 1
      end

      if controls.sneak and not controls.aux1 then
         moving = moving - 1
      end

      if controls.jump then
         moving = moving + 1
      end

      if controls.aux1 then -- sprinting
         moving = moving + 3
      end

      hunger.userdata[name].moving = math.max(0, moving)
   end

   for _,player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      local hp = player:get_hp()

      if hunger.userdata[name] == nil then
         hunger.userdata[name] = {
            hunger = MAX_HUNGER,
            active = 0,
            moving = 0,
            saturation = 0,
         }
      end

      if not player_step[name] then
         player_step[name] = 0
      end

      hunger.userdata[name].active = hunger.userdata[name].active +
         hunger.userdata[name].moving

      player_step[name] = player_step[name] + hunger.userdata[name].active + 1

      hunger.userdata[name].saturation = hunger.userdata[name].saturation - 1

      if hunger.userdata[name].saturation <= 0 then
         hunger.userdata[name].saturation = 0
         if player_step[name] >= 24 then -- how much the player has been active
            player_step[name] = 0
            local oldhng = hunger.userdata[name].hunger
            hunger.userdata[name].hunger = hunger.userdata[name].hunger - 1
            if (oldhng == HUNGER_WARNING_1 or oldhng == HUNGER_WARNING_2) and hp >= 0 then
               minetest.chat_send_player(name, minetest.colorize("#ff0", S("You are hungry.")))
               local pos_sound  = player:get_pos()
               minetest.sound_play({name="hunger_hungry"}, {pos=pos_sound, max_hear_distance=3, object=player}, true)
            end
            if hunger.userdata[name].hunger <= HUNGER_STARVE_LEVEL and hp >= 0 then
               player:set_hp(hp - 1)
               hunger.userdata[name].hunger = 0
               if hp > 1 then
                  minetest.chat_send_player(name, minetest.colorize("#f00", S("You are starving.")))
               else
                  minetest.chat_send_player(name, minetest.colorize("#f00", S("You starved to death.")))
               end
            end
         end
      end

      hunger.userdata[name].active = 0

      health_step(player, hunger.userdata[name].hunger)

      hunger.update_bar(player)
   end

   delayed_save()
end

-- Eating food when hunger is disabled.
-- This just removes the food.
local function fake_on_item_eat(hpdata, replace_with_item, itemstack,
                                player, pointed_thing)
   local headpos  = player:get_pos()
   headpos.y = headpos.y + 1
   minetest.sound_play(
      "hunger_eat",
      {
         pos = headpos,
         max_hear_distance = 8,
         object = player,
   }, true)

   if not minetest.is_creative_enabled(player:get_player_name()) then
       itemstack:take_item(1)
   end

   return itemstack
end

-- If hunger is disabled, just heal players over time
local function on_globalstep_nohunger(dtime)
   timer = timer + dtime
   if timer < timer_interval then
      return
   end
   timer = 0
   for _,player in ipairs(minetest.get_connected_players()) do
      health_step(player, nil)
      if HUNGER_DEBUG then
         hunger.update_bar(player)
      end
   end
end

if minetest.settings:get_bool("enable_damage") and minetest.settings:get_bool("hunger_enable", true) then

   minetest.after(0, on_load)

   minetest.register_on_shutdown(on_shutdown)

   minetest.register_on_dignode(on_dignode)
   minetest.register_on_placenode(on_placenode)

   minetest.register_on_joinplayer(on_joinplayer)

   minetest.register_on_leaveplayer(on_leaveplayer)

   minetest.register_on_respawnplayer(on_respawnplayer)

   minetest.register_on_item_eat(on_item_eat)

   minetest.register_globalstep(on_globalstep)
else
   minetest.register_on_leaveplayer(on_leaveplayer)
   minetest.register_on_item_eat(fake_on_item_eat)
   minetest.register_on_respawnplayer(on_respawnplayer_nohunger)
   minetest.register_globalstep(on_globalstep_nohunger)
end

player_effects.register_effect(
   "hunger_eating",
   {
      title = S("Eating"),
      description = S("You're eating food, which slows you down"),
      duration = EATING_SPEED_DURATION,
      physics = {
         speed = EATING_SPEED,
      },
      icon = "hunger_effect_eating.png",
})
