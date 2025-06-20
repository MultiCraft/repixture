local rp_sky = {}

-- list of currently active sky, per player
local current_skies = {}

local DEFAULT_CLOUDS = {
	density = 0.4,
	color = "#fff0f0e5",
	ambient = "#000000",
	height = 120,
	thickness = 16,
	speed = {x=0, z=-2},
}
local DEFAULT_FOG_SUN_TINT = "#ff6300"
local DEFAULT_FOG_MOON_TINT = "#7f99fe"

local function make_clouds(params)
	local clouds = table.copy(DEFAULT_CLOUDS)
	for k,v in pairs(params) do
		clouds[k] = v
	end
	return clouds
end

local registered_skies = {}

local function register_sky(name, def)
	registered_skies[name] = def
end

-- Returns true if the sky definition is the definition of a dynamic sky.
-- A dynamic sky is a sky that uses any function to determine its sky values.
-- If all values are defined by constant values, it is static (not dynamic).
local function is_dynamic_sky(skydef)
	if type(skydef.sky.sky_color) == "function" or type(skydef.day_night_ratio) == "function" then
		return true
	else
		return false
	end
end

function rp_sky.set_sky(player, skyname)
	local pname = player:get_player_name()
	local skydef = registered_skies[skyname]
	-- Don't set sky if it's a static sky already in use.
	-- Done to reduce unneccessary network packages.
	if current_skies[pname] == skyname and not is_dynamic_sky(skydef) then
		return
	end

	local skyskydef = table.copy(skydef.sky)
	if type(skydef.sky.sky_color) == "function" then
		skyskydef.sky_color = skydef.sky.sky_color()
	end
	player:set_sky(skyskydef)
	player:set_clouds(skydef.clouds)
	--player:set_sun(skydef.sun)
	--player:set_moon(skydef.moon)
	player:set_stars(skydef.stars)
	local dnr
	if type(skydef.day_night_ratio) == "function" then
		dnr = skydef.day_night_ratio()
	else
		dnr = skydef.day_night_ratio
	end
	player:override_day_night_ratio(dnr)

	-- Remember skyname for later
	current_skies[pname] = skyname
end

