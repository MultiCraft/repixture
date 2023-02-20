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
