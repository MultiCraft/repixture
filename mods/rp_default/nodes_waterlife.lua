local S = minetest.get_translator("rp_default")

local ALGA_BLOCK_SLIPPERY = 2 -- Slippery level of alga block

local AIRWEED_ADD_BREATH = 1 -- How much breath points an airweed restores by a single use

-- Airweed recharge times on different nodes, in seconds
local AIRWEED_RECHARGE_DIRT = 10
local AIRWEED_RECHARGE_SWAMP_DIRT = 15
local AIRWEED_RECHARGE_DRY_DIRT = 12.5
local AIRWEED_RECHARGE_GRAVEL = 5
local AIRWEED_RECHARGE_SAND = 7.5

local function get_sea_plant_on_place(base, paramtype2)
return function(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer then
           return itemstack
	end

        -- Boilerplate to handle pointed node handlers
        local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
        if handled then
           return handled_itemstack
        end

	local player_name = placer:get_player_name()
        local undernode = minetest.get_node(pointed_thing.under)
	local underdef = minetest.registered_nodes[undernode.name]
	-- Grow leveled plantlike_rooted node by 1 "node length"
	if paramtype2 == "leveled" and underdef and underdef.paramtype2 == "leveled" and pointed_thing.under.y < pointed_thing.above.y and pointed_thing.under.x == pointed_thing.above.x and pointed_thing.under.z == pointed_thing.above.z then
           if minetest.is_protected(pointed_thing.under, player_name) or
                 minetest.is_protected(pointed_thing.above, player_name) then
              minetest.record_protection_violation(pointed_thing.under, player_name)
              return itemstack
           end
           local grown, top = default.grow_underwater_leveled_plant(pointed_thing.under, undernode)
           if grown then
              local snd = underdef.sounds.place
              if snd and top then
                 minetest.sound_play(snd, {pos = top}, true)
              end
              if not minetest.is_creative_enabled(player_name) then
                 itemstack:take_item()
              end
           end
           return itemstack
        end

        -- Find position to place plant at
        local place_in, place_floor = util.pointed_thing_to_place_pos(pointed_thing)
        if place_in == nil then
           return itemstack
        end
        local floornode = minetest.get_node(place_floor)

        -- Check protection
        if minetest.is_protected(place_in, player_name) or
              minetest.is_protected(place_floor, player_name) then
           minetest.record_protection_violation(place_floor, player_name)
           return itemstack
        end

	local node_floor = minetest.get_node(place_floor)
	local def_floor = minetest.registered_nodes[node_floor.name]

	if not util.is_water_source_or_waterfall(place_in) then
		return itemstack
	end

	if node_floor.name == "rp_default:dirt" then
		node_floor.name = "rp_default:"..base.."_on_dirt"
	elseif node_floor.name == "rp_default:swamp_dirt" then
		node_floor.name = "rp_default:"..base.."_on_swamp_dirt"
	elseif node_floor.name == "rp_default:sand" then
		node_floor.name = "rp_default:"..base.."_on_sand"
	elseif node_floor.name == "rp_default:fertilized_dirt" then
		node_floor.name = "rp_default:"..base.."_on_fertilized_dirt"
	elseif node_floor.name == "rp_default:fertilized_swamp_dirt" then
		node_floor.name = "rp_default:"..base.."_on_fertilized_swamp_dirt"
	elseif node_floor.name == "rp_default:fertilized_sand" then
		node_floor.name = "rp_default:"..base.."_on_fertilized_sand"
	elseif base == "alga" and node_floor.name == "rp_default:alga_block" then
		node_floor.name = "rp_default:"..base.."_on_alga_block"
	elseif base == "airweed_inert" and node_floor.name == "rp_default:gravel" then
		node_floor.name = "rp_default:"..base.."_on_gravel"
	elseif base == "airweed_inert" and node_floor.name == "rp_default:dry_dirt" then
		node_floor.name = "rp_default:"..base.."_on_dry_dirt"
	elseif base == "airweed_inert" and node_floor.name == "rp_default:fertilized_dry_dirt" then
		node_floor.name = "rp_default:"..base.."_on_fertilized_dry_dirt"
	else
		return itemstack
	end

	def_floor = minetest.registered_nodes[node_floor.name]
	if def_floor and def_floor.place_param2 then
		node_floor.param2 = def_floor.place_param2
	end

	minetest.set_node(place_floor, node_floor)
        local snd = def_floor.sounds.place
        if snd then
           minetest.sound_play(snd, {pos = place_in}, true)
        end
	if not minetest.is_creative_enabled(player_name) then
		itemstack:take_item()
	end

	return itemstack
end
end

-- Seagrass


local register_seagrass = function(plant_id, selection_box, drop, append, basenode, basenode_tiles, _on_trim, fertilize_info)
   local groups = {snappy = 2, dig_immediate = 3, seagrass = 1, grass = 1, green_grass = 1, plant = 1, rooted_plant = 1}
   local _fertilized_node
   local def_base = minetest.registered_nodes[basenode]
   if minetest.get_item_group(basenode, "fall_damage_add_percent") ~= 0 then
      groups.fall_damage_add_percent = def_base.groups.fall_damage_add_percent
   end
   if fertilize_info == true then
      groups.plantable_fertilizer = 1
   elseif type(fertilize_info) == "string" then
      _fertilized_node = "rp_default:"..plant_id.."_on_"..fertilize_info
   end
   minetest.register_node(
      "rp_default:"..plant_id.."_on_"..append,
      {
         drawtype = "plantlike_rooted",
         paramtype = "light",
	 selection_box = selection_box,
         collision_box = {
            type = "regular",
         },
         visual_scale = 1.14,
         tiles = basenode_tiles,
         special_tiles = {"rp_default_"..plant_id.."_clump.png"},
         inventory_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_"..plant_id..".png",
         wield_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_"..plant_id..".png",
         waving = 1,
         walkable = true,
         groups = groups,
         sounds = rp_sounds.node_sound_leaves_defaults(),
	 node_dig_prediction = basenode,
         after_destruct = function(pos)
            local newnode = minetest.get_node(pos)
            if minetest.get_item_group(newnode.name, "seagrass") == 0 then
               minetest.set_node(pos, {name=basenode})
               minetest.check_for_falling(pos)
            end
         end,
	 _on_trim = _on_trim,
	 _fertilized_node = _fertilized_node,
	 _waterplant_base_node = basenode,
	 drop = drop,
   })
end
local register_seagrass_on = function(append, basenode, basenode_tiles, fertilize_info)
   register_seagrass("seagrass",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 17/16, 0.5},
      }}, "rp_default:seagrass", append, basenode, basenode_tiles, nil, fertilize_info)

    -- Trim tall sea grass with shears
    local _on_trim = function(pos, node, player, itemstack)
       local param2 = node.param2
       -- This turns it to a normal sea grass clump and drops one bonus sea grass clump
       minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
       minetest.set_node(pos, {name = "rp_default:seagrass_on_"..append, param2 = param2})

       local dir = vector.multiply(minetest.wallmounted_to_dir(param2), -1)
       local droppos = vector.add(pos, dir)
       item_drop.drop_item(droppos, "rp_default:seagrass")

       -- Add wear
       if not minetest.is_creative_enabled(player:get_player_name()) then
          local def = itemstack:get_definition()
          itemstack:add_wear_by_uses(def.tool_capabilities.groupcaps.snappy.uses)
       end
       return itemstack
   end
   register_seagrass("tall_seagrass",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 1.5, 0.5},
      }}, "rp_default:seagrass", append, basenode, basenode_tiles, _on_trim, fertilize_info)

