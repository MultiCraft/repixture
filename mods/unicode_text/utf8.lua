#!/usr/bin/env lua5.1

--[[
Copyright © 2023  Nils Dagsson Moskopp (erle)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Dieses Programm hat das Ziel, die Medienkompetenz der Leser zu
steigern. Gelegentlich packe ich sogar einen handfesten Buffer
Overflow oder eine Format String Vulnerability zwischen die anderen
Codezeilen und schreibe das auch nicht dran.
]]--

utf8 = {}

-- convert a table with codepoints into an UTF-8 string
-- inspired by <http://news.dieweltistgarnichtso.net/bin/unicode>
utf8.codepoints_to_text = function(codepoints)
   assert(
      "table" == type(codepoints)
   )
   for _, codepoint in ipairs(codepoints) do
      if (
         0 >= codepoint or
         1114111 < codepoint or
         math.floor(codepoint) ~= codepoint
      ) then
         error(
            string.format(
               "invalid codepoint: %s",
               codepoint
            )
         )
      end
   end
   local codepoints_encoded = {}
   codepoints_encoded.append = function(...)
      codepoints_encoded[#codepoints_encoded+1] = string.char(...)
   end
   for _, codepoint in ipairs(codepoints) do
      if codepoint <= 127 then
         -- one byte encoding
         codepoints_encoded.append(codepoint)
      elseif codepoint <= 2048 then
         -- two bytes encoding
         codepoints_encoded.append(
            math.floor(codepoint / 64) + 192,
            codepoint % 64 + 128
         )
      elseif codepoint <= 65535 then
         -- three bytes encoding
         codepoints_encoded.append(
            math.floor(codepoint / 4096) + 224,
            math.floor(codepoint / 64) % 64 + 128,
            codepoint % 64 + 128
         )
      elseif codepoint <= 1114111 then
         -- four bytes encoding
         codepoints_encoded.append(
            math.floor(codepoint / 262144) + 240,
            math.floor(codepoint / 4096) % 64 + 128,
            math.floor(codepoint / 64) % 64 + 128,
            codepoint % 64 + 128
         )
      end
   end
   return table.concat(codepoints_encoded)
end

-- Test one codepoint for each byte length:
local text = utf8.codepoints_to_text(
   {119, 240, 9829, 66376}  -- U+0077 U+00F0 U+2665 U+10348
)
assert(
   "wð♥𐍈" == text
)

-- convert an UTF-8 string into a table with codepoints
-- inspired by <https://lua-users.org/wiki/LuaUnicode>
utf8.text_to_codepoints = function(text)
   assert(
      "string" == type(text)
   )
   local result = {}
   local sequence_length = 0
   local i = 1
   while i <= #text do
      local value = nil
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

-- Test one codepoint for each byte length:
local codepoints = utf8.text_to_codepoints(
   "wð♥𐍈"  -- U+0077 U+00F0 U+2665 U+10348
)
assert(
   table.concat(codepoints, " ") == "119 240 9829 66376"
)
