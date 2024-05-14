
--
-- TNT mod
--
local S = minetest.get_translator("rp_tnt")
local NS = function(s) return s end

-- Time in seconds before TNT explodes after ignited
local TNT_TIMER = 2.0

-- For performance debugging
local TNT_NO_SOUNDS = false
local TNT_NO_PARTICLES = false

tnt = {}

local particlespawners = {}

-- Default to enabled in singleplayer and disabled in multiplayer

local singleplayer = minetest.is_singleplayer()
local setting = minetest.settings:get_bool("tnt_enable")
local mod_attached = minetest.get_modpath("rp_attached") ~= nil
local mod_death_messages = minetest.get_modpath("rp_death_messages") ~= nil

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
   ["group:dirt"] = 4,
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

-- Checks if the given item would be lost
local check_loss = function(itemname)
   if loss_prob[itemname] ~= nil then
      if math.random(1, loss_prob[itemname]) == 1 then
         return true
      end
   else
      for k,v in pairs(loss_prob) do
         if string.sub(k, 1, 6) == "group:" then
            local group = string.sub(k, 7)
            if minetest.get_item_group(itemname, group) ~= 0 then
               if math.random(1, v) == 1 then
                  return true
	       end
	    end
	 end
      end
   end
   return false
end

local function add_drop(drops, item)
   item = ItemStack(item)
   local name = item:get_name()
   if check_loss(name) then
      return
   end

   local drop = drops[name]
   if drop == nil then
      drops[name] = item
   else
      drop:set_count(drop:get_count() + item:get_count())
   end
end

local function check_destroy(drops, pos, cid)
   if minetest.is_protected(pos, "") then
      return false, "protected"
   end
   local def = cid_data[cid]
   if def and def.on_blast then
      return false, "on_blast"
   end

   if def then
      local node_drops = minetest.get_node_drops(def.name, "")
      for _, item in ipairs(node_drops) do
	 add_drop(drops, item)
      end
   end
   return true
end


local function calc_velocity(pos1, pos2, power)
   local vel = vector.direction(pos1, pos2)
   vel = vector.normalize(vel)
   vel = vector.multiply(vel, power)

   -- Divide by distance
   local dist = vector.distance(pos1, pos2)
   dist = math.max(dist, 1)
   vel = vector.divide(vel, dist)

   return vel
end

local function add_node_break_effects(pos, node, node_tile)
   if TNT_NO_PARTICLES then
      return
   end
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


local function emit_fuse_smoke(pos)
	if TNT_NO_PARTICLES then
		return
	end
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
         achievements.trigger_achievement(igniter, "boom")
         if igniter:is_player() then
            local meta = minetest.get_meta(pos)
            meta:set_string("igniter", igniter:get_player_name())
         end
         minetest.log("action", "[rp_tnt] TNT ignited by "..igniter:get_player_name().." at "..minetest.pos_to_string(pos, 0))
      else
         minetest.log("verbose", "[rp_tnt] TNT ignited at "..minetest.pos_to_string(pos, 0))
      end
   end
end

function tnt.explode(pos, radius, sound, remove_nodes, causer)
   rp_explosions.explode(pos, radius, {
      sound=sound,
      griefing=remove_nodes,
      death_message=NS("You were blasted away by TNT."),
   }, causer)
end

-- TNT node explosion

local function rawboom(pos, radius, sound, remove_nodes, is_tnt, igniter)
   if is_tnt then
      local node = minetest.get_node(pos)
      minetest.remove_node(pos)
      add_node_break_effects(pos, node, 0)
      if is_tnt and not tnt_enable then
          local pp = {x=pos.x, y=pos.y, z=pos.z}
          minetest.check_for_falling(pp)
          if mod_attached then
             rp_attached.detach_from_node(pp)
          end
          return
      end
   end
   if remove_nodes then
      tnt.explode(pos, radius, sound, remove_nodes, igniter)
      if is_tnt then
          minetest.log("verbose", "[rp_tnt] TNT exploded at "..minetest.pos_to_string(pos, 0))
      else
          minetest.log("verbose", "[rp_tnt] Explosion at "..minetest.pos_to_string(pos, 0))
      end
      --eject_drops(drops, pos, radius)
   end
end


function tnt.boom(pos, radius, sound, igniter)
   if not radius then
      radius = tnt_radius
   end
   if not sound then
      sound = "tnt_explode"
   end
   rawboom(pos, radius, sound, true, true, igniter)
end

function tnt.boom_notnt(pos, radius, sound, remove_nodes, igniter)
   if not radius then
      radius = tnt_radius
   end
   if not sound then
      sound = "tnt_explode"
   end
   if remove_nodes == nil then
      remove_nodes = tnt_enable
   end
   rawboom(pos, radius, sound, remove_nodes, false, igniter)
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
      _rp_tt_has_ignitible_text = true, -- prevent rp_tt mod from adding automatic tooltip
      tiles = {top_tex, "tnt_bottom.png", "tnt_sides.png"},
      is_ground_content = false,
      groups = {handy = 2, interactive_node=1},
      sounds = rp_sounds.node_sound_wood_defaults(),

      on_blast = function(pos, intensity)
         if tnt_enable then
            tnt.burn(pos)
         end
      end,
      _rp_on_ignite = function(pos, itemstack, user)
         if not tnt_enable then
            return
         end
         tnt.burn(pos, user)
         return { sound = false }
      end,
})

local tnt_burning_on_timer = function(pos)
	local meta = minetest.get_meta(pos)
	local igniter_name = meta:get_string("igniter")
	local igniter = minetest.get_player_by_name(igniter_name)
	tnt.boom(pos, nil, nil, igniter)
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
             if TNT_NO_SOUNDS == false then
                minetest.sound_play("tnt_ignite", {pos = pos}, true)
             end
             local id = emit_fuse_smoke(pos)
	     if id ~= -1 and TNT_NO_PARTICLES == false then
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
         if TNT_NO_PARTICLES then
            return
         end
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
             if TNT_NO_SOUNDS == false then
                minetest.sound_play("tnt_ignite", {pos = pos}, true)
             end
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
         -- Use inventorycube to make sure the icon renders correctly
         icon = minetest.inventorycube("tnt_top_burning_static.png", "tnt_sides.png", "tnt_sides.png"),
	 difficulty = 4.9,
   })
else
   achievements.register_achievement(
      "boom",
      {
         title = S("Boom?"),
         description = S("Craft defused TNT."),
         times = 1,
         craftitem = "rp_tnt:tnt",
         -- difficulty slightly lower than for “Boom!” because of fewer materials required
	 difficulty = 4.6,
   })
end

-- Load aliases
dofile(minetest.get_modpath("rp_tnt").."/aliases.lua")
