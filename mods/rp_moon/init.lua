local MOON_PHASES = 4

-- Randomize initial moon phase, based on map seed
local mg_seed = minetest.get_mapgen_setting("seed")
local rand = PseudoRandom(mg_seed)
local phase_offset = rand:next(0, MOON_PHASES - 1)

minetest.log("info", "[rp_moon] Moon phase offset of this world: "..phase_offset)

rp_moon = {}
rp_moon.MOON_PHASES = MOON_PHASES

function rp_moon.get_moon_phase()
	local after_midday = 0
	-- Moon phase changes after midday
	local tod = minetest.get_timeofday()
	if tod > 0.5 then
		after_midday = 1
	end
	return (minetest.get_day_count() + phase_offset + after_midday) % MOON_PHASES
end

local moon_textures = {
	[0] = "rp_moon_full_moon.png",
	[1] = "rp_moon_waning_moon.png",
	[2] = "rp_moon_new_moon.png",
	[3] = "rp_moon_waxing_moon.png",
}

local function get_moon_texture()
	local phase = rp_moon.get_moon_phase()
	return moon_textures[phase]
end

local timer = 0
local last_reported_phase = nil
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 8 then
		return
	end
	timer = 0
	local phase = rp_moon.get_moon_phase()
	-- No-op when moon phase didn't change yet
	if last_reported_phase == phase then
		return
	end
	minetest.log("info", "[rp_moon] New moon phase: "..phase)
	last_reported_phase = phase
	local moon_arg = {texture = get_moon_texture()}
	local players = minetest.get_connected_players()
	for p=1, #players do
		players[p]:set_moon(moon_arg)
	end
end)

minetest.register_on_joinplayer(function(player)
	player:set_moon({texture = get_moon_texture()})
end)
