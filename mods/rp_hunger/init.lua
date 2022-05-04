--
-- Hunger mod
-- originally from Nodetest
-- Tweaked by Kaadmy and Wuzzy, for Repixture
--

local S = minetest.get_translator("rp_hunger")

hunger = {}

-- Per-player userdata

hunger.userdata = {}

local particlespawners = {}
local player_step = {}
local player_health_step = {}
local player_bar = {}

local hunger_file = minetest.get_worldpath() .. "/hunger.dat"
local saving = false

-- Seconds per hunger update, 2.0 is slightly fast
local timer_interval = tonumber(minetest.settings:get("hunger_step")) or 3.0
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
               hunger = 20,
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
	    item = 20,
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
end

local function on_placenode(pos, node, player)
   if not player then
      return
   end

   local name = player:get_player_name()

   hunger.userdata[name].active = hunger.userdata[name].active + 2
end

local function on_joinplayer(player)
   local name = player:get_player_name()

   if not hunger.userdata[name] then
      hunger.userdata[name] = {
         hunger = 20,
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
end

local function on_respawnplayer(player)
   local name = player:get_player_name()

   hunger.userdata[name].hunger = 20
   hunger.update_bar(player)

   delayed_save()
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


   hunger.userdata[name].hunger = math.min(20, hunger.userdata[name].hunger)
   hunger.userdata[name].saturation = math.min(100, hunger.userdata[name].saturation
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
            hunger = 20,
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
            if (oldhng == 5 or oldhng == 3) and hp >= 0 then
               minetest.chat_send_player(name, minetest.colorize("#ff0", S("You are hungry.")))
               local pos_sound  = player:get_pos()
               minetest.sound_play({name="hunger_hungry"}, {pos=pos_sound, max_hear_distance=3, object=player}, true)
            end
            if hunger.userdata[name].hunger <= 0 and hp >= 0 then
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
      hunger.update_bar(player)

      if player_health_step[name] == nil then player_health_step[name] = 0 end

      player_health_step[name] = player_health_step[name] + 1
      if hp > 0 and hp < 20 and player_health_step[name] >= 5
      and hunger.userdata[name].hunger >= 16 then
         player_health_step[name] = 0
         player:set_hp(hp+1)
      end
   end

   delayed_save()
end

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

if minetest.settings:get_bool("enable_damage") and minetest.settings:get_bool("hunger_enable") then

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
   minetest.register_on_item_eat(fake_on_item_eat)
end

player_effects.register_effect(
   "hunger_eating",
   {
      title = S("Eating"),
      description = S("You're eating food, which slows you down"),
      duration = 2,
      physics = {
         speed = 0.6,
      },
      icon = "hunger_effect_eating.png",
})
