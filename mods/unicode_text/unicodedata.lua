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

local modpath = minetest and
   minetest.get_modpath and
   minetest.get_modpath("unicode_text") or
   "."

unicodedata = {}

-- https://www.unicode.org/reports/tr44/#Format_Conventions
-- https://www.unicode.org/reports/tr44/#UnicodeData.txt
-- https://www.unicode.org/L2/L1999/UnicodeData.html
local pattern = "^(%x+)" .. (";([^;]*)"):rep(14) .. "$"
for line in io.lines(modpath .. "/UnicodeData.txt") do
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

local w = unicodedata[0x0077]
assert( "LATIN SMALL LETTER W" == w.name )
assert( "Ll" == w.general_category )  -- a lowercase letter
