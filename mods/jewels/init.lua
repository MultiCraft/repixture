
--
-- Jewels mod
-- By Kaadmy
--

local S = minetest.get_translator("jewels")
local NS = function(s) return s end
local F = minetest.formspec_escape

jewels = {}

-- Array of registered jeweled tools

jewels.registered_jewels = {}
jewels.registered_jewel_parents = {}

-- Formspec

local form_bench = default.ui.get_page("default:2part")

form_bench = form_bench .. "list[current_name;main;2.25,1.75;1,1;]"
form_bench = form_bench .. "listring[current_name;main]"
form_bench = form_bench .. default.ui.get_itemslot_bg(2.25, 1.75, 1, 1)

form_bench = form_bench .. "label[3.25,1.75;"..F(S("1. Place tool here")).."]"
form_bench = form_bench .. "label[3.25,2.25;"..F(S("2. Hold a jewel and punch the bench")).."]"

form_bench = form_bench .. "list[current_player;main;0.25,4.75;8,4;]"
form_bench = form_bench .. "listring[current_player;main]"
form_bench = form_bench .. default.ui.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_bench = form_bench .. default.ui.get_itemslot_bg(0.25, 5.75, 8, 3)

default.ui.register_page("jewels_bench", form_bench)

local function plus_power(i)
   if i >= 0 then
      i = "+" .. i
   end

   return i
end

local function append_stat(desc, format_text, stats_key, parent, data)
   local disp_val = data.stats[stats_key] or 0
   if parent then
      disp_val = disp_val + parent.stats[stats_key]
   end
   if disp_val ~= 0 then
      desc = desc .. "\n"..S(format_text, plus_power(disp_val))
   end
   return desc
end

function jewels.register_jewel(toolname, new_toolname, def)
   -- registers a new tool with different stats

   local data = {
      name = new_toolname, -- the new name of the tool
      overlay = def.overlay or "jewels_jeweled_handle.png", -- overlay image
      description = def.description or nil,
      stats = {
	 digspeed = def.stats.digspeed, -- negative digs faster
	 maxlevel = def.stats.maxlevel, -- positive digs higher levels
	 maxdrop = def.stats.maxdrop, -- positive increases max drop level
	 uses = def.stats.uses, -- positive increases uses
	 fleshy = def.stats.fleshy, -- positive increases fleshy damage
	 range = def.stats.range, -- positive increases reach distance with tool
      }
   }

   if not jewels.registered_jewels[toolname] then
      jewels.registered_jewels[toolname] = {}
   end

   table.insert(jewels.registered_jewels[toolname], data)
   local newparent = {
      name = toolname,
      stats = {
         digspeed = (data.stats.digspeed or 0),
         maxlevel = (data.stats.maxlevel or 0),
         maxdrop = (data.stats.maxdrop or 0),
         uses = (data.stats.uses or 0),
         fleshy = (data.stats.fleshy or 0),
         range = (data.stats.range or 0),
      }
   }

   local parent = jewels.registered_jewel_parents[toolname] 
   if parent then
      for k,v in pairs(parent.stats) do
         newparent.stats[k] = newparent.stats[k] + v
      end
   end
   jewels.registered_jewel_parents[new_toolname] = newparent

   local tooldef = minetest.deserialize(
      minetest.serialize(minetest.registered_tools[toolname]))

   if not tooldef then
      minetest.log("warning",
                   "Trying to register jewel " .. new_toolname
                      .. " that has an unknown output item " .. toolname)

      return
   end

   local new_tool_invimage = ""
   if tooldef.inventory_image then
      new_tool_invimage = tooldef.inventory_image .. "^" .. data.overlay
   end

   local new_tool_wieldimage = ""
   if tooldef.wield_image then
      new_tool_wieldimage = tooldef.wield_image .. "^" .. data.overlay
   end

   local new_tooldef = tooldef
   local desc
   if data.description ~= nil then
      desc = data.description
   else
      -- All tools should have their description set explicitly. This is a fallback
      minetest.log("warning", "[jewels] No description for jeweled tool "..new_toolname.."! Auto-generating a name")
      desc = new_tooldef.description
      if not desc then
         desc = new_toolname
      else
         desc = S("Jeweled @1", desc)
      end
   end

   new_tooldef.inventory_image = new_tool_invimage
   new_tooldef.wield_image = new_tool_wieldimage

   if data.stats.range then
      if not new_tooldef.range then
          new_tooldef.range = 4
      end
      new_tooldef.range = new_tooldef.range + data.stats.range
   end
   desc = append_stat(desc, NS("Range: @1"), "range", parent, data)

   if new_tooldef.tool_capabilities then
      if data.stats.maxdrop and new_tooldef.tool_capabilities.max_drop_level then
	 new_tooldef.tool_capabilities.max_drop_level =
            new_tooldef.tool_capabilities.max_drop_level + data.stats.maxdrop
      end
      desc = append_stat(desc, NS("Drop level: @1"), "maxdrop", parent, data)

      if data.stats.digspeed then
	 for group, cap in pairs(new_tooldef.tool_capabilities.groupcaps) do
	    for i, _ in ipairs(cap.times) do
	       cap.times[i] = cap.times[i] + data.stats.digspeed
	    end

	    if data.stats.maxlevel and cap.maxlevel then
	       cap.maxlevel = cap.maxlevel + data.stats.maxlevel
	    end

	    if data.stats.uses and cap.uses then
	       cap.uses = cap.uses + data.stats.uses
	    end
	 end
      end
      desc = append_stat(desc, NS("Dig time: @1 s"), "digspeed", parent, data)

      desc = append_stat(desc, NS("Uses: @1"), "uses", parent, data)

      desc = append_stat(desc, NS("Dig level: @1"), "maxlevel", parent, data)

      if data.stats.fleshy and new_tooldef.tool_capabilities.damage_groups
      and new_tooldef.tool_capabilities.damage_groups.fleshy then
	 new_tooldef.tool_capabilities.damage_groups.fleshy =
            new_tooldef.tool_capabilities.damage_groups.fleshy + data.stats.fleshy
      end
      desc = append_stat(desc, NS("Damage: @1"), "fleshy", parent, data)
   end

   new_tooldef.description = desc

   if not new_tooldef.groups then
     new_tooldef.groups = {}
   end
   new_tooldef.groups.not_in_creative_inventory = 1

   minetest.register_tool(new_toolname, new_tooldef)
