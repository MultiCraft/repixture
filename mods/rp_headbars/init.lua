--
-- Headbars mod
--

local headbars = {}

local enable_damage = minetest.settings:get_bool("enable_damage")

local enable_headbars = minetest.settings:get_bool("headbars_enable")
if enable_headbars == nil then enable_headbars = true end

local headbars_scale = tonumber(minetest.settings:get("headbars_scale")) or 1.0
headbars_scale = math.max(0.25, headbars_scale)

function headbars.get_sprite(icon, background, max, amt)
   local img = "[combine:" .. (max * 8) .. "x16:0,0=blank.png:0,0=blank.png"

   if amt < max then
      for i = 0, max / 2 do
	 img = img .. "^[combine:16x16:0,0=blank.png:" .. (i * 16) .. ",0=" .. background
      end
   end

   img = img .. "^([combine:" .. (max * 8) .. "x16:0,0=blank.png:0,0=blank.png"

   for i = 0, max / 2 do
      if i < (amt - 1) / 2 then
	 img = img .. "^[combine:" .. (max * 8) .. "x16:0,0=blank.png:" .. (i * 16) .. ",0=" .. icon
      elseif i < amt / 2 then
	 img = img .. "^[combine:" .. (max * 8) .. "x16:0,0=blank.png:" .. (i * 16) .. ",0=" .. icon
	 img = img .. "^[combine:" .. (max * 8) .. "x16:0,0=blank.png:" .. (i * 16) .. ",0=headbars_half.png"
      end
   end

   img = img .. "^[makealpha:255,0,255)"

   return img
end

minetest.register_entity(
   "rp_headbars:hpbar",
   {
      visual = "sprite",
      visual_size = {x = 1 * headbars_scale, y = 0.1 * headbars_scale, z = 1},
      textures = {headbars.get_sprite("headbars_heart.png", "blank.png", 20, 20)},

      glow = 5,

      physical = false,
      pointable = false,
      static_save = false,

      _wielder = nil,

      on_activate = function(self, staticdata)
         self.object:set_armor_groups({immortal=1})
         local name = staticdata
         local wielder = minetest.get_player_by_name(name)
         if wielder and wielder:is_player() then
            self._wielder = wielder
         else
            minetest.log("info", "[rp_headbars] Attempted to spawn orphan HP bar entity!")
            self.object:remove()
            return
         end
      end,
      on_step = function(self, dtime)
         local ent = self._wielder

         -- Remove orphan HP bar
         if ent == nil or (minetest.get_player_by_name(ent:get_player_name()) == nil) then
            self.object:remove()
            return
         end

         if self.object:get_attach() == nil then
            self.object:set_attach(ent, "", {x = 0, y = 19, z = 0}, {x = 0, y = 0, z = 0})
         end

         local hp = ent:get_hp()

         -- Update displayed hearts
         self.object:set_properties({textures = {headbars.get_sprite("headbars_heart.png", "headbars_heart_bg.png", 20, hp)}})
      end,
})

function headbars.attach_hpbar(to)
   if not enable_damage then return end
   if not enable_headbars then return end

   local pos = to:get_pos()
   local name = to:get_player_name()
   local bar = minetest.add_entity(pos, "rp_headbars:hpbar", name)

   if bar == nil then
      minetest.log("error", "[rp_headbars] HP bar failed to spawn!")
      return
   end
end

minetest.register_on_joinplayer(function(player)
	minetest.after(1, function(player)
		if player and player:is_player() then
			headbars.attach_hpbar(player)
		end
	end, player)
end)
