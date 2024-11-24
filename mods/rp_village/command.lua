local S = minetest.get_translator("rp_village")

minetest.register_chatcommand("villages", {
	description = S("List known villages"),
	params = "",
	privs = { debug = true },
	func = function(name, param)
		local list = {}
		for _, vill in pairs(village.villages) do
			--~ List entry for /villages command that lists all known villages. @1 = village name, @2 coordinates
			table.insert(list, "• " .. S("@1: @2", vill.name, minetest.pos_to_string(vill.pos)))
		end
		if #list == 0 then
			return true, S("No villages.")
		end
		local out = table.concat(list, "\n")
		out = S("List of villages:") .. "\n" .. out
		return true, out
	end,
})

minetest.register_chatcommand("find_village", {
	description = S("Find closest known village"),
	params = "",
	privs = { debug = true },
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, S("No player.")
		end
		local pos = player:get_pos()
		local vill = village.get_nearest_village(pos)
		if not vill then
			return true, S("No villages.")
		end
		--~ @1 = village name, @2 = coordinates
		return true, S("Nearest village is @1 at @2.", vill.fname, minetest.pos_to_string(vill.pos))
	end,
})
