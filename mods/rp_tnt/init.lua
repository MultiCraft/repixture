
--
-- TNT mod
--
local S = minetest.get_translator("rp_tnt")

-- Time in seconds before TNT explodes after ignited
local TNT_TIMER = 2.0

tnt = {}

local particlespawners = {}

-- Default to enabled in singleplayer and disabled in multiplayer

local singleplayer = minetest.is_singleplayer()
local setting = minetest.settings:get_bool("tnt_enable")

local tnt_enable
if (not singleplayer and setting ~= true) or (singleplayer and setting == false) then
   tnt_enable = false
else
   tnt_enable = true
end

local tnt_radius = tonumber(minetest.settings:get("tnt_radius") or 3)

-- Loss probabilities array (one in X will be lost)

local loss_prob = {
   ["rp_default:cobble"] = 3,
   ["rp_default:dirt"] = 4,
}

-- Fill a list with data for content IDs, after all nodes are registered

local cid_data = {}

local function rand_pos(center, pos, radius)
   pos.x = center.x + math.random(-radius, radius)
   pos.z = center.z + math.random(-radius, radius)
end

local function eject_drops(drops, pos, radius)
   local drop_pos = vector.new(pos)
   for _, item in pairs(drops) do
      local count = item:get_count()
      local max = item:get_stack_max()
      if count > max then
	 item:set_count(max)
      end
      while count > 0 do
	 if count < max then
	    item:set_count(count)
	 end
	 rand_pos(pos, drop_pos, radius)
	 local obj = minetest.add_item(drop_pos, item)
	 if obj then
	    obj:get_luaentity().collect = true
	    obj:set_velocity({x=math.random(-3, 3), y=10,
			     z=math.random(-3, 3)})
	 end
	 count = count - max
      end
   end
end

local function add_drop(drops, item)
   item = ItemStack(item)
   local name = item:get_name()
   if loss_prob[name] ~= nil and math.random(1, loss_prob[name]) == 1 then
      return
   end

   local drop = drops[name]
   if drop == nil then
      drops[name] = item
   else
      drop:set_count(drop:get_count() + item:get_count())
   end
end

local function destroy(drops, pos, cid)
   if minetest.is_protected(pos, "") then
      return
   end
   local def = cid_data[cid]
   if def and def.on_blast then
      def.on_blast(vector.new(pos), 1)
      return
   end

   minetest.remove_node(pos)
   if def then
      local node_drops = minetest.get_node_drops(def.name, "")
      for _, item in ipairs(node_drops) do
	 add_drop(drops, item)
      end
   end
end


local function calc_velocity(pos1, pos2, old_vel, power)
   local vel = vector.direction(pos1, pos2)
   vel = vector.normalize(vel)
   vel = vector.multiply(vel, power)

   -- Divide by distance
   local dist = vector.distance(pos1, pos2)
   dist = math.max(dist, 1)
   vel = vector.divide(vel, dist)

   -- Add old velocity
   vel = vector.add(vel, old_vel)
   return vel
end

local function entity_physics(pos, radius)
   -- Make the damage radius larger than the destruction radius
   radius = radius * 2

   local objs = minetest.get_objects_inside_radius(pos, radius)
   for _, obj in pairs(objs) do
      local obj_pos = obj:get_pos()
      local obj_vel = obj:get_velocity()
      local dist = math.max(1, vector.distance(pos, obj_pos))

      if obj_vel ~= nil then
	 obj:set_velocity(calc_velocity(pos, obj_pos,
				       obj_vel, radius * 10))
      end

      local damage = (4 / dist) * radius
      local dir = vector.direction(pos, obj_pos)
      obj:punch(obj, 1000000, { full_punch_interval = 0, damage_groups = { fleshy = damage } }, dir)
   end
end

local function add_node_break_effects(pos, node, node_tile)
   minetest.add_particlespawner(
      {
         amount = 40,
         time = 0.1,
         pos = {
            min = vector.subtract(pos, 0.4),
            max = vector.add(pos, 0.4),
         },
         vel = {
            min = vector.new(-5, -5, -5),
            max = vector.new(5, 5, 5),
         },
         acc = vector.new(0, -9.81, 0),
         exptime = { min = 0.2, max = 0.6 },
         size = { min = 1.0, max = 1.5 },
         node = node,
	 node_tile = node_tile,
   })

end

