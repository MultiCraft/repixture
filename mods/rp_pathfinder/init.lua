-- Maximum allowed elements in the open list before aborting
local MAX_OPEN = 300

rp_pathfinder = {}

-- Returns true if node is walkable
local function walkable_default(node)
	local def = minetest.registered_nodes[node.name]
	if not def or def.walkable then
		return true
	else
		return false
	end
end

-- Returns true is node is "blocking"
local blocking_default = walkable_default

-- Returns true if node is climbable
-- * node: Node table
-- * dir: Check for vertical climb restriction:
--    * 1: Check if can climb up (no 'disable_jump' group)
--    * -1: Check if can climb down (no 'disable_descend' group)
--    * nil: Ignore climb restrictions
local function climbable_default(node, dir)
	local def = minetest.registered_nodes[node.name]
	if not def then
		return false
	elseif def.climbable then
		if dir then
			if dir == 1 then
				return minetest.get_item_group(node.name, "disable_jump") == 0
			elseif dir == -1 then
				return minetest.get_item_group(node.name, "disable_descend") == 0
			else
				error("[rp_pathfinder] climbable: invalid dir argument!")
			end
		else
			return true
		end
	else
		return false
	end
end

-- Returns true player can jump from node
local function jumpable(node)
	return minetest.get_item_group(node.name, "disable_jump") == 0
end

-- Return the height of the given node or pessimistic_height
-- if the node is too complex. This function is not 100% accurate
-- and does not cover all possible node definitions and param2 values.
-- TODO: Cover all possible node definitions and param2 values.
local function get_node_height(node, pessimistic_height)
	local def = minetest.registered_nodes[node.name]
	if not def then
		return 1
	end
	if not def.walkable then
		return 0
	end
	local node_box
	if def.collision_box then
		node_box = def.collision_box
	elseif def.node_box then
		node_box = def.node_box
	end
	if node_box then
		if node_box.type == "regular" then
			return 1
		elseif node_box.type == "fixed" or (node_box.type == "connected" and node_box.fixed) then
			local max_y = 0
			local fixed = node_box.fixed
			if type(fixed[1]) == "table" then
				for f=1, #fixed do
					max_y = math.max(max_y, fixed[f][5])
				end
			else
				max_y = fixed[5]
			end
			return (0.5 + max_y)
		elseif node_box.type == "leveled" and def.paramtype2 == "leveled" then
			if node.param2 == 0 then
				return def.leveled or 0
			else
				return (node.param2 % 128) / 64
			end
		else
			return pessimistic_height
		end
	else
		-- No node box, this is a normal cube
		return 1
	end
end

-- 2D distance heuristic between pos1 and pos2
local function get_distance_2d(pos1, pos2)
	local distX = math.abs(pos1.x - pos2.x)
	local distZ = math.abs(pos1.z - pos2.z)

	-- Manhattan distance
	return distX + distZ
end

-- Get actual cost to walk from pos1 to pos2 (which must be a neighbor)
-- * pos1: Origin position
-- * pos2: Target position (neighbor of pos1)
-- * get_node: get_node function
-- * get_floor_cost(node): Function that, given a node table, returns the
--   cost of walking *on* this node (default cost is 1)
local function get_neighbor_cost(pos1, pos2, get_node, get_floor_cost)
	if not get_floor_cost then
		return 1
	end
	local floor = vector.offset(pos2, 0, -1, 0)
	local floornode = get_node(floor)
	return get_floor_cost(floornode)
end

-- Checks nodes above pos to be non-blocking.
-- Returns true if all nodes are non-blocking,
-- false otherwise
--
-- * pos: Start position (will not be checked)
-- * nodes_above: number of nodes above pos to check
-- * nh: Node handers table
-- * get_node: Note getter function
local function check_height_clearance(pos, nodes_above, nh, get_node)
	if nodes_above <= 0 then
		-- Trivial: No nodes need to be checked
		return true
	end
	local npos = table.copy(pos)
	local nnode
	local height = 0
	repeat
		height = height + 1
		npos.y = npos.y + 1
		nnode = get_node(npos)
		if nh.blocking(nnode) then
			return false
		end
	until height >= nodes_above
	return true
