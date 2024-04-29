unicode_text - Repixture version
================================

This is `unicode_text`, but modified for Repixture!
Original mod by erlehmann.

Synopsis
--------

This repository contains Lua code to render Unicode text to a pixels table.

`unicode_text` requires font files encoded in GNU Unifont hexfont format.

The resulting pixels table can be written to a file using `tga_encoder`_.

However, `tga_encoder` is not neccessary.

.. _`tga_encoder`: https://git.minetest.land/erlehmann/tga_encoder

Features
--------

- Render UTF-8-encoded text to a pixels table
- Supports bidirectional text
- Choose font color
- Optional kerning
- Custom tab size
- Replacement character for missing characters and unsupported writing systems

However, there are some limitations:

- Combining characters are not supported
- The only right-to-left script that works is Hebrew, but without diacritics
- RTL text is still rendered left-justified
- This mod refuses to render glyphs of complex writing systems it doesn't support
  even if the font has them. Our motto: Rather refuse to render, than render incorrectly!
- GNU Unifont is not included!

Example Code
------------

If you are impatient, just copy and paste the following example code:

.. code::

   local font = unicode_text.hexfont()
   font:load_glyphs(io.lines("unifont.hex"))
   font:load_glyphs(io.lines("unifont_upper.hex"))
   local pixels = font:render_text("wð♥𐍈😀!🂐겫")
   tga_encoder.image(pixels):save("unicode.tga")

The above code creates an 80×16 TGA file with white-on-black text.

Hexfont Tables
--------------

All Unicode text rendering is done through hexfont tables.

Instantiation
+++++++++++++

To create a hexfont table with default parameters, do:

.. code::

   font = unicode_text.hexfont()

The above code is equivalent to the following code:

.. code::

   font = unicode_text.hexfont(
      {
         background_color = { 0x00 },
         foreground_color = { 0xFF },
         scanline_order = "bottom-top",
         tabulator_size = 64,
         kerning = false,
      }
   )

Loading Glyphs
++++++++++++++

To render text, it is suggested to load glyphs, e.g. from GNU Unifont:

.. code::

   font:load_glyphs(io.lines("unifont.hex"))
   font:load_glyphs(io.lines("unifont_upper.hex"))

Font Properties
+++++++++++++++

Colors
^^^^^^

`background_color` and `foreground_color` contain 1 or 3 or 4 bytes
that represent color channels. The tables must have the same length
for the output to be a valid pixels table.

Scanline Order
^^^^^^^^^^^^^^

`scanline_order` can have the value `bottom-top` (i.e. the first
encoded pixel is the bottom left pixel) or the value `top-bottom`
(i.e. the first encoded pixel is the top left pixel).

Tabulator Size
^^^^^^^^^^^^^^

`tabulator_size` represents the number of pixels a tab stops is wide.

Kerning
^^^^^^^

If `kerning` is `true`, the space between adjacent glyphs is reduced.

Using kerning can make rendered glyphs a few pixels narrower, which is
likely to make fonts appear variable-width even if glyphs have a fixed
width. One possible consequence is that ASCII & Shift-JIS art may look
wrong.

Writing Files
-------------

A pixels table can be encoded into a file using `tga_encoder`:

.. code::

   local pixels = font:render_text("wð♥𐍈😀!🂐겫")
   tga_encoder.image(pixels):save("image.tga")

The above code writes an uncompressed 80×16 grayscale bitmap.

Pixels Tables
+++++++++++++

Pixels tables represent output rendered by `unicode_text`.

Pixels tables contains tables that represent scanlines.

The number of scanlines equals the height of an image.

Examples:

.. code::

   -- white “:” on black background
   local pixels_grayscale = {
      { { 0x00 }, { 0xFF }, { 0x00 } },
      { { 0x00 }, { 0x00 }, { 0x00 } },
      { { 0x00 }, { 0xFF }, { 0x00 } },
   }

   -- blue “x” on red background
   local _ = { 200, 0, 0 }
   local x = { 0, 0, 200 }
   local pixels_rgb = {
      { x, _, _, _, x },
      { _, x, _, x, _ },
      { _, _, x, _, _ },
      { _, x, _, x, _ },
      { x, _, _, _, x },
   }

   -- green “+” on blue 50% opacity background
   local _ = { 0, 0, 255, 127 }
   local x = { 0, 255, 0, 255 }
   local pixels_rgba = {
      { _, _, x, _, _ },
      { _, _, x, _, _ },
      { x, x, x, x, x },
      { _, _, x, _, _ },
      { _, _, x, _, _ },
   }


Scanline Tables
^^^^^^^^^^^^^^^

Scanline tables represent lines of a bitmap.

Scanline tables contain tables representing single pixels.

The number of pixels in a scanline table equals the width of an image.
This means that all scanlines must have the same width.

Note that the default scanline order is “bottom-to-top”;
this means that bitmap[1][1] is the “bottom left” pixel.

Pixel Tables
^^^^^^^^^^^^

A pixel table contains 1 / 3 / 4 numbers (color channels).
A single color channel value contains 1 byte – i.e. 8 bit.
All pixel tables for one bitmap must have the same length.

