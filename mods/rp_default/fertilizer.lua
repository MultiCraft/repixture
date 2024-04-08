-- Fertilizer

local S = minetest.get_translator("rp_default")
local GRAVITY = tonumber(minetest.settings:get("movement_gravity") or 9.81)

minetest.register_node(
   "rp_default:fertilized_dirt",
   {
      description = S("Fertilized Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_dirt.png^default_fertilizer.png",
         "default_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 dirt = 1,
	 normal_dirt = 1,
	 plantable_soil = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -5,
      },
      drop = "rp_default:dirt",
      sounds = rp_sounds.node_sound_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_dry_dirt",
   {
      description = S("Fertilized Dry Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_dry_dirt.png^default_fertilizer.png",
         "default_dry_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 dirt = 1,
	 dry_dirt = 1,
	 plantable_dry = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
      },
      drop = "rp_default:dry_dirt",
      sounds = rp_sounds.node_sound_dry_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_swamp_dirt",
   {
      description = S("Fertilized Swamp Dirt"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {
         "default_swamp_dirt.png^default_fertilizer.png",
         "default_swamp_dirt.png"
      },
      groups = {
	 crumbly = 3,
	 soil = 1,
	 dirt = 1,
	 swamp_dirt = 1,
	 plantable_wet = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
      },
      drop = "rp_default:swamp_dirt",
      sounds = rp_sounds.node_sound_swamp_dirt_defaults(),
})

minetest.register_node(
   "rp_default:fertilized_sand",
   {
      description = S("Fertilized Sand"),
      _tt_help = S("Speeds up the growth of plants"),
      tiles = {"default_sand.png^default_fertilizer.png", "default_sand.png"},
      groups = {
	 crumbly = 3,
	 falling_node = 1,
	 sand = 1,
	 plantable_sandy = 1,
	 plantable_fertilizer = 1,
	 fall_damage_add_percent = -10,
      },
      drop = "rp_default:sand",
      sounds = rp_sounds.node_sound_sand_defaults(),
})

minetest.register_craftitem(
   "rp_default:fertilizer",
   {
      description = S("Fertilizer"),
      _tt_help = S("Used to fertilize dirt and sand to speed up plant growth"),
      inventory_image = "default_fertilizer_inventory.png",
      wield_scale = {x=1,y=1,z=2},
      groups = { tool = 1 },
      on_place = function(itemstack, placer, pointed_thing)
         -- Boilerplate to handle pointed node and protection
         local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
         if handled then
            return handled_itemstack
         end
         if util.handle_node_protection(placer, pointed_thing) then
            return itemstack
         end

	 -- Fertilize node (depending on node type)
	 local underpos = pointed_thing.under
         local undernode = minetest.get_node(underpos)
         if minetest.get_item_group(undernode.name, "plant") ~= 0 and minetest.get_item_group(undernode.name, "rooted_plant") == 0 then
            underpos = vector.add(underpos, vector.new(0,-1,0))
            undernode = minetest.get_node(underpos)
	 end
         local diff = vector.subtract(pointed_thing.above, underpos)
	 local fertilized = false
         if diff.y > 0 then
            if minetest.get_item_group(undernode.name, "plantable_fertilizer") ~= 0 then
               return itemstack
            else
               local underdef = minetest.registered_nodes[undernode.name]
               if underdef and underdef._fertilized_node then
                  minetest.swap_node(underpos, {name = underdef._fertilized_node, param2 = undernode.param2})
	          fertilized = true
               end
            end
	    if fertilized then
	       minetest.log("action", "[rp_default] " .. placer:get_player_name() .. " fertilizes " .. undernode.name .. " at " .. minetest.pos_to_string(underpos, 0))
               local above_soil_pos = vector.add(underpos, vector.new(0,1,0))
               local above_soil_node = minetest.get_node(above_soil_pos)

               minetest.sound_play({name="rp_default_fertilize", gain=1.0}, {pos=underpos}, true)

	       local pymin, pymax = 0.6, 0.65
               local abovedef = minetest.registered_nodes[above_soil_node.name]
               local yacc = -GRAVITY
               if abovedef then
                  if abovedef.move_resistance and abovedef.move_resistance > 0 then
                     yacc = yacc / (abovedef.move_resistance + 1)
                  elseif abovedef.liquid_viscosity and abovedef.liquid_viscosity > 0 then
                     yacc = yacc / (abovedef.liquid_viscosity + 1)
                  else
                     if minetest.get_item_group(above_soil_node.name, "plant") ~= 0 then
                        pymin, pymax = 0.75, 1.2
                     end
                  end
               end
               minetest.add_particlespawner({
                  amount = 16,
                  time = 0.001,
                  pos = {
                     min = vector.add(underpos, vector.new(-0.4, pymin, -0.4)),
                     max = vector.add(underpos, vector.new(0.4, pymax, 0.4)),
                  },
                  vel = { min = vector.new(-0.5, 0, -0.5), max = vector.new(0.5, 0.5, 0.5) },
                  acc = vector.new(0, yacc, 0),
                  collisiondetection = true,
                  exptime = 1.0,
                  drag = vector.new(3.5, 0, 3.5),
                  size = 1,
                  texpool = {
                     { name="rp_default_fertilize_particle_1.png", alpha_tween={ 1, 0, start = 0.8} },
                     { name="rp_default_fertilize_particle_2.png", alpha_tween={ 1, 0, start = 0.8} },
                     { name="rp_default_fertilize_particle_3.png", alpha_tween={ 1, 0, start = 0.8} },
                     { name="rp_default_fertilize_particle_4.png", alpha_tween={ 1, 0, start = 0.8} },
                  },
               })

	       -- Add time bonus for sapling so it grows faster.
	       -- Note this only has an effect if the sapling was not
	       -- already fertilized.
	       if minetest.get_item_group(above_soil_node.name, "sapling") == 1 then
                  -- This increases the sapling's 'elapsed' timer by adding
		  -- a fraction of the total growth time.
		  -- It's possible this will instantly expire the timer.
                  local sapling_meta = minetest.get_meta(above_soil_pos)
		  local timer = minetest.get_node_timer(above_soil_pos)
		  local timeout = timer:get_timeout()
		  local elapsed = timer:get_elapsed()
		  local bonus = timeout * default.SAPLING_FERTILIZER_TIME_BONUS_FACTOR
		  local new_elapsed = elapsed + bonus
		  timer:set(timeout, new_elapsed)
	          minetest.log("action", "[rp_default] Fertilizer affects sapling! Sapling timer of " .. above_soil_node.name ..
                          " at " .. minetest.pos_to_string(above_soil_pos, 0) .. " with timeout="..timeout.." set from elapsed="..elapsed..
			  " to elapsed="..new_elapsed)
	       end
               if placer and placer:is_player() then
                  achievements.trigger_achievement(placer, "fertile")
               end
	    end
         end

         -- Reduce item count
         if not minetest.is_creative_enabled(placer:get_player_name()) then
            itemstack:take_item()
         end

         return itemstack
      end,
})
