local S = minetest.get_translator("rp_gold")

--[[
Table of trades offered by villagers.

Format:

	gold.trades = {
		-- List of trades for this villager profession
		["profession_1"] = {
			-- first trade table (see below)
			trade_1,
			-- second trade table (see below)
			trade_2,
			-- ...
		},
		["profession_2"] = {
			-- ...
		},
		-- ...
	},

A trade table is a list of 3 itemstrings:

	{ wanted_item_1, wanted_item_2, given_item }

The first 2 items are the items you give to the villager.
`wanted_item_2` can be the empty string.
`given_item` is the item you get.
If `wanted_item_2` and `given_item` are equal and tools
(via `minetest.registered_tool`), this trade is considered
to be a repair trade
]]
gold.trades = {}

-- List of possible trader names
gold.trade_names = {}

if minetest.get_modpath("rp_mobs_mobs") == nil then
	return
end

gold.trades["farmer"] = {
	-- seeds/plants
	{"rp_gold:ingot_gold", "", "rp_farming:wheat_1 6"},
	{"rp_gold:ingot_gold", "", "rp_farming:potato_1 7"},
	{"rp_gold:ingot_gold", "", "rp_farming:cotton_1 2"},
	{"rp_gold:ingot_gold", "", "rp_default:papyrus 4"},
	{"rp_gold:ingot_gold 2", "", "rp_farming:carrot_1"},
	{"rp_gold:ingot_gold 2", "", "rp_farming:asparagus_1"},
	{"rp_gold:ingot_gold 3", "", "rp_default:cactus"},

	-- crafts
	{"rp_gold:ingot_gold 2", "", "rp_farming:cotton_bale 1"},

	-- tool repair
	{"rp_gold:ingot_gold 1", "rp_default:shovel_stone", "rp_default:shovel_stone"},
	{"rp_gold:ingot_gold 8", "rp_default:shovel_steel", "rp_default:shovel_steel"},
	{"rp_gold:ingot_gold 10", "rp_default:shovel_carbon_steel", "rp_default:shovel_carbon_steel"},

	-- filling buckets
	{"rp_gold:ingot_gold", "rp_default:bucket", "rp_default:bucket_water"},
}
gold.trades["carpenter"] = {
	-- materials
	{"rp_gold:ingot_gold", "", "rp_default:planks 6"},
	{"rp_gold:ingot_gold", "", "rp_default:planks_birch 5"},
	{"rp_gold:ingot_gold", "", "rp_default:planks_oak 3"},
	{"rp_gold:ingot_gold", "", "rp_default:frame 2"},
	{"rp_gold:ingot_gold", "", "rp_default:reinforced_frame"},

	-- useables
	{"rp_gold:ingot_gold 5", "", "rp_bed:bed"},
	{"rp_gold:ingot_gold 2", "", "rp_default:chest"},
	{"rp_gold:ingot_gold 10", "", "rp_locks:chest"},
	{"rp_gold:ingot_gold", "rp_mobs_mobs:wool 3", "rp_bed:bed"},
}
gold.trades["tavernkeeper"] = {
	-- edibles
	{"rp_gold:ingot_gold", "", "rp_default:apple 6"},
	{"rp_gold:ingot_gold", "", "rp_farming:bread 2"},
	{"rp_gold:ingot_gold", "", "rp_mobs_mobs:meat"},
	{"rp_gold:ingot_gold 2", "", "rp_mobs_mobs:pork"},

	-- filling buckets
	{"rp_gold:ingot_gold", "rp_default:bucket", "rp_default:bucket_water"},
}
gold.trades["blacksmith"] = {
	-- smeltables
	{"rp_gold:ingot_gold", "", "rp_default:lump_coal"},
	{"rp_gold:ingot_gold 3", "", "rp_default:lump_iron"},

	-- materials
	{"rp_gold:ingot_gold", "", "rp_default:cobble 20"},
	{"rp_gold:ingot_gold", "", "rp_default:stone 18"},
	{"rp_gold:ingot_gold", "", "rp_default:reinforced_cobble 2"},
	-- much cheaper than 9 steel ingots, buying in bulk slashes the price
	{"rp_gold:ingot_gold 25", "", "rp_default:block_steel"},
	{"rp_gold:ingot_gold 6", "", "rp_default:glass 5"},

	-- usebles
	{"rp_gold:ingot_gold", "", "rp_default:furnace"},

	-- ingots
	{"rp_gold:ingot_gold 5", "", "rp_default:ingot_steel"},
	{"rp_gold:ingot_gold 8", "", "rp_default:ingot_carbon_steel"},

	-- special trades
	-- iron to steel
	{"rp_gold:ingot_gold 2", "rp_default:lump_iron 2", "rp_default:ingot_steel"},
	-- bronze lump: unique item, can't be crafted. Cheaper than crafting bronze ingots
	{"rp_default:lump_tin 1", "rp_default:lump_copper 4", "rp_default:lump_bronze"},
	-- chainmail sheet to steel
	{"rp_gold:ingot_gold", "rp_armor:chainmail_sheet", "rp_default:ingot_steel"},

	-- tool repair
	{"rp_gold:ingot_gold 1", "rp_default:pick_stone", "rp_default:pick_stone"},
	{"rp_gold:ingot_gold 12", "rp_default:pick_steel", "rp_default:pick_steel"},
	{"rp_gold:ingot_gold 16", "rp_default:pick_carbon_steel", "rp_default:pick_carbon_steel"},
}
gold.trades["butcher"] = {
	-- raw edibles
	{"rp_gold:ingot_gold", "", "rp_mobs_mobs:meat_raw"},
	{"rp_gold:ingot_gold 3", "", "rp_mobs_mobs:pork_raw 2"},

	-- cooking edibles
	{"rp_gold:ingot_gold 1", "rp_mobs_mobs:meat_raw", "rp_mobs_mobs:meat"},
	{"rp_gold:ingot_gold 2", "rp_mobs_mobs:pork_raw", "rp_mobs_mobs:pork"},

	-- tool repair
	{"rp_gold:ingot_gold 1", "rp_default:spear_stone", "rp_default:spear_stone"},
	{"rp_gold:ingot_gold 7", "rp_default:spear_steel", "rp_default:spear_steel"},
	{"rp_gold:ingot_gold 11", "rp_default:spear_carbon_steel", "rp_default:spear_carbon_steel"},

}
-- trading currency
if minetest.get_modpath("rp_jewels") ~= nil then -- jewels/gold
	--farmer
	table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 16", "", "rp_jewels:jewel"})
	table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 22", "", "rp_jewels:jewel 2"})
	table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 34", "", "rp_jewels:jewel 4"})

	table.insert(gold.trades["farmer"], {"rp_jewels:jewel", "", "rp_gold:ingot_gold 7"})
	table.insert(gold.trades["farmer"], {"rp_jewels:jewel 2", "", "rp_gold:ingot_gold 15"})
	table.insert(gold.trades["farmer"], {"rp_jewels:jewel 4", "", "rp_gold:ingot_gold 31"})

	-- tavern keeper
	table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 14", "", "rp_jewels:jewel"})
	table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 20", "", "rp_jewels:jewel 2"})
	table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 32", "", "rp_jewels:jewel 4"})

	-- blacksmith
	table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 14", "", "rp_jewels:jewel"})
	table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 20", "", "rp_jewels:jewel 2"})
	table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 32", "", "rp_jewels:jewel 4"})
