
--
-- Jewels mod
-- By Kaadmy
--

local S = minetest.get_translator("rp_jewels")
local NS = function(s) return s end
local FS = function(...) return minetest.formspec_escape(S(...)) end

jewels = {}

-- Array of registered jeweled tools

jewels.registered_jewels = {}
jewels.registered_jewel_defs = {}
jewels.registered_jewel_parents = {}

-- Formspec

local form_bench = rp_formspec.get_page("rp_formspec:2part")

form_bench = form_bench .. "container["..rp_formspec.default.start_point.x..","..rp_formspec.default.start_point.y.."]"
form_bench = form_bench .. rp_formspec.get_itemslot_bg(2.5, 1.75, 1, 1)
form_bench = form_bench .. "list[current_name;main;2.5,1.75;1,1;]"
form_bench = form_bench .. "listring[current_name;main]"

form_bench = form_bench .. "label[3.75,2;"..FS("1. Place tool here").."]"
form_bench = form_bench .. "label[3.75,2.5;"..FS("2. Hold a jewel and punch the bench").."]"
form_bench = form_bench .. "container_end[]"

form_bench = form_bench .. rp_formspec.default.player_inventory
form_bench = form_bench .. "listring[current_player;main]"

rp_formspec.register_page("rp_jewels:bench", form_bench)

local function plus_power(i)
   if i >= 0 then
      i = "+" .. i
   end

   return i
end

