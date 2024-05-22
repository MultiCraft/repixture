#!/usr/bin/env lua5.1
-- -*- coding: utf-8 -*-

dofile("init.lua")
dofile("../tga_encoder/init.lua")

font = unicode_text.hexfont(
   {
      kerning = true,
   }
)
font:load_glyphs(
   io.lines("unifont.hex")
)
font:load_glyphs(
   io.lines("unifont_upper.hex")
)

local text = "\
  子曰：「學而時習之，不亦說乎？  \
  ሰማይ አይታረስ ንጉሥ አይከሰስ።  \
  გთხოვთ ახლავე გაიაროთ რეგისტრაცია  \
  Heizölrückstoßabdämpfung  \
  נקודה מודגשת  \
  Ξεσκεπάζω τὴν ψυχοφθόρα βδελυγμία \
  다람쥐 헌 쳇바퀴에 타고파  \
  ബ്qരഹ്മപുരത്തേക്ക്  \
  В чащах юга жил бы цитрус?  \
  𝐛𝐨𝐥𝐝 𝖋𝖗𝖆𝖐𝖙𝖚𝖗 𝒊𝒕𝒂𝒍𝒊𝒄 𝓼𝓬𝓻𝓲𝓹𝓽  \
  "
local pixels = font:render_text(text)
local image = tga_encoder.image(pixels)
image:save("screenshot.tga")
