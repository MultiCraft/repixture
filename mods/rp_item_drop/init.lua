-- Item drop mod

-- Time in seconds for which the item magnet is
-- inactive after being dropped by a player
local ITEM_MAGNET_DELAY_AFTER_DROP = 1.5

item_drop = {}
function item_drop.drop_item(pos, itemstack, spread)
   local rpos = {
      x = pos.x + math.random(-100, 100)*0.003,
      y = pos.y,
      z = pos.z + math.random(-100, 100)*0.003,
   }

   local drop = minetest.add_item(rpos, itemstack)

   if drop ~= nil then
      local x = math.random(1, 5)
      if math.random(1, 2) == 1 then
         x = -x
      end
      local z = math.random(1, 5)
      if math.random(1, 2) == 1 then
         z = -z
      end

      local vel = drop:get_velocity()
      if not vel then
          vel = {x=0, y=0, z=0}
      end
      vel.x = 1 / x
      vel.z = 1 / z
      drop:set_velocity(vel)
      return drop
   end
end

-- Overwrite Minetest's item_drop function
minetest.item_drop = function(itemstack, dropper, pos)
	local dropper_is_player = dropper and dropper:is_player()
	local dpos = vector.new(pos.x, pos.y, pos.z)
	local cnt = itemstack:get_count()
	if dropper_is_player then
		dpos.y = dpos.y + 1.2
	end
	local item = itemstack:take_item(cnt)
	local obj = minetest.add_item(dpos, item)
	if obj then
		if dropper_is_player then
			local dir = dropper:get_look_dir()
			dir.x = dir.x * 2
			dir.y = dir.y * 2 + 2
			dir.z = dir.z * 2
			obj:set_velocity(dir)
			local lua = obj:get_luaentity()
			if lua then
				lua.dropped_by = dropper:get_player_name()
				lua.item_magnet_timer = ITEM_MAGNET_DELAY_AFTER_DROP
			end
		end
		return itemstack
	end
end

function minetest.handle_node_drops(pos, drops, digger)
   -- If digger is in Creative Mode, give items directly to digger
   if digger and digger:is_player() and minetest.is_creative_enabled(digger:get_player_name()) then
     local inv = digger:get_inventory()
     if inv then
        for _,item in ipairs(drops) do
           if not inv:contains_item("main", item, true) then
              inv:add_item("main", item)
           end
        end
     end
     return
   end

   -- Drop items on the ground, unless global Creative Mode
   -- is enabled
   if minetest.is_creative_enabled("") then
      return
   end
   local node = minetest.get_node(pos)
   local def = minetest.registered_nodes[node.name]
   local droppos = table.copy(pos)
   if def and def.drawtype == "plantlike_rooted" then
      local dir
      if def.paramtype2 == "wallmounted" then
         dir = vector.multiply(minetest.wallmounted_to_dir(node.param2), -1)
      else
         dir = vector.new(0, 1, 0)
      end
      droppos = vector.add(pos, dir)
   end
   for _,item in ipairs(drops) do
      local obj = minetest.add_item(droppos, item)
      if obj ~= nil then
         local x = math.random(1, 5)
         if math.random(1,2) == 1 then
            x = -x
         end
         local z = math.random(1, 5)
         if math.random(1,2) == 1 then
            z = -z
         end
         obj:set_velocity({x=1/x, y=obj:get_velocity().y, z=1/z})
      end
   end
end
