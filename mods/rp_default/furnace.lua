--
-- Furnace
--

local S = minetest.get_translator("rp_default")

local generate_furnace_formspec = function(active, percent, item_percent)
   local form = ""
   form = form .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"
   -- Source slot
   form = form .. rp_formspec.get_itemslot_bg(2.5, 0.5, 1, 1)
   form = form .. "list[current_name;src;2.5,0.5;1,1;]"

   -- Fuel slot
   form = form .. rp_formspec.get_itemslot_bg(2.5, 3, 1, 1)
   form = form .. "list[current_name;fuel;2.5,3;1,1;]"

   -- Output slots
   form = form .. rp_formspec.get_hotbar_itemslot_bg(5, 1.25, 2, 2)
   form = form .. "list[current_name;dst;5,1.25;2,2;]"

   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;src]"
   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;dst]"
   form = form .. "listring[current_player;main]"
   form = form .. "listring[current_name;fuel]"

   -- Flame and arrow
   if not active then
      -- Inactive
      form = form .. "image[2.5,1.75;1,1;ui_fire_bg.png]"
      form = form .. "image[3.75,1.75;1,1;ui_arrow_bg.png^[transformR270]"
   else
      -- Active
      form = form .. "image[2.5,1.75;1,1;ui_fire_bg.png^[lowpart:"
      form = form .. (100-percent) .. ":ui_fire.png]"
      form = form .. "image[3.75,1.75;1,1;ui_arrow_bg.png^[lowpart:"
      form = form .. (item_percent) .. ":ui_arrow.png^[transformR270]"
   end
   form = form .. "container_end[]"
   return form
end

function default.furnace_active_formspec(percent, item_percent)
   local form_furnace = rp_formspec.get_page("rp_formspec:2part")
   form_furnace = form_furnace .. rp_formspec.default.player_inventory
   form_furnace = form_furnace .. generate_furnace_formspec(true, percent, item_percent)
   return form_furnace
end

local form_furnace = rp_formspec.get_page("rp_formspec:2part")
form_furnace = form_furnace .. rp_formspec.default.player_inventory
form_furnace = form_furnace .. generate_furnace_formspec(false)

rp_formspec.register_page("rp_default:furnace_inactive", form_furnace)

local after_dig_node = function(pos, nodenode, oldmetadata, digger)
    item_drop.drop_items_from_container_meta_table(pos, {"fuel", "src", "dst"}, oldmetadata)
end

local on_blast = function(pos)
    item_drop.drop_items_from_container(pos, {"fuel", "src", "dst"})
    minetest.remove_node(pos)
end

local is_lump = function(itemstack)
    return minetest.get_item_group(itemstack:get_name(), "mineral_lump") ~= 0
end

local function set_last_placer(pos, meta, mtype, playername)
    meta:set_string("last_"..mtype.."_placer", playername)
    minetest.log("verbose", "[rp_default] Furnace at "..minetest.pos_to_string(pos, 0)..": last_"..mtype.."_placer='"..playername.."'")
end

local on_put = function(pos, listname, index, stack, player)
    local pname = ""
    if player:is_player() then
       pname = player:get_player_name()
    end
    local meta = minetest.get_meta(pos)
    if listname == "fuel" then
        if stack:get_count() > 0 then
           set_last_placer(pos, meta, "fuel", pname)
        end
    elseif listname == "src" then
        if stack:get_count() > 0 then
           set_last_placer(pos, meta, "src", pname)
        end
    end
end

