local legacy_mobs = {}
local S = minetest.get_translator("rp_mobs_legacy")

-- Register alias for legacy Repixture mob from Repixture 3.12.1 or earlier
-- so it still works after a world upgrade.
-- These are mobs with the 'mobs:' prefix.
-- Also registers item alias for the mob items
local register_mob_alias = function(old_name, new_name, villager_profession)
	legacy_mobs[old_name] = new_name

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
			self.object:remove()
			local mobent = minetest.add_entity(pos, new_name)
			if mobent then
				-- Initialize custom state
				local mobluaent = mobent:get_luaentity()
				if mobluaent and not mobluaent._custom_state then
					mobluaent._custom_state = {}
				end

				-- Restore villager profession
				if villager_profession then
					if mobluaent then
						rp_mobs_mobs.set_villager_profession(mobluaent, villager_profession)
						minetest.log("action", "[rp_mobs_legacy] Restored profession of legacy villager at "..minetest.pos_to_string(pos, 1).." to: "..villager_profession)
					end
				end

				-- Restore mob status
				if staticdata then
					local data = minetest.deserialize(staticdata)
					if data then
						-- Restore child status
						if data.child then
							rp_mobs.turn_into_child(mobent)
							minetest.log("info", "[rp_mobs_legacy] Restored child status of legacy mob at "..minetest.pos_to_string(pos, 1))
						-- Restore shorn sheep status
						elseif old_name == "mobs:sheep" and data.gotten == true and mobluaent then
							mobluaent._custom_state.shorn = true
							mobent:set_properties({
								textures = {"mobs_sheep_shaved.png"},
							})
							minetest.log("info", "[rp_mobs_legacy] Restored shorn status of legacy sheep at "..minetest.pos_to_string(pos, 1))
						end
						-- Restore tamed status
						if data.tamed then
							mobluaent._tamed = true
							minetest.log("info", "[rp_mobs_legacy] Restored tamed status of legacy mob at "..minetest.pos_to_string(pos, 1))
						end
						-- Restore health
						if data.health and type(data.health) == "number" and data.health > 0 then
							mobent:set_hp(data.health)
							minetest.log("info", "[rp_mobs_legacy] Restored health of legacy villager at "..minetest.pos_to_string(pos, 1).." to: "..data.health)
						end
						-- Set villager base skin based on villager textures.
						-- This keepps the literal skin intact, but the clothes
						-- will be changed in the villager code based on the villager's profession.
						if villager_profession and data.textures and type(data.textures) == "table" then
							local base_skin = data.textures[1]
							-- Legacy texture name is expected to be "mobs_npc<number>.png"
							if base_skin and string.sub(base_skin, 1, 8) == "mobs_npc" then
								local num = string.sub(base_skin, 9, 9)
								num = tonumber(num)
								if type(num) == "number" and num >= 1 and num <= 6 then
									num = math.floor(num)
									base_skin = "mobs_villager_base_"..num..".png"
									mobluaent._custom_state.base_skin = base_skin
									rp_mobs_mobs.update_villager_textures(mobluaent)
									minetest.log("info", "[rp_mobs_legacy] Restored base skin of legacy villager at "..minetest.pos_to_string(pos, 1).." to: "..base_skin)
								end
							end
						end
					end
				end

				minetest.log("action", "[rp_mobs_legacy] Replaced legacy mob '"..old_name.."' at "..minetest.pos_to_string(pos, 1).." with '"..new_name.."'")
			else
				minetest.log("error", "[rp_mobs_legacy] Could not replace legacy mob '"..old_name.."' at "..minetest.pos_to_string(pos, 1).." with '"..new_name.."'!")
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
register_mob_alias("mobs:npc_butcher", "rp_mobs_mobs:villager", "butcher")
register_mob_alias("mobs:npc_tavernkeeper", "rp_mobs_mobs:villager", "tavernkeeper")
register_mob_alias("mobs:npc_farmer", "rp_mobs_mobs:villager", "farmer")
register_mob_alias("mobs:npc_blacksmith", "rp_mobs_mobs:villager", "blacksmith")
register_mob_alias("mobs:npc_carpenter", "rp_mobs_mobs:villager", "carpenter")

minetest.register_on_chatcommand(function(name, command, params)
	if command == "spawnentity" then
		local entityname = string.match(params, "[a-zA-Z0-9_:]+")
		if legacy_mobs[entityname] then
			minetest.chat_send_player(name, S("Entity name “@1” is outdated. Use “@2” instead.", entityname, legacy_mobs[entityname]))
			return true
		end
	end
end)
