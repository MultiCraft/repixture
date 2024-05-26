local STAIR_BURNTIME_RATIO = 0.75
local SLAB_BURNTIME_RATIO = 0.5
local FALLBACK_BURNTIME = 7

--
-- Partial blocks API
--

local adv_slab_tex = function(tiles, tex_prefix, force_white)
	local t1 = tiles[1]
	local t2 = tex_prefix.."_slab.png"
	if force_white then
		t2 = { name = t2, color = "white" }
	end
	return { t1, t1, t2 }
end
local adv_stair_tex = function(tiles, tex_prefix, force_white)
	local t1 = tiles[1]
	local t2 = tex_prefix.."_stair.png"
	local t3 = tex_prefix.."_slab.png"
	local t4 = tex_prefix.."_stair.png^[transformFX"
	if force_white then
		t2 = { name = t2, color = "white" }
		t3 = { name = t3, color = "white" }
		t4 = { name = t4, color = "white" }
	end
	return { t3, t1, t4, t2, t1, t3 }
end

local parse_slab_tiles = function(tiles_slab_def, tiles_fallback)
   local tiles
   if tiles_slab_def then
      -- Advanced slab tiles
      if type(tiles_slab_def) == "string" and string.sub(tiles_slab_def, 1, 2) == "a|" then
          local texpref = string.sub(tiles_slab_def, 3)
	  tiles = adv_slab_tex(tiles_fallback, texpref)
      elseif type(tiles_slab_def) == "string" and string.sub(tiles_slab_def, 1, 2) == "A|" then
          local texpref = string.sub(tiles_slab_def, 3)
	  tiles = adv_slab_tex(tiles_fallback, texpref, true)
      else
      -- Explicit slab tiles
          tiles = tiles_slab_def
      end
   else
      -- Slab tiles from base node
      tiles = tiles_fallback
   end
   return tiles
end

local parse_stair_tiles = function(tiles_stair_def, tiles_fallback)
   local tiles
   if tiles_stair_def then
      -- Advanced stair tiles
      if type(tiles_stair_def) == "string" and string.sub(tiles_stair_def, 1, 2) == "a|" then
          local texpref = string.sub(tiles_stair_def, 3)
	  tiles = adv_stair_tex(tiles_fallback, texpref)
      elseif type(tiles_stair_def) == "string" and string.sub(tiles_stair_def, 1, 2) == "A|" then
          local texpref = string.sub(tiles_stair_def, 3)
	  tiles = adv_stair_tex(tiles_fallback, texpref, true)
      elseif tiles_stair_def == "w" then
      -- World-aligned stair textures
          if tiles_fallback then
             local tex1 = tiles_fallback[1]
             if type(tex1) == "string" then
                tiles = {{ name = tex1, align_style = "world" }}
             elseif type(tex1) == "table" then
                tiles = { table.copy(tex1) }
                tiles[1].align_style = "world"
             else
                minetest.log("error", "[rp_partialblocks] Failed to generate world-aligned stair texture!")
             end
          end
      else
      -- Explicit stair tiles
          tiles = tiles_stair_def
      end
   else
      -- Stair tiles from base node
      tiles = tiles_fallback
   end
   return tiles
end

