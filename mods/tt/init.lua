local S = minetest.get_translator("tt")
local COLOR_DEFAULT = "#d0ffd0"
local COLOR_DANGER = "#ffff00"
local COLOR_GOOD = "#00ff00"

tt = {}
tt.registered_snippets = {}

local function append_descs()
	for itemstring, def in pairs(minetest.registered_items) do
		if itemstring ~= "" and itemstring ~= "air" and itemstring ~= "ignore" and itemstring ~= "unknown" and def ~= nil and def.description ~= nil and def.description ~= "" and def._tt_ignore ~= true then
			local desc = def.description
			local orig_desc = desc
			-- Custom text
			if def._tt_help then
				desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, def._tt_help)
			end
			-- Tool info
			if def.tool_capabilities then
				-- Digging stats
				if def.tool_capabilities.groupcaps then
					-- TODO: Add more detail (such as digging speed)
					--local groups = {}
					--for group, caps in pairs(def.tool_capabilities.groupcaps) do
					--	table.insert(groups, group)
					--end
					--desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Digs: @1", table.concat(groups, ", ")))
				end
				-- Weapon stats
				if def.tool_capabilities.damage_groups then
					for group, damage in pairs(def.tool_capabilities.damage_groups) do
						if group == "fleshy" then
							desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Damage: @1", damage))
						else
							desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Damage (@1): @2", group, damage))
						end
					end
					local full_punch_interval = def.tool_capabilities.full_punch_interval
					if not full_punch_interval then
						full_punch_interval = 1
					end
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Full punch interval: @1s", full_punch_interval))
				end
			end
			-- Food
			if def._tt_food then
				desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Food item"))
				if def._tt_food_hp then
					local msg = S("+@1 food points", def._tt_food_hp)
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, msg)
				end
				-- NOTE: This is unused atm
				--[[if def._tt_food_satiation then
                                        if def._tt_food_satiation >= 0 then
						msg = S("+@1 satiation", def._tt_food_satiation)
					else
						msg = S("@1 satiation", def._tt_food_satiation)
					end
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, msg)
				end]]
			end
			-- Node info
			-- Damage-related
			do
				if def.damage_per_second and def.damage_per_second > 0 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DANGER, S("Contact damage: @1 per second", def.damage_per_second))
				end
				if def.drowning and def.drowning > 0 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DANGER, S("Drowning damage: @1", def.drowning))
				end
				local tmp = minetest.get_item_group(itemstring, "fall_damage_add_percent")
				if tmp > 0 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DANGER, S("Fall damage: +@1%", tmp))
				elseif tmp == -100 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_GOOD, S("No fall damage"))
				elseif tmp < 0 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Fall damage: @1%", tmp))
				end
			end
			-- Movement-related node facts
			if minetest.get_item_group(itemstring, "disable_jump") == 1 and not def.climbable then
				if def.liquidtype == "none" then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("No jumping"))
				else
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("No swimming upwards"))
				end
			end
			if def.climbable then
				if minetest.get_item_group(itemstring, "disable_jump") == 1 then
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Climbable (only downwards)"))
				else
					desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Climbable"))
				end
			end
			if minetest.get_item_group(itemstring, "slippery") >= 1 then
				desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Slippery"))
			end
			local tmp = minetest.get_item_group(itemstring, "bouncy")
			if tmp >= 1 then
				desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Bouncy (@1%)", tmp))
			end
			-- Node appearance
			tmp = def.light_source
			if tmp and tmp >= 1 then
				desc = desc .. "\n" .. minetest.colorize(COLOR_DEFAULT, S("Luminance: @1", tmp))
			end
			-- Custom functions
			for s=1, #tt.registered_snippets do
				local str, snippet_color = tt.registered_snippets[s](itemstring)
				if not snippet_color then
					snippet_color = COLOR_DEFAULT
				end
				if str then
					desc = desc .. "\n" .. minetest.colorize(snippet_color, str)
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
