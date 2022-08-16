
--
-- Music player mod
--
local S = minetest.get_translator("rp_music")

local INFOTEXT_ON = S("Music Player (on)")
local INFOTEXT_OFF = S("Music Player (off)")
local INFOTEXT_DISABLED = S("Music Player (disabled by server)")
local NOTES_PER_SECOND = 1

local music = {}
local particlespawners = {}

music.tracks = {
   { name = "music_catsong", length = 30.0, note_color = "#26b7dc", },
   { name = "music_greyarms", length = 82.0, note_color = "#d8cb2b", },
}

music.volume = tonumber(minetest.settings:get("music_volume")) or 1.0
music.volume = math.max(0.0, math.min(1.0, music.volume))


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
   local track = meta:get_int("music_player_track")
   local note = "rp_music_note.png"
   local note_color
   if music.tracks[track] then
      note_color = music.tracks[track].note_color
      note = note .. "^[multiply:"..note_color
   end
   return note
end

-- Array of music players

music.players = {}

if minetest.settings:get_bool("music_enable") then
   function music.stop(pos)
      local dp = minetest.hash_node_position(pos)

      local meta = minetest.get_meta(pos)
      meta:set_string("infotext", INFOTEXT_OFF)
      meta:set_int("music_player_enabled", 0)

      if music.players[dp] ~= nil then
	 minetest.sound_stop(music.players[dp]["handle"])
	 music.players[dp] = nil
      end

      local id = particlespawners[dp]
      if id then
         minetest.delete_particlespawner(id)
         particlespawners[dp] = nil
      end
   end

   function music.start(pos)
      local dp = minetest.hash_node_position(pos)

      local meta = minetest.get_meta(pos)
      meta:set_string("infotext", INFOTEXT_ON)
      meta:set_int("music_player_enabled", 1)

      -- Get track or set random track if not set
      local track = meta:get_int("music_player_track")
      if track == nil or not music.tracks[track] then
         track = math.random(1, #music.tracks)
         meta:set_int("music_player_track", track)
      end

      if music.players[dp] == nil then
	 music.players[dp] = {
	    ["handle"] = minetest.sound_play(
	       music.tracks[track].name,
	       {
		  pos = pos,
		  gain = music.volume,
            }),
	    ["timer"] = 0,
	    ["pos"] = pos,
	 }
      else
	 music.players[dp]["timer"] = 0
	 minetest.sound_stop(music.players[dp]["handle"])
	 music.players[dp]["handle"] = minetest.sound_play(
	    music.tracks[track].name,
	    {
	       pos = pos,
	       gain = music.volume,
         })
      end

      -- Spawn a single note immediately
      local note = get_note(pos)
      note_particle(pos, note)

      -- Spawn a permanent particlespawner
      if particlespawners[dp] then
         -- Replace old particlespawener, if present
         minetest.delete_particlespawner(particlespawners[dp])
      end
      local particle = note_particle(pos, note, true)
      particlespawners[dp] = particle
   end

   function music.update(pos)
      local dp = minetest.hash_node_position(pos)

      if music.players[dp] ~= nil then
	 local node = minetest.get_node(pos)

	 if node.name ~= "rp_music:player" then
	    music.stop(pos)

	    return
	 end

	 local meta = minetest.get_meta(pos)
         local track = meta:get_int("music_player_track")

	 if music.tracks[track] then
	    if music.players[dp]["timer"] > music.tracks[track].length then
	       music.start(pos)
	    end
         end
      end
   end

   function music.toggle(pos)
      local dp = minetest.hash_node_position(pos)

      if music.players[dp] == nil then
	 music.start(pos)
	 return true
      else
	 music.stop(pos)
	 return false
      end
   end

   minetest.register_node(
      "rp_music:player",
      {
	 description = S("Music Player"),

	 tiles = {"music_top.png", "music_bottom.png", "music_side.png"},

	 inventory_image = "music_inventory.png",
	 wield_image = "music_inventory.png",

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

         sounds = rp_sounds.node_sound_defaults(),

	 on_construct = function(pos)
            music.start(pos)
         end,

	 after_destruct = function(pos)
            music.stop(pos)
         end,

	 on_rightclick = function(pos, node, clicker)
            if minetest.is_protected(pos, clicker:get_player_name()) and
                    not minetest.check_player_privs(clicker, "protection_bypass") then
                minetest.record_protection_violation(pos, clicker:get_player_name())
                return
            end
            music.toggle(pos)
	 end,

	 groups = {oddly_breakable_by_hand = 3, attached_node = 1, creative_decoblock = 1}
   })

   local function step(dtime)
      for dp, _ in pairs(music.players) do
	 music.players[dp]["timer"] = music.players[dp]["timer"] + dtime

	 music.update(music.players[dp]["pos"])
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
            if music.players[minetest.hash_node_position(pos)] == nil then
               local meta = minetest.get_meta(pos)
               if meta:get_int("music_player_enabled") == 1 then
                  music.start(pos)
               end
            end
         end
   })
else
   minetest.register_node(
      "rp_music:player",
      {
	 description = S("Music Player"),

	 tiles = {"music_top.png", "music_bottom.png", "music_side.png"},

	 inventory_image = "music_inventory.png",
	 wield_image = "music_inventory.png",

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

         sounds = rp_sounds.node_sound_defaults(),

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

	 groups = {oddly_breakable_by_hand = 3, attached_node = 1, interactive_node = 1}
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

-- Update music player infotexts
minetest.register_lbm(
   {
      label = "Update music players",
      name = "rp_music:update_music_players",
      run_at_every_load = true,
      nodenames = {"rp_music:player"},
      action = function(pos, node)
         local def = minetest.registered_nodes[node.name]
         local meta = minetest.get_meta(pos)
         if minetest.settings:get_bool("music_enable") then
            if meta:get_int("music_player_enabled") == 1 then
               meta:set_string("infotext", INFOTEXT_ON)
               local particle = note_particle(pos, get_note(pos), true)
               local hash = minetest.hash_node_position(pos)
               particlespawners[hash] = particle
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