local function add_explosion_effects(pos, radius)
   minetest.add_particlespawner(
      {
         amount = 128,
         time = 0.6,
         pos = {
            min = vector.subtract(pos, radius / 2),
            max = vector.add(pos, radius / 2),
         },
         vel = {
            min = vector.new(-20, -20, -20),
            max = vector.new(20, 20, 20),
         },
         acc = vector.zero(),
         exptime = { min = 0.2, max = 1.0 },
         size = { min = 16, max = 24 },
	 drag = vector.new(1,1,1),
         texture = {
	    name = "rp_tnt_smoke_anim_1.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
	    name = "rp_tnt_smoke_anim_2.png", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
	    name = "rp_tnt_smoke_anim_1.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
	    name = "rp_tnt_smoke_anim_2.png^[transformFX", animation = { type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 },
         },
   })
   minetest.add_particlespawner({
         amount = 1,
         time = 0.01,
         pos = pos,
         vel = vector.zero(),
         acc = vector.zero(),
         exptime = 1,
         size = radius*10,
         texture = "rp_tnt_smoke_ball_big.png",
         animation = { type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = -1, },
   })
   minetest.add_particlespawner({
         amount = 4,
         time = 0.25,
         pos = pos,
         vel = vector.zero(),
         acc = vector.zero(),
         exptime = { min = 0.6, max = 0.9 },
         size = { min = 8, max = 12 },
	 radius = { min = 0.5, max = math.max(0.6, radius*0.75) },
         texture = "rp_tnt_smoke_ball_medium.png",
         animation = { type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = -1, },
   })
   minetest.add_particlespawner({
         amount = 28,
         time = 0.5,
         pos = pos,
         vel = vector.zero(),
         acc = vector.zero(),
         exptime = { min = 0.5, max = 0.8 },
         size = { min = 6, max = 8 },
	 radius = { min = 1, max = math.max(1.1, radius+1) },
         texture = "rp_tnt_smoke_ball_small.png",
         animation = { type = "vertical_frames", aspect_w = 32, aspect_h = 32, length = -1, },
   })


end

local function emit_fuse_smoke(pos)
	local minpos = vector.add(pos, vector.new(1/16, 0.5, 4/16))
	local maxpos = vector.add(pos, vector.new(2/16, 0.5, 5/16))
	local minvel = vector.new(0.2 - 0.1, 2.0, 0.2 - 0.1)
	local maxvel = vector.new(-0.2 - 0.1, 0.0, -0.2 - 0.1)
	local acc = vector.new(0, -0.1, 0)
	return minetest.add_particlespawner({
		time = TNT_TIMER,
		amount = 40,
		pos = { min = minpos, max = maxpos },
		vel = { min = minvel, max = maxvel },
		acc = acc,
		exptime = { min = 0.05, max = 0.6 },
		size = { min = 0.25, max = 2.0 },
		collisiondetection = false,
		texture = {
			name = "tnt_smoke_fuse.png",
			alpha_tween = { 1, 0, start = 0.75 },
		},
	})
end


-- Ignite TNT at pos.
-- igniter: Optional player object of player who ignited it or nil if nobody
function tnt.burn(pos, igniter)
   local name = minetest.get_node(pos).name
   if tnt_enable and name == "rp_tnt:tnt" then
      minetest.set_node(pos, {name = "rp_tnt:tnt_burning"})

      if igniter then
         minetest.log("action", "[rp_tnt] TNT ignited by "..igniter:get_player_name().." at "..minetest.pos_to_string(pos, 0))
      else
         minetest.log("action", "[rp_tnt] TNT ignited at "..minetest.pos_to_string(pos, 0))
      end
   end
end

local function play_tnt_sound(pos, sound)
   minetest.sound_play(
      sound,
      {
         pos = pos,
         gain = 1.5,
         max_hear_distance = 128
   }, true)
end

-- TNT ground removal

function tnt.explode(pos, radius)
   local pos = vector.round(pos)
   local vm = VoxelManip()
   local pr = PseudoRandom(os.time())
   local p1 = vector.subtract(pos, radius)
   local p2 = vector.add(pos, radius)
   local minp, maxp = vm:read_from_map(p1, p2)
   local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
   local data = vm:get_data()

   local drops = {}
   local p = {}

   local c_air = minetest.get_content_id("air")

   for z = -radius, radius do
      for y = -radius, radius do
	 local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	 for x = -radius, radius do
	    if (x * x) + (y * y) + (z * z) <= (radius * radius) + pr:next(-radius, radius) then
	       local cid = data[vi]
	       p.x = pos.x + x
	       p.y = pos.y + y
	       p.z = pos.z + z
	       if cid ~= c_air then
		  destroy(drops, p, cid)
		  minetest.check_for_falling({x=p.x, y=p.y, z=p.z})
	       end
	    end
	    vi = vi + 1
	 end
      end
   end

   return drops
end

-- TNT node explosion

local function rawboom(pos, radius, sound, remove_nodes, is_tnt)
   if is_tnt then
      local node = minetest.get_node(pos)
      minetest.remove_node(pos)
      add_node_break_effects(pos, node, 0)
      if is_tnt and not tnt_enable then
          minetest.check_for_falling({x=pos.x, y=pos.y, z=pos.z})
          return
      end
   end
   if remove_nodes then
      local drops = tnt.explode(pos, radius, sound)
      play_tnt_sound(pos, sound)
      if is_tnt then
          minetest.log("action", "[rp_tnt] TNT exploded at "..minetest.pos_to_string(pos, 0))
      else
          minetest.log("action", "[rp_tnt] Explosion at "..minetest.pos_to_string(pos, 0))
      end
      entity_physics(pos, radius)
      eject_drops(drops, pos, radius)
   else
      entity_physics(pos, radius)
      play_tnt_sound(pos, sound)
   end
   add_explosion_effects(pos, radius)
