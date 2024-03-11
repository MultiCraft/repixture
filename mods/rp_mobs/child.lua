-- Child system.
-- This file adds functionality for child mobs as well as breeding.

-- Hardcoded values:
-- How long a mob remains horny (seconds)
local HORNY_TIME = 40

-- How long a mob needs to wait before being able to become horny again (seconds)
local HORNY_AGAIN_TIME = 240

-- How long it takes by default for a child mob to grow into an adult (seconds)
local CHILD_GROW_TIME = 240

-- How long it take for a child to spawn once a mob turned pregnant
local CHILD_BIRTH_TIME = 7

-- The size of child mobs is divided by this number
local CHILD_SIZE_DIVISOR = 2

-- Range in within mobs can breed
local DEFAULT_BREED_RANGE = 4

-- Interval in which the mob checks for partners to breed with (seconds)
local BREED_CHECK_INTERVAL = 1

-- Entity variables to persist:
rp_mobs.add_persisted_entity_vars({
	"_child", -- true if this is a child mob
	"_child_grow_timer", -- counts the time the mob has been a child (seconds)
	"_horny", -- true if mob is horny and ready to mate
	"_horny_timer", -- time the mob has been horny, or, if _horny_recover is true, time mob has been recovering from a previous horny phase
	"_horny_recover", -- true if mob is currently recovering from a previous horny phase
	"_breed_check_timer", -- timer for the breed check; if it reaches BREED_CHECK_INTERVAL, mob will attempt to mate, then the timer resets (in seconds)
	"_pregnant", -- true if mob is 'pregnant' and about to spawn a child
	"_pregnant_timer" -- timer the mob has been pregnant (seconds)
})
--[[ NOT persisted variables:
	_last_breeder: Name of the player who last breeded the mob, used for achievement
]]

-- Make mob horny, if possible
rp_mobs.make_horny = function(mob, force)
	if mob._child or mob._horny_recover or mob._pregnant or not rp_mobs.is_alive(mob) then
		return
	end
	if (not mob._horny) and (force or (mob._horny_timer < HORNY_AGAIN_TIME)) then
		rp_mobs.default_mob_sound(mob, "horny")
		mob._horny = true
		mob._horny_recover = false
		mob._horny_timer = 0
		-- Start spawning breed particles in next step
		mob._breed_check_timer = BREED_CHECK_INTERVAL
	end
end

-- Disable mob being horny again
rp_mobs.make_unhorny = function(mob)
	if mob._horny then
		mob._horny_recover = true
	end
	mob._horny = false
	mob._horny_timer = 0
end

-- Turn the mob into an adult
rp_mobs.turn_into_adult = function(mob)
	if not mob._child or not rp_mobs.is_alive(mob) then
		-- No-op if already an adult or dying
		return
	end
	mob._child = false
	mob._child_grow_timer = nil
	local cpos = mob.object:get_pos()
	cpos.y = cpos.y + ((mob._base_colbox[5] - mob._base_colbox[2]) / CHILD_SIZE_DIVISOR)
	mob.object:set_pos(cpos)
	mob.object:set_properties({
		visual_size = mob._base_size,
		collisionbox = mob._base_colbox,
		selectionbox = mob._base_selbox,
		textures = mob._textures_adult,
	})
end

-- Change the mob's properties to child properties without
-- setting the _child or _child_grow_timer variables.
-- Meant for internal rp_mobs use only!
rp_mobs.set_mob_child_properties = function(mob)
	if not rp_mobs.is_alive(mob) then
		return
	end
	mob.object:set_properties({
		visual_size = {
			x = mob._base_size.x / CHILD_SIZE_DIVISOR,
			y = mob._base_size.y / CHILD_SIZE_DIVISOR,
			z = mob._base_size.z / CHILD_SIZE_DIVISOR,
		},
		collisionbox = {
			mob._base_colbox[1] / CHILD_SIZE_DIVISOR,
			mob._base_colbox[2] / CHILD_SIZE_DIVISOR,
			mob._base_colbox[3] / CHILD_SIZE_DIVISOR,
			mob._base_colbox[4] / CHILD_SIZE_DIVISOR,
			mob._base_colbox[5] / CHILD_SIZE_DIVISOR,
			mob._base_colbox[6] / CHILD_SIZE_DIVISOR,
		},
		selectionbox = {
			mob._base_selbox[1] / CHILD_SIZE_DIVISOR,
			mob._base_selbox[2] / CHILD_SIZE_DIVISOR,
			mob._base_selbox[3] / CHILD_SIZE_DIVISOR,
			mob._base_selbox[4] / CHILD_SIZE_DIVISOR,
			mob._base_selbox[5] / CHILD_SIZE_DIVISOR,
			mob._base_selbox[6] / CHILD_SIZE_DIVISOR,
			rotate = mob._base_selbox.rotate,
		},
		textures = mob._textures_child,
	})
