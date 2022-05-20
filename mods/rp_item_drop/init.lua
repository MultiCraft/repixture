
--
-- Item drop mod
-- By PilzAdam
-- Tweaked by Kaadmy, for Pixture
--

local nav_mod = minetest.get_modpath("rp_nav") ~= nil

item_drop = {}

-- Distance from player to item
-- below which the item magnet kicks in
-- and starts attracting the item.
local ITEM_MAGNET_ACTIVE_DISTANCE = 1.5

-- Distance from player to item
-- below which the player's item magnet
-- will collect the item into the inventory.
local ITEM_MAGNET_COLLECT_DISTANCE = 0.5

-- Distance above ground at which players
-- will collect items
local ITEM_MAGNET_HAND_HEIGHT = 0.5

-- Movement speed at which the item
-- magnet attracts items
local ITEM_MAGNET_ATTRACT_SPEED = 5

-- Time in seconds for which the item magnet is
-- inactive after being dropped by a player
local ITEM_MAGNET_DELAY_AFTER_DROP = 1.5

function item_drop.drop_item(pos, itemstack)
   local rpos = {
      x = pos.x + math.random(-0.3, 0.3),
      y = pos.y,
      z = pos.z + math.random(-0.3, 0.3)
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

local function valid(object)
   local ent = object:get_luaentity()
   return ent.timer ~= nil and ent.item_magnet_timer ~= nil
end

minetest.register_globalstep(
   function(dtime)
      for _,player in ipairs(minetest.get_connected_players()) do
	 if player:get_hp() > 0 or not minetest.settings:get_bool("enable_damage") then
	    local pos = player:get_pos()
	    local inv = player:get_inventory()

            local in_radius = minetest.get_objects_inside_radius(pos, 6.0)

	    for _,object in ipairs(in_radius) do
	       if not object:is_player() and object:get_luaentity()
               and object:get_luaentity().name == "__builtin:item" and valid(object) then
                  local pos1 = table.copy(pos)

                  pos1.y = pos1.y + ITEM_MAGNET_HAND_HEIGHT

                  local pos2 = object:get_pos()

                  local vec = {
                     x = pos1.x - pos2.x,
                     y = pos1.y - pos2.y,
                     z = pos1.z - pos2.z
                  }

                  local len = vector.length(vec)

                  local lua = object:get_luaentity()

                  if object == nil or lua == nil or lua.itemstring == nil then
                    return
                  end

		  -- Item magnet handling
                  if len < ITEM_MAGNET_ACTIVE_DISTANCE and lua.item_magnet_timer <= 0 then
                     -- Activate item magnet
                     if inv and inv:room_for_item("main", ItemStack(lua.itemstring)) then
                        if len >= ITEM_MAGNET_COLLECT_DISTANCE then
                           -- Attract item to player
                           vec = vector.divide(vec, len) -- It's a normalize but we have len yet (vector.normalize(vec))

                           vec.x = vec.x*ITEM_MAGNET_ATTRACT_SPEED
                           vec.y = vec.y*ITEM_MAGNET_ATTRACT_SPEED
                           vec.z = vec.z*ITEM_MAGNET_ATTRACT_SPEED

                           lua.item_magnet = true
                           object:set_velocity(vec)
                           object:set_properties({ physical = false })

                        else
                           -- Player collects item if close enough
                           if inv:room_for_item("main", ItemStack(lua.itemstring)) then
                              if minetest.is_creative_enabled(player:get_player_name()) then
                                  if not inv:contains_item("main", ItemStack(lua.itemstring), true) then
                                      inv:add_item("main", ItemStack(lua.itemstring))
                                  end
                              else
                                  inv:add_item("main", ItemStack(lua.itemstring))
                              end

                              if lua.itemstring ~= "" then
                                 minetest.sound_play(
                                    "item_drop_pickup",
                                    {
                                       pos = pos,
                                       gain = 0.3,
                                       max_hear_distance = 16
                                 }, true)
                              end
                              -- Notify nav mod of inventory change
                              if nav_mod and lua.itemstring == "rp_nav:map" then
                                  nav.map.update_hud_flags(player)
                              end

                              lua.itemstring = ""
                              object:remove()
                           end
                        end
                     end
                  else
                     -- Deactivate item magnet if out of range
		     if lua.item_magnet then
                        object:set_velocity({x = 0, y = object:get_velocity().y, z = 0})
                        lua.item_magnet = false
		     end
                  end
               end
            end
         end
      end
end)

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
   for _,item in ipairs(drops) do
      local obj = minetest.add_item(pos, item)
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
