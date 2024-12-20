rp_player = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local ANIMATION_BLEND = 0

-- Animation speed factor when sneaking
local ANIM_SPEED_SNEAK = 0.6

rp_player.registered_models = {}

-- Local for speed.
local models = rp_player.registered_models

local function collisionbox_or_selectionbox_equals(box, other_box)
	if box == other_box then
		return true
	end
	for index = 1, 6 do
		if box[index] ~= other_box[index] then
			return false
		end
	end
	return true
end

function rp_player.player_register_model(name, def)
	models[name] = def
	def.visual_size = def.visual_size or {x = 1, y = 1}
	def.collisionbox = def.collisionbox or {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}
	def.selectionbox = def.selectionbox or def.collisionbox
	def.stepheight = def.stepheight or 0.6
	def.eye_height = def.eye_height or 1.47

	-- Sort animations into property classes:
	-- Animations with same properties have the same _equals value
	for animation_name, animation in pairs(def.animations) do
		animation.eye_height = animation.eye_height or def.eye_height
		animation.collisionbox = animation.collisionbox or def.collisionbox
		animation.selectionbox = animation.selectionbox or def.selectionbox
		animation.override_local = animation.override_local or false

		for _, other_animation in pairs(def.animations) do
			if other_animation._equals then
				if collisionbox_or_selectionbox_equals(animation.collisionbox, other_animation.collisionbox)
						and collisionbox_or_selectionbox_equals(animation.selectionbox, other_animation.selectionbox)
						and animation.eye_height == other_animation.eye_height then
					animation._equals = other_animation._equals
					break
				end
			end
		end
		animation._equals = animation._equals or animation_name
	end
end

-- Player stats and animations
-- model, textures, animation
local players = {}
rp_player.player_attached = {}

local function get_player_data(player)
	return assert(players[player:get_player_name()])
end

function rp_player.player_get_animation(player)
	return get_player_data(player)
end

-- Called when a player's appearance needs to be updated
function rp_player.player_set_model(player, model_name)
	local player_data = get_player_data(player)
	if player_data.model == model_name then
		return
	end
	-- Update data
	player_data.model = model_name
	-- Clear animation data as the model has changed
	-- (required for setting the `stand` animation not to be a no-op)
	player_data.animation, player_data.animation_speed, player_data.animation_loop = nil, nil, nil

	local model = models[model_name]
	if model then
		player:set_properties({
			mesh = model_name,
			textures = player_data.textures or model.textures,
			visual = "mesh",
			visual_size = model.visual_size,
			stepheight = model.stepheight
		})
		-- sets local_animation, collisionbox, selectionbox & eye_height
		rp_player.player_set_animation(player, "stand")
	else
		player:set_properties({
			textures = {"player.png", "player_back.png"},
			visual = "upright_sprite",
			visual_size = {x = 1, y = 2},
			collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3},
			selectionbox = {-0.3, 0.0, -0.3, 0.3, 1.75, 0.3, rotate = true},
			stepheight = 0.6,
			eye_height = 1.625,
		})
	end
end

function rp_player.player_get_textures(player)
	local player_data = get_player_data(player)
	local model = models[player_data.model]
	return assert(player_data.textures or (model and model.textures))
end

function rp_player.player_set_textures(player, textures)
	local player_data = get_player_data(player)
	local model = models[player_data.model]
	local new_textures = assert(textures or (model and model.textures))
	player_data.textures = new_textures
	player:set_properties({textures = new_textures})
end

function rp_player.player_set_texture(player, index, texture)
	local textures = table.copy(rp_player.player_get_textures(player))
	textures[index] = texture
	rp_player.player_set_textures(player, textures)
end

function rp_player.player_set_animation(player, anim_name, speed, loop)
	local player_data = get_player_data(player)
	local model = models[player_data.model]
	if not (model and model.animations[anim_name]) then
		return
	end
	speed = speed or model.animation_speed
	if loop == nil then
		loop = true
	end
	if player_data.animation == anim_name
		and player_data.animation_speed == speed
		and player_data.animation_loop == loop
	then
		return
	end
	local previous_anim = model.animations[player_data.animation] or {}
	local anim = model.animations[anim_name]
	player_data.animation = anim_name
	player_data.animation_speed = speed
	player_data.animation_loop = loop
	-- If necessary change the local animation (only seen by the client of *that* player)
	-- `override_local` <=> suspend local animations while this one is active
	-- (this is basically a hack, proper engine feature needed...)
	if anim.override_local ~= previous_anim.override_local then
		if anim.override_local then
			local none = {x=0, y=0}
			player:set_local_animation(none, none, none, none, 1)
		else
			local a = model.animations -- (not specific to the animation being set)
			player:set_local_animation(
				a.stand, a.walk, a.mine, a.walk_mine,
				model.animation_speed or 30
			)
		end
	end
	-- Set the animation seen by everyone else
	player:set_animation(anim, speed, ANIMATION_BLEND, loop)
	-- Update related properties if they changed
	if anim._equals ~= previous_anim._equals then
		player:set_properties({
			collisionbox = anim.collisionbox,
			selectionbox = anim.selectionbox,
			eye_height = anim.eye_height
		})
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	players[name] = {}
	rp_player.player_attached[name] = false
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	players[name] = nil
	rp_player.player_attached[name] = nil
end)

-- Localize for better performance.
local player_set_animation = rp_player.player_set_animation
local player_attached = rp_player.player_attached

-- Prevent knockback for attached players
local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, ...)
	if player_attached[player:get_player_name()] then
		return 0
	end
	return old_calculate_knockback(player, ...)
end

-- Check each player and apply animations
function rp_player.globalstep()
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local player_data = players[name]
		local model = player_data and models[player_data.model]
		if model and not player_attached[name] then
			local controls = player:get_player_control()
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod * ANIM_SPEED_SNEAK
			end

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "lay")
			elseif controls.up or controls.down or controls.left or controls.right then
				if controls.LMB or controls.RMB then
					player_set_animation(player, "walk_mine", animation_speed_mod)
				else
					player_set_animation(player, "walk", animation_speed_mod)
				end
			elseif controls.LMB or controls.RMB then
				player_set_animation(player, "mine", animation_speed_mod)
			else
				player_set_animation(player, "stand", animation_speed_mod)
			end
		end
	end
end

-- Mods can modify the globalstep by overriding rp_player.globalstep
minetest.register_globalstep(function(...)
	rp_player.globalstep(...)
end)

