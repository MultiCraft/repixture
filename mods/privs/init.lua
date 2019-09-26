local S = minetest.get_translator("privs")
minetest.register_privilege("maphack", {
	description = S("Can make advanced changes to the map, like placing villages"),
	give_to_singleplayer = false,
	give_to_admin = false,
})
