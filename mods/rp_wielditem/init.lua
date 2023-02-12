
--
-- Wielditem mod
--

local wielditem = {}

local default_rotation = {x = -90, y = 225, z = 90}

local function set_attach(player, object, rotation_y)
	local rotation = table.copy(default_rotation)
	if rotation_y then
		rotation.y = rotation_y
	end
	object:set_attach(player, "right_arm", {x = -1.5, y = 5.7, z = 2.5}, rotation)
end

local function attach_wielditem(player)
	 local name = player:get_player_name()
	 local pos = player:get_pos()

	 wielditem[name] = minetest.add_entity(pos, "rp_wielditem:wielditem", name)
	 if not wielditem[name] then
		 return false
	 end
	 set_attach(player, wielditem[name])
	 wielditem[name]:get_luaentity()._wielder = player
	 return true
end

minetest.register_entity("rp_wielditem:wielditem", {
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
	_itemname = nil,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})
	end,
	on_deactivate = function(self)
		-- Respawn wielditem entity if neccessary
		local wielder = self._wielder
		if wielder and wielder:is_player() then
			minetest.after(3, function(player)
				if player and player:is_player() then
					attach_wielditem(player)
				end
			end, wielder)
		end
	end,
	on_step = function(self, dtime)
		local player = self._wielder
		-- Remove orphan wielditem
		if player == nil or (minetest.get_player_by_name(player:get_player_name()) == nil) then
			minetest.log("info", "[rp_wielditem] Removed orphan wielditem!")
			self.object:remove()
			return
		end

		local itemname = player:get_wielded_item():get_name()

		-- Update displayed item if it has changed
		if itemname ~= self._itemname then
			if itemname ~= "" then
				self.object:set_properties({wield_item = itemname, is_visible=true})
				local def = minetest.registered_items[itemname]
				if def and def._rp_wielditem_rotation then
					-- Custom rotation
					set_attach(player, self.object, def._rp_wielditem_rotation)
				else
					-- Default rotation
					set_attach(player, self.object)
				end
			else
				self.object:set_properties({is_visible=false})
			end
			-- Remember item name for the next step
			self._itemname = itemname
		end
	end
})

minetest.register_on_joinplayer(function(player)
	local spawn_wielditem
	spawn_wielditem = function(player)
		if not player or not player:is_player() then
			return
		end
		attach_wielditem(player)
	end
	minetest.after(3, spawn_wielditem, player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	wielditem[name] = nil
end)
