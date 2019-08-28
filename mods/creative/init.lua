local S = minetest.get_translator("creative")
local F = minetest.formspec_escape

local creative_inventory = {}
creative_inventory.creative_inventory_size = 0

-- Create detached creative inventory after loading all mods
minetest.register_on_mods_loaded(function()
	local inv = minetest.create_detached_inventory("creative", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			if minetest.settings:get_bool("creative_mode") then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.settings:get_bool("creative_mode") then
				return -1
			else
				return 0
			end
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		end,
		on_put = function(inv, listname, index, stack, player)
		end,
		on_take = function(inv, listname, index, stack, player)
			if stack then
				minetest.log("action", player:get_player_name().." takes "..dump(stack:get_name()).." from creative inventory")
			end
		end,
	})
	local creative_list = {}
	for name,def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
				and def.description and def.description ~= "" then
			table.insert(creative_list, name)
		end
	end
	table.sort(creative_list)
	inv:set_size("main", #creative_list)
	for _,itemstring in ipairs(creative_list) do
		inv:add_item("main", ItemStack(itemstring))
	end
	creative_inventory.creative_inventory_size = #creative_list
end)

-- Create the trash field
local trash = minetest.create_detached_inventory("creative_trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		if minetest.settings:get_bool("creative_mode") then
			return stack:get_count()
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		inv:set_stack(listname, index, "")
	end,
})
trash:set_size("main", 1)


creative_inventory.set_creative_formspec = function(player, start_i, pagenum)
	pagenum = math.floor(pagenum)
	local pagemax = math.floor((creative_inventory.creative_inventory_size-1) / (6*4) + 1)
	player:set_inventory_formspec(
			"size[13,7.5]"..
			"list[current_player;main;5,3.5;8,1;]"..
			"list[current_player;main;5,4.75;8,3;8]"..
			"list[detached:creative;main;0.3,0.5;4,6;"..tostring(start_i).."]"..
			"label[2.0,6.55;"..F(S("@1/@2", pagenum, pagemax)).."]"..
			"button[0.3,6.5;1.6,1;creative_prev;<<]"..
			"button[2.7,6.5;1.6,1;creative_next;>>]"..
			"label[5,1.5;"..F(S("Trash:")).."]"..
			"list[detached:creative_trash;main;5,2;1,1;]"..
			"listring[current_player;main]"..
			"listring[detached:creative_trash;main]"..
			"listring[detached:creative;main]"..
			"listring[current_player;main]"
	)
end
minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	creative_inventory.set_creative_formspec(player, 0, 1)
end)
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	-- Figure out current page from formspec
	local current_page = 0
	local formspec = player:get_inventory_formspec()
	local start_i = string.match(formspec, "list%[detached:creative;main;[%d.]+,[%d.]+;[%d.]+,[%d.]+;(%d+)%]")
	start_i = tonumber(start_i) or 0

	if fields.creative_prev then
		start_i = start_i - 4*6
	end
	if fields.creative_next then
		start_i = start_i + 4*6
	end

	if start_i < 0 then
		start_i = start_i + 4*6
	end
	if start_i >= creative_inventory.creative_inventory_size then
		start_i = start_i - 4*6
	end
		
	if start_i < 0 or start_i >= creative_inventory.creative_inventory_size then
		start_i = 0
	end

	creative_inventory.set_creative_formspec(player, start_i, start_i / (6*4) + 1)
end)

