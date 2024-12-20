local S = minetest.get_translator("rp_default")

local water_buckets = {
   { "water", S("Wooden Bucket with Water"), "default_bucket_water.png", "rp_default:water_source", S("Punch to empty the bucket") },
   { "river_water", S("Wooden Bucket with River Water"), "default_bucket_river_water.png", "rp_default:river_water_source", S("Punch to empty the bucket") },
   { "swamp_water", S("Wooden Bucket with Swamp Water"), "default_bucket_swamp_water.png", "rp_default:swamp_water_source", S("Punch to empty the bucket") },
}

local node_to_bucket = {}
for b=1, #water_buckets do
   local data = water_buckets[b]
   local bucket = "rp_default:bucket_"..data[1]
   local nodename = data[4]
   node_to_bucket[nodename] = bucket -- water source
   node_to_bucket["rp_default:bucket_"..data[1]] = bucket -- filled bucket node
end

for b=1, #water_buckets do
   local bucket = water_buckets[b]
   local waterdef = minetest.registered_nodes[bucket[4]]
   local watertile = waterdef.tiles[1]
   minetest.register_node(
      "rp_default:bucket_"..bucket[1],
      {
         description = bucket[2],
         _tt_help = bucket[5],

         drawtype = "mesh",
         mesh = "rp_default_bucket.obj",
         tiles = {
            {name="rp_default_bucket_node_side_1.png",backface_culling=true},
            {name="rp_default_bucket_node_side_2.png",backface_culling=true},
            {name="rp_default_bucket_node_top_handle.png",backface_culling=true},
            {name="rp_default_bucket_node_bottom_inside.png",backface_culling=true},
            {name="rp_default_bucket_node_bottom_outside.png",backface_culling=true},
            watertile,
         },
	 use_texture_alpha = "blend",
	 paramtype = "light",
         paramtype2 = "4dir",
	 is_ground_content = false,
         selection_box = {
            type = "fixed",
            fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
         },
         sounds = rp_sounds.node_sound_planks_defaults({
            place = { name = "rp_default_place_bucket_water", gain = 0.65 },
            dug = { name = "rp_default_dug_bucket_water", gain = 0.7 },
            fall = { name = "rp_default_dug_bucket_water", gain = 0.5 },
            footstep = {},
         }),
         walkable = false,
         floodable = true,
         on_flood = function(pos, oldnode, newnode)
            minetest.add_item(pos, "rp_default:bucket_"..bucket[1])
         end,

         inventory_image = bucket[3],
         wield_image = bucket[3],
         stack_max = 1,
         wield_scale = {x=1,y=1,z=2},
         liquids_pointable = true,
         groups = { bucket = 2, bucket_water = 1, tool = 1, dig_immediate = 3, attached_node = 1 },
         on_use = function(itemstack, user, pointed_thing)
            local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, user, pointed_thing)
            if handled then
               return handled_itemstack
            end
            if util.handle_node_protection(user, pointed_thing) then
               return itemstack
            end

            local inv=user:get_inventory()
   
            local pos = pointed_thing.above
	    local above_node = minetest.get_node(pointed_thing.above)
	    local under_node = minetest.get_node(pointed_thing.under)
            local above_nodedef = minetest.registered_nodes[above_node.name]
            local under_nodedef = minetest.registered_nodes[under_node.name]

            if under_nodedef and under_nodedef.buildable_to then
               pos=pointed_thing.under
            end

	    local bucket_placed = false
            if minetest.get_item_group(under_node.name, "bucket") ~= 0 then
               -- Pour water into bucket node
               minetest.set_node(pointed_thing.under, {name = "rp_default:bucket_"..bucket[1], param2=under_node.param2 % 32})
               minetest.sound_play({name="rp_default_bucket_fill_water"}, {pos=pos}, true)
	       bucket_placed = true
	    elseif not above_nodedef.walkable and above_nodedef.buildable_to then
               -- Place water source node
               minetest.add_node(pos, {name = bucket[4]})
               minetest.sound_play({name="default_place_node_water", gain=0.5}, {pos=pos}, true)
	       bucket_placed = true
            end

            if bucket_placed then
               -- Handle inventory stuff
               if not minetest.is_creative_enabled(user:get_player_name()) then
                  if itemstack:get_count() == 1 then
                     itemstack:set_name("rp_default:bucket")
                  elseif inv:room_for_item("main", {name="rp_default:bucket"}) then
                     itemstack:take_item()
                     inv:add_item("main", "rp_default:bucket")
                  else
                     itemstack:take_item()
                     local pos = user:get_pos()
                     pos.y = math.floor(pos.y + 0.5)
                     minetest.add_item(pos, "rp_default:bucket")
                  end
               end
            end

            return itemstack
         end
   })
