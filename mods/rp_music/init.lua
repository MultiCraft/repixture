
--
-- Music player mod
--
local S = minetest.get_translator("rp_music")
local NS = function(s) return s end

local INFOTEXT_ON = S("Music Player (on)")
local INFOTEXT_OFF = S("Music Player (off)")
local INFOTEXT_DISABLED = S("Music Player (disabled by server)")
local INFOTEXT_NOW_PLAYING = NS("Now playing: @1 by @2")
local NOTES_PER_SECOND = 1
local DEFAULT_MUSIC_PLAYER_COLOR = rp_paint.COLOR_AZURE_BLUE

rp_music = {}
local localmusic = {}

localmusic.tracks = {} -- list of track info
localmusic.tracks_by_name = {} -- list of tracks. key = name, value = table index for localmusic.tracks

rp_music.add_track = function(name, def)
   table.insert(localmusic.tracks, {name=name, length=def.length, note_color=def.note_color, title=def.title, author=def.author})
   localmusic.tracks_by_name[name] = #localmusic.tracks
end

rp_music.clear_tracks = function()
   localmusic.tracks = {}
   localmusic.tracks_by_name = {}
end

localmusic.volume = tonumber(minetest.settings:get("music_volume")) or 1.0
localmusic.volume = math.max(0.0, math.min(1.0, localmusic.volume))

local get_track_from_meta = function(meta, return_default)
   if #localmusic.tracks == 0 then
      return nil
   end
   local metastr = meta:get_string("music_player_track")
   local track
   if metastr ~= "" and (not string.match(metastr, "^%d")) then
      track = localmusic.tracks_by_name[metastr]
   end
   if not track and return_default then
      return 1
   else
      return track
   end
end

local function note_particle(pos, texture, permanent)
   local amount, time
   if permanent then
      amount = NOTES_PER_SECOND
      time = 0
   else
      amount = 1
      time = 0.01
   end
   return minetest.add_particlespawner({
      amount = amount,
      time = time,
      pos = vector.add(pos, vector.new(0,-0.25,0)),
      vel = vector.new(0, 1, 0),
      exptime = 0.5,
      size = 2,
      drag = vector.new(2,2,2),
      texture = {
         name = texture,
         alpha_tween = { 1, 0, start = 0.6 },
      },
   })
end

local function get_note(pos)
   local meta = minetest.get_meta(pos)
   local track = get_track_from_meta(meta, true)
   if not track then
      return
   end
   local note = "rp_music_note.png"
   local note_color
   if localmusic.tracks[track] then
      note_color = localmusic.tracks[track].note_color
      note = note .. "^[multiply:"..note_color
   end
   return note
end

local get_now_playing_string = function(trackinfo)
   if not trackinfo then
      return ""
   end
   local title = trackinfo.title
   local author = trackinfo.author
   local now_playing = ""
   if title and author then
      now_playing = "\n" .. S(INFOTEXT_NOW_PLAYING, title, author)
   end
   return now_playing
end

--[[ Array of music players
* key: node position hash of music player node
* value: {
    * pos: node position (vector)
    * timer: current track timer
    * handle: ID of associated sound
    * particlespawner: ID of associated particlespawner
}
]]

localmusic.players = {}

local m_tiles = {"rp_music_colored.png", {name="rp_music_bottom_base.png",color="white"}, "rp_music_colored.png"}
local m_overlay_tiles = {{name="rp_music_top_base.png",color="white"}, "", {name="rp_music_side_base.png",color="white"}}
local m_use_texture_alpha = "clip"
local m_palette = "rp_paint_palette_256d.png"
local m_paramtype2 = "color"
local m_place_param2 = DEFAULT_MUSIC_PLAYER_COLOR-1

