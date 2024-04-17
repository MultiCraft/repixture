--
-- Door mod
--

local S = minetest.get_translator("rp_door")

local DOOR_THICKNESS = 1.5/16

door = {}

-- Mark the door segment at pos as having a right hinge.
-- This function assumes that there is a door segment at pos.
local function set_segment_hinge_right(pos)
   local meta = minetest.get_meta(pos)
   -- the meta key "right" stores the door hinge:
   -- * 0: hinge is left
   -- * 1: hinge is right
   meta:set_int("right", 1)
end

-- Remove node at pos and possibly trigger a fall
-- if a falling/attached node above
local function remove_node_and_check_falling(pos)
   minetest.remove_node(pos)
   local pos2 = {x=pos.x, y=pos.y+1, z=pos.z}
   minetest.check_for_falling(pos2)
end

local function open_or_close_door_segment_raw(pos, dir, check_name, replace, replace_dir, params, sound_open_door, sound_close_door)
   local other_pos = table.copy(pos)
   other_pos.y = pos.y+dir
   -- Check for the other door segment.
   -- If it's is missing, it doesn't budge.
   if minetest.get_node(other_pos).name ~= check_name then
      return false
   end
   local p2 = minetest.get_node(pos).param2
   local p2mod = p2 % 4
   local p2flat = p2 - p2mod
   p2mod = params[p2mod+1]
   p2 = p2flat + p2mod

   minetest.swap_node(other_pos, {name=replace_dir, param2=p2})

   minetest.swap_node(pos, {name=replace, param2=p2})

   local snd_1 = sound_close_door
   local snd_2 = sound_open_door

   if params[1] == 3 then
      snd_1, snd_2 = snd_2, snd_1
   end

   local snd
   if minetest.get_meta(pos):get_int("right") ~= 0 then
      snd = snd_1
   else
      snd = snd_2
   end
   minetest.sound_play(
      snd,
      {
         pos = pos,
         gain = 0.8,
         max_hear_distance = 10
      }, true)
   return true
end

local door_params = {
   ["_b_1"] = { 1, 2, 3, 0 },
   ["_t_1"] = { 1, 2, 3, 0 },
   ["_b_2"] = { 3, 0, 1, 2 },
   ["_t_2"] = { 3, 0, 1, 2 },
}

local on_toggle = function(pos, snddef, segment_type, base_name, blocked_sound)
   local ok = false
   local params = door_params[segment_type]
   if segment_type == "_b_1" then
      ok = open_or_close_door_segment_raw(pos, 1, base_name.."_t_1", base_name.."_b_2", base_name.."_t_2", params, snddef.sound_open_door, snddef.sound_close_door)
   elseif segment_type == "_t_1" then
      ok = open_or_close_door_segment_raw(pos, -1, base_name.."_b_1", base_name.."_t_2", base_name.."_b_2", params, snddef.sound_open_door, snddef.sound_close_door)
   elseif segment_type == "_b_2" then
      ok = open_or_close_door_segment_raw(pos, 1, base_name.."_t_2", base_name.."_b_1", base_name.."_t_1", params, snddef.sound_open_door, snddef.sound_close_door)
   elseif segment_type == "_t_2" then
      ok = open_or_close_door_segment_raw(pos, -1, base_name.."_b_2", base_name.."_t_1", base_name.."_b_1", params, snddef.sound_open_door, snddef.sound_close_door)
   else
      minetest.log("error", "[rp_door] Called on_toggle with wrong segment_type!")
      return false
   end
   if blocked_sound and not ok then
      -- Play sound if door could not be toggled due to it being a single door segment,
      -- not a full door
      minetest.sound_play(
         snddef.sound_blocked,
         {
            pos = pos,
            gain = 0.8,
            max_hear_distance = 10
         }, true)
      return false
   end
   return true
end

