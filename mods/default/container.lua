local S = minetest.get_translator("default")

-- Chest and bookshelf

minetest.register_node(
   "default:chest",
   {
      description = S("Chest"),
      tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_sides.png",
	      "default_chest_sides.png", "default_chest_sides.png", "default_chest_front.png"},
      paramtype2 = "facedir",
      groups = {snappy = 2,choppy = 2,oddly_breakable_by_hand = 2},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)

         meta:set_string("formspec", default.ui.get_page("default:chest"))
         meta:set_string("infotext", S("Chest"))

         local inv = meta:get_inventory()

         inv:set_size("main", 8 * 4)
      end,
      can_dig = function(pos, player)
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()
         return inv:is_empty("main")
      end,
      write_name = function(pos, text)
         local meta = minetest.get_meta(pos)
         
         if text ~= "" then
             meta:set_string("infotext", text)
         else
             meta:set_string("infotext", S("Chest"))
         end
      end,
})

local form_chest = default.ui.get_page("default:2part")
form_chest = form_chest .. "list[current_name;main;0.25,0.25;8,4;]"
form_chest = form_chest .. "listring[current_name;main]"
form_chest = form_chest .. default.ui.get_itemslot_bg(0.25, 0.25, 8, 4)

form_chest = form_chest .. "list[current_player;main;0.25,4.75;8,4;]"
form_chest = form_chest .. "listring[current_player;main]"
form_chest = form_chest .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_chest = form_chest .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)
default.ui.register_page("default:chest", form_chest)


minetest.register_node(
   "default:bookshelf",
   {
      description = S("Bookshelf"),
      tiles = {"default_wood.png", "default_wood.png", "default_bookshelf.png"},
      paramtype2 = "facedir",
      groups = {snappy = 2,choppy = 3,oddly_breakable_by_hand = 2},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("formspec", default.ui.get_page("default:bookshelf"))
         meta:set_string("infotext", S("Bookshelf"))
         local inv = meta:get_inventory()
         inv:set_size("main", 4*2)
      end,
      can_dig = function(pos,player)
         local meta = minetest.get_meta(pos);
         local inv = meta:get_inventory()
         return inv:is_empty("main")
      end,
      write_name = function(pos, text)
         local meta = minetest.get_meta(pos)

         if text ~= "" then
            meta:set_string("infotext", text)
         else
            meta:set_string("infotext", S("Bookshelf"))
         end
      end,
})

default.log("container", "loaded")
