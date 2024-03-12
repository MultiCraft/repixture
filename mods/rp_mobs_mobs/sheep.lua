-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

local mod_nav = minetest.get_modpath("rp_nav")

local top_grass = {
	["rp_default:grass"] = "air",
	["rp_default:tall_grass"] = "rp_default:grass",
	["rp_default:swamp_grass"] = "air",
	["rp_default:dry_grass"] = "air",
}
local dirt_cover = {
	["rp_default:dirt_with_swamp_grass"] = "rp_default:swamp_dirt",
	["rp_default:dirt_with_dry_grass"] = "rp_default:dirt",
	["rp_default:dirt_with_grass"] = "rp_default:dirt",
}

-- Time between random call sounds (ms)
local RANDOM_SOUND_TIMER_MIN = 10000
local RANDOM_SOUND_TIMER_MAX = 60000

-- Time to wait between eating grass (ms)
local EAT_GRASS_TIMER_MIN = 45000
local EAT_GRASS_TIMER_MAX = 75000

-- Mimimum time sheep has to stand still before eating (s)
local EAT_GRASS_STAND_TIMER = 0.7

-- Minimum time to wait before wool can regrow (s).
-- Timer starts after sheep is shorn.
local WOOL_REGROW_TIMER = 45.0

-- Wool drop count if shorn
local WOOL_SHEAR_MIN = 1
local WOOL_SHEAR_MAX = 3

-- Wool drop count if killed
local WOOL_DROP_MIN = 1
local WOOL_DROP_MAX = 1

-- Distance in which sheep can "see" player holding food
local VIEW_RANGE = 5

-- What the sheep eats
local FOOD = { "rp_farming:wheat" }

local task_queue_roam_settings = {
	walk_speed = 1,
	liquid_rise_speed = 2,
	jump_strength = 5,
	fall_height = 4,
	max_fall_damage_add_percent_drop_on = 10,
	walk_duration_min = 2000,
	walk_duration_max = 6000,
	find_land_duration_min = 7000,
	find_land_duration_max = 10000,
	find_safe_land_duration_min = 1000,
	find_safe_land_duration_max = 1100,
	idle_duration_min = 2000,
	idle_duration_max = 4000,
	find_land_length = 20,
	view_range = VIEW_RANGE,
	follow_reach_distance = 2,
	follow_give_up_time = 10.0,
	no_follow_time = 6.0,
}

local microtask_eat_grass = function()
	return rp_mobs.create_microtask({
		label = "Eat blocks and regrow wool",
		on_start = function(self, mob)
			self.statedata.stand_timer = 0
			self.statedata.eat_grass_timer = 0
			self.statedata.eat_grass_timer_goal = math.random(EAT_GRASS_TIMER_MIN, EAT_GRASS_TIMER_MAX)/1000
		end,
		on_step = function(self, mob, dtime)
			self.statedata.eat_grass_timer = self.statedata.eat_grass_timer + dtime
			if not mob._custom_state.wool_regrow_timer then
				mob._custom_state.wool_regrow_timer = 0
			end
			if mob._custom_state.shorn then
				mob._custom_state.wool_regrow_timer = mob._custom_state.wool_regrow_timer + dtime
			end

			if self.statedata.eat_grass_timer < self.statedata.eat_grass_timer_goal then
				return
			end

			local mobpos = mob.object:get_pos()

			local plantpos = {x=mobpos.x, y=mobpos.y-1, z=mobpos.z}
			local groundpos = {x=mobpos.x, y=mobpos.y-2, z=mobpos.z}
			local np = minetest.get_node(plantpos)
			local ng = minetest.get_node(groundpos)

			local vel = mob.object:get_velocity()
			-- Don't eat while moving
			if vector.length(vel) > 0.5 then
				self.statedata.stand_timer = 0
				return
			else
				self.statedata.stand_timer = self.statedata.stand_timer + dtime
			end
			-- Needs to have stood for a minimum amount of time before eating
			if self.statedata.stand_timer <= EAT_GRASS_STAND_TIMER then
				return
			end

			local eaten = false
			-- Eat grass
			if np.name == "air" then
				-- Eat grass from dirt node
				if dirt_cover[ng.name] then
					minetest.set_node(groundpos, {name = dirt_cover[ng.name]})
					eaten = true
				end
			elseif top_grass[np.name] then
				-- If grass plant on top, eat it first
				minetest.set_node(plantpos, {name = top_grass[np.name]})
				eaten = true
			end

			if eaten then
				self.statedata.eat_grass_timer_goal = math.random(EAT_GRASS_TIMER_MIN, EAT_GRASS_TIMER_MAX)/1000
				self.statedata.eat_grass_timer = 0
			end

			-- Regrow wool
			if eaten and mob._custom_state.shorn and mob._custom_state.wool_regrow_timer >= WOOL_REGROW_TIMER then
				mob.object:set_properties(
				{
					textures = {"mobs_sheep.png"},
				})
				mob._custom_state.shorn = false
				mob._custom_state.wool_regrow_timer = 0
			end
		end,
		is_finished = function(self, mob)
			return self.statedata.eaten
		end,
	})
end

-- Decide when to eat grass
local eat_decider = function(task_queue, mob)
	local task = rp_mobs.create_task({label="eat grass"})
	local mtask = microtask_eat_grass()
	rp_mobs.add_microtask_to_task(mob, mtask, task)

	rp_mobs.add_task_to_task_queue(task_queue, task)
end

