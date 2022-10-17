local S = minetest.get_translator("rp_default")
local F = minetest.formspec_escape

local protection_check_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    if minetest.is_protected(pos, player:get_player_name()) and
            not minetest.check_player_privs(player, "protection_bypass") then
        minetest.record_protection_violation(pos, player:get_player_name())
        return 0
    else
        return count
    end
end
local protection_check_put_take = function(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) and
            not minetest.check_player_privs(player, "protection_bypass") then
        minetest.record_protection_violation(pos, player:get_player_name())
        return 0
    else
        return stack:get_count()
    end
end

-- Chest and bookshelf

minetest.register_node(
   "rp_default:chest",
   {
      description = S("Chest"),
      _tt_help = S("Provides 32 inventory slots"),
      tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_sides.png",
	      "default_chest_sides.png", "default_chest_sides.png", "default_chest_front.png"},
      paramtype2 = "facedir",
      groups = {snappy = 2,choppy = 2,oddly_breakable_by_hand = 2,container=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)

         meta:set_string("formspec", rp_formspec.get_page("rp_default:chest"))
         meta:set_string("infotext", S("Chest"))

         local inv = meta:get_inventory()

         inv:set_size("main", 8 * 4)
      end,
      on_destruct = function(pos)
         item_drop.drop_items_from_container(pos, {"main"})
      end,
      write_name = function(pos, text)
--[[ TODO: Bring back container naming
         local meta = minetest.get_meta(pos)
         
         if text ~= "" then
             meta:set_string("infotext", text)
         else
             meta:set_string("infotext", S("Chest"))
         end
]]
      end,
})

local form_chest = rp_formspec.get_page("rp_formspec:2part")
form_chest = form_chest .. "list[current_name;main;0.25,0.25;8,4;]"
form_chest = form_chest .. "listring[current_name;main]"
form_chest = form_chest .. rp_formspec.get_itemslot_bg(0.25, 0.25, 8, 4)

form_chest = form_chest .. "list[current_player;main;0.25,4.75;8,4;]"
form_chest = form_chest .. "listring[current_player;main]"
form_chest = form_chest .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_chest = form_chest .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)
rp_formspec.register_page("rp_default:chest", form_chest)


-- Bookshelf

local reading_bookshelves = {}

minetest.register_on_leaveplayer(function(player)
   local name = player:get_playr_name()
   reading_bookshelves[name] = nil
end)

local form_bookshelf = rp_formspec.get_page("rp_formspec:2part")
form_bookshelf = form_bookshelf .. "list[current_player;main;0.25,4.75;8,4;]"
form_bookshelf = form_bookshelf .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_bookshelf = form_bookshelf .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)

form_bookshelf = form_bookshelf .. rp_formspec.get_itemslot_bg(0.25, 1.5, 8, 1)
for i=1,8 do
   local xoff = i-1
   form_bookshelf = form_bookshelf .. rp_formspec.image_button(0.25+xoff, 2.5, 1, 1, "open_"..i, "ui_icon_view.png", S("Read book"))
end

local function get_bookshelf_formspec(pos)
   local x, y, z = pos.x, pos.y, pos.z
   local context = "nodemeta:"..x..","..y..","..z
   local form = form_bookshelf
   form = form .. "list["..context..";main;0.25,1.5;8,1;]"
   form = form .. "listring["..context..";main]"
   form = form .. "listring[current_player;main]"
   return form
end

minetest.register_node(
   "rp_default:bookshelf",
   {
      description = S("Bookshelf"),
      _tt_help = S("Provides 8 inventory slots"),
      tiles = {"default_wood.png", "default_wood.png", "default_bookshelf.png"},
      paramtype2 = "facedir",
      groups = {snappy = 2,choppy = 3,oddly_breakable_by_hand = 2,container=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", S("Bookshelf"))
         local inv = meta:get_inventory()
         inv:set_size("main", 4*2)
      end,
      allow_metadata_inventory_move = protection_check_move,
      allow_metadata_inventory_put = protection_check_put_take,
      allow_metadata_inventory_take = protection_check_put_take,
      on_destruct = function(pos)
         item_drop.drop_items_from_container(pos, {"main"})
      end,
      on_rightclick = function(pos, node, clicker)
         if clicker and clicker:is_player() then
            local pname = clicker:get_player_name()
            reading_bookshelves[pname] = table.copy(pos)
            minetest.show_formspec(pname, "rp_default:bookshelf", get_bookshelf_formspec(pos))
         end
      end,
      write_name = function(pos, text)
--[[ TODO: Bring back container naming
         local meta = minetest.get_meta(pos)

         if text ~= "" then
            meta:set_string("infotext", text)
         else
            meta:set_string("infotext", S("Bookshelf"))
         end
]]
      end,
})

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      if not player or not player:is_player() then
         return
      end
      if form_name == "rp_default:bookshelf" then
         local field_no
         for i=1,8 do
            if fields["open_"..i] then
                field_no = i
                break
            end
         end
         if not field_no then
            return
         end
         local pname = player:get_player_name()
	 local shelfpos = reading_bookshelves[pname]
         if not shelfpos then
            return
         end

         local meta = minetest.get_meta(shelfpos)
         local inv = meta:get_inventory()

         local book = inv:get_stack("main", field_no)
         if not book or book:get_name() ~= "rp_default:book" then
            return
         end
         local bmeta = book:get_meta()
         local text, title = "", ""
         if bmeta then
            text = bmeta:get_string("book:text")
            title = bmeta:get_string("book:title")
         end
         local form = rp_formspec.get_page("rp_formspec:default")
         form = form .. "label[0.25,0.25;"..F(title).."]"
         form = form .. "textarea[0.5,0.75;8,7.75;;;"..F(text).."]"
         form = form .. rp_formspec.button(2.75, 7.75, 3, 1, "return", S("Return"))
         minetest.show_formspec(pname, "rp_default:read_book_in_bookshelf", form)

      elseif form_name == "rp_default:read_book_in_bookshelf" then
         if (not fields["return"] and not fields["key_enter"]) then
            return
	 end
         local pname = player:get_player_name()
	 local shelfpos = reading_bookshelves[pname]
         if not shelfpos then
            return
         end
         local node = minetest.get_node(shelfpos)
         if node.name ~= "rp_default:bookshelf" then
            return
         end
         minetest.show_formspec(pname, "rp_default:bookshelf", get_bookshelf_formspec(shelfpos))
     end
end)

minetest.register_lbm({
   label = "Update bookshelf formspec",
   name = "rp_default:update_bookshelf_formspec",
   nodenames = { "rp_default:bookshelf" },
   action = function(pos, node)
      local meta = minetest.get_meta(pos)
      meta:set_string("formspec", "")
   end,
})


