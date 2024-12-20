local S = minetest.get_translator("rp_mobs")

--
-- Crafts and items
--

local play_swing_hit_sound = function(swing_player, hit_pos, swing_sound, hit_sound, hit_sound_gain, hit_sound_dist)
    minetest.sound_play(swing_sound, {
       object = swing_player,
       gain = hit_sound_gain,
       max_hear_distance = hit_sound_dist}, true)
    minetest.sound_play(hit_sound, {
       pos = hit_pos,
       gain = hit_sound_gain }, true)
end

-- on_use function for the mob capturing tools.
-- This triggers the _on_capture handler of
-- the mob, which might capture the mob.
local capture_tool_on_use = function(swing_sound, hit_sound, hit_sound_gain, hit_sound_dist)
    return function(itemstack, player, pointed_thing)
        if not player or not player:is_player() then
            return
        end
        if pointed_thing.type == "node" then
            play_swing_hit_sound(player, pointed_thing.above, swing_sound, hit_sound, hit_sound_gain, hit_sound_dist)
            return
        elseif pointed_thing.type ~= "object" then
            return
        end

        local ent = pointed_thing.ref:get_luaentity()
        if ent then
            if ent._cmi_is_mob and ent._on_capture then
                ent:_on_capture(player)
            else
                play_swing_hit_sound(player, ent.object:get_pos(), swing_sound, hit_sound, hit_sound_gain, hit_sound_dist)
            end
        end
    end
end

-- Net

minetest.register_tool(
   "rp_mobs:net",
   {
      description = S("Net"),
      _tt_help = S("Good for capturing small animals"),
      inventory_image = "mobs_net.png",
      on_use = capture_tool_on_use("mobs_swing_hit_swing", "mobs_swing_hit_hit", 0.2, 16),
      -- Note: no on_place function as mobs have their on_rightclick handlers
      sound = {
         punch_use_air = { name = "mobs_swing", gain = 0.2, max_hear_distance = 16 },
      },
})

crafting.register_craft(
   {
      output = "rp_mobs:net",
      items= {
         "rp_default:fiber 3",
         "rp_default:stick",
      }
})

rp_mobs.register_capture_tool("rp_mobs:net", { uses = 17, sound = "mobs_swing", sound_gain = 0.2, sound_max_hear_distance = 16})

-- Lasso

minetest.register_tool(
   "rp_mobs:lasso",
   {
      description = S("Lasso"),
      _tt_help = S("Good for capturing large animals"),
      inventory_image = "mobs_lasso.png",
      on_use = capture_tool_on_use("mobs_lasso_swing_hit_swing", "mobs_lasso_swing_hit_hit", 0.3, 24),
      sound = {
         punch_use_air = { name = "mobs_lasso_swing", gain = 0.3, max_hear_distance = 24 },
      }
})

crafting.register_craft(
   {
      output = "rp_mobs:lasso",
      items = {
         "rp_default:rope 4",
         "rp_default:stick",
      }
})

rp_mobs.register_capture_tool("rp_mobs:lasso", { uses = 43, sound = "mobs_lasso_swing", sound_gain = 0.3, sound_max_hear_distance = 24})


-- Compability with Repixture 3.12.1 and earlier
minetest.register_alias("mobs:net", "rp_mobs:net")
minetest.register_alias("mobs:lasso", "rp_mobs:lasso")