======== ============== ============== ===== ===================================
Channels Example Pixel  Channel Order  Depth Possible TGA Color Format Encodings
======== ============== ============== ===== ===================================
1        { 127 }        not necessary  8bpp  Grayscale (Y8) / Colormap (Palette)
3        { 33, 66, 99 } { R, G, B }    24bpp B8G8R8 / 16bpp A1R5G5B5
4        { 0, 0, 0, 0 } { R, G, B, A } 32bpp RGBA (B8G8R8A8)
======== ============== ============== ===== ===================================

Colormapped (Palette)
^^^^^^^^^^^^^^^^^^^^^

When `foreground_color` and `background_color` are single values, a colormap (palette) can be given to `tga_encoder`.

.. code::

   tga_encoder.image(pixels):save(
      "image.tga",
      {
         colormap = {
            { 255, 127, 0 },
            { 0, 127, 255 },
         }
      }
   )

Note that colormap indexing starts at zero, as it uses a pixel's byte value.
In the above example, this means:

- some pixels have the color `{ 255, 127, 0 }` (orange)
- some pixels have the color `{ 0, 127, 255 }` (blue)

Frequently Questioned Answers
-----------------------------

Why is my text all question marks?
++++++++++++++++++++++++++++++++++

Glyphs not in a font are rendered like U+FFFD REPLACEMENT CHARACTER
(�). You did load a font containing the glyphs you wanted, did you?

Why does this repository not contain Unifont?
+++++++++++++++++++++++++++++++++++++++++++++

I do not like the burden of updating those files.

I suggest that you get current font files yourself.

Hint 1: <https://unifoundry.com/unifont/index.html>

Hint 2: <https://trevorldavis.com/R/hexfont/>

Why is Arabic / Hebrew / Urdu etc. text rendered somewhat wrong?
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

I did not implement the entire `Unicode Bidirectional Algorithm`_.

If you are able to read a right-to-left language, please help …

.. _`Unicode Bidirectional Algorithm`:
   https://www.unicode.org/reports/tr9/

Why is the generated pixels table upside down?
++++++++++++++++++++++++++++++++++++++++++++++

Like in school, the x axis points right and the y axis points up …

Scanline order `bottom-top` was chosen as the default to match the
default scanline order of `tga_encoder` and to require users using
another file format encoder to care about scanline order. Users of
`unicode_text` that “do not care about scanline order” may see the
glyphs upside down – the fault, naturally, lies with the user.

TGA is an obsolete format! Why write TGA files?
+++++++++++++++++++++++++++++++++++++++++++++++

TGA is a very simple file format that supports many useful features.
It is so simple that you can even create an image with a hex editor.

TGA is used for textures in 3D applications or games. It was the
default output format in Blender_ and used by Valve_ and Mojang_.

.. _Blender: https://download.blender.org/documentation/htmlI/ch17s04.html

.. _Valve: https://developer.valvesoftware.com/wiki/TGA

.. _Mojang:
   https://minecraft.fandom.com/wiki/Terrain-atlas.tga

BMP is a better format! Why not write BMP files?
++++++++++++++++++++++++++++++++++++++++++++++++

This is wrong. BMP is more complex and produces larger files. Go read
the `Wikipedia article on BMP`_ to learn how BMP is worse than almost
all other bitmap file formats for (almost) all conceivable use cases.

.. _`Wikipedia article on BMP`:
   https://en.wikipedia.org/wiki/BMP_file_format

PNG is a better format! Why not write PNG files?
++++++++++++++++++++++++++++++++++++++++++++++++

Simplicity
^^^^^^^^^^

Go write a parser for PNG, I'll wait here. Tell me, was it hard?

Speed
^^^^^

Writing TGA files is fast and scales linearly with the number of
pixels. This holds even when using RLE compression or colormaps.

Writing PNG files involves compression and checksums, which need
additional computation. This obviously slows down file encoding.

You can witness this effect when optimizing PNG filesizes with a
program that improves the compression, e.g. pngcrush or optipng,
or maybe even zopflipng if you have too much time on your hands.
Runtime for these programs is often measured in tens of seconds,
even for small files (as they try to find the best compression).

In practice, these effects rarely matter, even for large images:
Encoding may be CPU-bound, but is usually faster than writing to
storage media. If you want to send textures over a network, that
might be a situation where you want any textures to be generated
as fast as possible.

Size
^^^^

Small Images (up to 64×64)
..........................

TGA has less overhead than PNG, i.e. even with better compression, TGA
can be a more useful format for images with smaller size (e.g. 16×16).

.. code::

   local pixels = {}
   for h = 1,16 do
      pixels[h] = {}
      for w = 1,16 do
         pixels[h][w] = { 255, 0, 255, 127 }
      end
   end
   tga_encoder.image(pixels):save("small.tga", {compression="RLE"})

The above code writes a 16×16 TGA file full of 50% opacity purple.

- The TGA file created by `tga_encoder` has a filesize of 54 bytes.
- Converting `small.tga` to PNG using GIMP yields a 100 byte file.
- Using optipng or pngcrush this file is compressed to 96 bytes.
- Using zopflipng does not work; the image becomes grayscale.