end

minetest.register_craftitem("rp_default:tall_seagrass", {
   description = S("Tall Seagrass Clump"),
   _tt_help = S("Grows underwater on dirt, swamp dirt or sand"),
   inventory_image = "rp_default_tall_seagrass_clump_inventory.png",
   wield_image = "rp_default_tall_seagrass_clump_inventory.png",
   on_place = get_sea_plant_on_place("tall_seagrass", "wallmounted"),
   groups = { node = 1, green_grass = 1, seagrass = 1, plant = 1, grass = 1 },
})
minetest.register_craftitem("rp_default:seagrass", {
   description = S("Seagrass Clump"),
   _tt_help = S("Grows underwater on dirt, swamp dirt or sand"),
   inventory_image = "rp_default_seagrass_clump_inventory.png",
   wield_image = "rp_default_seagrass_clump_inventory.png",
   on_place = get_sea_plant_on_place("seagrass", "wallmounted"),
   groups = { node = 1, green_grass = 1, seagrass = 1, plant = 1, grass = 1 },
})

local waterplant_base_tiles = function(basetexture, plant_id, is_fertilized)
	local fert = basetexture
	if is_fertilized then
		fert = basetexture.."^default_fertilizer.png"
	end
	return {
		{name=fert,backface_culling=true},
		{name=basetexture.."^rp_default_plantlike_rooted_"..plant_id.."_roots.png",backface_culling=true},
		{name=basetexture,backface_culling=true},
	}
