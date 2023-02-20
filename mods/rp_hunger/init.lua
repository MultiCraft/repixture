--
-- Hunger mod
-- originally from Nodetest
-- Tweaked by Kaadmy and Wuzzy, for Repixture
--

local S = minetest.get_translator("rp_hunger")

hunger = {}

-- If enabled, show advanced player hunger values in the HUD
-- and the saturation value of foods in their item tooltips
local HUNGER_DEBUG = minetest.settings:get_bool("hunger_debug", false)

-- Maximum possible hunger value
hunger.MAX_HUNGER = 20

-- Maximum possible saturation value
hunger.MAX_SATURATION = 100

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

local mod_achievements = minetest.get_modpath("rp_achievements") ~= nil

-- Per-player userdata

local userdata = {}

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

-- play eating sound
-- * pos: Position
-- * player: Sound attached to player
-- * is_full: If true, play a different sound when the sound
--   should symbolize fullness (hunger and saturation at max)
local function play_eat_sound(pos, player, is_full)
   local pitch
   if is_full then
      pitch = 0.9
   end
   minetest.sound_play("hunger_eat", {pos = pos, max_hear_distance = 8, object=player, pitch=pitch}, true)
end

-- Loading and saving

local function save_hunger()
   local f = io.open(hunger_file, "w")

   for name, data in pairs(userdata) do
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

         if not userdata[name] then
            userdata[name] = {
               hunger = hunger.MAX_HUNGER,
               active = 0,
               moving = 0,
               saturation = 0,
            }
         end

         if hnger then
            userdata[name].hunger = hnger
         end
         if sat then
            userdata[name].saturation = sat
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

