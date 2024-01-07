
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
   local itemwear = itemstack:get_wear()

   local itemdesc = ""
   if minetest.registered_items[itemname]
   and minetest.registered_items[itemname].description ~= nil then
      itemdesc = minetest.registered_items[itemname].description
   end

   local itemstring = itemname .. " " .. itemamt .. " " .. itemwear

   local result = ""
   if itemname ~= "" then
      result = result .. "item_image["..x..","..y..";1,1;"
         ..minetest.formspec_escape(itemstring).."]"

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

-- Inventory tabs (invtabs)

rp_formspec.registered_invtabs = {}
local registered_invtabs_order = {}

local invtabs_cached
local invtabs_cached_needs_update = true

-- Register an inventory tab
function rp_formspec.register_invtab(name, def)
   local rdef = table.copy(def)
   rp_formspec.registered_invtabs[name] = def
   table.insert(registered_invtabs_order, name)
   invtabs_cached_needs_update = true
end

-- Returns a formspec string for all the inventory tabs
local function get_invtabs()
   if not invtabs_cached_needs_update then
      return invtabs_cached
   end
   local form = ""
   local tabx = -0.9
   local taby = 0.5
   local tabplus = 0.78
   for o=1, #registered_invtabs_order do
      local tabname = registered_invtabs_order[o]
      local def = rp_formspec.registered_invtabs[tabname]
      if def then
         form = form .. rp_formspec.tab(tabx, taby, "_rp_formspec_tab_"..tabname, def.icon, def.tooltip)
         taby = taby + tabplus
      end
   end
   invtabs_cached = form
   return form
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

function rp_formspec.get_page(name, with_invtabs)
   local page = rp_formspec.registered_pages[name]

   if page == nil then
      minetest.log("warning", "[rp_formspec] UI page '" .. name .. "' is not yet registered")
      return ""
   end
   if with_invtabs then
      page = page .. get_invtabs()
   end

   return page
end

function rp_formspec.register_page(name, form)
   rp_formspec.registered_pages[name] = form
end

-- Default formspec boilerplates

local form_default = ""
form_default = form_default .. "size[8.5,9]"
form_default = form_default .. rp_formspec.default.bg
form_default = form_default .. "background[0,0;8.5,9;ui_formspec_bg_tall.png]"
local form_2part = form_default .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"

-- 1-part frame
rp_formspec.register_page("rp_formspec:default", form_default)
-- 2-part frame
rp_formspec.register_page("rp_formspec:2part", form_2part)

-- Simple text input field
local form_default_field = ""
form_default_field = form_default_field .. "size[8.5,5]"
form_default_field = form_default_field .. rp_formspec.default.bg
form_default_field = form_default_field .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_default_field = form_default_field .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
form_default_field = form_default_field .. "set_focus[text;true]"
form_default_field = form_default_field .. "field[1,1.75;7,0;text;;${text}]"
rp_formspec.register_page("rp_formspec:field", form_default_field)

-- A page (and invpage) with only the player inventory, used as fallback
local form_inventory = ""
form_inventory = form_inventory .. rp_formspec.get_page("rp_formspec:default")
form_inventory = form_inventory .. "list[current_player;main;0.25,4.75;8,4;]"
form_inventory = form_inventory .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_inventory = form_inventory .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)
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

function rp_formspec.set_current_invpage(player, page)
    local def = rp_formspec.registered_invpages[page]
    local pname = player:get_player_name()
    local formspec
    if def.get_formspec then
       formspec = def.get_formspec(pname)
    else
       formspec = rp_formspec.registered_pages[page]
    end
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
		return rp_formspec.get_page("rp_formspec:inventory", true)
	end,
})

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      rp_formspec.receive_fields(player, form_name, fields)
end)

minetest.register_on_joinplayer(
   function(player)
      -- Initialize player formspec and set initial invpage
      player:set_formspec_prepend(formspec_prepend)
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
