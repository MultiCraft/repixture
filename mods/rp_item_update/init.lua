rp_item_update = {}

local updaters = {}

rp_item_update.register_item_update = function(itemname, updater)
	if updaters[itemname] then
		return false
	end
	updaters[itemname] = updater
	return true
end

rp_item_update.update_item = function(itemstack)
	local iname = itemstack:get_name()
	if updaters[iname] then
		local new_itemstack = updaters[iname](itemstack)
		return new_itemstack
	else
		return nil
	end
end

local update_inventory = function(inventory, lists)
	if not lists then
		lists = { main = inventory:get_list("main") }
	end
	for listname, list in pairs(lists) do
		local changed = false
		for i=1, #list do
			local item = list[i]
			local new_item = rp_item_update.update_item(item)
			if new_item then
				list[i] = new_item
				changed = true
			end
		end
		if changed then
			inventory:set_list(listname, list)
		end
	end
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	update_inventory(inv)
end)

minetest.register_lbm({
	label = "Update items in containers",
	name = "rp_item_update:update_containers",
	nodenames = { "group:container" },
	run_at_every_load = true,
	action = function(pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local lists = inv:get_lists()
		update_inventory(inv, lists)
	end,
})
