--
-- Editable books
-- Code based off the books_plus mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("book")
local F = minetest.formspec_escape

local BOOK_MAX_TITLE_LENGTH = 64
local BOOK_MAX_TEXT_LENGTH = 4500

minetest.register_craftitem(
   ":default:book",
   {
      description = S("Unnamed Book"),
      _tt_help = S("Write down some notes"),
      inventory_image = "default_book.png",
      stack_max = 1,

      on_use = function(itemstack, player, pointed_thing)
         local name = player:get_player_name()
         local data = itemstack:get_meta()

         local title = ""
         local text = ""

         if data then
            text = data:get_string("book:text")
            title = data:get_string("book:title")
         end

         local form = default.ui.get_page("default:notabs")
         form = form .. "field[0.5,1.25;8,0;title;"..F(S("Title:"))..";"..F(title).."]"
         form = form .. "textarea[0.5,1.75;8,6.75;text;"..F(S("Contents:"))..";"..F(text).."]"
         form = form .. default.ui.button_exit(2.75, 7.75, 3, 1, "write", S("Write"))

         minetest.show_formspec(name, "book:book", form)
      end,
})

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      if form_name ~= "book:book" or not fields.write then return end

      local itemstack = player:get_wielded_item()

      local meta = itemstack:get_meta()

      -- Limit title and text length
      if string.len(fields.title) > BOOK_MAX_TITLE_LENGTH then
          fields.title = string.sub(fields.title, 1, BOOK_MAX_TITLE_LENGTH)
      end
      if string.len(fields.text) > BOOK_MAX_TEXT_LENGTH then
          fields.text= string.sub(fields.text, 1, BOOK_MAX_TEXT_LENGTH)
      end

      meta:set_string("description", S("Book: “@1”", minetest.colorize("#ffff00", fields.title))) -- Set the item description

      meta:set_string("book:title", fields.title)
      meta:set_string("book:text", fields.text)

      player:set_wielded_item(itemstack)
end)

default.log("mod:book", "loaded")