door.is_open = function(pos)
   local node = minetest.get_node(pos)
   if minetest.get_item_group(node.name, "door") == 0 then
      return nil
   end

   -- Get door segment type
   local suffix = string.sub(node.name, -4, -1)
   local params = door_params[suffix]

   -- Open/closed state (true = open, false = closed)
   local state1 = true
   local state2 = false
   if params[1] == 3 then
      state1, state2 = state2, state1
   end
   local state
   -- left/right hinge
   if minetest.get_meta(pos):get_int("right") ~= 0 then
      state = state1
   else
      state = state2
   end
   return state
end

door.get_free_axis = function(pos)
   local node = minetest.get_node(pos)
   if minetest.get_item_group(node.name, "door") == 0 then
      return nil
   end
   local p2m = node.param2 % 4
   if p2m == 0 or p2m == 2 then
      return "x"
   else
      return "z"
   end
end

local drop_door = function(pos, player, item)
   if player and player:is_player() and minetest.is_creative_enabled(player:get_player_name()) then
      local inv = player:get_inventory()
      if not inv:contains_item("main", item) then
         inv:add_item("main", item)
      end
   else
      minetest.add_item(pos, item)
   end
end

-- Registers a door

function door.register_door(name, def)
   local box = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5+DOOR_THICKNESS}}

   if not def.node_box_bottom then
      def.node_box_bottom = box
   end
   if not def.node_box_top then
      def.node_box_top = box
   end
   if not def.selection_box_bottom then
      def.selection_box_bottom= box
   end
   if not def.selection_box_top then
      def.selection_box_top = box
   end

   if not def.sound_close_door then
      def.sound_close_door = "door_close"
   end
   if not def.sound_open_door then
      def.sound_open_door = "door_open"
   end
   if not def.sound_blocked then
      def.sound_blocked = "door_blocked"
   end

   if not def.groups then
      def.groups = {}
   end
   local groups_craftitem = table.copy(def.groups)
   groups_craftitem.node = 1
   groups_craftitem.creative_decoblock = 1
   groups_craftitem.interactive_node = 1

   -- Door item (for the players)
   minetest.register_craftitem(
      name, {
	 description = def.description,
	 inventory_image = def.inventory_image,

	 groups = groups_craftitem,

	 on_place = function(itemstack, placer, pointed_thing)
            -- Handle pointed node handlers first
            local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
            if handled then
               return handled_itemstack
            end

            if pointed_thing.type ~= "node" then
               return itemstack
            end

            -- Get position where the bottom door segment will go
            local pos
            local undername = minetest.get_node(pointed_thing.under).name
            -- Respect buildable_to when building
            if minetest.registered_items[undername] and minetest.registered_items[undername].buildable_to then
               pos = pointed_thing.under
            else
               pos = pointed_thing.above
            end

	    -- Check protection
	    for i=0, 1 do
               local protpos = vector.add(pos, vector.new(0, i, 0))
               if minetest.is_protected(protpos, placer:get_player_name()) and
                     not minetest.check_player_privs(placer, "protection_bypass") then
                  minetest.record_protection_violation(protpos, placer:get_player_name())
                  return itemstack
               end
            end

            -- Position of top door segment
            local pos2 = vector.offset(pos, 0, 1, 0)
            local posdef = minetest.registered_nodes[minetest.get_node(pos).name]
            local pos2def = minetest.registered_nodes[minetest.get_node(pos2).name]
            if
               not posdef or
               not pos2def or
               not posdef.buildable_to or
               not pos2def.buildable_to or
               not placer or
               not placer:is_player()
            then
               rp_sounds.play_place_failed_sound(placer)
               return itemstack
            end

            -- Check if there's already a door left from this door.
            -- If yes, the door hinge will be right, otherwise it will be left.
            -- This allows to build double doors.
            local p2 = minetest.dir_to_fourdir(placer:get_look_dir())
            local pos3 = table.copy(pos)
            if p2 == 0 then
               pos3.x = pos3.x-1
            elseif p2 == 1 then
               pos3.z = pos3.z+1
            elseif p2 == 2 then
               pos3.x = pos3.x+1
            elseif p2 == 3 then
               pos3.z = pos3.z-1
            end
            if minetest.get_item_group(minetest.get_node(pos3).name, "door") == 0 then
               minetest.set_node(pos, {name=name.."_b_1", param2=p2})
               minetest.set_node(pos2, {name=name.."_t_1", param2=p2})
            else
               minetest.set_node(pos, {name=name.."_b_2", param2=p2})
               minetest.set_node(pos2, {name=name.."_t_2", param2=p2})
               set_segment_hinge_right(pos)
               set_segment_hinge_right(pos2)
            end
            if def.sounds and def.sounds.place then
               minetest.sound_play(def.sounds.place, {pos=pos}, true)
            end

            if not minetest.is_creative_enabled(placer:get_player_name()) then
               itemstack:take_item()
            end

            return itemstack
         end,
   })

   local tt = def.tiles_top
   local tb = def.tiles_bottom
   local ott = def.overlay_tiles_top
   local otb = def.overlay_tiles_bottom

   local transformTileFX = function(tile)
      if type(tile) == "string" then
         return tile .. "^[transformFX"
      elseif type(tile) == "table" then
         local newtile = table.copy(tile)
         newtile.name = newtile.name .. "^[transformFX"
         return newtile
      else
         minetest.log("error", "[rp_door] Called transformTileFX with unknown tile type! tile="..tostring(tile))
      end
   end

   local on_paint_or_unpaint = function(pos, new_param2, dir, check_name, replace_name)
       local other_pos = table.copy(pos)
       other_pos.y = pos.y+dir

       local other_node = minetest.get_node(other_pos)
       if other_node.name == check_name then
          other_node.name = replace_name
          other_node.param2 = new_param2
          minetest.swap_node(other_pos, other_node)
       end
       return true
   end

   --[[ Register door segments
   (internal use, should not be obtainable by player) ]]

   local groups_node = table.copy(def.groups)
   groups_node.not_in_creative_inventory = 1

   local groups_node_b_1 = table.copy(groups_node)
   -- door position: 1 = bottom, 2 = top
   groups_node_b_1.door_position = 1
   groups_node_b_1.door_state = 1

   local groups_node_b_2 = table.copy(groups_node)
   groups_node_b_2.door_position = 1
   groups_node_b_2.door_state = 2

   local groups_node_t_1 = table.copy(groups_node)
   groups_node_t_1.door_position = 2
   groups_node_t_1.door_state = 1

   local groups_node_t_2 = table.copy(groups_node)
   groups_node_t_2.door_position = 2
   groups_node_t_2.door_state = 2

   local painted_name, unpainted_name, drop_name
   local palette
   local paramtype2 = "4dir"
   if def.is_painted then
      paramtype2 = "color4dir"
      palette = "rp_paint_palette_64.png"
   end
   if def.can_paint and not def.is_painted then
      painted_name = name .. "_painted"
   elseif def.is_painted then
      painted_name = name
   end
   if def.can_unpaint then
      unpainted_name = string.sub(name, 1, -9)
      drop_name = unpainted_name
   else
      drop_name = name
   end
   local sounds = {}
   if def.sounds then
      sounds = table.copy(def.sounds)
   end
   sounds._rp_door_close = def.sound_close_door
   sounds._rp_door_open = def.sound_open_door
   sounds._rp_door_blocked = def.sound_blocked

   -- Door segment: bottom, state 1
   minetest.register_node(
      name.."_b_1",
      {
         inventory_image = tb[1] .. "^rp_door_overlay_state_1.png",
	 tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], transformTileFX(tb[1])},
	 overlay_tiles = otb and {otb[2], otb[2], otb[2], otb[2], otb[1], transformTileFX(otb[1])},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = paramtype2,
         palette = palette,
         -- item is dropped via drop_door()
	 drop = "",
	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = def.node_box_bottom
	 },
	 selection_box = {
	    type = "fixed",
	    fixed = def.selection_box_bottom
	 },

	 groups = groups_node_b_1,

	 on_rightclick = function(pos, node, clicker)
            on_toggle(pos, def, "_b_1", name, true)
         end,
         _on_paint = function(pos, new_param2)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, new_param2, 1, name.."_t_1", painted_name.."_t_1")
         end,
         _on_unpaint = function(pos, newnode)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, newnode.param2, 1, name.."_t_1", unpainted_name.."_t_1")
         end,

         floodable = true,
         on_flood = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_2" and minetest.get_node(top).name == name.."_t_1" then
               remove_node_and_check_falling(top)
               drop_door(bottom, nil, drop_name)
            end
         end,
         on_blast = function(bottom)
            minetest.remove_node(bottom)
         end,
         after_destruct = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_2" and minetest.get_node(top).name == name.."_t_1" then
               remove_node_and_check_falling(top)
            end
         end,
         on_dig = function(bottom, node, digger)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(top).name == name.."_t_1" then
               drop_door(bottom, digger, drop_name)
            end
            return minetest.node_dig(bottom, node, digger)
         end,

	 is_ground_content = false,
	 sounds = sounds,
	 sunlight_propagates = def.sunlight,

         -- Additional fields for rp_paint mod
	 _rp_unpainted_node_name = unpainted_name and unpainted_name.."_b_1",
	 _rp_painted_node_name = painted_name and painted_name.."_b_1",
         _rp_paint_particle_node = def.paint_particle_node,
   })

   -- Door segment: top, state 1
   minetest.register_node(
      name.."_t_1",
      {
         inventory_image = tt[1] .. "^rp_door_overlay_state_1.png",
	 tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], transformTileFX(tt[1])},
	 overlay_tiles = ott and {ott[2], ott[2], ott[2], ott[2], ott[1], transformTileFX(ott[1])},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = paramtype2,
         palette = palette,
	 drop = "",
	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = def.node_box_top
	 },
	 selection_box = {
	    type = "fixed",
	    fixed = def.selection_box_top
	 },
	 groups = groups_node_t_1,

	 on_rightclick = function(pos, node, clicker)
            on_toggle(pos, def, "_t_1", name, true)
         end,
         _on_paint = function(pos, new_param2)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, new_param2, -1, name.."_b_1", painted_name.."_b_1")
         end,
         _on_unpaint = function(pos, newnode)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, newnode.param2, -1, name.."_b_1", unpainted_name.."_b_1")
         end,


         floodable = true,
         on_flood = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_2" and minetest.get_node(bottom).name == name.."_b_1" and oldnode.name == name.."_t_1" then
               minetest.dig_node(bottom)
            end
         end,
         on_blast = function(top)
            minetest.remove_node(top)
         end,
         after_destruct = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_2" and minetest.get_node(bottom).name == name.."_b_1" and oldnode.name == name.."_t_1" then
               minetest.dig_node(bottom)
            end
         end,
         on_dig = function(top, node, digger)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(bottom).name == name.."_b_1" then
               drop_door(bottom, digger, drop_name)
            end
            return minetest.node_dig(top, node, digger)
         end,

	 is_ground_content = false,
	 sounds = sounds,
	 sunlight_propagates = def.sunlight,

         -- Additional fields for rp_paint mod
	 _rp_unpainted_node_name = unpainted_name and unpainted_name.."_t_1",
	 _rp_painted_node_name = painted_name and painted_name.."_t_1",
         _rp_paint_particle_node = def.paint_particle_node,
   })

   -- Door segment: bottom, state 2
   minetest.register_node(
      name.."_b_2",
      {
         inventory_image = "("..tb[1] .. "^[transformfx)^rp_door_overlay_state_2.png",
	 tiles = {tb[2], tb[2], transformTileFX(tb[2]), transformTileFX(tb[2]), transformTileFX(tb[1]), tb[1]},
	 overlay_tiles = otb and {otb[2], transformTileFX(otb[2]), transformTileFX(otb[2]), otb[2], transformTileFX(otb[1]), otb[1]},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = paramtype2,
         palette = palette,
	 drop = "",
	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = def.node_box_bottom
	 },
	 selection_box = {
	    type = "fixed",
	    fixed = def.selection_box_bottom
	 },
	 groups = groups_node_b_2,

	 on_rightclick = function(pos, node, clicker)
            on_toggle(pos, def, "_b_2", name, true)
         end,
         _on_paint = function(pos, new_param2)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, new_param2, 1, name.."_t_2", painted_name.."_t_2")
         end,
         _on_unpaint = function(pos, newnode)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, newnode.param2, 1, name.."_t_2", unpainted_name.."_t_2")
         end,

         floodable = true,
         on_flood = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_1" and minetest.get_node(top).name == name.."_t_2" then
               remove_node_and_check_falling(top)
               drop_door(bottom, nil, drop_name)
            end
         end,
         on_blast = function(bottom)
            minetest.remove_node(bottom)
         end,
         after_destruct = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_1" and minetest.get_node(top).name == name.."_t_2" then
               remove_node_and_check_falling(top)
            end
         end,
         on_dig = function(bottom, node, digger)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(top).name == name.."_t_2" then
               drop_door(bottom, digger, drop_name)
            end
            return minetest.node_dig(bottom, node, digger)
         end,

	 is_ground_content = false,
	 sounds = sounds,
	 sunlight_propagates = def.sunlight,

         -- Additional fields for rp_paint mod
	 _rp_unpainted_node_name = unpainted_name and unpainted_name.."_b_2",
	 _rp_painted_node_name = painted_name and painted_name.."_b_2",
         _rp_paint_particle_node = def.paint_particle_node,
   })

   -- Door segment: top, state 2
   minetest.register_node(
      name.."_t_2",
      {
         inventory_image = "("..tt[1] .. "^[transformfx)^rp_door_overlay_state_2.png",
	 tiles = {tt[2], tt[2], transformTileFX(tt[2]), transformTileFX(tt[2]), transformTileFX(tt[1]), tt[1]},
	 overlay_tiles = ott and {ott[2], ott[2], transformTileFX(ott[2]), transformTileFX(ott[2]), transformTileFX(ott[1]), ott[1]},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = paramtype2,
         palette = palette,
	 drop = "",
	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = def.node_box_top
	 },
	 selection_box = {
	    type = "fixed",
	    fixed = def.selection_box_top
	 },
	 groups = groups_node_t_2,

	 on_rightclick = function(pos, node, clicker)
            on_toggle(pos, def, "_t_2", name, true)
         end,
         _on_paint = function(pos, new_param2)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, new_param2, -1, name.."_b_2", painted_name.."_b_2")
         end,
         _on_unpaint = function(pos, newnode)
            local node = minetest.get_node(pos)
            on_paint_or_unpaint(pos, newnode.param2, -1, name.."_b_2", unpainted_name.."_b_2")
         end,

         floodable = true,
         on_flood = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_1" and minetest.get_node(bottom).name == name.."_b_2" and oldnode.name == name.."_t_2" then
               minetest.dig_node(bottom)
            end
         end,
         on_blast = function(top)
            minetest.remove_node(top)
         end,
         after_destruct = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_1" and minetest.get_node(bottom).name == name.."_b_2" and oldnode.name == name.."_t_2" then
               minetest.dig_node(bottom)
            end
         end,
         on_dig = function(top, node, digger)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(bottom).name == name.."_b_2" then
               drop_door(bottom, digger, drop_name)
            end
            return minetest.node_dig(top, node, digger)
         end,

	 is_ground_content = false,
	 sounds = sounds,
	 sunlight_propagates = def.sunlight,

         -- Additional fields for rp_paint mod
         _rp_unpainted_node_name = unpainted_name and unpainted_name.."_t_2",
         _rp_painted_node_name = painted_name and painted_name.."_t_2",
         _rp_paint_particle_node = def.paint_particle_node,
   })

