-- number of moon phases
local MOON_PHASES = 4
-- time in seconds after which to check/update the moon status
local MOON_UPDATE_TIME = 8.0

-- Randomize initial moon phase, based on map seed
local mg_seed = minetest.get_mapgen_setting("seed")
local rand = PseudoRandom(mg_seed)
local phase_offset = rand:next(0, MOON_PHASES - 1)

minetest.log("info", "[rp_moon] Moon phase offset of this world: "..phase_offset)

rp_moon = {}
rp_moon.MOON_PHASES = MOON_PHASES

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

-- Updates the moon for a single player
local function update_moon_for_player(player)
	player:set_moon({texture = get_moon_texture()})
end

-- Updates the moon for all players
local function update_moon()
	local moon_arg = {texture = get_moon_texture()}
	local players = minetest.get_connected_players()
	for p=1, #players do
		players[p]:set_moon(moon_arg)
	end
end

local timer = 0
local last_reported_phase = nil
-- Update the moon for all players after some time has passed
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < MOON_UPDATE_TIME then
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
	update_moon()
end)

-- Initialize moon for joining player
minetest.register_on_joinplayer(function(player)
	update_moon_for_player(player)
end)

-- Update moon for all players when "time" command was called
minetest.register_on_chatcommand(function(name, command, params)
	if command == "time" then
		minetest.after(0, function()
			update_moon()
		end)
	end
end)

-- API functions

function rp_moon.get_moon_phase()
	local after_midday = 0
	-- Moon phase changes after midday
	local tod = minetest.get_timeofday()
	if tod > 0.5 then
		after_midday = 1
	end
	return (minetest.get_day_count() + phase_offset + after_midday) % MOON_PHASES
end

function rp_moon.update_moon()
	update_moon()
end

