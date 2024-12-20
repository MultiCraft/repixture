--
-- Player skins mod
--

local S = minetest.get_translator("rp_player_skins")

player_skins = {}

player_skins.skins = {}
player_skins.skindata_ids = {}

-- Load legacy skins file (version 1.4.2 and before) to load the
-- correct skin for players coming from old versions.
-- Old versions supported only 2 skins: "male" and "female".
-- Current version knows no gender, only skins.
local legacy_skins = {}
local function load_legacy_player_skins()
	local legacy_skins_file = minetest.get_worldpath() .. "/player_skins.dat"
	local f = io.open(legacy_skins_file, "r")

	if not f then
		return
	end
	repeat
		local l = f:read("*l")
		if l == nil then break end

		for name, tex in string.gmatch(l, "(.+) (.+)") do
			legacy_skins[name] = tex
		end
	until f:read(0) == nil
	minetest.log("action", "[rp_player_skins] Legacy skins file player_skins.dat found and loaded")

	io.close(f)
end
load_legacy_player_skins()

function player_skins.get_skin(name)
	if not player_skins.skins[name] then
		-- Fallback skin
		return "character.png"
	else
		return player_skins.skins[name]
	end
end

-- The names of all skin components.
-- Note: The 'blank' component is a special case in which no texture is added.
--       If present, it MUST be the first one.
local components = {
	skin_colors = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	cloth_colors = { "red", "redviolet", "magenta", "purple", "blue", "cyan", "green", "yellow", "orange" },
	band_colors = { "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "turquoise", "lime", "green", "yellow", "orange" },
	headband_colors = { "blank", "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "turquoise", "lime", "green", "yellow", "orange" },
	wristband_colors = { "blank", "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "turquoise", "lime", "green", "yellow", "orange" },
	shoe_colors = { "red", "redviolet", "magenta", "purple", "blue", "cyan", "green", "yellow", "orange" },
	hairs = {
		"blank",
		"beard_brown", "beard_dark_brown", "beard_silver", "beard_black", "beard_red", "beard_orange",
		"short_brown", "short_dark_brown", "short_silver", "short_black", "short_red", "short_orange",
		"spots_brown", "spots_dark_brown", "spots_silver", "spots_black", "spots_red", "spots_orange",
		"rocker_brown", "rocker_dark_brown", "rocker_silver", "rocker_black", "rocker_red", "rocker_orange",
	},
	beards = {
		"blank",
		"chin_brown", "chin_dark_brown", "chin_silver", "chin_black", "chin_red", "chin_orange",
		"mini_brown", "mini_dark_brown", "mini_silver", "mini_black", "mini_red", "mini_orange",
	},
	eye_colors = { "green", "blue", "brown" },
}

function player_skins.build_skin(skin, cloth, bands, hair, eyes, headband, wristbands, shoes, beard)

	local texes = {}
	table.insert(texes, "player_skins_skin_"..skin..".png")
	table.insert(texes, "player_skins_eyes_"..eyes..".png")

	if beard ~= "blank" then
		table.insert(texes, "player_skins_beard_"..beard..".png")
	end
	if hair ~= "blank" then
		table.insert(texes, "player_skins_hair_"..hair..".png")
	end
	table.insert(texes, "player_skins_clothes_"..cloth..".png")
	table.insert(texes, "player_skins_bands_"..bands..".png")

	if headband ~= "blank" then
		table.insert(texes, "player_skins_headband_"..headband..".png")
	end
	if wristbands ~= "blank" then
		table.insert(texes, "player_skins_wristbands_"..wristbands..".png")
	end
	table.insert(texes, "player_skins_shoes_"..shoes..".png")

	local skin = table.concat(texes, "^")

	return skin
end

-- NOTE: Skin data is saved in player meta under player_skins:skindata
-- in comma-separated list, in this order:
-- skin, eye, hair, cloth, bands, headband, wristbands, shoes, beard

function player_skins.set_skin(name, skin, cloth, bands, hair, eyes, headband, wristbands, shoes, beard)
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
	if not beard then
		beard = components.beards[skindata.beards]
	end
	if not eyes then
		eyes = components.eye_colors[skindata.eye_colors]
	end
	if not headband then
		headband = components.headband_colors[skindata.headband_colors]
	end
	if not wristbands then
		wristbands = components.wristband_colors[skindata.wristband_colors]
	end
	if not shoes then
		shoes = components.shoe_colors[skindata.shoe_colors]
	end
	local newskin = player_skins.build_skin(skin, cloth, bands, hair, eyes, headband, wristbands, shoes, beard)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end
	-- Set player skin and wieldhand
	rp_player.player_set_textures(player, { newskin })
	wieldhand.set_hand(player, skin)

	-- Update internal data
	player_skins.skins[name] = newskin
	local meta = player:get_meta()
	local metastring = skin..","..eyes..","..hair..","..cloth..","..bands..","..headband..","..wristbands..","..shoes..","..beard
	meta:set_string("player_skins:skindata", metastring)

	if minetest.global_exists("armor") then
		armor.update(player)
	end
	return true
end

local function on_joinplayer(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	local skinstr = meta:get_string("player_skins:skindata")
	player_skins.skindata_ids[name] = {}
	for k,v in pairs(components) do
		player_skins.skindata_ids[name][k] = {}
	end
	if skinstr ~= "" or legacy_skins[name] then
		-- If no skin found in player meta, but a legacy skin (v.1.4.2 and before) is found,
		-- use the legacy skin
		local skin, eye, hair, cloth, bands, headband, wristbands, shoes, beard
		if skinstr == "" and legacy_skins[name] then
			skin = "1"
			eye = "green"
			cloth = "red"
			bands = "green"
			headband = "green"
			wristbands = "green"
			shoes = "red"
			local legacy_skin = legacy_skins[name]
			legacy_skins[name] = nil
			-- Load skin from legacy version (v1.4.2 and before)
			if legacy_skin == "female" then
				minetest.log("action", "[rp_player_skins] Converting legacy skin 'female' for player "..name)
				hair = "short_brown"
				beard = "mini_brown"
			elseif legacy_skin == "male" then
				minetest.log("action", "[rp_player_skins] Converting legacy skin 'male' for player "..name)
				hair = "beard_brown"
				beard = "chin_brown"
			else
				minetest.log("action", "[rp_player_skins] Unknown legacy skin '"..tostring(legacy_skin).."' detected for player "..name..", setting a random skin")
				player_skins.set_random_skin(name)
				return
			end
		-- Skin found in player meta, so we parse it
		else
			local skindata = string.split(skinstr, ",")
			skin = skindata[1]
			eye = skindata[2]
			hair = skindata[3]
			cloth = skindata[4]
			bands = skindata[5]
			headband = skindata[6] or bands
			wristbands = skindata[7] or bands
			shoes = skindata[8] or cloth
			beard = skindata[9] or "chin_brown"
		end

		-- Populate skindata_ids (needed for formspec to know which skin components are selected)
		local map = {
			skin_colors = skin,
			eye_colors = eye,
			hairs = hair,
			cloth_colors = cloth,
			band_colors = bands,
			headband_colors = headband,
			wristband_colors = wristbands,
			shoe_colors = shoes,
			beards = beard,
		}
		for c,component in pairs(components) do
			for i=1, #component do
				if component[i] == map[c] then
					player_skins.skindata_ids[name][c] = i
				end
			end
		end

		-- Set skin :-)
		player_skins.set_skin(name, skin, cloth, bands, hair, eye, headband, wristbands, shoes, beard)
	else
		-- No skin found, set a random one
		minetest.log("action", "[rp_player_skins] Player "..name.." appears to be new, setting initial random skin")
		player_skins.set_random_skin(name)
	end

	rp_formspec.refresh_invpage(player, "rp_player_skins:player_skins")
end

local function on_leaveplayer(player)
	local name = player:get_player_name()
	player_skins.skins[name] = nil
	player_skins.skindata_ids[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

local function get_formspec(playername)
	local form = rp_formspec.get_page("rp_player_skins:player_skins")
	local skin = player_skins.skins[playername]
	if skin then
		form = form .. "model[0.5,0.2;4.35,9.7;player_skins_skin_select_model;character.b3d;"..player_skins.skins[playername]..";0,180;false;false;0,0]"
	end
	return form
end

local form = rp_formspec.get_page("rp_formspec:default")

-- Add buttons
local buttons = {
	{ 0.1, "headband_colors", S("Headband") },
	{ 1.0, "hairs", S("Hair") },
	{ 1.9, "eye_colors", S("Eyes") },
	{ 2.8, "beards", S("Beard") },
	{ 4.1, "cloth_colors", S("Shirt") },
	{ 5.3, "wristband_colors", S("Wristbands") },
	{ 6.3, "band_colors", S("Trousers") },
	{ 7.25, "skin_colors", S("Skin") },
	{ 8.2, "shoe_colors", S("Shoes") },
	{ 9.1, "random", S("Random") },
}
form = form .. "container[5.5,0]"
for b=1, #buttons do
	local y = buttons[b][1]
	local texture = buttons[b][2]
	local label = buttons[b][3]
	form = form .. rp_formspec.button(0, y, 3, 0.9, "player_skins_skin_select_"..texture, label)
end
form = form .. "container_end[]"

rp_formspec.register_page("rp_player_skins:player_skins", form)
rp_formspec.register_invpage("rp_player_skins:player_skins", {get_formspec = get_formspec})
rp_formspec.register_invtab("rp_player_skins:player_skins", {
	icon = "ui_icon_player_skins.png",
	icon_active = "ui_icon_player_skins_active.png",
	tooltip = S("Player Skins"),
})

minetest.register_on_player_receive_fields(function(player, form_name, fields)
        local invpage = rp_formspec.get_current_invpage(player)
        if not (form_name == "" and invpage == "rp_player_skins:player_skins") then
           return
        end
	local name = player:get_player_name()
	local changed = false
	if fields.player_skins_skin_select_random then
		player_skins.set_random_skin(name)
		changed = true
	else
		local checks = {"hairs", "beards", "eye_colors", "cloth_colors", "band_colors", "skin_colors", "headband_colors", "wristband_colors", "shoe_colors"}
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
		rp_formspec.refresh_invpage(player, "rp_player_skins:player_skins")
	end
end)

function player_skins.set_random_skin(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end

	-- Skin
	local snum = math.random(1, #components.skin_colors)
	local scol = components.skin_colors[snum]

	-- Shirt
	local cnum = math.random(1, #components.cloth_colors)
	local ccol = components.cloth_colors[cnum]

	-- Headband
	-- 50% chance for no headband (blank)
	-- (similar for other components below)
	local rnd = math.random(1, 2)
	local henum, hecol
	if rnd == 1 then
		-- Component no. 1 is blank
		henum = 1
	else
		henum = math.random(2, #components.headband_colors)
	end
	hecol = components.headband_colors[henum]

	-- Wristbands
	rnd = math.random(1, 2)
	local wnum, wcol
	if rnd == 1 then
		wnum = 1
	else
		wnum = math.random(2, #components.wristband_colors)
	end
	wcol = components.wristband_colors[wnum]

	-- Shoes
	local shnum = math.random(1, #components.shoe_colors)
	local shcol = components.shoe_colors[shnum]

	-- Trousers
	rnd = math.random(1, 2)
	local bnum, bcol
	if rnd == 1 then
		bnum = 1
	else
		bnum = math.random(2, #components.band_colors)
	end
	bcol = components.band_colors[bnum]

	-- Hair
	rnd = math.random(1, 3)
	local hnum, hair
	if rnd == 1 then
		hnum = 1
	else
		hnum = math.random(2, #components.hairs)
	end
	hair = components.hairs[hnum]

	-- Beard
	rnd = math.random(1, 2)
	local benum, becol
	if rnd == 1 then
		benum = 1
	else
		benum = math.random(2, #components.beards)
	end
	becol = components.beards[benum]

	-- Eyes
	local enum = math.random(1, #components.eye_colors)
	local ecol = components.eye_colors[enum]

	player_skins.skindata_ids[name].skin_colors = snum
	player_skins.skindata_ids[name].cloth_colors = cnum
	player_skins.skindata_ids[name].headband_colors = henum
	player_skins.skindata_ids[name].wristband_colors = wnum
	player_skins.skindata_ids[name].shoe_colors = shnum
	player_skins.skindata_ids[name].band_colors = bnum
	player_skins.skindata_ids[name].hairs = hnum
	player_skins.skindata_ids[name].beards = benum
	player_skins.skindata_ids[name].eye_colors = enum

	player_skins.set_skin(name, scol, ccol, bcol, hair, ecol, hecol, wcol, shcol, becol)
end
