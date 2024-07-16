local S = minetest.get_translator("rp_default")

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

local get_chest_formspec = function(meta)
   local form = rp_formspec.get_page("rp_default:chest")
   form = form .. rp_label.container_label_formspec_element(meta)
   return form
end
local get_chest_infotext = function(meta)
   local name = meta:get_string("name")
   if name ~= "" then
      return S("Chest") .. "\n" .. S('“@1”', name)
   else
      return S("Chest")
   end
end

local chest_write_name = function(pos, text)
   local meta = minetest.get_meta(pos)
   meta:set_string("name", text)
   meta:set_string("infotext", get_chest_infotext(meta))
   meta:set_string("formspec", get_chest_formspec(meta))
end

minetest.register_node(
   "rp_default:chest",
   {
      description = S("Chest"),
      _tt_help = S("Provides 32 inventory slots"),
      tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_sides.png",
	      "default_chest_sides.png", "default_chest_sides.png", "default_chest_front.png"},
      paramtype2 = "4dir",
      groups = {choppy = 2, oddly_breakable_by_hand = 2, level = -1, chest = 1, container = 1, paintable = 2, furniture = 1, pathfinder_hard = 1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)

         meta:set_string("formspec", get_chest_formspec(meta))
         meta:set_string("infotext", get_chest_infotext(meta))

         local inv = meta:get_inventory()

         inv:set_size("main", 8 * 4)
      end,
      on_destruct = function(pos)
         item_drop.drop_items_from_container(pos, {"main"})
      end,
      _rp_write_name = chest_write_name,
      _rp_blast_resistance = 2,
})
minetest.register_node(
   "rp_default:chest_painted",
   {
      description = S("Painted Chest"),
      _tt_help = S("Provides 32 inventory slots"),
      tiles = {"default_chest_top_painted.png", "default_chest_top_painted.png", "default_chest_sides_painted.png",
	      "default_chest_sides_painted.png", "default_chest_sides_painted.png", "default_chest_front_painted.png"},
      overlay_tiles = {
              -- HACK: This is a workaround to fix the coloring of the crack overlay
              {name="rp_textures_blank_paintable_overlay.png",color="white"},
              {name="rp_textures_blank_paintable_overlay.png",color="white"},
              {name="rp_textures_blank_paintable_overlay.png",color="white"},
              {name="rp_textures_blank_paintable_overlay.png",color="white"},
              {name="rp_textures_blank_paintable_overlay.png",color="white"},
              -- Actual legit overlay
	      {name="default_chest_front_painted_overlay.png",color="white"}},
      paramtype2 = "color4dir",
      groups = {choppy = 2, oddly_breakable_by_hand = 2, level = -1, chest = 1, container = 1, paintable = 1, not_in_creative_inventory = 1, furniture = 1, pathfinder_hard = 1},
      palette = "rp_paint_palette_64d.png",
      is_ground_content = false,
      sounds = rp_sounds.node_sound_planks_defaults(),
      on_destruct = function(pos)
         item_drop.drop_items_from_container(pos, {"main"})
      end,
      _rp_write_name = chest_write_name,
      drop = "rp_default:chest",
      _rp_blast_resistance = 2,
})

local xstart = rp_formspec.default.start_point.x
local ystart = rp_formspec.default.start_point.y
local form_chest = rp_formspec.get_page("rp_formspec:2part")
form_chest = form_chest .. rp_formspec.get_itemslot_bg(xstart, ystart, 8, 4)
form_chest = form_chest .. "list[current_name;main;"..xstart..","..ystart..";8,4;]"
form_chest = form_chest .. "listring[current_name;main]"

form_chest = form_chest .. rp_formspec.default.player_inventory
form_chest = form_chest .. "listring[current_player;main]"
rp_formspec.register_page("rp_default:chest", form_chest)

minetest.register_lbm({
	label = "Update chest formspec",
	name = "rp_default:update_chest_formspec_3_14_0",
	nodenames = { "rp_default:chest", "rp_default:chest_painted" },
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local formspec = get_chest_formspec(meta)
		local infotext = get_chest_infotext(meta)
		meta:set_string("formspec", formspec)
		meta:set_string("infotext", infotext)
	end,
})
