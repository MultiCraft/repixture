--
-- Armor mod
--

local S = minetest.get_translator("rp_armor")
local FS = function(...) return minetest.formspec_escape(S(...)) end

local mod_player_skins = minetest.get_modpath("rp_player_skins") ~= nil

-- Gain for equip/unequip sounds
local SOUND_GAIN = 0.4

-- Boost protection value by this many percentage points if
-- wearing a full set of armor
local SAME_ARMOR_BONUS_PERCENT = 10

armor = {}

local armor_local = {}

-- Wear is wear per HP of damage taken

armor.materials = {
   -- material, craftitem, description, protection %, equip sound, unequip sound, pitch
   {"wood",         "group:planks",                  { S("Wooden Helmet"), S("Wooden Chestplate"), S("Wooden Boots") }, 10, "rp_armor_equip_wood", "rp_armor_unequip_wood"},
   {"steel",        "rp_default:ingot_steel",        { S("Steel Helmet"), S("Steel Chestplate"), S("Steel Boots") }, 20, "rp_armor_equip_metal", "rp_armor_unequip_metal", 0.90},
   {"chainmail",    "rp_armor:chainmail_sheet",      { S("Chainmail Helmet"), S("Chainmail Chestplate"), S("Chainmail Boots") }, 30, "rp_armor_equip_chainmail", "rp_armor_unequip_chainmail"},
   {"carbon_steel", "rp_default:ingot_carbon_steel", { S("Carbon Steel Helmet"), S("Carbon Steel Chestplate"), S("Carbon Steel Boots") }, 40, "rp_armor_equip_metal", "rp_armor_unequip_metal", 0.95},
   {"bronze",       "rp_default:ingot_bronze",       { S("Bronze Helmet"), S("Bronze Chestplate"), S("Bronze Boots") }, 60, "rp_armor_equip_metal", "rp_armor_unequip_metal", 1.0},
}

-- Usable slots

armor.slots = {"helmet", "chestplate", "boots"}

-- Formspec

local form_armor = rp_formspec.get_page("rp_formspec:2part")

form_armor = form_armor .. rp_formspec.default.player_inventory

form_armor = form_armor .. "listring[current_player;main]"

local startx = rp_formspec.default.start_point.x + 2.5
local starty = rp_formspec.default.start_point.y + 0.6
form_armor = form_armor .. "container["..startx..","..starty.."]"

form_armor = form_armor .. "label[1.25,0.5;"..minetest.formspec_escape(S("Helmet")).."]"
form_armor = form_armor .. "label[1.25,1.65;"..minetest.formspec_escape(S("Chestplate")).."]"
form_armor = form_armor .. "label[1.25,2.8;"..minetest.formspec_escape(S("Boots")).."]"

form_armor = form_armor .. rp_formspec.get_itemslot_bg(0, 0, 1, 3)
form_armor = form_armor .. "list[current_player;armor;0,0;1,3;]"

form_armor = form_armor .. "container_end[]"

form_armor = form_armor .. "listring[current_player;armor]"

function armor.get_formspec(name)
   local player = minetest.get_player_by_name(name)

   -- Base page
   local form = rp_formspec.get_page("rp_armor:armor", true)

   -- Player model with armor
   if form then
      if player then
         local base_skin = armor.get_base_skin(player)
         if base_skin then
            local full_skin = armor_local.get_texture(player, base_skin)
            if full_skin then
               local x = rp_formspec.default.start_point.x
               local y = rp_formspec.default.start_point.y + 0.25
               form = form .. "model["..x..","..y..";2,4;player_skins_skin_select_model;character.b3d;"..full_skin..";0,180;false;false;0,0]"
            end
         end
      end
   end

   -- Armor percentage
   local armor_full, armor_base, armor_bonus = armor.get_armor_protection(player)
   local x = rp_formspec.default.start_point.x
   local y = rp_formspec.default.start_point.y
   form = form .. "image["..(x+6.25)..","..(y+1.75)..";1,1;rp_armor_icon_protection.png]"
   form = form .. "tooltip["..(x+6.25)..","..(y+1.75)..";1,1;"..FS("Protection").."]"
   form = form .. "style_type[label;font_size=*1.75]"
   form = form .. "label["..(x+7.25)..","..(y+2.25)..";"..S("@1%", armor_full).."]"
   if armor_bonus ~= 0 then
      form = form .. "style_type[label;font_size=]"
      form = form .. "image["..(x+2.5)..","..(y+4.1)..";0.4,0.4;rp_armor_icon_bonus.png]"
      form = form .. "tooltip["..(x+2.5)..","..(y+4.1)..";0.4,0.4;"..FS("Protection bonus for full set").."]"
      form = form .. "label["..(x+3)..","..(y+4.3)..";"..S("+@1%", armor_bonus).."]"
   end

   return form
