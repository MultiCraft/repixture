-- Register alias for legacy Repixture mob from Repixture 3.12.1 or earlier
-- so it still works after a world upgrade.
-- These are mobs with the 'mobs:' prefix.
-- Also registers item alias for the mob items
local register_mob_alias = function(old_name, new_name)
	-- It's a hack! We register a dummy entity with
	-- the old prefix but we instantly replace it
	-- with the modern version.
	minetest.register_entity(":"..old_name, {
		initial_properties = {
			is_visible = false,
			pointable = false,
			physical = false,
		},
		on_activate = function(self)
			local pos = self.object:get_pos()
			self.object:remove()
			minetest.add_entity(pos, new_name)
			minetest.log("action", "[rp_mobs_legacy] Replaced legacy mob '"..old_name.."' at "..minetest.pos_to_string(pos, 1).." with '"..new_name.."'")
		end,
	})

	-- Item alias
	minetest.register_alias(old_name, new_name)
end

-- Mob aliases
register_mob_alias("mobs:boar", "rp_mobs_mobs:boar")
register_mob_alias("mobs:sheep", "rp_mobs_mobs:sheep")
register_mob_alias("mobs:skunk", "rp_mobs_mobs:skunk")
register_mob_alias("mobs:mineturtle", "rp_mobs_mobs:mineturtle")
register_mob_alias("mobs:walker", "rp_mobs_mobs:walker")
register_mob_alias("mobs:npc_butcher", "rp_mobs_mobs:villager_butcher")
register_mob_alias("mobs:npc_tavernkeeper", "rp_mobs_mobs:villager_tavernkeeper")
register_mob_alias("mobs:npc_farmer", "rp_mobs_mobs:villager_farmer")
register_mob_alias("mobs:npc_blacksmith", "rp_mobs_mobs:villager_blacksmith")
register_mob_alias("mobs:npc_carpenter", "rp_mobs_mobs:villager_carpenter")

