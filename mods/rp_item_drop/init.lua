
--
-- Item drop mod
-- By PilzAdam
-- Tweaked by Kaadmy, for Pixture
--

local nav_mod = minetest.get_modpath("rp_nav") ~= nil

item_drop = {}

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
   end
end

local function valid(object)
   return object:get_luaentity().timer ~= nil and object:get_luaentity().timer > 1
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

                  pos1.y = pos1.y + 0.2

                  local pos2 = object:get_pos()

                  local vec = {
                     x = pos1.x - pos2.x,
                     y = pos1.y - pos2.y,
                     z = pos1.z - pos2.z
                  }

                  local len = vector.length(vec)

                  if len < 1.35 then
                     if inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then
                        if len > 0.5 then
                           vec = vector.divide(vec, len) -- It's a normalize but we have len yet (vector.normalize(vec))

                           vec.x = vec.x*3
                           vec.y = vec.y*3
                           vec.z = vec.z*3

                           object:get_luaentity().item_magnet = true
                           object:set_velocity(vec)
                           object:set_properties({ physical = false })

                        else
                           local lua = object:get_luaentity()

                           if object == nil or lua == nil or lua.itemstring == nil then
                              return
                           end

                           if inv:room_for_item("main", ItemStack(lua.itemstring)) then
                              if minetest.settings:get_bool("creative_mode") then
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
                     object:set_velocity({x = 0, y = object:get_velocity().y, z = 0})
                     object:get_luaentity().item_magnet = false
                  end
               end
            end
         end
      end
end)

function minetest.handle_node_drops(pos, drops, digger)
   if minetest.settings:get_bool("creative_mode") then
      if not digger or not digger:is_player() then
         return
      end
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

default.log("mod:rp_item_drop", "loaded")