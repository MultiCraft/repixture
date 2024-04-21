#!/usr/bin/env lua5.1
-- -*- coding: utf-8 -*-

hexdraw = {}

-- only U+FFFD REPLACEMENT CHARACTER is necessary …
-- DO NOT EXTEND THIS TABLE – JUST LOAD A HEX FONT!
local bitmaps_hex = {
   [0xFFFD] = "0000018003C006600C301998399C7F3E7E7E3E7C1FF80E70066003C001800000"
}

-- load glyphs from a .hex format font file
hexdraw.load_font_file = function(filename)
   assert(
      "string" == type(filename)
   )
   for line in io.lines(filename) do
      local codepoint_hex, bitmap_hex = line:match(
         "([0123456789ABCDEF]+):([01234567890ABCDEF]+)"
      )
      codepoint = tonumber(codepoint_hex, 16)
      bitmaps_hex[codepoint] = bitmap_hex
   end
end

-- TODO: write tests for hexdraw.load_hex_font()

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

-- convert a binary bitmap to pixels accepted by tga_encoder
--
-- properties.background_color and properties.foreground_color must
-- have the same amount of entries. Use one entry for grayscale or
-- colormapped (palette) output, use three entries for RGB and four
-- entries for RGBA.
-- 
hexdraw.bitmap_to_pixels = function(bitmap_hex, properties)
   -- bitmap_hex must be a string of uppercase hexadecimal digits
   assert(
      "string" == type(bitmap_hex) and
      bitmap_hex:match("[0123456789ABCDEF]+") == bitmap_hex
   )

   local properties = properties or {}
   assert(
      "table" == type(properties)
   )

   local background_color = properties.background_color or { 0 }
   local foreground_color = properties.foreground_color or { 255 } 
   -- background and foreground color must have equal color depth
   assert(
      #background_color == #foreground_color
   )
   local colormap = {
      background_color,
      foreground_color,
   }

   local kerning = properties.kerning or false
   assert(
      "boolean" == type(kerning)
   )

   -- scanline order “bottom-top” was chosen as the default to match
   -- the default scanline order of tga_encoder and to require users
   -- using another file format encoder to care about scanline order
   -- (users who “do not care about scanline order” might find their
   -- glyphs upside down … the fault, naturally, lies with the user)
   local scanline_order = properties.scanline_order or "bottom-top"
   assert(
      "bottom-top" == scanline_order or
      "top-bottom" == scanline_order
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
   bitmap_bin = table.concat(bitmap_bin_table)

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

   -- flip image upside down for ”bottom-top” scanline order
   -- (i.e. the first encoded pixel is the bottom left pixel)
   if "bottom-top" == scanline_order then
      local pixels_tmp = {}
      for h = 1, height do
         local scanline = height - h + 1
         pixels_tmp[scanline] = pixels[h]
      end
      pixels = pixels_tmp
   end

   if kerning then
      -- remove rightmost column if it is empty
      local remove_rightmost_column = true
      for h = 1, height do
         if foreground_color == pixels[h][width] then
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
            foreground_color == pixels[h][1] or
            foreground_color == pixels[h][2]
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

-- convert an UTF-8 string into a table with codepoints
-- inspired by <https://lua-users.org/wiki/LuaUnicode>
local utf8_text_to_codepoints = function(text)
   assert(
      "string" == type(text)
   )
   local result = {}
   local sequence_length = 0
   local i = 1
   while i <= #text do
      value = nil
      local byte_1, byte_2, byte_3, byte_4
      byte_1 = string.byte(text, i)
      local sequence_length =
         byte_1 <= 127 and 1 or  -- 0xxxxxxx
         byte_1 <= 223 and 2 or  -- 110xxxxx 10xxxxxx
         byte_1 <= 239 and 3 or  -- 1110xxxx 10xxxxxx 10xxxxxx
         byte_1 <= 247 and 4 or  -- 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
         error("invalid UTF-8 sequence")
      if sequence_length > 1 then
         byte_2 = string.byte(text, i+1)
      end
      if sequence_length > 2 then
         byte_3 = string.byte(text, i+2)
      end
      if sequence_length > 3 then
         byte_4 = string.byte(text, i+3)
      end
      if 1 == sequence_length then
         -- 0xxxxxxx
         value = byte_1
      elseif 2 == sequence_length then
         -- 110xxxxx 10xxxxxx
         value =
            (byte_1 % 64) * 64 +
            (byte_2 % 64)
      elseif 3 == sequence_length then
         -- 1110xxxx 10xxxxxx 10xxxxxx
         value =
            (byte_1 % 32) * 4096 +
            (byte_2 % 64) * 64 +
            (byte_3 % 64)
      elseif 4 == sequence_length then
         -- 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
         value =
            (byte_1 % 16) * 262144 +
            (byte_2 % 64) * 4096 +
            (byte_3 % 64) * 64 +
            (byte_4 % 64)
      end

      table.insert(result, value)
      i = i + sequence_length
   end
   return result
end

local codepoints = utf8_text_to_codepoints(
   "wð♥𐍈"  -- U+0077 U+00F0 U+2665 U+10348
)
assert(
   table.concat(codepoints, " ") == "119 240 9829 66376"
)

local right_pad = function(pixels, amount, padding)
   assert(
      "table" == type(pixels)
   )
   assert(
      "number" == type(amount) and
      amount > 0
   )
   assert(
      "table" == type(padding)
   )
   local result = pixels
   local height = #pixels
   local width = #pixels[1]
   for h = 1, height do
      for a = 1, amount do
         pixels[h][width + a] = padding
      end
   end
   return result
end

local is_combining_character = {}

local add_codepoint_range = function(table_, value, first, last)
   for codepoint = first, last do
      table_[codepoint] = value
   end
end

-- Combining Diacritical Marks
add_codepoint_range(is_combining_character, true, 0x0300, 0x036F)

assert( is_combining_character[0x0300] )
assert( is_combining_character[0x0301] )
assert( is_combining_character[0x036E] )
assert( is_combining_character[0x036F] )

-- Combining Diacritical Marks Extended
add_codepoint_range(is_combining_character, true, 0x1AB0, 0x1AFF)

-- Malayalam
add_codepoint_range(is_combining_character, true, 0x0D00, 0x0D03)
add_codepoint_range(is_combining_character, true, 0x0D3B, 0x0D3C)
add_codepoint_range(is_combining_character, true, 0x0D3E, 0x0D44)
add_codepoint_range(is_combining_character, true, 0x0D46, 0x0D48)
add_codepoint_range(is_combining_character, true, 0x0D4A, 0x0D4E)
is_combining_character[0x0D57] = true
add_codepoint_range(is_combining_character, true, 0x0D62, 0x0D63)

-- Thai
is_combining_character[0x0E31] = true
add_codepoint_range(is_combining_character, true, 0x0E34, 0x0E3A)
add_codepoint_range(is_combining_character, true, 0x0E47, 0x0E4E)

-- Combining Diacritical Marks for Symbols
add_codepoint_range(is_combining_character, true, 0x20D0, 0x20FF)

-- Combining Half Marks
add_codepoint_range(is_combining_character, true, 0xFE20, 0xFE2F)

-- Combining Diacritical Marks Supplement
add_codepoint_range(is_combining_character, true, 0x1DC0, 0x1DFF)

assert( nil == is_combining_character[0x0077] )
assert( nil == is_combining_character[0x00F0] )
assert( nil == is_combining_character[0x2665] )
assert( nil == is_combining_character[0x010348] )

local render_utf8_line = function(utf8_text, properties)
   assert(
      "string" == type(utf8_text)
   )

   properties = properties or {}
   assert(
      "table" == type(properties)
   )

   -- default colors are black (0) & white (255) in 1 bit color depth
   local background_color = properties.background_color or { 0 }
   local foreground_color = properties.foreground_color or { 255 }
   -- background and foreground color must have equal color depth
   assert(
      #background_color == #foreground_color
   )

   local minimal_width = properties.minimal_width or 0
   assert(
      "number" == type(minimal_width)
   )

   local tabulator_size = properties.tabulator_size or 8 * 8
   assert(
      "number" == type(tabulator_size)
   )

   local result
   local codepoints = utf8_text_to_codepoints(utf8_text)
   for i = 1, #codepoints do
      local codepoint = codepoints[i]
      local bitmap_hex = bitmaps_hex[codepoint]
      -- use U+FFFD as fallback character
      if nil == bitmap_hex then
         bitmap_hex = bitmaps_hex[0xFFFD]
      end
      local bitmap = hexdraw.bitmap_to_pixels(
         bitmap_hex,
         properties
      )
      -- FIXME: the way text is rendered below only works for LTR
      -- scripts. render RTL scripts (like hebrew or arabic), the
      -- blitting logic needs to be mirrored.
      --
      -- TODO: For mixes of LTR and RTL scripts (i.e. a hebrew word
      -- embedded in an english text), render a separate line with
      -- separate direction on each change of direction
      --
      -- TODO: figure out if the code can use luabidi here
      if 0x0009 == codepoint then  -- HT (horizontal tab)
         if nil == result then
            result = {}
            for i = 1, 16 do
               result[i] = { background_color }
            end
         end
         local result_width = #result[1]
         local tab_stop = math.floor(
            result_width / tabulator_size + 1
         ) * tabulator_size
         result = right_pad(
            result,
            tab_stop - result_width,
            background_color
         )
      elseif nil == result then
         result = bitmap
      else
         local result_width = #result[1]
         local bitmap_width = #bitmap[1]
         if is_combining_character[codepoint] then
            -- render combining glyph over previous glyph
            -- FIXME: this is horrible, but seems to work
            for j = 1, 16 do
               for k = 1, bitmap_width do
                  if foreground_color == bitmap[j][k] then
                     result[j][result_width - bitmap_width + k] = bitmap[j][k]
                  end
               end
            end
         else
            -- append current glyph at right edge of result
            -- FIXME: only works for LTR, should use UAX #9
            for j = 1, 16 do
               for k = 1, bitmap_width do
                  result[j][result_width + k] = bitmap[j][k]
               end
            end
         end
      end
   end
   return result
end

hexdraw.render_text = function(utf8_text, properties)
   local properties = properties or {}
   assert(
      "table" == type(properties)
   )

   local background_color = properties.background_color or { 0 }
   local foreground_color = properties.foreground_color or { 255 }
   -- background and foreground color must have equal color depth
   assert(
      #background_color == #foreground_color
   )

   local scanline_order = properties.scanline_order or "bottom-top"
   assert(
      "bottom-top" == scanline_order or
      "top-bottom" == scanline_order
   )

   local result
   -- TODO: implement UAX #14
   for utf8_line in string.gmatch(utf8_text .. "\n", "([^\n]*)\n") do
      local pixels = render_utf8_line(
         utf8_line,
         properties
      )
      if nil == pixels then
         pixels = {}
         for i = 1, 16 do
            pixels[i] = { background_color }
         end
      end
      if nil == result then
         result = pixels
      else
         local result_width = #result[1]
         local pixels_width = #pixels[1]
         if result_width > pixels_width then
            pixels = right_pad(
               pixels,
               result_width - pixels_width,
               background_color
            )
         elseif result_width < pixels_width then
            result = right_pad(
               result,
               pixels_width - result_width,
               background_color
            )
         end
         assert(
            #result[1] == #pixels[1]
         )
         if "bottom-top" == scanline_order then
            for i = #pixels, 1, -1 do
               table.insert(result, 1, pixels[i])
            end
         end
         if "top-bottom" == scanline_order then
            for i = 1, #pixels do
               result[#result+1] = pixels[i]
            end
         end
      end
   end
   return result
end