local function update_bar(player)
   if not player then
      return
   end
   if minetest.settings:get_bool("enable_damage") == false then
      return
   end

   local name = player:get_player_name()

   if HUNGER_DEBUG then
      local getval = function(valtype)
         local val
         if valtype == "step" then
            val = player_step[name]
         elseif valtype == "health_step" then
            val = player_health_step[name]
         else
            val = userdata[name][valtype]
         end
         return tostring(val)
      end
      local text = S("Hunger Debug:").."\n"
      if minetest.settings:get_bool("hunger_enable", true) then
         -- Intentionally untranslated as these are technical values
         text = text .. "hunger = " .. getval("hunger") .. "\n"
         text = text .. "saturation = " .. getval("saturation") .. "\n"
         text = text .. "moving = " .. getval("moving") .. "\n"
         text = text .. "active = " .. getval("active") .. "\n"
         text = text .. "step = " .. getval("step") .. "\n"
      else
         text = text .. S("<hunger disabled>").."\n"
      end
      -- Intentionally untranslated as this is a technical value
      text = text .. "health_step = " .. getval("health_step")

      if player_debughud[name] then
          player:hud_change(player_debughud[name], "text", text)
      else
         player_debughud[name] = player:hud_add(
	 {
	    hud_elem_type = "text",
            position = {x=0.75,y=1.0},
            text = text,
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
      player:hud_change(player_bar[name], "number", userdata[name].hunger)
   else
      player_bar[name] = player:hud_add(
	 {
	    hud_elem_type = "statbar",
	    position = {x=0.5,y=1.0},
	    text = "hunger.png",
	    text2 = "hunger.png^[colorize:#666666:255",
	    number = userdata[name].hunger,
	    item = hunger.MAX_HUNGER,
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
   if not userdata[name] then
      return
   end
   userdata[name].active = userdata[name].active + 2
   if HUNGER_DEBUG then
      update_bar(player)
   end
end

local function on_placenode(pos, node, player)
   if not player then
      return
   end

   local name = player:get_player_name()

   userdata[name].active = userdata[name].active + 2
   if HUNGER_DEBUG then
      update_bar(player)
   end
end

local function on_joinplayer(player)
   local name = player:get_player_name()

   if not userdata[name] then
      userdata[name] = {
         hunger = hunger.MAX_HUNGER,
         active = 0,
         moving = 0,
         saturation = 0,
      }
   end
   player_step[name] = 0
   player_health_step[name] = 0

   update_bar(player)
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   player_bar[name] = nil
   player_debughud[name] = nil
   userdata[name] = nil
   player_step[name] = nil
   player_health_step[name] = nil
end

local function on_respawnplayer(player)
   local name = player:get_player_name()

   userdata[name].hunger = hunger.MAX_HUNGER
   userdata[name].saturation = 0
   userdata[name].active = 0
   userdata[name].moving = 0
   player_step[name] = 0
   player_health_step[name] = 0
   update_bar(player)

   delayed_save()
end

local function on_respawnplayer_nohunger(player)
   local name = player:get_player_name()
   player_health_step[name] = 0

   if HUNGER_DEBUG then
      update_bar(player)
   end
end

local function on_item_eat(hp_change, replace_with_item, itemstack,
                           player, pointed_thing)
   if not player then
      return
   end
   if not hp_change then
      minetest.log("error", "[rp_hunger] minetest.item_eat called with nil hp_change (item="..itemstack:get_name()..")!")
      return
   end

   local food = 0
   local saturation = 0

   if type(hp_change) == "table" then
      -- Legacy support for old Repixture versions: table form:
      -- { hp = <food points>, sat = <saturation }
      food = hp_change.hp
      saturation = hp_change.sat
   elseif type(hp_change) == "number" then
      -- Recommended method: Try to take food data from item definition
      local def = itemstack:get_definition()
      if def then
         food = def._rp_hunger_food
         saturation = def._rp_hunger_sat
         if not food or not saturation then
            minetest.log("error", "[rp_hunger] Missing _rp_hunger_food and/or _rp_hunger_sat field in item definition (item="..itemstack:get_name()..")!")
            return
         end
      else
         -- Fallback
         if not food then
            food = 0
         end
         if not saturation then
            saturation = 0
         end
      end
   else
      minetest.log("error", "[rp_hunger] minetest.item_eat called with invalid hp_change (item="..itemstack:get_name()..")!")
      return
   end

   local name = player:get_player_name()

   userdata[name].hunger = userdata[name].hunger + food


   userdata[name].hunger = math.min(hunger.MAX_HUNGER, userdata[name].hunger)
   userdata[name].saturation = math.min(hunger.MAX_SATURATION, userdata[name].saturation
                                                  + saturation)

   local headpos  = player:get_pos()

   headpos.y = headpos.y + 1
   local full = userdata[name].saturation >= hunger.MAX_SATURATION and userdata[name].hunger >= hunger.MAX_HUNGER
   play_eat_sound(headpos, player, full)
   local particle
   if full then
      particle = "rp_hud_particle_eatpuff_full.png"
   else
      particle = "rp_hud_particle_eatpuff.png"
   end

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
         texture = {
            name = particle,
            scale_tween = { 1, 0, start = 0.75 },
         },
   })

   minetest.after(0.15, function(name)
         if particlespawners[name] then
                 minetest.delete_particlespawner(particlespawners[name])
         end
   end, name)

   if mod_achievements then
      achievements.trigger_subcondition(player, "eat_everything", itemstack:get_name())
   end
   player_effects.apply_effect(player, "hunger_eating")

   update_bar(player)
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
         -- health regeneration
         player:set_hp(hp+1, { type = "set_hp", from = "mod", _reason_precise = "regenerate" })
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

      userdata[name].moving = math.max(0, moving)
   end

   for _,player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      local hp = player:get_hp()

      if userdata[name] == nil then
         userdata[name] = {
            hunger = hunger.MAX_HUNGER,
            active = 0,
            moving = 0,
            saturation = 0,
         }
      end

      if not player_step[name] then
         player_step[name] = 0
      end

      userdata[name].active = userdata[name].active +
         userdata[name].moving

      player_step[name] = player_step[name] + userdata[name].active + 1

      userdata[name].saturation = userdata[name].saturation - 1

      if userdata[name].saturation <= 0 then
         userdata[name].saturation = 0
         if player_step[name] >= 24 then -- how much the player has been active
            player_step[name] = 0
            local oldhng = userdata[name].hunger
            userdata[name].hunger = userdata[name].hunger - 1
            if (oldhng == HUNGER_WARNING_1 or oldhng == HUNGER_WARNING_2) and hp >= 0 then
               minetest.chat_send_player(name, minetest.colorize("#ff0", S("You are hungry.")))
               local pos_sound  = player:get_pos()
               minetest.sound_play({name="hunger_hungry"}, {pos=pos_sound, max_hear_distance=3, object=player}, true)
            end
            if userdata[name].hunger <= HUNGER_STARVE_LEVEL and hp >= 0 then
               local old_hp = hp
               -- Hurt player due to starving
               player:set_hp(hp - 1, { type = "set_hp", from = "mod", _reason_precise = "starve" })
               userdata[name].hunger = 0
               if hp > 1 then
                  minetest.chat_send_player(name, minetest.colorize("#f00", S("You are starving.")))
               elseif old_hp > 0 then
                  minetest.chat_send_player(name, minetest.colorize("#f00", S("You starved to death.")))
               end
            end
         end
      end

      userdata[name].active = 0

      health_step(player, userdata[name].hunger)

      update_bar(player)
   end

   delayed_save()
end

-- Eating food when hunger is disabled.
-- This just removes the food.
local function fake_on_item_eat(hp_change, replace_with_item, itemstack,
                                player, pointed_thing)
   local headpos  = player:get_pos()
   headpos.y = headpos.y + 1
   play_eat_sound(headpos, player, true)
   if mod_achievements then
      achievements.trigger_subcondition(player, "eat_everything", itemstack:get_name())
   end

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
         update_bar(player)
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

  -- Public API functions.
  -- Note this mod itself sets the hunger and saturation directly
  function hunger.get_hunger(playername)
     return userdata[playername].hunger
  end
  function hunger.get_saturation(playername)
     return userdata[playername].saturation
  end
  function hunger.set_hunger(playername, hnger)
     userdata[playername].hunger = math.floor(math.max(0, math.min(hunger.MAX_HUNGER, hnger)))
     local player = minetest.get_player_by_name(playername)
     update_bar(player)
  end
  function hunger.set_saturation(playername, saturation)
     userdata[playername].saturation = math.floor(math.max(0, math.min(hunger.MAX_SATURATION, saturation)))
     local player = minetest.get_player_by_name(playername)
     update_bar(player)
  end
else
   minetest.register_on_leaveplayer(on_leaveplayer)
   minetest.register_on_item_eat(fake_on_item_eat)
   minetest.register_on_respawnplayer(on_respawnplayer_nohunger)
   minetest.register_globalstep(on_globalstep_nohunger)

   -- Public API functions are no-op if hunger disabled
   function hunger.get_hunger() return nil end
   function hunger.get_saturation() return nil end
   function hunger.set_hunger() return end
   function hunger.set_saturation() return end
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
      icon = "rp_hunger_effect_eating.png",
})

