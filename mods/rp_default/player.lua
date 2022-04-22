local S = minetest.get_translator("rp_default")

local player_soundspec = {}
local player_lastsound = {}
local player_health = {}
local player_lastpos = {}

local particlespawners = {}

local function step(dtime)
   local player_positions = {}

   for _, player in ipairs(minetest.get_connected_players()) do
      local player_pos=player:get_pos()
      local head_pos = player_pos
      local name=player:get_player_name()

      player_lastpos[name] = player:get_pos()

      player_health[name] = player:get_hp()

      head_pos.x=math.floor(head_pos.x+0.5)
      head_pos.y=math.ceil(head_pos.y+1.0)
      head_pos.z=math.floor(head_pos.z+0.5)

      player_pos.x=math.floor(player_pos.x+0.5)
      player_pos.y=math.ceil(player_pos.y-0.3)
      player_pos.z=math.floor(player_pos.z+0.5)

      if player_lastsound[name] == nil then player_lastsound[name] = 100 end

      player_lastsound[name] = player_lastsound[name] + dtime

      if minetest.get_item_group(minetest.get_node(head_pos).name, 'water') > 0 then
	 particlespawners[name] = minetest.add_particlespawner(
	    {
	       amount = 2,
	       time = 0.1,
	       minpos = {
                  x = head_pos.x - 0.2,
                  y = head_pos.y - 0.3,
                  z = head_pos.z - 0.3
               },
	       maxpos = {
                  x = head_pos.x + 0.3,
                  y = head_pos.y + 0.3,
                  z = head_pos.z + 0.3
               },
               minvel = {x = -0.5, y = 0, z = -0.5},
               maxvel = {x = 0.5, y = 0, z = 0.5},
               minacc = {x = -0.5, y = 4, z = -0.5},
               maxacc = {x = 0.5, y = 1, z = 0.5},
               minexptime = 0.3,
               maxexptime = 0.8,
               minsize = 0.7,
               maxsize = 2.4,
               texture = "bubble.png"
         })

	 minetest.after(0.15, function(name)
               if particlespawners[name] then
                       minetest.delete_particlespawner(particlespawners[name])
               end
         end, name)
      end

      if minetest.get_item_group(minetest.get_node(player_pos).name, "water") > 0 then
	 if player_lastsound[name] > 3.3 then
	    player_soundspec[name]=minetest.sound_play(
	       "default_water",
	       {
		  pos = player_pos,
		  max_hear_distance = 16,
            })
	    player_lastsound[name] = 0
	 end
      else
	 if player_soundspec[name] ~= nil then
	    minetest.sound_stop(player_soundspec[name])

	    player_lastsound[name] = 100
	 end
      end

      local grass_pos=minetest.find_node_near(player_pos, 1, {"rp_default:dirt_with_grass"})

      if grass_pos ~= nil and math.random(1, 500) == 1 then
	 if grass_pos.x == player_pos.x and grass_pos.z == player_pos.z then
	    minetest.set_node(grass_pos, {name = "rp_default:dirt_with_grass_footsteps"})
	 end
      end

      table.insert(player_positions, player_pos)
   end
end

local function on_joinplayer(player)
   local name=player:get_player_name()

   player_health[name] = player:get_hp()

   player_lastpos[name] = player:get_pos()

   local inv = player:get_inventory()
   inv:set_size("hand", 1)
end

local function on_leaveplayer(player)
   local name = player:get_player_name()

   player_health[name] = nil

   player_lastpos[name] = nil

   player_soundspec[name] = nil
   player_lastsound[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

minetest.register_globalstep(step)

default.log("player", "loaded")