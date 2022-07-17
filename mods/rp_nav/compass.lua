
--
-- Compass handling
--
local S = minetest.get_translator("rp_nav")

local wield_image_0 = "nav_compass_inventory_0.png"
local wield_image_1 = "nav_compass_inventory_1.png"
local magno_wield_image_0 = "rp_nav_magnocompass_inventory_0.png"
local magno_wield_image_1 = "rp_nav_magnocompass_inventory_1.png"

local yaw_to_compass_dir = function(yaw)
      local dir = math.floor(((yaw / math.pi) * 4) + 0.5)

      if dir < 0 then
	 dir = dir + 8
      end

      if dir >= 8 then
	 dir = 0
      end
      return dir
end

local update_compass_itemstack = function(itemstack, pos, lookyaw)
	local item = minetest.registered_items[itemstack:get_name()]
	local new_itemstack = ItemStack(itemstack)
	local changed = false

	local lookdir = yaw_to_compass_dir(lookyaw)

	if item ~= nil then
		-- normal compass
		if item.groups.nav_compass == 1 then
			new_itemstack:set_name("rp_nav:compass_"..lookdir)
			changed = true
		-- magnocompass
		elseif item.groups.nav_compass == 2 then
			local meta = itemstack:get_meta()
			local x, y, z = meta:get_int("magno_x"), meta:get_int("magno_y"), meta:get_int("magno_z")
			if not x or not y or not z then
			-- Fallback pos
				x, y, z = 0, 0, 0
			end
			local magno_pos = vector.new(x,y,z)
			local vdir = vector.direction(magno_pos, pos)
			local magnoyaw = minetest.dir_to_yaw(vdir)
			magnoyaw = (math.pi - magnoyaw + lookyaw) % (math.pi*2)
			local dir = yaw_to_compass_dir(magnoyaw)
			new_itemstack:set_name("rp_nav:magnocompass_"..dir)
			changed = true
		end
	end
	return new_itemstack, changed
end

