--
-- Sounds
--

local PLACE_FAILED_GAIN = 0.25

rp_sounds = {}

function rp_sounds.node_sound_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="", gain=1.0}
   table.dig = table.dig or
      {name="default_dig_hard", gain=0.3}
   table.dug = table.dug or
      {name="default_dug_node", gain=0.1}
   table.place = table.place or
      {name="default_place_node_hard", gain=0.8}
   table.place_failed = table.place_failed or
      {name="rp_sounds_place_failed", gain=PLACE_FAILED_GAIN}
   table._rp_scrape = table._rp_scrape or
      {name="rp_sounds_scrape_wood", gain=0.3}
   return table
end

function rp_sounds.node_sound_small_defaults(table)
   table = table or {}
   table.dig = table.dig or
      {name="rp_sounds_dig_smallnode", gain=0.3}
   table.dug = table.dug or
      {name="rp_sounds_dug_smallnode", gain=0.5}
   table.place = table.place or
      {name="rp_sounds_place_smallnode", gain=1.0}
   table.fall = table.fall or
      {name="rp_sounds_dug_smallnode", gain=0.4}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_stone_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_stone", gain=0.6}
   table.dug = table.dug or
      {name="rp_sounds_dug_stone", gain=0.9}
   table.dig = table.dig or
      {name="rp_sounds_dig_stone", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_metal_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_metal", gain=0.6}
   table.dug = table.dug or
      {name="rp_sounds_dug_metal", gain=1.0}
   table.dig = table.dig or
      {name="rp_sounds_dig_metal", gain=0.5}
   table.place = table.place or
      {name="rp_sounds_place_metal", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_dirt", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dug_dirt", gain=0.4}
   table.dig = table.dig or
      {name="rp_sounds_dig_dirt", gain=0.25}
   table.place = table.place or
      {name="rp_sounds_place_dirt", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_dry_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_dry_dirt", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dug_dirt", gain=0.4, pitch=0.8}
   table.dig = table.dig or
      {name="rp_sounds_dig_dirt", gain=0.25, pitch=0.8}
   table.place = table.place or
      {name="rp_sounds_place_dry_dirt", gain=0.5}
   rp_sounds.node_sound_dirt_defaults(table)
   return table
end

function rp_sounds.node_sound_swamp_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_swamp_dirt", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dug_swamp_dirt", gain=0.4}
   table.dig = table.dig or
      {name="rp_sounds_dig_swamp_dirt", gain=0.25}
   table.place = table.place or
      {name="rp_sounds_place_swamp_dirt", gain=0.5}
   rp_sounds.node_sound_dirt_defaults(table)
   return table
end

