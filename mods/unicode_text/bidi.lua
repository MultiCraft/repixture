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
dofile(modpath .. "/unicodedata.lua")

bidi = {}

-- Returns true if given codepoint is RTL
bidi.is_rtl_codepoint = function(codepoint)
   if not unicodedata[codepoint] then
      return false
   end
   local bidi_class = unicodedata[codepoint].bidi_class
   if (
      "R" == bidi_class or  -- right-to-left
      "AL" == bidi_class  -- right-to-left (arabic)
   ) then
      return true
   end
   return false
end

local get_paragraph_direction = function(codepoints)
   -- Find the first character of type L, AL or R …
   -- See <https://www.unicode.org/reports/tr9/#P2>
   for _, codepoint in ipairs(codepoints) do
      if unicodedata[codepoint] then
         local bidi_class = unicodedata[codepoint].bidi_class
         if (
            "L" == bidi_class or  -- left-to-right
            "R" == bidi_class or  -- right-to-left
            "AL" == bidi_class  -- right-to-left (arabic)
         ) then
            return bidi_class
         end
      end
   end
end

-- See <https://www.unicode.org/reports/tr9/>
bidi.get_visual_reordering = function(codepoints)
   -- rule P2
   local paragraph_direction =
      get_paragraph_direction(codepoints) or "L"

   -- rule P3
   local paragraph_embedding_level = 0
   if (
      "R" == paragraph_direction or
      "AL" == paragraph_direction
   ) then
      paragraph_embedding_level = 1
   end

   -- FIXME: Rule X1 to X10 are not implemented yet. This basically
   -- means that explicit levels or display directions are ignored.

   local run = {}
   for i, codepoint in ipairs(codepoints) do
      run[i] = {}
      run[i].codepoint = codepoint
      run[i].bidi_class =
         unicodedata[codepoint] and
         unicodedata[codepoint].bidi_class or paragraph_direction
      run[i].embedding_level = 0
   end

   -- Hack: This code is almost certainly non-conforming …
   -- but it seems to “kinda” work. Someone should fix it!
   run = bidi.resolve_weak_types(run, paragraph_direction)
   run = bidi.resolve_ni_types(run, paragraph_direction)
   run = bidi.resolve_implicit_types(run, paragraph_embedding_level)
   run = bidi.reorder_resolved_levels(run, paragraph_embedding_level)

   local codepoints_reordered = {}
   for i, element in ipairs(run) do
      codepoints_reordered[i] = element.codepoint
   end
   return codepoints_reordered
end

bidi.W1 = function(run, sos)
   -- Examine each nonspacing mark (NSM) in the isolating run
   -- sequence, and change the type of the NSM to Other Neutral
   -- if the previous character is an isolate initiator or PDI,
   -- and to the type of the previous character otherwise. If
   -- the NSM is at the start of the isolating run sequence, it
   -- will get the type of sos.
   for i = 1, #run do
      if "NSM" == run[i].bidi_class then
         if 1 == i then
            run[i].bidi_class = sos
         else
            -- FIXME: handle isolate initiator, PDI
            run[i].bidi_class = run[i-1].bidi_class
         end
      end
   end
   return run
end

local W2 = function(run, sos)
   -- sos is the text ordering type assigned to the virtual position
   -- before an isolating run sequence
   assert(
      "AL" == sos or  -- FIXME: find the actual bug & remove this line
      "L" == sos or
      "R" == sos
   )
   for i = 1, #run do
      if "EN" == run[i].bidi_class then
         -- Search backward from each instance of a European number
         -- until the first strong type (R, L, AL, or sos) is found.
         local previous_strong_bidi_class = nil
         local j = i
         repeat
            j = j - 1
            local previous_bidi_class = (run[j] and run[j].bidi_class) or nil
            if (
               "L" == previous_bidi_class or  -- left-to-right
               "R" == previous_bidi_class or  -- right-to-left
               "AL" == previous_bidi_class or -- right-to-left (arabic)
               sos == previous_bidi_class
            ) then
               previous_strong_bidi_class = previous_bidi_class
            end
         until(
            nil ~= previous_strong_bidi_class or
            j <= 1
         )
         -- If an AL is found, change the type of the European number
         -- to Arabic number.
         if "AL" == previous_strong_bidi_class then
            run[i].bidi_class = "AN"
         end
      end
   end
   return run
