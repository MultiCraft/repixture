
--
-- Lumien mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("rp_lumien")

local lumien_on_radius = 2
local lumien_off_radius = 4

local timer_interval = 1
local timer = 0

-- Update function

local function on_globalstep(dtime)
   timer = timer + dtime

   if timer < timer_interval then
      return
   end

   timer = 0

   for _, player in ipairs(minetest.get_connected_players()) do
      local pos = player:get_pos()

      util.nodefunc(
	 {
            x = pos.x-lumien_on_radius,
            y = pos.y-lumien_on_radius,
            z = pos.z-lumien_on_radius
         },
	 {
            x = pos.x+lumien_on_radius,
            y = pos.y+lumien_on_radius,
            z = pos.z+lumien_on_radius
         },
	 "rp_lumien:crystal_off",
	 function(pos)
	    local node = minetest.get_node(pos)

	    minetest.set_node(
	       pos,
	       {
		  name = "rp_lumien:crystal_on",
		  param = node.param,
		  param2 = node.param2
            })
	 end,
	 true
      )
   end
end

minetest.register_globalstep(on_globalstep)

-- Nodes

minetest.register_node(
   "rp_lumien:crystal_on",
   {
      description = S("Glowing Lumien Crystal"),
      inventory_image = "lumien_crystal_on.png",
      tiles = {"lumien_block.png"},
      paramtype = "light",
      paramtype2 = "wallmounted",
      is_ground_content = false,
      drawtype = "nodebox",
      node_box = {
         type = "wallmounted",
         wall_top = {-4/16, 0.5-(4/16), -4/16, 4/16, 0.5, 4/16},
         wall_side = {-0.5, -4/16, -4/16, -0.5+(4/16), 4/16, 4/16},
         wall_bottom = {-4/16, -0.5, -4/16, 4/16, -0.5+(4/16), 4/16}
      },

      groups = {crumbly = 3, not_in_creative_inventory = 1},
      light_source = 12,
      drop = "rp_lumien:crystal_off",
      sounds = rp_sounds.node_sound_glass_defaults(),
})

minetest.register_node(
   "rp_lumien:crystal_off",
   {
      description = S("Lumien Crystal"),
      _tt_help = S("Can be placed; glows when someone is close"),
      inventory_image = "lumien_crystal.png",
      tiles = {"lumien_block.png"},
      paramtype = "light",
      paramtype2 = "wallmounted",
      is_ground_content = false,
      drawtype = "nodebox",
      node_box = {
         type = "wallmounted",
         wall_top = {-4/16, 0.5-(4/16), -4/16, 4/16, 0.5, 4/16},
         wall_side = {-0.5, -4/16, -4/16, -0.5+(4/16), 4/16, 4/16},
         wall_bottom = {-4/16, -0.5, -4/16, 4/16, -0.5+(4/16), 4/16}
      },

      groups = {crumbly = 3},
      light_source = 2,
      sounds = rp_sounds.node_sound_glass_defaults(),
})

minetest.register_node(
   "rp_lumien:block",
   {
      description = S("Lumien Block"),
      _tt_help = S("It shines so bright"),
      tiles = {"lumien_block.png"},
      groups = {cracky = 1},
      light_source = 14,
      sounds = rp_sounds.node_sound_stone_defaults(),
})

-- Ores

minetest.register_node(
   "rp_lumien:stone_with_lumien",
   {
      description = S("Stone with Lumien"),
      tiles = {"default_stone.png^lumien_mineral_lumien.png"},
      groups = {cracky = 1, stone = 1},
      drop = "rp_lumien:block",
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_lumien:stone_with_lumien",
      wherein        = "rp_default:stone",
      clust_scarcity = 5*5*5,
      clust_num_ores = 8,
      clust_size     = 6,
      y_min     = -107,
      y_max     = -100,
})

-- Update functions

minetest.register_abm(
   {
      label = "Lumien crystals",
      nodenames = {"rp_lumien:crystal_on"},
      interval = timer_interval,
      chance = 1,
      action = function(pos, node)
         util.nodefunc(
            {x = pos.x-1, y = pos.y-1, z = pos.z-1},
            {x = pos.x+1, y = pos.y+1, z = pos.z+1},
            "rp_tnt:tnt",
            function(pos)
               tnt.burn(pos)
            end,
            true
         )

         local ok = true

         for _,object in ipairs(minetest.get_objects_inside_radius(pos, lumien_off_radius)) do
            if object:is_player() then
               ok = false
            end
         end

         if ok then
            minetest.set_node(
               pos,
               {
                  name = "rp_lumien:crystal_off",
                  param = node.param,
                  param2 = node.param2
            })
         end
      end,
})

-- Crafting

crafting.register_craft(
   {
      output = "rp_lumien:crystal_off 9",
      items = {
         "rp_lumien:block"
      },
})

crafting.register_craft(
   {
      output = "rp_lumien:block",
      items = {
	 "rp_lumien:crystal_off 9",
      },
})

crafting.register_craft(
   {
      output = "rp_default:heated_dirt_path 2",
      items = {
         "rp_default:dirt_path 2",
         "rp_lumien:crystal_off",
      },
})


-- Achievements

achievements.register_achievement(
   "enlightened",
   {
      title = S("Enlightened"),
      description = S("Place a lumien crystal."),
      times = 1,
      placenode = "rp_lumien:crystal_off",
})

minetest.register_alias("lumien:block", "rp_lumien:block")
minetest.register_alias("lumien:crystal_off", "rp_lumien:crystal_off")
minetest.register_alias("lumien:crystal_on", "rp_lumien:crystal_on")
minetest.register_alias("lumien:stone_with_lumien", "rp_lumien:stone_with_lumien")

default.log("mod:rp_lumien", "loaded")
