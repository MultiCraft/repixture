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

unicode_text = {}

local modpath = minetest and
   minetest.get_modpath and
   minetest.get_modpath("unicode_text") or
   "."
-- unicode_text only supports GNU Unifont .hex file format for now
dofile( modpath .. "/unicodedata.lua" )
dofile( modpath .. "/hexfont.lua" )
