
--
-- Map handling
--

local S = minetest.get_translator("rp_nav")

-- Based on Minetest Game's map mod, licensed under MIT License.

nav.map = {}

-- Update HUD flags
-- Global to allow overriding

function nav.map.update_hud_flags(player)
	local creative_enabled = minetest.is_creative_enabled(player:get_player_name())

	local minimap_enabled = creative_enabled or
		player:get_inventory():contains_item("main", "rp_nav:map")
	local radar_enabled = creative_enabled

	player:hud_set_flags({
		minimap = minimap_enabled,
		minimap_radar = radar_enabled
	})
end


-- Set HUD flags 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	nav.map.update_hud_flags(player)
end)

-- Update HUD flags on inventory change. Sadly, this function is not exhaustive and doesn't capture all
-- inventory changes (such as changes by Lua).

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" then
		local stack_from = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		local stack_to = inventory:get_stack(inventory_info.to_list, inventory_info.to_index)
		if stack_from:get_name() == "rp_nav:map" or stack_to:get_name() == "rp_nav:map" then
			nav.map.update_hud_flags(player)
		end
	elseif action == "put" or action == "take" then
		if inventory_info.stack:get_name() == "rp_nav:map" then
			nav.map.update_hud_flags(player)
		end
	end
end)

-- Cyclic update of HUD flags. Required because register_on_player_inventory_action does not
-- capture all changes.

local function cyclic_update()
	for _, player in ipairs(minetest.get_connected_players()) do
		nav.map.update_hud_flags(player)
	end
	minetest.after(5.3, cyclic_update)
end

minetest.after(5.3, cyclic_update)


-- Items

minetest.register_craftitem(
   "rp_nav:map",
   {
      description = S("Map"),
      _tt_help = S("Keep this in your inventory and view the map with the 'minimap' key"),
      inventory_image = "nav_inventory.png",
      wield_image = "nav_inventory.png",
      stack_max = 1,
      groups = { tool = 1 },
      sound = {},
      on_use = function(itemstack, user, pointed_thing)
          minetest.chat_send_player(user:get_player_name(), minetest.colorize("#FFFF00", S("Use the minimap key to show the map.")))
          nav.map.update_hud_flags(user)
      end,
})

-- Crafting

crafting.register_craft(
   {
      output = "rp_nav:map",
      items = {
         "rp_default:stick 6",
         "rp_default:paper 3",
      }
})


-- Achievements

achievements.register_achievement(
   "navigator",
   {
      title = S("Navigator"),
      description = S("Craft a map."),
      times = 1,
      craftitem = "rp_nav:map",
      difficulty = 2.5,
})

minetest.register_alias("nav:map", "rp_nav:map")
