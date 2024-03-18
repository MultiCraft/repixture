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
		on_activate = function(self, staticdata)
			local pos = self.object:get_pos()
			local hp = self.object:get_hp()
			self.object:remove()
			local mobent = minetest.add_entity(pos, new_name)
			if mobent then
				-- Restore child status
				if staticdata then
					local data = minetest.deserialize(staticdata)
					if data and data.child then
						rp_mobs.turn_into_child(mobent)
					end
				end
				-- Note: We don't restore any other attributes to keep it simple.
				-- Most notably, the HP of the legacy mob apparently cannot be
				-- retrieved so the new mob will spawn with full HP.
				minetest.log("action", "[rp_mobs_legacy] Replaced legacy mob '"..old_name.."' at "..minetest.pos_to_string(pos, 1).." with '"..new_name.."'")
			else
				minetest.log("error", "[rp_mobs_legacy] Could not replaced legacy mob '"..old_name.."' at "..minetest.pos_to_string(pos, 1).." with '"..new_name.."'!")
			end
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

