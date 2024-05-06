rp_mobs_spawn = {}

-- SETTINGS

-- If true, mobs may spawn naturally
local setting_spawn_mobs = minetest.settings:get_bool("mobs_spawn", true)

-- Whether to allow *natural* spawning mobs in protected areas.
-- * number 1 or non-false value = disallow spawning in protected areas
-- (the numeric value is used for backwards-compability)
local setting_spawn_protected = minetest.settings:get("mobs_spawn_protected")
if tonumber(setting_spawn_protected) == 1 or setting_spawn_protected == "false" then
 	-- mobs can't spawn naturally in protected areas
	setting_spawn_protected = false
else
 	-- mobs can spawn naturally in protected areas
	setting_spawn_protected = true
end

-- If true, then only peaceful mobs may spawn
local setting_peaceful_only = minetest.settings:get_bool("only_peaceful_mobs", false)

-- END OF SETTINGS

local mg_corner_1, mg_corner_2 = minetest.get_mapgen_edges()
local MIN_Y, MAX_Y = mg_corner_1.y, mg_corner_2.y

function rp_mobs_spawn.register_spawn(name, params)
	local p_nodes = params.nodes
	local p_neighbors = params.neighbors
	local p_interval = params.interval
	local p_chance = params.chance

	local active_object_limit = params.active_object_limit
	local active_object_limit_wider = params.active_object_limit_wider

	local min_light = params.min_light or 0
	local max_light = params.max_light or minetest.LIGHT_MAX
	local min_height = params.min_height or MIN_Y
	local max_height = params.max_height or MAX_Y

	if not minetest.registered_entities[name] then
		minetest.log("error", "[rp_mobs_spawn] rp_mobs_spawn.register_spawn: Mob '"..tostring(name).."' is undefined")
		return
	end

	minetest.register_abm({
		label = "Mob spawn: " .. name,
		nodenames = p_nodes,
		neighbors = p_neighbors,
		interval = p_interval,
		chance = p_chance,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Do not spawn if mob spawning is disabled
			if not setting_spawn_mobs then
				return
			end

			-- Do not spawn if too many active objects in area
			if active_object_count > active_object_limit then
				return
			end
			if active_object_count_wider > active_object_limit_wider then
				return
			end

			-- Non-peaceful mobs cannot spawn if setting restricts it
			if setting_peaceful_only and rp_mobs.mobdef_has_tag(name, "peaceful") then
				return
			end

			local spawn_pos = table.copy(pos)
			-- Spawn above node
			spawn_pos.y = spawn_pos.y + 1

			-- Mobs cannot spawn inside protected areas if setting restricts it
			if setting_spawn_protected == false and minetest.is_protected(spawn_pos, "") then
				return
			end

			-- Check if light and height levels are ok to spawn
			local light = minetest.get_node_light(spawn_pos)
			if not light or light > max_light or light < min_light or spawn_pos.y > max_height or spawn_pos.y < min_height then
				return
			end

			-- Are we spawning inside air?
			-- NOTE: Support for spawning inside other nodes (like water)
			-- might be desirable as well (ideally via a function argument).
			local spawn_in = minetest.get_node(spawn_pos)
			if spawn_in.name ~= "air" then
				return
			end

			-- Spawn mob half block higher
			spawn_pos.y = spawn_pos.y + 0.5

			-- Spawn
			minetest.add_entity(spawn_pos, name)
			minetest.log("action", "[rp_mobs_spawn] Spawned "..name.." at "..minetest.pos_to_string(spawn_pos, 1).." on "..node.name)
		end
	})
end
