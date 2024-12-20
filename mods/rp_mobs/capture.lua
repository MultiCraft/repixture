local S = minetest.get_translator("rp_mobs")

-- Color of mob name in inventory
local MOB_NAME_COLOR_INV = "#FFFF00"

local capture_tools = {}
rp_mobs.register_capture_tool = function(toolname, def)
	capture_tools[toolname] = { uses = def.tool_uses, sound = def.sound, sound_gain = def.sound_gain, sound_max_hear_distance = def.sound_max_hear_distance }
end

rp_mobs.call_on_capture = function(self, capturer)
	if not capturer:is_player() or not rp_mobs.is_alive(self) then
		return false
	end
	if self._on_capture then
		return self._on_capture(self, capturer)
	else
		minetest.log("error", "[rp_mobs] rp_mobs.call_on_capture called for mob of type '"..self.name.."' but it has no _on_capture function!")
		return false
	end
end

rp_mobs.attempt_capture = function(self, clicker, capture_chances, force_take, replace_with)
	if clicker:is_player() and clicker:get_inventory() and not self._child and rp_mobs.is_alive(self) then
		local mobname = self.name

		-- Change what item will be added to inventory
		if replace_with then
			mobname = replace_with
		end

		-- Using a capture tool?
		local name = clicker:get_player_name()
		local tool = clicker:get_wielded_item()
		local toolname = tool:get_name()
		if not (capture_tools[toolname]) then
			 return
		end

		-- Is mob tamed?
		if self._tamed == false and force_take == false then
			minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Not tamed!")))
			return
		end

		local chance = capture_chances[toolname]
		local ctoolinfo = capture_tools[toolname]
		if not chance then
			return
		end

		local pitch = 1 + math.random(-100, 100)*0.0005
		minetest.sound_play(ctoolinfo.sound, {
			object = clicker,
			gain = ctoolinfo.sound_gain,
			max_hear_distance = ctoolinfo.sound_max_hear_distance,
			pitch = pitch}, true)

		if not minetest.is_creative_enabled(name) and ctoolinfo.uses ~= nil and ctoolinfo.uses ~= 0 then
			tool:add_wear_by_uses(ctoolinfo.uses)
		end
		clicker:set_wielded_item(tool)

		-- Fail if 0 chance
		if chance == 0 then
			minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Missed!")))
			return
		end

		-- Calculate chance ... was capture successful?
		if math.random(100) <= chance then
			-- Successful capture!
			minetest.sound_play("mobs_capture_succeed", {
				pos = clicker:get_pos(),
				gain = 0.2, max_hear_distance = 16}, true)

			-- Create item
			local mobitem = ItemStack(mobname)
			local mobitemmeta = mobitem:get_meta()

			-- Set mob name in description
			if self._name and self._name ~= "" then
				--~ Tooltip of mob in item form. @1 = mob description, @2 = mob name (label)
				mobitemmeta:set_string("description", S("@1: “@2”", mobitem:get_description(), minetest.colorize(MOB_NAME_COLOR_INV, self._name)))
			end

			-- _on_create_capture_item
			local mobitemdef = minetest.registered_items[mobname]
			if mobitemdef and mobitemdef._on_create_capture_item then
				mobitem = mobitemdef._on_create_capture_item(self, mobitem)
			end

			-- Store metadata and HP
			local mobitemmeta = mobitem:get_meta()
			if self.get_staticdata then
				-- Capturing makes mob unhorny again
				rp_mobs.make_unhorny(self)

				local staticdata = self:get_staticdata()
				mobitemmeta:set_string("staticdata", staticdata)
			end
			mobitemmeta:set_int("hp", self.object:get_hp())

			-- Add to inventory
			if clicker:get_inventory():room_for_item("main", mobitem) then
				clicker:get_inventory():add_item("main", mobitem)
			else
				-- or drop as item entity if no room
				minetest.add_item(self.object:get_pos(), mobitem)
			end

			minetest.log("action", "[rp_mobs] Mob of type '"..self.name.."' captured by " .. name .. " at "..minetest.pos_to_string(self.object:get_pos(), 1))
			self.object:remove()
			achievements.trigger_achievement(clicker, "ranger")
			return
		else
			 minetest.chat_send_player(name, minetest.colorize("#FFFF00", S("Missed!")))
		end
	end
end
