
--
-- Map handling
--

local S = minetest.get_translator("nav")

-- Based on Minetest Game's map mod, licensed under MIT License.

local map = {}

-- Cache creative mode setting

local creative_mode_cache = minetest.settings:get_bool("creative_mode")


-- Update HUD flags
-- Global to allow overriding

function map.update_hud_flags(player)
	local creative_enabled =
		(minetest.global_exists("creative") and creative.is_enabled_for(player:get_player_name())) or
		creative_mode_cache

	local minimap_enabled = creative_enabled or
		player:get_inventory():contains_item("main", "nav:map")
	local radar_enabled = creative_enabled

	player:hud_set_flags({
		minimap = minimap_enabled,
		minimap_radar = radar_enabled
	})
end


-- Set HUD flags 'on joinplayer'

minetest.register_on_joinplayer(function(player)
	map.update_hud_flags(player)
end)


-- Cyclic update of HUD flags

local function cyclic_update()
	for _, player in ipairs(minetest.get_connected_players()) do
		map.update_hud_flags(player)
	end
	minetest.after(5.3, cyclic_update)
end

minetest.after(5.3, cyclic_update)


-- Items

minetest.register_craftitem(
   "nav:map",
   {
      description = S("Map"),
      inventory_image = "nav_inventory.png",
      wield_image = "nav_inventory.png",
      stack_max = 1,
      on_use = function(itemstack, user, pointed_thing)
          map.update_hud_flags(user)
      end,
})

-- Crafting

crafting.register_craft(
   {
      output = "nav:map",
      items = {
         "default:stick 6",
         "default:paper 3",
      }
})


-- Achievements

achievements.register_achievement(
   "navigator",
   {
      title = S("Navigator"),
      description = S("Craft a map"),
      times = 1,
      craftitem = "nav:map",
})

default.log("map", "loaded")
