local S = minetest.get_translator("rp_tt")
tt.register_snippet(function(itemstring)
	local magnetic = minetest.get_item_group(itemstring, "magnetic") > 0
	local unmagnetic = minetest.get_item_group(itemstring, "unmagnetic") > 0
	local str = nil
	if magnetic then
		str = S("Magnetic")
	elseif unmagnetic then
		str = S("Unmagnetic")
	end
	return str
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def and def._rp_on_ignite and not def._rp_tt_has_ignitible_text then
		return S("Ignitible")
	end
	return
end)

tt.register_snippet(function(itemstring)
	local can_scrape = minetest.get_item_group(itemstring, "can_scrape")
	if can_scrape == 2 then
		return S("Place: Scrape off paint")
	elseif can_scrape == 3 then
		return S("Punch: Scrape off paint")
	elseif can_scrape == 1 then
		return S("Can scrape off paint")
	else
		return ""
	end
end)