end

minetest.register_node(
   "rp_default:bucket",
   {
      description = S("Wooden Bucket"),
      _tt_help = S("Punch to collect a liquid source"),
      inventory_image = "default_bucket.png",
      wield_image = "default_bucket.png",

      drawtype = "mesh",
      mesh = "rp_default_bucket.obj",
      tiles = {
         {name="rp_default_bucket_node_side_1.png",backface_culling=true},
         {name="rp_default_bucket_node_side_2.png",backface_culling=true},
         {name="rp_default_bucket_node_top_handle.png",backface_culling=true},
         {name="rp_default_bucket_node_bottom_inside.png",backface_culling=true},
         {name="rp_default_bucket_node_bottom_outside.png",backface_culling=true},
        "blank.png",
      },
      selection_box = {
	      type = "fixed",
	      fixed = { -6/16, -0.5, -6/16, 6/16, 5/16, 6/16 },
      },
      sounds = rp_sounds.node_sound_planks_defaults({
         place = { name = "rp_default_place_bucket", gain = 0.65 },
         dug = { name = "rp_default_dug_bucket", gain = 0.7 },
         fall = { name = "rp_default_dug_bucket", gain = 0.5 },
         footstep = {},
      }),
      paramtype = "light",
      paramtype2 = "4dir",
      use_texture_alpha = "clip",
      walkable = false,
      floodable = true,
      on_flood = function(pos, oldnode, newnode)
         minetest.add_item(pos, "rp_default:bucket")
      end,

      stack_max = 10,
      wield_scale = {x=1,y=1,z=2},
      liquids_pointable = true,
      groups = { bucket = 1, tool = 1, dig_immediate = 3, attached_node = 1, react_on_rain = 1 },
      on_use = function(itemstack, user, pointed_thing)
         if pointed_thing.type ~= "node" then return end

         local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
         if minetest.is_protected(pos_protected, user:get_player_name()) and
                 not minetest.check_player_privs(user, "protection_bypass") then
             minetest.record_protection_violation(pos_protected, user:get_player_name())
             return
         end

         local nodename=minetest.get_node(pointed_thing.under).name

         local replace_bucket = function(itemstack, new_bucket)
            if minetest.is_creative_enabled(user:get_player_name()) then
                -- no-op
            elseif itemstack:get_count() == 1 then
                itemstack:set_name(new_bucket)
            else
                itemstack:take_item()

                local inv=user:get_inventory()

                local bucket = node_to_bucket[nodename]
                if not bucket then
                   return itemstack
                end

                if inv:room_for_item("main", {name=bucket}) then
                   inv:add_item("main", bucket)
                else
                   local pos = user:get_pos()
                   pos.y = math.floor(pos.y + 0.5)
                   minetest.add_item(pos, bucket)
                end
             end
	     local oldnode = minetest.get_node(pointed_thing.under)
             if minetest.get_item_group(oldnode.name, "bucket") == 2 then
                -- Pick up liquid from bucket node
                minetest.set_node(pointed_thing.under, {name="rp_default:bucket", param2 = oldnode.param2 % 32})
                minetest.sound_play({name="rp_default_bucket_fill_water", pitch=0.95}, {pos=pointed_thing.under}, true)
             else
                -- Pick up liquid source node
                minetest.remove_node(pointed_thing.under)
                minetest.sound_play({name="default_dug_water", gain=0.5}, {pos=pointed_thing.under}, true)
             end
             return itemstack
         end

         local bucket = node_to_bucket[nodename]
         if bucket then
            itemstack = replace_bucket(itemstack, bucket)
         end

         return itemstack
      end,

      _rp_on_rain = function(pos, node)
	  -- Fill bucket with water when it rains.
	  -- Before the bucket fills, it first increases a hidden "fullness"
	  -- value. The rain callback must be called 3 times before the bucket
	  -- fills with water. The fullness value is stored in param2.
	  local p2 = node.param2
          if p2 < 64 then
             -- We increase param2 by 32 because it's a number divisible by 4 (4dir wraps around)
             p2 = p2 + 32
             minetest.set_node(pos, {name=node.name, param2 = p2})
	     minetest.log("verbose", "[rp_default] Bucket at "..minetest.pos_to_string(pos).." got its fullness increased in the rain (param2="..p2..")")
          else
             -- If param2 was 64 or greater, we know that the bucket
	     -- was rained into 2 times before. Therefore, this must
	     -- be now the 3rd time, so we add the water bucket node.
             p2 = p2 % 32
             minetest.set_node(pos, {name="rp_default:bucket_water", param2 = p2})
	     minetest.log("action", "[rp_default] Bucket at "..minetest.pos_to_string(pos).." was filled with water by rain")
          end
      end,
})