end

-- Turn the mob into a child, if not already.
rp_mobs.turn_into_child = function(mob)
	if not rp_mobs.is_alive(mob) then
		return
	end
	local mobl = mob:get_luaentity()
	if mobl._child then
		-- No-op if already a child
		return
	end
	rp_mobs.set_mob_child_properties(mobl)
	mobl._child = true
	mobl._child_grow_timer = 0
end

-- Advance the child growth timer of the given mob by dtime (in seconds)
-- and turn it into an adult once the time has passed.
-- Recommended to be added into the on_step function of the mob
-- if the mob supports a child version of it.
rp_mobs.advance_child_growth = function(mob, dtime)
	if not rp_mobs.is_alive(mob) then
		return
	end
	-- If mob is child, take CHILD_GROW_TIME seconds before growing into adult
	if mob._child == true then
		mob._child_grow_timer = (mob._child_grow_timer or 0) + dtime
		if mob._child_grow_timer > CHILD_GROW_TIME then
			rp_mobs.turn_into_adult(mob)
		end
	end
end

-- Pregnancy check that needs to be called every step for mobs
-- that can be bred.
local pregnancy = function(mob, dtime)
	if not rp_mobs.is_alive(mob) then
		return
	end
	if mob._pregnant then
		mob._pregnant_timer = mob._pregnant_timer + dtime
		if mob._pregnant_timer >= CHILD_BIRTH_TIME then
			-- Spawn child
			local pos = mob.object:get_pos()
			local child = minetest.add_entity(pos, mob.name)
			if child then
				rp_mobs.default_mob_sound(mob, "give_birth")
				rp_mobs.turn_into_child(child)

				-- Award achievement to player who has breeded the mobs
				if mob._last_breeder then
					local breeder = minetest.get_player_by_name(mob._last_breeder)
					if breeder:is_player() then
						achievements.trigger_achievement(breeder, "wonder_of_life")
					end
					mob._last_breeder = nil
				end
				mob._pregnant = false
				mob._pregnant_timer = nil
				minetest.log("action", "[rp_mobs] Child mob of type '"..mob.name.."' was born at "..minetest.pos_to_string(pos, 1))
			else
				minetest.log("error", "[rp_mobs] Child mob of type '"..mob.name.."' could not be born at "..minetest.pos_to_string(pos, 1))
			end
		end
	end
end

