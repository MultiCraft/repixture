village.name = {}

village.name.prefixes = {"long", "dan", "fan", "tri", "man"}
village.name.middles = {"er", "in", "ao", "ie", "ir", "et", "em", "me", "el"}
village.name.postfixes = {"ton", "eth", "ing", "arn", "agt", "seg"}
village.name.disambiguators = {"nova", "vino", "gemo", "bira", "leno", "gata"}

-- Map of used village names.
-- 	key = village name
-- 	value = true if village name is used
village.name.used = {}

-- Generates and returns a random village name.
-- * pr: PseudoRandom object
-- * used_names: Optional. If a table, is a name-index list of used names
--
-- Returns a village name. Sets used_names[<village name>] to true
function village.name.generate(pr, used_names)
   local prefix = ""
   local middle = ""
   local postfix = ""

   local middles = pr:next(2, 5)

   if pr:next(1, 4) <= 1 then
      prefix = village.name.prefixes[pr:next(1, #village.name.prefixes)]
      middles = middles - 1
   end

   if pr:next(1, 2) <= 1 then
      postfix = village.name.postfixes[pr:next(1, #village.name.postfixes)]
      middles = middles - 2
   end

   if middles < 2 then
      middles = 2
   end

   for i = 1, middles do
      middle = middle..village.name.middles[pr:next(1, #village.name.middles)]
   end

   local name = prefix..middle..postfix

   name = name:gsub("^%l", string.upper)

   if used_names then
      -- If name is already taken, append random disambiguators
      -- (extra suffixes) until the name is unique
      -- Name will be of the form "<Old name>-<Disambiguator>",
      -- e.g. "Iner" will become "Iner-Nova".
      while village.name.used[name] do
         local rnd = pr:next(1, #village.name.disambiguators)
         local disambiguator = village.name.disambiguators[rnd]
         disambiguator = disambiguator:gsub("^%l", string.upper)
         local append = "-" .. disambiguator
         name = name .. append
      end

      used_names[name] = true
   end

   return name
end