end

-- farmer
table.insert(gold.trades["farmer"], {"rp_farming:wheat 15", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_default:apple 12", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_default:flower 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_default:fern 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_farming:carrot_1 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_farming:asparagus_1 12", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_farming:potato_1 14", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_default:lump_sulfur 6", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["farmer"], {"rp_default:thistle 13", "", "rp_gold:ingot_gold"})

-- blacksmith
table.insert(gold.trades["blacksmith"], {"rp_default:tree 6", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["blacksmith"], {"rp_default:lump_coal 15", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["blacksmith"], {"rp_default:lump_iron 12", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["blacksmith"], {"rp_default:lump_tin 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["blacksmith"], {"rp_gold:lump_gold 2", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["blacksmith"], {"rp_armor:chainmail_sheet 2", "", "rp_gold:ingot_gold"})

-- carpenter
table.insert(gold.trades["carpenter"], {"rp_default:tree 5", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_default:tree_birch 5", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_default:tree_oak 4", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_default:fiber 50", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_mobs_mobs:wool 8", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_farming:cotton_bale 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["carpenter"], {"rp_default:glass 10", "", "rp_gold:ingot_gold"})

-- butcher
table.insert(gold.trades["butcher"], {"rp_mobs_mobs:meat_raw 4", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["butcher"], {"rp_mobs_mobs:pork_raw 3", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["butcher"], {"rp_default:flint 12", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["butcher"], {"rp_default:paper 30", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["butcher"], {"rp_default:sandstone 28", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["butcher"], {"rp_default:ingot_wrought_iron 11", "", "rp_gold:ingot_gold"})

-- tavernkeeper
table.insert(gold.trades["tavernkeeper"], {"rp_default:pearl 2", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["tavernkeeper"], {"rp_default:sheet_graphite 10", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["tavernkeeper"], {"rp_lumien:block 4", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["tavernkeeper"], {"rp_farming:flour 4", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["tavernkeeper"], {"rp_default:cactus 24", "", "rp_gold:ingot_gold"})
table.insert(gold.trades["tavernkeeper"], {"rp_default:swamp_grass 20", "", "rp_gold:ingot_gold"})



-- List of trader names
gold.trade_names["farmer"] = S("Farmer")
gold.trade_names["tavernkeeper"] = S("Tavern Keeper")
gold.trade_names["carpenter"] = S("Carpenter")
gold.trade_names["blacksmith"] = S("Blacksmith")
gold.trade_names["butcher"] = S("Butcher")
