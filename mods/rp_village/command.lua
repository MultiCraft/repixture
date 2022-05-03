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
		return true, out
	end,
})
