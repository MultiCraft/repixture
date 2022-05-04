local S = minetest.get_translator("rp_default")

local water_buckets = {
   { "water", S("Water Bucket"), "default_bucket_water.png", "rp_default:water_source", S("Places a water source") },
   { "river_water", S("River Water Bucket"), "default_bucket_river_water.png", "rp_default:river_water_source", S("Places a river water source") },
   { "swamp_water", S("Swamp Water Bucket"), "default_bucket_swamp_water.png", "rp_default:swamp_water_source", S("Places a swamp water source") },
}

for b=1, #water_buckets do
   local bucket = water_buckets[b]
   minetest.register_craftitem(
      "rp_default:bucket_"..bucket[1],
      {
         description = bucket[2],
         _tt_help = bucket[5],
         inventory_image = bucket[3],
         stack_max = 1,
         wield_scale = {x=1,y=1,z=2},
         liquids_pointable = true,
         groups = { bucket = 2, bucket_water = 1 },
         on_place = function(itemstack, user, pointed_thing)
            if pointed_thing.type ~= "node" then return itemstack end
   
            local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
            if minetest.is_protected(pos_protected, user:get_player_name()) and
                    not minetest.check_player_privs(user, "protection_bypass") then
                minetest.record_protection_violation(pos_protected, user:get_player_name())
                return itemstack
            end
   
            local inv=user:get_inventory()
   
            local pos = pointed_thing.above
            local above_nodedef = minetest.registered_nodes[minetest.get_node(pointed_thing.above).name]
            local under_nodedef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

            if under_nodedef.buildable_to then
               pos=pointed_thing.under
            end

            if not above_nodedef.walkable then
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
               minetest.add_node(pos, {name = bucket[4]})
               minetest.sound_play({name="default_place_node_water", gain=1.0}, {pos=pos}, true)
            end

            return itemstack
         end
   })
end

minetest.register_craftitem(
   "rp_default:bucket",
   {
      description = S("Empty Bucket"),
      _tt_help = S("Place it to collect a liquid source"),
      inventory_image = "default_bucket.png",
      stack_max = 10,
      wield_scale = {x=1,y=1,z=2},
      liquids_pointable = true,
      groups = { bucket = 1 },
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

                if inv:room_for_item("main", {name="rp_default:bucket_water"}) then
                   inv:add_item("main", "rp_default:bucket_water")
                else
                   local pos = user:get_pos()
                   pos.y = math.floor(pos.y + 0.5)
                   minetest.add_item(pos, "rp_default:bucket_water")
                end
             end
             minetest.remove_node(pointed_thing.under)
             minetest.sound_play({name="default_dug_water", gain=1.0}, {pos=pointed_thing.pos}, true)
             return itemstack
         end

         if nodename == "rp_default:water_source" then
            itemstack = replace_bucket(itemstack, "rp_default:bucket_water")
         elseif nodename == "rp_default:river_water_source" then
            itemstack = replace_bucket(itemstack, "rp_default:bucket_river_water")
         elseif nodename == "rp_default:swamp_water_source" then
            itemstack = replace_bucket(itemstack, "rp_default:bucket_swamp_water")
         end

         return itemstack
      end

})

default.log("bucket", "loaded")
