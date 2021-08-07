hand = {}

for h=0, 9 do
	minetest.register_item("wieldhand:hand_"..h, {
		type = "none",
		wield_image = "wieldhand_"..h..".png",
		wield_scale = {x=1.0,y=1.0,z=3.0},
	})
end

function wieldhand.set_hand(player, skin_tone)
	local inv = player:get_inventory()
	local hand = ItemStack("wieldhand:hand_"..skin_tone)
	inv:set_stack("hand", 1, hand)
end
