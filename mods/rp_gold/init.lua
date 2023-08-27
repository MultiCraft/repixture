--
-- Gold and NPC Trading
--
local S = minetest.get_translator("rp_gold")

gold = {}

-- Sound pitch modifier of gold nodes
gold.PITCH = 1.25

local mapseed = minetest.get_mapgen_setting("seed")
gold.pr = PseudoRandom(mapseed+8732)

--[[
Table of trades offered by villagers.
Format:

   gold.trades = {
      -- List of trades for this villager type
      ["villager_type_1"] = {
         -- first trade table (see below)
         trade_1,
         -- second trade table (see below)
         trade_2,
         -- ...
      },
      ["villager_type_1"] = {
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

gold.trade_names = {}

local TRADE_FORMSPEC_OFFSET = 2.5

if minetest.get_modpath("mobs") ~= nil then
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

   gold.trade_names["farmer"] = S("Farmer")
   gold.trade_names["tavernkeeper"] = S("Tavern Keeper")
   gold.trade_names["carpenter"] = S("Carpenter")
   gold.trade_names["blacksmith"] = S("Blacksmith")
   gold.trade_names["butcher"] = S("Butcher")
end

local form_trading = ""

form_trading = form_trading .. rp_formspec.get_page("rp_formspec:2part")

form_trading = form_trading .. "list[current_player;main;0.25,4.75;8,4;]"
form_trading = form_trading .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_trading = form_trading .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)

form_trading = form_trading .. "container["..TRADE_FORMSPEC_OFFSET..",0]"
form_trading = form_trading .. "list[current_player;gold_trade_out;4.75,2.25;1,1;]"
form_trading = form_trading .. rp_formspec.get_hotbar_itemslot_bg(4.75, 2.25, 1, 1)

form_trading = form_trading .. "list[current_player;gold_trade_in;1.25,2.25;2,1;]"
form_trading = form_trading .. rp_formspec.get_itemslot_bg(1.25, 2.25, 2, 1)

form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_in]"
form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_out]"

form_trading = form_trading .. "image[3.5,1.25;1,1;ui_arrow_bg.png^[transformR270]"
form_trading = form_trading .. "image[3.5,2.25;1,1;ui_arrow.png^[transformR270]"

form_trading = form_trading .. rp_formspec.button(1.25, 3.25, 2, 1, "trade", S("Trade"))
form_trading = form_trading .. "container_end[]"

rp_formspec.register_page("rp_gold:trading_book", form_trading)

-- Returns true if the given trade is a repair trade
local is_repair_trade = function(trade)
   return trade[2] == trade[3] and ItemStack(trade[2]):get_definition().type == "tool"
end

-- Remember with which traders the players trade
local active_tradings = {}

-- Open the trading formspec that allows players to trade with NPCs.
-- * trade: Single trade table from gold.trades table
-- * trade_type: Trader type name
-- * player: Player object of player who trades
-- * trader: Trader object that player trades with
-- * trade_index: Index of current active trade in all of the available trades for this trader
-- * all_trades: List of all trades available by this trader
function gold.trade(trade, trade_type, player, trader, trade_index, all_trades)
   local name = player:get_player_name()
   local item = player:get_wielded_item()

   -- Player must hold trading book in hand
   local itemname = item:get_name()
   local item_alias = minetest.registered_aliases[itemname]
   if itemname ~= "rp_gold:trading_book" and item_alias ~= "rp_gold:trading_book" then
      return
   end

   -- Trader must exist
   if not trader or not trader.object:get_luaentity() then
      return
   end

   active_tradings[name] = { all_trades = all_trades, trade_index = trade_index, trade_type = trade_type, trader = trader }

   local inv = player:get_inventory()

   inv:set_stack("gold_trade_wanted", 1, trade[1])
   inv:set_stack("gold_trade_wanted", 2, trade[2])

   local trade_name = gold.trade_names[trade_type]
   local label = S("Trading with @1", trade_name)

   local trade_wanted1 = inv:get_stack("gold_trade_wanted", 1)
   local trade_wanted2 = inv:get_stack("gold_trade_wanted", 2)

   local form = rp_formspec.get_page("rp_gold:trading_book")
   form = form .. "label[0.25,0.25;"..minetest.formspec_escape(label).."]"

   local trades_listed = {}
   local print_item = function(itemstring)
      local stack = ItemStack(itemstring)
      local name = stack:get_short_description()
      if stack:get_name() == "rp_gold:ingot_gold" then
         -- Short for "Gold Ingot"
         name = S("G")
      end
      local count = stack:get_count()
      local out
      if stack:get_name() == "rp_gold:ingot_gold" then
         out = S("@1 @2", count, name)
      elseif count > 1 then
         out = S("@1×@2", count, name)
      else
         out = name
      end
      return out
   end
   for t=1, #all_trades do
      local take, give
      if all_trades[t][2] == "" then
         take = print_item(all_trades[t][1])
      else
         take = S("@1 + @2", print_item(all_trades[t][1]), print_item(all_trades[t][2]))
      end
      if is_repair_trade(all_trades[t]) then
         give = S("(repair)")
      else
         give = print_item(all_trades[t][3])
      end
      local entry = S("@1 → @2", take, give)
      table.insert(trades_listed, minetest.formspec_escape(entry))
   end
   local trades_listed_str = table.concat(trades_listed, ",")
   form = form .. "tablecolumns[text]"
   form = form .. "table[0.15,1.25;3.5,2.5;tradelist;"..trades_listed_str..";"..trade_index.."]"

   form = form .. "container["..TRADE_FORMSPEC_OFFSET..",0]"
   if is_repair_trade(trade) then
      -- Display repairable tool as damaged so the purpose of
      -- repair trades is more obvious
      trade_wanted2:set_wear(58982) -- ca. 90% wear
   end
   form = form .. rp_formspec.fake_itemstack(1.25, 1.25, trade_wanted1)
   form = form .. rp_formspec.fake_itemstack(2.25, 1.25, trade_wanted2)
   form = form .. rp_formspec.fake_itemstack(4.75, 1.25, ItemStack(trade[3]))
   form = form .. "container_end[]"

   minetest.show_formspec(name, "rp_gold:trading_book", form)

   return true
end

-- In the inventory `inv`, move all items of the trading slots
-- in the "gold_trade_out" and "gold_trade_in" inventory lists
-- to the "main" inventory list. Items that can't be moved
-- will be dropped on the floor at `drop_pos`.
-- If `drop_all` is true (false by default), then all items
-- will be dropped, not moved to "main".
local function clear_trading_slots(inv, drop_pos, drop_all)
   if drop_all == nil then
      drop_all = false
   end
   -- Collect items from trading slots
   local items = {}
   local list = inv:get_list("gold_trade_out")
   if not list then
	   return
   end
   for i=1, #list do
      if not list[i]:is_empty() then
         table.insert(items, list[i])
      end
   end
   list = inv:get_list("gold_trade_in")
   if not list then
	   return
   end
   for i=1, #list do
      if not list[i]:is_empty() then
         table.insert(items, list[i])
      end
   end
   -- Copy them to "main" list or drop them
   for i=1, #items do
      if (not drop_all) and inv:room_for_item("main", items[i]) then
          inv:add_item("main", items[i])
      else
          minetest.add_item(drop_pos, items[i])
      end
   end
   -- Clear the trading slots
   inv:set_list("gold_trade_out", {})
   inv:set_list("gold_trade_in", {})
end

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      local name = player:get_player_name()
      if form_name ~= "rp_gold:trading_book" then
         active_tradings[name] = nil
         return
      end

      local inv = player:get_inventory()
      if fields.cancel or fields.quit then
         clear_trading_slots(inv, player:get_pos())
         active_tradings[name] = nil
         return
      end

      if not active_tradings[name] then
         -- No trading possible if active_tradings table is empty (mustn't happen)
	 minetest.log("error", "[rp_gold] active_tradings["..tostring(name).."] was nil after receiving trading formspec fields!")
         return
      end

      local trader = active_tradings[name].trader
      if not trader or not trader.object:get_luaentity() then
         -- No trading possible if trader is gone
         clear_trading_slots(inv, player:get_pos())
	 minetest.close_formspec(name, "rp_gold:trading_book")
	 return
      end

      if fields.tradelist then
	 local tdata = minetest.explode_table_event(fields.tradelist)
	 if tdata.type == "CHG" or tdata.type == "DCL" then
            do
               local trade_index = tdata.row
               local all_trades = active_tradings[name].all_trades
               local trade_type = active_tradings[name].trade_type
               local trader = active_tradings[name].trader
               local trade = all_trades[trade_index]
               gold.trade(trade, trade_type, player, trader, trade_index, all_trades)
	    end
	 end
	 return
      end
      if fields.trade then
	 local trade_wanted1 = inv:get_stack("gold_trade_wanted", 1)
	 local trade_wanted2 = inv:get_stack("gold_trade_wanted", 2)
	 local trade_wanted1_n = trade_wanted1:get_name()
	 local trade_wanted2_n = trade_wanted2:get_name()

	 local trade_in1 = inv:get_stack("gold_trade_in", 1)
	 local trade_in2 = inv:get_stack("gold_trade_in", 2)
	 local trade_in1_n = trade_in1:get_name()
	 local trade_in2_n = trade_in2:get_name()

	 local matches = false
	 if trade_wanted1_n == "" or trade_wanted2_n == "" then
	    -- Wants 1 item
	    local wanted, wanted_n, wanted_c
	    if trade_wanted1_n ~= "" then
	       wanted = trade_wanted1
	    else
	       wanted = trade_wanted2
	    end
	    if inv:contains_item("gold_trade_in", wanted) then
	       matches = true
	    end
	 else
	    -- Wants 2 items (this assumes both items are different)
	    if inv:contains_item("gold_trade_in", trade_wanted1) and inv:contains_item("gold_trade_in", trade_wanted2) then
	       matches = true
	    end
	 end

	 local trade
	 local active_trade = active_tradings[name]
	 if active_trade then
	    trade = active_trade.all_trades[active_trade.trade_index]
	 end
	 if not trade then
	    minetest.log("error", "[rp_gold] "..player:get_player_name().." tried to trade with invalid/unknown active trade!")
	    return
	 end

	 if matches then
	    if inv:room_for_item("gold_trade_out", trade[3]) then
	       inv:add_item("gold_trade_out", trade[3])
	       inv:remove_item("gold_trade_in", trade[1])
	       inv:remove_item("gold_trade_in", trade[2])
               achievements.trigger_achievement(player, "trader")
	    end
	 end
      end
end)

local function init_inventory(player)
   local inv = player:get_inventory()
   if inv:get_size("gold_trade_wanted") ~= 2 then
      inv:set_size("gold_trade_wanted", 2)
   end

   if inv:get_size("gold_trade_out") ~= 1 then
      inv:set_size("gold_trade_out", 1)
   end

   if inv:get_size("gold_trade_in") ~= 2 then
      inv:set_size("gold_trade_in", 2)
   end
end
-- Make sure to clean up the trading slots properly
-- on rejoining, respawning and dying
local function clear_trading_slots_move_main(player)
   local inv = player:get_inventory()
   local pos = player:get_pos()
   clear_trading_slots(inv, pos, false)
end
minetest.register_on_joinplayer(init_inventory)
minetest.register_on_joinplayer(clear_trading_slots_move_main)
minetest.register_on_respawnplayer(clear_trading_slots_move_main)

-- Death = drop all items in trading slots
local function clear_trading_slots_drop(player)
   local inv = player:get_inventory()
   local pos = player:get_pos()
   clear_trading_slots(inv, pos, true)
end
minetest.register_on_dieplayer(clear_trading_slots_drop)

-- Items / nodes

book.register_book_node(
   "rp_gold:trading_book",
   {
      description = S("Trading Book"),
      _tt_help = S("Show this to a villager to trade"),
      texture = "gold_book.png^gold_bookribbon.png",
      stack_max = 1,
      tiles = {
         "rp_gold_book_node_top.png^gold_bookribbon.png",
         "rp_gold_book_node_bottom.png",
         "rp_gold_book_node_pages.png",
         "rp_gold_book_node_spine.png^rp_gold_book_node_spine_bookribbon.png",
         "rp_gold_book_node_side_1.png",
         "rp_gold_book_node_side_2.png",

      },
      groups = { book = 1, tool = 1, dig_immediate = 3 },
})

minetest.register_craftitem(
   "rp_gold:lump_gold",
   {
      description = S("Gold Lump"),
      groups = { mineral_lump = 1, mineral_natural = 1 },
      inventory_image = "gold_lump_gold.png",
})

minetest.register_craftitem(
   "rp_gold:ingot_gold",
   {
      description = S("Gold Ingot"),
      groups = { ingot = 1 },
      inventory_image = "gold_ingot_gold.png",
})

default.register_ingot("rp_gold:ingot_gold", {
	description = S("Gold Ingot"),
	texture = "gold_ingot_gold.png",
	tilesdef = {
		top = "rp_gold_ingot_gold_node_top.png",
		side_short = "rp_gold_ingot_gold_node_side_short.png",
		side_long = "rp_gold_ingot_gold_node_side_long.png",
	},
	pitch = gold.PITCH,
})

-- Classic nodes

minetest.register_node(
   "rp_gold:stone_with_gold",
   {
      description = S("Stone with Gold"),
      tiles ={"default_stone.png^gold_mineral_gold.png"},
      groups = {cracky=1, stone=1, ore=1},
      drop = "rp_gold:lump_gold",
      is_ground_content = true,
      sounds = rp_sounds.node_sound_stone_defaults(),
})

local make_metal_sounds = function(pitch)
	local sounds = rp_sounds.node_sound_metal_defaults()
	if sounds.footstep then
		sounds.footstep.pitch = pitch
	end
	if sounds.dig then
		sounds.dig.pitch = pitch
	end
	if sounds.dug then
		sounds.dug.pitch = pitch
	end
	if sounds.place then
		sounds.place.pitch = pitch
	end
	return sounds
end

minetest.register_node(
   "rp_gold:block_gold",
   {
      description = S("Gold Block"),
      tiles = {"gold_block.png"},
      groups = {cracky = 2},
      sounds = make_metal_sounds(gold.PITCH),
      is_ground_content = false,
})

-- Ores

minetest.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_gold:stone_with_gold",
      wherein        = "rp_default:stone",
      clust_scarcity = 9*9*9,
      clust_num_ores = 12,
      clust_size     = 6,
      y_min          = -60,
      y_max          = -45,
})

