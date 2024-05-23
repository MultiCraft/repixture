rp_sky = {}
local registered_skies = {}

local function register_sky(name, def)
	registered_skies[name] = def
end

function rp_sky.set_sky(player, skyname)
	local skydef = registered_skies[skyname]
	player:set_sky(skydef.sky)
	player:set_clouds(skydef.clouds)
	player:set_sun(skydef.sun)
	player:set_moon(skydef.moon)
	player:set_stars(skydef.stars)
	player:override_day_night_ratio(skydef.day_night_ratio)
end

register_sky("light_blue", {
	sky = {
		sky_color = {
			day_sky = "#8cbafa",
			day_horizon = "#9bc1f0",
			dawn_sky = "#b4bafa",
			dawn_horizon = "#bac1f0",
			night_sky = "#006aff",
			night_horizon = "#4090ff",
		},
		clouds = true,
	},
	sun = {
		visible = true,
		sunrise_visible = true,
	},
	moon = {
		visible = true,
	},
	stars = {
		visible = true,
	},
})

register_sky("swamp", {
	sky = {
		sky_color = {
			day_sky = "#00ffde",
			day_horizon = "#27ea93",
			dawn_sky = "#00ffc0",
			dawn_horizon = "#24ea93",
			night_sky = "#00ffc9",
			night_horizon = "#1bd290",
		},
		clouds = true,
	},
	sun = {
		visible = true,
		sunrise_visible = true,
	},
	moon = {
		visible = true,
	},
	stars = {
		visible = true,
	},
})

local SKY_UPDATE = 1
local skytimer = SKY_UPDATE

minetest.register_globalstep(function(dtime)
	if not registered_skies then
		return
	end
	skytimer = skytimer + dtime
	if skytimer < SKY_UPDATE then
		return
	end
	skytimer = 0
        if weather.get_weather() ~= "clear" then
		return
	end
	local players = minetest.get_connected_players()
	for p=1, #players do
		local player = players[p]
		local pos = player:get_pos()
		pos.y = math.floor(pos.y)
		local biomedata = minetest.get_biome_data(pos)
		if biomedata then
			local biome_id = biomedata.biome
			local biome = minetest.get_biome_name(biome_id)
			local biomeinfo = default.get_biome_info(biome)
			if biomeinfo.class == "swampy" then
				rp_sky.set_sky(player, "swamp")
			else
				rp_sky.set_sky(player, "light_blue")
			end
		end
	end
end)
