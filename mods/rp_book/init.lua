rp_book = {}

local bookform = rp_formspec.default.version ..
	"size[10.25,10.25]" ..
	rp_formspec.default.boilerplate ..
	"background[0,0;10.25,10.25;ui_formspec_bg_book.png]"
rp_formspec.register_page("rp_book:book_page", bookform)

function rp_book.make_read_book_page_formspec(title, text)
    local form = ""
    form = form .. "style_type[label;font_size=*2]"
    form = form .. "label[0.7,0.7;"..minetest.formspec_escape(title).."]"
    form = form .. "textarea[0.7,1.2;8.85,7.7;;;"..minetest.formspec_escape(text).."]"
    return form
end

dofile(minetest.get_modpath("rp_book") .. "/book.lua")
dofile(minetest.get_modpath("rp_book") .. "/bookshelf.lua")
