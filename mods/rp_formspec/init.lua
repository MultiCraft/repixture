
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
-- Holds the formspec version
rp_formspec.default.version = "formspec_version[7]"

-- Default formspec coordinates
rp_formspec.default.size = { x = 10.75, y = 10.25 }
rp_formspec.default.list_spacing = { x = 0.25, y = 0.15 }
rp_formspec.default.start_point = { x = 0.5, y = 0.25 }

-- Legacy variable that used to contain a bgcolor[] but is no longer needed
rp_formspec.default.bg = ""

local current_invpage = {}

-- Variables for the default 9-slice button

local btn_scale = 4 -- change this to scale the entire button

-- Button size in pixels
local btn_x = 44 * btn_scale
local btn_y = 12 * btn_scale
local btn_resize = btn_x.."x"..btn_y

-- for bgimg_middle
local btn_middle_i_x = 4 * btn_scale
local btn_middle_i_y = 4 * btn_scale
local btn_middle_i_x2 = -4 * btn_scale
local btn_middle_i_y2 = -6 * btn_scale
local btn_middle_a_x = 4 * btn_scale
local btn_middle_a_y = 5 * btn_scale
local btn_middle_a_x2 = -4 * btn_scale
local btn_middle_a_y2 = -6 * btn_scale
local btn_middle_i = btn_middle_i_x..","..btn_middle_i_y..","..btn_middle_i_x2..","..btn_middle_i_y2
local btn_middle_a = btn_middle_a_x..","..btn_middle_a_y..","..btn_middle_a_x2..","..btn_middle_a_y2

-- Use negative padding to disable padding; otherwise the text is squeezed too much
local btn_padding = -6 * btn_scale
local btn_padding_img = -2 * btn_scale

local shared_prepend =
    "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]" ..
    "tableoptions[background=#DDDDDD30;highlight=#539646]" ..
    "bgcolor[#00000000]" ..
    "style_type[image_button:pressed,item_image_button:pressed;content_offset=0]" ..
    "tableoptions[background=#DDDDDD30;highlight=#539646]" ..
    "style_type[button,image_button,item_image_button,checkbox,tabheader;sound=default_gui_button]"

local global_prepend =
    shared_prepend ..
    "style_type[button,image_button;bgimg=ui_button_9slice_inactive.png^[resize:"..btn_resize..";border=false;bgimg_middle="..btn_middle_i..";content_offset=0,0]" ..
    "style_type[button:pressed,image_button:pressed;bgimg=ui_button_9slice_active.png^[resize:"..btn_resize..";border=false;bgimg_middle="..btn_middle_a..";content_offset=0,2]" ..
    "style_type[button,button:pressed;padding="..btn_padding.."]" ..
    "style_type[image_button,image_button:pressed;padding="..btn_padding_img.."]" ..
    "listcolors[#7d6f52;#00000010;#786848;#68B259;#FFF]" ..
    "background9[0,0;8.5,4.5;ui_formspec_bg_9tiles.png;true;20,20,-20,-28]"


local repixture_prepend =
    shared_prepend ..
    "listcolors[#00000000;#00000010;#00000000;#68B259;#FFF]"..
    "style_type[list;spacing="..rp_formspec.default.list_spacing.x..","..rp_formspec.default.list_spacing.y.."]"

-- Must be included in every page after size[]
rp_formspec.default.boilerplate = "no_prepend[]" .. repixture_prepend

-- Group default items

rp_formspec.group_defaults = {
   fuzzy = "rp_mobs_mobs:wool",
   planks = "rp_default:planks",
   soil = "rp_default:dirt",
   stone = "rp_default:stone",
   tree = "rp_default:tree",
   green_grass = "rp_default:grass",
   paint_bucket = "rp_paint:bucket",
   paint_bucket_not_full = "rp_paint:bucket_0",
}
rp_formspec.group_names = {
   fuzzy = { S("Fuzzy"), S("Any fuzzy block") },
   planks = { S("Planks"), S("Any planks") },
   soil = { S("Soil"), S("Any soil") },
   stone = { S("Stone"), S("Any stone") },
   green_grass = { S("Green Grass Clump"), S("Any green grass clump") },
   paint_bucket = { S("Paint Bucket"), S("Any paint bucket") },
   paint_bucket_not_full = { S("Non-full Paint Bucket"), S("Any paint bucket that isn’t full") },
}

-- Itemslot backgrounds

