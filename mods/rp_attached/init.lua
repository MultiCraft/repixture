rp_attached = {}

-- Detach all specially attached nodes from the node at pos.
-- * pos: Position: Node at which nodes are attached to
-- * digger: optional player object. Specify this if the detaching of
--           nodes should be treated as being dug by digger
rp_attached.detach_from_node = function(pos, digger)
	local below = vector.add(pos, vector.new(0,-1,0))
	local belownode = minetest.get_node(below)
	local at = minetest.get_item_group(belownode.name, "_attached_node_top") == 1
	if at then
		util.dig_down(pos, belownode, digger)
		return
	end
	local above = vector.add(pos, vector.new(0,1,0))
	local abovenode = minetest.get_node(above)
	local ab = minetest.get_item_group(abovenode.name, "_attached_node_bottom") == 1
	if ab then
		util.dig_up(pos, abovenode, digger)
	end
end

minetest.register_on_dignode(function(pos, oldnode, digger)
	rp_attached.detach_from_node(pos, digger)
end)
