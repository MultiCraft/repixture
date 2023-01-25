-- Boar by KrupnoPavel
-- Changed to Skunk and tweaked by KaadmY
local S = minetest.get_translator("mobs")

mobs:register_mob(
   "mobs:skunk",
   {
      type = "animal",
      mob_name = S("Skunk"),
      passive = false,
      attack_type = "dogfight",
      damage = 1,
      breath_max = 7,
      hp_min = 16,
      hp_max = 22,
      armor = 130,
      collisionbox = {-0.2, -0.45, -0.2, 0.2, 0.1, 0.2},
      visual = "mesh",
      mesh = "mobs_skunk.x",
      textures = {
	 {"mobs_skunk.png"},
      },
      makes_footstep_sound = true,
      sounds = {
	 attack = "mobs_skunk_hiss",
	 damage = "mobs_skunk_hiss",
	 death = "mobs_skunk_hiss",
	 eat = "mobs_eat",
	 distance = 16,
      },
      walk_velocity = 1.5,
      run_velocity = 2,
      jump = true,
      follow = "rp_default:apple",
      view_range = 15,
      drops = {
	 {name = "mobs:meat_raw",
	  chance = 1, min = 1, max = 2},
      },
      water_damage = 0,
      lava_damage = 7,
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
         mobs:feed_tame(self, clicker, 6, true)
         mobs:capture_mob(self, clicker, 10, 40, 20, false, nil)
      end,
})

mobs:register_spawn(
   "mobs:skunk",
   {
      "rp_default:dirt_with_swamp_grass",
      "rp_default:dirt_with_dry_grass"
   },
   20,
   7,
   12000,
   2,
   50
)

mobs:register_egg("mobs:skunk", S("Skunk"), "mobs_skunk_inventory.png")
