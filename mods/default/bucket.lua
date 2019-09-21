local S = minetest.get_translator("default")

local water_buckets = {
   { "water", S("Water Bucket"), "default_bucket_water.png", "default:water_source" },
   { "river_water", S("River Water Bucket"), "default_bucket_river_water.png", "default:river_water_source" },
   { "swamp_water", S("Swamp Water Bucket"), "default_bucket_swamp_water.png", "default:swamp_water_source" },
}

for b=1, #water_buckets do
   local bucket = water_buckets[b]
   minetest.register_craftitem(
      "default:bucket_"..bucket[1],
      {
         description = bucket[2],
         inventory_image = bucket[3],
         stack_max = 1,
         wield_scale = {x=1,y=1,z=2},
         liquids_pointable = true,
         groups = { bucket = 2, bucket_water = 1 },
         on_place = function(itemstack, user, pointed_thing)
            if pointed_thing.type ~= "node" then return end
   
            local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
            if minetest.is_protected(pos_protected, user) then return end
   
            local inv=user:get_inventory()
   
            if not minetest.settings:get_bool("creative_mode") then
               if itemstack:get_count() == 1 then
                  itemstack:set_name("default:bucket")
               elseif inv:room_for_item("main", {name="default:bucket"}) then
                  itemstack:take_item()
                  inv:add_item("main", "default:bucket")
               else
                  itemstack:take_item()
                  local pos = user:get_pos()
                  pos.y = math.floor(pos.y + 0.5)
                  minetest.add_item(pos, "default:bucket")
               end
            end

            local pos = pointed_thing.above
            local above_nodedef = minetest.registered_nodes[minetest.get_node(pointed_thing.above).name]
            local under_nodedef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]

            if under_nodedef.buildable_to then
               pos=pointed_thing.under
            end

            if not above_nodedef.walkable then
               minetest.add_node(pos, {name = bucket[4]})
               minetest.sound_play({name="default_place_node_water", gain=1.0}, {pos=pos})
            end

            return itemstack
         end
   })
end

minetest.register_craftitem(
   "default:bucket",
   {
      description = S("Empty Bucket"),
      inventory_image = "default_bucket.png",
      stack_max = 10,
      wield_scale = {x=1,y=1,z=2},
      liquids_pointable = true,
      groups = { bucket = 1 },
      on_use = function(itemstack, user, pointed_thing)
         if pointed_thing.type ~= "node" then return end

         local nodename=minetest.get_node(pointed_thing.under).name

         local replace_bucket = function(itemstack, new_bucket)
            if minetest.settings:get_bool("creative_mode") then
                -- no-op
            elseif itemstack:get_count() == 1 then
                itemstack:set_name(new_bucket)
            else
                itemstack:take_item()

                local inv=user:get_inventory()

                if inv:room_for_item("main", {name="default:bucket_water"}) then
                   inv:add_item("main", "default:bucket_water")
                else
                   local pos = user:get_pos()
                   pos.y = math.floor(pos.y + 0.5)
                   minetest.add_item(pos, "default:bucket_water")
                end
             end
             minetest.remove_node(pointed_thing.under)
             minetest.sound_play({name="default_dug_water", gain=1.0}, {pos=pointed_thing.pos})
             return itemstack
         end

         if nodename == "default:water_source" then
            itemstack = replace_bucket(itemstack, "default:bucket_water")
         elseif nodename == "default:river_water_source" then
            itemstack = replace_bucket(itemstack, "default:bucket_river_water")
         elseif nodename == "default:swamp_water_source" then
            itemstack = replace_bucket(itemstack, "default:bucket_swamp_water")
         end

         return itemstack
      end

})

default.log("bucket", "loaded")
