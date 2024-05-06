local S = minetest.get_translator("rp_commands")

local mod_death_messages = minetest.get_modpath("rp_death_messages") ~= nil

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
		if mod_death_messages then
			if name == targetname then
				rp_death_messages.player_damage(target, S("You suicided."))
			else
				rp_death_messages.player_damage(target, S("You were killed by a higher power."))
			end
		end

		target:set_hp(hp, { type = "set_hp", from = "mod", _reason_precise = "hp_command" })
		return true
	end,
})

if mod_death_messages then
	-- Extend /kill command to show death message
	minetest.register_on_chatcommand(function(name, command, params)
		if command == "kill" then
			local targetname = params
			if targetname == "" then
				targetname = name
			end
			local target = minetest.get_player_by_name(targetname)
			if not target or not target:is_player() then
				return
			end
			if name == targetname then
				rp_death_messages.player_damage(target, S("You suicided."))
			else
				rp_death_messages.player_damage(target, S("You were killed by a higher power."))
			end
		end
	end)
end
