local S = minetest.get_translator("default")

local SIGN_MAX_TEXT_LENGTH = 64

minetest.register_node(
   "default:sign",
   {
      description = S("Sign"),
      drawtype = "nodebox",
      tiles = {"default_sign.png"},
      inventory_image = "default_sign_inventory.png",
      wield_image = "default_sign_inventory.png",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      node_box = {
	 type = "wallmounted",
	 wall_top = {-0.5+(1/16), 0.5, -0.5+(4/16), 0.5-(1/16), 0.5-(1/16), 0.5-(4/16)},
	 wall_bottom = {-0.5+(1/16), -0.5, -0.5+(4/16), 0.5-(1/16), -0.5+(1/16), 0.5-(4/16)},
	 wall_side = {-0.5, -0.5+(4/16), -0.5+(1/16), -0.5+(1/16), 0.5-(4/16), 0.5-(1/16)},
      },
      groups = {choppy = 2,dig_immediate = 2,attached_node = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
      on_construct = function(pos)
         --local n = minetest.get_node(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("formspec", default.ui.get_page("default:field"))
         -- Show empty sign text in quotation marks
         meta:set_string("infotext", S('""'))
         meta:set_string("text", "")
      end,
      on_receive_fields = function(pos, formname, fields, sender)
         if fields.text == nil then return end
         local meta = minetest.get_meta(pos)
         local text = fields.text
         if string.len(text) > SIGN_MAX_TEXT_LENGTH then
             text = string.sub(text, 1, SIGN_MAX_TEXT_LENGTH)
         end
         minetest.log("action", (sender:get_player_name() or "")..
                         " wrote \""..text.."\" to sign at "..
                         minetest.pos_to_string(pos))
         meta:set_string("text", text)
         -- Show sign text in quotation marks
         meta:set_string("infotext", S('"@1"', text))

         default.write_name(pos, meta:get_string("text"))
      end,
      on_destruct = function(pos)
         default.write_name(pos, "")
      end
})
