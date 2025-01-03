
--
-- Mapgen
--
local S = minetest.get_translator("rp_village")

local spawn_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 0, z = 0}
local spawn_radius = tonumber(minetest.settings:get("static_spawn_radius")) or 256
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

local check_priv = function(player)
    if not minetest.get_player_privs(player:get_player_name()).maphack then
        minetest.chat_send_player(player:get_player_name(), minetest.colorize("#FF0000", S("You need the “maphack” privilege to use this.")))
        return false
    end
    return true
end

local place_entity_spawner = function(itemstack, placer, pointed_thing)
    if pointed_thing.type ~= "node" then
       return itemstack
    end
    if util.handle_node_protection(placer, pointed_thing) then
       return itemstack
    end
    local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
    if handled then
       return handled_itemstack
    end
    if not check_priv(placer) then
        return itemstack
    end

    local place_pos
    itemstack, place_pos = minetest.item_place(itemstack, placer, pointed_thing)
    if placer and placer:is_player() then
       minetest.add_particle({
          pos = place_pos,
          expirationtime = 3,
          size = 5,
          texture = "village_entity.png",
          playername = placer:get_player_name(),
       })
    end
    return itemstack
end

minetest.register_node(
   "rp_village:entity_spawner",
   {
      description = S("Village Entity Spawner"),
      _tt_help = S("Placeholder that marks a position at which to spawn an entity during village generation").."\n"..
                 S("Punch to reveal village entity spawners nearby"),
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
      on_place = place_entity_spawner,
      on_use = function(itemstack, player, pointed_thing)
         if not check_priv(player) then
            return itemstack
	 end
	 local pos = vector.round(player:get_pos())
	 local offset = vector.new(18, 18, 18)
	 local nodes = minetest.find_nodes_in_area(vector.subtract(pos, offset), vector.add(pos, offset), "rp_village:entity_spawner")
	 for n=1, #nodes do
             local nodepos = nodes[n]
             minetest.add_particle({
                pos = nodepos,
                expirationtime = 3,
                size = 5,
                texture = "village_entity.png",
                playername = player:get_player_name(),
            })
         end
	 return itemstack
      end,
      on_timer = function(pos, elapsed)
          -- Wait until some objects are nearby ...
          local objs_around = minetest.get_objects_inside_radius(pos, 12)
          -- ... but not TOO nearby (occupying the pos)
          local objs_near = minetest.get_objects_inside_radius(pos, 1.2)
          if #objs_around > 0 and #objs_near == 0 then
              local meta = minetest.get_meta(pos)
              local ent_name = meta:get_string("entity")
              if ent_name ~= "" then
                  local ent = minetest.add_entity({x=pos.x, y=pos.y+0.6, z=pos.z}, ent_name)
                  local luaent = ent and ent:get_luaentity()
                  if luaent ~= nil then
                     -- Set villager profession

                     if ent_name == "rp_mobs_mobs:villager" then
                        local profession = meta:get_string("villager_profession")
                        if profession ~= "" then
                           rp_mobs_mobs.set_villager_profession(luaent, profession)
                           minetest.log("info", "[rp_village] Profession of villager spawned at "..minetest.pos_to_string(pos).." set to: "..tostring(profession))
                        else
                           minetest.log("info", "[rp_village] Entity spawner at "..minetest.pos_to_string(pos).." spawned a villager but without villager_profession set in meta. Not setting profession")
                        end
                     end
                     -- Tame animal
                     if rp_mobs.mobdef_has_tag(ent_name, "animal") then
                        luaent._tamed = true
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
   ["swamp"] = { ground = "rp_default:swamp_dirt", ground_top = "rp_default:dirt_with_swamp_grass" },
   ["savanna"] = { ground = "rp_default:dry_dirt", ground_top = "rp_default:dirt_with_dry_grass" },
   ["dry"] = { ground = "rp_default:dry_dirt", ground_top = "rp_default:dry_dirt" },
}

local use_village_spawner = function(itemstack, placer, pointed_thing)
    if not pointed_thing.type == "node" then
       return itemstack
    end
    if util.handle_node_protection(placer, pointed_thing) then
       return itemstack
    end
    local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
    if handled then
       return handled_itemstack
    end
    if not check_priv(placer) then
       return itemstack
    end

    local pos = pointed_thing.above

    minetest.add_particle({
       pos = pos,
       expirationtime = 3,
       size = 8,
       texture = "village_gen.png",
       playername = placer:get_player_name(),
    })

    local pr = PseudoRandom(shortseed + pos.x + pos.y + pos.z)

    local below = minetest.get_node({x=pos.x, y=pos.y-1, z=pos.z})
    local vinfo
    if below.name == "rp_default:dirt_with_dry_grass" then
       vinfo = village_info["savanna"]
    elseif minetest.get_item_group(below.name, "dry_dirt") ~= 0 then
       vinfo = village_info["dry"]
    elseif below.name == "rp_default:dirt_with_swamp_grass" or below.name == "rp_default:swamp_dirt" then
       vinfo = village_info["swamp"]
    else
       vinfo = village_info["grassland"]
    end

    -- Spawn village on placement.
    -- Guarantee that at least the starter villagechunk is placed, to avoid confusion.
    village.spawn_village({x=pos.x,y=pos.y-1,z=pos.z}, pr, true, vinfo.ground, vinfo.ground_top)

    return itemstack
end

minetest.register_tool(
   "rp_village:grassland_village",
   {
      description = S("Village Spawner"),
      _tt_help = S("Generates a village when placed"),
      inventory_image = "village_gen.png",
      wield_image = "village_gen.png",
      groups = { supertool = 1, disable_repair = 1},
      on_place = use_village_spawner,
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
          if spawn_radius == 0 or vector.distance(spawn_pos, spos) > spawn_radius then
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

if not minetest.settings:get_bool("mapgen_disable_villages") then
   -- Register dummy decorations to find possible village spawn points
   -- via gennotify.

   local decoration_ids = {}
   local village_types = {}
   -- decoration template
   local function new_decoration(name, place_on, biomes, fill_ratio)
      if not fill_ratio then
         fill_ratio = 0.005
      end
      local deconame = "village_"..name
      minetest.register_decoration(
         {
            name = deconame,
            deco_type = "schematic",
            place_on = place_on,
            sidelen = 16,
            fill_ratio = fill_ratio,
            biomes = biomes,
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

      local decoration_id = minetest.get_decoration_id(deconame)
      if decoration_id then
         table.insert(decoration_ids, decoration_id)
         table.insert(village_types, name)
      else
         minetest.log("error", "[rp_village] Decoration ID could not be found for village dummy decoration '"..deconame.."'")
      end
   end

   new_decoration("grassland", "rp_default:dirt_with_grass", {"Grassland","Dense Grassland","Poplar Plains","Baby Poplar Plains"})
   new_decoration("swamp", "rp_default:dirt_with_swamp_grass", {"Swamp Meadow", "Swamp Meadow Highland", "Papyrus Swamp"})
   new_decoration("savanna", "rp_default:dirt_with_dry_grass", {"Savanna", "Savannic Wasteland"})

   if #decoration_ids > 0 then
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