end

rp_formspec.register_page("rp_armor:armor", form_armor)
rp_formspec.register_invpage("rp_armor:armor", {
	get_formspec = armor.get_formspec,
})

rp_formspec.register_invtab("rp_armor:armor", {
   icon = "ui_icon_armor.png",
   tooltip = S("Armor"),
})

function armor.is_armor(itemname)
   local item = minetest.registered_items[itemname]

   if item ~= nil and item.groups ~= nil then
      if item.groups.is_armor then
	 return true
      end
   end
end

function armor.is_slot(itemname, slot)
   local match = string.find(itemname, "rp_armor:" .. slot .. "_")
   local matchbool = false
   if match ~= nil and match >= 1 then
      matchbool = true
   end
   return matchbool
end

function armor.get_base_skin(player)
   if minetest.get_modpath("rp_player_skins") ~= nil then
      return player_skins.get_skin(player:get_player_name())
   else
      return armor.player_skin
   end
end

-- Returns the full skin texture for `player`.
-- `base` is the player's base skin (without armor).
function armor_local.get_texture(player, base)
   local inv = player:get_inventory()

   local image = base

   for slot_index, slot in ipairs(armor.slots) do
      local itemstack = inv:get_stack("armor", slot_index)
      local itemname = itemstack:get_name()

      if armor.is_armor(itemname) and armor.is_slot(itemname, slot) then
	 local item = minetest.registered_items[itemname]
	 local mat = armor.materials[item.groups.armor_material][1]

	 image = image .. "^armor_" .. slot .. "_" .. mat ..".png"
      end
   end

   return image
end

-- Checks if the player qualifies for the `full_armor`
-- achievement and awards it if that's the case
function armor_local.check_achievement(player)
   local inv = player:get_inventory()

   local achv_ok = true
   for slot_index, slot in ipairs(armor.slots) do
      local itemstack = inv:get_stack("armor", slot_index)
      local itemname = itemstack:get_name()

      if itemstack:get_name() ~= "rp_armor:"..slot.."_bronze" then
         achv_ok = false
         break
      end
   end
   if achv_ok then
      achievements.trigger_achievement(player, "full_armor")
   end
end

-- Returns the player's current armor protection,
-- as a percentage.
-- Returns <full>, <base>, <bonus>
-- <full>: Full armor protection percentage (base + bonus)
-- <base>: Armor without bonus
-- <bonus>: Armor bonus
function armor.get_armor_protection(player)
   local match_mat = nil
   local match_amt = 0

   local inv = player:get_inventory()

   local armor_base = 0 -- armor percentage points (without bonus)
   local armor_bonus = 0 -- armor bonus percentage points

   for slot_index, slot in ipairs(armor.slots) do
      local itemstack = inv:get_stack("armor", slot_index)
      local itemname = itemstack:get_name()

      if armor.is_armor(itemname) then
	 local item = minetest.registered_items[itemname]

	 for mat_index, _ in ipairs(armor.materials) do
	    local mat = armor.materials[mat_index][1]

	    if mat_index == item.groups.armor_material then
	       armor_base = armor_base + item.groups.armor
	       if match_mat == nil then
		  match_mat = mat
	       end

	       if mat == match_mat then
		  match_amt = match_amt + 1
	       end

	       break
	    end
	 end
      end
   end

   -- If full set of same armor material, then boost armor protection
   if match_amt == #armor.slots then
      armor_bonus = SAME_ARMOR_BONUS_PERCENT
   end

   -- Final armor protection is sum of base armor and bonus,
   -- as percentage points
   local armor_all = math.min(100, armor_base + armor_bonus)
   -- Negative armor is allowed, but limited by Minetest's
   -- armor group value range.
   armor_all = math.max(armor_all, -32767+100)
   return armor_all, armor_base, armor_bonus
end

-- Returns the correct and relevant armor groups of player.
function armor_local.get_groups(player)
   local groups = {fleshy = 100}

   local armor_pct = armor.get_armor_protection(player)
   groups.fleshy = groups.fleshy - armor_pct

   if minetest.settings:get_bool("enable_damage", true) == false then
      groups.immortal = 1
   end

   return groups
end

-- Initialize armor for player
function armor_local.init(player)
   local inv = player:get_inventory()

   if inv:get_size("armor") ~= 3 then
      inv:set_size("armor", 3)
   end
end

