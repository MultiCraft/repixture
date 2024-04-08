rp_checkitem = {}

-- Time in seconds to check inventory for items
local ITEM_CHECK_TIME = 10

local items_to_watch = {}

function rp_checkitem.register_on_got_item(item, callback)
	table.insert(items_to_watch, {item=item, callback=callback})
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	for i=1, #items_to_watch do
		local entry = items_to_watch[i]
		if inv:contains_item("main", entry.item) then
			entry.callback(player)
		end
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "put" then
		local itemname = inventory_info.stack:get_name()
		for i=1, #items_to_watch do
			local entry = items_to_watch[i]
			if inventory_info.stack:get_name() == entry.item then
				entry.callback(player)
			end
		end
	end
end)

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < ITEM_CHECK_TIME then
		return
	end
	timer = 0

	local players = minetest.get_connected_players()
	for p=1, #players do
		local player = players[p]
		local inv = player:get_inventory()
		for i=1, #items_to_watch do
			local entry = items_to_watch[i]
			if inv:contains_item("main", entry.item) then
				entry.callback(player)
			end
		end
	end
end)

