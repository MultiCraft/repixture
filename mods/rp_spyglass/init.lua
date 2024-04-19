local S = minetest.get_translator("rp_spyglass")

local settings = {
	verify_s = 0.2, -- verify seconds (how long between each minetest.after to check if a player is still using a spyglass)
	fov_default = 0, -- global FOV for players (what spyglass will default to when exited)
	fov_zoom = 10, -- FOV value when zooming
	zoom_in_time = 0.4, -- how long it takes to zoom in (seconds)
	zoom_out_time = 0.1, -- how long it takes to zoom out (seconds)
	-- TODO: Spyglass HUD element is disabled because player can switch camera modes.
	-- Allow it as soon we can restrict camera modes.
	use_hud = false, -- whether to add a HUD element for the spyglass screen
}
local spyglass_users = {}

rp_spyglass = {}

-- check if player is using spyglass
local function is_spyglassing(player)
	local name = type(player) == "string" and player or minetest.is_player(player) and player:get_player_name() or nil
	if name and spyglass_users[name] then
		return true
	end
	return false
end
rp_spyglass.is_spyglassing = is_spyglassing

-- remove spyglass HUD from player
local function remove_scope(player)
	local p_name = minetest.is_player(player) and player:get_player_name()
	local data = spyglass_users[p_name or nil]
	if not data then
		return
	end
	minetest.sound_play("tph_spyglass_exit2",{pos = player:get_pos(), gain=1, max_hear_distance=8})
	if settings.use_hud and data.hud then
		player:hud_remove(data.hud)
	end

	rp_hud.set_hud_flag_semaphore(player, "rp_spyglass:spyglassing", "wielditem", true)

	spyglass_users[p_name] = nil
	player:set_fov(settings.fov_default, false, settings.zoom_out_time)
end
rp_spyglass.deactivate_spyglass = remove_scope

local function use_spyglass(player)
	if not minetest.is_player(player) then
		return
	end
	local p_name = player:get_player_name()
	-- check if player is using spyglass when using again, lower spyglass if so
	if is_spyglassing(p_name) then
		remove_scope(player)
		return
	end
	local hud_flags = player:hud_get_flags()
	local data = {
		hud = settings.use_hud and player:hud_add({
			name = "tph_spyglass",
			hud_elem_type = "image",
			text = "tph_spyglass_hud.png", -- image is 52x32, any texture pack or edit to the image should have a resolution that properly factors to said resolution or width = height*1.625
			position = {x = 0.5, y = 0.5},
			scale = { x = -100, y = -100},
			z_index = -350,
		}),
		index = player:get_wield_index(),
	}
	spyglass_users[p_name] = data

	-- Hide wielditem while spyglassing
	rp_hud.set_hud_flag_semaphore(player, "rp_spyglass:spyglassing", "wielditem", false)

	local spy_fov = settings.fov_zoom
	player:set_fov(spy_fov, false, settings.zoom_in_time)
	-- play sound
	minetest.sound_play("tph_spyglass_open", {pos = player:get_pos(), gain=1, max_hear_distance=8})
	-- verify if player is still using spyglass
	local function verify()
		-- not even using the spyglass (or invalid player)
		if not minetest.is_player(player) then
			return
		elseif not is_spyglassing(p_name) then
			return
		-- you changed slots!
		elseif player:get_wield_index() ~= data.index then
			remove_scope(player)
		-- wielded item is different
		elseif player:get_wielded_item():get_name() ~= "rp_spyglass:spyglass" then
			remove_scope(player)
		-- if FOV has been changed while in spyglass
		elseif player:get_fov() ~= spy_fov then
			remove_scope(player)
		else -- repeat verify check
			minetest.after(settings.verify_s, verify)
		end
	end
	verify()
end
rp_spyglass.toggle_spyglass = use_spyglass

minetest.register_craftitem("rp_spyglass:spyglass",{
	description = S("Spyglass"),
	_tt_help = S("Magnifies the view"),
	inventory_image = "tph_spyglass_icon.png",
	stack_max = 1,
	-- The control scheme differs from tph_spyglass;
	-- Repixture requires the [Punch] key for normal item use
	on_use = function(itemstack, user, pointed_thing)
		local is_looking = is_spyglassing(user)
		if is_looking then
			-- permit interacting with node after closing spyglass
			use_spyglass(user)
		end
		if not is_looking then
			-- don't run if we're already looking
			use_spyglass(user)
		end
	end,
})

crafting.register_craft({
	output = "rp_spyglass:spyglass",
	items = {
		"rp_default:glass 1",
		"rp_default:ingot_copper 3",
		"rp_default:stick 1",
	},
})
