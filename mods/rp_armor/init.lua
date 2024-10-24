--
-- Armor mod
--

local S = minetest.get_translator("rp_armor")
local FS = function(...) return minetest.formspec_escape(S(...)) end
local NS = function(s) return s end

local mod_player_skins = minetest.get_modpath("rp_player_skins") ~= nil

local hud_def_type_field
if minetest.features.hud_def_type_field then
    hud_def_type_field = "type"
else
    hud_def_type_field = "hud_elem_type"
end

-- Gain for equip/unequip sounds
local SOUND_GAIN = 0.4

armor = {}

-- Usable slots

armor.slots = {"helmet", "chestplate", "boots"}
armor.slot_names = {S("Helmet"), S("Chestplate"), S("Boots")}

local armor_local = {}

-- Wear is wear per HP of damage taken

-- List of armor materials (contains all armor definitions)
armor.materials = {}

-- This is a table in which each entry is a list with elements in that order:
local A_MAT = 1 -- material ID
local A_MODNAME = 2 -- mod name
local A_CRAFTITEM = 3 -- item used for crafting
local A_DESCRIPTIONS = 4 -- per-piece descripton list (in the order of armor.slots)
local A_PROTECTIONS = 5 -- per-piece protection % (in the order of armor.slots)
local A_SOUND_EQUIP = 6 -- equip sound
local A_SOUND_UNEQUIP = 7 -- unequip sound
local A_SOUND_PITCH = 8 -- pitch of all sounds
local A_FULL_SUIT_BONUS = 9 -- bonus for wearing full suit
local A_INVIMG_PREFIX = 10 -- prefix for inventory image file name

