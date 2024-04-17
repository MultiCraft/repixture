local S = minetest.get_translator("rp_supertools")

-- The supertools support two additional node fields:
-- _on_grow(pos, node, grower): Called when a plant must grow
-- _on_degrow(pos, node, grower): Called when a plant must reverse its growth

local GROWTH_TOOL_USES = 13
local DEGROWTH_TOOL_USES = 13

local grow_tall = function(pos, y_dir, nodename)
	local newpos
	for i=1, 10 do
		newpos = vector.add(pos, vector.new(0,i*y_dir,0))
		local newnode = minetest.get_node(newpos)
		if newnode.name == "air" then
			minetest.set_node(newpos, {name=nodename})
			return true
		elseif newnode.name ~= nodename then
			return false
		end
	end
	return false
end

minetest.register_craftitem("rp_supertools:growth_tool", {
	description = S("Growth Tool"),
	_tt_help = S("Make plants and mobs grow instantly"),
	inventory_image = "rp_supertools_growth_tool.png",
	wield_image = "rp_supertools_growth_tool.png",
	groups = { supertool = 1, tool = 1 },
	stack_max = 1,
	on_secondary_use = function(itemstack, placer, pointed_thing)
		-- Handle growing child mobs into adults
		if pointed_thing.type == "object" then
			local obj = pointed_thing.ref
			local ent = obj:get_luaentity()
			if ent and ent._cmi_is_mob and ent._child then
				rp_mobs.turn_into_adult(ent)
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:add_wear_by_uses(GROWTH_TOOL_USES)
				end
				local pos = obj:get_pos()
				minetest.log("action", "[rp_supertools] " .. placer:get_player_name() .. " used growth tool on mob '"..ent.name.."' at "..minetest.pos_to_string(pos, 1))
			end
			return itemstack
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		-- Handle pointed node handlers and protection
		local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
		if handled then
			return handled_itemstack
		end
		if util.handle_node_protection(placer, pointed_thing) then
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
		if not udef and not udef._on_grow then
			return itemstack
		end

		local used = false
		-- Call _on_grow from node definition, if it exists
		if udef._on_grow then
			used = udef._on_grow(upos, unode, placer)
			if used == nil then
				used = true
			end
		end

		if used then
			minetest.sound_play({name="rp_farming_place_nonseed", gain=0.75}, {pos=pointed_thing.under}, true)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:add_wear_by_uses(GROWTH_TOOL_USES)
			end

			minetest.log("action", "[rp_supertools] " .. placer:get_player_name() .. " used growth tool on "..unode.name.." at "..minetest.pos_to_string(upos))
		end

		return itemstack
	end,
})

minetest.register_craftitem("rp_supertools:degrowth_tool", {
	description = S("Degrowth Tool"),
	_tt_help = S("Turn mobs into children"),
	inventory_image = "rp_supertools_degrowth_tool.png",
	wield_image = "rp_supertools_degrowth_tool.png",
	groups = { supertool = 1, tool = 1 },
	stack_max = 1,
	on_secondary_use = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "object" then
			return itemstack
		end
		local obj = pointed_thing.ref
		local ent = obj:get_luaentity()
		if ent and ent._cmi_is_mob and not ent._child and rp_mobs.mobdef_has_tag(ent.name, "child_exists") then
			local pos = obj:get_pos()
			rp_mobs.turn_into_child(obj)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:add_wear_by_uses(DEGROWTH_TOOL_USES)
			end
			minetest.log("action", "[rp_supertools] " .. placer:get_player_name() .. " used degrowth tool on '"..ent.name.."' at "..minetest.pos_to_string(pos, 1))
		end
		return itemstack
	end,
	on_place = function(itemstack, placer, pointed_thing)
		-- Handle pointed node handlers and protection
		local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
		if handled then
			return handled_itemstack
		end
		if util.handle_node_protection(placer, pointed_thing) then
			return itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- Handle degrowing nodes
		local apos = pointed_thing.above
		local upos = pointed_thing.under
		local unode = minetest.get_node(upos)

		local udef = minetest.registered_nodes[unode.name]
		if not udef and not udef._on_degrow then
			return itemstack
		end

		local used = false
		-- Call _on_degrow from node definition, if it exists
		if udef._on_degrow then
			udef._on_degrow(upos, unode, placer)
			used = true
			if used == nil then
				used = true
			end
		end

		if used then
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:add_wear_by_uses(DEGROWTH_TOOL_USES)
			end

			minetest.log("action", "[rp_supertools] " .. placer:get_player_name() .. " used degrowth tool on "..unode.name.." at "..minetest.pos_to_string(upos))
		end

		return itemstack
	end,

})
