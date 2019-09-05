
--
-- Mapgen
--
local S = minetest.get_translator("village")

local spawn_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 0, z = 0}
local spawn_radius = minetest.settings:get("static_spawn_radius") or 256
local mapseed = minetest.get_mapgen_setting("seed")

local bitwise_and = function(x,y)
	local upper = math.floor(math.log(x, 2))
	local sum = 0
	for n=0, upper do
		sum = sum + math.pow(2, n) * (math.floor(x/math.pow(2, n)) % 2) * ( math.floor(y / math.pow(2, n)) % 2)
	end
	return math.floor(sum)
end

local shortseed = bitwise_and(mapseed, 0xFFFFFF)

-- Nodes

minetest.register_node(
   "village:entity_spawner",
   {
      description = S("Village Entity Spawner"),
      tiles = {
          "village_entity.png", "village_entity.png", "village_entity.png",
          "village_entity.png", "village_entity.png^[transformFX", "village_entity.png^[transformFX"
      },
      is_ground_content = false,
      sunlight_propagates = true,
      paramtype = "light",
      post_effect_color = { a = 0x40, r = 0x8D, g = 0x75, b = 0x97 },
      walkable = false,
      drop = "",
      groups = {dig_immediate = 3, not_in_creative_inventory = 1},
      sounds = default.node_sound_defaults()
})

minetest.register_node(
   "village:grassland_village",
   {
      description = S("Village Spawner"),
      tiles = {
          "village_gen.png", "village_gen.png", "village_gen.png",
          "village_gen.png", "village_gen.png^[transformFX", "village_gen.png^[transformFX",
      },
      is_ground_content = false,
      groups = {dig_immediate = 2},
      sounds = default.node_sound_dirt_defaults(),
      drop = "",

      on_construct = function(pos)
         minetest.remove_node(pos)

         local pr = PseudoRandom(shortseed + pos.x + pos.y + pos.z)

         village.spawn_village({x=pos.x,y=pos.y-1,z=pos.z}, pr)
      end,
})

local function attempt_village_spawn(pos)
    local spos = table.copy(pos)
    spos.y = spos.y + 1
    if minetest.settings:get_bool("mapgen_disable_villages") == true then
        return
    end

    local pr = PseudoRandom(shortseed + spos.x + spos.y + spos.z)

    if ((shortseed + spos.x + spos.y + spos.z) % 30) == 1 then
       local nearest = village.get_nearest_village(spos)

       if nearest.dist > village.min_spawn_dist then
          if vector.distance(spawn_pos, spos) > spawn_radius then
             minetest.log("action", "[village] Spawning a grassland village at " .. "(" .. spos.x
                             .. ", " .. spos.y .. ", " .. spos.z .. ")")
             local ok = village.spawn_village({x=spos.x,y=spos.y-1,z=spos.z}, pr)
             if not ok then
                 minetest.log("action", "[village] Village spawn failed")
             end
          else
             minetest.log("action", "[village] Cannot spawn village, too near the static spawnpoint")
          end
       else
          minetest.log("action", "[village] Cannot spawn village, too near another village")
       end
    end
end

local village_decoration_id
if not minetest.settings:get_bool("mapgen_disable_villages") then
   -- Dummy decoration to find possible village spawn points
   -- via gennotify.
   minetest.register_decoration(
      {
         name = "village_grassland",
         deco_type = "schematic",
         place_on = "default:dirt_with_grass",
         sidelen = 16,
         fill_ratio = 0.005,
         biomes = {
            "Grassland",
         },
         -- empty schematic
         schematic = {
             size = { x = 1, y = 1, z = 1 },
             data = {
                 { name = "air", prob = 0 },
             },
         },
         y_min = 1,
         y_max = 1000,
   })
   village_decoration_id = minetest.get_decoration_id("village_grassland")

   if village_decoration_id then
       minetest.set_gen_notify({decoration=true}, {village_decoration_id})
       minetest.register_on_generated(function(minp, maxp, blockseed)
           local mgobj = minetest.get_mapgen_object("gennotify")
           local deco = mgobj["decoration#"..village_decoration_id]
           if deco then
               for d=1, #deco do
                   attempt_village_spawn(deco[d])
               end
           end
       end)
   end
end

-- Legacy alias
minetest.register_alias("village:grassland_village_mg", "air")