rp_mobs.handle_breeding = function(mob, dtime)
	if mob._dying then
		return
	end
	if not mob._horny_timer then
		mob._horny_timer = 0
	end
	if not mob._breed_check_timer then
		mob._breed_check_timer = 0
	end

	-- Horny mob can mate for HORNY_TIME seconds, afterwards the mob cannot mate again for HORNY_AGAIN_TIME seconds
	if mob._horny then
		mob._horny_timer = mob._horny_timer + dtime
		if mob._horny_timer >= HORNY_TIME then
			rp_mobs.make_unhorny(mob)
		end
	-- Also, the horny recover time does not start while the mob is still pregnant
	elseif mob._horny_recover and not mob._pregnant then
		mob._horny_timer = mob._horny_timer + dtime
		if mob._horny_timer >= HORNY_AGAIN_TIME then
			mob._horny_recover = false
			mob._horny_timer = 0
		end
	end

	-- Update pregnancy status, if pregnant
	pregnancy(mob, dtime)

	-- If mob is horny, find another same mob who is horny, and mate
	if (not mob._pregnant) and mob._horny and mob._horny_timer <= HORNY_TIME then
		local pos = mob.object:get_pos()

		mob._breed_check_timer = mob._breed_check_timer + dtime
		if mob._breed_check_timer < BREED_CHECK_INTERVAL then
			return
		end
		mob._breed_check_timer = 0

		-- Particles show that the mob is horny
		local effect_pos = {x = pos.x, y = pos.y, z = pos.z}
		local props = mob.object:get_properties()
		effect_pos.y = effect_pos.y + props.collisionbox[5]
		minetest.add_particlespawner(
		{
			amount = 4,
			time = 0.25,
			minpos = effect_pos,
			maxpos = effect_pos,
			minvel = {x = -0, y = 2, z = -0},
			maxvel = {x = 2,  y = 6,  z = 2},
			minacc = {x = -4, y = -16, z = -4},
			maxacc = {x = 4, y = -4, z = 4},
			minexptime = 0.1,
			maxexptime = 1,
			minsize = 1,
			maxsize = 2,
			texture = {
				name = "mobs_breed.png",
				alpha_tween = { 1, 0, start = 0.75 },
			},
		})

		-- Pick a partner to mate with
		local nearby_objects = minetest.get_objects_inside_radius(pos, mob._breed_range or DEFAULT_BREED_RANGE)
		local potential_partners = {}
		local num = 0
		local partner = nil
		for _, obj in ipairs(nearby_objects) do
			local ent = obj:get_luaentity()
			-- Partner must be a horny non-pregnant mob
			if ent and mob ~= ent and ent.name == mob.name and ent._horny and ent._horny_timer <= HORNY_TIME and (not ent._pregnant) then
				-- There must be no solid node between the two partners
				local ray = minetest.raycast(obj:get_pos(), mob.object:get_pos(), false, false)
				local collision = false
				for pointed_thing in ray do
					if pointed_thing.type == "node" then
						local node = minetest.get_node(pointed_thing.under)
						local ndef = minetest.registered_nodes[node.name]
						-- Walkable nodes and unknown nodes count as "solid" nodes
						if (not ndef) or (ndef and ndef.walkable) then
							collision = true
							break
						end
					end
				end
				if not collision then
					table.insert(potential_partners, ent)
				end
			end
		end
		-- No partners found, abort
		if #potential_partners == 0 then
			return
		end

		-- Of all eligible partners, pick a random one
		local r = math.random(1, #potential_partners)
		local partner = potential_partners[r]
		
		-- Of the two parents, a random mob will become pregnant and bear the child
		local child_bearer, child_giver
		r = math.random(1, 2)
		if r == 1 then
			child_bearer = mob
			child_giver = partner
		else
			child_bearer = partner
			child_giver = mob
		end
		rp_mobs.make_unhorny(child_bearer)
		rp_mobs.make_unhorny(child_giver)
		-- Record breeder name if player has fed both parents (for achievement)
		if child_bearer._last_feeder and child_bearer._last_feeder ~= "" and child_bearer._last_feeder == child_giver._last_feeder then
			child_bearer._last_breeder = child_bearer._last_feeder
		end
		-- Induce pregnancy; the actual child will happen in rp_mobs.pregnancy
		child_bearer._pregnant = true
		child_bearer._pregnant_timer = 0

		local ppos = child_bearer.object:get_pos()
		local effect2_pos = {x = ppos.x, y = ppos.y, z = ppos.z}
		props = child_bearer.object:get_properties()
		effect2_pos.y = effect2_pos.y + props.collisionbox[5]
		minetest.add_particlespawner({
			amount = 1,
			time = 0.01,
			minpos = effect2_pos,
			maxpos = effect2_pos,
			minvel = {x = 0, y = 2, z = -0},
			maxvel = {x = 0,  y = 2,  z = 0},
			minexptime = 2,
			maxexptime = 2,
			minsize = 4,
			maxsize = 4,
			drag = { x=2, y=2, z=2 },
			texture = {
				name = "mobs_pregnant.png",
				alpha_tween = { 1, 0, start = 0.75 },
			},
		})
		minetest.log("action", "[rp_mobs] Mob of type '"..child_bearer.name.."' became pregnant at "..minetest.pos_to_string(child_bearer.object:get_pos(), 1))
	end
end


