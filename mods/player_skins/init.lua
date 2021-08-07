--
-- Player skins mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("player_skins")
local NS = function(s) return s end

player_skins = {}

player_skins.skins = {}

local timer_interval = 1
local timer = 10

function player_skins.get_skin(name)
	if not player_skins.skins[name] then
		-- Fallback skin
		return "character.png"
	else
		return player_skins.skins[name]
	end
end

-- NOTE: Skin data is saved in player meta under player_skins:skindata
-- in comma-separated list, in this order:
-- skin, eye, hair, cloth, bands

function player_skins.set_skin(name, skin, cloth, bands, hair, eyes)
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
	default.player_set_textures(player, { newskin })
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
	if skin ~= "" then
		local skindata = string.split(skin, ",")
		local skin = skindata[1]
		local eye = skindata[2]
		local hair = skindata[3]
		local cloth = skindata[4]
		local bands = skindata[5]
		player_skins.set_skin(name, skin, cloth, bands, hair, eye)
	else
		player_skins.set_random_skin(name)
	end
end

local function on_leaveplayer(player)
	local name = player:get_player_name()
	player_skins.skins[name] = nil
end

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)

local components = {
	cloth_colors = { "red", "redviolet", "magenta", "purple", "blue", "cyan", "green", "yellow", "orange" },
	band_colors = { "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "green", "lime", "turquoise", "yellow", "orange" },
	hairs = { "beard", "short" },
	eye_colors = { "green", "blue", "brown" },
}

function player_skins.get_formspec(playername)
   local form = default.ui.get_page("default:default")

   form = form .. "model[0,0.1;10.5,8;player_skins_skin_select_model;character.b3d;"..player_skins.skins[playername]..";0,180;false;false;0,0;0]"

   --[[ TODO: Add skin selection buttons
   local x, y = 0.1, 0.1
   for c,component in pairs(components) do
       for c=1, #component do
           local color = component[c]
           form = form .. default.ui.button(x, y, 1, 1, "skin_select_" .. color, color)
           x = x + 0.7
       end
       x = 0.1
       y = y + 1
   end
   ]]
   form = form .. default.ui.button(2.75, 7.75, 3, 1, "player_skins_skin_select_random", S("New skin"))

   return form
end

minetest.register_on_player_receive_fields(function(player, form_name, fields)
	if not fields.player_skins_skin_select_random then
		return
	end
	local name = player:get_player_name()
	player_skins.set_random_skin(name)
	local form = player_skins.get_formspec(name)
	player:set_inventory_formspec(form)
	minetest.show_formspec(name, "", form)
end)

function player_skins.set_random_skin(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end
	-- TODO: Pick a random skin color (0-9)
	local scol = "1"
	local ccol = components.cloth_colors[math.random(1, #components.cloth_colors)]
	local bcol = components.band_colors[math.random(1, #components.band_colors)]
	local hair = components.hairs[math.random(1, #components.hairs)]
	local ecol = components.eye_colors[math.random(1, #components.eye_colors)]
	local newskin =
		"player_skins_skin_"..scol..".png" .. "^" ..
		"player_skins_eyes_"..ecol..".png" .. "^" ..
		"player_skins_hair_"..hair..".png" .. "^" ..
		"player_skins_clothes_"..ccol..".png" .. "^" ..
		"player_skins_bands_"..bcol..".png"

	player_skins.set_skin(name, scol, ccol, bcol, hair, ecol)
end

minetest.register_chatcommand(
   "random_skin",
   {
      params = "",
      description = S("Set random player skin"),
      privs = {},
      func = function(name, param)
         player_skins.set_random_skin(name)
         return true
      end
})


default.log("mod:player_skins", "loaded")
