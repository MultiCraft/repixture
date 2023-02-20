
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
			local magno_pos = vector.new(x, 0, z)
			local check_pos = vector.new(pos.x, 0, pos.z)
			local vdir = vector.direction(magno_pos, check_pos)
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

		-- Cycle through all inventory slots
		for i = 1, inv:get_size("main") do
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
local node_imgs = {
	[0] = "rp_nav_compass_0.png",
	"rp_nav_compass_1.png",
	"rp_nav_compass_0.png^[transformR270",
	"rp_nav_compass_1.png^[transformR270",
	"rp_nav_compass_0.png^[transformR180",
	"rp_nav_compass_1.png^[transformR180",
	"rp_nav_compass_0.png^[transformR90",
	"rp_nav_compass_1.png^[transformR90",
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
local node_imgs_magno = {
	[0] = "rp_nav_magnocompass_0.png",
	"rp_nav_magnocompass_1.png",
	"rp_nav_magnocompass_0.png^[transformR270",
	"rp_nav_magnocompass_1.png^[transformR270",
	"rp_nav_magnocompass_0.png^[transformR180",
	"rp_nav_magnocompass_1.png^[transformR180",
	"rp_nav_magnocompass_0.png^[transformR90",
	"rp_nav_magnocompass_1.png^[transformR90",
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

local compass_node_box = {
      type = "fixed",
      fixed = {
	      {-5/16, -0.5, -4/16, 5/16, -7/16, 4/16},
	      {-4/16, -0.5, 4/16, 4/16, -7/16, 5/16},
	      {-4/16, -0.5, -5/16, 4/16, -7/16, -4/16},
      },
}
local compass_selection_box = {
	type = "fixed",
	fixed = {
		{-5/16, -0.5, -5/16, 5/16, -7/16, 5/16},
	},
}

for c=0,7 do
	local magnetize_on_place = function(itemstack, placer, pointed_thing)
		local handle_itemstack = itemstack
		local is_magno = minetest.get_item_group(itemstack:get_name(), "nav_compass") == 2
		if pointed_thing.type == "node" then
			-- Change the itemstack for node placement so the correct
			-- compass orientation is shown. Important for the rp_itemshow mod
			local nodepos = pointed_thing.under
			local node = minetest.get_node(nodepos)
			-- If this group is set, compass needle always faces upwards
			if minetest.get_item_group(node.name, "uses_canonical_compass") == 1 then
				if is_magno then
					handle_itemstack:set_name("rp_nav:magnocompass_0")
				else
					handle_itemstack:set_name("rp_nav:compass_0")
				end
			-- Otherwise, adjust the compass needle so it shows to the correct direction
			else
				local nodeyaw = 0
				-- If this group is set, calculate the node's "yaw" and use that
				-- for the placed magnocompass
				if minetest.get_item_group(node.name, "special_magnocompass_place_handling") == 1 then
					local nodedef = minetest.registered_nodes[node.name]
					if nodedef and (nodedef.paramtype2 == "wallmounted" or nodedef.paramtype2 == "colorwallmounted") then
						nodeyaw = minetest.dir_to_yaw(minetest.wallmounted_to_dir(node.param2))
					elseif nodedef and (nodedef.paramtype2 == "facedir" or nodedef.paramtype2 == "colorfacedir") then
						nodeyaw = minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2))
					end
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
		-- (skip if 'sneak' key is pressed)
		local check_magnet = true
		if placer and placer:is_player() then
			local ctrl = placer:get_player_control()
			if ctrl.sneak then
				check_magnet = false
			end
		end

		if check_magnet then
			local nodepos = pointed_thing.under
			local node = minetest.get_node(nodepos)
			-- demagnetize compass at magnetic node
			if minetest.get_item_group(node.name, "magnetic") > 0 then
				itemstack = nav.magnetize_compass(itemstack, nodepos, placer:get_pos(), placer)
				return itemstack
			-- demagnetize magnocompass at "unmagnetic" node
			elseif is_magno and minetest.get_item_group(node.name, "unmagnetic") > 0 then
				itemstack = nav.demagnetize_compass(itemstack, placer:get_pos())
				return itemstack
			end
		end

		-- Place compass as node

		local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
		if place_in == nil then
			return itemstack
		end

		-- Check protection
		if minetest.is_protected(place_in, placer:get_player_name()) and
				not minetest.check_player_privs(placer, "protection_bypass") then
			minetest.record_protection_violation(pos, placer:get_player_name())
			return itemstack
		end

		local place_item = handle_itemstack:get_name()
		local itemmeta = handle_itemstack:get_meta()
		local mx = itemmeta:get_int("magno_x")
		local my = itemmeta:get_int("magno_y")
		local mz = itemmeta:get_int("magno_z")
		if is_magno then
			local mpos = vector.new(mx, 0, mz)
			local ppos = vector.new(place_in.x, 0, place_in.z)
			if vector.distance(mpos, ppos) < 0.1 then
				place_item = "rp_nav:magnocompass_rotating"
			end
		else
			place_item = "rp_nav:compass_0"
		end

		local node_floor = minetest.get_node(place_floor)
		local def_floor = minetest.registered_nodes[node_floor.name]
		if (not def_floor) or (not def_floor.walkable) or minetest.get_item_group(node_floor.name, "attached_node") == 1 then
			return itemstack
		end
		-- Place node
		minetest.set_node(place_in, {name = place_item})

		-- Set node metadata (magnocompass position)
		if is_magno then
			local nodemeta = minetest.get_meta(place_in)
			local itemmeta = handle_itemstack:get_meta()
			local mx = itemmeta:get_int("magno_x")
			local my = itemmeta:get_int("magno_y")
			local mz = itemmeta:get_int("magno_z")
			nodemeta:set_int("magno_x", mx)
			nodemeta:set_int("magno_y", my)
			nodemeta:set_int("magno_z", mz)
		end

		-- Node sound
		local idef = handle_itemstack:get_definition()
		if idef and idef.sounds then
                        local snd = idef.sounds.place
                        if snd then
                                minetest.sound_play(snd, {pos = place_in}, true)
                        end
                end

		-- Reduce item count
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end

	if c == 0 then
		-- Compass 0 points to North and is a placable node
		minetest.register_node(
		   "rp_nav:compass_0",
		   {
		      description = d,
		      _tt_help = t,
		      _rp_canonical_item = "rp_nav:compass_0",

		      drawtype = "nodebox",
		      walkable = false,
		      node_box = compass_node_box,
		      selection_box = compass_selection_box,
		      paramtype = "light",
		      sunlight_propagates = true,
		      tiles = {
			      node_imgs[c],
			      "("..node_imgs[c]..")^[transformR180",
			      "rp_nav_compass_side.png",
		      },
		      use_texture_alpha = "clip",
		      sounds = rp_sounds.node_sound_defaults(),

		      inventory_image = inv_imgs[c],
		      wield_image = wield_imgs[c],

		      node_placement_prediction = "",
		      on_place = magnetize_on_place,
                      floodable = true,
                      on_flood = function(pos, oldnode, newnode)
                         minetest.add_item(pos, "rp_nav:compass_0")
                      end,

		      groups = {nav_compass = 1, tool=1, attached_node=1, dig_immediate=3 },
		      stack_max = 1,
		})
	else
		-- Compass 1 and higher points to the other cardinal directions.
		-- They aren't nodes since the placed compass must always
		-- point North.
		minetest.register_craftitem(
		   "rp_nav:compass_"..c,
		   {
		      description = d,
		      _tt_help = t,
		      _rp_canonical_item = "rp_nav:compass_0",

		      inventory_image = inv_imgs[c],
		      wield_image = wield_imgs[c],

		      on_place = magnetize_on_place,

                      floodable = true,
                      on_flood = function(pos, oldnode, newnode)
                         minetest.add_item(pos, "rp_nav:compass_0")
                      end,

		      groups = {nav_compass = 1, tool=1, not_in_creative_inventory = 1 },
		      stack_max = 1,
		})
	end

        local preserve_metadata_magnocompass = function(pos, oldnode, oldmeta, drops)
		for d=1, #drops do
			local item = drops[d]
			if minetest.get_item_group(item:get_name(), "nav_compass") == 2 then
				local mx = tonumber(oldmeta.magno_x) or 0
				local my = tonumber(oldmeta.magno_y) or 0
				local mz = tonumber(oldmeta.magno_z) or 0
				local itemmeta = item:get_meta()
				itemmeta:set_int("magno_x", mx)
				itemmeta:set_int("magno_y", my)
				itemmeta:set_int("magno_z", mz)
			end
		end
        end

	-- Magno compass, points to a position.
	-- Unlike the normal compass, all magnocompass directions are
	-- placable nodes since a magno compass might point to any position.
	minetest.register_node(
	   "rp_nav:magnocompass_"..c,
	   {
	      description = dm,
	      _tt_help = tm,
	      _rp_canonical_item = "rp_nav:magnocompass_0",

              drawtype = "nodebox",
	      walkable = false,
	      node_box = compass_node_box,
	      selection_box = compass_selection_box,
              paramtype = "light",
              sunlight_propagates = true,
              tiles = {
                      node_imgs_magno[c],
		      "("..node_imgs_magno[c]..")^[transformR180",
		      "rp_nav_magnocompass_side.png",
              },
              use_texture_alpha = "clip",
	      sounds = rp_sounds.node_sound_defaults(),

	      inventory_image = inv_imgs_magno[c],
	      wield_image = wield_imgs_magno[c],

	      node_placement_prediction = "",
	      on_place = magnetize_on_place,

	      drop = "rp_nav:magnocompass_0",
	      floodable = true,
	      on_flood = function(pos, oldnode, newnode)
		      minetest.add_item(pos, "rp_nav:compass_0")
	      end,

              preserve_metadata = preserve_metadata_magnocompass,

	      groups = {nav_compass = 2, tool=1, attached_node=1, dig_immediate=3, not_in_creative_inventory = 1 },
	      stack_max = 1,
	})

	-- Special magnocompass node if it is exactly (or nearly exactly) placed
	-- at the magnetized X/Z position. The needle rotates in this special case.
	minetest.register_node(
	   "rp_nav:magnocompass_rotating",
	   {
	      _rp_canonical_item = "rp_nav:magnocompass_0",

              drawtype = "nodebox",
	      walkable = false,
	      node_box = compass_node_box,
	      selection_box = compass_selection_box,
              paramtype = "light",
              sunlight_propagates = true,
	      -- The rotating needle is a simple animation
              tiles = {
                      {
                         name="rp_nav_magnocompass_rotating.png",
                         animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.6 }
                      },
                      {
                         name="rp_nav_magnocompass_rotating_below.png",
                         animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 1.6 }
                      },
		      "rp_nav_magnocompass_side.png",
              },
              use_texture_alpha = "clip",
	      sounds = rp_sounds.node_sound_defaults(),

	      inventory_image = "rp_nav_magnocompass_inventory_0.png",
	      wield_image = "rp_nav_magnocompass_inventory_0.png",

	      drop = "rp_nav:magnocompass_0",
	      preserve_metadata = preserve_metadata_magnocompass,

	      floodable = true,
	      on_flood = function(pos, oldnode, newnode)
		      minetest.add_item(pos, "rp_nav:compass_0")
	      end,


	      groups = {nav_compass = 2, tool=1, attached_node=1, dig_immediate=3, not_in_creative_inventory=1 },
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
   -- REFERENCE ACHIEVEMENT 5
   "true_navigator_v2",
   {
      title = S("True Navigator"),
      description = S("Magnetize a compass."),
      times = 1,
      item_icon = "rp_nav:magnocompass",
      difficulty = 5,
})

minetest.register_alias("nav:compass", "rp_nav:compass_0")
for i=0, 7 do
	minetest.register_alias("nav:compass_"..i, "rp_nav:compass_"..i)
end
