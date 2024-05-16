local lu = {}

-- Bidi_Class values
local bidi_class_strings = {
	["L"] = 0,
	["LRE"] = 1,
	["LRO"] = 2,
	["R"] = 3,
	["AL"] = 4,
	["RLE"] = 5,
	["RLO"] = 6,
	["PDF"] = 7,
	["EN"] = 8,
	["ES"] = 9,
	["ET"] = 10,
	["AN"] = 11,
	["CS"] = 12,
	["NSM"] = 13,
	["BN"] = 14,
	["B"] = 15,
	["S"] = 16,
	["WS"] = 17,
	["ON"] = 18,
	["LRI"] = 19,
	["RLI"] = 20,
	["FSI"] = 21,
	["PDI"] = 22,
}

for name, number in pairs(bidi_class_strings) do
	lu["UCDN_BIDI_CLASS_"..name] = number
end

-- Bidi_Paired_Bracket_Type values
lu.UCDN_BIDI_PAIRED_BRACKET_TYPE_OPEN = 0
lu.UCDN_BIDI_PAIRED_BRACKET_TYPE_CLOSE = 1
lu.UCDN_BIDI_PAIRED_BRACKET_TYPE_NONE = 2

lu.get_bidi_class = function(cp)
	local bidi_class = unicodedata[cp] and unicodedata[cp].bidi_class
	if bidi_class then
		return bidi_class_strings[bidi_class]
	else
		return bidi_class_strings["L"]
	end
end

local compare_bp = function(a, b)
	return a.from - b.from
end

local bsearch = function(key, base, nmemb, size, compar)
end

local search_bp = function(cp)
	local bp = {0,0,2}
	local res

	bp.from = cp
	res = bsearch(bp, bracket_pairs, BIDI_BRACKET_LEN, 3, compare_bp)
	return res
end

lu.paired_bracket = function(cp)
	return cp
end

lu.paired_bracket_type = function(cp)
	return lu.UCDN_BIDI_PAIRED_BRACKET_TYPE_NONE
end

return lu
