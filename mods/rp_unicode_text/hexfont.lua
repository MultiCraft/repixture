#!/usr/bin/env lua5.1

--[[
Copyright © 2023  Ælla Chiana Moskopp (erle)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Dieses Programm hat das Ziel, die Medienkompetenz der Leser zu
steigern. Gelegentlich packe ich sogar einen handfesten Buffer
Overflow oder eine Format String Vulnerability zwischen die anderen
Codezeilen und schreibe das auch nicht dran.
]]--

--[[ List of scripts that this mod does NOT support.
The mod will refuse to render glyphs of any of
the listed scripts, even if the font supports them.
The glyphs will turn into U+FFFD REPLACEMENT CHARACTER.
This is because some writing systems are very complex
and would not render correctly by the current code.
So rather than render incorrectly, we refuse to render. ]]
-- TODO: Add support for these scripts
local UNSUPPORTED_SCRIPTS = {
   ["Arabic"] = true,
   ["Devanagari"] = true,
   ["Malayalam"] = true,
   ["Lao"] = true,
   ["Tamil"] = true,
   ["Mongolian"] = true,
   ["Phags_Pa"] = true,
}

-- Whether bidirectional text is recognized.
local ENABLE_BIDI = false

local modpath = minetest and
   minetest.get_modpath and
   minetest.get_modpath("rp_unicode_text") or
   "."
if ENABLE_BIDI then
   dofile(modpath .. "/luabidi/bidi.lua")
end
dofile(modpath .. "/pixelops.lua")
dofile(modpath .. "/utf8.lua")

local hexfont = setmetatable(
   {},
   {
      __call = function(self, ...)
         local new_hexfont = setmetatable(
            {},
            {
               __index = self
            }
         )
         new_hexfont:constructor(...)
         return new_hexfont
      end
   }
)

local iter = function(table_)
   local index = 0
   local total = #table_
   return function()
      index = index + 1
      if index <= total
      then
         return table_[index]
      end
   end
end

hexfont.constructor = function(self, properties)
   properties = properties or {}
   assert(
      "table" == type(properties)
   )

   -- Defaults
   self.background_color = properties.background_color or { 0x00 }
   self.foreground_color = properties.foreground_color or { 0xFF }

   -- scanline order “bottom-top” was chosen as the default to match
   -- the default scanline order of tga_encoder and to require users
   -- using another file format encoder to care about scanline order
   -- (users who “do not care about scanline order” might find their
   -- glyphs upside down … the fault, naturally, lies with the user)
   self.scanline_order = properties.scanline_order or "bottom-top"

   -- tab size = 8 half-width spaces when using GNU Unifont
   self.tabulator_size = properties.tabulator_size or 8 * 8
   self.kerning = properties.kerning or false

   local minimal_hexfont = {
      -- U+FFFD REPLACEMENT CHARACTER
      "FFFD:0000018003C006600C301998399C7F3E7E7E3E7C1FF80E70066003C001800000"
   }
   self:load_glyphs(
      iter(minimal_hexfont)
   )
end

-- Usage:
--    hexfont.load_glyphs(io.lines("unifont.hex"))
--    hexfont.load_glyphs(io.lines("unifont_upper.hex"))
hexfont.load_glyphs = function(self, iterator)
   assert( "function" == type(iterator), "Are you using io.lines()?" )
   for line in iterator do
      assert("string" == type(line))
      local codepoint_hex, bitmap_hex = line:match(
         "([0123456789ABCDEF]+):([01234567890ABCDEF]+)"
      )
      local codepoint = tonumber(codepoint_hex, 16)
      self[codepoint] = bitmap_hex
   end
end

-- Test: Glyphs are correctly loaded
local font = hexfont({})
assert(
   font[0xFFFD] == "0000018003C006600C301998399C7F3E7E7E3E7C1FF80E70066003C001800000"
)
font = nil

