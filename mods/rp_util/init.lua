--
-- Utility functions.
-- See API.md for documentation.
--

util = {}

function util.sort_pos(pos1, pos2)
   -- (function taken from WorldEdit)
   pos1 = {x=pos1.x, y=pos1.y, z=pos1.z}
   pos2 = {x=pos2.x, y=pos2.y, z=pos2.z}
   if pos1.x > pos2.x then
      pos2.x, pos1.x = pos1.x, pos2.x
   end
   if pos1.y > pos2.y then
      pos2.y, pos1.y = pos1.y, pos2.y
   end
   if pos1.z > pos2.z then
      pos2.z, pos1.z = pos1.z, pos2.z
   end
   return pos1, pos2
end

-- TODO: Remove this function (it's deprecated)
function util.fixlight(pos1, pos2)
   -- (function taken from WorldEdit)
   pos1, pos2 = util.sort_pos(pos1, pos2)

   --make area stay loaded

   local manip = minetest.get_voxel_manip()
   manip:read_from_map(pos1, pos2)

   local nodes = minetest.find_nodes_in_area(pos1, pos2, "air")
   local dig_node = minetest.dig_node
   for _, pos in ipairs(nodes) do
      dig_node(pos)
   end

   manip:write_to_map()

   return #nodes
end

function util.nodefunc(pos1, pos2, nodes, func, nomanip)
   -- (function based off fixlight)
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   if not nomanip then
      local manip = minetest.get_voxel_manip()
      manip:read_from_map(pos1, pos2)
   end

   local nodes = minetest.find_nodes_in_area(pos1, pos2, nodes)
   for _, pos in ipairs(nodes) do
      func(pos)
   end
end

function util.remove_area(pos1, pos2, nomanip)
   -- (function based off fixlight)
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   -- TODO: VoxelManip support

   local posses = {}
   for x = pos1.x, pos2.x-1 do
      for y = pos1.y, pos2.y-1 do
         for z = pos1.z, pos2.z-1 do
            table.insert(posses, {x = x, y = y, z = z})
         end
      end
   end
   minetest.bulk_set_node(posses, {name="air"})
end

function util.areafunc(pos1, pos2, func, nomanip)
   -- (function based off fixlight)
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   if not nomanip then
      local manip = minetest.get_voxel_manip()
      manip:read_from_map(pos1, pos2)
   end

   for i = pos1.x, pos2.x-1 do
      for j = pos1.y, pos2.y-1 do
	 for k = pos1.z, pos2.z-1 do
	    func(pos)
	 end
      end
   end
end

function util.reconstruct(pos1, pos2, nomanip)
   -- (function based off fixlight)
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   if not nomanip then
      local manip = minetest.get_voxel_manip()
      manip:read_from_map(pos1, pos2)
   end

   -- Fix chests, locked chests, music players, furnaces
   local nodetypes = {
      "rp_default:chest", "rp_locks:chest", "rp_music:player", "rp_default:furnace",
      "rp_jewels:bench", "rp_default:bookshelf", "rp_itemshow:frame", "rp_itemshow:showcase",
   }
   for n=1, #nodetypes do
       local nodes = minetest.find_nodes_in_area(pos1, pos2, nodetypes[n])
       local node = minetest.registered_nodes[nodetypes[n]]
       for _, pos in ipairs(nodes) do
          node.on_construct(pos)
       end
   end
end

function util.choice(tab, pr)

   local choices = {}

   for n, _ in pairs(tab) do
      table.insert(choices, n)
   end

   if #choices <= 0 then return end

   if pr then
      return choices[pr:next(1, #choices)]
   else
      return choices[math.random(1, #choices)]
   end
end

function util.choice_element(tab, pr)

   local choices = {}

   for _,n in pairs(tab) do
      table.insert(choices, n)
   end

   if #choices <= 0 then return end

   local rnd
   if pr then
      rnd = pr:next(1, #choices)
   else
      rnd = math.random(1, #choices)
   end
   return choices[rnd], rnd
end

function util.dig_up(pos, node, digger, drop_item)
   if node.name == "ignore" then
      return
   end
   local np = {x = pos.x, y = pos.y + 1, z = pos.z}
   local nn = minetest.get_node(np)
   if nn.name == node.name then
      if digger then
          minetest.node_dig(np, nn, digger)
          if drop_item then
             minetest.add_item(pos, drop_item)
          end
      else
	  while nn.name == node.name do
	     minetest.remove_node(np)
             if drop_item then
                minetest.add_item(np, drop_item)
             end
	     np.y = np.y + 1
	     nn = minetest.get_node(np)
          end
      end
   end
end

function util.dig_down(pos, node, digger, drop_item)
   if node.name == "ignore" then
      return
   end
   local np = {x = pos.x, y = pos.y - 1, z = pos.z}
   local nn = minetest.get_node(np)
   if nn.name == node.name then
      if digger then
          minetest.node_dig(np, nn, digger)
          if drop_item then
             minetest.add_item(pos, drop_item)
          end
      else
	  while nn.name == node.name do
	     minetest.remove_node(np)
             if drop_item then
                minetest.add_item(np, drop_item)
             end
	     np.y = np.y - 1
	     nn = minetest.get_node(np)
          end
      end
   end
end

function util.pointed_thing_to_place_pos(pointed_thing, top)
   if pointed_thing.type ~= "node" then
      return nil
   end
   local offset = -1
   if top then
      offset = 1
   end
   local place_in, place_on
   local undernode = minetest.get_node(pointed_thing.under)
   local underdef = minetest.registered_nodes[undernode.name]
   if not underdef then
      return nil
   end
   if underdef.buildable_to then
      place_in = pointed_thing.under
      place_on = vector.add(place_in, vector.new(0, offset, 0))
   else
      place_in = pointed_thing.above
      place_on = vector.add(place_in, vector.new(0, offset, 0))
      local inname = minetest.get_node(place_in).name
      local indef = minetest.registered_nodes[inname]
      if not indef or not indef.buildable_to then
         return nil
      end
   end
   return place_in, place_on
end

function util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
   if not placer or not placer:is_player() then
      return true, itemstack
   end
   if pointed_thing.type ~= "node" then
      return true, minetest.item_place_node(itemstack, placer, pointed_thing)
   end
   local node = minetest.get_node(pointed_thing.under)
   local def = minetest.registered_nodes[node.name]
   if def and def.on_rightclick and
         ((not placer) or (placer and not placer:get_player_control().sneak)) then
      return true, (def.on_rightclick(pointed_thing.under, node, placer, itemstack, pointed_thing) or itemstack)
   end
   return false
end

function util.handle_node_protection(player, pointed_thing)
   if pointed_thing.type ~= "node" then
      return false
   end
   local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
   if minetest.is_protected(pos_protected, player:get_player_name()) and
         not minetest.check_player_privs(player, "protection_bypass") then
      minetest.record_protection_violation(pos_protected, player:get_player_name())
      return true
   end
   return false
end

function util.is_water_source_or_waterfall(pos)
   local node = minetest.get_node(pos)
   local is_water = minetest.get_item_group(node.name, "water") > 0
   if not is_water then
      return false
   end
   local def = minetest.registered_nodes[node.name]
   if not def then
      return false
   end
   if def.liquidtype == "source" then
      return true
   elseif def.liquidtype == "flowing" then
      local bits = node.param2 % 16
      if bits >= 8 then
         return true
      else
         local above = vector.add(pos, vector.new(0,1,0))
	 local anode = minetest.get_node(above)
	 if minetest.get_item_group(anode.name, "water") > 0 then
            return true
	 end
      end
   end
   return false
end
