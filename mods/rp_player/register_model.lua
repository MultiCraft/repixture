rp_player.player_register_model("character.b3d", {
	animation_speed = 33,
	textures = {"character.png"},
	animations = {
		-- Standard animations
		stand     = {x = 0,   y = 79},
		lay       = {x = 162, y = 166, eye_height = 0.3, override_local = true,
			collisionbox = { -0.6, 0, -0.6, 0.6, 0.2, 0.6 }
		},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		-- Extra animations
		sit      = { x = 81, y = 160, eye_height = 0.9, override_local = true,
			collisionbox = { -0.3, 0, -0.3, 0.3, 1, 0.3 }},
	},
	collisionbox = { -0.3, 0, -0.3, 0.3, 1.77, 0.3 },
	eye_height = 1.5,
	stepheight = 0.626, -- slightly above 10/16
})

minetest.register_on_joinplayer(function(player)
	rp_player.player_set_model(player, "character.b3d")
end)