-- a lookup table was chosen for readability
-- DO NOT EVER REFUCKTOR IT INTO A FUNCTION!
local hex_to_bin = {
   ["0"] = "0000",
   ["1"] = "0001",
   ["2"] = "0010",
   ["3"] = "0011",
   ["4"] = "0100",
   ["5"] = "0101",
   ["6"] = "0110",
   ["7"] = "0111",
   ["8"] = "1000",
   ["9"] = "1001",
   ["A"] = "1010",
   ["B"] = "1011",
   ["C"] = "1100",
   ["D"] = "1101",
   ["E"] = "1110",
   ["F"] = "1111",
}

hexfont.bitmap_to_pixels = function(self, bitmap_hex)
   -- bitmap_hex must be a string of uppercase hexadecimal digits
   assert(
      "string" == type(bitmap_hex) and
      bitmap_hex:match("[0123456789ABCDEF]+") == bitmap_hex
   )

   -- background and foreground color must have equal color depth
   assert(
      "table" == type(self.background_color) and
      "table" == type(self.foreground_color) and
      #self.background_color == #self.foreground_color
   )
   local colormap = {
      self.background_color,
      self.foreground_color,
   }

   assert(
      "boolean" == type(self.kerning)
   )

   local height = 16
   local width = bitmap_hex:len() * 4 / height
   assert(
      16 == width or  -- full-width character
      8 == width      -- half-width character
   )

   -- convert hexadecimal bitmap to binary bitmap
   local bitmap_bin_table = {}
   for i = 1, #bitmap_hex do
      local character = bitmap_hex:sub(i,i)
      bitmap_bin_table[i] = hex_to_bin[character]
   end
   local bitmap_bin = table.concat(bitmap_bin_table)

   -- decode binary bitmap with “top-bottom” scanline order
   -- (i.e. the first encoded pixel is the top left pixel)
   local pixels = {}
   for scanline = 1, height do
      pixels[scanline] = {}
      for w = 1, width do
         local i = ( ( scanline - 1 ) * width ) + w
         local pixel
         pixel = colormap[tonumber(bitmap_bin:sub(i,i)) + 1]
         pixels[scanline][w] = pixel
      end
   end

   if self.kerning then
      -- remove rightmost column if it is empty
      local remove_rightmost_column = true
      for h = 1, height do
         if self.foreground_color == pixels[h][width] then
            remove_rightmost_column = false
         end
      end
      if remove_rightmost_column then
         for h = 1, height do
            pixels[h][width] = nil
         end
      end
       -- remove leftmost column if it and the column to its right are
       -- both empty, glyphs touch too often without the extra check
      local remove_leftmost_column = true
      for h = 1, height do
         if (
            self.foreground_color == pixels[h][1] or
            self.foreground_color == pixels[h][2]
         ) then
            remove_leftmost_column = false
         end
      end
      if remove_leftmost_column then
         for h = 1, height do
            for w = 1, width do
               pixels[h][w] = pixels[h][w+1]
            end
         end
      end
   end

   return pixels
end

