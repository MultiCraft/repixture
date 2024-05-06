--
-- Editable books
--

--[[ Get translation function. The 'book' name is used
here instead of 'rp_book' due to legacy reasons,
so that old written books still have their
correct translation after the renaming orgy
after 1.5.3. If we switch to 'rp_book',
then the item tooltip of writen books would
lose their translation.
This could be solved if Minetest had a function like
minetest.register_lbm, but for items.
But the 'book' identifier works just fine for now,
it's just a minor deviation from convention. ]]
local S = minetest.get_translator("book")
local F = minetest.formspec_escape
local FS = function(...) return F(S(...)) end

local BOOK_MAX_TITLE_LENGTH = 64
local BOOK_MAX_TEXT_LENGTH = 4500
local MAX_HEAR_DISTANCE = 16

-- Book writing formspec
local on_use = function(itemstack, player, pointed_thing)
   local name = player:get_player_name()
   local data = itemstack:get_meta()

   local title = ""
   local text = ""

   if data then
      text = data:get_string("book:text")
      title = data:get_string("book:title")
   end

   local form = rp_formspec.get_page("rp_formspec:default")
   form = form .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"
   form = form .. "style_type[field;font_size=*2]"
   form = form .. "field[0,0.4;9.75,0.5;title;"..FS("Title:")..";"..F(title).."]"
   form = form .. "textarea[0,1.4;9.75,7;text;"..FS("Contents:")..";"..F(text).."]"
   form = form .. "style[write;sound=]"
   form = form .. rp_formspec.button_exit(3.5, 8.6, 3, 1, "write", S("Write"))
   form = form .. "container_end[]"

   minetest.sound_play({name="rp_book_open_book", gain=0.5}, {pos=player:get_pos(), max_hear_distance=16}, true)
   minetest.show_formspec(name, "rp_book:book", form)
end

book = {}

book.register_book_node = function(nodename, def)
   local groups
   if def.groups then
      groups = table.copy(def.groups)
   else
      groups = {}
   end
   groups.attached_node = 1
   groups.dig_immediate = 3

   local newdef = {
         inventory_image = def.texture,
	 wield_image = def.texture,
         wield_scale = { x=1,y=1,z=2 },
	 groups = groups,
	 drawtype = "nodebox",
         node_box = {
            type = "fixed",
            fixed = {-5/16,-0.5,-5/16, 5/16,-5/16,5/16},
	 },
	 use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = "4dir",
	 sunlight_propagates = true,
	 is_ground_content = false,
	 walkable = false,
         floodable = true,
         on_flood = function(pos)
            minetest.add_item(pos, nodename)
         end,
         sounds = rp_sounds.node_sound_small_defaults({
            place = { name = "rp_book_place_book", gain = 0.5 },
            dug = { name = "rp_book_dug_book", gain = 0.5 },
         }),
         sound = {},
   }
   for k,v in pairs(def) do
      if k ~= "groups" then
         newdef[k] = v
      end
   end

   minetest.register_node(nodename, newdef)
end

-- Unwritten book (stackable)
book.register_book_node(
   ":rp_default:book_empty",
   {
      description = S("Book"),
      _tt_help = S("Write down some notes"),
      texture = "rp_book_book_empty.png",
      tiles = {
         "rp_book_book_empty_node_top.png",
         "rp_book_book_empty_node_bottom.png",
         "rp_book_book_empty_node_pages.png",
         "rp_book_book_empty_node_spine.png",
         "rp_book_book_empty_node_side_1.png",
         "rp_book_book_empty_node_side_2.png",

      },
      groups = { book = 2, tool = 1, dig_immediate = 3 },

      on_use = function(itemstack, player, pointed_thing)
         on_use(itemstack, player, pointed_thing)
      end,
})

local set_meta_description = function(meta, title)
   if title ~= "" then
      meta:set_string("description", S("Book: “@1”", minetest.colorize("#ffff00", title))) -- Set the item description
   else
      meta:set_string("description", "")
   end
end

-- Writable book (not stackable)
book.register_book_node(
   ":rp_default:book",
   {
      description = S("Unnamed Book"),
      texture = "default_book.png",
      stack_max = 1,
      tiles = {
         "rp_book_book_written_node_top.png",
         "rp_book_book_written_node_bottom.png",
         "rp_book_book_written_node_pages.png",
         "rp_book_book_written_node_spine.png",
         "rp_book_book_written_node_side_1.png",
         "rp_book_book_written_node_side_2.png",
      },
      groups = { book = 2, tool = 1, not_in_creative_inventory = 1, dig_immediate = 3 },

      after_place_node = function(pos, player, itemstack, pointed_thing)
         local imeta = itemstack:get_meta()
         local nmeta = minetest.get_meta(pos) 
	 local title = imeta:get_string("book:title")
         nmeta:set_string("book:title", title)
         nmeta:set_string("book:text", imeta:get_string("book:text"))
         nmeta:set_string("infotext", S("Book: “@1”", title))
      end,
      preserve_metadata = function(pos,oldnode,oldmeta,drops)
         for d=1,#drops do
            local item = drops[d]
            if item:get_name() == "rp_default:book" then
               local imeta = item:get_meta()
               local title = oldmeta["book:title"] or ""
               local text = oldmeta["book:text"] or ""
               imeta:set_string("book:title", title)
               imeta:set_string("book:text", text)
               set_meta_description(imeta, title)
	    end
	 end
      end,
      on_flood = function(pos)
         local nmeta = minetest.get_meta(pos)
	 local item = ItemStack("rp_default:book")
         local imeta = item:get_meta()
         local title = nmeta:get_string("book:title")
         local text = nmeta:get_string("book:text")
         imeta:set_string("book:title", title)
         imeta:set_string("book:text", text)
         set_meta_description(imeta, title)
         minetest.add_item(pos, item)
      end,
      on_blast = function(pos)
         local nmeta = minetest.get_meta(pos)
         local item = ItemStack("rp_default:book")
         local imeta = item:get_meta()
         local title = nmeta:get_string("book:title")
         local text = nmeta:get_string("book:text")
         imeta:set_string("book:title", title)
         imeta:set_string("book:text", text)
         set_meta_description(imeta, title)
         minetest.remove_node(pos)
         minetest.check_for_falling({x=pos.x, y=pos.y+1, z=pos.z})
         minetest.add_item(pos, item)
      end,
      on_use = function(itemstack, player, pointed_thing)
         on_use(itemstack, player, pointed_thing)
      end,
      on_rightclick = function(pos, node, clicker, itemstack)
         if not clicker or not clicker:is_player() then
            return itemstack
	 end
         -- Read book
         local form = rp_formspec.get_page("rp_book:book_page")
         local nmeta = minetest.get_meta(pos)
         local title = nmeta:get_string("book:title")
         local text = nmeta:get_string("book:text")
         form = form .. rp_book.make_read_book_page_formspec(title, text)

         minetest.sound_play({name="rp_book_open_book", gain=0.5}, {pos=clicker:get_pos(), max_hear_distance=16}, true)
         minetest.show_formspec(clicker:get_player_name(), "rp_book:read_book", form)
         return itemstack
      end,
})

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      if form_name ~= "rp_book:book" and form_name ~= "rp_book:read_book" then
         return
      end
      if (not fields.write and not fields.key_enter) then
	 if fields.quit then
            minetest.sound_play({name="rp_book_close_book", gain=0.5}, {pos=player:get_pos(), max_hear_distance=16}, true)
         end
         return
      end
      if form_name ~= "rp_book:book" then
         return
      end

      local wieldstack = player:get_wielded_item()
      local iname = wieldstack:get_name()
      if minetest.get_item_group(iname, "book") ~= 2 then
         return
      end

      local title = fields.title
      local text = fields.text

      -- Limit title and text length
      if string.len(title) > BOOK_MAX_TITLE_LENGTH then
          title = string.sub(title, 1, BOOK_MAX_TITLE_LENGTH)
      end
      if string.len(text) > BOOK_MAX_TEXT_LENGTH then
          text= string.sub(text, 1, BOOK_MAX_TEXT_LENGTH)
      end

      -- Title: Discard everything after 1st newline or carriage return
      local tsplit = string.split(title, "\n", nil, 1)
      if #tsplit >= 1 then
         title = tsplit[1]
      end
      tsplit = string.split(title, "\r", nil, 1)
      if #tsplit >= 1 then
         title = tsplit[1]
      end

      local function set_book_meta(item, title, text)
         local meta = item:get_meta()
	 set_meta_description(meta, title)
         meta:set_string("book:title", title)
         meta:set_string("book:text", text)
      end

      -- Revert book back to stackable book if empty contents
      if title == "" and text == "" then
         if wieldstack:get_name() == "rp_default:book" then
            wieldstack:set_name("rp_default:book_empty")
            set_book_meta(wieldstack, title, text)
            player:set_wielded_item(wieldstack)
            minetest.sound_play({name="rp_book_erase_book", gain=0.2}, {pos=player:get_pos(), max_hear_distance=MAX_HEAR_DISTANCE}, true)
         else
            minetest.sound_play({name="rp_book_close_book", gain=0.5}, {pos=player:get_pos(), max_hear_distance=MAX_HEAR_DISTANCE}, true)
         end
         return
      end

      -- Contents written: Update the player inventory
      minetest.sound_play({name="rp_book_write_book", gain=0.1}, {pos=player:get_pos(), max_hear_distance=MAX_HEAR_DISTANCE}, true)
      if wieldstack:get_name() ~= "rp_default:book" then
         -- 1 book: Replace with written book
	 if wieldstack:get_count() == 1 then
            wieldstack:set_name("rp_default:book")
	    set_book_meta(wieldstack, title, text)
            player:set_wielded_item(wieldstack)
         -- Book stack
         else
	    local newstack = wieldstack:take_item()
	    newstack:set_count(1)
	    newstack:set_name("rp_default:book")
	    set_book_meta(newstack, title, text)
            local inv = player:get_inventory()
	    if inv:room_for_item("main", newstack) then
               -- If space available: Add written book in inventory
               inv:add_item("main", newstack)
               player:set_wielded_item(wieldstack)
	    else
               -- Inventory overflow: Drop the written book
               minetest.add_item(player:get_pos(), newstack)
               player:set_wielded_item(wieldstack)
	    end
	 end
      -- Update an existing written book
      else
	 set_book_meta(wieldstack, title, text)
         player:set_wielded_item(wieldstack)
      end
end)

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:book_empty",
      burntime = 2,
})

minetest.register_craft(
   {
      type = "fuel",
      recipe = "rp_default:book",
      burntime = 2,
})

crafting.register_craft(
   {
      output = "rp_default:book_empty",
      items = {
         "rp_default:paper 3",
         "rp_default:stick",
         "rp_default:fiber",
      }
})