end

dump_table = function(table_, indentation)
   assert( "table" == type(table_) )

   local indentation = indentation or 0
   assert( "number" == type(indentation) )

   local result = {}
   for key, value in pairs(table_) do
      local prefix = "\n" .. ("   "):rep(indentation) .. key .. ": "
      if "table" == type(value) then
         result[#result + 1] = prefix .. dump_table(value, indentation + 1)
      else
         result[#result + 1] = prefix .. tostring(value)
      end
   end
   return table.concat(result)
end

local test_rule = function(
      description,
      rule,
      test_input,
      expected_output,
      ...
)
   assert( "string" == type(description) )
   assert( "function" == type(rule) )
   assert( "table" == type(test_input) )
   assert( "table" == type(expected_output) )
   local test_output = rule(test_input, ...)
   for i = 1, #test_input do
      assert(
         test_output[i].bidi_class == expected_output[i].bidi_class,
         description ..
         dump_table(test_output)
      )
   end
end

test_rule(
   "Test W2: AL EN → AL AN",
   W2,
   {
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "AN" },
   },
   "L"
)

test_rule(
   "Test W2: AL NI EN → AL NI AN",
   W2,
   {
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "AN" },
   },
   "L"
)

test_rule(
   "Test W2: sos NI EN → sos NI EN (sos = L)",
   W2,
   {
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   "L"
)

test_rule(
   "Test W2: sos NI EN → sos NI EN (sos = R)",
   W2,
   {
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   "R"
)

test_rule(
   "Test W2: L NI EN → L NI EN",
   W2,
   {
      { ["bidi_class"] = "L" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "L" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   "L"
)

test_rule(
   "Test W2: R NI EN → R NI EN",
   W2,
   {
      { ["bidi_class"] = "R" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "R" },
      { ["bidi_class"] = "NI" },
      { ["bidi_class"] = "EN" },
   },
   "L"
)

local W3 = function(run)
   -- Change al ALs to R.
   for i = 1, #run do
      if "AL" == run[i].bidi_class then
         run[i].bidi_class = "R"
      end
   end
   return run
end

test_rule(
   "Test W3: AL AL AL → R R R",
   W3,
   {
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "AL" },
      { ["bidi_class"] = "AL" },
   },
   {
      { ["bidi_class"] = "R" },
      { ["bidi_class"] = "R" },
      { ["bidi_class"] = "R" },
   }
)

local W4 = function(run)
   for i = 1, #run do
      if "ES" == run[i].bidi_class then
         -- A single European separator between two European numbers
         -- changes to a European number.
         if (
            1 < i and
            #run > i and
            "EN" == run[i-1].bidi_class and
            "EN" == run[i+1].bidi_class
         ) then
            run[i].bidi_class = "EN"
         end
      end
      if "CS" == run[i].bidi_class then
         -- A single common separator between two numbers of the same
         -- type changes to that type.
         if (
            1 < i and
            #run > i and
            "EN" == run[i-1].bidi_class and
            "EN" == run[i+1].bidi_class
         ) then
            run[i].bidi_class = "EN"
         end
         if (
            1 < i and
            #run > i and
            "AN" == run[i-1].bidi_class and
            "AN" == run[i+1].bidi_class
         ) then
            run[i].bidi_class = "AN"
         end
      end
   end
   return run
end

test_rule(
   "Test·W4:·EN·ES·EN·→·EN·EN·EN",
   W4,
   {
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "ES" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "EN" },
   }
)

test_rule(
   "Test·W4:·EN·CS·EN·→·EN·EN·EN",
   W4,
   {
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "CS" },
      { ["bidi_class"] = "EN" },
   },
   {
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "EN" },
      { ["bidi_class"] = "EN" },
   }
)

