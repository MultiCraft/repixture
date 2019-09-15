
--
-- Wielditem mod
-- By Kaadmy, for Pixture
--

wielditem = {}

local update_time = 1
local timer = 10 -- needs to be more than update_time

minetest.register_entity(
   "wielditem:wielditem",
   {
      is_visible = false,

      visual = "wielditem",
      visual_size = {x = 0.17, y = 0.17},

      hp_max = 1,

      physical = false,
      pointable = false,
      collide_with_objects = false,
      makes_footstep_sounds = false,
      static_save = false,

      _wielder = nil,

      on_activate = function(self, staticdata)
         local name = staticdata
         local wielder = minetest.get_player_by_name(name)
         if wielder and wielder:is_player() then
            self._wielder = wielder
         else
            -- Remove orphan wielditem
            minetest.log("info", "[wielditem] Attempted to spawn orphan wielditem entity!")
            self.object:remove()
         end
         self.object:set_armor_groups({immortal=1})
      end,
      on_step = function(self, dtime)
		   local player = self._wielder

                   -- Remove orphan wielditem
		   if player == nil or (minetest.get_player_by_name(player:get_player_name()) == nil) then
		      self.object:remove()
		      return
		   end
		   
		   local itemname = player:get_wielded_item():get_name()

		   if itemname ~= "" then
		      self.object:set_properties({textures = {itemname}, is_visible=true})
		   else
		      self.object:set_properties({is_visible=false})
		   end
		end
   })

local function attach_wielditem(player)
   local name = player:get_player_name()
   local pos = player:get_pos()

   wielditem[name] = minetest.add_entity(pos, "wielditem:wielditem", name)
   wielditem[name]:set_attach(player, "right_arm", {x = -1.5, y = 5.7, z = 2.5}, {x = 90, y = -45, z = 270})
   wielditem[name]:get_luaentity()._wielder = player
end

minetest.register_on_joinplayer(function(player)
	minetest.after(1, function(player)
		if player and player:is_player() then
			attach_wielditem(player)
		end
	end, player)
end)

default.log("mod:wielditem", "loaded")
