
rp_formspec = {}

local S = minetest.get_translator("rp_formspec")

function minetest.nodedef_default.on_receive_fields(pos, form_name, fields, player)
   rp_formspec.receive_fields(player, form_name, fields)
end

-- Registered UI pages

rp_formspec.registered_pages = {}
rp_formspec.registered_invpages = {}

-- UI defaults

rp_formspec.default = {}

local current_invpage = {}

-- Colors

local prepend = "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]" ..
    "tableoptions[background=#DDDDDD30;highlight=#539646]" ..
    "style_type[button,image_button,item_image_button,checkbox,tabheader;sound=default_gui_button]" ..
    "style_type[button:pressed,image_button:pressed,item_image_button:pressed;content_offset=0]"
rp_formspec.default.bg = "bgcolor[#00000000]"

-- bgcolor intentionally not included because it would make pause menu transparent, too :(
local formspec_prepend = prepend

-- Group default items

rp_formspec.group_defaults = {
   fuzzy = "mobs:wool",
   planks = "rp_default:planks",
   soil = "rp_default:dirt",
   stone = "rp_default:stone",
   tree = "rp_default:tree",
   green_grass = "rp_default:grass",
}
rp_formspec.group_names = {
   fuzzy = { S("Fuzzy"), S("Any fuzzy block") },
   planks = { S("Planks"), S("Any planks") },
   soil = { S("Soil"), S("Any soil") },
   stone = { S("Stone"), S("Any stone") },
   green_grass = { S("Green Grass Clump"), S("Any green grass clump") },
}

-- Itemslot backgrounds

function rp_formspec.get_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	 out = out .."image["..x+i..","..y+j..";1,1;ui_itemslot.png]"
      end
   end
   return out
end

function rp_formspec.get_hotbar_itemslot_bg(x, y, w, h)
   local out = ""
   for i = 0, w - 1, 1 do
      for j = 0, h - 1, 1 do
	 out = out .."image["..x+i..","..y+j
            ..";1,1;ui_itemslot.png^ui_itemslot_dark.png]"
      end
   end
   return out
end

rp_formspec.get_output_itemslot_bg = rp_formspec.get_hotbar_itemslot_bg

-- Buttons

function rp_formspec.image_button(x, y, w, h, name, image, tooltip)
   local ww
   if w == 1 then
      ww = "1w"
   elseif w == 2 then
      ww = "2w"
   else
      ww = "3w"
   end
   local tooltip = tooltip or ""
   local img_active = "[combine:16x16:0,0=ui_button_"..ww.."_active.png:0,1="..image

   local form = ""
   local img_inactive = "ui_button_"..ww.."_inactive.png^" .. image

   form = form .. "image_button["..x..","..y..";1,1;"
      ..minetest.formspec_escape(img_inactive)
      ..";"..name..";;true;false;"
      ..minetest.formspec_escape(img_active).."]"

   form = form .. "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"

   return form
end

function rp_formspec.button(x, y, w, h, name, label, noclip, tooltip)
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

function rp_formspec.button_exit(x, y, w, h, name, label, noclip, tooltip)
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

function rp_formspec.tab(x, y, name, icon, tooltip, side)
   local tooltip = tooltip or ""
   local img_active
   if side == "right" then
      img_active = "[combine:16x16:0,0=(ui_tab_active.png^[transformFX):0,1="..icon
   else
      img_active = "[combine:16x16:0,0=ui_tab_active.png:0,1="..icon
   end

   local form = ""
   local img_inactive
   if side == "right" then
      img_inactive = "(ui_tab_inactive.png^[transformFX)^" .. icon
   else
      img_inactive = "ui_tab_inactive.png^" .. icon
   end

   form = form .. "image_button["..x..","..y..";1,1;"
      ..minetest.formspec_escape(img_inactive)
      ..";"..name..";;true;false;"
      ..minetest.formspec_escape(img_active).."]"

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

function rp_formspec.fake_itemstack(x, y, itemstack)
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

      result = result .. "tooltip["..x..","..y..";0.8,0.8;"..minetest.formspec_escape(itemdesc).."]"
   end

   return result
end

function rp_formspec.item_group(x, y, group, count, name)
   local name = name or "fake_itemgroup"

   local itemname = ""

   local group_default = rp_formspec.group_defaults[group]

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
      if rp_formspec.group_names[group] then
          group_prettyprint = minetest.colorize("#ffecb6", rp_formspec.group_names[group][2])
      else
          group_prettyprint = S("Group: @1", minetest.colorize("#ffecb6", group))
      end
      result = result .. "tooltip["..x..","..y..";1,1;"..
         minetest.formspec_escape(group_prettyprint).."]"
   end

   return result
end

function rp_formspec.fake_itemstack_any(x, y, itemstack, name)
   local group = string.match(itemstack:get_name(), "group:(.*)")

   if group == nil then
      return rp_formspec.fake_itemstack(x, y, itemstack)
   else
      return rp_formspec.item_group(x, y, group, itemstack:get_count(), name)
   end
end

-- Pages

function rp_formspec.get_page(name)
   local page= rp_formspec.registered_pages[name]

   if page == nil then
      minetest.log("info", "[rp_formspec] UI page '" .. name .. "' is not yet registered")
      page = ""
   end

   return page
end

function rp_formspec.register_page(name, form)
   rp_formspec.registered_pages[name] = form
end

-- Default formspec boilerplates

local form_default_default = ""
form_default_default = form_default_default .. "size[8.5,9]"
form_default_default = form_default_default .. rp_formspec.default.bg
form_default_default = form_default_default .. rp_formspec.tab(-0.9, 0.5, "_rp_formspec_tab_rp_crafting:crafting", "ui_icon_crafting.png", S("Crafting"))
if minetest.get_modpath("rp_armor") ~= nil then
   form_default_default = form_default_default .. rp_formspec.tab(-0.9, 1.28, "_rp_formspec_tab_rp_armor:armor", "ui_icon_armor.png", S("Armor"))
end
if minetest.get_modpath("rp_achievements") ~= nil then
   form_default_default = form_default_default .. rp_formspec.tab(-0.9, 2.06, "_rp_formspec_tab_rp_achievements:achievements", "ui_icon_achievements.png", S("Achievements"))
end
if minetest.get_modpath("rp_player_skins") ~= nil then
   form_default_default = form_default_default .. rp_formspec.tab(-0.9, 2.84, "_rp_formspec_tab_rp_player_skins:player_skins", "ui_icon_player_skins.png", S("Player Skins"))
end
if minetest.get_modpath("rp_creative") ~= nil and minetest.is_creative_enabled("") then
   form_default_default = form_default_default .. rp_formspec.tab(-0.9, 3.64, "_rp_formspec_tab_rp_creative:creative", "ui_icon_creative.png", S("Creative Inventory"))
end
form_default_default = form_default_default .. "background[0,0;8.5,9;ui_formspec_bg_tall.png]"
rp_formspec.register_page("rp_default:default", form_default_default)
rp_formspec.register_page("rp_default:2part", form_default_default .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]")

local form_default_notabs = ""
form_default_notabs = form_default_notabs .. "size[8.5,9]"
form_default_notabs = form_default_notabs .. rp_formspec.default.bg
form_default_notabs = form_default_notabs .. "background[0,0;8.5,9;ui_formspec_bg_tall.png]"
rp_formspec.register_page("rp_default:notabs", form_default_notabs)
rp_formspec.register_page("rp_default:notabs_2part", form_default_notabs .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]")

local form_default_field = ""
form_default_field = form_default_field .. "size[8.5,5]"
form_default_field = form_default_field .. rp_formspec.default.bg
form_default_field = form_default_field .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_default_field = form_default_field .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
form_default_field = form_default_field .. "set_focus[text;true]"
form_default_field = form_default_field .. "field[1,1.75;7,0;text;;${text}]"
rp_formspec.register_page("rp_default:field", form_default_field)

function rp_formspec.receive_fields(player, form_name, fields)
   local pname = player:get_player_name()

   local invpagename, form
   for k,def in pairs(rp_formspec.registered_invpages) do
      if fields["_rp_formspec_tab_"..k] then
         invpagename = k
	 form = def.get_formspec(pname)
      end
   end
   if invpagename and form then
      rp_formspec.set_invpage(player, invpagename)
   end
end

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      rp_formspec.receive_fields(player, form_name, fields)
end)

minetest.register_on_joinplayer(
   function(player)
      player:set_formspec_prepend(formspec_prepend)
      local pname = player:get_player_name()
      for invpagename,def in pairs(rp_formspec.registered_invpages) do
          if def.is_startpage and def.is_startpage(pname) then
             player:set_inventory_formspec(def.get_formspec(pname))
             current_invpage[pname] = invpagename
          end
      end
end)

function rp_formspec.set_invpage(player, page)
    local def = rp_formspec.registered_invpages[page]
    local pname = player:get_player_name()
    player:set_inventory_formspec(def.get_formspec(pname))
    current_invpage[pname] = page
end

function rp_formspec.get_invpage(player)
    local pname = player:get_player_name()
    return current_invpage[pname]
end

function rp_formspec.register_invpage(name, def)
   rp_formspec.registered_invpages[name] = def
end

minetest.register_on_leaveplayer(
   function(player)
      current_invpage[player:get_player_name()] = nil
end)