function jewels.register_jewel(toolname, new_toolname, def)
   -- registers a new tool with different stats

   local data = {
      name = new_toolname, -- the new name of the tool
      overlay = def.overlay or "jewels_jeweled_handle.png", -- overlay image
      overlay_wield = def.overlay_wield, -- overlay wield image
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
   if not data.overlay_wield then
      data.overlay_wield = data.overlay
   end

   if not jewels.registered_jewels[toolname] then
      jewels.registered_jewels[toolname] = {}
   end

   jewels.registered_jewel_defs[new_toolname] = data

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

   local tooldef = minetest.registered_tools[toolname]

   if not tooldef then
      minetest.log("warning",
                   "[rp_jewels] Trying to register jewel " .. new_toolname
                      .. " that has an unknown output item " .. toolname)

      return
   end

   local new_tool_invimage
   if tooldef.inventory_image ~= nil and tooldef.inventory_image ~= "" then
      new_tool_invimage = "(" .. tooldef.inventory_image .. ")^(" .. data.overlay .. ")"
   end

   local new_tool_wieldimage
   if tooldef.wield_image ~= nil and tooldef.wield_image ~= "" then
      new_tool_wieldimage = "(" .. tooldef.wield_image .. ")^(" .. data.overlay_wield .. ")"
   elseif data.overlay_wield then
      new_tool_wieldimage = "(" .. tooldef.inventory_image .. ")^(" .. data.overlay_wield .. ")"
   end

   local new_tooldef = table.copy(tooldef)
   local desc
   if data.description ~= nil then
      desc = data.description
   else
      -- All tools should have their description set explicitly. This is a fallback
      minetest.log("warning", "[rp_jewels] No description for jeweled tool "..new_toolname.."! Auto-generating a name")
      desc = new_tooldef.description
      if not desc then
         desc = new_toolname
      else
         -- Fallback description
         desc = S("@1 (jeweled)", desc)
      end
   end
   new_tooldef.description = desc

   new_tooldef.inventory_image = new_tool_invimage
   new_tooldef.wield_image = new_tool_wieldimage

   if data.stats.range then
      if not new_tooldef.range then
          new_tooldef.range = 4
      end
      new_tooldef.range = new_tooldef.range + data.stats.range
   end

   if new_tooldef.tool_capabilities then
      if data.stats.maxdrop and new_tooldef.tool_capabilities.max_drop_level then
	 new_tooldef.tool_capabilities.max_drop_level =
            new_tooldef.tool_capabilities.max_drop_level + data.stats.maxdrop
      end

      if data.stats.digspeed then
	 for group, cap in pairs(new_tooldef.tool_capabilities.groupcaps) do
	    for i, _ in ipairs(cap.times) do
	       cap.times[i] = math.max(0, cap.times[i] + data.stats.digspeed)
	    end

	    if data.stats.maxlevel and cap.maxlevel then
	       cap.maxlevel = cap.maxlevel + data.stats.maxlevel
	    end

	    if data.stats.uses and cap.uses then
	       cap.uses = cap.uses + data.stats.uses
	    end
	 end
      end

      if data.stats.fleshy and new_tooldef.tool_capabilities.damage_groups
      and new_tooldef.tool_capabilities.damage_groups.fleshy then
	 new_tooldef.tool_capabilities.damage_groups.fleshy =
            new_tooldef.tool_capabilities.damage_groups.fleshy + data.stats.fleshy
      end
   end

   if not new_tooldef.groups then
     new_tooldef.groups = {}
   end
   new_tooldef.groups.not_in_creative_inventory = 1

   minetest.register_tool(new_toolname, new_tooldef)
end

if minetest.get_modpath("tt") then

local function get_stat(format_text, stats_key, parent, stats)
   local disp_val = stats[stats_key] or 0
   if parent then
      disp_val = disp_val + parent.stats[stats_key]
   end
   if disp_val ~= 0 then
      return S(format_text, loc.num(plus_power(disp_val)))
   end
   return nil
end

local amendments = {
   { "range", NS("Range bonus: @1") },
   { "maxdrop", NS("Drop level bonus: @1") },
   { "digspeed", NS("Dig time bonus: @1 s") },
   { "uses", NS("Durability bonus: @1") },
   { "maxlevel", NS("Dig level bonus: @1") },
}

for a=1, #amendments do
   tt.register_snippet(function(itemname)
      local jewel = jewels.registered_jewel_defs[itemname]
      local parent = jewels.registered_jewel_parents[itemname]
      if not jewel then
         return
      end

      local desc
      local stat = amendments[a][1]
      if jewel.stats[stat] then
          desc = get_stat(amendments[a][2], stat, parent, jewel.stats)
      end
      if desc ~= nil then
         return desc, "#4CFFFD"
      end

      return desc
   end)
end

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

-- Nodes

minetest.register_node(
   "rp_jewels:jewel",
   {
      description = S("Jewel"),
      inventory_image = "jewels_jewel.png",
      wield_image  = "jewels_jewel.png",
      wield_scale = { x=1, y=1, z=2 },
      tiles = {"rp_jewels_node_top.png", "rp_jewels_node_top.png", "rp_jewels_node_side.png"},
      use_texture_alpha = "clip",
      paramtype = "light",
      sunlight_propagates = true,
      is_ground_content = false,
      drawtype = "nodebox",
      walkable = false,
      floodable = true,
      on_flood = function(pos, oldnode, newnode)
         minetest.add_item(pos, "rp_jewels:jewel")
      end,
      node_box = {
         type = "fixed",
         fixed = {-4/16, -0.5, -4/16, 4/16, -0.5+(3/16), 4/16}
      },
      -- Note: The jewel does NOT count as a mineral, it is special
      groups = {dig_immediate = 3, craftitem = 1, attached_node = 1},
      sounds = rp_sounds.node_sound_crystal_defaults({
         footstep = {name="rp_sounds_footstep_glass",gain=0.5,pitch=1.2},
         place = {name="rp_sounds_place_crystal",gain=1,pitch=1.4},
         dug = {name="rp_sounds_dug_crystal",gain=1,pitch=1.35},
      }),
})

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
   "rp_jewels:bench",
   {
      description = S("Jeweler's Workbench"),
      _tt_help = S("Tools can be upgraded with jewels here"),
      tiles ={"jewels_bench_top.png", "jewels_bench_bottom.png", "jewels_bench_sides.png"},
      paramtype2 = "4dir",
      groups = {choppy=2,oddly_breakable_by_hand=2,interactive_node=1},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_wood_defaults(),

      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_string("formspec", rp_formspec.get_page("rp_jewels:bench"))
         meta:set_string("infotext", S("Jeweler's Workbench"))

         local inv = meta:get_inventory()
         inv:set_size("main", 1)
      end,
      on_destruct = function(pos)
         item_drop.drop_items_from_container(pos, {"main"})
      end,
      can_dig = function(pos, player)
         -- Player can't dig if bench has an item and
         -- player wields a jewel.
         -- Needed to avoid accidental digging in Creative Mode
         -- when jewelling a tool.
         if player and player:is_player() then
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            if inv:get_stack("main", 1):is_empty() then
               return true
            else
               local wield = player:get_wielded_item()
               if wield:get_name() == "rp_jewels:jewel" then
                  return false
               else
                  return true
               end
            end
         end
	 return true
      end,
      allow_metadata_inventory_move = check_move,
      allow_metadata_inventory_put = check_put,
      allow_metadata_inventory_take = check_take,
      on_punch = function(pos, node, player, pointed_thing)
         local itemstack = player:get_wielded_item()
         local itemstack_changed = false
         if itemstack:get_name() == "rp_jewels:jewel" then
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
               local new_item = jewels.get_jeweled(itemname)
	       if not new_item then
                  return
	       end
	       new_item = ItemStack(new_item)
	       if not new_item then
                  return
	       end
               -- Success
               inv:set_stack("main", 1, new_item)

               if not minetest.is_creative_enabled(player:get_player_name()) then
                  itemstack:take_item()
                  itemstack_changed = true
               end

               minetest.sound_play({name="jewels_jewelling_a_tool"}, {gain=0.8, pos=pos, max_hear_distance=8}, true)

	       -- Show the new tool above the bench
               local part = "jewels_jewel.png" -- fallback texture
               local idef = new_item:get_definition()
               if idef and idef.inventory_image then
                  part = idef.inventory_image
               end
               minetest.add_particlespawner({
                   amount = 1,
                   time = 0.01,
                   pos = {
                      min = vector.add(pos, vector.new(-0.01, 0.7, -0.01)),
                      max = vector.add(pos, vector.new(0.01, 0.7, 0.01)),
                   },
                   vel = {
                      min = vector.new(-0.1, 1, -0.1),
                      max = vector.new(0.1, 1, 0.1),
                   },
                   exptime = 1.4,
                   size = 6,
	           drag = vector.new(2,2,2),
                   texture = {
	              name = part,
                      alpha_tween = { 0.8, 0, start = 0.75 },
                   },
               })


               achievements.trigger_achievement(player, "jeweler")

               if new_item:get_name() == "rp_jewels:serrated_broadsword" then
                  achievements.trigger_achievement(player, "true_mighty_weapon")
               end
            else
               -- Failure
               minetest.sound_play({name="jewels_jewelling_fail"}, {gain=0.8, pos=pos, max_hear_distance=8}, true)
            end
         end

         if itemstack_changed then
             player:set_wielded_item(itemstack)
         end
      end,
      _rp_blast_resistance = 2,
})

