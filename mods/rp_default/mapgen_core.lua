
--
-- Mapgen
--

-- Uncomment this to cut a big portion of ground out for visualizing ore spawning

--[[
local function on_generated(minp, maxp, blockseed)
   for x = minp.x, maxp.x do
      if x > 0 then
         return
      end

      for z = minp.z, maxp.z do
         if z > -16 and z < 16 then
            for y = minp.y, maxp.y do
               minetest.remove_node({x = x, y = y, z = z})
            end
         end
      end
   end
end

minetest.register_on_generated(on_generated)
--]]

default.UNDERGROUND_Y_MAX = -200
default.ORCHARD_Y_MIN = 20
default.SWAMP_Y_MAX = 7
default.SWAMP_HIGH_Y_MAX = 24
default.GLOBAL_Y_MAX = 31000
default.GLOBAL_Y_MIN = -31000


-- Aliases for map generator outputs

minetest.register_alias("mapgen_stone", "rp_default:stone")
minetest.register_alias("mapgen_desert_stone", "rp_default:sandstone")
minetest.register_alias("mapgen_desert_sand", "rp_default:sand")
minetest.register_alias("mapgen_sandstone", "rp_default:sandstone")
minetest.register_alias("mapgen_sandstonebrick", "rp_default:compressed_sandstone")
minetest.register_alias("mapgen_cobble", "rp_default:cobble")
minetest.register_alias("mapgen_gravel", "rp_default:gravel")
minetest.register_alias("mapgen_mossycobble", "rp_default:cobble")
minetest.register_alias("mapgen_dirt", "rp_default:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_sand", "rp_default:sand")
minetest.register_alias("mapgen_snow", "air")
minetest.register_alias("mapgen_snowblock", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "rp_default:dirt_with_grass")
minetest.register_alias("mapgen_ice", "rp_default:water_source")
minetest.register_alias("mapgen_tree", "rp_default:tree")
minetest.register_alias("mapgen_leaves", "rp_default:leaves")
minetest.register_alias("mapgen_apple", "rp_default:apple")
minetest.register_alias("mapgen_jungletree", "rp_default:tree_birch")
minetest.register_alias("mapgen_jungleleaves", "rp_default:leaves_birch")
minetest.register_alias("mapgen_junglegrass", "rp_default:tall_grass")
minetest.register_alias("mapgen_pine_tree", "rp_default:tree_oak")
minetest.register_alias("mapgen_pine_needles", "rp_default:leaves_oak")

minetest.register_alias("mapgen_water_source", "rp_default:water_source")
minetest.register_alias("mapgen_river_water_source", "rp_default:river_water_source")

minetest.register_alias("mapgen_lava_source", "rp_default:water_source")