-- This function must be called whenever the armor inventory has been changed
function armor.update(player)
   local groups = armor_local.get_groups(player)
   armor_local.check_achievement(player)
   player:set_armor_groups({fleshy = groups.fleshy, immortal = groups.immortal})

   local image = armor_local.get_texture(player, armor.get_base_skin(player))
   if image ~= rp_player.player_get_textures(player)[1] then
      rp_player.player_set_textures(player, {image})
   end
   rp_formspec.refresh_invpage(player, "rp_armor:armor")
end

-- Armor reduces player damage taken from nodes
minetest.register_on_player_hpchange(function(player, hp_change, reason)
   if reason.type == "node_damage" and hp_change < 0 then
      local pierce = 0
      local real_hp_change = hp_change
      if reason.node then
         -- Get ACTUAL damage from node def because engine reports
         -- a reduced hp_change if player is low on health
	 if reason.from == "engine" then
            local def = minetest.registered_nodes[reason.node]
            real_hp_change = -def.damage_per_second
	    if real_hp_change > 0 then
               -- In case of a healing node, we don't interfere ...
               return hp_change
            end
         end

         -- Get armor piercing
         pierce = minetest.get_item_group(reason.node, "armor_piercing")
         -- Armor does not protect at all at 100% armor piercing or above
         if pierce >= 100 then
            return real_hp_change
         end
      end
      -- Get player fleshy value
      local groups = armor_local.get_groups(player)
      local fleshy = groups.fleshy

      -- Armor piercing
      if pierce > 0 then
         local prot = 100 - fleshy
         prot = prot * ((100-pierce) / 100)
         fleshy = 100 - prot
      end

      -- Ratio for HP change
      local ratio = fleshy / 100
      if ratio < 0 then
         return real_hp_change
      end
      real_hp_change = -math.round(math.abs(real_hp_change * ratio))
      return real_hp_change
   end
   return hp_change
end, true)

local function on_newplayer(player)
   armor_local.init(player)
end

local function on_joinplayer(player)
   armor_local.init(player)
   armor.update(player)
end

local function on_respawnplayer(player)
   armor.update(player)
end

if minetest.get_modpath("rp_drop_items_on_die") ~= nil then
   drop_items_on_die.register_listname("armor")
end

minetest.register_on_newplayer(on_newplayer)
minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_respawnplayer(on_respawnplayer)

-- Chainmail

minetest.register_craftitem(
   "rp_armor:chainmail_sheet",
   {
      description = S("Chainmail Sheet"),

      inventory_image = "armor_chainmail.png",
      wield_image = "armor_chainmail.png",

      stack_max = 20,
})

crafting.register_craft(
   {
      output = "rp_armor:chainmail_sheet 3",
      items = {
         "rp_default:ingot_steel 5",
      }
})

-- Armor pieces

for mat_index, matdef in ipairs(armor.materials) do

   local mat = matdef[1]

   local armor_def = math.floor(matdef[4] / #armor.slots)

   for s, slot in ipairs(armor.slots) do

      minetest.register_craftitem(
	 "rp_armor:" .. slot .. "_" .. mat,
	 {
	    description = matdef[3][s],

	    inventory_image = "armor_" .. slot .. "_" .. mat .. "_inventory.png",
	    wield_image = "armor_" .. slot .. "_" .. mat .. "_inventory.png",

	    groups = {
	       is_armor = 1,
	       armor = armor_def,
	       armor_material = mat_index,
	       armor_slot = s,
	    },

            -- Allow to equip armor from wieldhand
            on_use = function(itemstack, user, pointed_thing)
               local inv = user:get_inventory()
               local slotstack = inv:get_stack("armor", s)
               local armor_changed = false
               if slotstack:is_empty() then
                  -- Empty slot: Equip armor
                  inv:set_stack("armor", s, itemstack)
                  itemstack:take_item()
                  armor_changed = true
               else
                  -- Occupied slot: Exchange armor
                  itemstack, slotstack = slotstack, itemstack
                  inv:set_stack("armor", s, slotstack)
                  armor_changed = true
               end
               if armor_changed then
                  minetest.sound_play({name=matdef[5] or "rp_armor_equip_metal", gain=SOUND_GAIN, pitch=matdef[7]}, {object=user}, true)
                  armor.update(user)
                  return itemstack
               end
            end,

	    stack_max = 1,

            _rp_armor_material = mat,
      })
   end

   crafting.register_craft(
      {
	 output = "rp_armor:helmet_" .. mat,
	 items = {
            matdef[2] .. " 5",
	 }
   })

   crafting.register_craft(
      {
	 output = "rp_armor:chestplate_" .. mat,
	 items = {
            matdef[2] .. " 8",
	 }
   })

   crafting.register_craft(
      {
	 output = "rp_armor:boots_" .. mat,
	 items = {
            matdef[2] .. " 6",
	 }
   })

end

-- Only allow armor items to be put into armor slots
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if action == "move" and inventory_info.to_list == "armor" then
       local stack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
       local name = stack:get_name()
       if minetest.get_item_group(name, "is_armor") ~= 1 then
           return 0
       end
       local slot = minetest.get_item_group(name, "armor_slot")
       if not inventory:get_stack("armor", slot):is_empty() then
           return 0
       end
    elseif action == "put" and inventory_info.listname == "armor" then
       local name = inventory_info.stack:get_name()
       if minetest.get_item_group(name, "is_armor") ~= 1 then
           return 0
       end
       local slot = minetest.get_item_group(name, "armor_slot")
       if not inventory:get_stack("armor", slot):is_empty() then
           return 0
       end
    end
end)