local function get_itemslot_bg_raw(slot_type, x, y, w, h, count)
   if count == 0 then
      return ""
   end
   local tex
   if slot_type == "normal" then
      tex = "ui_itemslot.png"
   elseif slot_type == "dark" then
      tex = "ui_itemslot.png^ui_itemslot_dark.png"
   else
      minetest.log("error", "[rp_formspec] get_itemslot_bg_raw called with invalid slot_type!")
      return ""
   end
   local slots = 0
   local out = ""
   for i = 0, h - 1, 1 do
      local ii = i * rp_formspec.default.list_spacing.y
      for j = 0, w - 1, 1 do
         local jj = j * rp_formspec.default.list_spacing.x
	 out = out .."image["..x+j+jj..","..y+i+ii..";1,1;"..tex.."]"
         slots = slots + 1
         if count and slots >= count then
            return out
         end
      end
   end
   return out
end

function rp_formspec.get_itemslot_bg(x, y, w, h, count)
   return get_itemslot_bg_raw("normal", x, y, w, h, count)
end

function rp_formspec.get_hotbar_itemslot_bg(x, y, w, h, count)
   return get_itemslot_bg_raw("dark", x, y, w, h, count)
end

rp_formspec.get_output_itemslot_bg = rp_formspec.get_hotbar_itemslot_bg

-- Default player inventory
rp_formspec.default.player_inventory = rp_formspec.get_hotbar_itemslot_bg(rp_formspec.default.start_point.x, 5.35, 8, 1)
	.. rp_formspec.get_itemslot_bg(rp_formspec.default.start_point.x, 5.35+1+rp_formspec.default.list_spacing.y, 8, 3)
	.. "list[current_player;main;"..rp_formspec.default.start_point.x..",5.35;8,4;]"

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

-- Wrapper for rp_formspec.button and rp_formspec.button_exit
-- * button_type: Formspec element name: "button" or "button_exit"
-- * Other arguments: Same as for rp_formspec.button
local function button_raw(button_type, x, y, w, h, name, label, tooltip)
   local tt = ""
   if tooltip then
      tt = "tooltip["..name..";"..minetest.formspec_escape(tooltip).."]"
   end

   local ww
   if w == 1 then
      ww = "1w"
   elseif w == 2 then
      ww = "2w"
   elseif w == 3 then
      ww = "3w"
   else
      minetest.log("warning", "[rp_formspec] Called rp_formspec."..button_type.." with w unequal to 1, 2 or 3")
      -- Fallback
      ww = "3w"
      w = 3
   end

   local form = ""

   -- Inactive button style
   form = form .. "style["..name..";bgimg=ui_button_"..ww.."_inactive.png;border=false;content_offset=0,0;padding=;bgimg_middle=]"
   -- Active button style
   form = form .. "style["..name..":pressed;bgimg=ui_button_"..ww.."_active.png;border=false;content_offset=0,2;padding=;bgimg_middle=]"

   -- Button
   form = form .. button_type.."["..x..","..y..";"..w..","..h
      ..";"..name..";"..minetest.formspec_escape(label).."]"

   form = form .. tt
   return form
end

function rp_formspec.button(x, y, w, h, name, label, noclip, tooltip)
   return button_raw("button", x, y, w, h, name, label, tooltip)
end

function rp_formspec.button_exit(x, y, w, h, name, label, noclip, tooltip)
   return button_raw("button_exit", x, y, w, h, name, label, tooltip)
end

-- Tabs

function rp_formspec.tab(x, y, name, icon, tooltip, side, pushed)
   local tooltip = tooltip or ""
   local img_active, img_inactive
   if pushed then
      if side == "right" then
         img_active = "[combine:16x16:0,0=(ui_tab_active_pushed.png^[transformFX):0,1="..icon
      else
         img_active = "[combine:16x16:0,0=ui_tab_active_pushed.png:0,1="..icon
      end

      if side == "right" then
         img_inactive = "(ui_tab_inactive_pushed.png^[transformFX)^"..icon
      else
         img_inactive = "ui_tab_inactive_pushed.png^"..icon
      end
   else
      if side == "right" then
         img_active = "[combine:16x16:0,0=(ui_tab_active.png^[transformFX):0,1="..icon
      else
         img_active = "[combine:16x16:0,0=ui_tab_active.png:0,1="..icon
      end

      if side == "right" then
         img_inactive = "(ui_tab_inactive.png^[transformFX)^" .. icon
      else
         img_inactive = "ui_tab_inactive.png^" .. icon
      end
   end

   local form = ""
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