end

function jewels.can_jewel(toolname)
   for name, _ in pairs(jewels.registered_jewels) do
      if name == toolname then
	 return true
      end
   end

   return false
end

function jewels.get_jeweled(toolname)
   for name, jables in pairs(jewels.registered_jewels) do
      if name == toolname then
	 return util.choice_element(jables)
      end
   end
end

-- Items

minetest.register_craftitem(
   "jewels:jewel",
   {
      description = S("Jewel"),
      inventory_image = "jewels_jewel.png",
      stack_max = 10
})

-- Nodes

local check_put = function(pos, listname, index, stack, player)
    if minetest.is_protected(pos, player:get_player_name()) and
            not minetest.check_player_privs(player, "protection_bypass") then
        minetest.record_protection_violation(pos, player:get_player_name())
        return 0
    end
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    if listname == "main" then
        local name = stack:get_name()
        if minetest.registered_items[name] then
            -- Disallow put for non-tools (unless it can be jeweled)
            if (not jewels.can_jewel(name)) and minetest.registered_items[name].type ~= "tool" then
                return 0
            end
        end
    end
    return stack:get_count()
end
local check_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local stack = inv:get_stack(from_list, from_index)
    return check_take(pos, to_list, to_index, stack, player)
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

minetest.register_node(
   "jewels:bench",
   {
      description = S("Jeweler's Workbench"),
      tiles ={"jewels_bench_top.png", "jewels_bench_bottom.png", "jewels_bench_sides.png"},
      paramtype2 = "facedir",
      groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
      legacy_facedir_simple = true,
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),

      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("formspec", default.ui.get_page("jewels_bench"))
         meta:set_string("infotext", S("Jeweler's Workbench"))

         local inv = meta:get_inventory()
         inv:set_size("main", 1)
      end,
      can_dig = function(pos, player)
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()

         return inv:is_empty("main")
      end,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      on_punch = function(pos, node, player, pointed_thing)
         local itemstack = player:get_wielded_item()
         local itemstack_changed = false
         if itemstack:get_name() == "jewels:jewel" then
            if minetest.is_protected(pos, player:get_player_name()) and
                    not minetest.check_player_privs(player, "protection_bypass") then
                minetest.record_protection_violation(pos, player:get_player_name())
                return
            end
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()

            local iitem = inv:get_stack("main", 1)
            if iitem:is_empty() then
                return
            end
            local itemname = iitem:get_name()

            if jewels.can_jewel(itemname) then
               -- Success
               inv:set_stack("main", 1, ItemStack(jewels.get_jeweled(itemname)))

               if not minetest.settings:get_bool("creative_mode") then
                  itemstack:take_item()
                  itemstack_changed = true
               end

               minetest.sound_play({name="jewels_jewelling_a_tool"}, {gain=0.8, pos=pos, max_hear_distance=8})
               -- TODO: Graphical effect

               achievements.trigger_achievement(player, "jeweler")
               achievements.trigger_achievement(player, "master_jeweler")
            else
               -- Failure
               minetest.sound_play({name="jewels_jewelling_fail"}, {gain=0.8, pos=pos, max_hear_distance=8})
            end
         end

         if itemstack_changed then
             player:set_wielded_item(itemstack)
         end
      end,
})

minetest.register_node(
   "jewels:jewel_ore",
   {
      description = S("Jewel Ore"),
      tiles = {
         "default_tree_birch_top.png",
         "default_tree_birch_top.png",
         "default_tree_birch.png^jewels_ore.png"
      },
      drop = "jewels:jewel",
      groups = {snappy=1, choppy=1, tree=1},
      sounds = default.node_sound_wood_defaults(),
})

crafting.register_craft(
   {
      output = "jewels:bench",
      items = {
         "group:planks 5",
         "default:ingot_carbon_steel 2",
         "jewels:jewel",
      }
})

-- Achievements

achievements.register_achievement(
   "jeweler",
   {
      title = S("Jeweler"),
      description = S("Jewel a tool."),
      times = 1,
})

achievements.register_achievement(
   "secret_of_jewels",
   {
      title = S("Secret of Jewels"),
      description = S("Discover the origin of jewels."),
      times = 1,
      dignode = "jewels:jewel_ore",
})

-- The tool jewel definitions

dofile(minetest.get_modpath("jewels").."/jewels.lua")
dofile(minetest.get_modpath("jewels").."/mapgen.lua")

default.log("mod:jewels", "loaded")