end


function tnt.boom(pos, radius, sound)
   if not radius then
      radius = tnt_radius
   end
   if not sound then
      sound = "tnt_explode"
   end
   rawboom(pos, radius, sound, true, true)
end

function tnt.boom_notnt(pos, radius, sound, remove_nodes)
   if not radius then
      radius = tnt_radius
   end
   if not sound then
      sound = "tnt_explode"
   end
   if remove_nodes == nil then
      remove_nodes = tnt_enable
   end
   rawboom(pos, radius, sound, remove_nodes, false)
end

-- On load register content IDs

local function on_load()
   for name, def in pairs(minetest.registered_nodes) do
      cid_data[minetest.get_content_id(name)] = {
         name = name,
         drops = def.drops,
         on_blast = def.on_blast,
      }
   end
end

minetest.register_on_mods_loaded(on_load)

-- Nodes

local top_tex, desc, tt
if tnt_enable then
   top_tex = "tnt_top.png"
   desc = S("TNT")
   tt = S("Will explode when ignited by flint and steel")
else
   top_tex = "tnt_top_disabled.png"
   desc = S("TNT (defused)")
   tt = S("It's harmless")
end

minetest.register_node(
   "rp_tnt:tnt",
   {
      description = desc,
      _tt_help = tt,
      tiles = {top_tex, "tnt_bottom.png", "tnt_sides.png"},
      is_ground_content = false,
      groups = {handy = 2, interactive_node=1},
      sounds = rp_sounds.node_sound_wood_defaults(),

      on_punch = function(pos, node, puncher)
         if not tnt_enable then
            return
         end
         local item = puncher:get_wielded_item()
         local itemname = item:get_name()

         if itemname == "rp_default:flint_and_steel" then
            if minetest.is_protected(pos, puncher:get_player_name()) and
                    not minetest.check_player_privs(puncher, "protection_bypass") then
                minetest.record_protection_violation(pos, puncher:get_player_name())
                return
            end
	    if not minetest.is_creative_enabled(puncher:get_player_name()) then
                item:add_wear_by_uses(82)
                puncher:set_wielded_item(item)
            end
            tnt.burn(pos, puncher)
            achievements.trigger_achievement(puncher, "boom")
         end
      end,
      on_blast = function(pos, intensity)
         if tnt_enable then
            tnt.burn(pos)
         end
      end,
})

local tnt_burning_on_timer = function(pos)
	tnt.boom(pos)
end

-- Nodes

minetest.register_node(
   "rp_tnt:tnt_burning",
   {
      description = S("TNT (ignited)"),
      _tt_help = S("Will explode after being placed"),
      tiles = {
	 {
	    name = "tnt_top_burning.png",
	    animation = {
	       type = "vertical_frames",
	       aspect_w = 16,
	       aspect_h = 16,
	       length = 1,
	    }
	 },
	 "tnt_bottom.png", "tnt_sides.png"},
      light_source = 5,
      drop = "",
      is_ground_content = false,
      groups = {handy = 2, not_in_creative_inventory=1},
      sounds = rp_sounds.node_sound_wood_defaults(),
      on_timer = tnt_burning_on_timer,
      on_construct = function(pos)
	  if tnt_enable then
             local timer = minetest.get_node_timer(pos)
             minetest.sound_play("tnt_ignite", {pos = pos}, true)
             local id = emit_fuse_smoke(pos)
	     if id ~= -1 then
                local hash = minetest.hash_node_position(pos)
                particlespawners[hash] = id
                minetest.after(TNT_TIMER, function()
                   if particlespawners[hash] == id then
                      particlespawners[hash] = nil
	           end
                end)
             end
             timer:start(TNT_TIMER)
          else
             minetest.set_node(pos, {name="rp_tnt:tnt"})
	  end
      end,
      after_destruct = function(pos)
         local hash = minetest.hash_node_position(pos)
         local id = particlespawners[hash]
	 if id then
            minetest.delete_particlespawner(id)
            particlespawners[hash] = nil
	 end
      end,
      on_blast = function(pos)
	  -- Force timer to restart if the timer was halted for some reason
          local timer = minetest.get_node_timer(pos)
	  if not timer:is_started() then
             minetest.sound_play("tnt_ignite", {pos = pos}, true)
             timer:start(TNT_TIMER)
	  end
      end,
})


-- Crafting

crafting.register_craft(
   {
      output = "rp_tnt:tnt",
      items = {
         "group:planks 4",
         "rp_default:flint_and_steel",
      }
})

-- Achievements

local title, desc
if tnt_enable then
   achievements.register_achievement(
      "boom",
      {
         title = S("Boom!"),
         description = S("Ignite TNT."),
         times = 1,
         item_icon = "rp_tnt:tnt_burning",
   })
else
   achievements.register_achievement(
      "boom",
      {
         title = S("Boom?"),
         description = S("Craft defused TNT."),
         times = 1,
         craftitem = "rp_tnt:tnt",
   })
end

-- Load aliases
dofile(minetest.get_modpath("rp_tnt").."/aliases.lua")