register_sky("condensed", {
	sky = {
		sky_color = {
			day_sky = "#8cbafa",
			day_horizon = "#9bc1f0",
			dawn_sky = "#b4bafa",
			dawn_horizon = "#bac1f0",
			night_sky = "#006aff",
			night_horizon = "#4090ff",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = DEFAULT_CLOUDS,
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

register_sky("saturated", {
	sky = {
		sky_color = {
			day_sky = "#549fff",
			day_horizon = "#78c9ff",
			dawn_sky = "#347fdf",
			dawn_horizon = "#58a9df",
			night_sky = "#045faf",
			night_horizon = "#3889af",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = DEFAULT_CLOUDS,
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

register_sky("oakish", {
	sky = {
		sky_color = {
			day_sky = "#009fa5",
			day_horizon = "#1bbac6",
			dawn_sky = "#005f65",
			dawn_horizon = "#003f45",
			night_sky = "#00364b",
			night_horizon = "#005d6c",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		{color="#e0e0ffe5"}
	}),
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

register_sky("oakish_soft", {
	sky = {
		sky_color = {
			day_sky = "#24b1c7",
			day_horizon = "#34cbde",
			dawn_sky = "#005f65",
			dawn_horizon = "#003f45",
			night_sky = "#00364b",
			night_horizon = "#005d6c",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#e0e0ffe5",
	}),
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



register_sky("birchish", {
	sky = {
		sky_color = {
			day_sky = "#78abff",
			day_horizon = "#abc3d5",
			dawn_sky = "#78abff",
			dawn_horizon = "#abc3d5",
			night_sky = "#588bdf",
			night_horizon = "#8ba3b5",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = DEFAULT_CLOUDS,
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
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#bdffc6c3",
	}),
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

register_sky("dry_swamp", {
	sky = {
		sky_color = {
			day_sky = "#00ccb1",
			day_horizon = "#99e1a7",
			dawn_sky = "#00a791",
			dawn_horizon = "#8aad91",
			night_sky = "#005146",
			night_horizon = "#546961",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#bdffdec3",
	}),
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

register_sky("savannic", {
	sky = {
		sky_color = {
			day_sky = "#6ff0ff",
			day_horizon = "#e1e7ab",
			dawn_sky = "#81c9ff",
			dawn_horizon = "#db3900",
			night_sky = "#db3900",
			night_horizon = "#b70000",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#e6e0c4c3",
	}),
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

register_sky("hot_sky", {
	sky = {
		sky_color = {
			day_sky = "#6ff0ff",
			day_horizon = "#4fd0df",
			dawn_sky = "#6ff0ff",
			dawn_horizon = "#4fd0df",
			night_sky = "#3fc0cf",
			night_horizon = "#1fa0af",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = DEFAULT_CLOUDS,
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



register_sky("drylandic", {
	sky = {
		sky_color = {
			day_sky = "#d5ab9c",
			day_horizon = "#edd2c6",
			dawn_sky = "#d5ab9c",
			dawn_horizon = "#edd2c6",
			night_sky = "#db3900",
			night_horizon = "#b70000",
			fog_tint_type = "custom",
			fog_sun_tint = DEFAULT_FOG_SUN_TINT,
			fog_moon_tint = DEFAULT_FOG_MOON_TINT,
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#f0d5c3e1",
	}),
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

register_sky("mystic", {
	sky = {
		sky_color = {
			day_sky = "#c8b9ff",
			day_horizon = "#7c9bb3",
			dawn_sky = "#7f55b2",
			dawn_horizon = "#c1acdf",
			night_sky = "#5f3592",
			night_horizon = "#a18cbf",
			fog_sun_tint = "#ff6300",
			fog_moon_tint = "#510045",
			fog_tint_type = "custom",
		},
		clouds = true,
	},
	clouds = make_clouds({
		color = "#ffc9ffab",
		ambient = "#380946",
	}),
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

local get_storm_light = function()
	local light = (minetest.get_timeofday() * 2)
	if light > 1 then
		light = 1 - (light - 1)
	end
	light = (light * 0.5) + 0.15
	return light
end

register_sky("storm", {
	sky = {
		sky_color = function()
			local light = get_storm_light()
			local skycol = math.floor(light * 190)
			local sky_color = {
				day_sky = {r = skycol, g = skycol, b = skycol * 1.2},
				day_horizon = {r = skycol, g = skycol, b = skycol * 1.2},
				dawn_sky = {r = skycol*0.75, g = skycol*0.75, b = skycol * 0.9},
				dawn_horizon = {r = skycol*0.75, g = skycol*0.75, b = skycol * 0.9},
				night_sky = {r = skycol*0.5, g = skycol*0.5, b = skycol * 0.6},
				night_horizon = {r = skycol*0.5, g = skycol*0.5, b = skycol * 0.6},
			}
			return sky_color
		end,
		clouds = true,
	},
	clouds = make_clouds({
		density = 0.5,
		color = "#a0a0a0f0",
		ambient = "#000000",
		height = 100,
		thickness = 40,
		speed = {x = -2, y = 1},
	}),
	sun = {
		visible = false,
		sunrise_visible = false,
	},
	moon = {
		visible = false,
	},
	stars = {
		visible = false,
	},
	day_night_ratio = function()
		return get_storm_light()
	end,
})

local update_sky_for_player = function(player, is_storm)
	if is_storm then
		rp_sky.set_sky(player, "storm")
	else
		local pos = player:get_pos()
		pos.y = math.floor(pos.y)
		local biomedata = minetest.get_biome_data(pos)
		if biomedata then
			local biome_id = biomedata.biome
			local biome = minetest.get_biome_name(biome_id)
			local biomeinfo = default.get_biome_info(biome)
			local main = biomeinfo.main_biome
			local class = biomeinfo.class
			if main == "Mystery Forest" then
				rp_sky.set_sky(player, "mystic")
			elseif main == "Thorny Shrubs" or main == "Poplar Plains" or main == "Baby Poplar Plains" or main == "Shrubbery" or main == "Wilderness" then
				rp_sky.set_sky(player, "hot_sky")
			elseif main == "Oak Forest" or biomeinfo.main == "Dense Oak Forest" or main == "Tall Oak Forest" then
				rp_sky.set_sky(player, "oakish")
			elseif main == "Oak Shrubbery" then
				rp_sky.set_sky(player, "oakish_soft")
			elseif main == "Birch Forest" or biomeinfo.main == "Tall Birch Forest" or main == "Deep Forest" then
				rp_sky.set_sky(player, "birchish")
			elseif main == "Forest" or main == "Orchard" or main == "Grove" then
				rp_sky.set_sky(player, "saturated")
			elseif main == "Dry Swamp" then
				rp_sky.set_sky(player, "dry_swamp")
			elseif class == "swampy" then
				rp_sky.set_sky(player, "swamp")
			elseif class == "savannic" then
				rp_sky.set_sky(player, "savannic")
			elseif class == "drylandic" then
				rp_sky.set_sky(player, "drylandic")
			else
				rp_sky.set_sky(player, "condensed")
			end
		end
	end
end

local update_biome_skies = function()
	local is_storm = weather.get_weather() == "storm"
	local players = minetest.get_connected_players()
	for p=1, #players do
		update_sky_for_player(players[p], is_storm)
	end
end

minetest.register_on_joinplayer(function(player)
	local is_storm = weather.get_weather() == "storm"
	update_sky_for_player(player, is_storm)
end)

minetest.register_on_leaveplayer(function(player)
	current_skies[player:get_player_name()] = nil
end)

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
	update_biome_skies()
end)

weather.register_on_weather_change(function(old_weather, new_weather)
	update_biome_skies()
end)
