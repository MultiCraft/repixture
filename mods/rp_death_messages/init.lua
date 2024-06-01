local S = minetest.get_translator("rp_death_messages")
local NS = function(s) return s end

rp_death_messages = {}

-- Death messages
local msgs = {
	["drown"] = {
		NS("You drowned."),
	},
	["node"] = {
		NS("You took fatal damage from a block."),
	},
	["murder"] = {
		NS("You were killed by @1."),
	},
	["murder_any"] = {
		NS("You were killed."),
	},
	["mob_kill_any"] = {
		NS("You were killed by a hostile creature."),
	},
	["mob_kill_named"] = {
		NS("You were killed by a hostile creature named @1."),
	},
	["fall"] = {
		NS("You fell to your death."),
	},
	["other"] = {
		NS("You died."),
	}
}

local mobkills = {
	["rp_mobs_mobs:walker"] = {
		NS("You were kicked to death by a walker."),
		NS("You were kicked to death by @1, a walker."),
	},
	["rp_mobs_mobs:boar"] = {
		NS("You were killed by a boar."),
		NS("You were killed by @1, a boar."),
	},
	["rp_mobs_mobs:skunk"] = {
		NS("You were killed by a skunk."),
		NS("You were killed by @1, a skunk."),
	},
	["rp_mobs_mobs:villager"] = {
		NS("You were killed by a villager."),
		NS("You were killed by @1, a villager."),
	},
	["rp_mobs_mobs:mineturtle"] = {
		NS("You were killed by a mine turtle."),
		NS("You were killed by @1, a mine turtle."),
	},
}

local dmsg = function(mtype, ...)
	local r = math.random(1, #msgs[mtype])
	return S("@1", S(msgs[mtype][r], ...))
end

-- Select death message for death by mob
local mmsg = function(mtype, mname)
	if mtype and mobkills[mtype] then
		if mname and mname ~= "" then
			return S(mobkills[mtype][2], mname)
		else
			return S(mobkills[mtype][1])
		end
	elseif mname and mname ~= "" then
		return dmsg("mob_kill_named", mname)
	else
		return dmsg("mob_kill_any")
	end
end

local last_damages = { }

minetest.register_on_dieplayer(function(player, reason)
	-- Death message
	local message = minetest.settings:get_bool("rp_show_death_messages", true)
	if message == nil then
		message = true
	end
	if message then
		local name = player:get_player_name()
		if not name then
			return
		end
		local msg
		if last_damages[name] then
			-- custom message
			msg = last_damages[name].message
		elseif reason.type == "node_damage" then
			local pos = player:get_pos()
			local node = reason.node
			local node_def = minetest.registered_nodes[node]
			if node_def and node_def._rp_node_death_message then
				local field = node_def._rp_node_death_message
				local field_msg
				if type(field) == "table" then
					field_msg = field[math.random(1, #field)]
				else
					field_msg = field
				end
				local textdomain
				if node_def.mod_origin then
					textdomain = node_def.mod_origin
				else
					textdomain = "rp_death_messages"
				end
				-- We assume the textdomain of the death message in the node definition
				-- equals the modname.
				msg = minetest.translate(textdomain, field_msg)
			else
				msg = dmsg("node")
			end
		elseif reason.type == "drown" then
			local pos = player:get_pos()
			-- check "head position" to estimate in which node the player drowned
			local cpos = {x=pos.x,y=pos.y+1,z=pos.z}
			local dnode = minetest.get_node(cpos)
			msg = dmsg("drown")
		elseif reason.type == "punch" then
		-- Punches
			local hitter = reason.object
			local hittername, hittertype, hittersubtype, shooter
			-- Custom message
			if last_damages[name] then
				msg = last_damages[name].message
			-- Unknown hitter
			elseif hitter == nil then
				msg = dmsg("murder_any")
			-- Player
			elseif hitter:is_player() then
				hittername = hitter:get_player_name()
				if hittername ~= nil then
					msg = dmsg("murder", hittername)
				else
					msg = dmsg("murder_any")
				end
			-- Mob (according to Common Mob Interface)
			elseif hitter:get_luaentity() and hitter:get_luaentity()._cmi_is_mob then
				local lua = hitter:get_luaentity()
				hittername = rp_mobs.get_nametag(lua)
				hittersubtype = lua.name
				if hittername and hittername ~= "" then
					msg = mmsg(hittersubtype, hittername)
				else
					msg = mmsg(hittersubtype)
				end
			end
		-- Falling
		elseif reason.type == "fall" then
			msg = dmsg("fall")
		-- Other
		elseif reason.type == "set_hp" then
			if last_damages[name] then
				msg = last_damages[name].message
			end
		end
		if not msg then
			msg = dmsg("other")
		end
		minetest.chat_send_player(name, minetest.colorize("#FF8080", msg))
		last_damages[name] = nil
	end
end)

-- dmg_sequence_number is used to discard old damage events
local dmg_sequence_number = 0
local start_damage_reset_countdown = function (player, sequence_number)
	minetest.after(1, function(playername, sequence_number)
		if last_damages[playername] and last_damages[playername].sequence_number == sequence_number then
			last_damages[playername] = nil
		end
	end, player:get_player_name(), sequence_number)
end

-- Send a custom death mesage when damaging a player via set_hp or punch.
-- To be called directly BEFORE damaging a player via set_hp or punch.
-- The next time the player dies due to a set_hp, the message will be shown.
-- The player must die via set_hp within 0.1 seconds, otherwise the message will be discarded.
function rp_death_messages.player_damage(player, message)
	last_damages[player:get_player_name()] = { message = message, sequence_number = dmg_sequence_number }
	start_damage_reset_countdown(player, dmg_sequence_number)
	dmg_sequence_number = dmg_sequence_number + 1
	if dmg_sequence_number >= 65535 then
		dmg_sequence_number = 0
	end
end

