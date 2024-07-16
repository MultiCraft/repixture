
--
-- Lumien mod
--

local S = minetest.get_translator("rp_lumien")

-- How close a player needs to be (in nodes) for a lumien crystal to light up
local LUMIEN_ON_RADIUS = 2
-- How far a player needs to be (in nodes) from an active lumien crystal to turn off again
local LUMIEN_OFF_RADIUS = 4
-- Light level of inactive lumien crystal
local LUMIEN_CRYSTAL_LIGHT_MIN = 2
-- Light level of active lumien crystal
local LUMIEN_CRYSTAL_LIGHT_MAX = 12
-- Light level of lumien block
local LUMIEN_BLOCK_LIGHT = 14
-- Sound pitch modifier for lumien crystal (compared to lumien block)
local LUMIEN_CRYSTAL_SOUND_PITCH = 1.2
-- Sound pitch modifier for lumien footstep sound (both block and crystal)
local LUMIEN_SOUND_PITCH_FOOTSTEP = 0.8

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
            x = pos.x-LUMIEN_ON_RADIUS,
            y = pos.y-LUMIEN_ON_RADIUS,
            z = pos.z-LUMIEN_ON_RADIUS
         },
	 {
            x = pos.x+LUMIEN_ON_RADIUS,
            y = pos.y+LUMIEN_ON_RADIUS,
            z = pos.z+LUMIEN_ON_RADIUS
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

local get_sounds = function(pitch)
   if not pitch then
      pitch = 1.0
   end
   return rp_sounds.node_sound_crystal_defaults({
      footstep = {name="rp_sounds_footstep_glass",gain=1,pitch=LUMIEN_SOUND_PITCH_FOOTSTEP},
      place = {name="rp_sounds_place_crystal",gain=1,pitch=pitch},
      dig = {name="rp_sounds_dug_crystal",gain=0.5,pitch=pitch},
      dug = {name="rp_sounds_dug_crystal",gain=1,pitch=pitch*0.95},
   })
end

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
      floodable = true,
      on_flood = function(pos)
         minetest.add_item(pos, "rp_lumien:crystal_off")
      end,

      groups = {crumbly = 3, not_in_creative_inventory = 1},
      light_source = LUMIEN_CRYSTAL_LIGHT_MAX,
      _rp_itemshow_offset = vector.new(-0.2, 0, -0.2),
      drop = "rp_lumien:crystal_off",
      sounds = get_sounds(LUMIEN_CRYSTAL_SOUND_PITCH),
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
      floodable = true,
      on_flood = function(pos)
         minetest.add_item(pos, "rp_lumien:crystal_off")
      end,

      groups = {crumbly = 3, creative_decoblock = 1},
      light_source = LUMIEN_CRYSTAL_LIGHT_MIN,
      _tt_light_source_max = LUMIEN_CRYSTAL_LIGHT_MAX,
      _rp_itemshow_offset = vector.new(-0.2, 0, -0.2),
      sounds = get_sounds(LUMIEN_CRYSTAL_SOUND_PITCH),
})

minetest.register_node(
   "rp_lumien:block",
   {
      description = S("Lumien Block"),
      tiles = {"lumien_block.png"},
      groups = {cracky = 1, mineral_natural=1},
      light_source = LUMIEN_BLOCK_LIGHT,
      sounds = get_sounds(),
      _rp_blast_resistance = 3,
})

minetest.register_node(
   "rp_lumien:reinforced_block",
   {
      description = S("Reinforced Lumien Block"),
      tiles = {"rp_lumien_reinforced_block.png"},
      groups = {cracky = 1},
      light_source = LUMIEN_BLOCK_LIGHT,
      sounds = get_sounds(),
      _rp_blast_resistance = 6,
})

-- Ores

minetest.register_node(
   "rp_lumien:stone_with_lumien",
   {
      description = S("Stone with Lumien"),
      tiles = {"default_stone.png^lumien_mineral_lumien.png"},
      groups = {cracky = 1, stone = 1, ore=1},
      drop = "rp_lumien:block",
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
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
         local ok = true

         for _,object in ipairs(minetest.get_objects_inside_radius(pos, LUMIEN_OFF_RADIUS)) do
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
      output = "rp_lumien:reinforced_block",
      items = {
	 "rp_default:fiber 8",
	 "rp_default:stick 6",
	 "rp_lumien:block",
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

minetest.register_craft(
{
      type = "cooking",
      output = "rp_lumien:block",
      recipe = "rp_lumien:stone_with_lumien",
      cooktime = 6,
})

-- Achievements

achievements.register_achievement(
   "enlightened",
   {
      title = S("Enlightened"),
      description = S("Place a lumien crystal."),
      times = 1,
      placenode = "rp_lumien:crystal_off",
      icon = "rp_lumien_achievement_enlightened.png",
      difficulty = 5.5,
})

minetest.register_alias("lumien:block", "rp_lumien:block")
minetest.register_alias("lumien:crystal_off", "rp_lumien:crystal_off")
minetest.register_alias("lumien:crystal_on", "rp_lumien:crystal_on")
minetest.register_alias("lumien:stone_with_lumien", "rp_lumien:stone_with_lumien")