minetest.register_node(
   "rp_jewels:jewel_ore",
   {
      description = S("Jewel Ore"),
      tiles = {
         "default_tree_birch_top.png",
         "default_tree_birch_top.png",
         "default_tree_birch.png^jewels_ore.png"
      },
      drop = "rp_jewels:jewel",
      groups = {choppy=1, tree=1, ore=1},
      sounds = rp_sounds.node_sound_wood_defaults(),
      _rp_blast_resistance = 1,
})

crafting.register_craft(
   {
      output = "rp_jewels:bench",
      items = {
         "group:planks 5",
         "rp_default:ingot_carbon_steel 2",
         "rp_jewels:jewel",
      }
})

minetest.register_craft(
{
      type = "cooking",
      output = "rp_jewels:jewel",
      recipe = "rp_jewels:jewel_ore",
      cooktime = 6,
})

-- Achievements

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 7
   "jeweler",
   {
      title = S("Jeweler"),
      description = S("Jewel a tool."),
      times = 1,
      item_icon = "rp_jewels:shovel_steel_uses",
      difficulty = 7,
})

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 8
   "true_mighty_weapon",
   {
      title = S("True Mighty Weapon"),
      description = S("Use jewels to create a serrated jewel broadsword."),
      times = 1,
      item_icon = "rp_jewels:serrated_broadsword",
      difficulty = 8,
})

achievements.register_achievement(
   -- REFERENCE ACHIEVEMENT 9
   "secret_of_jewels",
   {
      title = S("Secret of Jewels"),
      description = S("Discover the origin of jewels."),
      times = 1,
      dignode = "rp_jewels:jewel_ore",
      difficulty = 9,
})

-- Force node to update infotext/formspec
minetest.register_lbm(
   {
      label = "Update jeweler's workbench",
      name = "rp_jewels:update_bench_3_14_0",
      nodenames = {"rp_jewels:bench"},
      action = function(pos, node)
          local def = minetest.registered_nodes[node.name]
          if def and def.on_construct then
              def.on_construct(pos)
          end
      end
   }
)

-- The tool jewel definitions

dofile(minetest.get_modpath("rp_jewels").."/jewels.lua")
dofile(minetest.get_modpath("rp_jewels").."/mapgen.lua")
dofile(minetest.get_modpath("rp_jewels").."/aliases.lua")