end

register_seagrass_on("dirt", "rp_default:dirt", waterplant_base_tiles("default_dirt.png", "seagrass", false), "fertilized_dirt")
register_seagrass_on("swamp_dirt", "rp_default:swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "seagrass", false), "fertilized_swamp_dirt")
register_seagrass_on("sand", "rp_default:sand", waterplant_base_tiles("default_sand.png", "seagrass", false), "fertilized_sand")
register_seagrass_on("fertilized_dirt", "rp_default:fertilized_dirt", waterplant_base_tiles("default_dirt.png", "seagrass", true), true)
register_seagrass_on("fertilized_swamp_dirt", "rp_default:fertilized_swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "seagrass", true), true)
register_seagrass_on("fertilized_sand", "rp_default:fertilized_sand", waterplant_base_tiles("default_sand.png", "seagrass", true), true)


local register_airweed = function(plant_id, selection_box, drop, append, basenode, basenode_tiles, on_rightclick, on_timer, on_construct, fertilize_info, is_inert, recharge_time)
   local groups = {snappy = 2, dig_immediate = 3, airweed = 1, plant = 1, rooted_plant = 1}
   if is_inert then
      groups.airweed_inert = 1
   end

   local _fertilized_node
   local def_base = minetest.registered_nodes[basenode]
   if minetest.get_item_group(basenode, "fall_damage_add_percent") ~= 0 then
      groups.fall_damage_add_percent = def_base.groups.fall_damage_add_percent
   end
   if fertilize_info == true then
      groups.plantable_fertilizer = 1
   elseif type(fertilize_info) == "string" then
      _fertilized_node = "rp_default:"..plant_id.."_on_"..fertilize_info
   end
   minetest.register_node(
      "rp_default:"..plant_id.."_on_"..append,
      {
         drawtype = "plantlike_rooted",
         paramtype = "light",
	 selection_box = selection_box,
         collision_box = {
            type = "regular",
         },
         visual_scale = 1.14,
         tiles = basenode_tiles,
         special_tiles = {"rp_default_"..plant_id.."_clump.png"},
         inventory_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_"..plant_id..".png",
         wield_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_"..plant_id..".png",
         waving = 1,
         walkable = true,
         groups = groups,
         sounds = rp_sounds.node_sound_leaves_defaults(),
	 node_dig_prediction = basenode,
	 on_rightclick = on_rightclick,
	 on_timer = on_timer,
	 on_construct = on_construct,
         after_destruct = function(pos)
            local newnode = minetest.get_node(pos)
            if minetest.get_item_group(newnode.name, "airweed") == 0 then
               minetest.set_node(pos, {name=basenode})
               minetest.check_for_falling(pos)
            end
         end,
	 _fertilized_node = _fertilized_node,
	 _waterplant_base_node = basenode,
	 _airweed_recharge_time = recharge_time,
	 drop = drop,
   })
end
local register_airweed_on = function(append, basenode, basenode_tiles, fertilize_info, recharge_time)

   local on_timer = function(pos)
      local node = minetest.get_node(vector.add(pos, vector.new(0,1,0)))
      if minetest.get_item_group(node.name, "water") == 0 then
         -- Restart timer if airweed is not in water
         default.start_inert_airweed_timer(pos)
         return
      end

      -- Airweed is ready again
      minetest.set_node(pos, {name="rp_default:airweed_on_"..append})
   end

   local on_construct = function(pos)
      default.start_inert_airweed_timer(pos)
   end

   -- on_rightclick for "inert" airweed: Start timer
   -- in case the airweed timer was not started before
   -- for some reason. This acts as a simple fallback,
   -- just in case.
   local on_rightclick_inert = function(pos)
      default.start_inert_airweed_timer(pos)
   end

   -- on_rightclick for "charged" airweed: Increase breath of clicker
   -- and players nearby. Also make airweed inert
   local on_rightclick_charged = function(pos, node, clicker, itemstack, pointed_thing)
      -- First check if the *plant* was rightclicked (the base node does not count)
      local face_pos
      if pointed_thing and clicker and clicker:is_player() then
         face_pos = minetest.pointed_thing_to_face_pos(clicker, pointed_thing)
         if face_pos and (face_pos.y < pos.y + 0.5) then
	    -- The base node was rightclicked: Do nothing
            return
         end
      end

      local bubble_pos = {x=pos.x,y=pos.y+1,z=pos.z}

      -- No bubbles if the plant is not in water
      local bnode = minetest.get_node(bubble_pos)
      if minetest.get_item_group(bnode.name, "water") == 0 then
         return
      end

      -- Effect particles + sound
      minetest.add_particlespawner({
         amount = 20,
         time = 0.1,
         pos = {
            min = {
               x = bubble_pos.x - 0.4,
               y = bubble_pos.y,
               z = bubble_pos.z - 0.4
            },
            max = {
               x = bubble_pos.x + 0.4,
               y = bubble_pos.y + 0.2,
               z = bubble_pos.z + 0.4
            },
         },
         vel = {
            min = {x = -1.5, y = 0, z = -1.5},
            max = {x = 1.5, y = 0, z = 1.5},
         },
         acc = {
            min = {x = -0.5, y = 4, z = -0.5},
            max = {x = 0.5, y = 1, z = 0.5},
         },
	 drag = { x = 0.7, y = 0, z = 0.7 },
         exptime = {min=0.3,max=0.8},
         size = {min=0.7, max=2.4},
         texture = {
            name = "bubble.png",
            alpha_tween = { 1, 0, start = 0.75 }
         },
      })
      minetest.sound_play({name = "rp_default_airweed_bubbles", gain = 0.6}, {pos = bubble_pos}, true)

      -- Set airweed inert (in which it can't release bubbles
      -- temporarily)
      minetest.set_node(pos, {name="rp_default:airweed_inert_on_"..append})

      -- Always increase breath of clicker
      if clicker and clicker:is_player() then
         clicker:set_breath(clicker:get_breath() + AIRWEED_ADD_BREATH)
      end

      -- Also increase breath of other players nearby
      -- TODO: Also mobs
      local min = vector.add(bubble_pos, vector.new(-1.5,-1,-1.5))
      local max = vector.add(bubble_pos, vector.new(1.5,1.5,1.5))
      local objs = minetest.get_objects_in_area(min, max)
      for o=1, #objs do
         local obj = objs[o]
         if obj:is_player() and obj ~= clicker then
            obj:set_breath(obj:get_breath() + AIRWEED_ADD_BREATH)
         end
      end
   end

   -- Inert airweed (bubbles not ready)
   register_airweed("airweed_inert",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 17/16, 0.5},
      }}, "rp_default:airweed_inert", append, basenode, basenode_tiles, on_rightclick_inert, on_timer, on_construct, fertilize_info, true, recharge_time)

   -- "charged" airweed (bubbles ready)
   register_airweed("airweed",
      { type = "fixed",
        fixed = {
           {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
           {-0.5, 0.5, -0.5, 0.5, 22/16, 0.5},
      }}, "rp_default:airweed_inert", append, basenode, basenode_tiles, on_rightclick_charged, nil, nil, fertilize_info, nil, recharge_time)
end

minetest.register_craftitem("rp_default:airweed_inert", {
   description = S("Airweed"),
   _tt_help = S("Gives back breath") .. "\n"..
      S("Grows underwater on any dirt, sand or gravel"),
   inventory_image = "rp_default_airweed_inert_clump_inventory.png",
   wield_image = "rp_default_airweed_inert_clump_inventory.png",
   on_place = get_sea_plant_on_place("airweed_inert", "wallmounted"),
   groups = { node = 1, airweed = 1, airweed_inert = 1, plant = 1 },
})

minetest.register_craftitem("rp_default:airweed", {
   description = S("Airweed (full)"),
   _tt_help = S("Gives back breath") .. "\n"..
      S("Grows underwater on any dirt, sand or gravel"),
   inventory_image = "rp_default_airweed_clump_inventory.png",
   wield_image = "rp_default_airweed_clump_inventory.png",
   on_place = get_sea_plant_on_place("airweed", "wallmounted"),
   groups = { node = 1, airweed = 1, plant = 1 },
})

register_airweed_on("dirt", "rp_default:dirt", waterplant_base_tiles("default_dirt.png", "airweed", false), "fertilized_dirt", AIRWEED_RECHARGE_DIRT)
register_airweed_on("swamp_dirt", "rp_default:swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "airweed", false), "fertilized_swamp_dirt", AIRWEED_RECHARGE_SWAMP_DIRT)
register_airweed_on("dry_dirt", "rp_default:dry_dirt", waterplant_base_tiles("default_dry_dirt.png", "airweed", false), "fertilized_dry_dirt", AIRWEED_RECHARGE_DRY_DIRT)
register_airweed_on("sand", "rp_default:sand", waterplant_base_tiles("default_sand.png", "airweed", false), "fertilized_sand", AIRWEED_RECHARGE_SAND)
register_airweed_on("gravel", "rp_default:gravel", waterplant_base_tiles("default_gravel.png", "airweed", false), false, AIRWEED_RECHARGE_GRAVEL)
register_airweed_on("fertilized_dirt", "rp_default:fertilized_dirt", waterplant_base_tiles("default_dirt.png", "airweed", true), true, AIRWEED_RECHARGE_DIRT)
register_airweed_on("fertilized_swamp_dirt", "rp_default:fertilized_swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "airweed", true), true, AIRWEED_RECHARGE_SWAMP_DIRT)
register_airweed_on("fertilized_sand", "rp_default:fertilized_sand", waterplant_base_tiles("default_sand.png", "airweed", true), true, AIRWEED_RECHARGE_SAND)
register_airweed_on("fertilized_dry_dirt", "rp_default:fertilized_dry_dirt", waterplant_base_tiles("default_dry_dirt.png", "airweed", true), true, AIRWEED_RECHARGE_DRY_DIRT)


-- Alga
local register_alga_on = function(append, basenode, basenode_tiles, max_height, fertilize_info)
   if not max_height then
      max_height = 15
   end
   local groups = {snappy = 2, dig_immediate = 3, alga = 1, plant = 1, rooted_plant = 1}
   local def_base = minetest.registered_nodes[basenode]
   if minetest.get_item_group(basenode, "fall_damage_add_percent") ~= 0 then
      groups.fall_damage_add_percent = def_base.groups.fall_damage_add_percent
   end
   local _fertilized_node, _unfertilized_node
   if fertilize_info == true then
      groups.plantable_fertilizer = 1
   elseif type(fertilize_info) == "string" then
      _fertilized_node = "rp_default:alga_on_"..fertilize_info
   end
   if basenode == "rp_default:alga_block" then
      groups.slippery = ALGA_BLOCK_SLIPPERY
   end
   minetest.register_node(
      "rp_default:alga_on_"..append,
      {
         drawtype = "plantlike_rooted",
         paramtype = "light",
	 selection_box = {
            type = "fixed",
	    fixed = {
               { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }, -- base
               { -6/16, 0.5, -6/16, 6/16, 1.5, 6/16 }, -- plant
	    },
	 },
         collision_box = {
            type = "regular",
         },
	 waving = 1,
	 paramtype2 = "leveled",
	 place_param2 = 16,
	 leveled_max = 16 * max_height,
         tiles = basenode_tiles,
         special_tiles = {{name="rp_default_alga.png", tileable_vertical=true}},
         inventory_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_alga.png",
         wield_image = "rp_default_plantlike_rooted_inv_"..append..".png^rp_default_plantlike_rooted_inv_alga.png",
         walkable = true,
         groups = groups,
         sounds = rp_sounds.node_sound_leaves_defaults(),
	 node_dig_prediction = basenode,
	 drop = "rp_default:alga",
         after_destruct = function(pos)
            local newnode = minetest.get_node(pos)
            if minetest.get_item_group(newnode.name, "alga") == 0 then
               minetest.set_node(pos, {name=basenode})
               minetest.check_for_falling(pos)
            end
         end,
	 on_dig = function(pos, node, digger)
            local dname = ""
            if digger:is_player() then
               dname = digger:get_player_name()
            end
            -- Check protection
            if minetest.is_protected(pos, digger:get_player_name()) and
                    not minetest.check_player_privs(digger, "protection_bypass") then
                minetest.record_protection_violation(pos, digger:get_player_name())
                return itemstack
            end
            local height = math.floor(node.param2 / 16)
	    -- Destroy alga
	    local def = minetest.registered_nodes[node.name]
	    node.name = def.node_dig_prediction
	    node.param2 = 0
	    minetest.set_node(pos, node)
	    -- Drop items
            if not minetest.is_creative_enabled(digger:get_player_name()) then
               for i=1, height do
	          local droppos = vector.new(pos.x, pos.y + i, pos.z)
                  item_drop.drop_item(droppos, "rp_default:alga")
               end
	    end
	    return true
	 end,
	 _on_trim = function(pos, node, player, itemstack)
            local param2 = node.param2
            if param2 <= 16 then
               return itemstack
            end
            local cut_height = math.floor((node.param2 - 16) / 16)
            -- This reduces the alga height
            minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = player:get_pos(), max_hear_distance = 8}, true)
            minetest.set_node(pos, {name=node.name, param2=16})

            -- Add wear
            if not minetest.is_creative_enabled(player:get_player_name()) then
               local def = itemstack:get_definition()
               itemstack:add_wear_by_uses(def.tool_capabilities.groupcaps.snappy.uses)
            end

	    -- Drop items
	    if cut_height < 1 then
               return itemstack
	    end
	    if not minetest.is_creative_enabled(player:get_player_name()) then
               local dir = vector.multiply(minetest.wallmounted_to_dir(param2), -1)
               for i=3, cut_height+2 do
                  local droppos = vector.new(pos.x, pos.y + i, pos.z)
                  item_drop.drop_item(droppos, "rp_default:alga")
               end
            end
            return itemstack
         end,
	 _fertilized_node = _fertilized_node,
         _waterplant_base_node = basenode,
   })
end

minetest.register_craftitem("rp_default:alga", {
   description = S("Alga"),
   _tt_help = S("Grows underwater on dirt, swamp dirt, sand or alga block"),
   inventory_image = "rp_default_alga_inventory.png",
   wield_image = "rp_default_alga_inventory.png",
   on_place = get_sea_plant_on_place("alga", "leveled"),
   groups = { node = 1, plant = 1, alga = 1 },
})

local alga_block_tiles = {
   { name="rp_default_alga_block_top.png", backface_culling=true },
   { name="rp_default_alga_block_top.png", backface_culling=true },
   { name="rp_default_alga_block_side.png", backface_culling=true },
}
register_alga_on("alga_block", "rp_default:alga_block", alga_block_tiles, 10)

register_alga_on("dirt", "rp_default:dirt", waterplant_base_tiles("default_dirt.png", "alga", false), 5, "fertilized_dirt")
register_alga_on("swamp_dirt", "rp_default:swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "alga", false), 7, "fertilized_swamp_dirt")
register_alga_on("sand", "rp_default:sand", waterplant_base_tiles("default_sand.png", "alga", false), 3, "fertilized_sand")
register_alga_on("fertilized_dirt", "rp_default:fertilized_dirt", waterplant_base_tiles("default_dirt.png", "alga", true), 7, true)
register_alga_on("fertilized_swamp_dirt", "rp_default:fertilized_swamp_dirt", waterplant_base_tiles("default_swamp_dirt.png", "alga", true), 9, true)
register_alga_on("fertilized_sand", "rp_default:fertilized_sand", waterplant_base_tiles("default_sand.png", "alga", true), 4, true)

-- Alga Block
minetest.register_node(
   "rp_default:alga_block",
   {
      description = S("Alga Block"),
      tiles = alga_block_tiles,
      groups = {snappy=2, fall_damage_add_percent=-10, slippery=ALGA_BLOCK_SLIPPERY},
      is_ground_content = false,
      sounds = rp_sounds.node_sound_leaves_defaults(),
})

minetest.register_node(
   "rp_default:clam",
   {
      description = S("Clam"),
      _rp_hunger_food = 4,
      _rp_hunger_sat = 10,
      drawtype = "nodebox",
      tiles = {"default_clam.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_clam_inventory.png",
      wield_image = "default_clam_inventory.png",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-3/16, -0.5, -3/16, 3/16, -6/16, 3/16},
	 },
      },
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      drop = {
	 max_items = 3,
	 items = {
	    {items = {"rp_default:clam"}, rarity = 1},
	    {items = {"rp_default:pearl"}, rarity = 60},
	    {items = {"rp_default:pearl"}, rarity = 20},
	 }
      },
      groups = {clam = 1, fleshy = 3, oddly_breakable_by_hand = 2, choppy = 3, attached_node = 1, food = 2},
      on_use = minetest.item_eat(0),
      sounds = rp_sounds.node_sound_defaults(),

      -- Place node as the 'nopearl' clam to make sure the player can't
      -- place the same clam over and over again to farm pearls.
      node_placement_prediction = "rp_default:clam_nopearl",
      after_place_node = function(pos, placer, itemstack, pointed_thing)
         minetest.set_node(pos, {name="rp_default:clam_nopearl"})
      end,

})
-- Same as clam, except it never drops pearls.
-- To be used as node only, not for player inventory.
minetest.register_node(
   "rp_default:clam_nopearl",
   {
      drawtype = "nodebox",
      tiles = {"default_clam.png"},
      use_texture_alpha = "clip",
      inventory_image = "default_clam_inventory.png^default_clam_nopearl_overlay.png",
      wield_image = "default_clam_inventory.png",
      paramtype = "light",
      node_box = {
	 type = "fixed",
	 fixed = {
	    {-3/16, -0.5, -3/16, 3/16, -6/16, 3/16},
	 },
      },
      drop = "rp_default:clam",
      sunlight_propagates = true,
      walkable = false,
      floodable = true,
      groups = {clam = 1, fleshy = 3, oddly_breakable_by_hand = 2, choppy = 3, attached_node = 1, not_in_creative_inventory = 1},
      sounds = rp_sounds.node_sound_defaults(),
})

