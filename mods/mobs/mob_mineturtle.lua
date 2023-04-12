
-- Mineturtle by KaadmY

local S = minetest.get_translator("mobs")

mobs:register_mob(
   "mobs:mineturtle",
   {
      type = "monster",
      mob_name = S("Mine Turtle"),
      passive = false,
      attack_type = "explode",
      hp_min = 10,
      hp_max = 15,
      breath_max = 20,
      armor = 200,
      collisionbox = {-0.4, 0, -0.4, 0.4, 0.7, 0.4},
      selectionbox = {-0.4, 0, -0.5, 0.4, 0.7, 0.8, rotate=true},
      visual = "mesh",
      mesh = "mobs_mineturtle.x",
      textures = {
	 {"mobs_mineturtle.png"},
      },
      makes_footstep_sound = false,
      sounds = {
	 war_cry = "mobs_mineturtle",
	 random = "mobs_mineturtle",
	 explode = "tnt_explode",
	 distance = 16,
      },
      walk_velocity = 2,
      run_velocity = 4,
      jump = true,
      view_range = 10,
      drops = {
	 {name = "rp_tnt:tnt",
	  chance = 1, min = 1, max = 3},
      },
      water_damage = 0,
      lava_damage = 5,
      light_damage = 0,
      takes_node_damage = false,
      animation = {
	 speed_normal = 25,
	 speed_run = 35,
	 stand_start = 0,
	 stand_end = 30,
	 run_start = 31,
	 run_end = 50,
	 walk_start = 31,
	 walk_end = 50,
	 punch_start = 51,
	 punch_end = 60,
      },
      on_die = function(self, pos, hitter)
         if hitter == nil or (hitter ~= nil and not hitter:is_player()) then
            return
         end

         achievements.trigger_achievement(hitter, "bomb_has_been_defused")
      end,
})

mobs:register_spawn(
   "mobs:mineturtle",
   {
      "rp_default:dirt_with_grass"
   },
   20,
   5,
   200000,
   1,
   31000
)

mobs:register_egg("mobs:mineturtle", S("Mine Turtle"), "mobs_mineturtle_inventory.png")
