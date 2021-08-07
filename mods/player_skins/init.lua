--
-- Player skins mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("player_skins")

player_skins = {}

player_skins.skins = {}
player_skins.skindata_ids = {}

function player_skins.get_skin(name)
	if not player_skins.skins[name] then
		-- Fallback skin
		return "character.png"
	else
		return player_skins.skins[name]
	end
end

local components = {
	skin_colors = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	cloth_colors = { "red", "redviolet", "magenta", "purple", "blue", "cyan", "green", "yellow", "orange" },
	band_colors = { "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "turquoise", "lime", "green", "yellow", "orange" },
	hairs = {
		"beard_brown", "beard_dark_brown", "beard_silver", "beard_black", "beard_red", "beard_orange",
		"short_brown", "short_dark_brown", "short_silver", "short_black", "short_red", "short_orange",
	},
	eye_colors = { "green", "blue", "brown" },
}

-- NOTE: Skin data is saved in player meta under player_skins:skindata
-- in comma-separated list, in this order:
-- skin, eye, hair, cloth, bands

function player_skins.set_skin(name, skin, cloth, bands, hair, eyes)
	local skindata = player_skins.skindata_ids[name]
	if not skindata then
		return false
	end
	if not skin then
		skin = components.skin_colors[skindata.skin_colors]
	end
	if not cloth then
		cloth = components.cloth_colors[skindata.cloth_colors]
	end
	if not bands then
		bands = components.band_colors[skindata.band_colors]
	end
	if not hair then
		hair = components.hairs[skindata.hairs]
	end
	if not eyes then
		eyes = components.eye_colors[skindata.eye_colors]
	end
	local newskin =
		"player_skins_skin_"..skin..".png" .. "^" ..
		"player_skins_eyes_"..eyes..".png" .. "^" ..
		"player_skins_hair_"..hair..".png" .. "^" ..
		"player_skins_clothes_"..cloth..".png" .. "^" ..
		"player_skins_bands_"..bands..".png"
	local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end
	-- Set player skin and wieldhand
	default.player_set_textures(player, { newskin })
	wieldhand.set_hand(player, skin)

	-- Update internal data
	player_skins.skins[name] = newskin
	local meta = player:get_meta()
	local metastring = skin..","..eyes..","..hair..","..cloth..","..bands
	meta:set_string("player_skins:skindata", metastring)

	if minetest.global_exists("armor") then
		armor.update(player)
	end
	return true
end

local function on_joinplayer(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	local skin = meta:get_string("player_skins:skindata")
	player_skins.skindata_ids[name] = {}
	for k,v in pairs(components) do
		player_skins.skindata_ids[name][k] = {}
	end
	if skin ~= "" then
		local skindata = string.split(skin, ",")
		local skin = skindata[1]
		local eye = skindata[2]
		local hair = skindata[3]
		local cloth = skindata[4]
		local bands = skindata[5]
		local map = {
			skin_colors = skin,
			eye_colors = eye,
			hairs = hair,
			cloth_colors = cloth,
			band_colors = bands,
		}
		for c,component in pairs(components) do
			for i=1, #component do
				if component[i] == map[c] then
					player_skins.skindata_ids[name][c] = i
				end
			end
		end

		player_skins.set_skin(name, skin, cloth, bands, hair, eye)
	else
		player_skins.set_random_skin(name)
	end
end

local function on_leaveplayer(player)
	local name = player:get_player_name()
	player_skins.skins[name] = nil
	player_skins.skindata_ids[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

function player_skins.get_formspec(playername)
	local form = default.ui.get_page("default:default")
	form = form .. "model[0.2,0.5;4,8;player_skins_skin_select_model;character.b3d;"..player_skins.skins[playername]..";0,180;false;false;0,0]"
	form = form .. default.ui.button(3.5, 0.3, 3, 1, "player_skins_skin_select_hairs", S("Hair"))
	form = form .. default.ui.button(3.5, 1.3, 3, 1, "player_skins_skin_select_eye_colors", S("Eyes"))
	form = form .. default.ui.button(3.5, 3, 3, 1, "player_skins_skin_select_cloth_colors", S("Shirt"))
	form = form .. default.ui.button(3.5, 5, 3, 1, "player_skins_skin_select_band_colors", S("Trousers"))
	form = form .. default.ui.button(3.5, 6, 3, 1, "player_skins_skin_select_skin_colors", S("Skin"))
	form = form .. default.ui.button(3.5, 7.75, 3, 1, "player_skins_skin_select_random", S("Random"))
	return form
end

minetest.register_on_player_receive_fields(function(player, form_name, fields)
	local name = player:get_player_name()
	local changed = false
	if fields.player_skins_skin_select_random then
		player_skins.set_random_skin(name)
		changed = true
	else
		local checks = {"hairs", "eye_colors", "cloth_colors", "band_colors", "skin_colors"}
		for c=1, #checks do
			local check = checks[c]
			if fields["player_skins_skin_select_"..check] then
				player_skins.skindata_ids[name][check] = (player_skins.skindata_ids[name][check] + 1)
				if player_skins.skindata_ids[name][check] > #components[check] then
					player_skins.skindata_ids[name][check] = 1
				end
				player_skins.set_skin(name)
				changed = true
				break
			end
		end
	end
	if changed then
		local form = player_skins.get_formspec(name)
		player:set_inventory_formspec(form)
		minetest.show_formspec(name, "", form)
	end
end)

function player_skins.set_random_skin(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end

	local snum = math.random(1, #components.skin_colors)
	local scol = components.skin_colors[snum]

	local cnum = math.random(1, #components.cloth_colors)
	local ccol = components.cloth_colors[cnum]

	local bnum = math.random(1, #components.band_colors)
	local bcol = components.band_colors[math.random(1, bnum)]

	local hnum = math.random(1, #components.hairs)
	local hair = components.hairs[hnum]

	local enum = math.random(1, #components.eye_colors)
	local ecol = components.eye_colors[enum]

	player_skins.skindata_ids[name].skin_colors = snum
	player_skins.skindata_ids[name].cloth_colors = cnum
	player_skins.skindata_ids[name].band_colors = bnum
	player_skins.skindata_ids[name].hairs = hnum
	player_skins.skindata_ids[name].eye_colors = enum

	local newskin =
		"player_skins_skin_"..scol..".png" .. "^" ..
		"player_skins_eyes_"..ecol..".png" .. "^" ..
		"player_skins_hair_"..hair..".png" .. "^" ..
		"player_skins_clothes_"..ccol..".png" .. "^" ..
		"player_skins_bands_"..bcol..".png"

	player_skins.set_skin(name, scol, ccol, bcol, hair, ecol)
end

default.log("mod:player_skins", "loaded")
