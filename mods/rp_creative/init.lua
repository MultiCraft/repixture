local S = minetest.get_translator("rp_creative")
local F = minetest.formspec_escape

creative = {}

creative.creative_inventories = {}
creative.creative_sizes = {}

local playerdata = {}

local form = default.ui.get_page("rp_default:2part")

form = form .. "list[current_player;main;0.25,4.75;8,4;]"
form = form .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form = form .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

default.ui.register_page("rp_creative:creative", form)

creative.slots_num = 7*4

-- Create detached creative inventory for player
local function create_creative_inventory(player)
	local player_name = player:get_player_name()
	local inv = minetest.create_detached_inventory("creative_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local name = player:get_player_name()
			if minetest.settings:get_bool("creative_mode") and to_list ~= "main" then
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
	}, player_name)
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
	creative.creative_inventories[player_name] = inv
	creative.creative_sizes[player_name] = inv:get_size("main")
	return inv
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative!trash", {
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

creative.get_creative_formspec = function(player, start_i, pagenum)
	pagenum = math.floor(pagenum)
	local player_name = player:get_player_name()
	if not creative.creative_inventories[player_name] then
		create_creative_inventory(player)
	end
	local size = creative.creative_sizes[player_name]
	local pagemax = math.floor((size-1) / (creative.slots_num) + 1)
	return
		"list[detached:creative_"..player_name..";main;0.25,0.25;7,4;"..tostring(start_i).."]"..
		"label[7.5,0.75;"..F(S("@1/@2", pagenum, pagemax)).."]"..

                default.ui.image_button(7.25, 1.25, 1, 1, "creative_prev", "ui_icon_prev.png")..
                default.ui.image_button(7.25, 2.25, 1, 1, "creative_next", "ui_icon_next.png")..

                default.ui.get_itemslot_bg(0.25, 0.25, 7,4)..
		"image[7.25,3.25;1,1;creative_trash_icon.png]"..
		"list[detached:creative!trash;main;7.25,3.25;1,1;]"..
                default.ui.get_itemslot_bg(7.25, 3.25, 1,1)..
		"listring[current_player;main]"..
		"listring[detached:creative!trash;main]"..
		"listring[detached:creative_"..player_name..";main]"..
		"listring[current_player;main]"
end

local init_playerdata = function(playername)
	if not playerdata[playername] then
		playerdata[playername] = { page = 1 }
	end
end

local get_page_and_start_i = function(playername)
	init_playerdata(playername)
	local page = playerdata[playername].page or 1
	local start_i = (page - 1) * creative.slots_num
	return page, start_i
end

creative.get_formspec = function(playername)
	if not minetest.settings:get_bool("creative_mode") then
		return ""
	end
	local player = minetest.get_player_by_name(playername)
	if player then
                local form = default.ui.get_page("rp_creative:creative")
		local page, start_i = get_page_and_start_i(playername)
		form = form .. creative.get_creative_formspec(player, start_i, page)
		return form
	end
end

minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	init_playerdata(player:get_player_name())
	if not creative.creative_inventories[player:get_player_name()] then
		create_creative_inventory(player)
	end
end)
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	playerdata[player:get_player_name()] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	local playername = player:get_player_name()
	-- Figure out current page from formspec
	local current_page = 0
	local formspec = player:get_inventory_formspec()
	local page, start_i = get_page_and_start_i(playername)

	local changed = false
	if fields.creative_prev then
		page = page - 1
		start_i = start_i - creative.slots_num
		changed = true
	end
	if fields.creative_next then
		page = page + 1
		start_i = start_i + creative.slots_num
		changed = true
	end

	if start_i < 0 then
		start_i = start_i + creative.slots_num
		page = page + 1
	end
	if start_i >= creative.creative_sizes[playername] then
		start_i = start_i - creative.slots_num
		page = page - 1
	end
	playerdata[playername].page = page
		
	if start_i < 0 or start_i >= creative.creative_sizes[playername] then
		start_i = 0
		page = 1
	end

	local form = default.ui.get_page("rp_creative:creative")
	form = form .. creative.get_creative_formspec(player, start_i, start_i / (creative.slots_num) + 1)
	if changed then
		minetest.show_formspec(playername, "rp_creative:creative", form)
		player:set_inventory_formspec(form)
	end
end)

-- Dummy implementation
-- TODO: Implement per-player creative mode
creative.is_enabled_for = function(player)
	if minetest.settings:get_bool("creative_mode") then
		return true
	else
		return false
	end
end

if minetest.settings:get_bool("creative_mode") then
	minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
		-- Place infinite nodes, except for shulker boxes
		local group = minetest.get_item_group(itemstack:get_name(), "shulker_box")
		return group == 0 or group == nil
	end)
end