local on_take = function(pos, listname, index, stack, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local orig_stack = inv:get_stack(listname, index)
    if listname == "src" then
        if orig_stack:get_count() == 0 then
           set_last_placer(pos, meta, "src", "")
        end
    end
end

local on_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    if count == 0 then
       return
    end
    local pname = ""
    if player:is_player() then
        pname = player:get_player_name()
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    if from_list == "src" and to_list == "fuel" then
        set_last_placer(pos, meta, "fuel", pname)
	if stack:get_count() == 0 then
           set_last_placer(pos, meta, "src", "")
        end
    elseif to_list == "src" then
        set_last_placer(pos, meta, "src", pname)
    elseif to_list == "fuel" then
        set_last_placer(pos, meta, "fuel", pname)
    end
end


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
      tiles ={"rp_default_furnace_top.png", "rp_default_furnace_top.png", "rp_default_furnace_sides.png",
	      "rp_default_furnace_sides.png", "rp_default_furnace_sides.png", "rp_default_furnace_front.png"},
      paramtype2 = "4dir",
      groups = {cracky = 2,container=1,interactive_node=1,furnace=1,furniture=1,pathfinder_hard=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults(),
      on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", rp_formspec.get_page("rp_default:furnace_inactive"))
			meta:set_string("infotext", S("Furnace"))

			local inv = meta:get_inventory()
			inv:set_size("fuel", 1)
			inv:set_size("src", 1)
			inv:set_size("dst", 4)
		     end,
      on_metadata_inventory_put = on_put,
      on_metadata_inventory_take = on_take,
      on_metadata_inventory_move = on_move,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      after_dig_node = after_dig_node,
      on_blast = on_blast,
      _rp_blast_resistance = 2,
   })

minetest.register_node(
   "rp_default:furnace_active",
   {
      description = S("Furnace (active)"),
      _tt_help = S("Uses fuel to smelt a material into something else"),
      tiles ={"rp_default_furnace_top.png", "rp_default_furnace_top.png", "rp_default_furnace_sides.png",
	      "rp_default_furnace_sides.png", "rp_default_furnace_sides.png",
	      { name = "rp_default_furnace_active_anim.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.0 }}
      },
      paramtype2 = "4dir",
      light_source = 8,
      drop = "rp_default:furnace",
      groups = {cracky = 2, container=1,interactive_node=1, furnace=2,not_in_creative_inventory=1,furniture=1,pathfinder_hard=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_stone_defaults(),
      on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", rp_formspec.get_page("rp_default:furnace_inactive"))
			meta:set_string("infotext", S("Furnace"));

			local inv = meta:get_inventory()
			inv:set_size("fuel", 1)
			inv:set_size("src", 1)
			inv:set_size("dst", 4)
		     end,
      on_metadata_inventory_put = on_put,
      on_metadata_inventory_take = on_take,
      on_metadata_inventory_move = on_move,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      after_dig_node = after_dig_node,
      on_blast = on_blast,
      _rp_blast_resistance = 2,
   })

local function swap_node(pos, name)
   local node = minetest.get_node(pos)
   if node.name == name then
      return
   end
   node.name = name
   minetest.swap_node(pos, node)
end

-- Checks and possibly triggers the metal_age achievement
local function check_metal_age_achievement(output_item, meta)
   -- Achievement is triggered only if an ingot was smelted
   if minetest.get_item_group(output_item:get_name(), "ingot") == 0 then
      return
   end
   -- To trigger the achievement, a player must have both
   -- placed the src AND fuel item as the last player.
   minetest.log("verbose", "[rp_default] Checking metal_age_achievement for furnace ...")
   local last_src_placer = meta:get_string("last_src_placer")
   local last_fuel_placer = meta:get_string("last_fuel_placer")
   if last_src_placer ~= "" and last_src_placer == last_fuel_placer then
      local player = minetest.get_player_by_name(last_src_placer)
      if player then
         achievements.trigger_achievement(player, "metal_age")
      end
   end
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
                              -- Add result
			      inv:add_item("dst", cooked.item)
                              -- Check achievement
                              check_metal_age_achievement(cooked.item, meta)
                              -- Update src stack and timer
			      inv:set_stack("src", 1, aftercooked.items[1])
                              if inv:get_stack("src", 1):is_empty() then
                                 set_last_placer(pos, meta, "src", "")
                              end
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
		  local formspec = rp_formspec.get_page("rp_default:furnace_inactive")
		  local item_state = ""
		  local item_percent = 0
		  if cookable then
		     item_percent =  math.floor(src_time / cooked.time * 100)
                     --~ Furnace cook completion percentage, shown when hovering furnace
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
                     --~ Percentage showing remaining furnace fuel, shown when hovering furnace
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
                     --~ Shown when hovering furnace. @1 = cooked item, @2 = fuel percentage
		     infotext = S("Furnace active (Item: @1; Fuel: @2)", item_state, fuel_state)
		  else
                     --~ Shown when hovering furnace. @1 = cooked item, @2 = fuel percentage
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