In both the TGA file and the PNG file the majority of the file is
taken up by header & footer information, TGA has just less of it.

If you want to reduce filesize, note that on many filesystems even
small files often take up a full filesystem block (e.g. 4K). Getting
rid of a few bytes here and there is not going to change that; but if
lots of images are located in an archive or supposed to be transmitted
over a network, saving a dozen bytes in all of them could make sense.

Medium Images (up to 512×512)
.............................

If you care about how many bytes are written to disk or sent over the
network, it is likely that you will get “good enough” results using a
DEFLATE-compressed TGA file instead of a PNG file if an image has few
colors and regular features, like images that `unicode_text` renders.

To verify, generate a TGA image with a black and orange checkerboard:

.. code::

  local black = { 0x00, 0x00, 0x00 }
  local orange = { 0xFF, 0x88, 0x00 }

  local pixels = {}
  for h = 1,512 do
     pixels[h] = {}
     for w = 1,512 do
        local hori = (math.floor( ( w - 1 ) / 32) % 2)
        local vert = (math.floor( ( h - 1 ) / 32) % 2)
        pixels[h][w] = hori ~= vert and orange or black
     end
  end
  tga_encoder.image(pixels):save(
     "medium.tga",
     {
        color_format="A1R5G5B5",
        compression = "RLE",
     }
  )

- The generated checkerboard TGA file has a filesize of about 24K.
- Converting `medium.tga` to PNG using GIMP yields a filesize of 1.7K.
- optipng can reduce PNG filesize to 236 bytes.
- zopflipng seems to hang while optimizing PNG filesize.
- Compressing `medium.tga` using `gzip -9` yields a 143 byte file.
- Compressing `medium.tga` using `zopfli --deflate` yields a 117 bytes file.

While the DEFLATE-compressed TGA beats an optimized PNG on filesize in
this case, this is not necessarily true in all cases – the compression
can make a file larger if the contents are largely incompressible. For
this reason, automatically applying DEFLATE must always be followed by
a check if it actually yielded a smaller filesize. Here is an example:

.. code::

   math.randomseed(os.time())

   local pixels = {}
   for h = 1,128 do
      pixels[h] = {}
      for w = 1,128 do
         pixels[h][w] = {
            math.random() * 256 % 256,
            math.random() * 256 % 256,
            math.random() * 256 % 256,
         }
      end
   end
   tga_encoder.image(pixels):save("random.tga")

The resulting TGA file `random.tga` has exactly 49196 bytes. Since the
contents are random enough to be incompressible, both converting it to
PNG and compressing the file using DEFLATE makes the file even larger.

Note that there is no uncompressed variant of PNG. DEFLATE, however is
capable of storing uncompressed blocks. In that case PNG still has the
overhead that chunks and checksums imply. Anyways …

Large Images
............

A good PNG encoder (i.e. one that uses prefilters) is likely to beat a
TGA encoder on filesize for larger image dimensions, but not on speed.

Note that `minetest.encode_png()` is not a good PNG encoder, as it can
not apply prefilters and always writes 32bpp non-colormap RBGA images.
Compare the Minetest devtest checkerboard to the checkerboard that was
generated in the previous section to know how bad of an encoder it is.

In the following example, rendering `UTF-8-demo.txt`_ with GNU Unifont
writes an uncompressed 8bpp grayscale TGA file with 632 × 3408 pixels:

.. _`UTF-8-demo.txt`:
   https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt

.. code::

   font = unicode_text.hexfont()
   font:load_glyphs( io.lines("unifont.hex") )
   font:load_glyphs( io.lines("unifont_upper.hex") )

   local file = io.open("UTF-8-demo.txt")
   local pixels = font:render_text( file:read("*all") )
   file:close()

   tga_encoder.image(pixels):save("UTF-8-demo.tga")

PNG does not necessarily have an advantage if speed is important:

- Uncompressed TGA filesize is about 2MB, i.e. 632 × 3408 + 44 bytes.
- Converting `UTF-8-demo.tga` to PNG using GIMP yields a 52K file.
- Compressing the TGA using `gzip -9` yields a 51K file.

If filesize is important, PNG is better – but it takes some time:

- zopfli can compress `UTF-8-demo.tga` to 43K in about 32 seconds.
- optipng can reduce PNG filesize to 32K, taking about 25 seconds.
- zopflipng reduces PNG filesize further to 28K, taking 3 seconds.

The above times were measured on a Thinkpad P14s.

Anything else?
++++++++++++++

Yes, Minetest should support deflated TGA as a texture format and send
uncompressed TGA to older clients to provide compatibility at the cost
of more network traffic. Minetest should also compress files which are
sent as dynamic media, but only if doing it reduces the transfer size.

Also, any developer who proposes to use ZSTD instead of DEFLATE should
be forced to benchmark any such proposal with an antique Netbook until
they figure out why ZSTD compresses so slowly and why it is worse than
DEFLATE for relatively small payloads that are dynamically generated …

Why do you ask?

License
-------

unicode_text, a Unicode text renderer mod for Minetest
Copyright (C) 2024  Wuzzy and erlehmann

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
