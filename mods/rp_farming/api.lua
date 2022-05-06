
--
-- Farming and plant growing API
--

farming.registered_plants = {}

function farming.register_plant(name, plant)
   -- Note: You'll have to register 4 plant growing nodes before calling this!
   -- Format: "[mod:plant]_[stage from 1-4]"

   farming.registered_plants[name] = plant -- Might need to fully copy here?

   local lbm_name = string.gsub(name, ":", "_")
   minetest.register_lbm(
      {
         label = "Grow legacy farming plants ("..name..")",
         name = "rp_farming:grow_legacy_plants_v2_"..lbm_name,

	 nodenames = {
	    name .. "_1",
	    name .. "_2",
	    name .. "_3",
	 },

	 action = function(pos, node)
            local timer = minetest.get_node_timer(pos)
            if not timer:is_started() then
                farming.begin_growing_plant(pos)
            end
         end,
      }
   )

   local function add_callbacks(nodename)
      minetest.override_item(
         nodename,
         {
            on_timer = function(pos)
               local name = string.gsub(minetest.get_node(pos).name, "_(%d+)", "")

               farming.grow_plant(pos, name)
            end,

            on_construct = function(pos)
               farming.begin_growing_plant(pos)
            end,

            on_place = farming.place_plant,
         }
      )
   end

   add_callbacks(name .. "_1")
   add_callbacks(name .. "_2")
   add_callbacks(name .. "_3")
end

function farming.begin_growing_plant(pos)
   local name = string.gsub(minetest.get_node(pos).name, "_(%d+)", "")

   local plant = farming.registered_plants[name]

   minetest.get_node_timer(pos):start(
      math.random(plant.grow_time / 8, plant.grow_time / 4))
end

function farming.place_plant(itemstack, placer, pointed_thing)
   -- Boilerplace to handle pointed node's rightclick handler
   if not placer or not placer:is_player() then
      return itemstack
   end
   if pointed_thing.type ~= "node" then
      return minetest.item_place_node(itemstack, placer, pointed_thing)
   end
   local node = minetest.get_node(pointed_thing.under)
   local def = minetest.registered_nodes[node.name]
   if def and def.on_rightclick and
         ((not placer) or (placer and not placer:get_player_control().sneak)) then
      return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
         pointed_thing) or itemstack
   end

   -- Get plant ID
   local name = string.gsub(itemstack:get_name(), "_(%d+)", "")

   local plant = farming.registered_plants[name]

   -- Find placement position
   local place_in, place_on = util.pointed_thing_to_place_pos(pointed_thing)
   if not place_in then
      return itemstack
   end
   local place_on_node = minetest.get_node(place_on)

   -- Find plant definition and grow plant
   for _, can_grow_on in ipairs(plant.grows_on) do
      local group = string.match(can_grow_on, "group:(.*)")

      if (group ~= nil and minetest.get_item_group(place_on_node.name, group) > 0) or
      (place_on_node.name == can_grow_on) then
         itemstack = minetest.item_place(itemstack, placer, pointed_thing)
         break
      end
   end

   return itemstack
end

-- Grow plant to next stage.
-- Returns true if plant has grown, false if not (e.g. because of max stage)
function farming.next_stage(pos, plant_name)
   local my_node = minetest.get_node(pos)

   if my_node.name == plant_name .. "_1" then
      minetest.set_node(pos, {name = plant_name .. "_2"})
      return true
   elseif my_node.name == plant_name .. "_2" then
      minetest.set_node(pos, {name = plant_name .. "_3"})
      return true
   elseif my_node.name == plant_name .. "_3" then
      minetest.set_node(pos, {name = plant_name .. "_4"})

      -- Stop the timer on the node so no more growing occurs until needed

      minetest.get_node_timer(pos):stop()
      return true
   end
   return false
end

function farming.grow_plant(pos, name)
   local plant = farming.registered_plants[name]

   -- Check nearby nodes such as water

   local my_node = minetest.get_node(pos)

   if plant.grows_near and
   minetest.find_node_near(pos, plant.growing_distance, plant.grows_near) == nil then
      minetest.get_node_timer(pos):start(
         math.random(plant.grow_time / 16, plant.grow_time / 4))

      return
   end

   -- Check light; if too dark check again soon

   local light = minetest.get_node_light(pos)

   if light ~= nil and (light < plant.light_min or light > plant.light_max) then
      minetest.get_node_timer(pos):start(
         math.random(plant.grow_time / 16, plant.grow_time / 4))

      return
   end

   -- Grow and check for rain and fertilizer

   farming.next_stage(pos, name)

   local under = vector.add(pos, vector.new(0, -1, 0))
   if minetest.get_item_group(under.name, "plantable_fertilizer") > 0 then
      farming.next_stage(pos, name)
   end

   if weather.weather == "storm" then
      farming.next_stage(pos, name)
   end
end