end

function door.init_segment(pos, is_open)
   local node = minetest.get_node(pos)
   local state = minetest.get_item_group(node.name, "door_state")
   if state == 0 then
      return
   end
   if is_open == nil then
      is_open = false
   end
   if (state == 2 and is_open == false) or (state == 1 and is_open == true) then
      set_segment_hinge_right(pos)
   end
end

local sounds_wood_door = rp_sounds.node_sound_planks_defaults({
	dig = { name = "rp_sounds_dig_wood", pitch = 1.2, gain = 0.5 },
	dug = { name = "rp_sounds_dug_planks", pitch = 1.1, gain = 0.7 },
	place = { name = "rp_sounds_place_planks", pitch = 1.1, gain = 0.9 },
})

door.register_door(
   "rp_door:door_wood",
   {
      description = S("Wooden Door"),
      inventory_image = "door_wood.png",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=2},
      tiles_top = {"door_wood_a.png", "door_wood_side_a.png"},
      tiles_bottom = {"door_wood_b.png", "door_wood_side_b.png"},
      sounds = sounds_wood_door,
      sunlight = false,
      can_paint = true,
})
door.register_door(
   "rp_door:door_wood_painted",
   {
      description = S("Painted Wooden Door"),
      inventory_image = "door_wood.png^[hsl:0:-100:0",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=1,not_in_creative_inventory=1},
      tiles_top = {"door_wood_a_painted.png", {name="door_wood_side_a.png",color="white"}},
      tiles_bottom = {"door_wood_b_painted.png", {name="door_wood_side_b.png",color="white"}},
      overlay_tiles_top = {{name="door_wood_a_painted_overlay.png",color="white"}, ""},
      overlay_tiles_bottom = {{name="door_wood_b_painted_overlay.png",color="white"}, ""},
      sounds = sounds_wood_door,
      sunlight = false,
      is_painted = true,
      can_unpaint = true,
      paint_particle_node = false,
})