hexfont.render_line = function(self, text)
   assert(
      "string" == type(text)
   )

   -- background and foreground color must have equal color depth
   assert(
      "table" == type(self.background_color) and
      "table" == type(self.foreground_color) and
      #self.background_color == #self.foreground_color
   )

   assert(
      "number" == type(self.tabulator_size)
   )

   local result = {}
   for i = 1, 16 do
      result[i] = {}
   end
   local codepoints = rp_unicode_text.utf8.text_to_codepoints(text)
   if ENABLE_BIDI then
      codepoints = rp_unicode_text.bidi.get_visual_reordering(codepoints)
   end
   for i = 1, #codepoints do
      local codepoint = codepoints[i]
      local ucdata = rp_unicode_text.unicodedata[codepoint]
      local bitmap_hex = self[codepoint]
      -- use U+FFFD as fallback character
      if nil == bitmap_hex then
         bitmap_hex = self[0xFFFD]
      else
         local script = ucdata and ucdata.script or "Unknown"
         -- Check if script is even supported; if not, refuse this glyph.
         if UNSUPPORTED_SCRIPTS[script] then
            bitmap_hex = self[0xFFFD]
         -- Refuse to render right-to-left characters if bidirectional support is disabled.
         elseif not ENABLE_BIDI and ucdata and
               (ucdata.bidi_class == "R" or ucdata.bidi_class == "AL") then
            bitmap_hex = self[0xFFFD]
         else
            -- We don't support combining marks.
            -- TODO: Support combining marks.
            local gc = ucdata and ucdata.general_category
            if gc == "Mn" or gc == "Me" or gc == "Mc" then
               bitmap_hex = self[0xFFFD]
            end
         end
      end
      local bitmap = self:bitmap_to_pixels(bitmap_hex)
      if 0x0009 == codepoint then  -- HT (horizontal tab)
         local result_width = #result[1]
         local tab_stop = math.floor(
            result_width / self.tabulator_size + 1
         ) * self.tabulator_size
         result = pixelops.pad_right(
            result,
            tab_stop - result_width,
            self.background_color
         )
      elseif ucdata and ucdata.default_ignorable_codepoint then
         -- Do nothing, this is an ignorable code point and should not be rendered at all
      else
         local result_width = #result[1]
         local bitmap_width = #bitmap[1]
         -- TODO: Support combining marks
         -- append current glyph at right edge of result
         for j = 1, 16 do
            for k = 1, bitmap_width do
               result[j][result_width + k] = bitmap[j][k]
            end
         end
      end
   end
   return result
end

hexfont.render_text = function(self, text)
   -- background and foreground color must have equal color depth
   assert(
      "table" == type(self.background_color) and
      "table" == type(self.foreground_color) and
      #self.background_color == #self.foreground_color
   )

   assert(
      "bottom-top" == self.scanline_order or
      "top-bottom" == self.scanline_order
   )

   local result
   local max_width = 0

   local codepoints = rp_unicode_text.utf8.text_to_codepoints(text)

   -- According to UAX #14, line breaks happen on:
   -- • U+000A LINE FEED
   -- • U+000D CARRIAGE RETURN (except as part of CRLF)
   -- • U+0085 NEXT LINE
   -- • U+2029 PARAGRAPH SEPARATOR
   --
   -- Hack: Replace all of those with LINE FEED.
   for i, codepoint in ipairs(codepoints) do
      if (
         0x0085 == codepoints[i] or
         0x2029 == codepoints[i]
      ) then
         codepoints[i] = 0x000A
      elseif (
         0x000D == codepoints[i]
      ) then
         -- CR, LF
         if i < #codepoints and 0x000A == codepoints[i+1] then
            -- Replace with line feed followed by ASCII DEL
            -- (the DEL character should be ignored)
            codepoints[i] = 0x000A
            codepoints[i+1] = 0x007F
         -- CR only
         else
            codepoints[i] = 0x000A
         end
      end
   end
   -- FIXME: Code below should only operate on codepoints! Converting
   -- back and forth makes it needlessly slow – but I do not know how
   -- to split a table properly to get a single table for each line …
   text = rp_unicode_text.utf8.codepoints_to_text(codepoints)
   local utf8_lines = string.split(text, "\n", true)
   for _, utf8_line in pairs(utf8_lines) do
      local pixels = self:render_line(utf8_line)
      assert( nil ~= pixels )
      if nil == result then
         result = pixels
      else
         for i = 1, #pixels do
            result[#result+1] = pixels[i]
         end
      end
      local pixels_width = #pixels[1]
      if pixels_width > max_width then
         max_width = pixels_width
      end
   end
   for _, scanline in ipairs(result) do
      local scanline_width = #scanline
      if scanline_width < max_width then
         for i = 1, max_width - scanline_width do
            scanline[scanline_width + i] = self.background_color
         end
         assert(
            max_width == #scanline
         )
      end
   end
   -- flip image upside down for ”bottom-top” scanline order
   -- (i.e. the first encoded pixel is the bottom left pixel)
   if "bottom-top" == self.scanline_order then
      result = pixelops.flip_vertically(result)
   end
   return result
end

rp_unicode_text.hexfont = hexfont