end

local function vertical_walk(start_pos, vdir, max_height, stop_func, stop_value, get_node, precise_height)
	local pos = table.copy(start_pos)
	local height = 0
	local ok = false

	local final_node
	while height < max_height do
		pos.y = pos.y + vdir
		local node = get_node(pos)
		height = height + 1
		if stop_func(node) == stop_value then
			ok = true
			break
		end
		final_node = node
	end
	-- Precide height mode:
	-- Reduce returned height if the final node is node a standard cube,
	-- e.g. a slab
	if precise_height and ok then
		if not final_node then
			final_node = get_node(start_pos)
		end
		local nheight
		local pessimistic
		if vdir > 0 then
			pessimistic = 2
		else
			pessimistic = 0
		end
		nheight = get_node_height(final_node, pessimistic)
		height = height - (1 - nheight)
	end

	if ok then
		return pos, height
	end
end

-- Simulate falling with a given drop_height limit
-- and returns the final node we land *in*
local function drop_down(pos, drop_height, stop_at_climb, nh, get_node)
	local stop = function(node)
		return nh.blocking(node) or nh.walkable(node) or (stop_at_climb and nh.climbable(node))
	end
	local dpos = table.copy(pos)
	-- Get the first blocking or walkable node below neighbor

	-- add 1 node to drop height because
	-- we need an 1 node offset for the floor (on which we drop on top)
	drop_height = drop_height + 1

	local floor = vertical_walk(dpos, -1, drop_height, stop, true, get_node)
	if not floor then
		return nil
	end

	local fnode = get_node(floor)
	if nh.blocking(fnode) and not nh.walkable(fnode) then
		-- If node is blocking but not walkable, we must not take it;
		-- its a potential danger
		return nil
	else
		floor.y = floor.y + 1
		return floor
	end
end

local function get_neighbor_floor_pos(neighbor_pos, current_pos, clear_height, jump_height, drop_height, climb, nh, get_node)
	local npos = table.copy(neighbor_pos)
	local nnode = get_node(npos)
	-- Climb
	if climb then
		-- If neighbor is climbable
		if nh.climbable(nnode) and not nh.blocking(nnode) then
			return npos
		-- If node *below* neighbor is climbable
		elseif not nh.blocking(nnode) then
			local bpos = vector.offset(npos, 0, -1, 0)
			local bnode = get_node(bpos)
			if nh.climbable(bnode) and not nh.blocking(bnode) then
				return npos
			end
		end
	end
	-- Drop down
	if not nh.walkable(nnode) and not nh.blocking(nnode) then
		local floor = drop_down(npos, drop_height, false, nh, get_node)
		return floor
	-- Jump
	else
		local stop = function(node)
			return (not nh.walkable(node)) or nh.blocking(node)
		end

		-- Get the first non-walkable node above the neighbor
		local target_pos, height = vertical_walk(npos, 1, jump_height, stop, true, get_node, true)

		if target_pos then
			-- Check if the floor node is lowered and if yes,
			-- increase the required jump height by the difference.
			-- E.g. a slab of height 0.5 would increase the
			-- required jump height by 0.5
			local floor = vector.offset(current_pos, 0, -1, 0)
			local fnode = get_node(floor)
			-- for normal nodes, add_height will be 0.
			-- for overhigh nodes, add_height will be 0.
			-- for nodes with a height lower than 1 (like slabs)
			-- add_height will increase by the difference from a full node.
			local add_height = math.max(0, 1-get_node_height(fnode, 0))
			height = height + add_height
			-- Check if we could still jump high enough
			if jump_height < height then
				return
			end

			-- Also check the nodes above current pos for any blocking nodes,
			-- since this is where the player has to jump

			-- If the top node is non-walkable,
			-- we don't want to jump on it
			local tnode = get_node(vector.offset(target_pos, 0, -1, 0))
			if not nh.walkable(tnode) then
				return
			end

			-- Also take height clearance into account
			height = height + (clear_height - 1)
			local jump_blocking_pos = vertical_walk(current_pos, 1, height, nh.blocking, true, get_node)
			if not jump_blocking_pos then
				return target_pos
			end
		end
	end