test_rule(
   "Test·W4:·AN·CS·AN·→·AN·AN·AN",
   W4,
   {
      { ["bidi_class"] = "AN" },
      { ["bidi_class"] = "CS" },
      { ["bidi_class"] = "AN" },
   },
   {
      { ["bidi_class"] = "AN" },
      { ["bidi_class"] = "AN" },
      { ["bidi_class"] = "AN" },
   }
)

bidi.W5 = function(run)
   for i = 1, #run do
      if "ET" == run[i].bidi_class then
         -- A sequence of European terminators adjacent to European
         -- numbers changes to all European numbers.
         if (
            1 < i and
            "EN" == run[i-1].bidi_class
         ) or (
            #run > i and
            "EN" == run[i+1].bidi_class
         ) then
            run[i].bidi_class = "EN"
         end
      end
   end
   return run
end

bidi.W6 = function(run)
   for i = 1, #run do
      if (
         "ES" == run[i].bidi_class or
         "ET" == run[i].bidi_class or
         "CS" == run[i].bidi_class
      ) then
         -- Otherwise, separators and terminators change to Other
         -- Neutral.
         run[i].bidi_class = "ON"
      end
   end
   return run
end

bidi.W7 = function(run, sos)
   for i = 1, #run do
      if "EN" == run[i].bidi_class then
         -- Search backward from each instance of a European number
         -- until the first strong type (R, L, or sos) is found. If an
         -- L is found, then change the type of the European number to
         -- L.
         local previous_strong_bidi_class = nil
         local j = i
         repeat
            local previous_bidi_class = run[j].bidi_class
            if (
               "L" == previous_bidi_class or  -- left-to-right
               "R" == previous_bidi_class or  -- right-to-left
               sos == previous_bidi_class
            ) then
               previous_strong_bidi_class = previous_bidi_class
            end
            j = j - 1
         until(
            nil ~= previous_strong_bidi_class or
            0 == j
         )
         if "L" == previous_strong_bidi_class then
            run[i].bidi_class = "L"
         end
      end
   end
   return run
end

bidi.resolve_weak_types = function(run, sos)
   run = bidi.W1(run, sos)
   run = W2(run, sos)
   run = W3(run)
   run = W4(run)
   run = bidi.W5(run)
   run = bidi.W6(run)
   run = bidi.W7(run, sos)
   return run
end

bidi.resolve_ni_types = function(run, embedding_direction)
   for i, element in ipairs(run) do
      -- N0
      -- FIXME: Process bracket pairs!
      -- N1
      if (
         "B" == run[i].bidi_class or
         "S" == run[i].bidi_class or
         "WS" == run[i].bidi_class or
         "ON" == run[i].bidi_class or
         "FSI" == run[i].bidi_class or
         "LRI" == run[i].bidi_class or
         "RLI" == run[i].bidi_class or
         "PDI" == run[i].bidi_class
      ) then
         -- A sequence of NIs takes the direction of the surrounding
         -- strong text if the text on both sides has the same
         -- direction.
         local previous_direction = nil
         local j = i
         repeat
            local previous_bidi_class = run[j].bidi_class
            if (
               "L" == previous_bidi_class or  -- left-to-right
               "R" == previous_bidi_class     -- right-to-left
            ) then
               previous_direction = previous_bidi_class
            end
            j = j - 1
         until(
            nil ~= previous_direction or
            0 == j
         )
         local next_direction = nil
         local j = i
         repeat
            local next_bidi_class = run[j].bidi_class
            if (
               "L" == next_bidi_class or  -- left-to-right
               "R" == next_bidi_class     -- right-to-left
            ) then
               next_direction = next_bidi_class
            end
            j = j + 1
         until(
            nil ~= next_direction or
            #run + 1 == j
         )
         if (
            1 < i and
            #run > i and
            "L" == previous_direction and
            "L" == next_direction
         ) then
            run[i].bidi_class = "L"
         elseif (
            -- European and Arabic numbers act as if they were R in
            -- terms of their influence on NIs.
            1 < i and
            #run > i and
            (
               "R" == previous_direction or
               "EN" == previous_direction or
               "AN" == previous_direction
            ) and (
               "R" == next_direction or
               "EN" == next_direction or
               "AN" == next_direction
            )
         ) then
            run[i].bidi_class = "R"
         -- N2
         else
            -- Any remaining NIs take the embedding direction.
            run[i].bidi_class = embedding_direction
         end
      end
   end
   return run
