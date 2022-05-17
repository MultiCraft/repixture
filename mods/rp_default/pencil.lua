
--
-- Tool definitions
--

local S = minetest.get_translator("rp_default")

local active_posses = {}

-- Trim node (as defined by node definition's _on_trim field)
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
       local form = ""
       form = form .. "size[8.5,5]"
       form = form .. rp_formspec.default.bg
       form = form .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
       form = form .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
       form = form .. "set_focus[text;true]"
       form = form .. "field[1,1.75;7,0;text;;"..minetest.formspec_escape(text).."]"

       minetest.show_formspec(player:get_player_name(), "rp_default:pencil", form)
    end

    return itemstack
end

minetest.register_tool(
   "rp_default:pencil",
   {
      description = S("Pencil"),
      _tt_help = S("Name blocks"),
      inventory_image = "rp_default_pencil.png",
      wield_image = "rp_default_pencil.png",
      groups = { pencil = 1 },
      on_place = write,
      on_use = write,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
   if formname ~= "rp_default:pencil" then
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
