-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

local GRAVITY = tonumber(minetest.settings:get("movement_gravity")) or 9.81

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true

	rp_mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

rp_mobs.drop_death_items = function(self, pos)
	if not pos then
		pos = self.object:get_pos()
	end
	local mobdef = rp_mobs.registered_mobs[self.name]
	if not mobdef then
		error("[rp_mobs] rp_mobs.drop_death_items was called on something that is not a registered mob! name="..tostring(self.name))
	end
	if mobdef.drops then
		for d=1, #mobdef.drops do
			minetest.add_item(pos, mobdef.drops[d])
		end
	end
end

rp_mobs.on_death_default = function(self, killer)
	rp_mobs.drop_death_items(self)
end

rp_mobs.activate_gravity = function(self)
	local acc = self.object:get_acceleration()
	acc.y = -GRAVITY
	self.object:set_acceleration(acc)
end
rp_mobs.deactivate_gravity = function(self)
	local acc = self.object:get_acceleration()
	acc.y = 0
	self.object:set_acceleration(acc)
end

rp_mobs.register_mob_item = function(mobname, invimg, desc)
	local place
	if not desc then
		desc = rp_mobs.registered_mobs[mobname].description
	end
	minetest.register_craftitem(mobname, {
		description = desc,
		inventory_image = invimg,
		groups = { spawn_egg = 1 },
		on_place = function(itemstack, placer, pointed_thing)
			local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
			if handled then
				return handled_itemstack
			end
			if pointed_thing.type == "node" then
				local pos = pointed_thing.above
				local pname = placer:get_player_name()
				if minetest.is_protected(pos, pname) and
						not minetest.check_player_privs(placer, "protection_bypass") then
					 minetest.record_protection_violation(pos, pname)
					 return itemstack
				end

				pos.y = pos.y + 0.5
				local mob = minetest.add_entity(pos, mobname)
				local ent = mob:get_luaentity()
				if ent.type ~= "monster" then
					-- set owner
					ent.owner = pname
					ent.tamed = true
				end
				 minetest.log("action", "[rp_mobs] "..pname.." spawns "..mobname.." at "..minetest.pos_to_string(pos, 1))
				if not minetest.is_creative_enabled(pname) then
					 itemstack:take_item()
				end
			end
			return itemstack
		end,
	})
end


-- TODO
rp_mobs.feed_tame = function()
end

-- TODO
rp_mobs.capture_mob = function()
end
