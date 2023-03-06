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

-- Chest

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
      sounds = rp_sounds.node_sound_planks_defaults(),
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

