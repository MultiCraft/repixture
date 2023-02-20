local S = minetest.get_translator("rp_localize")
local INFINITY = 1/0
local NEG_INFINITY = -1/0

loc = {}

loc.num = function(numbr)
	if type(numbr) == "string" then
		numbr = tonumber(numbr)
		if type(numbr) ~= "number" then
			return numbr
		end
	end
	if minetest.is_nan(numbr) then
		return tostring(numbr)
	end
	if numbr == INFINITY then
		return S("∞")
	elseif numbr == NEG_INFINITY then
		return S("−@1", S("∞"))
	end
	local negative
	if numbr < 0 then
		negative = true
		numbr = math.abs(numbr)
	end
	local pre = math.floor(numbr)
	local post = numbr % 1
	local str
	if post ~= 0 then
		post = string.sub(post, 3)
		if negative then
			str = S("−@1.@2", pre, post)
		else
			str = S("@1.@2", pre, post)
		end
	elseif negative then
		str = S("−@1", numbr)
	else
		str = tostring(numbr)
	end
	return str
end