function rp_formspec.fake_itemstack(x, y, itemstack, xsize, ysize)
   local itemname = itemstack:get_name()
   local itemamt = itemstack:get_count()
   local itemwear = itemstack:get_wear()
   if not xsize then
      xsize = 1
   end
   if not ysize then
      ysize = 1
   end

   local itemdesc = ""
   if minetest.registered_items[itemname]
   and minetest.registered_items[itemname].description ~= nil then
      itemdesc = minetest.registered_items[itemname].description
   end

   local itemstring = itemname .. " " .. itemamt .. " " .. itemwear

   local result = ""
   if itemname ~= "" then
      result = result .. "item_image["..x..","..y..";"..xsize..","..ysize..";"
         ..minetest.formspec_escape(itemstring).."]"

      result = result .. "tooltip["..x..","..y..";"..xsize..","..ysize..";"..minetest.formspec_escape(itemdesc).."]"
   end

   return result
end

function rp_formspec.item_group(x, y, group, count, name, xsize, ysize)
   local name = name or "fake_itemgroup"
   if not xsize then
      xsize = 1
   end
   if not ysize then
      ysize = 1
   end

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
         .."box["..x..","..y..";"..xsize..","..ysize..";#00000040]"
         .."item_image["..x..","..y..";"..xsize..","..ysize..";"
         ..minetest.formspec_escape(itemname .. " " .. count).."]"

      local group_prettyprint
      if rp_formspec.group_names[group] then
          group_prettyprint = minetest.colorize("#ffecb6", rp_formspec.group_names[group][2])
      else
          group_prettyprint = S("Group: @1", minetest.colorize("#ffecb6", group))
      end
      result = result .. "tooltip["..x..","..y..";"..xsize..","..ysize..";"..
         minetest.formspec_escape(group_prettyprint).."]"
   end

   return result
end

function rp_formspec.fake_itemstack_any(x, y, itemstack, name, xsize, ysize)
   local group = string.match(itemstack:get_name(), "group:(.*)")

   if group == nil then
      return rp_formspec.fake_itemstack(x, y, itemstack, xsize, ysize)
   else
      return rp_formspec.item_group(x, y, group, itemstack:get_count(), name, xsize, ysize)
   end
end

-- Inventory tabs (invtabs)

rp_formspec.registered_invtabs = {}
local registered_invtabs_order = {}

-- Register an inventory tab
function rp_formspec.register_invtab(name, def)
   local rdef = table.copy(def)
   rp_formspec.registered_invtabs[name] = def
   table.insert(registered_invtabs_order, name)
end

function rp_formspec.set_invtab_order(order)
  registered_invtabs_order = table.copy(order)
  local already_ordered = {}
  for o=1, #order do
    already_ordered[order[o]] = true
  end
  for k,v in pairs(rp_formspec.registered_invtabs) do
    if not already_ordered[k] then
       table.insert(registered_invtabs_order, k)
    end
  end
end

-- Pages

-- Note: Argument 2 was 'show_invtabs' but has been removed
function rp_formspec.get_page(name)
   local page = rp_formspec.registered_pages[name]

   if page == nil then
      minetest.log("warning", "[rp_formspec] UI page '" .. name .. "' is not yet registered")
      return ""
   end

   return page
end

function rp_formspec.register_page(name, form)
   rp_formspec.registered_pages[name] = form
end

-- Default formspec boilerplates

local form_default = ""
form_default = form_default .. rp_formspec.default.version
form_default = form_default .. "size["..rp_formspec.default.size.x..","..rp_formspec.default.size.y.."]"
form_default = form_default .. rp_formspec.default.boilerplate
form_default = form_default .. "background[0,0;"..rp_formspec.default.size.x..","..rp_formspec.default.size.y..";ui_formspec_bg_tall.png]"
local form_2part = form_default .. "background[0,0;"..rp_formspec.default.size.x..","..(rp_formspec.default.size.y/2)..";ui_formspec_bg_short.png]"


-- 1-part frame
rp_formspec.register_page("rp_formspec:default", form_default)
-- 2-part frame
rp_formspec.register_page("rp_formspec:2part", form_2part)

