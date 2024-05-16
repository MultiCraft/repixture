#!/usr/bin/env lua5.1
-- -*- coding: utf-8 -*-

dofile("init.lua")
dofile("../tga_encoder/init.lua")

font_1 = unicode_text.hexfont(
   {
      kerning = true,
   }
)
font_1:load_glyphs(
   io.lines("unifont.hex")
)
font_1:load_glyphs(
   io.lines("U+FFFD.hex")
)

-- The following text purposely contains glyphs not in unifont.hex, to
-- show that these are rendered like U+FFFD REPLACEMENT CHARACTER (�).
local text = "ABC...	123!!!	(*ˊᗜˋ*)/ᵗᑋᵃᐢᵏ ᵞᵒᵘ* 😁\
\
U+0077	w	LATIN SMALL LETTER W\
U+00F0	ð	LATIN SMALL LETTER ETH\
U+2665	♥	BLACK HEART SUIT\
U+10348	𐍈	GOTHIC LETTER HWAIR"
local pixels = font_1:render_text(text)
local image = tga_encoder.image(pixels)
image:save("test.tga")

font_2 = unicode_text.hexfont(
   {
      background_color = { 1 },
      foreground_color = { 0 },
   }
)
font_2:load_glyphs(
   io.lines("unifont.hex")
)
font_2:load_glyphs(
   io.lines("unifont_upper.hex")
)
local file = io.open("UTF-8-demo.txt")

-- encode image with colormap (palette)
tga_encoder.image(
   font_2:render_text(
      file:read("*all")
   )
):save(
   "UTF-8-demo.tga",
   {
      colormap = {
         { 0xFF, 0xFF, 0xFF },
         { 0x00, 0x00, 0xFF },
      }
   }
)
file:close()

font_2.background_color = { 0, 0, 0 }
font_2.foreground_color = { 255, 255, 255 }
font_2.tabulator_size = 4 * 8
local file = io.open("example.txt")
local text = file:read("*all")
file:close()
local pixels = font_2:render_text(text)

-- colorize text pixels
for h = 1, #pixels do
   for w = 1, #pixels[h] do
      local pixel = pixels[h][w]
      if (
         255 == pixel[1] and
         255 == pixel[2] and
         255 == pixel[3]
      ) then
         pixel = {
            ( h + w ) % 128 + 128,
            ( h % w ) % 128 + 128,
            ( h - w ) % 128 + 128,
         }
      end
      pixels[h][w] = pixel
   end
end

-- encode image with 15-bit colors
tga_encoder.image(pixels):save(
   "example.tga",
   {
      color_format="A1R5G5B5",
      compression = "RAW",
   }
)
