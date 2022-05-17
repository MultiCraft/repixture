--
-- Utility functions
--

util = {}

function util.sort_pos(pos1, pos2)
   -- function taken from worldedit
   -- ensure that pos2 has greater coords than pos1
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

function util.fixlight(pos1, pos2)
   -- function taken from worldedit
   -- repair most lighting in a block
   local pos1, pos2 = util.sort_pos(pos1, pos2)

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
   -- function based off fixlight
   -- call a function for every node of a single type
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
   -- function based off fixlight
   -- call a function for every node of a single type
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   if not nomanip then
      local manip = minetest.get_voxel_manip()
      manip:read_from_map(pos1, pos2)
   end

   for i = pos1.x, pos2.x-1 do
      for j = pos1.y, pos2.y-1 do
	 for k = pos1.z, pos2.z-1 do
	    minetest.remove_node({x = i, y = j, z = k})
	 end
      end
   end

   manip:write_to_map()
end

function util.areafunc(pos1, pos2, func, nomanip)
   -- function based off fixlight
   -- call a function for every node of a single type
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
   -- function based off fixlight
   -- force a re-construction of the nodes in an area, for fixing missing metadata in schematics
   local pos1, pos2 = util.sort_pos(pos1, pos2)

   if not nomanip then
      local manip = minetest.get_voxel_manip()
      manip:read_from_map(pos1, pos2)
   end

   -- Fix chests, locked chests, music players, furnaces
   local nodetypes = { "rp_default:chest", "rp_locks:chest", "rp_music:player", "rp_default:furnace", "rp_jewels:bench" }
   for n=1, #nodetypes do
       local nodes = minetest.find_nodes_in_area(pos1, pos2, nodetypes[n])
       local node = minetest.registered_nodes[nodetypes[n]]
       for _, pos in ipairs(nodes) do
          node.on_construct(pos)
       end
   end
end

function util.choice(tab, pr)
   -- return a random index of the given table

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
   -- return a random element of the given table
   -- 2nd return value is index of chosen element
   -- Returns nil if table is empty

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

-- util.split function taken from a StackOverflow answer.
-- http://stackoverflow.com/questions/12709205/split-a-string-and-store-in-an-array-in-lua
function util.split(str, tok)
   -- Source: http://lua-users.org/wiki/MakingLuaLikePhp
   -- Credit: http://richard.warburton.it/

   if not tok then return {} end

   local pos = 0
   local arr = {}

   for st, sp in function() return string.find(str, tok, pos, true) end do
      table.insert(arr, string.sub(str, pos, st - 1))
      pos = sp + 1
   end

   table.insert(arr, string.sub(str, pos))

   return arr
end

-- Dig all the nodes above pos that have the same nodename
-- as the node as pos, until a different node is reached.
-- digger is a player object
function util.dig_up(pos, node, digger)
   local np = {x = pos.x, y = pos.y + 1, z = pos.z}
   local nn = minetest.get_node(np)
   if nn.name == node.name then
      if digger then
         minetest.node_dig(np, nn, digger)
      else
         minetest.remove_node(np)
      end
   end
end

-- Dig all the nodes blow pos that have the same nodename
-- as the node as pos, until a different node is reached.
-- digger is a player object
function util.dig_down(pos, node, digger)
   local np = {x = pos.x, y = pos.y - 1, z = pos.z}
   local nn = minetest.get_node(np)
   if nn.name == node.name then
      minetest.node_dig(np, nn, digger)
   end
end

-- Helper function to determine the correct position when
-- the player places a "plant-like" node like a sapling.
-- The goal is the node will end up on top of a "floor"
-- node when possible, while also taking buildable_to
-- into account.
--
-- Takes a pointed_thing from a on_place callback or similar.
-- Returns <place_in>, <place_on> if success, nil otherwise
-- * place_in: Where the node is suggested to be placed
-- * place_on: Directly below place_in
function util.pointed_thing_to_place_pos(pointed_thing)
   if pointed_thing.type ~= "node" then
      return nil
   end
   local place_in, place_on
   local undernode = minetest.get_node(pointed_thing.under)
   local underdef = minetest.registered_nodes[undernode.name]
   if not underdef then
      return nil
   end
   if underdef.buildable_to then
      place_in = pointed_thing.under
      place_on = vector.add(place_in, vector.new(0, -1, 0))
   else
      place_in = pointed_thing.above
      place_on = vector.add(place_in, vector.new(0, -1, 0))
      local inname = minetest.get_node(place_in).name
      local indef = minetest.registered_nodes[inname]
      if not indef or not indef.buildable_to then
         return nil
      end
   end
   return place_in, place_on
end

-- Use this function for the on_place handler of tools and similar items
-- that are supposed to do something special when "placing" them on
-- a node. This makes sure the on_rightclick handler of the node
-- takes precedence, unless the player held down the sneak key.
-- Parameters: Same as the on_place of nodes
-- Returns <handled>, <handled_itemstack>
-- * <handled>: true if the function handled the placement. Your on_place handler should return <handled_itemstack>.
--              false if the function did not handle the placement. Your on_place handler can proceed normally.
-- * <handled_itemstack>: Only set if <handled> is true. Contains the itemstack you should return in your
--                        on_place handler
-- Recommended usage is by putting this boilerplate code at the beginning of your function:
--[[
   local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
   if handled then
      return handled_itemstack
   end
]]
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

-- Check if pointed_thing is protected, if player is the "user" of that thing,
-- and does the protection violation handling if needed.
-- returns true if it was protected (and protection dealt with), false otherwise.
-- Always returns false for non-nodes
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