-- Simple text input field
local form_default_field = ""
form_default_field = form_default_field .. rp_formspec.default.version
form_default_field = form_default_field .. "size[8.5,4.5]"
form_default_field = form_default_field .. rp_formspec.default.boilerplate
form_default_field = form_default_field .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_default_field = form_default_field .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
form_default_field = form_default_field .. "field[1,1.5;6.5,0.5;text;;${text}]"
form_default_field = form_default_field .. "set_focus[text;true]"
rp_formspec.register_page("rp_formspec:field", form_default_field)

-- A page (and invpage) with only the player inventory, used as fallback
local form_inventory = ""
form_inventory = form_inventory .. rp_formspec.get_page("rp_formspec:default")
form_inventory = form_inventory .. rp_formspec.default.player_inventory

rp_formspec.register_page("rp_formspec:inventory", form_inventory)

function rp_formspec.receive_fields(player, form_name, fields)
   local pname = player:get_player_name()

   local invpagename, form
   for k,def in pairs(rp_formspec.registered_invpages) do
      if fields["_rp_formspec_tab_"..k] then
         invpagename = k
         if def.get_formspec then
            form = def.get_formspec(pname)
         else
            form = rp_formspec.registered_pages[k]
         end
      end
   end
   if invpagename and form then
      rp_formspec.set_current_invpage(player, invpagename)
   end
end

function rp_formspec.register_invpage(name, def)
   rp_formspec.registered_invpages[name] = def
end

-- Returns a formspec string for all the inventory tabs,
-- already correctly positioned (assuming the default
-- formspec size)
-- * highlight: Name of invtab to highlight
local function get_invtabs(highlight)
   local form = ""
   local tabx = -1
   local taby = 0.5
   local tabplus = 0.9
   for o=1, #registered_invtabs_order do
      local tabname = registered_invtabs_order[o]
      local def = rp_formspec.registered_invtabs[tabname]
      if def then
         local icon, pushed
         if highlight == tabname and def.icon_active then
            icon = def.icon_active
            pushed = true
         else
            icon = def.icon
            pushed = false
         end
         form = form .. rp_formspec.tab(tabx, taby, "_rp_formspec_tab_"..tabname, icon, def.tooltip, "left", pushed)
         taby = taby + tabplus
      end
   end
   return form
end

function rp_formspec.set_current_invpage(player, page)
    local def = rp_formspec.registered_invpages[page]
    local pname = player:get_player_name()
    local formspec
    if def.get_formspec then
       formspec = def.get_formspec(pname)
    else
       formspec = rp_formspec.registered_pages[page]
    end
    formspec = formspec .. get_invtabs(page)
    player:set_inventory_formspec(formspec)
    current_invpage[pname] = page
end

function rp_formspec.refresh_invpage(player, invpage)
    local current = rp_formspec.get_current_invpage(player)
    if invpage == current then
        rp_formspec.set_current_invpage(player, invpage)
    end
end

function rp_formspec.get_current_invpage(player)
    local pname = player:get_player_name()
    return current_invpage[pname]
end

rp_formspec.register_invpage("rp_formspec:inventory", {
	get_formspec = function(pname)
		return rp_formspec.get_page("rp_formspec:inventory")
	end,
})

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      rp_formspec.receive_fields(player, form_name, fields)
end)

minetest.register_on_joinplayer(
   function(player)
      -- Initialize player formspec and set initial invpage
      player:set_formspec_prepend(global_prepend)
      local pname = player:get_player_name()
      local first_page
      for invpagename,def in pairs(rp_formspec.registered_invpages) do
          if not first_page and invpagename ~= "rp_formspec:inventory" then
             first_page = invpagename
          end
          -- _is_startpage returns true if this page
          -- is a startpage, false otherwise.
          -- As this function only makes sense within the context of a game,
          -- it is undocumented in API.md.
          if def._is_startpage and def._is_startpage(pname) then
             rp_formspec.set_current_invpage(player, invpagename)
             break
          end
      end
      -- Fallback invpage
      if not rp_formspec.get_current_invpage(player) then
         if first_page then
            -- First invpage of the pairs() above (kinda unpredicable tho)
            rp_formspec.set_current_invpage(player, first_page)
	 else
            -- Empty inventory fallback page if no invpages registered
            rp_formspec.set_current_invpage(player, "rp_formspec:inventory")
         end
      end
end)

minetest.register_on_leaveplayer(
   function(player)
      current_invpage[player:get_player_name()] = nil
end)
