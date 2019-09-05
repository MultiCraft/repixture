
--
-- Music player mod
-- By Kaadmy, for Pixture
--
local S = minetest.get_translator("music")

music = {}

music.default_track = minetest.settings:get("music_track") or "music_catsong"
music.track_length = tonumber(minetest.settings:get("music_track_length")) or 30.0
music.volume = tonumber(minetest.settings:get("music_volume")) or 1.0

-- Array of music players

music.players = {}

if minetest.settings:get_bool("music_enable") then
   function music.stop(pos)
      local dp = minetest.hash_node_position(pos)

      local meta = minetest.get_meta(pos)
      meta:set_string("infotext", S("Music Player (off)"))
      meta:set_int("music_player_enabled", 0)

      if music.players[dp] ~= nil then
	 minetest.sound_stop(music.players[dp]["handle"])
	 music.players[dp] = nil
      end
   end

   function music.start(pos)
      local dp = minetest.hash_node_position(pos)

      local meta = minetest.get_meta(pos)
      meta:set_string("infotext", S("Music Player (on)"))
      meta:set_int("music_player_enabled", 1)

      if music.players[dp] == nil then
	 music.players[dp] = {
	    ["handle"] = minetest.sound_play(
	       music.default_track,
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
	    music.default_track,
	    {
	       pos = pos,
	       gain = music.volume,
         })
      end
   end

   function music.update(pos)
      local dp = minetest.hash_node_position(pos)

      if music.players[dp] ~= nil then
	 local node = minetest.get_node(pos)

	 if node.name ~= "music:player" then
	    music.stop(pos)

	    return
	 end

	 if music.players[dp]["timer"] > music.track_length then
	    music.start(pos)
	 end
      end
   end

   function music.toggle(pos)
      local dp = minetest.hash_node_position(pos)

      if music.players[dp] == nil then
	 music.start(pos)
      else
	 music.stop(pos)
      end
   end

   minetest.register_node(
      "music:player",
      {
	 description = S("Music Player"),

	 tiles = {"music_top.png", "music_bottom.png", "music_side.png"},

	 inventory_image = "music_inventory.png",
	 wield_image = "music_inventory.png",

	 is_ground_content = false,
	 paramtype = "light",

	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = {-4/16, -0.5, -4/16, 4/16, -0.5 + (4/16), 4/16}
	 },

         sounds = default.node_sound_defaults(),

	 on_construct = function(pos)
            music.start(pos)
         end,

	 after_destruct = function(pos)
            music.stop(pos)
         end,

	 on_rightclick = function(pos)
            music.toggle(pos)
         end,

	 groups = {oddly_breakable_by_hand = 3, attached_node = 1}
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
	 nodenames = {"music:player"},
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
      "music:player",
      {
	 description = S("Music Player"),

	 tiles = {"music_top.png", "music_bottom.png", "music_side.png"},

	 inventory_image = "music_inventory.png",
	 wield_image = "music_inventory.png",

	 is_ground_content = false,
	 paramtype = "light",

	 drawtype = "nodebox",
	 node_box = {
	    type = "fixed",
	    fixed = {-4/16, -0.5, -4/16, 4/16, -0.5 + (4/16), 4/16}
	 },

         sounds = default.node_sound_defaults(),

	 on_construct = function(pos)
            local meta = minetest.get_meta(pos)

            meta:set_string("infotext", S("Music Player (disabled by server)"))
         end,

	 groups = {oddly_breakable_by_hand = 3, attached_node = 1}
   })
end

crafting.register_craft(
   {
      output = "music:player",
      items = {
         "group:planks 5",
         "default:ingot_steel",
      }
})

-- Achievements

achievements.register_achievement(
   "musician",
   {
      title = S("Sound Engineer"),
      description = S("Craft a music player."),
      times = 1,
      craftitem = "music:player",
})

default.log("mod:music", "loaded")
