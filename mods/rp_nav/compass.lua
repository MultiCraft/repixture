
--
-- Compass handling
--
local S = minetest.get_translator("rp_nav")

local wield_image_0 = "nav_compass_inventory_0.png"
local wield_image_1 = "nav_compass_inventory_1.png"

local function on_globalstep(dtime)
   for _, player in pairs(minetest.get_connected_players()) do
      local inv = player:get_inventory()

      local yaw = player:get_look_horizontal()
      local dir = math.floor(((yaw / math.pi) * 4) + 0.5)

      if dir < 0 then
	 dir = dir + 8
      end

      if dir >= 8 then
	 dir = 0
      end

      for i = 1, 8 do
	 local itemstack = inv:get_stack("main", i)
	 local item = minetest.registered_items[itemstack:get_name()]

	 if item ~= nil then
	    if item.groups.nav_compass then
	       inv:set_stack("main", i, ItemStack("rp_nav:compass_"..dir))
	    end
	 end
      end
   end
end

minetest.register_globalstep(on_globalstep)

-- Items

local d = S("Compass")
local t = S("It points to the North")

minetest.register_craftitem(
   "rp_nav:compass_0",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_0.png",
      wield_image = wield_image_0,

      groups = {nav_compass = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_1",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_1.png^[transformR90",
      wield_image = wield_image_1 .. "^[transformR90",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_2",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_0.png^[transformR90",
      wield_image = wield_image_0 .. "^[transformR90",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_3",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_1.png^[transformR180",
      wield_image = wield_image_1 .. "^[transformR180",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})


minetest.register_craftitem(
   "rp_nav:compass_4",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_0.png^[transformR180",
      wield_image = wield_image_0 .. "^[transformR180",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_5",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_1.png^[transformR270",
      wield_image = wield_image_1 .. "^[transformR270",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_6",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_0.png^[transformR270",
      wield_image = wield_image_0 .. "^[transformR270",

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_nav:compass_7",
   {
      description = d,
      _tt_help = t,

      inventory_image = "nav_compass_inventory_1.png",
      wield_image = wield_image_1,

      groups = {nav_compass = 1, not_in_creative_inventory = 1},
      stack_max = 1,
})

minetest.register_alias("rp_nav:compass", "rp_nav:compass_0")

-- Crafting

crafting.register_craft(
   {
      output = "rp_nav:compass",
      items = {
         "rp_default:ingot_steel 4",
         "rp_default:stick",
      }
})

-- Achievements

achievements.register_achievement(
   "true_navigator",
   {
      title = S("True Navigator"),
      description = S("Craft a compass."),
      times = 1,
      craftitem = "rp_nav:compass_0",
})

minetest.register_alias("nav:compass", "rp_nav:compass_0")
for i=0, 7 do
	minetest.register_alias("nav:compass_"..i, "rp_nav:compass_"..i)
end

default.log("compass", "loaded")