crafting.register_craft(
   {
      output = "rp_door:door_wood",
      items = {
         "rp_default:fiber 6",
         "rp_default:stick 7",
         "rp_default:planks 2",
      }
})

door.register_door(
   "rp_door:door_wood_oak",
   {
      description = S("Oak Door"),
      inventory_image = "rp_door_wood_oak.png",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=2},
      tiles_top = {"rp_door_wood_oak_a.png", "rp_door_wood_oak_side_a.png"},
      tiles_bottom = {"rp_door_wood_oak_b.png", "rp_door_wood_oak_side_b.png"},
      sounds = sounds_wood_door,
      sunlight = false,
      can_paint = true,
})
door.register_door(
   "rp_door:door_wood_oak_painted",
   {
      description = S("Painted Oak Door"),
      inventory_image = "rp_door_wood_oak.png^[hsl:0:-100:0",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=1,not_in_creative_inventory=1},
      tiles_top = {"rp_door_wood_oak_a_painted.png", {name="rp_door_wood_oak_side_a.png",color="white"}},
      tiles_bottom = {"rp_door_wood_oak_b_painted.png", {name="rp_door_wood_oak_side_b.png",color="white"}},
      overlay_tiles_top = {{name="rp_door_wood_oak_a_painted_overlay.png",color="white"}, ""},
      overlay_tiles_bottom = {{name="rp_door_wood_oak_b_painted_overlay.png",color="white"}, ""},
      sounds = sounds_wood_door,
      sunlight = false,
      is_painted = true,
      can_unpaint = true,
      paint_particle_node = false,
})


