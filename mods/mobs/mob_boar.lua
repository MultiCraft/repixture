
-- Warthog(Boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY

local S = minetest.get_translator("mobs")

mobs:register_mob(
   "mobs:boar",
   {
      type = "animal",
      passive = false,
      attack_type = "dogfight",
      damage = 2,
      hp_min = 16,
      hp_max = 20,
      breath_max = 5,
      armor = 200,
      collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
      visual = "mesh",
      mesh = "mobs_boar.x",
      textures = {
	 {"mobs_boar.png"},
      },
      makes_footstep_sound = true,
      sounds = {
	 random = "mobs_boar",
	 damage = "mobs_boar",
	 attack = "mobs_boar_angry",
	 death = "mobs_boar_angry",
	 eat = "mobs_eat",
	 distance = 16,
      },
      walk_velocity = 2,
      run_velocity = 3,
      jump = false,
      follow = "rp_default:acorn",
      view_range = 10,
      drops = {
	 {name = "mobs:pork_raw",
	  chance = 1, min = 1, max = 4},
      },
      water_damage = 0,
      lava_damage = 5,
      light_damage = 0,
      animation = {
	 speed_normal = 20,
	 stand_start = 0,
	 stand_end = 60,
	 walk_start = 61,
	 walk_end = 80,
	 punch_start = 90,
	 punch_end = 101,
      },

      on_rightclick = function(self, clicker)
         mobs:feed_tame(self, clicker, 8, true)

         mobs:capture_mob(self, clicker, 0, 5, 40, false, nil)
      end,
})

mobs:register_spawn(
   "mobs:boar",
   {
      "rp_default:dirt_with_grass"
   },
   20,
   10,
   15000,
   1,
   31000
)

mobs:register_egg("mobs:boar", S("Boar"), "mobs_boar_inventory.png")

-- Raw porkchop

minetest.register_craftitem(
   "mobs:pork_raw",
   {
      description = S("Raw Porkchop"),
      _rp_hunger_food = 4,
      _rp_hunger_sat = 30,
      inventory_image = "mobs_pork_raw.png",
      groups = { food = 2 },
      on_use = minetest.item_eat(0),
})

-- Cooked porkchop

minetest.register_craftitem(
   "mobs:pork",
   {
      description = S("Cooked Porkchop"),
      _rp_hunger_food = 8,
      _rp_hunger_sat = 50,
      inventory_image = "mobs_pork_cooked.png",
      groups = { food = 2 },
      on_use = minetest.item_eat(0),
})

minetest.register_craft(
   {
      type = "cooking",
      output = "mobs:pork",
      recipe = "mobs:pork_raw",
      cooktime = 5,
})