if minetest.settings:get_bool("music_enable") then
   function rp_music.stop(pos)
      local dp = minetest.hash_node_position(pos)

      local node = minetest.get_node(pos)
      if node.name == "rp_music:player" then
         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", INFOTEXT_OFF)
         meta:set_int("music_player_enabled", 0)
      end

      if localmusic.players[dp] ~= nil then
         -- Stop sound and delete particlespawner
         local sid = localmusic.players[dp]["handle"]
         if sid then
            minetest.sound_stop(sid)
         end

         local pid = localmusic.players[dp]["particlespawner"]
         if pid then
            minetest.delete_particlespawner(pid)
         end
         localmusic.players[dp] = nil
      end
   end

   function rp_music.start(pos)
      local dp = minetest.hash_node_position(pos)

      local meta = minetest.get_meta(pos)
      if #localmusic.tracks == 0 then
         note_particle(pos, "rp_music_no_music.png")
         return
      end
      meta:set_int("music_player_enabled", 1)

      -- Get track or set random track if not set
      local track = get_track_from_meta(meta, false)
      if track == nil or not localmusic.tracks[track] then
         track = math.random(1, #localmusic.tracks)
         meta:set_string("music_player_track", localmusic.tracks[track].name)
      end
      meta:set_string("infotext", INFOTEXT_ON .. get_now_playing_string(localmusic.tracks[track]))

      -- Spawn a single note particle immediately
      local note = get_note(pos)
      note_particle(pos, note)

      -- Start music and spawn particlespawner
      if localmusic.players[dp] == nil then
	 localmusic.players[dp] = {
	    ["handle"] = minetest.sound_play(
	       localmusic.tracks[track].name,
	       {
		  pos = pos,
		  gain = localmusic.volume,
            }),
	    ["particlespawner"] = note_particle(pos, note, true),
	    ["timer"] = 0,
	    ["pos"] = pos,
	 }
      else
         -- Music player data was already present:
         -- Reset everything and restart music and respawn particlespawner
	 localmusic.players[dp]["timer"] = 0

         if localmusic.players[dp]["handle"] then
            minetest.sound_stop(localmusic.players[dp]["handle"])
         end
         if localmusic.players[dp]["particlespawner"] then
            minetest.delete_particlespawner(localmusic.players[dp]["particlespawner"])
         end

	 localmusic.players[dp]["handle"] = minetest.sound_play(
	    localmusic.tracks[track].name,
	    {
	       pos = pos,
	       gain = localmusic.volume,
         })
         localmusic.players[dp]["particlespawner"] = note_particle(pos, note, true)
      end
   end

   function localmusic.update(pos)
      local dp = minetest.hash_node_position(pos)
      if #localmusic.tracks == 0 then
         return
      end

      if localmusic.players[dp] ~= nil then
	 local node = minetest.get_node(pos)

	 if node.name ~= "rp_music:player" then
	    rp_music.stop(pos)

	    return
	 end

	 local meta = minetest.get_meta(pos)
         local track = get_track_from_meta(meta, true)

	 if track and localmusic.tracks[track] then
	    if localmusic.players[dp]["timer"] > localmusic.tracks[track].length then
	       rp_music.start(pos)
	    end
         end
      end
   end

   function rp_music.toggle(pos)
      local dp = minetest.hash_node_position(pos)

      if localmusic.players[dp] == nil then
	 rp_music.start(pos)
	 return true
      else
	 rp_music.stop(pos)
	 return false
      end
   end

   minetest.register_node(
      "rp_music:player",
      {
	 description = S("Music Player"),

	 tiles = m_tiles,
	 overlay_tiles = m_overlay_tiles,
         use_texture_alpha = m_use_texture_alpha,
	 palette = m_palette,
	 paramtype2 = m_paramtype2,
	 place_param2 = m_place_param2,

	 inventory_image = "rp_music_inventory.png",
	 wield_image = "rp_music_inventory.png",

	 is_ground_content = false,
	 floodable = true,
         on_flood = function(pos, oldnode, newnode)
            rp_music.stop(pos)
            minetest.add_item(pos, "rp_music:player")
         end,
         on_blast = function(pos)
            minetest.remove_node(pos)
            minetest.check_for_falling({x=pos.x,y=pos.y,z=pos.z})
            rp_music.stop(pos)
	 end,
	 paramtype = "light",

	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = {-4/16, -0.5, -4/16, 4/16, -0.5 + (4/16), 4/16}
	 },

         sounds = rp_sounds.node_sound_small_defaults(),

	 on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_int("music_player_legacy_color", 1)
            rp_music.start(pos)
         end,

	 after_destruct = function(pos)
            rp_music.stop(pos)
         end,

	 on_rightclick = function(pos, node, clicker)
            if minetest.is_protected(pos, clicker:get_player_name()) and
                    not minetest.check_player_privs(clicker, "protection_bypass") then
                minetest.record_protection_violation(pos, clicker:get_player_name())
                return
            end
            rp_music.toggle(pos)
	 end,

	 groups = {handy = 3, attached_node = 1, interactive_node = 1, paintable = 1, furniture = 1, pathfinder_hard = 1},

	 drop = "rp_music:player",
   })

   local function step(dtime)
      for dp, _ in pairs(localmusic.players) do
	 localmusic.players[dp]["timer"] = localmusic.players[dp]["timer"] + dtime

	 localmusic.update(localmusic.players[dp]["pos"])
      end
   end

   minetest.register_globalstep(step)

   minetest.register_abm(
      {
         label = "Music Player",
	 nodenames = {"rp_music:player"},
	 chance = 1,
	 interval = 1,
	 action = function(pos, node)
            if localmusic.players[minetest.hash_node_position(pos)] == nil then
               local meta = minetest.get_meta(pos)
               if meta:get_int("music_player_enabled") == 1 then
                  rp_music.start(pos)
               end
            end
         end
   })
