local bookform = "size[8.5,9]" ..
	rp_formspec.default.bg ..
	"background[0,0;8.5,9;ui_formspec_bg_book.png]"
rp_formspec.register_page("rp_book:book_page", bookform)


dofile(minetest.get_modpath("rp_book") .. "/book.lua")
dofile(minetest.get_modpath("rp_book") .. "/bookshelf.lua")
