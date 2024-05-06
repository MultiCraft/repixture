local S = minetest.get_translator("rp_commands")

minetest.register_chatcommand("hp", {
	privs = {server=true},
	params = S("[<player>] <value>"),
	description = S("Set health points of player or yourself"),
	func = function(name, param)
		if minetest.settings:get_bool("enable_damage") == false then
			return false, S("Not possible, damage is disabled.")
		end
		if param == "" then
			return false
		end
		local targetname, hp = string.match(param, "(%S+) (%S+)")
		if not targetname then
			hp = param
			targetname = name
		end
		local target = minetest.get_player_by_name(targetname)
		if target == nil or not target:is_player() then
			return false, S("Player @1 does not exist.", targetname)
		end
		hp = minetest.parse_relative_number(hp, target:get_hp())
		if not hp then
			return false, S("Invalid health!")
		end
		if hp < 0 then
			hp = 0
		end
		local hp_max = target:get_properties().hp_max
		if hp > hp_max then
			hp = hp_max
		end
		if not hp then
			return false, S("Invalid health!")
		end

		target:set_hp(hp, { type = "set_hp", from = "mod", _reason_precise = "hp_command" })
		return true
	end,
})

