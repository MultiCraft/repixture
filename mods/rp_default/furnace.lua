--
-- Furnace
--

local S = minetest.get_translator("rp_default")
local F = minetest.formspec_escape

function default.furnace_active_formspec(percent, item_percent)
   local form = default.ui.get_page("rp_default:2part")
   form = form .. "list[current_player;main;0.25,4.75;8,4;]"
   form = form .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
   form = form .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

   form = form .. "list[current_name;src;2.25,0.75;1,1;]"
   form = form .. default.ui.get_itemslot_bg(2.25, 0.75, 1, 1)

   form = form .. "list[current_name;fuel;2.25,2.75;1,1;]"
   form = form .. default.ui.get_itemslot_bg(2.25, 2.75, 1, 1)

   form = form .. "list[current_name;dst;4.25,1.25;2,2;]"
   form = form .. default.ui.get_output_itemslot_bg(4.25, 1.25, 2, 2)

   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;src]"
   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;dst]"
   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;fuel]"

   form = form .. "image[2.25,1.75;1,1;ui_fire_bg.png^[lowpart:"
   form = form .. (100-percent) .. ":ui_fire.png]"
   form = form .. "image[3.25,1.75;1,1;ui_arrow_bg.png^[lowpart:"
   form = form .. (item_percent) .. ":ui_arrow.png^[transformR270]"

   return form
end

local form_furnace = default.ui.get_page("rp_default:2part")
form_furnace = form_furnace .. "list[current_player;main;0.25,4.75;8,4;]"
form_furnace = form_furnace .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_furnace = form_furnace .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

form_furnace = form_furnace .. "list[current_name;src;2.25,0.75;1,1;]"
form_furnace = form_furnace .. default.ui.get_itemslot_bg(2.25, 0.75, 1, 1)

form_furnace = form_furnace .. "list[current_name;fuel;2.25,2.75;1,1;]"
form_furnace = form_furnace .. default.ui.get_itemslot_bg(2.25, 2.75, 1, 1)

form_furnace = form_furnace .. "list[current_name;dst;4.25,1.25;2,2;]"
form_furnace = form_furnace .. default.ui.get_hotbar_itemslot_bg(4.25, 1.25, 2, 2)

form_furnace = form_furnace .. "listring[current_player;main]"
form_furnace = form_furnace .. "listring[current_name;src]"
form_furnace = form_furnace .. "listring[current_player;main]"
form_furnace = form_furnace .. "listring[current_name;dst]"
form_furnace = form_furnace .. "listring[current_player;main]"
form_furnace = form_furnace .. "listring[current_name;fuel]"

form_furnace = form_furnace .. "image[2.25,1.75;1,1;ui_fire_bg.png]"
form_furnace = form_furnace .. "image[3.25,1.75;1,1;ui_arrow_bg.png^[transformR270]"

default.ui.register_page("default_furnace_inactive", form_furnace)

local check_put = function(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) and
            not minetest.check_player_privs(player, "protection_bypass") then
        minetest.record_protection_violation(pos, player:get_player_name())
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "fuel" then
        if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
            return stack:get_count()
        else
            return 0
        end
    elseif listname == "src" then
        return stack:get_count()
    elseif listname == "dst" then
        return 0
    end
end

local check_take = function(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) and
            not minetest.check_player_privs(player, "protection_bypass") then
        minetest.record_protection_violation(pos, player:get_player_name())
        return 0
    else
        return stack:get_count()
    end
end

local check_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    return check_put(pos, to_list, to_index, stack, player)
end

minetest.register_node(
   "rp_default:furnace",
   {
      description = S("Furnace"),
      _tt_help = S("Uses fuel to smelt a material into something else"),
      tiles ={"default_furnace_top.png", "default_furnace_top.png", "default_furnace_sides.png",
	      "default_furnace_sides.png", "default_furnace_sides.png", "default_furnace_front.png"},
      paramtype2 = "facedir",
      groups = {cracky = 2},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", default.ui.get_page("default_furnace_inactive"))
			meta:set_string("infotext", S("Furnace"))

			local inv = meta:get_inventory()
			inv:set_size("fuel", 1)
			inv:set_size("src", 1)
			inv:set_size("dst", 4)
		     end,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      can_dig = function(pos,player)
		   local meta = minetest.get_meta(pos);
		   local inv = meta:get_inventory()
		   if not inv:is_empty("fuel") then
		      return false
		   elseif not inv:is_empty("dst") then
		      return false
		   elseif not inv:is_empty("src") then
		      return false
		   end
		   return true
		end,
   })

