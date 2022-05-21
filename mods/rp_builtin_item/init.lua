--
-- Builtin item mod
-- By PilzAdam
-- Tweaked by Kaadmy, for Pixture
--
--
local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

local nav_mod = minetest.get_modpath("rp_nav") ~= nil

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



local function add_item_death_particle(ent)
    minetest.add_particle({
        pos = ent.object:get_pos(),
        size = 3,
        texture = "smoke_puff.png",
    })
end

minetest.register_entity(
   ":__builtin:item",
   {
      initial_properties = {
	 hp_max = 1,
	 physical = true,
	 collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
	 collide_with_objects = false,
	 pointable = false,
	 visual = "wielditem",
	 visual_size = {x=0.15, y=0.15},
	 automatic_rotate = math.pi*0.5,
	 textures = {""},
	 spritediv = {x=1, y=1},
	 initial_sprite_basepos = {x=0, y=0},
	 is_visible = false,
	 timer = 0,
	 item_magnet_timer = 0,
      },

      itemstring = "",
      physical_state = true,
      item_magnet = false, -- set by other mod that implements item magnet

      set_item = function(self, itemstring)
		    self.itemstring = itemstring
		    local stack = ItemStack(itemstring)
		    local itemtable = stack:to_table()
		    local itemname = nil
		    if itemtable then
		       itemname = stack:to_table().name
		    end

                    -- Hand and specially marked items are not allowed in entity form
		    if itemname ~= nil and ((itemname == "") or (minetest.get_item_group(itemname, "no_item_drop") == 1)) then
		       self.object:remove()
                       return
		    end

		    local item_texture = nil
		    local item_type = ""
		    if minetest.registered_items[itemname] then
		       item_texture = minetest.registered_items[itemname].inventory_image
		       item_type = minetest.registered_items[itemname].type
		    end
		    local prop = {
		       is_visible = true,
		       textures = {itemname},
		    }
                    local ndef = minetest.registered_nodes[itemname]
                    if ndef then
                       prop.glow = ndef.light_source
                    end
		    self.object:set_properties(prop)
		 end,

      get_staticdata = function(self)
			  --return self.itemstring
			  return minetest.serialize(
			     {
				itemstring = self.itemstring,
				always_collect = self.always_collect,
				timer = self.timer,
			     })
		       end,

      on_activate = function(self, staticdata, dtime_s)
		       if string.sub(staticdata, 1, string.len("return")) == "return" then
			  local data = minetest.deserialize(staticdata)
			  if data and type(data) == "table" then
			     self.itemstring = data.itemstring
			     self.always_collect = data.always_collect
			     self.timer = data.timer
			     if not self.timer then
				self.timer = 0
			     end
			     self.timer = self.timer+dtime_s
			  end
		       else
			  self.itemstring = staticdata
		       end
		       self.object:set_armor_groups({immortal=1})
		       self.object:set_acceleration({x=0, y=-GRAVITY, z=0})
		       self:set_item(self.itemstring)
		    end,

      on_step = function(self, dtime)
		   local itempos = self.object:get_pos()

                   -- Remove item if old
		   local time_to_live = tonumber(minetest.settings:get("item_entity_ttl"))
		   if not time_to_live then time_to_live = 900 end
		   if not self.timer then self.timer = 0 end
		   if not self.item_magnet_timer then self.item_magnet_timer = 0 end

		   self.timer = self.timer + dtime
		   if self.item_magnet_timer >= 0 then
                      self.item_magnet_timer = self.item_magnet_timer - dtime
		   end
		   if time_to_live ~= -1 and (self.timer > time_to_live) then
		      add_item_death_particle(self)
		      minetest.log("action", "[rp_builtin_item] Item entity removed due to timeout at "..minetest.pos_to_string(itempos))
		      self.object:remove()
		      return
		   end

		   local nodename = minetest.get_node(itempos).name
                   local def = minetest.registered_nodes[nodename]
                   -- Destroy item in damaging node
		   if def and def.damage_per_second > 0 then
                      if minetest.get_item_group(nodename, "lava") ~= 0 or minetest.get_item_group(nodename, "fire") ~= 0 then
		          minetest.sound_play("builtin_item_lava", {pos = itempos, gain = 0.45})
                      end
		      add_item_death_particle(self)
		      minetest.log("action", "[rp_builtin_item] Item entity destroyed in damaging node at "..minetest.pos_to_string(itempos))
		      self.object:remove()
		      return
		   end

		   -- Item magnet: Attract item to closest living player

                   local object = self.object
		   local objects_around = minetest.get_objects_inside_radius(self.object:get_pos(), ITEM_MAGNET_ACTIVE_DISTANCE)
		   local closest_dist = math.huge
		   local closest_player = nil
                   local playerpos
		   for o=1, #objects_around do
                      local player = objects_around[o]
		      if player:is_player() then
                         playerpos = player:get_pos()
                         playerpos.y = playerpos.y + ITEM_MAGNET_HAND_HEIGHT
			 if vector.distance(playerpos, itempos) < closest_dist and player:get_hp() > 0 then
			     closest_dist = vector.distance(playerpos, itempos)
			     closest_player = player
		         end
                      end
                   end

                   local lua = object:get_luaentity()

                   if object == nil or lua == nil or lua.itemstring == nil then
                      return
                   end

                   -- Item magnet handling
		   local len, vec
                   if closest_player then
                      --playerpos.y = playerpos.y + ITEM_MAGNET_HAND_HEIGHT
                      vec = {
                         x = playerpos.x - itempos.x,
                         y = playerpos.y - itempos.y,
                         z = playerpos.z - itempos.z
                      }
                      len = vector.length(vec)
                   end
                   if closest_player ~= nil and lua.item_magnet_timer <= 0 and len < ITEM_MAGNET_ACTIVE_DISTANCE then
                      local inv = closest_player:get_inventory()
                      -- Activate item magnet
                      if inv and inv:room_for_item("main", ItemStack(lua.itemstring)) then
                         if len >= ITEM_MAGNET_COLLECT_DISTANCE then
                            -- Attract item to player
                            vec = vector.divide(vec, len) -- It's a normalize but we have len yet (vector.normalize(vec))

                            vec.x = vec.x*ITEM_MAGNET_ATTRACT_SPEED
                            vec.y = vec.y*ITEM_MAGNET_ATTRACT_SPEED
                            vec.z = vec.z*ITEM_MAGNET_ATTRACT_SPEED

                            object:set_velocity(vec)
                            object:set_properties({ physical = false })
                            self.item_magnet = true
                            return
                         else
                            -- Player collects item if close enough
                            if inv:room_for_item("main", ItemStack(lua.itemstring)) then
                               if minetest.is_creative_enabled(closest_player:get_player_name()) then
                                   if not inv:contains_item("main", ItemStack(lua.itemstring), true) then
                                       inv:add_item("main", ItemStack(lua.itemstring))
                                   end
                               else
                                   inv:add_item("main", ItemStack(lua.itemstring))
                               end

                               if lua.itemstring ~= "" then
                                  minetest.sound_play(
                                    "builtin_item_pickup",
                                     {
                                        pos = itempos,
                                        gain = 0.3,
                                        max_hear_distance = 16
                                  }, true)
                               end

                               -- Notify nav mod of inventory change
                               if nav_mod and lua.itemstring == "rp_nav:map" then
                                   nav.map.update_hud_flags(closest_player)
                               end

                               lua.itemstring = ""
                               object:remove()
			       return
                            end
			    return
                         end
                      end
                   else
                      -- Deactivate item magnet if out of range
                      if lua.item_magnet then
                         object:set_velocity({x = 0, y = object:get_velocity().y, z = 0})
                         lua.item_magnet = false
                      end
                   end

                   itempos.y = itempos.y - 0.3
		   local nn = minetest.get_node(itempos).name
		   -- If node is not registered or node is walkably solid:
		   if not minetest.registered_nodes[nn] or minetest.registered_nodes[nn].walkable then
		      if self.physical_state then
			 self.object:set_velocity({x=0,y=0,z=0})
			 self.object:set_acceleration({x=0, y=0, z=0})
			 self.physical_state = false
			 self.object:set_properties(
			    {
			       physical = false
			    })
		      end
		   else
		      if not self.physical_state then
			 self.object:set_velocity({x=0,y=0,z=0})
			 self.object:set_acceleration({x=0, y=-GRAVITY, z=0})
			 self.physical_state = true
			 self.object:set_properties(
			    {
			       physical = true
			    })
		      end
		   end
		end,
   })
