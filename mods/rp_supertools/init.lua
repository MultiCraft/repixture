local S = minetest.get_translator("rp_supertools")

-- The supertools support two additional node fields:
-- _on_grow(pos, node, grower): Called when a plant must grow
-- _on_degrow(pos, node, grower): Called when a plant must reverse its growth

local GROWTH_TOOL_USES = 13
local DEGROWTH_TOOL_USES = 13

local get_use_growth_or_degrowth_tool_function = function(growth, place)
	local uses, tool_name_debug
	if growth then
		uses = GROWTH_TOOL_USES
		tool_name_debug = "growth tool"
	else
		uses = DEGROWTH_TOOL_USES
		tool_name_debug = "degrowth tool"
	end
	return function(itemstack, user, pointed_thing)
		-- Handle growing child mobs into adults
		if pointed_thing.type == "object" then
			local obj = pointed_thing.ref
			if obj then
				local ent = obj:get_luaentity()
				if ent and ent._cmi_is_mob then
					local changed = false
					if growth and ent._child then
						rp_mobs.turn_into_adult(ent)
						changed = true
					elseif not growth and not ent._child then
						rp_mobs.turn_into_child(obj)
						changed = true
					end
					if changed then
						if not minetest.is_creative_enabled(user:get_player_name()) then
							itemstack:add_wear_by_uses(uses)
						end
						local pos = obj:get_pos()
						minetest.log("action", "[rp_supertools] " .. user:get_player_name() .. " used "..tool_name_debug.."on mob '"..ent.name.."' at "..minetest.pos_to_string(pos, 1))
					end
				end
			end
			return itemstack
		elseif pointed_thing.type == "node" then
			local handled, handled_itemstack
			if place then
				-- For placement, handle pointed node handlers and protection
				handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, user, pointed_thing)
			else
				handled, handled_itemstack = false, itemstack
			end
			if handled then
				return handled_itemstack
			end
			if util.handle_node_protection(user, pointed_thing) then
				return itemstack
			end

			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- Handle growing nodes
			local apos = pointed_thing.above
			local upos = pointed_thing.under
			local unode = minetest.get_node(upos)

			local udef = minetest.registered_nodes[unode.name]
			local callback
			if growth then
				callback = "_on_grow"
			else
				callback = "_on_degrow"
			end
			if not udef or not udef[callback] then
				return itemstack
			end

			local used = false
			-- Call _on_grow/_on_degrow from node definition, if it exists
			if udef[callback] then
				used = udef[callback](upos, unode, user)
				if used == nil then
					used = true
				end
			end

			if used then
				local pitch
				if not growth then
					pitch = 0.7
				end
				minetest.sound_play({name="rp_farming_place_nonseed", gain=0.75, pitch=pitch}, {pos=upos}, true)
				if not minetest.is_creative_enabled(user:get_player_name()) then
					itemstack:add_wear_by_uses(uses)
				end

				minetest.log("action", "[rp_supertools] " .. user:get_player_name() .. " used "..tool_name_debug.." on "..unode.name.." at "..minetest.pos_to_string(upos))
			end

			return itemstack
		else
			return itemstack
		end
	end
end

minetest.register_craftitem("rp_supertools:growth_tool", {
	description = S("Growth Tool"),
	_tt_help = S("Make plants and creatures grow instantly"),
	inventory_image = "rp_supertools_growth_tool.png",
	wield_image = "rp_supertools_growth_tool.png",
	groups = { supertool = 1, tool = 1 },
	stack_max = 1,

	-- Primary use by [Punch] key per Repixture convention
	on_use = get_use_growth_or_degrowth_tool_function(true, false),
	-- Still allow use by [Place] key for convenience
	on_secondary_use = get_use_growth_or_degrowth_tool_function(true, true),
	on_place = get_use_growth_or_degrowth_tool_function(true, true),
})

minetest.register_craftitem("rp_supertools:degrowth_tool", {
	description = S("Degrowth Tool"),
	_tt_help = S("Make plants and creatures reverse their growth"),
	inventory_image = "rp_supertools_degrowth_tool.png",
	wield_image = "rp_supertools_degrowth_tool.png",
	groups = { supertool = 1, tool = 1 },
	stack_max = 1,

	-- Primary use by [Punch] key per Repixture convention
	on_use = get_use_growth_or_degrowth_tool_function(false, false),
	-- Still allow use by [Place] key for convenience
	on_secondary_use = get_use_growth_or_degrowth_tool_function(false, true),
	on_place = get_use_growth_or_degrowth_tool_function(false, true),
})
