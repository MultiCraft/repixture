-- Walker by KaadmY

local S = minetest.get_translator("mobs")

mobs:register_mob(
   "mobs:walker",
   {
      type = "monster",
      mob_name = S("Walker"),
      passive = false,
      attack_type = "dogfight",
      damage = 3,
      hp_min = 8,
      hp_max = 16,
      breath_max = -1,
      armor = 200,
      collisionbox = {-0.3, 0, -0.3, 0.3, 1.5, 0.3},
      selectionbox = {-0.3, 0, -0.3, 0.3, 1.5, 0.3, rotate=true},
      visual = "mesh",
      mesh = "mobs_walker.b3d",
      textures = {
	 {"mobs_walker.png"},
      },
      makes_footstep_sound = true,
      sounds = {
	 attack = "mobs_swing",
	 distance = 16,
      },
      walk_velocity = 1,
      run_velocity = 3,
      jump = true,
      view_range = 14,
      drops = {
	 {
	    name = "rp_default:stick",
	    chance = 1, min = 1, max = 2
	 },
	 {
	    name = "rp_default:stick",
	    chance = 3, min = 2, max = 4
	 },
	 {
	    name = "rp_default:fiber",
	    chance = 15, min = 2, max = 3
	 },
      },
      water_damage = 2,
      lava_damage = 30,
      animation = {
	 speed_normal = 20,
	 speed_run = 20,
	 stand_start = 0,
	 stand_end = 24,
	 punch_start = 25,
	 punch_end = 34,
	 walk_start = 35,
	 walk_end = 50,
	 run_start = 35,
	 run_end = 50,
      },
})

mobs:register_spawn(
   "mobs:walker",
   {
      "rp_default:dry_dirt",
      "rp_default:dirt_with_dry_grass"
   },
   20,
   14,
   12000,
   1,
   31000
)

mobs:register_egg("mobs:walker", S("Walker"), "mobs_walker_inventory.png")
