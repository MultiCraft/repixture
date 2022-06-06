local SPAWNRADIUS = 21
local MAX_SPAWN_HEIGHT = 2

-- Cache spawnable blocks
local spawnable_blocks = {}

-- Returns true if the node with the given nodename can be spawned on
local can_spawn_on = function(nodename)
	if nodename == "ignore" then
		return false
	end
	-- Check cache
	if spawnable_blocks[nodename] ~= nil then
		return spawnable_blocks[nodename]
	end
	spawnable_blocks[nodename] = false
	local def = minetest.registered_nodes[nodename]
	if not def then
		return false
	end
	if def.walkable then
		local no_spawn = minetest.get_item_group(nodename, "no_spawn_allowed_on") == 1
		if no_spawn then
			return false
		end
		if def.damage_per_second > 0 then
			return false
		end
		local slab = minetest.get_item_group(nodename, "slab") > 0
		local stair = minetest.get_item_group(nodename, "stair") > 0
		if slab or stair then
			spawnable_blocks[nodename] = true
			return true
		end
		if def.collision_box then
			if def.collision_box.type == "regular" then
				spawnable_blocks[nodename] = true
				return true
			else
				return false
			end
		end
		spawnable_blocks[nodename] = true
		return true
	end
	return false
end

-- Returns true if player can spawn at pos1.
-- Checks if pos1 and the pos above pos1 are air,
-- and if the pos below pos1 can be stood on.
local is_valid_spawn_pos = function(pos1)
	local pos2 = vector.add(pos1, vector.new(0,1,0)) -- above
	local pos0 = vector.add(pos1, vector.new(0,-1,0)) -- floor

	local node1 = minetest.get_node(pos1)
	local node2 = minetest.get_node(pos2)
	local node0 = minetest.get_node(pos0)
	if node0.name == "ignore" then
		return false
	end
	if node1.name == "air" and node2.name == "air" and can_spawn_on(node0.name) then
		return true
	end
	return false
end

-- Checks pos as well as a number of positions above pos whether they are spawnable
local check_spawn_at_and_above_pos = function(pos)
	for h = 0, MAX_SPAWN_HEIGHT do
		local spawn = vector.new(pos.x, pos.y+h, pos.z)
		local valid = is_valid_spawn_pos(spawn)
		if valid then
			return spawn
		end
	end
	return nil
end

local neighbors = {
	vector.new(-1,0,-1),
	vector.new(0,0,-1),
	vector.new(1,0,1),
	vector.new(-1,0,0),
	vector.new(1,0,0),
	vector.new(-1,0,1),
	vector.new(0,0,1),
	vector.new(1,0,1),
}

-- Given a position pos, searches around pos to find
-- a safe position to spawn in. Might not succeeed in
-- very difficult terrain. Returns spawn position on success
-- and nil on failure
local find_spawn_nearby = function(pos)
	local npos = check_spawn_at_and_above_pos(pos)
	if npos then
		return npos
	end
	local nneighbors = table.copy(neighbors)
	while #nneighbors > 0 do
		local n = math.random(1, #nneighbors)
		local neighbor = nneighbors[n]
		npos = vector.add(pos, neighbor)
		local y = minetest.get_spawn_level(npos.x,npos.z)
		if y then
			y = y - 1
			npos.y = y
			npos = check_spawn_at_and_above_pos(npos)
			if npos then
				return npos
			end
		end
		table.remove(nneighbors, n)
	end
	for r=2, SPAWNRADIUS do
		for j=1, 20 do
			local x = pos.x + math.random(-r, r)
			local z = pos.z + math.random(-r, r)
			local y = minetest.get_spawn_level(x,z)
			if y then
				y = y - 1
				local spawn = vector.new(x, y, z)
				spawn = check_spawn_at_and_above_pos(spawn)
				if spawn then
					return spawn
				end
			end
		end
	end
end

-- Check for alternative spawn position if the map emerge was successful
local function emerge_callback(blockpos, action, calls_remaining, param)
	if calls_remaining == 0 and (action == minetest.EMERGE_FROM_MEMORY or action == minetest.EMERGE_FROM_DISK or action == minetest.EMERGE_GENERATED) then
		if not param.player or not param.player:is_player() then
			return
		end
		local emerge_timer2 = minetest.get_us_time()
		local time = emerge_timer2 - param.timer
		minetest.log("info", "[rp_safespawn] Time needed to emerge map for spawning: "..time.." µs")

		local ppos_cb = param.ppos
		if not is_valid_spawn_pos(ppos_cb) then
			minetest.log("action", "[rp_safespawn] Player spawn for "..param.player:get_player_name().." was indeed bad. Searching for new spawn ...")
			local newspawn = find_spawn_nearby(ppos_cb)
			if newspawn then
				minetest.log("action", "[rp_safespawn] Spawning "..param.player:get_player_name().." at new position: "..minetest.pos_to_string(newspawn, 0))
				param.player:set_pos(newspawn)
			else
				minetest.log("action", "[rp_safespawn] Failed to find new spawn position for "..param.player:get_player_name()..". Not moving player.")
			end
		else
			minetest.log("info", "[rp_safespawn] Player spawn for "..param.player:get_player_name().." was OK. Not moving player.")
		end
	end
end

-- Check if the player is at a valid position. If not, emerged the map around player
-- and checks again.
local function spawngen(player)
	local ppos = player:get_pos()
	local node = minetest.get_node(ppos)
		local timer = minetest.get_us_time()
	if not is_valid_spawn_pos(ppos) then
		minetest.log("action", "[rp_safespawn] Player "..player:get_player_name().." spawns at bad or unloaded position "..minetest.pos_to_string(ppos)..". Emerging map to check spawn ...")
		local min = vector.add(ppos, vector.new(-5,-5,-5))
		local max = vector.add(ppos, vector.new(5,5,5))
		minetest.emerge_area(min, max, emerge_callback, {ppos=ppos,timer=timer,player=player})
	end
end

minetest.register_on_newplayer(spawngen)
