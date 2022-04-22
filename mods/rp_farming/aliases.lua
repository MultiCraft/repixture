minetest.register_alias("farming:cotton_seed", "rp_farming:cotton_1")
minetest.register_alias("farming:wheat_seed", "rp_farming:wheat_1")

for i=1, 4 do
	minetest.register_alias("farming:cotton_"..i, "rp_farming:cotton_"..i)
	minetest.register_alias("farming:wheat_"..i, "rp_farming:wheat_"..i)
end
minetest.register_alias("farming:bread", "rp_farming:bread")
minetest.register_alias("farming:cotton", "rp_farming:cotton")
minetest.register_alias("farming:cotton_bale", "rp_farming:cotton_bale")
minetest.register_alias("farming:flour", "rp_farming:flour")
minetest.register_alias("farming:wheat", "rp_farming:wheat")