minetest.register_node(
   "rp_default:furnace_active",
   {
      description = S("Furnace (active)"),
      _tt_help = S("Uses fuel to smelt a material into something else"),
      tiles ={"default_furnace_top.png", "default_furnace_top.png", "default_furnace_sides.png",
	      "default_furnace_sides.png", "default_furnace_sides.png", "default_furnace_front.png^default_furnace_flame.png"},
      paramtype2 = "facedir",
      light_source = 8,
      drop = "rp_default:furnace",
      groups = {cracky = 2, not_in_creative_inventory=1},
      is_ground_content = false,
      sounds = default.node_sound_stone_defaults(),
      on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", default.ui.get_page("default_furnace_inactive"))
			meta:set_string("infotext", S("Furnace"));

			local inv = meta:get_inventory()
			inv:set_size("fuel", 1)
			inv:set_size("src", 1)
			inv:set_size("dst", 4)
		     end,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      can_dig = function(pos,player)
		   local meta = minetest.get_meta(pos);
		   local inv = meta:get_inventory()
		   if not inv:is_empty("fuel") then
		      return false
		   elseif not inv:is_empty("dst") then
		      return false
		   elseif not inv:is_empty("src") then
		      return false
		   end
		   return true
		end,
   })

local function swap_node(pos, name)
   local node = minetest.get_node(pos)
   if node.name == name then
      return
   end
   node.name = name
   minetest.swap_node(pos, node)
end

minetest.register_abm(
   {
      label = "Furnace",
      nodenames = {"rp_default:furnace", "rp_default:furnace_active"},
      interval = 1.0,
      chance = 1,
      action = function(pos, node, active_object_count, active_object_count_wider)
		  --
		  -- Initialize metadata
		  --
		  local meta = minetest.get_meta(pos)
		  local fuel_time = meta:get_float("fuel_time") or 0
		  local src_time = meta:get_float("src_time") or 0
		  local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

		  --
		  -- Initialize inventory
		  --
		  local inv = meta:get_inventory()
		  for listname, size in pairs(
		     {
			src = 1,
			fuel = 1,
			dst = 4,
		     }) do
		     if inv:get_size(listname) ~= size then
			inv:set_size(listname, size)
		     end
		  end
		  local srclist = inv:get_list("src")
		  local fuellist = inv:get_list("fuel")
		  local dstlist = inv:get_list("dst")

		  --
		  -- Cooking
		  --

		  -- Check if we have cookable content
		  local cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		  local cookable = true

		  if cooked.time == 0 then
		     cookable = false
		  end

		  -- Check if we have enough fuel to burn
		  if fuel_time < fuel_totaltime then
		     -- The furnace is currently active and has enough fuel
		     fuel_time = fuel_time + 1

		     -- If there is a cookable item then check if it is ready yet
		     if cookable then
			src_time = src_time + 1
			if src_time >= cooked.time then
			   -- Place result in dst list if possible
			   if inv:room_for_item("dst", cooked.item) then
			      inv:add_item("dst", cooked.item)
			      inv:set_stack("src", 1, aftercooked.items[1])
			      src_time = 0
			   end
			end
		     end
		  else
		     -- Furnace ran out of fuel
		     if cookable then
			-- We need to get new fuel
			local fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

			if fuel.time == 0 then
			   -- No valid fuel in fuel list
			   fuel_totaltime = 0
			   fuel_time = 0
			   src_time = 0
			else
			   -- Take fuel from fuel list
			   inv:set_stack("fuel", 1, afterfuel.items[1])

			   fuel_totaltime = fuel.time
			   fuel_time = 0

			end
		     else
			-- We don't need to get new fuel since there is no cookable item
			fuel_totaltime = 0
			fuel_time = 0
			src_time = 0
		     end
		  end

		  --
		  -- Update formspec, infotext and node
		  --
		  local formspec = default.ui.get_page("default_furnace_inactive")
		  local item_state = ""
		  local item_percent = 0
		  if cookable then
		     item_percent =  math.floor(src_time / cooked.time * 100)
		     item_state = S("@1%", item_percent)
		  else
		     if srclist[1]:is_empty() then
			item_state = S("Empty")
		     else
			item_state = S("Not cookable")
		     end
		  end

		  local fuel_state = S("Empty")
		  local active = false
		  if fuel_time <= fuel_totaltime and fuel_totaltime ~= 0 then
		     active = true
		     local fuel_percent = math.floor(fuel_time / fuel_totaltime * 100)
		     fuel_state = S("@1%", fuel_percent)
		     formspec = default.furnace_active_formspec(fuel_percent, item_percent)
		     swap_node(pos, "rp_default:furnace_active")
		  else
		     if not fuellist[1]:is_empty() then
			fuel_state = S("@1%", "0")
		     end
		     swap_node(pos, "rp_default:furnace")
		  end

		  local infotext
		  if active then
		     infotext = S("Furnace active (Item: @1; Fuel: @2)", item_state, fuel_state)
		  else
		     infotext = S("Furnace inactive (Item: @1; Fuel: @2)", item_state, fuel_state)
		  end

		  --
		  -- Set meta values
		  --
		  meta:set_float("fuel_totaltime", fuel_totaltime)
		  meta:set_float("fuel_time", fuel_time)
		  meta:set_float("src_time", src_time)
		  meta:set_string("formspec", formspec)
		  meta:set_string("infotext", infotext)
	       end,
   })

default.log("furnace", "loaded")