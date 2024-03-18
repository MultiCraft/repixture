-- Helper functions for internal use only (not part of the official API)

rp_mobs.internal = {}

-- List of entity variables to store in staticdata
-- (so they are persisted when unloading)
local persisted_entity_vars = {}

-- Getter function for persisted_entity_vars
rp_mobs.internal.get_persisted_entity_vars = function()
	return persisted_entity_vars
end

-- Declare an entity variable name to be persisted on shutdown
rp_mobs.internal.add_persisted_entity_var = function(name)
	for i=1, #persisted_entity_vars do
		if persisted_entity_vars[i] == name then
			return
		end
	end
	table.insert(persisted_entity_vars, name)
end

-- Same as above, but for a list of variables
rp_mobs.internal.add_persisted_entity_vars = function(names)
	for n=1, #names do
		rp_mobs.internal.add_persisted_entity_var(names[n])
	end
end