crafting.register_craft(
   {
      output = "rp_door:door_wood_oak",
      items = {
         "rp_default:fiber 6",
         "rp_default:stick 7",
         "rp_default:planks_oak 2",
      }
})

door.register_door(
   "rp_door:door_wood_birch",
   {
      description = S("Birch Door"),
      inventory_image = "rp_door_wood_birch.png",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=2},
      tiles_top = {"rp_door_wood_birch_a.png", "rp_door_wood_birch_side_a.png"},
      tiles_bottom = {"rp_door_wood_birch_b.png", "rp_door_wood_birch_side_b.png"},
      sounds = sounds_wood_door,
      sunlight = false,
      can_paint = true,
})
door.register_door(
   "rp_door:door_wood_birch_painted",
   {
      description = S("Painted Birch Door"),
      inventory_image = "rp_door_wood_birch.png^[hsl:0:-100:0",
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1,paintable=1,not_in_creative_inventory=1},
      tiles_top = {"rp_door_wood_birch_a_painted.png", {name="rp_door_wood_birch_side_a.png",color="white"}},
      tiles_bottom = {"rp_door_wood_birch_b_painted.png", {name="rp_door_wood_birch_side_b.png",color="white"}},
      overlay_tiles_top = {{name="rp_door_wood_birch_a_painted_overlay.png",color="white"}, ""},
      overlay_tiles_bottom = {{name="rp_door_wood_birch_b_painted_overlay.png",color="white"}, ""},
      sounds = sounds_wood_door,
      sunlight = false,
      is_painted = true,
      can_unpaint = true,
      paint_particle_node = false,
})


