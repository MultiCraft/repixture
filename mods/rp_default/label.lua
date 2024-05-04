-- Label

local S = minetest.get_translator("rp_default")

local form_label = ""
form_label = form_label .. rp_formspec.default.version
form_label = form_label .. "size[8.5,4.5]"
form_label = form_label .. rp_formspec.default.boilerplate
form_label = form_label .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_label = form_label .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
rp_formspec.register_page("rp_default:label", form_label)

default.container_label_formspec_element = function(meta)
   local name = meta:get_string("name")
   local form = ""
   if name ~= "" then
      form = form .. "background9[0.5,-0.5;7,0.5;ui_formspec_bg_label_extension.png;false;15,15,-15,-1]"
      form = form .. "style_type[label;noclip=true;textcolor=#000000FF]"
      form = form .. "label[0.7,-0.25;"..minetest.formspec_escape(name).."]"
   end
   return form
end

local active_posses = {}

local write = function(itemstack, player, pointed_thing)
    -- Handle pointed node handlers and protection
    if util.handle_node_protection(player, pointed_thing) then
       return itemstack
    end
    if pointed_thing.type ~= "node" then
       return itemstack
    end

    active_posses[player:get_player_name()] = table.copy(pointed_thing.under)
    local node = minetest.get_node(pointed_thing.under)
    local def = minetest.registered_nodes[node.name]

    if def._rp_write_name then
       local meta = minetest.get_meta(pointed_thing.under)
       local text = meta:get_string("name")

       local form = rp_formspec.get_page("rp_default:label")
       form = form .. "field[1,1.5;6.5,0.5;text;;"..minetest.formspec_escape(text).."]"
       form = form .. "set_focus[text;true]"

       minetest.show_formspec(player:get_player_name(), "rp_default:label", form)
    end

    if not minetest.is_creative_enabled(player:get_player_name()) then
       itemstack:take_item()
    end
    return itemstack
end

minetest.register_craftitem(
   "rp_default:label",
   {
      description = S("Label and Graphite"),
      _tt_help = S("Give a name to containers"),
      inventory_image = "rp_default_label.png",
      wield_image = "rp_default_label.png",
      on_use = write,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
   if formname ~= "rp_default:label" then
      return
   end
   if fields.text then
      local pos = active_posses[player:get_player_name()]
      if pos then
         default.write_name(pos, fields.text)
      end
   elseif fields.quit then
      active_posses[player:get_player_name()] = nil
   end
end)

minetest.register_on_leaveplayer(function(player)
   active_posses[player:get_player_name()] = nil
end)
