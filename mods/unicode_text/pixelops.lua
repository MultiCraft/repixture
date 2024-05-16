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

pixelops = {}

-- Use this to invert image scanline order!
pixelops.flip_vertically = function(pixels)
   local result = {}
   local height = #pixels
   for h = 1, height do
      local scanline = height - h + 1
      result[scanline] = pixels[h]
   end
   return result
end

-- Test helper
local tc = table.concat

-- Test: pixelops.flip_vertically() with one-byte pixels
local i = {
   { { 1 }, { 2 }, { 3 } },
   { { 4 }, { 5 }, { 6 } },
   { { 7 }, { 8 }, { 9 } },
}
assert(
   "123" == tc({i[1][1][1], i[1][2][1], i[1][3][1]}) and
   "456" == tc({i[2][1][1], i[2][2][1], i[2][3][1]}) and
   "789" == tc({i[3][1][1], i[3][2][1], i[3][3][1]})
)
local j = pixelops.flip_vertically(i)
assert(
   "789" == tc({j[1][1][1], j[1][2][1], j[1][3][1]}) and
   "456" == tc({j[2][1][1], j[2][2][1], j[2][3][1]}) and
   "123" == tc({j[3][1][1], j[3][2][1], j[3][3][1]})
)
local k = pixelops.flip_vertically(j)
assert(
   "123" == tc({k[1][1][1], k[1][2][1], k[1][3][1]}) and
   "456" == tc({k[2][1][1], k[2][2][1], k[2][3][1]}) and
   "789" == tc({k[3][1][1], k[3][2][1], k[3][3][1]})
)
i = nil
j = nil
k = nil

-- Test: pixelops.flip_vertically() with three-byte pixels
local i = {
   { { 1, 1, 0 }, { 2, 2, 0 }, { 3, 3, 0 } },
   { { 4, 4, 0 }, { 5, 5, 0 }, { 6, 6, 0 } },
   { { 7, 7, 0 }, { 8, 8, 0 }, { 9, 9, 0 } },
}
assert(
   "110220330" == tc({tc(i[1][1]), tc(i[1][2]), tc(i[1][3])}) and
   "440550660" == tc({tc(i[2][1]), tc(i[2][2]), tc(i[2][3])}) and
   "770880990" == tc({tc(i[3][1]), tc(i[3][2]), tc(i[3][3])})
)
local j = pixelops.flip_vertically(i)
assert(
   "770880990" == tc({tc(j[1][1]), tc(j[1][2]), tc(j[1][3])}) and
   "440550660" == tc({tc(j[2][1]), tc(j[2][2]), tc(j[2][3])}) and
   "110220330" == tc({tc(j[3][1]), tc(j[3][2]), tc(j[3][3])})
)
local k = pixelops.flip_vertically(j)
assert(
   "110220330" == tc({tc(k[1][1]), tc(k[1][2]), tc(k[1][3])}) and
   "440550660" == tc({tc(k[2][1]), tc(k[2][2]), tc(k[2][3])}) and
   "770880990" == tc({tc(k[3][1]), tc(k[3][2]), tc(k[3][3])})
)
i = nil
j = nil
k = nil

-- Test: pixelops.flip_vertically() with four-byte pixels
local i = {
   { { 1, 1, 0, 0 }, { 2, 2, 0, 0 }, { 3, 3, 0, 0 } },
   { { 4, 4, 0, 0 }, { 5, 5, 0, 0 }, { 6, 6, 0, 0 } },
   { { 7, 7, 0, 0 }, { 8, 8, 0, 0 }, { 9, 9, 0, 0 } },
}
assert(
   "110022003300" == tc({tc(i[1][1]), tc(i[1][2]), tc(i[1][3])}) and
   "440055006600" == tc({tc(i[2][1]), tc(i[2][2]), tc(i[2][3])}) and
   "770088009900" == tc({tc(i[3][1]), tc(i[3][2]), tc(i[3][3])})
)
local j = pixelops.flip_vertically(i)
assert(
   "770088009900" == tc({tc(j[1][1]), tc(j[1][2]), tc(j[1][3])}) and
   "440055006600" == tc({tc(j[2][1]), tc(j[2][2]), tc(j[2][3])}) and
   "110022003300" == tc({tc(j[3][1]), tc(j[3][2]), tc(j[3][3])})
)
local k = pixelops.flip_vertically(j)
assert(
   "110022003300" == tc({tc(k[1][1]), tc(k[1][2]), tc(k[1][3])}) and
   "440055006600" == tc({tc(k[2][1]), tc(k[2][2]), tc(k[2][3])}) and
   "770088009900" == tc({tc(k[3][1]), tc(k[3][2]), tc(k[3][3])})
)
i = nil
j = nil
k = nil

pixelops.pad_right = function(pixels, amount, padding)
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
   local result = {}
   local height = #pixels
   local width = #pixels[1]
   -- copy every pixel
   for h = 1, height do
      result[h] = {}
      for w = 1, width do
         result[h][w] = pixels[h][w]
      end
   end
   -- pad on right side
   for h = 1, height do
      for a = 1, amount do
         result[h][width + a] = padding
      end
   end
   return result
end

-- Test: pixelops.pad_right() with 1-byte pixels
local i = {
   { { 1 }, { 0 } },
   { { 0 }, { 1 } },
   { { 1 }, { 0 } },
}
assert(
   "10" == tc({i[1][1][1], i[1][2][1]}) and
   "01" == tc({i[2][1][1], i[2][2][1]}) and
   "10" == tc({i[3][1][1], i[3][2][1]})
)
local j = pixelops.pad_right(
   i,
   1,
   { 2 }
)
assert(
   "102" == tc({j[1][1][1], j[1][2][1], j[1][3][1]}) and
   "012" == tc({j[2][1][1], j[2][2][1], j[2][3][1]}) and
   "102" == tc({j[3][1][1], j[3][2][1], j[3][3][1]})
)
local k = pixelops.pad_right(
   i,
   2,
   { 3 }
)
assert(
   "1033" == tc({k[1][1][1], k[1][2][1], k[1][3][1], k[1][4][1]}) and
   "0133" == tc({k[2][1][1], k[2][2][1], k[2][3][1], k[2][4][1]}) and
   "1033" == tc({k[3][1][1], k[3][2][1], k[3][3][1], k[3][4][1]})
)
i = nil
j = nil
k = nil