crafting.register_craft(
   {
      output = "rp_door:door_wood_birch",
      items = {
         "rp_default:fiber 6",
         "rp_default:stick 7",
         "rp_default:planks_birch 2",
      }
})
minetest.register_craft({
    type = "fuel",
    recipe = "group:door_wood",
    burntime = 15
})


door.register_door(
   "rp_door:door_stone",
   {
      description = S("Stone Door"),
      inventory_image = "door_stone.png",
      groups = {cracky=3,oddly_breakable_by_hand=1,level=-2,door=1},
      tiles_top = {"door_stone_a.png", "door_stone_side_a.png"},
      tiles_bottom = {"door_stone_b.png", "door_stone_side_b.png"},
      sounds = rp_sounds.node_sound_stone_defaults(),
      sunlight = false,
      sound_open_door = "door_open_stone",
      sound_close_door = "door_close_stone",
})

door.toggle_door = function(pos)
   local node = minetest.get_node(pos)
   if minetest.get_item_group(node.name, "door") == 0 then
      return false
   end
   local suffix = string.sub(node.name, -4, -1)
   local prefix = string.sub(node.name, 1, -5)
   local nodedef = minetest.registered_nodes[node.name]
   local snddef = {}
   if nodedef and nodedef.sounds then
      snddef = {
         sound_open_door = nodedef.sounds._rp_door_open,
         sound_close_door = nodedef.sounds._rp_door_close,
         sound_blocked = nodedef.sounds._rp_door_blocked,
      }
   end
   return on_toggle(pos, snddef, suffix, prefix, false)
