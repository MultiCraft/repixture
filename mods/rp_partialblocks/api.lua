
--
-- Partial blocks API
--

local adv_slab_tex = function(name, tex_prefix)
	local t1 = minetest.registered_nodes[name].tiles[1]
	local t2 = tex_prefix.."_slab.png"
	return { t1, t1, t2 }
end
local adv_stair_tex = function(name, tex_prefix)
	local t1 = minetest.registered_nodes[name].tiles[1]
	local t2 = tex_prefix.."_stair.png"
	local t3 = tex_prefix.."_slab.png"
	return { t3, t1, t2.."^[transformFX", t2, t1, t3 }
end

function partialblocks.register_material(name, desc_slab, desc_stair, node, groups, is_fuel, tiles_slab, tiles_stair)
   local nodedef = minetest.registered_nodes[node]

   if nodedef == nil then
      minetest.log("warning", "[rp_partialblocks] Cannot find node for partialblock: " .. node)

      return
   end

   -- Slab
   local tiles
   if tiles_slab then
      -- Advanced slab tiles
      if type(tiles_slab) == "string" and string.sub(tiles_slab, 1, 2) == "a|" then
          local texpref = string.sub(tiles_slab, 3)
	  tiles = adv_slab_tex(node, texpref)
      else
      -- Explicit slab tiles
          tiles = tiles_slab
      end
   else
      -- Slab tiles from base node
      tiles = nodedef.tiles
   end
   local groups_slab
   if not groups then
      groups_slab = table.copy(nodedef.groups)
   else
      groups_slab = table.copy(groups)
   end
   groups_slab.slab = 1

   minetest.register_node(
      "rp_partialblocks:slab_" .. name,
      {
	 tiles = tiles,
	 groups = groups_slab,
	 sounds = nodedef.sounds,

	 description = desc_slab,
	 drawtype = "nodebox",

	 node_box = {
	    type = "fixed",
	    fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	 },

	 paramtype = "light",
	 is_ground_content = nodedef.is_ground_content,

         on_place = function(itemstack, placer, pointed_thing)
            -- Slab on slab placement creates full block
            if not (pointed_thing.above.y > pointed_thing.under.y) then
               itemstack = minetest.item_place(itemstack, placer, pointed_thing)
               return itemstack
            end
            local pos = pointed_thing.under
            local shift = false
            if placer:is_player() then
               -- Place node normally when sneak is pressed
               shift = placer:get_player_control().sneak
            end
            if (not shift) and minetest.get_node(pos).name == itemstack:get_name()
            and itemstack:get_count() >= 1 then
               minetest.set_node(pos, {name = node})

	       if not minetest.is_creative_enabled(placer:get_player_name()) then
                   itemstack:take_item()
               end

            else
               itemstack = minetest.item_place(itemstack, placer, pointed_thing)
            end
            return itemstack
         end,
   })

   crafting.register_craft( -- Craft to slab
      {
	 output = "rp_partialblocks:slab_" .. name .. " 2",
	 items = {
	    node,
	 },
   })

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
	      -- Burntime is 50% of the origin node (if a fuel recipe was available)
	      burntime = math.max(1, math.floor(output.time * 0.5))
      else
	      -- Fallback burntime
	      burntime = 7
      end
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "rp_partialblocks:slab_" .. name,
	    burntime = burntime,
      })
   end

   -- Stair

   local tiles
   if tiles_stair then
      if type(tiles_stair) == "string" and string.sub(tiles_stair, 1, 2) == "a|" then
      -- Advanced stair tiles
          local texpref = string.sub(tiles_stair, 3)
	  tiles = adv_stair_tex(node, texpref)
      elseif tiles_stair == "w" then
      -- World-aligned stair textures
          local texname = minetest.registered_nodes[node].tiles[1]
          tiles = {{ name = texname, align_style = "world" }}
      else
      -- Explicit stair tiles
          tiles = tiles_stair
      end
   else
      -- Stair tiles from base node
      tiles = nodedef.tiles
   end

   local groups_stair
   if not groups then
      groups_stair = table.copy(nodedef.groups)
   else
      groups_stair = table.copy(groups)
   end
   groups_stair.stair = 1

   minetest.register_node(
      "rp_partialblocks:stair_" .. name,
      {
	 tiles = tiles,
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
	 paramtype2 = "facedir",
	 is_ground_content = nodedef.is_ground_content,
   })

   crafting.register_craft( -- Craft to stair
      {
	 output = "rp_partialblocks:stair_" .. name,
	 items = {
            node,
	 },
   })

   if is_fuel then
      local burntime
      if full_node_burntime > 0 then
	      -- Burntime is 75% of the origin node (if a fuel recipe was available)
	      burntime = math.max(1, math.floor(output.time * 0.75))
      else
	      -- Fallback burntime
	      burntime = 7
      end
      minetest.register_craft( -- Fuel
	 {
	    type = "fuel",
	    recipe = "rp_partialblocks:stair_" .. name,
	    burntime = burntime,
      })
   end
end

