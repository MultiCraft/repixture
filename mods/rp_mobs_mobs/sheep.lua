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
	["rp_default:dirt_with_swamp_gras"] = "rp_default:swamp_dirt",
	["rp_default:dirt_with_dry_grass"] = "rp_default:dirt",
	["rp_default:dirt_with_grass"] = "rp_default:dirt",
}

microtask_eat_grass = function()
	return rp_mobs.create_microtask({
		label = "Eat blocks",
		singlestep = true,
		on_step = function(self, mob, dtime)
			local mobpos = mob.object:get_pos()

			local plantpos = {x=mobpos.x, y=mobpos.y-1, z=mobpos.z}
			local groundpos = {x=mobpos.x, y=mobpos.y-2, z=mobpos.z}
			local np = minetest.get_node(plantpos)
			local ng = minetest.get_node(groundpos)

			-- Eat grass
			if np.name == "air" then
				-- Eat grass from dirt node
				if dirt_cover[ng.name] then
					minetest.set_node(groundpos, {name = dirt_cover[ng.name]})
				else
					return
				end
			elseif top_grass[np.name] then
				-- If grass plant on top, eat it first
				minetest.set_node(plantpos, {name = top_grass[np.name]})
			else
				return
			end

			-- Regrow wool
			if mob._custom_state.shorn then
				mob.object:set_properties(
				{
					textures = {"mobs_sheep.png"},
				})
				mob._custom_state.shorn = false
			end
		end,
	})
end

rp_mobs.register_mob("rp_mobs_mobs:sheep", {
	description = S("Sheep"),
	is_animal = true,
	drops = {"rp_mobs_mobs:meat_raw", "rp_mobs_mobs:wool"},
	decider = function(self)
		local task = rp_mobs.create_task({label="eat grass"})
		rp_mobs.add_microtask_to_task(self, rp_mobs.microtasks.sleep(3.0), task)
		local mtask = microtask_eat_grass()
		rp_mobs.add_microtask_to_task(self, mtask, task)
		rp_mobs.add_task(self, task)
	end,
	default_sounds = {
		death = "mobs_sheep",
		damage = "mobs_sheep",
		eat = "mobs_eat",
	},
	entity_definition = {
		hp_max = 14,
		physical = true,
		collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
		selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
		visual = "mesh",
		mesh = "mobs_sheep.x",
		textures = { "mobs_sheep.png" },
		makes_footstep_sound = true,
		on_activate = function(self, staticdata)
			rp_mobs.restore_state(self, staticdata)
			if self._custom_state.shorn then
				self.object:set_properties({
					textures = {"mobs_sheep_shaved.png"},
				})
			end

			rp_mobs.init_fall_damage(self, true)
			rp_mobs.init_breath(self, true, {
				breath_max = 10,
				drowning_point = vector.new(0, -0.5, 0.49)
			})
			rp_mobs.init_node_damage(self, true)

			rp_mobs.init_physics(self)
			rp_mobs.activate_gravity(self)
			rp_mobs.init_tasks(self)
		end,
		get_staticdata = rp_mobs.get_staticdata_default,
		on_step = function(self, dtime, moveresult)
			rp_mobs.handle_environment_damage(self, dtime, moveresult)
			rp_mobs.handle_physics(self)
			rp_mobs.handle_tasks(self, dtime)
			rp_mobs.handle_breeding(self, dtime)
			rp_mobs.decide(self)
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
			if rp_mobs.feed_tame_breed(self, clicker, { "rp_farming:wheat" }, 8, true) then
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
					local obj = minetest.add_item(pos, ItemStack("mobs:wool"))
					minetest.sound_play({name = "default_shears_cut", gain = 0.5}, {pos = clicker:get_pos(), max_hear_distance = 8}, true)
					if obj then
						obj:set_velocity({
							x = math.random(-1,1),
							y = 5,
							z = math.random(-1,1)
						})
					end
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
					achievements.trigger_achievement(clicker, "shear_time")
				end
				return
			end

			-- Are we capturing?
			rp_mobs.handle_capture(self, clicker)
		end,

		on_death = rp_mobs.on_death_default,
		on_punch = rp_mobs.on_punch_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:sheep", "mobs_sheep_inventory.png")
