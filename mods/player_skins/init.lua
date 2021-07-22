--
-- Player skins mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("player_skins")
local NS = function(s) return s end

player_skins = {}

-- Array of usable player skins

player_skins.skin_names = {NS("male"), NS("female")}
player_skins.default_skins = {male=true, female=true}

player_skins.old_skins = {}
player_skins.skins = {}

local skins_file = minetest.get_worldpath() .. "/player_skins.dat"
local saving = false

local timer_interval = 1
local timer = 10

local function save_player_skins()
   local f = io.open(skins_file, "w")

   for name, tex in pairs(player_skins.skins) do
      f:write(name .. " " .. tex .. "\n")
   end

   io.close(f)
end

local function delayed_save()
   if not saving then
      saving = true

      minetest.after(40, save_player_skins)
   end
end

local function load_player_skins()
   local f = io.open(skins_file, "r")

   if f then
      repeat
	 local l = f:read("*l")
	 if l == nil then break end

	 for name, tex in string.gmatch(l, "(.+) (.+)") do
	    player_skins.skins[name] = tex
	 end
      until f:read(0) == nil

      io.close(f)
   else
      save_player_skins()
   end
end

local function is_valid_skin(tex)
   for _, n in pairs(player_skins.skin_names) do
      if n == tex then
	 return true
      end
   end

   return false
end

function player_skins.get_skin(name)
   return "player_skins_" .. player_skins.skins[name] .. ".png"
end

function player_skins.set_skin(name, tex)
   if is_valid_skin(tex) then
      player_skins.skins[name] = tex
      save_player_skins()
   else
      minetest.chat_send_player(name, S("Invalid skin!"))
   end
end

local function on_load()
   load_player_skins()
end

local function on_shutdown()
   save_player_skins()
end

local function on_joinplayer(player)
   local name = player:get_player_name()

   -- New players start with a random skin
   if player_skins.skins[name] == nil then
      local skin = math.random(1, #player_skins.skin_names)
      player_skins.skins[name] = player_skins.skin_names[skin]
   end
end

local function on_globalstep(dtime)
   timer = timer + dtime

   if timer < timer_interval then
      return
   end

   timer = 0

   for _, player in pairs(minetest.get_connected_players()) do
      local name = player:get_player_name()

      if player_skins.skins[name] ~= player_skins.old_skins[name] then
         default.player_set_textures(
            player, {
               "player_skins_" .. player_skins.skins[name] .. ".png"
         })

         player_skins.old_skins[name] = player_skins.skins[name]

         delayed_save()
      end
   end
end

minetest.register_on_mods_loaded(on_load)

minetest.register_on_shutdown(on_shutdown)

minetest.register_on_joinplayer(on_joinplayer)

minetest.register_globalstep(on_globalstep)

local function get_chatparams()
   local s = "["

   for _, n in pairs(player_skins.skin_names) do
      if s == "[" then
	 s = s .. n
      else
	 s = s .. "|" .. n
      end
   end

   return s .. "]"
end

function player_skins.get_formspec(playername)
   local form = default.ui.get_page("default:default")

   form = form .. "image[4,0;0.5,10.05;ui_vertical_divider.png]"

   for i, name in ipairs(player_skins.skin_names) do
      local x = 0
      local y = i - 0.5

      if i > 8 then
	 x = 4.5
	 y = y - 8
      end

      local sname
      if player_skins.default_skins[name] then
          sname = S(name)
      else
          sname = name
      end
      form = form .. default.ui.button(x, y, 2.75, 1, "skin_select_"
                                          .. name, sname)
      form = form .. "image[" .. (x + 2.7) .. "," .. y.. ";1,1;player_skins_icon_"
         .. name .. ".png]"
      if player_skins.skins[playername] == name then
	 form = form .. "image[" .. (x + 3.65) .. "," .. (y + 0.25)
            .. ";0.5,0.5;ui_checkmark.png]"
      end
   end

   return form
end

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      local name = player:get_player_name()

      for fieldname, val in pairs(fields) do
	 local skinname = string.match(fieldname, "skin_select_(.*)")

	 if skinname ~= nil then
	    player_skins.set_skin(name, skinname)

	    local form = player_skins.get_formspec(name)
	    player:set_inventory_formspec(form)
	    minetest.show_formspec(name, "player_skins:player_skins", form)
	 end
      end
end)

minetest.register_chatcommand(
   "player_skin",
   {
      params = get_chatparams(),
      description = S("Set your player skin"),
      privs = {},
      func = function(name, param)
         if is_valid_skin(param) then
            player_skins.set_skin(name, param)
            local form = player_skins.get_formspec(name)
            local player = minetest.get_player_by_name(name)
            if player and default.ui.current_page[name] then
                if default.ui.current_page[name] == "player_skins:player_skins" then
                    -- This updates inventory menu to make sure the checkmark is updated
                    player:set_inventory_formspec(form)
                end
            end
            return true, S("Skin set to “@1”.", param)
         elseif param == "" then
            return true, S("Current player skin: @1", player_skins.skins[name])
         else
            return false, S("Unknown player skin. Enter “/help player_skin” for help.")
         end
      end
})

local genders = { "male", "female" }
local cloth_colors = { "red", "redviolet", "magenta", "purple", "blue", "cyan", "green", "yellow", "orange" }
local band_colors = { "red", "redviolet", "magenta", "purple", "blue", "skyblue", "cyan", "green", "lime", "turquoise", "yellow", "orange" }
local hairs = { "male", "female" }
local eye_colors = { "green", "blue", "brown" }

minetest.register_chatcommand(
   "random_skin",
   {
      params = get_chatparams(),
      description = S("Set random player skin"),
      privs = {},
      func = function(name, param)
         local player = minetest.get_player_by_name(name)
         if not player then
              return false
         end
         local scol = math.random(0,9)
         local gender = genders[math.random(1, #genders)]
         local ccol = cloth_colors[math.random(1, #cloth_colors)]
         local bcol = band_colors[math.random(1, #band_colors)]
         local hair = hairs[math.random(1, #hairs)]
         local ecol = eye_colors[math.random(1, #eye_colors)]
         default.player_set_textures(
            player, {
               "player_skins_skin_"..scol.."_male.png" .. "^" ..
               "player_skins_eyes_"..ecol..".png" .. "^" ..
               "player_skins_hair_"..hair..".png" .. "^" ..
               "player_skins_clothes_"..ccol..".png" .. "^" ..
               "player_skins_bands_"..bcol..".png"
         })
         return true
      end
})


default.log("mod:player_skins", "loaded")
