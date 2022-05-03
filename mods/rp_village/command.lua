local S = minetest.get_translator("rp_village")

minetest.register_chatcommand("villages", {
	description = S("List known villages"),
	params = "",
	privs = { debug = true },
	func = function(name, param)
		local list = {}
		for _, village in pairs(village.villages) do
			-- <Village name>: Coordinates>
			table.insert(list, "• " .. S("@1: @2", village.name, minetest.pos_to_string(village.pos)))
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
		local village = village.get_nearest_village(pos)
		if not village then
			return true, S("No villages.")
		end
		return true, S("Nearest village is @1 at @2.", village.fname, minetest.pos_to_string(village.pos))
	end,
})
