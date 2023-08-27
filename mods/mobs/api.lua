local S = minetest.get_translator("mobs")

mobs.registered_mobs = {}

mobs.register_mob = function(mobname, def)
	local mdef = table.copy(def)
	mdef.entity_definition._cmi_is_mob = true

	mobs.registered_mobs[mobname] = mdef

	minetest.register_entity(mobname, mdef.entity_definition)
end

-- TODO
mobs.register_spawn_egg = function()
end

-- TODO
mobs.feed_tame = function()
end

-- TODO
mobs.capture_mob = function()
end
