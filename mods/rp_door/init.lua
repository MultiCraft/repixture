--
-- Door mod
--

local S = minetest.get_translator("rp_door")

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

-- Registers a door

function door.register_door(name, def)
   local box = {{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5+1.5/16}}

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

	    -- Check protection
            local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
	    for i=0, 1 do
               local protpos = vector.add(pos_protected, vector.new(0, i, 0))
               if minetest.is_protected(protpos, placer:get_player_name()) and
                     not minetest.check_player_privs(placer, "protection_bypass") then
                  minetest.record_protection_violation(protpos, placer:get_player_name())
                  return itemstack
               end
            end

            local pt = pointed_thing.above
            local pt2 = {x=pt.x, y=pt.y, z=pt.z}
            pt2.y = pt2.y+1
	    local ptdef = minetest.registered_nodes[minetest.get_node(pt).name]
	    local pt2def = minetest.registered_nodes[minetest.get_node(pt2).name]
            if
               not ptdef or
               not pt2def or
               not ptdef.buildable_to or
               not pt2def.buildable_to or
               not placer or
               not placer:is_player()
            then
               return itemstack
            end

            -- Check if there's already a door left from this door.
            -- If yes, the door hinge will be right, otherwise it will be left.
            -- This allows to build double doors.
            local p2 = minetest.dir_to_fourdir(placer:get_look_dir())
            local pt3 = {x=pt.x, y=pt.y, z=pt.z}
            if p2 == 0 then
               pt3.x = pt3.x-1
            elseif p2 == 1 then
               pt3.z = pt3.z+1
            elseif p2 == 2 then
               pt3.x = pt3.x+1
            elseif p2 == 3 then
               pt3.z = pt3.z-1
            end
            if minetest.get_item_group(minetest.get_node(pt3).name, "door") == 0 then
               minetest.set_node(pt, {name=name.."_b_1", param2=p2})
               minetest.set_node(pt2, {name=name.."_t_1", param2=p2})
            else
               minetest.set_node(pt, {name=name.."_b_2", param2=p2})
               minetest.set_node(pt2, {name=name.."_t_2", param2=p2})
               set_segment_hinge_right(pt)
               set_segment_hinge_right(pt2)
            end
            if def.sounds and def.sounds.place then
               minetest.sound_play(def.sounds.place, {pos=pt}, true)
            end

            if not minetest.is_creative_enabled(placer:get_player_name()) then
               itemstack:take_item()
            end

            return itemstack
         end,
   })

   local tt = def.tiles_top
   local tb = def.tiles_bottom

   local function on_rightclick(pos, dir, check_name, replace, replace_dir, params)
      local other_pos = table.copy(pos)
      other_pos.y = pos.y+dir
      -- Check for the other door segment.
      -- If it's is missing, it doesn't budge.
      if minetest.get_node(other_pos).name ~= check_name then
         minetest.sound_play(
            def.sound_blocked,
            {
               pos = pos,
               gain = 0.8,
               max_hear_distance = 10
            }, true)
         return
      end
      local p2 = minetest.get_node(pos).param2
      p2 = params[p2+1]

      minetest.swap_node(other_pos, {name=replace_dir, param2=p2})

      minetest.swap_node(pos, {name=replace, param2=p2})

      local snd_1 = def.sound_close_door
      local snd_2 = def.sound_open_door
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
   end

   local function check_player_priv(pos, player)
      if not def.only_placer_can_open then
	 return true
      end
      local meta = minetest.get_meta(pos)
      local pn = player:get_player_name()
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

   -- Door segment: bottom, state 1
   minetest.register_node(
      name.."_b_1",
      {
         inventory_image = tb[1] .. "^rp_door_overlay_state_1.png",
	 tiles = {tb[2], tb[2], tb[2], tb[2], tb[1], tb[1].."^[transformfx"},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = "4dir",
	 drop = name,
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
            if check_player_priv(pos, clicker) then
               on_rightclick(pos, 1, name.."_t_1", name.."_b_2", name.."_t_2", {1,2,3,0})
            end
         end,

         floodable = true,
         on_flood = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_2" and minetest.get_node(top).name == name.."_t_1" then
               remove_node_and_check_falling(top)
               minetest.add_item(bottom, name)
            end
         end,
         after_destruct = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_2" and minetest.get_node(top).name == name.."_t_1" then
               remove_node_and_check_falling(top)
            end
         end,

	 is_ground_content = false,
	 can_dig = check_player_priv,
	 sounds = def.sounds,
	 sunlight_propagates = def.sunlight
   })

   -- Door segment: top, state 1
   minetest.register_node(
      name.."_t_1",
      {
         inventory_image = tt[1] .. "^rp_door_overlay_state_1.png",
	 tiles = {tt[2], tt[2], tt[2], tt[2], tt[1], tt[1].."^[transformfx"},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = "4dir",
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
            if check_player_priv(pos, clicker) then
               on_rightclick(pos, -1, name.."_b_1", name.."_t_2", name.."_b_2", {1,2,3,0})
            end
         end,

         floodable = true,
         on_flood = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_2" and minetest.get_node(bottom).name == name.."_b_1" and oldnode.name == name.."_t_1" then
               minetest.dig_node(bottom)
               minetest.add_item(bottom, name)
            end
         end,
         after_destruct = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_2" and minetest.get_node(bottom).name == name.."_b_1" and oldnode.name == name.."_t_1" then
               minetest.dig_node(bottom)
            end
         end,

	 is_ground_content = false,
	 can_dig = check_player_priv,
	 sounds = def.sounds,
	 sunlight_propagates = def.sunlight,
   })

   -- Door segment: bottom, state 2
   minetest.register_node(
      name.."_b_2",
      {
         inventory_image = "("..tb[1] .. "^[transformfx)^rp_door_overlay_state_2.png",
	 tiles = {tb[2], tb[2], tb[2], tb[2], tb[1].."^[transformfx", tb[1]},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = "4dir",
	 drop = name,
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
            if check_player_priv(pos, clicker) then
               on_rightclick(pos, 1, name.."_t_2", name.."_b_1", name.."_t_1", {3,0,1,2})
            end
         end,

         floodable = true,
         on_flood = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_1" and minetest.get_node(top).name == name.."_t_2" then
               remove_node_and_check_falling(top)
	       minetest.add_item(bottom, name)
            end
         end,
         after_destruct = function(bottom, oldnode)
            local top = { x = bottom.x, y = bottom.y + 1, z = bottom.z }
            if minetest.get_node(bottom).name ~= name.."_b_1" and minetest.get_node(top).name == name.."_t_2" then
               remove_node_and_check_falling(top)
            end
         end,

	 is_ground_content = false,
	 can_dig = check_player_priv,
	 sounds = def.sounds,
	 sunlight_propagates = def.sunlight
   })

   -- Door segment: top, state 2
   minetest.register_node(
      name.."_t_2",
      {
         inventory_image = "("..tt[1] .. "^[transformfx)^rp_door_overlay_state_2.png",
	 tiles = {tt[2], tt[2], tt[2], tt[2], tt[1].."^[transformfx", tt[1]},
         use_texture_alpha = "clip",
	 paramtype = "light",
	 paramtype2 = "4dir",
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
            if check_player_priv(pos, clicker) then
               on_rightclick(pos, -1, name.."_b_2", name.."_t_1", name.."_b_1", {3,0,1,2})
            end
         end,

         floodable = true,
         on_flood = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_1" and minetest.get_node(bottom).name == name.."_b_2" and oldnode.name == name.."_t_2" then
               minetest.dig_node(bottom)
	       minetest.add_item(bottom, name)
            end
         end,
         after_destruct = function(top, oldnode)
            local bottom = { x = top.x, y = top.y - 1, z = top.z }
            if minetest.get_node(top).name ~= name.."_t_1" and minetest.get_node(bottom).name == name.."_b_2" and oldnode.name == name.."_t_2" then
               minetest.dig_node(bottom)
            end
         end,

	 is_ground_content = false,
	 can_dig = check_player_priv,
	 sounds = def.sounds,
	 sunlight_propagates = def.sunlight
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
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1},
      tiles_top = {"door_wood_a.png", "door_wood_side.png"},
      tiles_bottom = {"door_wood_b.png", "door_wood_side.png"},
      sounds = sounds_wood_door,
      sunlight = false,
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
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1},
      tiles_top = {"rp_door_wood_oak_a.png", "rp_door_wood_oak_side.png"},
      tiles_bottom = {"rp_door_wood_oak_b.png", "rp_door_wood_oak_side.png"},
      sounds = sounds_wood_door,
      sunlight = false,
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
      groups = {choppy=3,oddly_breakable_by_hand=2,level=-2,flammable=2,door=1,door_wood=1},
      tiles_top = {"rp_door_wood_birch_a.png", "rp_door_wood_birch_side.png"},
      tiles_bottom = {"rp_door_wood_birch_b.png", "rp_door_wood_birch_side.png"},
      sounds = sounds_wood_door,
      sunlight = false,
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
      tiles_top = {"door_stone_a.png", "door_stone_side.png"},
      tiles_bottom = {"door_stone_b.png", "door_stone_side.png"},
      sounds = rp_sounds.node_sound_stone_defaults(),
      sunlight = false,
      sound_open_door = "door_open_stone",
      sound_close_door = "door_close_stone",
})

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
