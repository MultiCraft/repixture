local S = minetest.get_translator("default")

local SIGN_MAX_TEXT_LENGTH = 64

local on_construct = function(pos)
   local meta = minetest.get_meta(pos)
   meta:set_string("formspec", default.ui.get_page("default:field"))
   -- Show empty sign text in quotation marks
   meta:set_string("infotext", S('""'))
   meta:set_string("text", "")
end
local on_receive_fields = function(pos, formname, fields, sender)
   if fields.text == nil then return end
   if minetest.is_protected(pos, sender:get_player_name()) and
                  not minetest.check_player_privs(sender, "protection_bypass") then
           minetest.record_protection_violation(pos, sender:get_player_name())
           return itemstack
   end
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
end
local on_destruct = function(pos)
   default.write_name(pos, "")
end

minetest.register_node(
   "default:sign",
   {
      description = S("Sign"),
      _tt_help = S("Write a short message"),
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
      groups = {choppy = 2,handy = 2,attached_node = 1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
      on_construct = on_construct,
      on_receive_fields = on_receive_fields,
      on_destruct = on_destruct,
      on_place = function(itemstack, placer, pointed_thing)
	if not placer or not placer:is_player() then
          return itemstack
        end
        if pointed_thing.type ~= "node" then
	  return minetest.item_place_node(itemstack, placer, pointed_thing)
	end
	if pointed_thing.under.y == pointed_thing.above.y then
	  return minetest.item_place_node(itemstack, placer, pointed_thing)
        end

	local r90 = false
        local yaw = placer:get_look_horizontal()
	if not ((yaw > (1/4)*math.pi and yaw < (3/4)*math.pi) or (yaw > (5/4)*math.pi and yaw < (7/4)*math.pi)) then
	  return minetest.item_place_node(itemstack, placer, pointed_thing)
        end
	local r90sign = ItemStack("default:sign90")
	r90sign = minetest.item_place_node(r90sign, placer, pointed_thing)
	if r90sign:is_empty() then
	  itemstack:take_item()
	end
	return itemstack
      end,
})

minetest.register_node(
   "default:sign90",
   {
      drawtype = "nodebox",
      tiles = {"default_sign.png^[transformR90"},
      inventory_image = "default_sign_inventory.png^[transformR90",
      wield_image = "default_sign_inventory.png^[transformR90",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      node_box = {
	 type = "wallmounted",
	 wall_top = {-0.5+(4/16), 0.5, -0.5+(1/16), 0.5-(4/16), 0.5-(1/16), 0.5-(1/16)},
	 wall_bottom = {-0.5+(4/16), -0.5, -0.5+(1/16), 0.5-(4/16), -0.5+(1/16), 0.5-(1/16)},
	 wall_side = {-0.5, -0.5+(1/16), -0.5+(4/16), -0.5+(1/16), 0.5-(1/16), 0.5-(4/16)},
      },
      groups = {choppy = 2,handy = 2,attached_node = 1, not_in_creative_inventory=1},
      is_ground_content = false,
      sounds = default.node_sound_defaults(),
      on_construct = on_construct,
      on_receive_fields = on_receive_fields,
      on_destruct = on_destruct,
      drop = "default:sign",
})

