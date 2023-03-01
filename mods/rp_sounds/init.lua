--
-- Sounds
--

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
      {name="rp_sounds_place_failed", gain=0.12}
   return table
end

function rp_sounds.node_sound_stone_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_stone", gain=0.6}
   table.dug = table.dug or
      {name="rp_sounds_dug_stone", gain=1.0}
   table.dig = table.dig or
      {name="rp_sounds_dig_stone", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_dirt", gain=1.0}
   table.dug = table.dug or
      {name="rp_sounds_dig_dirt", gain=1.0, pitch=0.8}
   table.dig = table.dig or
      {name="rp_sounds_dig_dirt", gain=0.5}
   table.place = table.place or
      {name="default_place_node_hard", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_dry_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_dry_dirt", gain=1.0}
   rp_sounds.node_sound_dirt_defaults(table)
   return table
end

function rp_sounds.node_sound_swamp_dirt_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_swamp_dirt", gain=1.0}
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
      {name="default_place_node_hard", gain=1.0}
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
      {name="rp_sounds_dig_wood", gain=0.2}
   table.dug = table.dug or
      {name="rp_sounds_dig_wood", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_planks_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="rp_sounds_footstep_wood", gain=0.7, pitch=1.1}
   table.dig = table.dig or
      {name="rp_sounds_dig_wood", gain=0.2, pitch=1.3}
   table.dug = table.dug or
      {name="rp_sounds_dig_wood", gain=0.5, pitch=1.1}
   table.place = table.place or
      {name="rp_sounds_place_planks", gain=1.0}
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
      {name="rp_sounds_footstep_fuzzy", gain=0.7}
   table.dig = table.dig or
      {name="default_dig_hard", gain=0.15}
   table.dug = table.dug or
      {name="default_dug_node", gain=0.5}
   rp_sounds.node_sound_defaults(table)
   return table
end

function rp_sounds.node_sound_water_defaults(table)
   table = table or {}
   table.footstep = table.footstep or
      {name="default_water_footstep", gain=1.0}
   table.dug = table.dug or
      {name="default_dug_water", gain=1.0}
   table.place = table.place or
      {name="default_place_node_water", gain=1.0}
   rp_sounds.node_sound_defaults(table)
   return table
end

-- Dummy function, snow is unused
function rp_sounds.node_sound_snow_defaults(table)
   return rp_sounds.node_sound_dirt_defaults(table)
end


