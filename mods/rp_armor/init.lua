--
-- Armor mod
--

local S = minetest.get_translator("rp_armor")

armor = {}

-- Wear is wear per HP of damage taken

armor.materials = {
   -- material      craftitem                     description     %
   {"wood",         "group:planks",               { S("Wooden Helmet"), S("Wooden Chestplate"), S("Wooden Boots") }, 10},
   {"steel",        "rp_default:ingot_steel",        { S("Steel Helmet"), S("Steel Chestplate"), S("Steel Boots") }, 20},
   {"chainmail",    "rp_armor:chainmail_sheet",      { S("Chainmail Helmet"), S("Chainmail Chestplate"), S("Chainmail Boots") }, 30},
   {"carbon_steel", "rp_default:ingot_carbon_steel", { S("Carbon Steel Helmet"), S("Carbon Steel Chestplate"), S("Carbon Steel Boots") }, 40},
   {"bronze",       "rp_default:ingot_bronze",       { S("Bronze Helmet"), S("Bronze Chestplate"), S("Bronze Boots") }, 60},
}

-- Usable slots

armor.slots = {"helmet", "chestplate", "boots"}

-- Formspec

local form_armor = rp_formspec.get_page("rp_default:2part")

form_armor = form_armor .. "list[current_player;main;0.25,4.75;8,4;]"
form_armor = form_armor .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_armor = form_armor .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)
form_armor = form_armor .. "listring[current_player;main]"

form_armor = form_armor .. "label[3.25,1;"..minetest.formspec_escape(S("Helmet")).."]"
form_armor = form_armor .. "label[3.25,2;"..minetest.formspec_escape(S("Chestplate")).."]"
form_armor = form_armor .. "label[3.25,3;"..minetest.formspec_escape(S("Boots")).."]"

form_armor = form_armor .. "list[current_player;armor;2.25,0.75;1,3;]"
form_armor = form_armor .. "listring[current_player;armor]"
form_armor = form_armor .. rp_formspec.get_itemslot_bg(2.25, 0.75, 1, 3)

rp_formspec.register_page("rp_armor:armor", form_armor)

function armor.get_formspec(name)
   local form = rp_formspec.get_page("rp_armor:armor")
   return form
end

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

function armor.get_texture(player, base)
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

function armor.get_groups(player)
   local groups = {fleshy = 100}

   local match_mat = nil
   local match_amt = 0

   local inv = player:get_inventory()

   local ach_ok = true
   for slot_index, slot in ipairs(armor.slots) do
      local itemstack = inv:get_stack("armor", slot_index)
      local itemname = itemstack:get_name()

      if itemstack:get_name() ~= "rp_armor:"..slot.."_bronze" then
         ach_ok = false
      end

      if armor.is_armor(itemname) then
	 local item = minetest.registered_items[itemname]

	 for mat_index, _ in ipairs(armor.materials) do
	    local mat = armor.materials[mat_index][1]

	    if mat_index == item.groups.armor_material then
	       groups.fleshy = groups.fleshy - item.groups.armor
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
   if ach_ok then
      achievements.trigger_achievement(player, "full_armor")
   end

   -- If full set of same armor material, then boost armor by 10%

   if match_amt == #armor.slots then
      groups.fleshy = groups.fleshy - 10
   end

   if minetest.settings:get_bool("enable_damage", true) == false then
      groups.immortal = 1
   end

   return groups
end

function armor.init(player)
   local inv = player:get_inventory()

   if inv:get_size("armor") ~= 3 then
      inv:set_size("armor", 3)
   end
end

-- This function must be called whenever the armor inventory has been changed
function armor.update(player)
   local groups = armor.get_groups(player)
   player:set_armor_groups({fleshy = groups.fleshy, immortal = groups.immortal})

   local image = armor.get_texture(player, armor.get_base_skin(player))
   if image ~= rp_player.player_get_textures(player)[1] then
      rp_player.player_set_textures(player, {image})
   end
end

local function on_newplayer(player)
   armor.init(player)
end

local function on_joinplayer(player)
   armor.init(player)
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
                  minetest.sound_play({name="armor_equip", object=user}, {gain=0.5}, true)
                  armor.update(user)
                  return itemstack
               end
            end,

	    stack_max = 1,
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
    if action == "move" and inventory_info.to_list == "armor" then
       local stack = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
       local name = stack:get_name()
       local slot = minetest.get_item_group(name, "armor_slot")
       if slot ~= inventory_info.to_index then
           inventory:set_stack("armor", inventory_info.to_index, "")
           inventory:set_stack("armor", slot, stack)
       end
       sound = 1
    elseif action == "put" and inventory_info.listname == "armor" then
       local name = inventory_info.stack:get_name()
       local slot = minetest.get_item_group(name, "armor_slot")
       if slot ~= inventory_info.to_index then
           inventory:set_stack("armor", inventory_info.index, "")
           inventory:set_stack("armor", slot, inventory_info.stack)
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
    if sound == 1 then
        minetest.sound_play({name="armor_equip", object=player}, {gain=0.5}, true)
    elseif sound == 2 then
        minetest.sound_play({name="armor_unequip", object=player}, {gain=0.5}, true)
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
})

achievements.register_achievement(
   "full_armor",
   {
      title = S("Skin of Bronze"),
      description = S("Equip a full suit of bronze armor."),
      times = 1,
      item_icon = "rp_armor:chestplate_bronze",
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
