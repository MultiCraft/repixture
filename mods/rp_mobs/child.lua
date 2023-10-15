-- Child system.
-- This file adds functionality for child mobs as well as breeding.

-- Hardcoded values:
-- How long a mob remains horny (seconds)
local HORNY_TIME = 40

-- How long a mob needs to wait before being able to become horny again (seconds)
local HORNY_AGAIN_TIME = 240	

-- How long it takes by default for a child mob to grow into an adult (seconds)
local CHILD_GROW_TIME = 240

-- How long it take for a child to spawn once two mobs have mated
local CHILD_BIRTH_TIME = 7

-- The size of child mobs is divided by this number
local CHILD_SIZE_DIVISOR = 2

-- Range in within mobs can breed
local DEFAULT_BREED_RANGE = 4

-- Make mob horny, if possible
rp_mobs.make_horny = function(mob, force)
	if mob._child then
		return
	end
	if (not mob._horny) and (force or (mob._hornytimer < HORNY_AGAIN_TIME)) then
		mob._horny = true
		mob._hornytimer = 0
	end
end

-- Disable mob being horny again
rp_mobs.make_unhorny = function(mob)
	mob._horny = false
	mob._hornytimer = 0
end

-- Turn the mob into an adult
rp_mobs.turn_into_adult = function(mob)
	if not mob._child then
		-- No-op if already an adult
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
	})
end


-- Turn the mob into a child
rp_mobs.turn_into_child = function(mob)
	mob = mob:get_luaentity()
	if mob._child then
		-- No-op if already a child
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
	})
	mob._child = true
	mob._child_grow_timer = 0
end

-- Advance the child growth timer of the given mob by dtime (in seconds)
-- and turn it into an adult once the time has passed.
-- Recommended to be added into the on_step function of the mob
-- if the mob supports a child version of it.
rp_mobs.advance_child_growth = function(mob, dtime)
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
rp_mobs.pregnancy = function(mob, dtime)
	if mob._pregnant then
		mob._pregnant_timer = mob._pregnant_timer + dtime
		if mob._pregnant_timer >= CHILD_BIRTH_TIME then
			-- Spawn child
			local pos = mob.object:get_pos()
			local child = minetest.add_entity(pos, mob.name)
			if child then
				rp_mobs.turn_into_child(child)

				-- Award achievement to player who has breeded the mobs
				if mob._breeder_name then
					local pfeeder = minetest.get_player_by_name(mob._breeder_name)
					if pfeeder:is_player() then
						achievements.trigger_achievement(pfeeder, "wonder_of_life")
					end
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

rp_mobs.horny_and_breed = function(mob, dtime)
	if not mob._hornytimer then
		mob._hornytimer = 0
	end

	-- Horny mob can mate for HORNY_TIME seconds, afterwards the mob cannot mate again for HORNY_AGAIN_TIME seconds
	if mob._horny and mob._hornytimer < HORNY_AGAIN_TIME and not mob._child then
		mob._hornytimer = mob._hornytimer + dtime
		if mob._hornytimer >= HORNY_AGAIN_TIME then
			rp_mobs.make_unhorny(mob)
		end
	end

	-- If mob is horny, find another same mob who is horny, and mate
	if (not mob._pregnant) and mob._horny and mob._hornytimer <= HORNY_TIME then
		local pos = mob.object:get_pos()

		-- Heart particles show the mob is horny
		local effect_pos = {x = pos.x, y = pos.y+0.5, z = pos.z}
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
			-- TODO: Add custom particle texthre
			texture = "heart.png",
		})

		-- Pick a partner to mate with
		local nearby_objects = minetest.get_objects_inside_radius(pos, mob._breed_range or DEFAULT_BREED_RANGE)
		local potential_partners = {}
		-- FIXME: Mobs can mate through solid nodes
		local num = 0
		local partner = nil
		for _, obj in ipairs(nearby_objects) do
			local ent = obj:get_luaentity()
			if mob ~= ent and ent and ent.name == mob.name and ent._horny and ent._hornytimer <= HORNY_TIME and (not ent._pregnant) then
				table.insert(potential_partners, ent)
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
		child_bearer._hornytimer = HORNY_TIME + 1
		child_giver._hornytimer = HORNY_TIME + 1
		local feeder_name
		-- Record feeder name if player has fed both parents
		if child_bearer._last_feeder and child_bearer._last_feeder ~= "" and child_bearer._last_feeder == child_giver._last_feeder then
			feeder_name = child_bearer._last_feeder
		end
		-- Induce pregnancy; the actual child will happen in rp_mobs.pregnancy
		child_bearer._pregnant = true
		child_bearer._pregnant_timer = 0
	end
end
