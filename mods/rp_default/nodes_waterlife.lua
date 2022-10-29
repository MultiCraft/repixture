local S = minetest.get_translator("rp_default")

local ALGA_BLOCK_SLIPPERY = 2

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
         sounds = rp_sounds.node_sound_grass_defaults(),
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
         sounds = rp_sounds.node_sound_grass_defaults(),
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
      sounds = rp_sounds.node_sound_grass_defaults(),
})

minetest.register_node(
   "rp_default:clam",
   {
      description = S("Clam"),
      _tt_food = true,
      _tt_food_hp = 4,
      _tt_food_satiation = 10,
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
      on_use = minetest.item_eat({hp = 4, sat = 10}),
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

