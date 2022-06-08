minetest.register_on_dignode(function(pos, oldnode, digger)
	local below = vector.add(pos, vector.new(0,-1,0))
	local belownode = minetest.get_node(below)
	local at = minetest.get_item_group(belownode.name, "_attached_node_top") == 1
	if at then
		util.dig_down(pos, belownode, digger)
	end
end)
