
-- Sheep by PilzAdam; tweaked for Pixture by KaadmY

local S = minetest.get_translator("mobs")

mobs:register_mob(
   "mobs:sheep",
   {
      type = "animal",
      passive = true,
      hp_min = 10,
      hp_max = 14,
      breath_max = 5,
      armor = 200,
      collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
      visual = "mesh",
      mesh = "mobs_sheep.x",
      visual_size = {x = 1, y = 1},
      textures = {
	 {"mobs_sheep.png"},
      },
      gotten_texture = {"mobs_sheep_shaved.png"},
      --      gotten_mesh = "mobs_sheep.x",
      makes_footstep_sound = true,
      sounds = {
	 random = "mobs_sheep",
	 death = "mobs_sheep",
	 damage = "mobs_sheep",
	 distance = 16,
      },
      walk_velocity = 1,
      walk_chance = 150,
      jump = false,
      jump_height = 5,
      drops = {
	 {name = "mobs:meat_raw",
	  chance = 1, min = 2, max = 4},
	 {name = "mobs:wool",
	  chance = 1, min = 1, max = 2},
      },
      water_damage = 0,
      lava_damage = 5,
      light_damage = 0,
      animation = {
	 speed_normal = 15,
	 speed_run = 25,
	 stand_start = 0,
	 stand_end = 60,
	 walk_start = 61,
	 walk_end = 80,
      },
      follow = "farming:wheat",
      view_range = 5,
      replace_rate = 50,
      replace_what = {
         "default:grass",
         "default:tall_grass",
         "farming:wheat_3",
         "farming:wheat_4"
      },
      replace_with = "air",
      replace_offset = -1,

      on_replace = function(self, pos)
         minetest.set_node(pos, {name = self.replace_with})

         if mobs:feed_tame(self, self.follow, 8, true) then
            if self.gotten == false then
               self.object:set_properties(
                  {
                     textures = {"mobs_sheep.png"},
                     mesh = "mobs_sheep.x",
               })
            end
         end
      end,
      on_rightclick = function(self, clicker)
         -- Are we feeding?

         if mobs:feed_tame(self, clicker, 8, true) then
            -- If full grow, add fuzz

            if self.gotten == false then
               self.object:set_properties(
                  {
                     textures = {"mobs_sheep.png"},
                     mesh = "mobs_sheep.x",
               })
            end

            return
         end

         local item = clicker:get_wielded_item()
         local itemname = item:get_name()

         -- Are we giving a haircut?

         if minetest.get_item_group(itemname, "shears") > 0 then
            if self.gotten == false and self.child == false then
               self.gotten = true -- shaved
               local pos = self.object:get_pos()
               pos.y = pos.y + 0.5
               local obj = minetest.add_item(pos, ItemStack("mobs:wool"))
               minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = clicker:get_pos(), max_hear_distance = 8}, true)
               if obj then
                  obj:set_velocity(
                     {
                        x = math.random(-1,1),
                        y = 5,
                        z = math.random(-1,1)
                  })
               end
               if not minetest.settings:get_bool("creative_mode") then
                   local def = item:get_definition()
                   local cuts = minetest.get_item_group(itemname, "sheep_cuts")
                   if cuts > 0 then
                      item:add_wear(math.floor(65535 / cuts))
                   else
                      item:add_wear(math.floor(65535 / def.tool_capabilities.snappy.uses))
                   end
               end
               clicker:set_wielded_item(item)
               self.object:set_properties(
                  {
                     textures = {"mobs_sheep_shaved.png"},
                     mesh = "mobs_sheep.x",
               })
            end

            return
         end

         -- Are we capturing?

         mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
      end,

})

mobs:register_spawn(
   "mobs:sheep",
   {
      "default:dirt_with_grass"
   },
   20,
   10,
   15000,
   1,
   31000
)

mobs:register_egg("mobs:sheep", S("Sheep"), "mobs_sheep_inventory.png")