if mod_achievements then
	minetest.register_on_mods_loaded(function()
		local all_foods, all_foods_readable = {}, {}
		for k, v in pairs(minetest.registered_items) do
			if minetest.get_item_group(k, "food") > 0 then
				table.insert(all_foods, k)
				table.insert(all_foods_readable, ItemStack(v):get_short_description())
			end
		end

		achievements.register_achievement(
		   "eat_everything",
		   {
		      title = S("Gourmet"),
		      description = S("Eat everything that can be eaten."),
		      subconditions = all_foods,
		      subconditions_readable = all_foods_readable,
		      times = 0,
		      icon = "rp_hunger_achievement_eat_everything.png",
		      difficulty = 6.9,
		})

	end)
end

minetest.register_chatcommand("hunger", {
	description = S("Set hunger level of player or yourself"),
	privs = { server = true },
	params = S("[<player>] <hunger>"),
	func = function(playername, param)
		-- Set hunger of specified target player
		local target, hungr = string.match(param, "^([a-zA-Z0-9-_]+) (~?-?[0-9]+)$")
		if target and hungr then
			local player = minetest.get_player_by_name(target)
			if not player then
				return false, S("Player is not online.")
			end
			local current_hungr = hunger.get_hunger(target)
			hungr = minetest.parse_relative_number(hungr, current_hungr)
			if not hungr then
				return false
			end
			hunger.set_hunger(target, hungr)
			return true
		end

		-- Set hunger of commander
		local player = minetest.get_player_by_name(playername)
		if not player then
			return false, S("No player.")
		end
		hungr = string.match(param, "^(~?-?[0-9]+)$")
		local current_hungr = hunger.get_hunger(playername)
		hungr = minetest.parse_relative_number(hungr, current_hungr)
		if not hungr then
			return false
		end
		hunger.set_hunger(playername, hungr)
		hunger.set_saturation(playername, 0)
		return true
	end
})

if minetest.get_modpath("tt") ~= nil then
	tt.register_snippet(function(itemstring)
		local def = minetest.registered_items[itemstring]
		local msg
		local is_food = minetest.get_item_group(itemstring, "food") > 0
		if def and is_food then
			msg = S("Food item")
			if def._rp_hunger_food then
				msg = msg .."\n" .. S("Food points: +@1", def._rp_hunger_food)
			end
			if HUNGER_DEBUG and def._rp_hunger_sat then
				msg = msg .. "\n" .. S("Saturation points: +@1", def._rp_hunger_sat)
			end
		end
		return msg
	end)
end
