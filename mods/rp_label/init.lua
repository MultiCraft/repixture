-- Label

local S = minetest.get_translator("rp_label")

rp_label = {}

-- Maximum length of the name of a named node (e.g. with label)
local NAMED_NODE_MAX_TEXT_LENGTH = 40

local mod_mobs = minetest.get_modpath("rp_mobs") ~= nil

local form_label = ""
form_label = form_label .. rp_formspec.default.version
form_label = form_label .. "size[8.5,4.5]"
form_label = form_label .. rp_formspec.default.boilerplate
form_label = form_label .. "background[0,0;8.5,4.5;ui_formspec_bg_short.png]"
form_label = form_label .. rp_formspec.button_exit(2.75, 3, 3, 1, "", minetest.formspec_escape(S("Write")), false)
rp_formspec.register_page("rp_label:label", form_label)

local active_posses = {}
local active_objects = {}

rp_label.container_label_formspec_element = function(meta)
   local name = meta:get_string("name")
   local form = ""
   if name ~= "" then
      form = form .. "background9[0.5,-0.5;7,0.5;ui_formspec_bg_label_extension.png;false;15,15,-15,-1]"
      form = form .. "style_type[label;noclip=true;textcolor=#000000FF]"
      form = form .. "label[0.7,-0.25;"..minetest.formspec_escape(name).."]"
   end
   return form
end

local restrict_text = function(text)
   -- Discard everything after the first newline or carriage return
   local tsplit = string.split(text, "\n", nil, 1)
   if #tsplit >= 1 then
      text = tsplit[1]
   end
   tsplit = string.split(text, "\r", nil, 1)
   if #tsplit >= 1 then
      text = tsplit[1]
   end

   -- Limit text length
   text = string.sub(text, 1, NAMED_NODE_MAX_TEXT_LENGTH)

   return text
end

-- Assign a name to a node
rp_label.write_name = function(pos, text)
   text = restrict_text(text)

   local node = minetest.get_node(pos)
   local def
   if minetest.registered_nodes[node.name] then
      def = minetest.registered_nodes[node.name]
   end

   if def and def._rp_write_name ~= nil then
      def._rp_write_name(pos, text)
      return true
   end
   return false
end

local write = function(itemstack, player, pointed_thing)
    -- Handle pointed node handlers and protection
    if util.handle_node_protection(player, pointed_thing) then
       return itemstack
    end
    if pointed_thing.type == "object" then
       if not mod_mobs then
          return itemstack
       end
       local obj = pointed_thing.ref
       local lua = obj:get_luaentity()
       if lua and lua._cmi_is_mob then
          local text = rp_mobs.get_nametag(lua)

          local form = rp_formspec.get_page("rp_label:label")
          form = form .. "field[1,1.5;6.5,0.5;text;;"..minetest.formspec_escape(text).."]"
          form = form .. "set_focus[text;true]"

          minetest.show_formspec(player:get_player_name(), "rp_label:label", form)

          active_objects[player:get_player_name()] = obj

          if not minetest.is_creative_enabled(player:get_player_name()) then
             itemstack:take_item()
          end
       end
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

       local form = rp_formspec.get_page("rp_label:label")
       form = form .. "field[1,1.5;6.5,0.5;text;;"..minetest.formspec_escape(text).."]"
       form = form .. "set_focus[text;true]"

       minetest.show_formspec(player:get_player_name(), "rp_label:label", form)
    end

    if not minetest.is_creative_enabled(player:get_player_name()) then
       itemstack:take_item()
    end
    return itemstack
end

minetest.register_craftitem(
   "rp_label:label",
   {
      description = S("Label and Graphite"),
      _tt_help = S("Give a name to a container or creature"),
      inventory_image = "rp_label_label.png",
      wield_image = "rp_label_label.png",
      on_use = write,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
   if formname ~= "rp_label:label" then
      return
   end
   local pname = player:get_player_name()
   if fields.text then
      local pos = active_posses[pname]
      if pos then
         rp_label.write_name(pos, fields.text)
      elseif mod_mobs then
         local obj = active_objects[pname]
         if obj then
            local lua = obj:get_luaentity()
            if lua and lua._cmi_is_mob then
               local text = restrict_text(fields.text)
               rp_mobs.set_nametag(lua, text)
            end
         end
      end
   elseif fields.quit then
      active_posses[pname] = nil
      active_objects[pname] = nil
   end
end)

minetest.register_on_leaveplayer(function(player)
   active_posses[player:get_player_name()] = nil
   active_objects[player:get_player_name()] = nil
end)


-- Crafting
if minetest.get_modpath("default") ~= nil then
   crafting.register_craft({
      output = "rp_label:label 20",
      items = {
         "rp_default:sheet_graphite",
         "rp_default:paper",
      }
   })
end

