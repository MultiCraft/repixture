-- Set default stack sizes
minetest.nodedef_default.stack_max = 60
minetest.craftitemdef_default.stack_max = 60

-- Set default item swing sound (when punching air)
-- NOTE: To disable this for a particular item, set the `sound`
--       table explicitly for the item.
minetest.craftitemdef_default.sound = {
   punch_use_air = { name = "rp_default_swing_hand_air", gain = 0.1 },
}
minetest.tooldef_default.sound = minetest.craftitemdef_default.sound
minetest.nodedef_default.sound = minetest.craftitemdef_default.sound