rp_mobs.register_mob("rp_mobs_mobs:sheep", {
	description = S("Sheep"),
	is_animal = true,
	is_peaceful = true,
	drops = {
		{name="rp_mobs_mobs:meat_raw", chance=1, min=2, max=4},
	},
	drop_func = function(self)
		-- Drop wool if a non-shorn adult
		if (not self._child) and (self._custom_state and (not self._custom_state.shorn)) then
			local count = math.random(WOOL_DROP_MIN, WOOL_DROP_MAX)
			return { "rp_mobs_mobs:wool "..count }
		end
		return {}
	end,
	default_sounds = {
		death = "mobs_sheep",
		damage = "mobs_sheep",
		eat = "mobs_eat",
		call = "mobs_sheep",
		give_birth = "mobs_sheep",
		horny = "mobs_sheep",
	},
	animations = {
		["idle"] = { frame_range = { x = 0, y = 60 }, default_frame_speed = 15 },
		["dead_static"] = { frame_range = { x = 0, y = 0 } },
		["walk"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 15 },
		["run"] = { frame_range = { x = 61, y = 80 }, default_frame_speed = 25 },
	},
	front_body_point = vector.new(0, -0.4, 0.5),
	dead_y_offset = 0.6,
	entity_definition = {
		initial_properties = {
			hp_max = 14,
			physical = true,
			collisionbox = {-0.49, -1, -0.49, 0.49, 0.1, 0.49},
			selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
			visual = "mesh",
			mesh = "mobs_sheep.x",
			textures = { "mobs_sheep.png" },
			makes_footstep_sound = true,
			stepheight = 0.6,
		},
		on_activate = function(self, staticdata)
			rp_mobs.init_mob(self)
			rp_mobs.restore_state(self, staticdata)
			if self._custom_state.shorn then
				self.object:set_properties({
					textures = {"mobs_sheep_shaved.png"},
				})
			end

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 10,
				drowning_point = vector.new(0, -0.1, 0.49)
			})
			rp_mobs.init_node_damage(self, true)

			self.object:set_acceleration(rp_mobs.GRAVITY_VECTOR)
			rp_mobs.init_tasks(self)
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_land_animal_roam(task_queue_roam_settings))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_follow_scan(VIEW_RANGE, FOOD))
			rp_mobs.add_task_queue(self, rp_mobs.create_task_queue(eat_decider))
			rp_mobs.add_task_queue(self, rp_mobs_mobs.task_queue_call_sound(RANDOM_SOUND_TIMER_MIN, RANDOM_SOUND_TIMER_MAX))
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_dying(self, dtime)
			rp_mobs.scan_environment(self, dtime)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_tasks(self, dtime, moveresult)
			rp_mobs.advance_child_growth(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
		end,
		_on_capture = function(self, capturer)
			rp_mobs.attempt_capture(self, capturer, { ["rp_mobs:net"] = 5, ["rp_mobs:lasso"] = 60 })
		end,
		on_rightclick = function(self, clicker)
			local item = clicker:get_wielded_item()
			local itemname = item:get_name()

			-- Demagnetize magnocompass if sheep has wool
			if mod_nav then
				local compass_group = minetest.get_item_group(itemname, "nav_compass")
				if compass_group > 0 then
					if compass_group == 2 and (not self._custom_state.shorn) then
						item = nav.demagnetize_compass(item, clicker:get_pos())
						clicker:set_wielded_item(item)
						return
					end
					return
				end
			end

			-- Are we feeding?
			if rp_mobs.feed_tame_breed(self, clicker, FOOD, 8, 8) then
				-- Update wool status if shorn
				if not self._custom_state.shorn then
					self.object:set_properties({
						textures = {"mobs_sheep.png"},
					})
				end
				return
			end

			-- Are we shearing wool?
			if minetest.get_item_group(itemname, "shears") > 0 then
				if (not self._custom_state.shorn) and (not self._child) then
					self._custom_state.shorn = true
					local pos = self.object:get_pos()
					pos.y = pos.y + 0.5
					local count = math.random(WOOL_SHEAR_MIN, WOOL_SHEAR_MAX)
					local obj = rp_mobs.spawn_mob_drop(pos, ItemStack("mobs:wool "..count))
					minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = clicker:get_pos(), max_hear_distance = 8}, true)
					if not minetest.is_creative_enabled(clicker:get_player_name()) then
						local def = item:get_definition()
						local cuts = minetest.get_item_group(itemname, "sheep_cuts")
						if cuts > 0 then
							item:add_wear_by_uses(cuts)
						else
							if def and def.tool_capabilities and def.tool_capabilities.snappy then
								item:add_wear_by_uses(def.tool_capabilities.snappy.uses)
							end
						end
					end
					clicker:set_wielded_item(item)
					self.object:set_properties({
						textures = {"mobs_sheep_shaved.png"},
					})
					self._custom_state.wool_regrow_timer = 0
					achievements.trigger_achievement(clicker, "shear_time")
				end
				return
			end

			-- Are we capturing?
			rp_mobs.call_on_capture(self, clicker)
		end,

		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:sheep", "mobs_sheep_inventory.png", nil, function(mob, itemstack)
	if mob._custom_state.shorn then
		local meta = itemstack:get_meta()
		meta:set_string("inventory_image", "mobs_sheep_shaved_inventory.png")
		meta:set_string("wield_image", "mobs_sheep_shaved_inventory.png")
	end
	return itemstack
end)