function rp_sounds.node_sound_sand_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_sand", gain=0.45}
   table.dug = table.dug or
      {name="rp_sounds_dig_sand", gain=0.8, pitch = 0.9}
   table.dig = table.dig or
      {name="rp_sounds_dig_sand", gain=0.4}
   table.place = table.place or
      {name="rp_sounds_place_sand", gain=0.2}
   table.fall = table.fall or
      {name="rp_sounds_fall_sand", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_gravel_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_gravel", gain=0.15}
   table.dug = table.dug or
      {name="rp_sounds_dig_gravel", gain=0.8, pitch=0.8}
   table.dig = table.dig or
      {name="rp_sounds_dig_gravel", gain=0.4}
   table.place = table.place or
      {name="rp_sounds_place_gravel", gain=0.6}
   table.fall = table.fall or
      {name="rp_sounds_fall_gravel", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_wood_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_wood", gain=0.7}
   table.dig = table.dig or
      {name="rp_sounds_dig_wood", gain=0.5}
   table.dug = table.dug or
      {name="rp_sounds_dug_wood", gain=1.0}
   table._rp_scrape = table._rp_scrape or
      {name="rp_sounds_scrape_wood", gain=0.3}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_planks_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_wood", gain=0.7, pitch=1.1}
   table.dig = table.dig or
      {name="rp_sounds_dig_wood", gain=0.5}
   table.dug = table.dug or
      {name="rp_sounds_dug_planks", gain=0.7}
   table.place = table.place or
      {name="rp_sounds_place_planks", gain=1.0}
   table._rp_scrape = table._rp_scrape or
      {name="rp_sounds_scrape_wood", gain=0.3}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_leaves_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_leaves", gain=0.95}
   table.dug = table.dug or
      {name="rp_sounds_dug_grass", gain=0.7}
   table.dig = table.dig or
      {name="rp_sounds_dug_grass", gain=0.3}
   table.place = table.place or
      {name="rp_sounds_dug_grass", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_grass_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_grass", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dug_grass", gain=0.7}
   table.dig = table.dig or
      {name="rp_sounds_dug_grass", gain=0.3}
   table.place = table.place or
      {name="rp_sounds_dug_grass", gain=1.0}
   table.fall = table.fall or
      {name="rp_sounds_fall_grass", gain=0.6}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_plant_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_grass", gain=0.25, pitch=0.9}
   table.dug = table.dug or
      {name="rp_sounds_dug_plant", gain=0.3}
   table.dig = table.dig or
      {name="rp_sounds_dig_plant", gain=0.15}
   table.place = table.place or
      {name="rp_sounds_place_plant", gain=0.25}
   table.fall = table.fall or
      {name="rp_sounds_fall_plant", gain=0.3}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_straw_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_straw", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dug_straw", gain=0.7}
   table.dig = table.dig or
      {name="rp_sounds_dig_straw", gain=0.7}
   table.place = table.place or
      {name="rp_sounds_place_straw", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_glass_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_glass", gain=0.5}
   table.dig = table.dig or
      {name="rp_sounds_dig_glass", gain=0.5}
   table.dug = table.dug or
      {name="rp_sounds_dug_glass", gain=1.0}
   table.place = table.place or
      {name="rp_sounds_place_glass", gain=1.0}
   table._rp_scrape = table._rp_scrape or
      {name="rp_sounds_scrape_glass", gain=0.4}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_crystal_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_glass", gain=1.0}
   table.dig = table.dig or
      {name="rp_sounds_dug_crystal", gain=0.5}
   table.dug = table.dug or
      {name="rp_sounds_dug_crystal", gain=1.0}
   table.fall = table.fall or
      {name="rp_sounds_fall_crystal", gain=0.25}
   table.place = table.place or
      {name="rp_sounds_place_crystal", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_coal_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_coal", gain=0.15}
   table.dig = table.dig or
      {name="rp_sounds_dig_coal", gain=0.5}
   table.dug = table.dug or
      {name="rp_sounds_dug_coal", gain=0.9}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_fuzzy_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_fuzzy", gain=0.3}
   table.dig = table.dig or
      {name="rp_sounds_dig_fuzzy", gain=0.2}
   table.dug = table.dug or
      {name="rp_sounds_dug_fuzzy", gain=0.2}
   table.place = table.place or
      {name="rp_sounds_place_fuzzy", gain=0.2}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_water_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="default_water_footstep", gain=0.10}
   table.dug = table.dug or
      {name="default_dug_water", gain=0.5}
   table.place = table.place or
      {name="default_place_node_water", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

-- Dummy function, snow is unused
function rp_sounds.node_sound_snow_defaults(table)
   return rp_sounds.node_sound_dirt_defaults(table)
end

function rp_sounds.play_place_failed_sound(player)
   if not player or not player:is_player() then
      return
   end
   minetest.sound_play({name="rp_sounds_place_failed", gain=PLACE_FAILED_GAIN}, {to_player=player:get_player_name()}, true)
end

function rp_sounds.play_node_sound(pos, node, soundtype)
   local def = minetest.registered_nodes[node.name]
   if not def then
      return
   end
   local sounds = def.sounds
   if not sounds or not sounds[soundtype] then
      return
   end
   minetest.sound_play(sounds[soundtype], {pos=pos}, true)
end
