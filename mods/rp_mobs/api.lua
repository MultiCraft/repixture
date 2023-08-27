-- TODO: Change to rp_mobs when ready
local S = minetest.get_translator("mobs")

rp_mobs.registered_mobs = {}

rp_mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true

	rp_mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

-- TODO
rp_mobs.register_spawn_egg = function()
end

-- TODO
rp_mobs.feed_tame = function()
end

-- TODO
rp_mobs.capture_mob = function()
end
