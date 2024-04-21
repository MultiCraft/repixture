#!/usr/bin/env lua5.1
-- -*- coding: utf-8 -*-

dofile("hexdraw.lua")

local draw_line = function(line, properties)
   local codepoint_hex, bitmap_hex = line:match(
      "([0123456789ABCDEF]+):([01234567890ABCDEF]+)"
   )
   return hexdraw.bitmap_to_pixels(bitmap_hex, properties)
end

local print_bitmap = function(pixels)
   for w = 1, #pixels, 1 do
      for h = 1, #pixels[w] do
         io.write(table.concat(pixels[w][h]))
      end
      print()
   end
end

pixels_A = draw_line("0041:0000000018242442427E424242420000")
print_bitmap(pixels_A)
print("---")

pixels_A = draw_line(
   "0041:0000000018242442427E424242420000",
   {
      scanline_order = "top-bottom"
   }
)
print_bitmap(pixels_A)
print("---")

pixels_1 = hexdraw.bitmap_to_pixels(
   '07C01FF03FF87EFC7CFCFAFEFEFEFEFEFEFEFEFE7EFC783C3FF81FF007C00000',
   {
      background_color = { 11, 11, 0 },
      foreground_color = { 88, 88, 0 },
      scanline_order = "top-bottom",
   }
)
print_bitmap(pixels_1)
print("---")

bitmap_1 = draw_line(
   '2776:07C01FF03FF87EFC7CFCFAFEFEFEFEFEFEFEFEFE7EFC783C3FF81FF007C00000',
   {
      background_color = { 1 },
      foreground_color = { 8 },
      scanline_order = "bottom-top",
   }
)
print_bitmap(bitmap_1)
print("---")

-- everything looks like U+FFFD REPLACEMENT CHARACTER without fonts
text_bitmap_0 = hexdraw.render_text("wð♥𐍈😀!🂐겫")
print_bitmap(text_bitmap_0)
print("---")

hexdraw.load_font_file("unifont.hex")
hexdraw.load_font_file("unifont_upper.hex")

text_bitmap_1 = hexdraw.render_text("wð♥𐍈😀!🂐겫")
print_bitmap(text_bitmap_1)
print("---")

text_bitmap_2 = hexdraw.render_text(
   "wð♥𐍈😀!🂐겫",
   {
      background_color = { 7 },
      foreground_color = { 8 },
      scanline_order="top-bottom",
   }
)
print_bitmap(text_bitmap_2)
print("---")

text_bitmap_3 = hexdraw.render_text(
   "wð♥𐍈😀!🂐겫",
   {
      background_color = { 7 },
      foreground_color = { 8 },
      scanline_order="top-bottom",
      kerning = true,
   }
)
print_bitmap(text_bitmap_3)
print("---")

dofile("../tga_encoder/init.lua")

-- colormapped uncompressed image
tga_encoder.image(text_bitmap_1):save(
   "text_bitmap_1.tga",
   {
      colormap = {
         [0]={ 255, 127, 000 },
         [255]={ 000, 127, 255 },
      }
   }
)

-- R8G8B8A8 compressed image
tga_encoder.image(
   hexdraw.render_text(
      "wð♥𐍈😀!🂐겫",
      {
         background_color = { 0, 0, 0, 0 },
         foreground_color = { 0, 255, 0, 255 },
         kerning = true,
      }
   )
):save(
   "text_bitmap_4.tga",
   {
      color_format="B8G8R8A8",
      compression = "RLE"
   }
)

-- uncompressed grayscale image
tga_encoder.image(
   hexdraw.render_text(
      "wð♥𐍈😀!🂐겫",
      {
         background_color = { 0 },
         foreground_color = { 255 },
         kerning = true,
      }
   )
):save(
   "text_bitmap_5.tga",
   {
      color_format="Y8",
      compression = "RAW"
   }
)

local file = io.open("example.txt")
local text = file:read("*all")
file:close()
print(text)

-- render text (RGB, white-on-black)
local pixels = hexdraw.render_text(
   text,
   {
      background_color = { 000, 000, 000 },
      foreground_color = { 255, 255, 255 },
      tabulator_size = 4 * 8,
   }
)
print(#pixels, #pixels[1])

-- colorize white pixels
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
         pixels[h][w] = pixel
      end
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

local file = io.open("UTF-8-demo.txt")
local text = file:read("*all")
file:close()

local pixels = hexdraw.render_text(text)

-- tga_encoder uses grayscale colors if no colormap is given
tga_encoder.image(pixels):save("UTF-8-demo.tga")

unicode_renderer = hexdraw

local pixels = unicode_renderer.render_text(
   "wð♥𐍈😀!🂐겫",
   {
      foreground_color={ 0 },
      background_color={ 1 },
   }
)
tga_encoder.image(pixels):save(
   "image.tga",
   {
      colormap = {
         { 255, 127, 000 },
         { 000, 127, 255 },
      }
   }
)

local pixels = unicode_renderer.render_text(
   "wð♥𐍈😀!🂐겫",
   { kerning = true }
)
tga_encoder.image(pixels):save("image.tga")
