-- TODO: Change to rp_mobs_mobs when ready
local S = minetest.get_translator("mobs")

-- Warthog (boar) by KrupnoPavel
-- Changed to Boar and tweaked by KaadmY
--
rp_mobs.register_mob("rp_mobs_mobs:boar", {
	description = S("Boar"),
	drops = {"rp_mobs_mobs:pork_raw"},
	entity_definition = {
		hp_max = 20,
		collisionbox = {-0.5, -1, -0.5, 0.5, 0.1, 0.5},
		selectionbox = {-0.4, -1, -0.6, 0.4, 0.1, 0.7, rotate = true},
		visual = "mesh",
		mesh = "mobs_boar.x",
		textures = { "mobs_boar.png" },
		makes_footstep_sound = true,
		on_rightclick = function(self, clicker)
			rp_mobs.feed_tame(self, clicker, 8, true)
			rp_mobs.capture_mob(self, clicker, 0, 5, 40, false, nil)
		end,
		on_death = rp_mobs.on_death_default,
	},
})

rp_mobs.register_mob_item("rp_mobs_mobs:boar", "mobs_boar_inventory.png")