end

bidi.resolve_implicit_types = function(run, embedding_level)
   for i, element in ipairs(run) do
      -- I1
      if 0 == embedding_level % 2 then
         -- For all characters with an even (left-to-right)
         -- embedding level, those of type R go up one level and those
         -- of type AN or EN go up two levels.
         if "R" == run[i].bidi_class then
            run[i].embedding_level = run[i].embedding_level + 1
         elseif (
            "AN" == run[i].bidi_class or
            "EN" == run[i].bidi_class
         ) then
            run[i].embedding_level = run[i].embedding_level + 2
         end
      -- I2
      else
         -- For all characters with an odd (right-to-left) embedding
         -- level, those of type L, EN or AN go up one level.
         if (
            "L" == run[i].bidi_class or
            "EN" == run[i].bidi_class or
            "AN" == run[i].bidi_class
         ) then
            run[i].embedding_level = run[i].embedding_level + 1
         end
      end
   end
   return run
end

-- reverse any sequences at minimum_embedding_level or higher
bidi.reverse_sequences = function(run, minimum_embedding_level)
   local sequence_start
   local sequence_end
   for i = 1, #run do
      if (
         minimum_embedding_level <= run[i].embedding_level and
         nil == sequence_start
      ) then
         -- found the start of a sequence
         sequence_start = i
      elseif (
         minimum_embedding_level > run[i].embedding_level and
         nil ~= sequence_start
      ) then
         -- found the end of a sequence
         sequence_end = i
      end
      if (
         nil ~= sequence_start and
         nil ~= sequence_end
      ) then
         -- extract sequence
         local sequence = {}
         for j = 1, sequence_end - sequence_start do
            sequence[#sequence+1] = run[sequence_start + j - 1]
         end
         -- insert sequence reversed
         for k = 1, #sequence do
            run[sequence_start + k - 1] = sequence[#sequence - k + 1]
         end
         sequence_start = nil
         sequence_end = nil
         sequence = {}
      end
   end
   return run
end

bidi.reorder_resolved_levels = function(run, paragraph_embedding_level)
   -- L1
   -- FIXME: Reset some embedding levels to paragraph embedding level!
   -- L2
   -- From the highest level found in the text to the lowest odd level
   -- on each line, including intermediate levels not actually present
   -- in the text, reverse any contiguous sequence of characters that
   -- are at that level or higher.
   local max_embedding_level = 0
   for _, element in ipairs(run) do
      if max_embedding_level < element.embedding_level then
         max_embedding_level = element.embedding_level
      end
   end
   assert(
      "number" == type(max_embedding_level)
   )
   for minimum_embedding_level = max_embedding_level, 1, -1 do
      run = bidi.reverse_sequences(run, minimum_embedding_level)
   end
   -- L3
   -- FIXME: Fix combining marks applied to right-to-left characters.
   -- L4
   -- FIXME: Replace characters by mirrored glyphs.
   return run
end

--[[
dofile("utf8.lua")

local text = "Reuben Rivlin (ראובן ריבלין; * 1939 in Jerusalem)"
local text_reordered = utf8.codepoints_to_text(
   bidi.get_visual_reordering(
      utf8.text_to_codepoints(
         text
      )
   )
)

print(text)
print(text_reordered)
--]]
