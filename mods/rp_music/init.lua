
--
-- Music player mod
-- By Kaadmy, for Pixture
--
local S = minetest.get_translator("rp_music")

local INFOTEXT_ON = S("Music Player (on)")
local INFOTEXT_OFF = S("Music Player (off)")
local INFOTEXT_DISABLED = S("Music Player (disabled by server)")

music = {}

music.tracks = {
   { name = "music_catsong", length = 30.0 },
   { name = "music_greyarms", length = 82.0 },
}

music.volume = tonumber(minetest.settings:get("music_volume")) or 1.0

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
      else
	 music.stop(pos)
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

	 groups = {oddly_breakable_by_hand = 3, attached_node = 1}
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

-- Update nodes after the rename orgy after 1.5.3
minetest.register_lbm(
   {
      label = "Update music players",
      name = "rp_music:update_music_players",
      nodenames = {"rp_music:player"},
      action = function(pos, node)
         local def = minetest.registered_nodes[node.name]
         if minetest.settings:get_bool("music_enable") then
            local meta = minetest.get_meta(pos)
            if meta:get_int("music_player_enabled") == 1 then
               meta:set_string("infotext", INFOTEXT_ON)
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

default.log("mod:rp_music", "loaded")