else
   minetest.register_node(
      "rp_music:player",
      {
	 description = S("Music Player"),

	 tiles = m_tiles,
	 overlay_tiles = m_overlay_tiles,
         use_texture_alpha = m_use_texture_alpha,
	 palette = m_palette,
	 paramtype2 = m_paramtype2,
	 place_param2 = m_place_param2,

	 inventory_image = "rp_music_inventory.png",
	 wield_image = "rp_music_inventory.png",

	 is_ground_content = false,
	 floodable = true,
	 on_flood = function(pos, oldnode, newnode)
	   minetest.add_item(pos, "rp_music:player")
	 end,
	 paramtype = "light",

	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = {-4/16, -0.5, -4/16, 4/16, -0.5 + (4/16), 4/16}
	 },

         sounds = rp_sounds.node_sound_small_defaults(),

	 on_construct = function(pos)
            local meta = minetest.get_meta(pos)

            meta:set_string("infotext", INFOTEXT_DISABLED)
         end,
	 on_rightclick = function(pos, node, clicker)
            if minetest.is_protected(pos, clicker:get_player_name()) and
                    not minetest.check_player_privs(clicker, "protection_bypass") then
                minetest.record_protection_violation(pos, clicker:get_player_name())
                return
            end
            note_particle(pos, "rp_music_no_music.png")
         end,

	 groups = {handy = 3, attached_node = 1, interactive_node = 1, furniture = 1, pathfinder_hard = 1}
   })
end

crafting.register_craft(
   {
      output = "rp_music:player",
      items = {
         "group:planks 5",
         "rp_default:ingot_steel",
      }
})

-- Update music player metadata
minetest.register_lbm(
   {
      label = "Update music players",
      name = "rp_music:update_music_players_v2",
      run_at_every_load = true,
      nodenames = {"rp_music:player"},
      action = function(pos, node)
         local def = minetest.registered_nodes[node.name]
         local meta = minetest.get_meta(pos)
         -- If this metadata is 0, it means this is an old
         -- music box when it didn't support color. In this
         -- case, the music box would most likely still have
         -- param2=0 and become black. So we update param2
         -- with the default color.
         if meta:get_int("music_player_legacy_color") == 0 then
            node.param2 = DEFAULT_MUSIC_PLAYER_COLOR - 1
            minetest.swap_node(pos, node)
            meta:set_int("music_player_legacy_color", 1)
         end
         if minetest.settings:get_bool("music_enable") then
            if meta:get_int("music_player_enabled") == 1 then
               local track = get_track_from_meta(meta)
               meta:set_string("infotext", INFOTEXT_ON .. get_now_playing_string(localmusic.tracks[track]))
            else
               meta:set_string("infotext", INFOTEXT_OFF)
            end
         else
            meta:set_string("infotext", INFOTEXT_DISABLED)
         end
      end
   }
)

minetest.register_alias("music:player", "rp_music:player")

-- Add tracks
rp_music.add_track("rp_music_earthen_lullaby", {length=93.0, note_color="#ee772c", title="earthen lullaby", author="vozh-kc"})
rp_music.add_track("rp_music_turtles", {length=114.0, note_color="#3eb13b", title="you may not rest, there are turtles nearby", author="vozh-kc"})