end

crafting.register_craft(
   {
      output = "rp_door:door_stone",
      items = {
         "rp_default:fiber 6",
         "rp_default:stick 7",
         "group:stone 2",
      }
})

-- Achievements

achievements.register_achievement(
   "adoorable",
   {
      title = S("Adoorable"),
      description = S("Craft a door."),
      times = 1,
      craftitem = "group:door",
      item_icon = "rp_door:door_wood",
      difficulty = 2.2,
})

minetest.register_alias("door:door_stone", "rp_door:door_stone")
minetest.register_alias("door:door_stone_b_1", "rp_door:door_stone_b_1")
minetest.register_alias("door:door_stone_b_2", "rp_door:door_stone_b_2")
minetest.register_alias("door:door_stone_t_1", "rp_door:door_stone_t_1")
minetest.register_alias("door:door_stone_t_2", "rp_door:door_stone_t_2")
minetest.register_alias("door:door_wood", "rp_door:door_wood")
minetest.register_alias("door:door_wood_b_1", "rp_door:door_wood_b_1")
minetest.register_alias("door:door_wood_b_2", "rp_door:door_wood_b_2")
minetest.register_alias("door:door_wood_t_1", "rp_door:door_wood_t_1")
minetest.register_alias("door:door_wood_t_2", "rp_door:door_wood_t_2")