function partialblocks.register_material(name, desc_slab, desc_stair, node, groups, is_fuel, tiles_slab, tiles_stair, overlay_tiles_slab, overlay_tiles_stair, register_crafts)
   local nodedef = minetest.registered_nodes[node]
   if register_crafts == nil then
      register_crafts = true
   end

   if nodedef == nil then
      minetest.log("warning", "[rp_partialblocks] Cannot find node for partialblock: " .. node)

      return
   end

   -- Node identifiers
   local slabname = "rp_partialblocks:slab_" .. name
   local slabupname = "rp_partialblocks:slab_up_" .. name
   local stairname = "rp_partialblocks:stair_" .. name
   local stairupname = "rp_partialblocks:stair_up_" .. name

   -- Slab
   local tiles = parse_slab_tiles(tiles_slab, nodedef.tiles)
   local overlay_tiles = parse_slab_tiles(overlay_tiles_slab, nodedef.overlay_tiles)

   local groups_slab
   if not groups then
      groups_slab = table.copy(nodedef.groups)
      if groups_slab.level then
         groups_slab.level = math.max(-32737, groups_slab.level - 1)
      else
         groups_slab.level = -1
      end
   else
      groups_slab = table.copy(groups)
      if not groups_slab.level then
         groups_slab.level = -1
      end
   end
   groups_slab.slab = 1

   local paramtype2_slab = "none"
   local paramtype2_stair = "4dir"
   local palette_slab, palette_stair
   local drop_slab, drop_stair
   if nodedef.groups and nodedef.groups.paintable then
      if nodedef.groups.paintable == 1 then
         paramtype2_slab = "color"
         paramtype2_stair = "color4dir"
         palette_slab = "rp_paint_palette_256.png"
         palette_stair = "rp_paint_palette_64.png"
      end
      drop_slab = slabname
      drop_stair = stairname
      if string.sub(name, -8, -1) == "_painted" then
         drop_slab = string.sub(drop_slab, 1, -9)
         drop_stair = string.sub(drop_stair, 1, -9)
      end
   end

   local slabdef =
      {
	 tiles = tiles,
         overlay_tiles = overlay_tiles,
	 groups = groups_slab,
	 sounds = nodedef.sounds,

	 description = desc_slab,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	 },

	 paramtype = "light",
	 paramtype2 = paramtype2_slab,
	 use_texture_alpha = nodedef.use_texture_alpha,
	 palette = palette_slab,
	 is_ground_content = nodedef.is_ground_content,
	 drop = drop_slab,

         on_place = function(itemstack, placer, pointed_thing)
            local function place_slab_up(itemstack, placer, pointed_thing)
               local itemstack_up = ItemStack(itemstack)
               itemstack_up:set_name(slabupname)
               itemstack_up:set_count(1)
               itemstack_up = minetest.item_place(itemstack_up, placer, pointed_thing)
               if itemstack_up:is_empty() and not minetest.is_creative_enabled(placer:get_player_name()) then
                  itemstack:take_item()
               end
               return itemstack
            end

            -- Place at wall: Place "up" slab up pointed at upper half of node side
            if (pointed_thing.above.y == pointed_thing.under.y) then
               local precise = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
               local h = precise.y % 1
               if h <= 0.5 then
                  -- Place "up" slab
                  itemstack = place_slab_up(itemstack, placer, pointed_thing)
                  return itemstack
               else
                  -- Normal placement
                  itemstack = minetest.item_place(itemstack, placer, pointed_thing)
                  return itemstack
               end
            end

            -- Place at floor or ceiling

            local place_down = pointed_thing.above.y > pointed_thing.under.y

            -- Slab on slab placement creates full block
            local pos = pointed_thing.under
            local shift = false
            if placer:is_player() then
               -- Place node normally when sneak is pressed
               shift = placer:get_player_control().sneak
            end

            -- If stacking paintable stacks, check for matching color
            local old_node = minetest.get_node(pos)
            local paint_match = true
            if minetest.get_item_group(old_node.name, "paintable") == 1 then
               local old_node_paint_index = old_node.param2
               local imeta = itemstack:get_meta()
               local item_paint_index = imeta:get_int("palette_index") or 0
               paint_match = old_node_paint_index == item_paint_index
            end

            -- Create full block if both slabs are compatible
            -- and player is not sneaking
            if (not shift) and ((place_down == true and old_node.name == slabname) or
                  (place_down == false and old_node.name == slabupname))
                  and itemstack:get_count() >= 1 and paint_match then

               minetest.swap_node(pos, {name = node, param2 = old_node.param2})
	       if not minetest.is_creative_enabled(placer:get_player_name()) then
                   itemstack:take_item()
               end

            else
               if place_down then
                  itemstack = minetest.item_place(itemstack, placer, pointed_thing)
               else
                  itemstack = place_slab_up(itemstack, placer, pointed_thing)
               end
            end
            return itemstack
         end,

         -- for rp_explosions
         _rp_blast_resistance = nodedef._rp_blast_resistance,
   }

   minetest.register_node(slabname, slabdef)

   local slabdef_up = table.copy(slabdef)
   if slabdef_up.groups then
      slabdef_up.groups.not_in_creative_inventory = 1
      slabdef_up.groups.slab = 2
   end
   slabdef_up.description = nil
   slabdef_up.on_place = nil
   slabdef_up._tt_help = nil
   slabdef_up.node_box = {
      type = "fixed",
      fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
   }
   slabdef_up.collision_box = nil
   slabdef_up.selection_box = nil
   minetest.register_node(slabupname, slabdef_up)

   if register_crafts then
      crafting.register_craft({ -- 1 block --> 2 slabs
	 output = slabname .. " 2",
	 items = {
	    node,
	 },
      })

      crafting.register_craft({ -- 2 slabs --> 1 block
	 output = node,
	 items = {
	    slabname .. " 2",
	 },
      })
   end

   local full_node_burntime
   local output = minetest.get_craft_result({
      method = "fuel",
      width = 1,
      items = {node},
   })
   full_node_burntime = output.time

   if is_fuel then
      local burntime
      if full_node_burntime > 0 then
         -- Burntime is based on the origin node (if a fuel recipe was available)
         burntime = math.max(1, math.floor(full_node_burntime * SLAB_BURNTIME_RATIO))
      else
         -- Fallback burntime
         burntime = FALLBACK_BURNTIME
      end
      minetest.register_craft({ -- Fuel
         type = "fuel",
         recipe = slabname,
         burntime = burntime,
      })
   end

   -- Stair

   tiles = parse_stair_tiles(tiles_stair, nodedef.tiles)
   overlay_tiles = parse_stair_tiles(overlay_tiles_stair, nodedef.overlay_tiles)

   local groups_stair
   if not groups then
      groups_stair = table.copy(nodedef.groups)
      if groups_stair.level then
         groups_stair.level = math.max(-32737, groups_stair.level - 1)
      else
         groups_stair.level = -1
      end
   else
      groups_stair = table.copy(groups)
      if not groups_stair.level then
         groups_stair.level = -1
      end
   end
   groups_stair.stair = 1

   local stairdef =
      {
	 tiles = tiles,
         overlay_tiles = overlay_tiles,
	 groups = groups_stair,
	 sounds = nodedef.sounds,

	 description = desc_stair,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {
	       {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	       {-0.5, 0, 0, 0.5, 0.5, 0.5},
	    },
	 },

	 paramtype = "light",
	 paramtype2 = paramtype2_stair,
	 palette = palette_stair,
	 use_texture_alpha = nodedef.use_texture_alpha,
	 is_ground_content = nodedef.is_ground_content,
	 drop = drop_stair,

         on_place = function(itemstack, placer, pointed_thing)
            local function place_stair_up(itemstack, placer, pointed_thing)
               local itemstack_up = ItemStack(itemstack)
               itemstack_up:set_name(stairupname)
               itemstack_up:set_count(1)
               itemstack_up = minetest.item_place(itemstack_up, placer, pointed_thing)
               if itemstack_up:is_empty() and not minetest.is_creative_enabled(placer:get_player_name()) then
                  itemstack:take_item()
               end
               return itemstack
            end

            -- Place at wall: Place "up" stair up if placer pointed at upper half of node side
            if (pointed_thing.above.y == pointed_thing.under.y) then
               local precise = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
               local h = precise.y % 1
               if h <= 0.5 then
                  -- Place "up" stair
                  itemstack = place_stair_up(itemstack, placer, pointed_thing)
                  return itemstack
               else
                  -- Normal placement
                  itemstack = minetest.item_place(itemstack, placer, pointed_thing)
                  return itemstack
               end
            elseif (pointed_thing.above.y < pointed_thing.under.y) then
               -- Place at ceiling: Place "up" stair
               itemstack = place_stair_up(itemstack, placer, pointed_thing)
               return itemstack
            else
               -- Place at floor: Normal placement
               itemstack = minetest.item_place(itemstack, placer, pointed_thing)
               return itemstack
            end
         end,

         -- for rp_explosions
         _rp_blast_resistance = nodedef._rp_blast_resistance,
   }

   minetest.register_node(stairname, stairdef)

   local stairdef_up = table.copy(stairdef)
   if stairdef_up.groups then
      stairdef_up.groups.not_in_creative_inventory = 1
      stairdef_up.groups.stair = 2
   end
   stairdef_up.description = nil
   stairdef_up.on_place = nil
   stairdef_up._tt_help = nil
   stairdef_up.node_box = {
      type = "fixed",
      fixed = {
         {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
         {-0.5, -0.5, 0, 0.5, 0, 0.5},
      },
   }
   local stiles = table.copy(stairdef.tiles)
   local last_tile
   for i=1,6 do
      if not stiles[i] then
         if i > 1 and not last_tile then
            last_tile = tiles[i-1]
         end
         stiles[i] = last_tile or ""
      end
   end
   local mirror = function(tile)
      if type(tile) == "string" then
         return "("..tile..")^[transformFY"
      else
         return tile
      end
   end
   stairdef_up.tiles = {
      stiles[2],
      stiles[1],
      mirror(stiles[3]),
      mirror(stiles[4]),
      stiles[5],
      stiles[6],
   }
   stairdef_up.collision_box = nil
   stairdef_up.selection_box = nil
   stairdef_up.drop = drop_stair
   minetest.register_node(stairupname, stairdef_up)


   if register_crafts then
      crafting.register_craft({ -- 3 blocks --> 4 stairs
         output = stairname .. " 4",
         items = {
            node .. " 3",
         },
      })

      crafting.register_craft({ -- 2 stairs --> 3 slabs
         output = slabname .. " 3",
         items = {
            stairname .. " 2",
         },
      })
   end
   if is_fuel then
      local burntime
      if full_node_burntime > 0 then
         -- Burntime is based on the origin node (if a fuel recipe was available)
         burntime = math.max(1, math.floor(full_node_burntime * STAIR_BURNTIME_RATIO))
      else
         -- Fallback burntime
         burntime = FALLBACK_BURNTIME
      end
      minetest.register_craft({ -- Fuel
         type = "fuel",
         recipe = stairname,
         burntime = burntime,
      })
   end
end