-- Move armor items to correct slot
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    local sound  -- 1 == equip, 2 = unequip

    local armorname, armorstack
    if action == "move" then
       armorstack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
       armorname = armorstack:get_name()
    elseif action == "put" or action == "take" then
       armorstack = inventory_info.stack
       armorname = armorstack:get_name()
    end
    if action == "move" and inventory_info.to_list == "armor" then
       local slot = minetest.get_item_group(armorname, "armor_slot")
       if slot ~= inventory_info.to_index then
           inventory:set_stack("armor", inventory_info.to_index, "")
           inventory:set_stack("armor", slot, armorstack)
       end
       sound = 1
    elseif action == "put" and inventory_info.listname == "armor" then
       local slot = minetest.get_item_group(armorname, "armor_slot")
       if slot ~= inventory_info.to_index then
           inventory:set_stack("armor", inventory_info.index, "")
           inventory:set_stack("armor", slot, armorstack)
       end
       sound = 1
    end
    if action == "move" then
        if inventory_info.to_list == "armor" then
            sound = 1
            armor.update(player)
        elseif inventory_info.from_list == "armor" then
            sound = 2
            armor.update(player)
        end
    elseif inventory_info.listname == "armor" then
        if action == "put" then
           sound = 1
           armor.update(player)
        elseif action == "take" then
           sound = 2
           armor.update(player)
        end
    end
    local equip_sound = "rp_armor_equip_metal"
    local unequip_sound = "rp_armor_unequip_metal"
    local pitch
    if armorname then
       local itemdef = minetest.registered_items[armorname]
       if itemdef and itemdef._rp_armor_material then
          for a=1, #armor.materials do
             local arm = armor.materials[a]
             if arm[1] == itemdef._rp_armor_material then
                equip_sound = arm[5] or "rp_armor_equip_metal"
                unequip_sound = arm[6] or "rp_armor_unequip_metal"
                pitch = arm[7]
                break
             end
          end
       end
    end
    if sound == 1 then
        minetest.sound_play({name=equip_sound, gain=SOUND_GAIN, pitch=pitch}, {object=player}, true)
    elseif sound == 2 then
        minetest.sound_play({name=unequip_sound, gain=SOUND_GAIN, pitch=pitch}, {object=player}, true)
    end
end)

-- Wooden armor fuel recipes
minetest.register_craft({
   type = "fuel",
   recipe = "rp_armor:helmet_wood",
   burntime = 10
})
minetest.register_craft({
   type = "fuel",
   recipe = "rp_armor:chestplate_wood",
   burntime = 16
})
minetest.register_craft({
   type = "fuel",
   recipe = "rp_armor:boots_wood",
   burntime = 12
})

-- Achievements

achievements.register_achievement(
   "armored",
   {
      title = S("Armored"),
      description = S("Craft a piece of armor."),
      times = 1,
      craftitem = "group:is_armor",
      item_icon = "rp_armor:chestplate_wood",
      difficulty = 1.9,
})

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 6
   "full_armor",
   {
      title = S("Skin of Bronze"),
      description = S("Equip a full suit of bronze armor."),
      times = 1,
      icon = "rp_armor_achievement_full_armor.png",
      difficulty = 6,
})

if minetest.get_modpath("tt") then
	tt.register_snippet(function(itemstring)
		if minetest.get_item_group(itemstring, "is_armor") == 1 then
			local a = minetest.get_item_group(itemstring, "armor")
			return S("Protection: +@1%", a)
		end
	end)
end

dofile(minetest.get_modpath("rp_armor").."/aliases.lua")
