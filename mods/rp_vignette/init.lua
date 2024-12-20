--
-- Vignette mod
--

local enable_vignette = minetest.settings:get_bool("vignette_enable")

local hud_def_type_field
if minetest.features.hud_def_type_field then
    hud_def_type_field = "type"
else
    hud_def_type_field = "hud_elem_type"
end

if enable_vignette then
   local vignette_definition = {
      [hud_def_type_field] = "image",
      position = {x = 0.5, y = 0.5},
      scale = {x = -100, y = -100},
      alignment = 0,
      text = "vignette_vignette.png",
      z_index = -400,
   }

   local function on_joinplayer(player)
      if not player:is_player() then
         return
      end

      player:hud_add(vignette_definition)
   end

   minetest.register_on_joinplayer(on_joinplayer)
end
