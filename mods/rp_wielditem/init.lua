
--
-- Wielditem mod
-- By Kaadmy, for Pixture
--

local wielditem = {}

local update_time = 1
local timer = 10 -- needs to be more than update_time

local function attach_wielditem(player)
	 local name = player:get_player_name()
	 local pos = player:get_pos()

	 wielditem[name] = minetest.add_entity(pos, "rp_wielditem:wielditem", name)
	 wielditem[name]:set_attach(player, "right_arm", {x = -1.5, y = 5.7, z = 2.5}, {x = 90, y = -45, z = 270})
	 wielditem[name]:get_luaentity()._wielder = player
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

		if itemname ~= "" then
			self.object:set_properties({wield_item = itemname, is_visible=true})
		else
			self.object:set_properties({is_visible=false})
		end
	end
})

minetest.register_on_joinplayer(function(player)
	minetest.after(3, function(player)
		if player and player:is_player() then
			attach_wielditem(player)
		end
	end, player)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	wielditem[name] = nil
end)
