unused_args = false
allow_defined_top = true
max_line_length = false

globals = {
	"minetest",
}

read_globals = {
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn", "shuffle"}},
	math = {fields = {"round", "sign"}},

	-- Builtin
	"vector", "ItemStack", "PcgRandom", "PseudoRandom",
	"dump", "DIR_DELIM", "VoxelArea", "Settings",
}