end

-- 4 neighbors: the 4 cardinal directions
local neighbor_dirs_2d = {
	{ x = -1, y = 0, z = 0 },
	{ x = 0, y = 0, z = -1 },
	{ x = 0, y = 0, z = 1 },
	{ x = 1, y = 0, z = 0 },
}

-- Reverse a list of values
local reverse_list = function(list)
	local reverse_list = {}
	for i=#list, 1, -1 do
		local elem = list[i]
		table.insert(reverse_list, elem)
	end
	return reverse_list
end

-- Constructs the final path if found
local function build_finished_path(closed_set, start_hash, final_hash)
	-- Basically, we walk backwards from the final node until we reached the start node
	local path = {}
	-- Start from the end ...
	local index = final_hash
	while start_hash ~= index do
		if not closed_set[index] then
			-- If this happens, this must be an error in the algorithm
			-- as the pathfinder has botched the closed_set somehow.
			error("rp_pathfinder: closed_set["..index.."] is nil in build_finished_path!")
		end
		table.insert(path, closed_set[index].pos)
		-- ... go to the previous node ...
		index = closed_set[index].parent
	end
	table.insert(path, closed_set[index].pos)
	local reverse_path = reverse_list(path)
	return reverse_path
end

function rp_pathfinder.get_voxelmanip_for_path(pos1, pos2, searchdistance)
	local min_pos = {
		x = math.min(pos1.x, pos2.x) - searchdistance,
		y = math.min(pos1.y, pos2.y) - searchdistance,
		z = math.min(pos1.z, pos2.z) - searchdistance,
	}
	local max_pos = {
		x = math.max(pos1.x, pos2.x) + searchdistance,
		y = math.max(pos1.y, pos2.y) + searchdistance,
		z = math.max(pos1.z, pos2.z) + searchdistance,
	}
	return minetest.get_voxel_manip(min_pos, max_pos)
end

