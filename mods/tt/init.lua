local S = minetest.get_translator("tt")
local color = "#d0ffd0"

tt = {}
tt.registered_snippets = {}

local function append_descs()
	for itemstring, def in pairs(minetest.registered_items) do
		if itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and def ~= nil and def.description ~= nil and def._tt_ignore ~= true then
			local desc = def.description
			local orig_desc = desc
			-- Custom text
			if def._tt_help then
				desc = desc .. "\n" .. minetest.colorize(color, def._tt_help)
			end
			if def.tool_capabilities then
				-- Digging stats
				if def.tool_capabilities.groupcaps then
					-- TODO: Add more detail (such as digging speed)
					--local groups = {}
					--for group, caps in pairs(def.tool_capabilities.groupcaps) do
					--	table.insert(groups, group)
					--end
					--desc = desc .. "\n" .. minetest.colorize(color, S("Digs: @1", table.concat(groups, ", ")))
				end
				-- Weapon stats
				if def.tool_capabilities.damage_groups then
					for group, damage in pairs(def.tool_capabilities.damage_groups) do
						if group == "fleshy" then
							desc = desc .. "\n" .. minetest.colorize(color, S("Damage: @1", damage))
						else
							desc = desc .. "\n" .. minetest.colorize(color, S("Damage (@1): @2", group, damage))
						end
					end
					local full_punch_interval = def.tool_capabilities.full_punch_interval
					if not full_punch_interval then
						full_punch_interval = 1
					end
					desc = desc .. "\n" .. minetest.colorize(color, S("Full punch interval: @1s", full_punch_interval))
				end
			end
			-- Food
			if def._tt_food then
				desc = desc .. "\n" .. minetest.colorize(color, S("Food item"))
				if def._tt_food_hp then
					msg = S("+@1 food points", def._tt_food_hp)
					desc = desc .. "\n" .. minetest.colorize(color, msg)
				end
				-- NOTE: This is unused atm
				--[[if def._tt_food_satiation then
                                        if def._tt_food_satiation >= 0 then
						msg = S("+@1 satiation", def._tt_food_satiation)
					else
						msg = S("@1 satiation", def._tt_food_satiation)
					end
					desc = desc .. "\n" .. minetest.colorize(color, msg)
				end]]
			end
			-- Custom functions
			for s=1, #tt.registered_snippets do
				local str = tt.registered_snippets[s](itemstring)
				if str then
					desc = desc .. "\n" .. minetest.colorize(color, str)
				end
			end

			minetest.override_item(itemstring, { description = desc, _tt_original_description = orig_desc })
		end
	end
end

tt.register_snippet = function(func)
	table.insert(tt.registered_snippets, func)
end

minetest.register_on_mods_loaded(append_descs)