-- Crafting

crafting.register_craft(
   {
      output = "rp_gold:trading_book",
      items = {
         "rp_default:book_empty",
         "rp_gold:ingot_gold",
      }
})

crafting.register_craft(
   {
      output = "rp_gold:block_gold",
      items = {
         "rp_gold:ingot_gold 9",
      }
})
crafting.register_craft(
   {
      output = "rp_gold:ingot_gold 9",
      items = {
         "rp_gold:block_gold",
      }
})


minetest.register_craft(
   {
      type = "cooking",
      output = "rp_gold:ingot_gold",
      recipe = "rp_gold:lump_gold",
      cooktime = 7,
})
minetest.register_craft(
{
      type = "cooking",
      output = "rp_gold:lump_gold",
      recipe = "rp_gold:stone_with_gold",
      cooktime = 6,
})

-- Achievements

achievements.register_achievement(
   "trader",
   {
      title = S("Trader"),
      description = S("Trade with a villager."),
      times = 1,
      item_icon = "rp_gold:trading_book",
      difficulty = 5.4,
})

achievements.register_achievement(
   "gold_rush",
   {
      title = S("Gold Rush"),
      description = S("Dig a gold ore."),
      times = 1,
      dignode = "rp_gold:stone_with_gold",
      difficulty = 5.2,
})

minetest.register_on_leaveplayer(function(player)
   local name = player:get_player_name()
   active_tradings[name] = nil
end)

if minetest.settings:get_bool("rp_testing_enable", false) == true then
    -- Check if all specified items are valid
    minetest.register_on_mods_loaded(function()
        for trader_name, trader in pairs(gold.trades) do
            for trade_id, trade in pairs(trader) do
                for i=1,3 do
                    local item = ItemStack(trade[i]):get_name()
                    assert(item ~= nil and (item == "" or minetest.registered_items[item]), "[rp_gold] Invalid trade item: trader="..trader_name..", index="..trade_id..", item="..item)
                end
            end
        end
    end)
end

-- Aliases
minetest.register_alias("gold:ingot_gold", "rp_gold:ingot_gold")
minetest.register_alias("gold:lump_gold", "rp_gold:lump_gold")
minetest.register_alias("gold:stone_with_gold", "rp_gold:stone_with_gold")
minetest.register_alias("gold:trading_book", "rp_gold:trading_book")