-- The main pathfinding function (see API.md)
function rp_pathfinder.find_path(pos1, pos2, searchdistance, options, timeout)
	-- Keep track of time
	local start_time = minetest.get_us_time()

	-- round positions if not done by former functions
	pos1 = vector.round(pos1)
	pos2 = vector.round(pos2)

	-- Trivial: pos1 and pos2 are the same
	if vector.equals(pos1, pos2) then
		return { pos1 }
	end

	local min_pos = {
		x = math.min(pos1.x, pos2.x) - searchdistance,
		y = math.min(pos1.y, pos2.y) - searchdistance,
		z = math.min(pos1.z, pos2.z) - searchdistance,
	}
	local max_pos = {
		x = math.max(pos1.x, pos2.x) + searchdistance,
		y = math.max(pos1.y, pos2.y) + searchdistance,
		z = math.max(pos1.z, pos2.z) + searchdistance,
	}

	-- Options
	if not options then
		options = {}
	end
	local clear_height = math.max(1, options.clear_height or 1)
	local max_drop = options.max_drop or 0
	local max_jump = options.max_jump or 0
	local respect_disable_jump = options.respect_disable_jump or false
	local respect_climb_restrictions = options.respect_climb_restrictions
	local get_floor_cost = options.get_floor_cost
	if respect_climb_restrictions == nil then
		respect_climb_restrictions = true
	end
	local climb = options.climb or false
	local nh = {
		walkable = options.handler_walkable or walkable_default,
		blocking = options.handler_blocking or blocking_default,
		climbable = options.handler_climbable or climbable_default,
	}
	local get_node
	if options.use_vmanip then
		local vmanip
		if options.vmanip then
			vmanip = options.vmanip
		else
			vmanip = minetest.get_voxel_manip(min_pos, max_pos)
		end
		get_node = function(pos)
			return vmanip:get_node_at(pos)
		end
	else
		get_node = minetest.get_node
	end

	-- Can't make a path if start or end node
	-- are blocking
	local target_node = get_node(pos2)
	if nh.blocking(target_node) then
		-- End position blocked
		return nil, "pos2_blocked"
	end

	local start_node = get_node(pos1)
	if nh.blocking(start_node) then
		-- Start position blocked
		return nil, "pos1_blocked"
	end

	-- Simulate an initial drop from pos1
	pos1 = drop_down(pos1, max_drop, climb, nh, get_node)
	if not pos1 then
		return nil, "pos1_too_high"
	end

	local start_hash = minetest.hash_node_position(pos1)
	local final_hash = minetest.hash_node_position(pos2)

	local open_set = {}
	local closed_set = {}

	local open_set_size = 0

	-- Helper functions to set and get search nodes
	local set_search_node = function(set, hash, values)
		if set == open_set then
			if not set[hash] and values ~= nil then
				open_set_size = open_set_size + 1
			elseif set[hash] and values == nil then
				open_set_size = open_set_size - 1
			end
		end
		set[hash] = values
	end
	local get_search_node = function(set, hash)
		return set[hash]
	end
	local get_next_search_node = function(set)
		return next(set)
	end

	--[[ Syntax of a single search node for the A* search:
		{
			pos: World position of the Minetest node that this search node represents
			parent: Reference to preceding node in the search (nil for start node)
			h: Heuristic cost estimate from node to finish
			g: Total cost from start to this node
			f: Equals g+h
		}
	]]

	-- Add the first search node to open set at the start

	local h_first = get_neighbor_cost(pos1, pos2, get_node, get_floor_cost)
	set_search_node(open_set, start_hash, {
		pos = pos1,
		parent = nil,
		h = h_first,
		g = 0,
		f = h_first,
	})

	-- Node has 4 neighbors: 4 cardinal directions
	local neighbor_dirs = neighbor_dirs_2d

	while open_set_size > 0 do
		-- Find node with lowest f cost (f value)
		local current_hash, current_data = get_next_search_node(open_set)
		for hash, data in pairs(open_set) do
			if data.f < open_set[current_hash].f or data.f == current_data.f and data.h < current_data.h then
				current_hash = hash
				current_data = data
			end
		end

		set_search_node(open_set, current_hash, nil)
		set_search_node(closed_set, current_hash, current_data)

		-- Target position found: Return path
		if current_hash == final_hash then
			return build_finished_path(closed_set, start_hash, current_hash)
		end

		local current_pos = current_data.pos
		local current_node = get_node(current_pos)
		local current_neighbor_dirs = neighbor_dirs
		local current_max_jump = max_jump
		local current_max_drop = max_drop
		if climb then
			current_neighbor_dirs = table.copy(neighbor_dirs)
			if respect_climb_restrictions then
				if nh.climbable(current_node) then
					if nh.climbable(current_node, 1) then
						table.insert(current_neighbor_dirs, {x=0,y=1,z=0})
					end
					if nh.climbable(current_node, -1) then
						table.insert(current_neighbor_dirs, {x=0,y=-1,z=0})
					end
					current_max_jump = 0
				else
					table.insert(current_neighbor_dirs, {x=0,y=-1,z=0})
				end
			else
				if nh.climbable(current_node) then
					table.insert(current_neighbor_dirs, {x=0,y=1,z=0})
					current_max_jump = 0
				end
				table.insert(current_neighbor_dirs, {x=0,y=-1,z=0})
			end

			if current_max_jump > 0 then
				local below_pos = vector.offset(current_pos, 0, -1, 0)
				local below_node = get_node(below_pos)
				if nh.climbable(below_node) then
					current_max_jump = 0
				end
			end
		end
		-- Prevent jumping from disable_jump nodes (if enabled)
		if respect_disable_jump and max_jump > 0 then
			local current_jumpable = jumpable(current_node)
			local below_current_pos = table.copy(current_pos)
			below_current_pos.y = below_current_pos.y - 1
			local below_current_node = get_node(below_current_pos)
			local below_jumpable = jumpable(below_current_node)

			if not current_jumpable or not below_jumpable then
				current_max_jump = 0
			end
		end

		local neighbors = {}

		for n=1, #current_neighbor_dirs do
			local ndir = current_neighbor_dirs[n]
			local x, y, z = ndir.x, ndir.y, ndir.z
			local neighbor_pos = {x = current_pos.x + x, y = current_pos.y + y, z = current_pos.z + z}

			if vector.in_area(neighbor_pos, min_pos, max_pos) then

				local neighbor = get_node(neighbor_pos)
				-- Check height clearance of raw (unmodified) neighbor
				if check_height_clearance(neighbor_pos, clear_height-1, nh, get_node) then
					-- Get floor position of neighbor. Implements jumping up or falling down.
					local neighbor_floor
					if y == 0 then
						neighbor_floor = get_neighbor_floor_pos(neighbor_pos, current_pos, clear_height,
								current_max_jump, current_max_drop, climb, nh, get_node)
					-- In case of Y change, we do a climb check
					elseif climb then
						if not nh.blocking(neighbor) then
							local safe_floor = true
							-- If we climb downwards, check if the node below our destination
							-- is safe to stand on
							if y < 0 then
								local below = vector.offset(neighbor_pos, 0, -1, 0)
								local bnode = get_node(below)
								safe_floor = nh.walkable(bnode) or nh.climbable(bnode)
							end
							if safe_floor then
								neighbor_floor = neighbor_pos
							end
						end
					end
					if neighbor_floor then
						-- Check height clearance of modified neighbor
						if check_height_clearance(neighbor_floor, clear_height-1, nh, get_node) then
							local hash = minetest.hash_node_position(neighbor_floor)
							table.insert(neighbors, {
								hash = hash,
								pos = neighbor_floor,
							})
						end
					end
				end
			end
		end

		for _, neighbor in pairs(neighbors) do
			local in_closed_list = get_search_node(closed_set, neighbor.hash) ~= nil
			if neighbor.hash ~= current_hash and not in_closed_list then
				local g = 0 -- cost from start
				local h -- estimated cost from search node to finish
				local f -- g+h
				local neighbor_cost = current_data.g + get_neighbor_cost(current_data.pos, neighbor.pos, get_node, get_floor_cost)
				local neighbor_data = get_search_node(open_set, neighbor.hash)
				local neighbor_exists
				if neighbor_data then
					g = neighbor_data.g
					neighbor_exists = true
				else
					neighbor_exists = false
				end
				if not neighbor_exists or neighbor_cost < g then
					h = get_neighbor_cost(neighbor.pos, pos2, get_node, get_floor_cost)
					g = neighbor_cost
					f = g + h
					set_search_node(open_set, neighbor.hash, {
						pos = neighbor.pos,
						parent = current_hash,
						f = f,
						g = g,
						h = h,
					})
				end
			end
		end

		if open_set_size > MAX_OPEN then
			-- Path complexity limit reached
			return nil, "path_complexity_reached"
		end
		local end_time = minetest.get_us_time()
		if (end_time - start_time)/1000000 > timeout then
			-- Aborting due to timeout
			return nil, "timeout"
		end
	end

	-- No path exists within searched area
	return nil, "no_path"
end

