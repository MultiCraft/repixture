wieldhand = {}

local default_hand_def = minetest.registered_items[""]

for h=0, 9 do
	local newdef = table.copy(default_hand_def)
	newdef.wield_image = "wieldhand_"..h..".png"
	minetest.register_item("rp_wieldhand:hand_"..h, newdef)
end

function wieldhand.set_hand(player, skin_tone)
	local inv = player:get_inventory()
	local hand = ItemStack("rp_wieldhand:hand_"..skin_tone)
	inv:set_stack("hand", 1, hand)
end

-- Legacy aliases
for h=0, 9 do
	minetest.register_alias("wieldhand:hand_"..h, "rp_wieldhand:hand_"..h)
end