function armor.register_armor_set(mod_name, material_id, def)
   local protections
   -- If def.protections is number, use this number for all armor slots
   if type(def.protections) == "number" then
      protections = {}
      for i=1, #armor.slots do
         table.insert(protections, def.protections)
      end
   else
      -- Otherwise we assume def.protections is a table
      protections = def.protections
   end
   local matdef = {
      material_id, -- material ID
      mod_name, -- mod name
      def.craftitem, -- item used for crafting
      def.descriptions, -- list of description (in order of armor.slots)
      protections, -- protection % per-piece (in order of armor.slots)
      def.sound_equip, -- equip sound name
      def.sound_unequip, -- unequip sound name
      def.sound_pitch, -- sound pitch for all sounds
      def.full_suit_bonus or 0, -- bonus % for wearing full suit
      def.inventory_image_prefix, -- prefix for inventory image file name
   }
   table.insert(armor.materials, matdef)

   local mat = material_id
   local mat_index = #armor.materials
   for s, slot in ipairs(armor.slots) do
      local armor_protection = matdef[A_PROTECTIONS][s]

      minetest.register_craftitem(
	 mod_name .. ":" .. slot .. "_" .. mat,
	 {
	    description = matdef[A_DESCRIPTIONS][s],

	    inventory_image = matdef[A_INVIMG_PREFIX].."_" .. slot .. "_" .. mat .. "_inventory.png",
	    wield_image = matdef[A_INVIMG_PREFIX].."_" .. slot .. "_" .. mat .. "_inventory.png",
            _rp_armor_hud_image = matdef[A_INVIMG_PREFIX].."_"..slot .. "_" .. mat .. "_hud.png",

	    groups = {
	       is_armor = 1,
	       armor = armor_protection,
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
                  minetest.sound_play({name=matdef[A_SOUND_EQUIP] or "rp_armor_equip_metal", gain=SOUND_GAIN, pitch=matdef[A_SOUND_PITCH]}, {object=user}, true)
                  armor.update(user)
                  return itemstack
               end
            end,

	    stack_max = 1,

            _rp_armor_material = mat,
      })
   end

   if matdef[A_CRAFTITEM] then
      crafting.register_craft(
         {
	    output = mod_name..":helmet_" .. mat,
	    items = {
               matdef[A_CRAFTITEM] .. " 5",
	    }
      })

      crafting.register_craft(
         {
	    output = mod_name..":chestplate_" .. mat,
	    items = {
               matdef[A_CRAFTITEM] .. " 8",
	    }
      })

      crafting.register_craft(
         {
	    output = mod_name..":boots_" .. mat,
	    items = {
               matdef[A_CRAFTITEM] .. " 6",
	    }
      })
   end

end

-- Formspec

function armor.get_formspec(name)
   local player = minetest.get_player_by_name(name)
   if not player then
      return ""
   end

   -- Base page
   local form = rp_formspec.get_page("rp_armor:armor")

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

   -- Player inventory
   form = form .. rp_formspec.default.player_inventory

   local startx = rp_formspec.default.start_point.x
   local starty = rp_formspec.default.start_point.y
   form = form .. "container["..startx..","..starty.."]"

   -- Armor inventory stuff
   form = form .. "container[2.5,0.6]"

   -- Show armor icons in empty slots (must be *before* the inventory list)
   local inv = player:get_inventory()
   local slot_y = 0
   for a=1, #armor.slots do
      local itemstack = inv:get_stack("armor", a)
      if itemstack:is_empty() then
         form = form .. "image[0,"..slot_y..";1,1;armor_"..armor.slots[a].."_slot.png]"
      end
      slot_y = slot_y + 1 + rp_formspec.default.list_spacing.y
   end

   -- Armor inventory list
   form = form .. rp_formspec.get_itemslot_bg(0, 0, 1, 3)
   form = form .. "list[current_player;armor;0,0;1,3;]"
   form = form .. "listring[current_player;armor]"
   form = form .. "listring[current_player;main]"

   -- Show tooltips in empty slots (must be *after* the inventory list)
   local inv = player:get_inventory()
   local slot_y = 0
   for a=1, #armor.slots do
      local itemstack = inv:get_stack("armor", a)
      if itemstack:is_empty() then
         form = form .. "tooltip[0,"..slot_y..";1,1;"..minetest.formspec_escape(armor.slot_names[a]).."]"
      end
      slot_y = slot_y + 1 + rp_formspec.default.list_spacing.y
   end

   form = form .. "container_end[]"

   -- Armor percentage
   local armor_full, armor_base, armor_bonus = armor.get_armor_protection(player)
   form = form .. "image[5,1.75;1,1;rp_armor_icon_protection.png]"
   form = form .. "tooltip[5,1.75;1,1;"..FS("Protection").."]"
   form = form .. "style_type[label;font_size=*2]"
   form = form .. "label[6.1,2.25;"..S("@1%", armor_full).."]"
   if armor_bonus ~= 0 then
      form = form .. "style_type[label;font_size=]"
      form = form .. "image[2.45,4.05;0.5,0.5;rp_armor_icon_bonus.png]"
      form = form .. "tooltip[2.45,4.05;0.5,0.5;"..FS("Protection bonus for full set").."]"
      form = form .. "label[3,4.3;"..S("+@1%", armor_bonus).."]"
   end

   form = form .. "container_end[]"

   return form
end

-- Only the bare minimum for the base page, the rest is in get_formspec.
local form_armor = rp_formspec.get_page("rp_formspec:2part")
rp_formspec.register_page("rp_armor:armor", form_armor)

rp_formspec.register_invpage("rp_armor:armor", {
	get_formspec = armor.get_formspec,
})
rp_formspec.register_invtab("rp_armor:armor", {
   icon = "ui_icon_armor.png",
   icon_active = "ui_icon_armor_active.png",
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
   local wanted_slot_index
   for s=1, #armor.slots do
      if armor.slots[s] == slot then
         wanted_slot_index = s
         break
      end
   end
   if not wanted_slot_index and wanted_slot_index ~= 0 then
      return false
   end

   local item_slot_index = minetest.get_item_group(itemname, "armor_slot")
   if item_slot_index == 0 then
      return false
   end
   return wanted_slot_index == item_slot_index
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
	 local mat = armor.materials[item.groups.armor_material][A_MAT]
         local prefix = armor.materials[item.groups.armor_material][A_INVIMG_PREFIX]
	 image = image .. "^" .. prefix .. "_" .. slot .. "_" .. mat ..".png"
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
   local last_material_index

   for slot_index, slot in ipairs(armor.slots) do
      local itemstack = inv:get_stack("armor", slot_index)
      local itemname = itemstack:get_name()

      if armor.is_armor(itemname) then
	 local item = minetest.registered_items[itemname]

	 for mat_index, _ in ipairs(armor.materials) do
	    local mat = armor.materials[mat_index][A_MAT]
            last_material_index = mat_index

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
      armor_bonus = armor.materials[last_material_index][A_FULL_SUIT_BONUS]
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

local armor_icon_definitions = {}

for a=1, #armor.slots do
   armor_icon_definitions[a] = {
      [hud_def_type_field] = "image",
      position = { x=0.5, y=1 },
      text = "blank.png",
      direction = 0,
      size = { x=12, y=12 },
      scale = { x=2, y=2 },
      offset = { x=-274, y=-64 + 24*(a-1) },
      z_index = 1,
   }
end

local hud_ids = {}

-- Initialize armor for player
function armor_local.init(player)
   local name = player:get_player_name()
   local huds = {}
   for a=1, #armor_icon_definitions do
      local id = player:hud_add(armor_icon_definitions[a])
      table.insert(huds, id)
   end
   hud_ids[name] = huds

   local inv = player:get_inventory()

   if inv:get_size("armor") ~= #armor.slots then
      inv:set_size("armor", #armor.slots)
   end
end



-- This function must be called whenever the armor inventory has been changed
function armor.update(player)
   local groups = armor_local.get_groups(player)
   armor_local.check_achievement(player)
   player:set_armor_groups({fleshy = groups.fleshy, immortal = groups.immortal})

   local huds = hud_ids[player:get_player_name()]
   local inv = player:get_inventory()
   for a=1, #huds do
      local item = inv:get_stack("armor", a)
      if item:is_empty() then
         player:hud_change(huds[a], "text", "blank.png")
      else
         local idef = item:get_definition()
         local tex = idef._rp_armor_hud_image or "no_texture.png"
         player:hud_change(huds[a], "text", tex)
      end
   end

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

local function on_leaveplayer(player)
   hud_ids[player:get_player_name()] = nil
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
             if arm[A_MAT] == itemdef._rp_armor_material then
                equip_sound = arm[A_SOUND_EQUIP] or "rp_armor_equip_metal"
                unequip_sound = arm[A_SOUND_UNEQUIP] or "rp_armor_unequip_metal"
                pitch = arm[A_SOUND_PITCH]
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



-- General achievement that applies to any armor
-- Note: Armor-specific achievements go into register.lua.

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

if minetest.get_modpath("tt") then
	tt.register_snippet(function(itemstring)
		if minetest.get_item_group(itemstring, "is_armor") == 1 then
			local a = minetest.get_item_group(itemstring, "armor")
			return S("Protection: +@1%", a)
		end
	end)
end

dofile(minetest.get_modpath("rp_armor").."/register.lua")
dofile(minetest.get_modpath("rp_armor").."/aliases.lua")
