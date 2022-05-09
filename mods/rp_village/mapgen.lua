
--
-- Mapgen
--
local S = minetest.get_translator("rp_village")

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

local place_priv = function(itemstack, placer, pointed_thing)
    if not minetest.get_player_privs(placer:get_player_name()).maphack then
        minetest.chat_send_player(placer:get_player_name(), minetest.colorize("#FF0000", S("You need the “maphack” privilege to use this.")))
        return itemstack
    end
    return minetest.item_place(itemstack, placer, pointed_thing)
end

minetest.register_node(
   "rp_village:entity_spawner",
   {
      description = S("Village Entity Spawner"),
      _tt_help = S("Placeholder that marks a position at which to spawn an entity during village generation"),
      drawtype = "airlike",
      pointable = false,
      inventory_image = "village_entity.png",
      wield_image = "village_entity.png",
      is_ground_content = true,
      sunlight_propagates = true,
      paramtype = "light",
      walkable = false,
      floodable = true,
      buildable_to = true,
      drop = "",
      groups = {dig_immediate = 3, not_in_creative_inventory = 1},
      sounds = rp_sounds.node_sound_defaults(),
      on_place = place_priv,
      on_timer = function(pos, elapsed)
          -- Wait until some objects are nearby ...
          local objs_around = minetest.get_objects_inside_radius(pos, 12)
          -- ... but not TOO nearby (occupying the pos)
          local objs_near = minetest.get_objects_inside_radius(pos, 1.2)
          if #objs_around > 0 and #objs_near == 0 then
              local ent_name = minetest.get_meta(pos):get_string("entity")
              if ent_name ~= "" then
                  local ent = minetest.add_entity({x=pos.x, y=pos.y+0.6, z=pos.z}, ent_name)
                  -- All spawned animals are tamed
                  if ent ~= nil and ent:get_luaentity() ~= nil then
                     if minetest.registered_entities[ent_name].type == "animal" then
                         ent:get_luaentity().tamed = true
                     end
                  end
              else
                  minetest.log("error", "[rp_village] Entity spawner without 'entity' in meta set @ "..minetest.pos_to_string(pos))
              end
              minetest.remove_node(pos)
              return
          else
              -- Don't spawn and try again later
              minetest.get_node_timer(pos):start(5)
          end
      end,
})

local village_info = {
   ["grassland"] = { ground = "rp_default:dirt", ground_top = "rp_default:dirt_with_grass" },
   ["savanna"] = { ground = "rp_default:dry_dirt", ground_top = "rp_default:dirt_with_dry_grass" },
}

minetest.register_node(
   "rp_village:grassland_village",
   {
      description = S("Village Spawner"),
      _tt_help = S("Generates a village when placed"),
      tiles = {
          "village_gen.png", "village_gen.png", "village_gen.png",
          "village_gen.png", "village_gen.png^[transformFX", "village_gen.png^[transformFX",
      },
      is_ground_content = false,
      groups = {dig_immediate = 2},
      sounds = rp_sounds.node_sound_dirt_defaults(),
      drop = "",

      on_place = place_priv,
      on_construct = function(pos)
         minetest.remove_node(pos)

         local pr = PseudoRandom(shortseed + pos.x + pos.y + pos.z)

         local below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
         local vinfo
	 if below.name == "rp_default:dirt_with_dry_grass" or minetest.get_item_group(below.name, "dry_dirt") == 1 then
            vinfo = village_info["savanna"]
	 else
            vinfo = village_info["grassland"]
	 end

         -- Spawn village on placement.
         -- Guarantee that at least the well is placed, to avoid confusion.
         village.spawn_village({x=pos.x,y=pos.y-1,z=pos.z}, pr, true, vinfo.ground, vinfo.ground_top)
      end,
})

local function attempt_village_spawn(pos, village_type)
    local spos = table.copy(pos)
    spos.y = spos.y + 1
    if minetest.settings:get_bool("mapgen_disable_villages") == true then
        return
    end

    local pr = PseudoRandom(shortseed + spos.x + spos.y + spos.z)

    if ((shortseed + spos.x + spos.y + spos.z) % 30) == 1 then
       local nearest = village.get_nearest_village(spos)

       if not nearest or nearest.dist > village.min_spawn_dist then
          if vector.distance(spawn_pos, spos) > spawn_radius then
             minetest.log("action", "[rp_village] Spawning a village at " .. "(" .. spos.x
                             .. ", " .. spos.y .. ", " .. spos.z .. ")")
             local ground = village_info[village_type].ground
             local ground_top = village_info[village_type].ground_top
             local ok = village.spawn_village({x=spos.x,y=spos.y-1,z=spos.z}, pr, false, ground, ground_top)
             if not ok then
                 minetest.log("action", "[rp_village] Village spawn failed")
             end
          else
             minetest.log("action", "[rp_village] Cannot spawn village at "..minetest.pos_to_string(spos)..", too near the static spawnpoint")
          end
       else
          minetest.log("action", "[rp_village] Cannot spawn village at "..minetest.pos_to_string(spos)..", too near another village (dist="..nearest.dist..")")
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
         place_on = "rp_default:dirt_with_grass",
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

   grassland_village_decoration_id = minetest.get_decoration_id("village_grassland")

   local decoration_ids = { grassland_village_decoration_id }
   local village_types = { "grassland" }

   if grassland_village_decoration_id then
       minetest.set_gen_notify({decoration=true}, decoration_ids)
       minetest.register_on_generated(function(minp, maxp, blockseed)
           local mgobj = minetest.get_mapgen_object("gennotify")
	   for i=1, #decoration_ids do
              local decos = mgobj["decoration#"..decoration_ids[i]]
              if decos then
                 for d=1, #decos do
                     attempt_village_spawn(decos[d], village_types[i])
                 end
              end
           end
       end)
   end
end

-- Legacy aliases
minetest.register_alias("village:grassland_village_mg", "air")
minetest.register_alias("village:entity_spawner", "rp_village:entity_spawner")
minetest.register_alias("village:grassland_village", "rp_village:grassland_village")
