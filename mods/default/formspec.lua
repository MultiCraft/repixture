
default.ui = {}

local S = minetest.get_translator("default")

-- Registered UI pages

default.ui.registered_pages = {
}

-- UI defaults

default.ui.default = {}

default.ui.current_page = {}

-- Colors

local listcolors = "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]"
default.ui.default.bg = "bgcolor[#00000000]"

-- bgcolor intentionally not included because it would make pause menu transparent, too :(
local formspec_prepend = listcolors

-- Group default items

default.ui.group_defaults = {
   fuzzy = "mobs:wool",
   planks = "default:planks",
   soil = "default:dirt",
   stone = "default:stone",
   tree = "default:tree",
   green_grass = "default:grass",
}
default.ui.group_names = {
   fuzzy = { S("Fuzzy"), S("Any fuzzy block") },
   planks = { S("Planks"), S("Any planks") },
   soil = { S("Soil"), S("Any soil") },
   stone = { S("Stone"), S("Any stone") },
   green_grass = { S("Green Grass Clump"), S("Any green grass clump") },
}

-- Itemslot backgrounds

function default.ui.get_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	 out = out .."image["..x+i..","..y+j..";1,1;ui_itemslot.png]"
      end
   end
   return out
end

function default.ui.get_hotbar_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	 out = out .."image["..x+i..","..y+j
            ..";1,1;ui_itemslot.png^ui_itemslot_dark.png]"
      end
   end
   return out
end

-- Buttons

function default.ui.image_button(x, y, w, h, name, image, tooltip)
   local image = minetest.formspec_escape(image)

   local tt = ""
   if tooltip then
      tt = "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"
   end

   return "image_button["..x..","..y..";"..w..","..h..";"
      ..image..";"..name..";;;false;"..image.."]"
      ..tt
end

function default.ui.button(x, y, w, h, name, label, noclip, tooltip)
   local nc = "false"

   if noclip then
      nc = "true"
   end

   local tt = ""
   if tooltip then
      tt = "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"
   end

   if w == 1 then
      return "image_button["..x..","..y..";"..w..","..h
         ..";ui_button_1w_inactive.png;"..name..";"..minetest.formspec_escape(label)..";"
         ..nc..";false;ui_button_1w_active.png]"
         ..tt
   elseif w == 2 then
      return "image_button["..x..","..y..";"..w..","..h
         ..";ui_button_2w_inactive.png;"..name..";"..minetest.formspec_escape(label)..";"
         ..nc..";false;ui_button_2w_active.png]"
         ..tt
   else
      return "image_button["..x..","..y..";"..w..","..h
         ..";ui_button_3w_inactive.png;"..name..";"..minetest.formspec_escape(label)..";"
         ..nc..";false;ui_button_3w_active.png]"
         ..tt
   end
end

function default.ui.button_exit(x, y, w, h, name, label, noclip, tooltip)
   local nc = "false"

   if noclip then
      nc = "true"
   end

   local tt = ""
   if tooltip then
      tt = "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"
   end

   if w == 2 then
      return "image_button_exit["..x..","..y..";"..w..","..h
         ..";ui_button_2w_inactive.png;"..name..";"..minetest.formspec_escape(label)..";"
         ..nc..";false;ui_button_2w_active.png]"
         ..tt
   else
      return "image_button_exit["..x..","..y..";"..w..","..h
         ..";ui_button_3w_inactive.png;"..name..";"..minetest.formspec_escape(label)..";"
         ..nc..";false;ui_button_3w_active.png]"
         ..tt
   end
end

-- Tabs

function default.ui.tab(x, y, name, icon, tooltip)
   local tooltip = tooltip or ""
   local shifted_icon = "[combine:16x16:0,0=ui_tab_active.png:0,1="..icon

   local form = ""

   form = form .. "image_button["..x..","..y..";1,1;ui_tab_inactive.png^"
      ..icon..";"..name..";;true;false;"
      ..minetest.formspec_escape(shifted_icon).."]"

   form = form .. "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"

   return form
end

-- Itemstacks

local function get_itemdef_field(itemname, fieldname)
   if not minetest.registered_items[itemname] then
      return nil
   end
   return minetest.registered_items[itemname][fieldname]
end

function default.ui.fake_itemstack(x, y, itemstack)
   local itemname = itemstack:get_name()
   local itemamt = itemstack:get_count()

   local itemdesc = ""
   if minetest.registered_items[itemname]
   and minetest.registered_items[itemname].description ~= nil then
      itemdesc = minetest.registered_items[itemname].description
   end

   if itemamt <= 1 then itemamt = "" end

   local result = ""
   if itemname ~= "" then
      result = result .. "item_image["..x..","..y..";1,1;"
         ..minetest.formspec_escape(itemname .. " " .. itemamt).."]"

      result = result .. "tooltip["..x..","..y..";1,1;"..minetest.formspec_escape(itemdesc).."]"
   end

   return result
end

function default.ui.fake_simple_itemstack(x, y, itemname, name)
   local name = name or "fake_simple_itemstack"

   local itemdesc = ""
   if minetest.registered_items[itemname]
   and minetest.registered_items[itemname].description ~= nil then
      itemdesc = minetest.registered_items[itemname].description
   end

   local result = ""
   if itemname ~= "" then
      result = result .. "image_button["..x..","..y..";1,1;blank.png;"
         ..name..";;false;false;blank.png]"
      result = result .. "item_image["..x..","..y..";1,1;"
         ..minetest.formspec_escape(itemname).."]"
      result = result .. "tooltip["..name..";"
         ..minetest.formspec_escape(itemdesc).."]"
   end

   return result
end

function default.ui.item_group(x, y, group, count, name)
   local name = name or "fake_itemgroup"

   local itemname = ""

   local group_default = default.ui.group_defaults[group]

   if group_default ~= nil and minetest.registered_items[group_default] then
      itemname = group_default
   else
      for itemn, itemdef in pairs(minetest.registered_items) do
         if minetest.get_item_group(itemn, group) ~= 0
         and minetest.get_item_group(itemn, "not_in_craft_guide") ~= 1 then
            itemname = itemn
         end
      end
   end

   local result = ""
   if itemname ~= "" then
      result = result
         .."box["..x..","..y..";0.85,0.9;#00000040]"
         .."item_image["..x..","..y..";1,1;"
         ..minetest.formspec_escape(itemname .. " " .. count).."]"

      local group_prettyprint
      if default.ui.group_names[group] then
          group_prettyprint = minetest.colorize("#ffecb6", default.ui.group_names[group][2])
      else
          group_prettyprint = S("Group: @1", minetest.colorize("#ffecb6", group))
      end
      result = result .. "tooltip["..x..","..y..";1,1;"..
         minetest.formspec_escape(group_prettyprint).."]"
   end

   return result
end

function default.ui.fake_itemstack_any(x, y, itemstack, name)
   local group = string.match(itemstack:get_name(), "group:(.*)")

   if group == nil then
      return default.ui.fake_itemstack(x, y, itemstack)
   else
      return default.ui.item_group(x, y, group, itemstack:get_count(), name)
   end
end

-- Pages

function default.ui.get_page(name)
   local page= default.ui.registered_pages[name]

   if page == nil then
      default.log("UI page '" .. name .. "' is not yet registered", "dev")
      page = ""
   end

   return page
end

function default.ui.register_page(name, form)
   default.ui.registered_pages[name] = form
end

-- Default formspec boilerplates

local form_default_default = ""
form_default_default = form_default_default .. "size[8.5,9]"
form_default_default = form_default_default .. default.ui.default.bg
form_default_default = form_default_default .. default.ui.tab(-0.9, 0.5, "tab_crafting", "ui_icon_crafting.png", S("Crafting"))
if minetest.get_modpath("armor") ~= nil then
   form_default_default = form_default_default .. default.ui.tab(-0.9, 1.28, "tab_armor", "ui_icon_armor.png", S("Armor"))
end
if minetest.get_modpath("achievements") ~= nil then
   form_default_default = form_default_default .. default.ui.tab(-0.9, 2.06, "tab_achievements", "ui_icon_achievements.png", S("Achievements"))
end
if minetest.get_modpath("player_skins") ~= nil then
   form_default_default = form_default_default .. default.ui.tab(-0.9, 2.84, "tab_player_skins", "ui_icon_player_skins.png", S("Player Skins"))
end
if minetest.get_modpath("creative") ~= nil and minetest.settings:get_bool("creative_mode") then
   form_default_default = form_default_default .. default.ui.tab(-0.9, 3.64, "tab_creative", "ui_icon_creative.png", S("Creative Inventory"))
end
form_default_default = form_default_default .. "background[0,0;8.5,9;ui_formspec_bg_tall.png]"
default.ui.register_page("default:default", form_default_default)
default.ui.register_page("default:2part", form_default_default .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]")

local form_default_notabs = ""
form_default_notabs = form_default_notabs .. "size[8.5,9]"
form_default_notabs = form_default_notabs .. default.ui.default.bg
form_default_notabs = form_default_notabs .. "background[0,0;8.5,9;ui_formspec_bg_tall.png]"
default.ui.register_page("default:notabs", form_default_notabs)
default.ui.register_page("default:notabs_2part", form_default_notabs .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]")

local form_default_field = ""
form_default_field = form_default_field .. "size[8.5,5]"
form_default_field = form_default_field .. default.ui.default.bg
form_default_field = form_default_field .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_default_field = form_default_field .. default.ui.button_exit(2.75, 3, 3, 1, "", S("Write"), false)
form_default_field = form_default_field .. "field[1,1.75;7,0;text;;${text}]"
default.ui.register_page("default:field", form_default_field)

local form_bookshelf = default.ui.get_page("default:2part")
form_bookshelf = form_bookshelf .. "list[current_player;main;0.25,4.75;8,4;]"
form_bookshelf = form_bookshelf .. "listring[current_player;main]"
form_bookshelf = form_bookshelf .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_bookshelf = form_bookshelf .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

form_bookshelf = form_bookshelf .. "list[current_name;main;2.25,1.25;4,2;]"
form_bookshelf = form_bookshelf .. "listring[current_name;main]"
form_bookshelf = form_bookshelf .. default.ui.get_itemslot_bg(2.25, 1.25, 4, 2)
default.ui.register_page("default:bookshelf", form_bookshelf)

function default.ui.receive_fields(player, form_name, fields)
   local name = player:get_player_name()

   local formname, form
   if fields.tab_crafting then
      formname = "crafting:crafting"
      form = crafting.get_formspec(name)
   elseif minetest.get_modpath("armor") ~= nil and fields.tab_armor then
      formname = "armor:armor"
      form = default.ui.get_page("armor:armor")
   elseif minetest.get_modpath("achievements") ~= nil and fields.tab_achievements then
      formname = "achievements:achievements"
      form = achievements.get_formspec(name)
   elseif minetest.get_modpath("player_skins") ~= nil and fields.tab_player_skins then
      formname = "player_skins:player_skins"
      form = player_skins.get_formspec(name)
   elseif minetest.get_modpath("creative") ~= nil and minetest.settings:get_bool("creative_mode") and fields.tab_creative then
      formname = "creative:creative"
      form = creative.get_formspec(name)
   end
   if formname and form then
      player:set_inventory_formspec(form)
      minetest.show_formspec(name, formname, form)
      default.ui.current_page[name] = formname
   end
end

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      default.ui.receive_fields(player, form_name, fields)
end)

minetest.register_on_joinplayer(
   function(player)
      player:set_formspec_prepend(formspec_prepend)
      local name = player:get_player_name()
      if minetest.settings:get_bool("creative_mode") then
          player:set_inventory_formspec(creative.get_formspec(name))
          default.ui.current_page[name] = "creative:creative"
      else
          player:set_inventory_formspec(crafting.get_formspec(name))
          default.ui.current_page[name] = "crafting:crafting"
      end
end)

minetest.register_on_leaveplayer(
   function(player)
      default.ui.current_page[player:get_player_name()] = nil
end)
