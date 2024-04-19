local S = minetest.get_translator("rp_creative")
local FS = function(...) return minetest.formspec_escape(S(...)) end

creative = {}

creative.creative_inventories = {}
creative.creative_sizes = {}

local playerdata = {}

local form = rp_formspec.get_page("rp_formspec:2part")

form = form .. rp_formspec.default.player_inventory

-- Maximum allowed length for a search string
local MAX_SEARCH_LENGTH = 100

creative.slots_width = 7
creative.slots_height = 4
creative.slots_num = creative.slots_width * creative.slots_height

local special_items = {}

-- Register a special itemstack to the Creative Inventory.
-- Use this to add an item stack with custom metadata.
-- Item count MUST be 1.
-- Note: Item stacks registered with this function will
-- apper in Creative Inventory even if the item has the
-- `not_in_creative_inventory` group.
creative.register_special_item = function(itemstack)
	table.insert(special_items, itemstack)
end

-- Fill creative inventory of player with name <pname>.
-- If `filter` is a string, only adds items that contain the value of `filter` as a substring.
-- If `filter` is nil or the empty string, it will be filled with all available items for Creative Mode.
local function fill_creative_inventory(pname, filter)
	local pinfo = minetest.get_player_information(pname)
	local lang_code
	if pinfo then
		lang_code = pinfo.lang_code
	end
	if filter == "" then
		filter = nil
	end
	if filter then
		filter = string.lower(filter)
	end
	local inv = minetest.get_inventory({type="detached", name="creative_"..pname})
	local creative_list = {}

	local function check_match(name, def, filter)
		if filter then
			local item = ItemStack(name)
			local desc = item:get_short_description()
			local descl = string.lower(desc)
			local desc_transl
			if lang_code then
				desc_transl = string.lower(minetest.get_translated_string(lang_code, desc))
			end
			if desc ~= "" and string.find(descl, filter, 1, true) then
				return true
			elseif desc_transl and desc_transl ~= "" and string.find(desc_transl, filter, 1, true) then
				return true
			elseif string.find(name, filter, 1, true) then
				return true
			end
		else
			return true
		end
	end

	for name, def in pairs(minetest.registered_items) do
		if (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
				and def.description and def.description ~= "" then
			if check_match(name, def, filter) then
				table.insert(creative_list, ItemStack(name))
			end
		end
	end
	for i=1, #special_items do
		local item = special_items[i]
		if check_match(item:get_name(), item:get_definition(), filter) then
			table.insert(creative_list, special_items[i])
		end
	end

	local get_type = function(def)
		if not def.groups then
			return "craftitem" -- fallback
		end
		if def.groups.craftitem then
			return "craftitem"
		elseif def.groups.tool then
			return "tool"
		elseif def.groups.node then
			return "node"
		end
		if def.type == "craft" then
			return "craftitem"
		elseif def.type == "tool" then
			return "tool"
		elseif def.type == "node" then
			return "node"
		end
		return "craftitem" -- fallback
	end
	local function creative_sort(item1, item2)
		local itemname1 = item1:get_name()
		local itemname2 = item2:get_name()
		local def1 = minetest.registered_items[itemname1]
		local def2 = minetest.registered_items[itemname2]
		local groups1 = def1.groups or {}
		local groups2 = def2.groups or {}
		local type1 = get_type(def1)
		local type2 = get_type(def2)

		if (type1 == "tool" and type2 ~= "tool") then
			return true
		elseif (type1 ~= "tool" and type2 == "tool") then
			return false
		elseif (type1 == "craftitem" and type2 ~= "craftitem") then
			return true
		elseif (type1 ~= "craftitem" and type2 == "craftitem") then
			return false
		elseif (type1 == "node" and type2 ~= "node") then
			return true
		elseif (type1 ~= "node" and type2 == "node") then
			return false
		elseif def1.tool_capabilities and not def2.tool_capabilities then
			return true
		elseif not def1.tool_capabilities and def2.tool_capabilities then
			return false
		elseif groups1.is_armor and not groups2.is_armor then
			return true
		elseif not groups1.is_armor and groups2.is_armor then
			return false
		elseif groups1.food and not groups2.food then
			return true
		elseif not groups1.food and groups2.food then
			return false
		elseif groups1.spawn_egg and not groups2.spawn_egg then
			return true
		elseif not groups1.spawn_egg and groups2.spawn_egg then
			return false
		elseif groups1.plant and not groups2.plant then
			return true
		elseif not groups1.plant and groups2.plant then
			return false
		elseif groups1.grass and not groups2.grass then
			return true
		elseif not groups1.grass and groups2.grass then
			return false
		elseif groups1.dirt and not groups2.dirt then
			return true
		elseif not groups1.dirt and groups2.dirt then
			return false
		elseif groups1.sand and not groups2.sand then
			return true
		elseif not groups1.sand and groups2.sand then
			return false
		elseif groups1.sandstone and not groups2.sandstone then
			return true
		elseif not groups1.sandstone and groups2.sandstone then
			return false
		elseif groups1.gravel and not groups2.gravel then
			return true
		elseif not groups1.gravel and groups2.gravel then
			return false
		elseif groups1.stone and not groups2.stone then
			return true
		elseif not groups1.stone and groups2.stone then
			return false
		elseif groups1.ore and not groups2.ore then
			return true
		elseif not groups1.ore and groups2.ore then
			return false
		elseif groups1.tree and not groups2.tree then
			return true
		elseif not groups1.tree and groups2.tree then
			return false
		elseif groups1.leaves and not groups2.leaves then
			return true
		elseif not groups1.leaves and groups2.leaves then
			return false
		elseif groups1.wood and not groups2.wood then
			return true
		elseif not groups1.wood and groups2.wood then
			return false
		elseif groups1.water and not groups2.water then
			return true
		elseif not groups1.water and groups2.water then
			return false
		elseif groups1.path and not groups2.path then
			return true
		elseif not groups1.path and groups2.path then
			return false
		elseif groups1.creative_decoblock and not groups2.creative_decoblock then
			return true
		elseif not groups1.creative_decoblock and groups2.creative_decoblock then
			return false
		elseif groups1.container and not groups2.container then
			return true
		elseif not groups1.container and groups2.container then
			return false
		elseif groups1.interactive_node and not groups2.interactive_node then
			return true
		elseif not groups1.interactive_node and groups2.interactive_node then
			return false
		else
			return itemname1 < itemname2
		end
	end

	-- Sort items
	table.sort(creative_list, creative_sort)

	-- Fill inventory
	if #creative_list == 0 then
		creative.creative_sizes[pname] = 0
		inv:set_size("main", 1)
		inv:set_stack("main", 1, "")
	else
		inv:set_size("main", #creative_list)
		for i, itemstring in ipairs(creative_list) do
			inv:set_stack("main", i, ItemStack(itemstring))
		end
		creative.creative_sizes[pname] = inv:get_size("main")
	end
end

-- Create detached creative inventory for player
local function create_creative_inventory(player)
	local player_name = player:get_player_name()
	local inv = minetest.create_detached_inventory("creative_"..player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local name = player:get_player_name()
			if minetest.is_creative_enabled(player_name) and to_list ~= "main" then
				return count
			else
				return 0
			end
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			if minetest.is_creative_enabled(player:get_player_name()) then
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
				minetest.log("action", "[rp_creative] " .. player:get_player_name().." takes "..dump(stack:get_name()).." from creative inventory")
			end
		end,
	}, player_name)
	creative.creative_inventories[player_name] = inv
	fill_creative_inventory(player_name)
	return inv
end

-- Create the trash field
local trash = minetest.create_detached_inventory("creative!trash", {
	-- Allow the stack to be placed and remove it in on_put()
	-- This allows the creative inventory to restore the stack
	allow_put = function(inv, listname, index, stack, player)
		if minetest.is_creative_enabled(player:get_player_name()) then
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
	local creative_slots_bg = ""
	if size > 0 then
		if pagenum < pagemax then
			-- Render all slots for all pages except the last one
			creative_slots_bg = rp_formspec.get_itemslot_bg(0, 0, creative.slots_width, creative.slots_height)
		else
			-- Render fewer slots for last page if it isn't full
			local last_page_slots = size % creative.slots_num
			if last_page_slots == 0 then
				-- Last page is full, no slot limit needed
				last_page_slots = nil
			end
			creative_slots_bg = rp_formspec.get_itemslot_bg(0, 0, creative.slots_width, creative.slots_height, last_page_slots)
		end
	end
	local inventory_list, page_label
	if size == 0 then
		inventory_list = "label[1.25,2.5;"..S("No items.").."]"
		page_label = ""
	else
		inventory_list = "list[detached:creative_"..player_name..";main;0,0;"..creative.slots_width..","..creative.slots_height..";"..tostring(start_i).."]"
		page_label = "label[8.95,0.75;"..FS("@1/@2", pagenum, pagemax).."]"
	end
	return
		"container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"..
                creative_slots_bg..
		inventory_list..
		page_label..
                rp_formspec.image_button(8.75, 1.15, 1, 1, "creative_prev", "ui_icon_prev.png")..
                rp_formspec.image_button(8.75, 2.30, 1, 1, "creative_next", "ui_icon_next.png")..

		"image[8.75,3.45;1,1;creative_trash_icon.png]"..
                rp_formspec.get_itemslot_bg(8.75, 3.45, 1,1)..
		"list[detached:creative!trash;main;8.75,3.45;1,1;]"..
		"container_end[]"..
		"listring[current_player;main]"..
		"listring[detached:creative!trash;main]"..
		"listring[detached:creative_"..player_name..";main]"..
		"listring[current_player;main]"
end

local init_playerdata = function(playername)
	if not playerdata[playername] then
		playerdata[playername] = { page = 1, search = nil }
	end
end

local get_page_and_start_i = function(playername)
	init_playerdata(playername)
	local page = playerdata[playername].page or 1
	local start_i = (page - 1) * creative.slots_num
	return page, start_i
end

creative.get_formspec = function(playername)
	if not minetest.is_creative_enabled(playername) then
		return ""
	end
	local player = minetest.get_player_by_name(playername)
	if player then
                local form = rp_formspec.get_page("rp_creative:creative")
		-- Pages
		local page, start_i = get_page_and_start_i(playername)

		-- Creative inventory
		form = form .. creative.get_creative_formspec(player, start_i, page)

		-- Search menu
		local searching = playerdata[playername].search
		local search_tex, search_pushed, search_tooltip
		if searching == nil then
			search_tex = "ui_icon_creative_search.png"
			search_pushed = false
			search_tooltip = S("Search")
		else
			-- Search input field
			search_tex = "ui_icon_creative_search_active.png"
			search_pushed = true
			search_tooltip = S("Stop search")
			local text
			if type(searching) == "string" then
				text = searching
			else
				text = ""
			end
			form = form .. "background["..rp_formspec.default.size.x..",1.6;2.135,0.8;ui_creative_text_bg.png]"
			form = form .. "style[search_input;noclip=true]"
			form = form .. "field["..(rp_formspec.default.size.x+0.05)..",1.7;2,0.5;search_input;;"..minetest.formspec_escape(text).."]"
			form = form .. "style[search_submit;border=false;noclip=true;bgimg=ui_button_search_submit_inactive.png]"
			form = form .. "style[search_submit:pressed;border=false;noclip=true;bgimg=ui_button_search_submit_active.png]"
			form = form .. "button["..(rp_formspec.default.size.x+2.134)..",1.6;0.77778,0.8;search_submit;]"
			form = form .. "tooltip[search_submit;"..minetest.formspec_escape(S("Submit")).."]"
			form = form .. "field_close_on_enter[search_input;false]"
		end
		form = form .. rp_formspec.tab(rp_formspec.default.size.x, 0.5, "search", search_tex, search_tooltip, "right", search_pushed)

		return form
	end
end

rp_formspec.register_page("rp_creative:creative", form)
rp_formspec.register_invpage("rp_creative:creative", {
	get_formspec = creative.get_formspec,
	_is_startpage = function(pname)
		if minetest.is_creative_enabled(pname) then
			return true
		else
			return false
		end
	end,
})
if minetest.is_creative_enabled("") then
	rp_formspec.register_invtab("rp_creative:creative", {
		icon = "ui_icon_creative.png",
		icon_active = "ui_icon_creative_active.png",
		tooltip = S("Creative Inventory"),
	})
end

minetest.register_on_joinplayer(function(player)
	-- If in creative mode, modify player's inventory forms
	if not minetest.is_creative_enabled(player:get_player_name()) then
		return
	end
	init_playerdata(player:get_player_name())
	if not creative.creative_inventories[player:get_player_name()] then
		create_creative_inventory(player)
	end
end)
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	playerdata[name] = nil
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
        local invpage = rp_formspec.get_current_invpage(player)
        if not (formname == "" and invpage == "rp_creative:creative") then
           return
        end
	if not minetest.is_creative_enabled(player:get_player_name()) then
		return
	end
	local playername = player:get_player_name()
	if fields.search then
		if playerdata[playername].search == nil then
			playerdata[playername].search = ""
		else
			playerdata[playername].search = nil
			fill_creative_inventory(playername)
		end
		rp_formspec.refresh_invpage(player, "rp_creative:creative")
		return
	end

	local changed = false
	if fields.search_input then
		if fields.search_submit or playerdata[playername].search ~= fields.search_input then
			local search_input = fields.search_input or ""
			search_input = string.sub(search_input, 1, MAX_SEARCH_LENGTH)
			if search_input ~= "" then
				playerdata[playername].search = search_input
				fill_creative_inventory(playername, search_input)
				changed = true
			else
				playerdata[playername].search = ""
				fill_creative_inventory(playername)
				changed = true
			end
		end
	end

	-- Figure out current page from formspec
	local current_page = 0
	local formspec = player:get_inventory_formspec()
	local page, start_i = get_page_and_start_i(playername)

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
		playerdata[playername].page = page
	end

	if changed then
		rp_formspec.refresh_invpage(player, "rp_creative:creative")
	end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack)
	local pname = ""
	if placer and placer:is_player() then
		pname = placer:get_player_name()
	end
	if minetest.is_creative_enabled(pname) then
		-- Place infinite nodes
		return true
	end
end)