local function on_globalstep(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local inv = player:get_inventory()

		local yaw = player:get_look_horizontal()
		local pos = player:get_pos()

		-- Cycle through hotbar slots
		for i = 1, 8 do
			local itemstack = inv:get_stack("main", i)
			local changed
			itemstack, changed = update_compass_itemstack(itemstack, pos, yaw)
			if changed then
				inv:set_stack("main", i, itemstack)
			end
		end
	end
end

minetest.register_globalstep(on_globalstep)

-- Items
local inv_imgs = {
	[0] = "nav_compass_inventory_0.png",
	"nav_compass_inventory_1.png",
	"nav_compass_inventory_0.png^[transformR270",
	"nav_compass_inventory_1.png^[transformR270",
	"nav_compass_inventory_0.png^[transformR180",
	"nav_compass_inventory_1.png^[transformR180",
	"nav_compass_inventory_0.png^[transformR90",
	"nav_compass_inventory_1.png^[transformR90",
}
local wield_imgs = {
	[0] = wield_image_0,
	wield_image_1,
	wield_image_0 .. "^[transformR270",
	wield_image_1 .. "^[transformR270",
	wield_image_0 .. "^[transformR180",
	wield_image_1 .. "^[transformR180",
	wield_image_0 .. "^[transformR90",
	wield_image_1 .. "^[transformR90",
}
local inv_imgs_magno = {
	[0] = "rp_nav_magnocompass_inventory_0.png",
	"rp_nav_magnocompass_inventory_1.png",
	"rp_nav_magnocompass_inventory_0.png^[transformR270",
	"rp_nav_magnocompass_inventory_1.png^[transformR270",
	"rp_nav_magnocompass_inventory_0.png^[transformR180",
	"rp_nav_magnocompass_inventory_1.png^[transformR180",
	"rp_nav_magnocompass_inventory_0.png^[transformR90",
	"rp_nav_magnocompass_inventory_1.png^[transformR90",
}
local wield_imgs_magno = {
	[0] = magno_wield_image_0,
	magno_wield_image_1,
	magno_wield_image_0 .. "^[transformR270",
	magno_wield_image_1 .. "^[transformR270",
	magno_wield_image_0 .. "^[transformR180",
	magno_wield_image_1 .. "^[transformR180",
	magno_wield_image_0 .. "^[transformR90",
	magno_wield_image_1 .. "^[transformR90",
}

local d = S("Compass")
local t = S("It points to the North") .. "\n" .. S("Can be magnetized at magnetic blocks")
local dm = S("Magno Compass")
local tm = S("It points to a position") .. "\n" .. S("Can be demagnetized at unmagnetic blocks")

-- Magnetize the compass item (`itemstack`) to point at position `magnet_pos`,
-- playing a confirm sound at `sound_pos`.
-- `achievement_player` is a player object if there is an associated player. It is used
-- to trigger the "True Navigator" achievement.
-- `itemstack` MUST be a compass.
-- Returns the itemstack of the magnetized compass.
nav.magnetize_compass = function(itemstack, magnet_pos, sound_pos, achievement_player)
	itemstack:set_name("rp_nav:magnocompass_0")
	local meta = itemstack:get_meta()
	meta:set_int("magno_x", magnet_pos.x)
	meta:set_int("magno_y", magnet_pos.y)
	meta:set_int("magno_z", magnet_pos.z)
	minetest.sound_play({name="rp_nav_magnetize_compass", gain=0.2}, {pos=sound_pos}, true)
	if achievement_player then
		achievements.trigger_achievement(achievement_player, "true_navigator_v2")
	end
	return itemstack
end

-- Demagnetize the compass item (`itemstack`) to point at North again,
-- playing a confirm sound at `sound_pos`.
-- Returns the itemstack of the demagnetized compass.
nav.demagnetize_compass = function(itemstack, sound_pos)
	local is_magnocompass = minetest.get_item_group(itemstack:get_name(), "nav_compass") == 2
	if not is_magnocompass then
		-- Don’t demagnetize if not magnocompass
		return itemstack
	end
	itemstack:set_name("rp_nav:compass_0")
	local meta = itemstack:get_meta()
	meta:set_string("magno_x", "")
	meta:set_string("magno_y", "")
	meta:set_string("magno_z", "")
	minetest.sound_play({name="rp_nav_demagnetize_compass", gain=0.2}, {pos=sound_pos}, true)
	return itemstack
end

for c=0,7 do
	local magnetize_on_place = function(itemstack, placer, pointed_thing)
		local handle_itemstack = itemstack
		if pointed_thing.type == "node" then
			-- Change the itemstack for node placement so the correct
			-- compass orientation is shown. Important for the rp_itemshow mod
			local nodepos = pointed_thing.under
			local node = minetest.get_node(nodepos)
			-- If this group is set, compass needle always faces upwards
			if minetest.get_item_group(node.name, "uses_canonical_compass") == 1 then
				if minetest.get_item_group(itemstack:get_name(), "nav_compass") == 1 then
					handle_itemstack:set_name("rp_nav:compass_0")
				elseif minetest.get_item_group(itemstack:get_name(), "nav_compass") == 2 then
					handle_itemstack:set_name("rp_nav:magnocompass_0")
				end
			-- Otherwise, adjust the compass needle so it shows to the correct direction
			else
				local nodedef = minetest.registered_nodes[node.name]
				local nodeyaw = 0
				if nodedef and nodedef.paramtype2 == "wallmounted" or nodedef.paramtype2 == "colorwallmounted" then
					nodeyaw = minetest.dir_to_yaw(minetest.wallmounted_to_dir(node.param2))
				elseif nodedef and nodedef.paramtype2 == "facedir" or nodedef.paramtype2 == "colorfacedir" then
					nodeyaw = minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2))
				end
				-- Special case: Item frame. Add a little offset for nodepos as
				-- the compass entity is at the side of the node rather than the center.
				if node.name == "rp_itemshow:frame" then
					local nodedir = minetest.facedir_to_dir(node.param2)
					local offset = 7/16
					nodepos = vector.add(nodepos, vector.multiply(nodedir, offset))
				end
				handle_itemstack = update_compass_itemstack(itemstack, nodepos, nodeyaw)
			end
		end
                -- Handle pointed node handlers
                local handled, handled_itemstack = util.on_place_pointed_node_handler(handle_itemstack, placer, pointed_thing)
                if handled then
			return handled_itemstack
                end

		-- Magnetize compass when placing on a magnetic node
		local nodepos = pointed_thing.under
		local node = minetest.get_node(nodepos)
		-- demagnetize compass at magnetic node
		if minetest.get_item_group(node.name, "magnetic") > 0 then
			itemstack = nav.magnetize_compass(itemstack, nodepos, placer:get_pos(), placer)
			return itemstack
		-- demagnetize magnocompass at "unmagnetic" node
		elseif minetest.get_item_group(itemstack:get_name(), "nav_compass") == 2 and minetest.get_item_group(node.name, "unmagnetic") > 0 then
			itemstack = nav.demagnetize_compass(itemstack, placer:get_pos())
			return itemstack
		end
	end

	local not_creative
	if c ~= 0 then
		not_creative = 1
	end
	minetest.register_craftitem(
	   "rp_nav:compass_"..c,
	   {
	      description = d,
	      _tt_help = t,
	      _rp_canonical_item = "rp_nav:compass_0",

	      inventory_image = inv_imgs[c],
	      wield_image = wield_imgs[c],

	      on_place = magnetize_on_place,

	      groups = {nav_compass = 1, tool=1, not_in_creative_inventory = not_creative },
	      stack_max = 1,
	})

	-- Magno compass, points to a position
	not_creative = 1
	minetest.register_craftitem(
	   "rp_nav:magnocompass_"..c,
	   {
	      description = dm,
	      _tt_help = tm,
	      _rp_canonical_item = "rp_nav:magnocompass_0",

	      inventory_image = inv_imgs_magno[c],
	      wield_image = wield_imgs_magno[c],

	      on_place = magnetize_on_place,

	      groups = {nav_compass = 2, tool=1, not_in_creative_inventory = not_creative },
	      stack_max = 1,
	})

end

minetest.register_alias("rp_nav:compass", "rp_nav:compass_0")
minetest.register_alias("rp_nav:magnocompass", "rp_nav:magnocompass_0")

-- Crafting

crafting.register_craft(
   {
      output = "rp_nav:compass",
      items = {
         "rp_default:ingot_steel 4",
         "rp_default:stick",
      }
})

-- Achievements

achievements.register_achievement(
   "true_navigator_v2",
   {
      title = S("True Navigator"),
      description = S("Magnetize a compass."),
      times = 1,
      item_icon = "rp_nav:magnocompass",
})

minetest.register_alias("nav:compass", "rp_nav:compass_0")
for i=0, 7 do
	minetest.register_alias("nav:compass_"..i, "rp_nav:compass_"..i)
end
