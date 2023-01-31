local S = minetest.get_translator("rp_fire")

local LIGHT = 10

local burnout_effect = function(pos)
   -- Spawn burnout particle
   local ppos, vel
   local vel = vector.new(0, 0.6, 0)
   ppos = vector.add(pos, vector.new(0, -0.4, 0))
   vel = vector.new(math.random(-10, 10)*0.001, math.random(50, 70)*0.01, math.random(-10, 10)*0.001)
   local anim = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = -1 }
   minetest.add_particlespawner({
      amount = 1,
      time = 0.001,
      pos = ppos,
      vel = vel,
      exptime = 1,
      size = 5.75,
      texpool = {
         {name = "rp_default_torch_smoke_anim.png", animation = anim},
         {name = "rp_default_torch_smoke_anim.png^[transformFX", animation = anim},
      },
   })
   -- Sound
   minetest.sound_play({name="rp_default_torch_burnout", gain=0.2, max_hear_distance = 16}, {pos=pos}, true)
end

minetest.register_node(
   "rp_fire:bonfire",
   {
      description = S("Bonfire"),
      _tt_light_source_max = LIGHT,
      drawtype = "mesh",
      mesh = "rp_fire_bonfire.obj",
      paramtype = "light",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, -6/16, 6/16},
      },
      tiles = {"rp_fire_bonfire_stones.png", "rp_fire_bonfire_ground.png", "blank.png"},
      inventory_image = "rp_fire_bonfire_inventory.png",
      wield_image = "rp_fire_bonfire_inventory.png",
      use_texture_alpha = "clip",
      floodable = true,
      on_flood = function(pos, oldnode, newnode)
         minetest.add_item(pos, "rp_fire:bonfire")
      end,
      walkable = false,
      groups = {cracky = 3, bonfire = 1, attached_node = 1},
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_on_ignite = function(pos, itemstack, user)
         minetest.set_node(pos, {name="rp_fire:bonfire_burning"})
	 return {}
      end,
})

minetest.register_node(
   "rp_fire:bonfire_burning",
   {
      description = S("Bonfire (burning)"),
      drawtype = "mesh",
      mesh = "rp_fire_bonfire.obj",
      paramtype = "light",
      selection_box = {
	 type = "fixed",
	 fixed = {-6/16, -0.5, -6/16, 6/16, -6/16, 6/16},
      },
      tiles = {
         "rp_fire_bonfire_stones.png",
         "rp_fire_bonfire_ground.png",
	 {name="rp_fire_bonfire_flame.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1}},
      },
      damage_per_second = 2,
      floodable = true,
      on_flood = function(pos, oldnode, newnode)
         minetest.sound_play({name="rp_default_torch_burnout", gain=0.2, max_hear_distance = 16}, {pos=pos}, true)
         minetest.add_item(pos, "rp_fire:bonfire")
      end,
      light_source = LIGHT,
      use_texture_alpha = "clip",
      groups = {cracky = 3, bonfine = 2, attached_node = 1, not_in_creative_inventory = 1, react_on_rain_hf = 1},
      walkable = false,
      drop = "rp_fire:bonfire",
      sounds = rp_sounds.node_sound_stone_defaults(),

      _rp_on_rain = function(pos, node)
          minetest.set_node(pos, {name="rp_fire:bonfire", param2 = node.param2})
          burnout_effect(pos)
	  minetest.log("action", "[rp_fire] Bonfire at "..minetest.pos_to_string(pos).." goes out in the rain")
      end,
})

crafting.register_craft({
    output = "rp_fire:bonfire",
    items = {
        "rp_default:gravel 4",
        "group:soil 4",
        "rp_default:stick 8",
    },
})
