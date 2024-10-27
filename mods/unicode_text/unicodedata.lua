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

local modpath = minetest and
   minetest.get_modpath and
   minetest.get_modpath("unicode_text") or
   "."

-- Maximum possible codepoint
local MAX_CODEPOINT = 0x10FFFF

local unicodedata = {}

-- https://www.unicode.org/reports/tr44/#Format_Conventions
-- https://www.unicode.org/reports/tr44/#UnicodeData.txt
local pattern = "^(%x+)" .. (";([^;]*)"):rep(14) .. "$"

-- https://www.unicode.org/Public/15.0.0/ucd/UnicodeData.txt
for line in io.lines(modpath .. "/ucd/UnicodeData.txt") do
   local properties = {}
   codepoint_hex,
      properties.name,
      properties.general_category,
      properties.canonical_combining_class,
      properties.bidi_class,
      properties.decomposition_mapping,
      properties.decimal_digit_value,
      properties.digit_value,
      properties.numeric_value,
      properties.bidi_mirrored,
      _, -- Unicode 1.0 Name (obsolete)
      _, -- 10464 comment field (obsolete)
      properties.simple_uppercase_mapping,
      properties.simple_lowercase_mapping,
      properties.simple_titlecase_mapping
      = line:match(pattern)
   local codepoint = tonumber(codepoint_hex, 16)
   unicodedata[codepoint] = properties
end

-- https://www.unicode.org/Public/15.0.0/ucd/Scripts.txt
for line in io.lines(modpath .. "/ucd/Scripts.txt") do
   local script
   local is_comment = string.sub(line, 1, 1) == "#"
   local entries = string.split(line, ";", true)
   if entries then
      local e_codepoints = entries[1]
      if not string.match(e_codepoints, "#") then
         local e_script = entries[2]
         local script
         if e_script then
            script = string.match(e_script, "[a-zA-Z_]+")
         end
         local codepoint1, codepoint2
         local tohex = tonumber(e_codepoints, 16)
         if tohex then
            codepoint1 = tohex
            codepoint2 = tohex
         elseif e_codepoints ~= "" then
            codepoint1, codepoint2 = string.match(e_codepoints, "([a-fA-F0-9]+)%.%.([a-fA-F0-9]+)")
            if codepoint1 and codepoint2 then
               codepoint1 = tonumber(codepoint1, 16)
               codepoint2 = tonumber(codepoint2, 16)
            end
         end
         if script and codepoint1 and codepoint2 then
            assert(codepoint1 >= 0 and codepoint1 <= MAX_CODEPOINT)
            assert(codepoint2 >= 0 and codepoint2 <= MAX_CODEPOINT)
            for cp=codepoint1, codepoint2 do
               if not unicodedata[cp] then
                  unicodedata[cp] = {}
               end
               unicodedata[cp].script = script
            end
         end
      end
   end
end

-- https://www.unicode.org/Public/15.1.0/ucd/DerivedCoreProperties.txt
-- (abridged version containing only properties we need)
for line in io.lines(modpath .. "/ucd/DerivedCoreProperties_abridged.txt") do
   local script
   local is_comment = string.sub(line, 1, 1) == "#"
   local entries = string.split(line, ";", true)
   if entries and #entries >= 2 then
      local e_codepoints = entries[1]
      if not string.match(e_codepoints, "#") then
         local e_prop = string.match(entries[2], "([a-zA-Z0-9_]+)")
         if e_prop == "Default_Ignorable_Code_Point" then
            local codepoint1, codepoint2
            local tohex = tonumber(e_codepoints, 16)
            if tohex then
               codepoint1 = tohex
               codepoint2 = tohex
            elseif e_codepoints ~= "" then
               codepoint1, codepoint2 = string.match(e_codepoints, "([a-fA-F0-9]+)%.%.([a-fA-F0-9]+)")
               if codepoint1 and codepoint2 then
                  codepoint1 = tonumber(codepoint1, 16)
                  codepoint2 = tonumber(codepoint2, 16)
               end
            end
            if codepoint1 and codepoint2 then
               assert(codepoint1 >= 0 and codepoint1 <= MAX_CODEPOINT)
               assert(codepoint2 >= 0 and codepoint2 <= MAX_CODEPOINT)
               for cp=codepoint1, codepoint2 do
                  if not unicodedata[cp] then
                     unicodedata[cp] = {}
                  end
                  unicodedata[cp].default_ignorable_codepoint = true
               end
            end
         end
      end
   end
end



-- Test character data
local w = unicodedata[0x0077]
assert( "LATIN SMALL LETTER W" == w.name )
assert( "Ll" == w.general_category )  -- a lowercase letter
assert( "Latin" == w.script)

w = unicodedata[0x00AD] -- SOFT HYPHEN
assert( true == w.default_ignorable_codepoint)

unicode_text.unicodedata = unicodedata
