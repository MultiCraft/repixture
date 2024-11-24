--
-- Gold and trading
--
local S = minetest.get_translator("rp_gold")

gold = {}

-- Sound pitch modifier of gold nodes
gold.PITCH = 1.25

-- Load available trades
dofile(minetest.get_modpath("rp_gold").."/trades.lua")

-- Randomness for selecting trades
gold.pr = PseudoRandom(os.time())

-- Trading formspec
local TRADE_FORMSPEC_START_X = rp_formspec.default.start_point.x
local TRADE_FORMSPEC_START_Y = rp_formspec.default.start_point.y
local TRADE_FORMSPEC_OFFSET_X = 5
local TRADE_FORMSPEC_OFFSET_Y = 0.5

local form_trading = ""

form_trading = form_trading .. rp_formspec.get_page("rp_formspec:2part")

form_trading = form_trading .. rp_formspec.default.player_inventory

form_trading = form_trading .. "container["..TRADE_FORMSPEC_START_X..","..TRADE_FORMSPEC_START_Y.."]"
form_trading = form_trading .. "container["..TRADE_FORMSPEC_OFFSET_X..","..TRADE_FORMSPEC_OFFSET_Y.."]"
form_trading = form_trading .. rp_formspec.get_hotbar_itemslot_bg(3.75, 1.25, 1, 1)
form_trading = form_trading .. "list[current_player;gold_trade_out;3.75,1.25;1,1;]"

form_trading = form_trading .. rp_formspec.get_itemslot_bg(0, 1.25, 2, 1)
form_trading = form_trading .. "list[current_player;gold_trade_in;0,1.25;2,1;]"

form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_in]"
form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_out]"

form_trading = form_trading .. "image[2.5,1.25;1,1;ui_arrow.png^[transformR270]"

form_trading = form_trading .. rp_formspec.button(0.15, 2.5, 2, 1, "trade", S("Trade"))
form_trading = form_trading .. "container_end[]"
form_trading = form_trading .. "container_end[]"

rp_formspec.register_page("rp_gold:trading_book", form_trading)

-- Returns true if the given trade is a repair trade
local is_repair_trade = function(trade)
   return trade[2] == trade[3] and ItemStack(trade[2]):get_definition().type == "tool"
end

-- Remember with which traders the players trade
local active_tradings = {}

-- Open the trading formspec that allows players to trade with traders.
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

   local scroll_pos
   if active_tradings[name] then
      scroll_pos = active_tradings[name].scroll_pos
   else
      scroll_pos = 0
   end
   active_tradings[name] = { all_trades = all_trades, trade_index = trade_index, scroll_pos = scroll_pos, trade_type = trade_type, trader = trader }

   local inv = player:get_inventory()

   inv:set_stack("gold_trade_wanted", 1, trade[1])
   inv:set_stack("gold_trade_wanted", 2, trade[2])

   local trade_name = gold.trade_names[trade_type]
   local trader_name
   -- Generate trading formspec caption
   if trader._name then
      -- Trader has a name: show name and profession
      --~ Shown in trader menu. @1 = trader name, @2 = profession name
      trader_name = S("@1 (@2)", trader._name, trade_name)
   else
      -- Trader has no name: show profession
      trader_name = trade_name
   end
   --~ @1 is either a given name or a profession
   local label = S("Trading with @1", trader_name)

   local trade_wanted1 = inv:get_stack("gold_trade_wanted", 1)
   local trade_wanted2 = inv:get_stack("gold_trade_wanted", 2)

   local form = rp_formspec.get_page("rp_gold:trading_book")
   form = form .. "container["..TRADE_FORMSPEC_START_X..","..TRADE_FORMSPEC_START_Y.."]"
   form = form .. "label[0,"..(TRADE_FORMSPEC_OFFSET_Y-0.3)..";"..minetest.formspec_escape(label).."]"

   local trades_listed = {}
   local trades_listed_str = ""
   local cy = 0
   for t=1, #all_trades do
      local take1, take2, give
      if all_trades[t][2] == "" then
         take1 = ItemStack(all_trades[t][1])
         take2 = ItemStack(all_trades[t][2])
      else
         take1 = ItemStack(all_trades[t][1])
         take2 = ItemStack(all_trades[t][2])
      end
      if is_repair_trade(all_trades[t]) then
         give = ItemStack(all_trades[t][2])
      else
         give = ItemStack(all_trades[t][3])
      end

      if is_repair_trade(all_trades[t]) then
         -- Display repairable tool as damaged so the purpose of
         -- repair trades is more obvious
         take2:set_wear(58982) -- ca. 90% wear
      end
      trades_listed_str =
          -- Trade selection button
          "button[0,"..cy..";4.2,1.0;tradesel_"..t..";]" ..
          trades_listed_str .. rp_formspec.fake_itemstack(0.2, cy+0.1, take1, 0.8, 0.8) ..
          rp_formspec.fake_itemstack(1.2, cy+0.1, take2, 0.8, 0.8) ..
          "image[2.2,"..(cy+0.1)..";0.8,0.8;ui_arrow_bg.png^[transformR270]" ..
          rp_formspec.fake_itemstack(3.2, cy+0.1, give, 0.8, 0.8)

      cy = cy + 1
   end
   if #all_trades > 4 then
      local maxscroll = #all_trades - 4
      local thumb = math.max(1, math.floor(maxscroll / 5))
      form = form .. "scrollbaroptions[min=0;max="..maxscroll..";thumbsize="..thumb..";smallstep=1;largestep=4]"
      form = form .. "scrollbar[4.3,"..TRADE_FORMSPEC_OFFSET_Y..";0.3,4;vertical;tradescroller;"..scroll_pos.."]"
   end
   form = form .. "scroll_container[0,"..TRADE_FORMSPEC_OFFSET_Y..";4.21,4;tradescroller;vertical;1]"
   form = form .. "style_type[button;border=false;bgimg_middle=24]"
   form = form .. "style_type[button;bgimg=ui_button_trade_inactive.png^[resize:64x64]"
   form = form .. "style_type[button:pressed;bgimg=ui_button_trade_active.png^[resize:64x64]"
   if trade_index then
      local selected_trade_elem = "tradesel_"..trade_index
      form = form .. "style["..selected_trade_elem..";bgimg=ui_button_trade_selected_inactive.png^[resize:64x64]"
      form = form .. "style["..selected_trade_elem..":pressed;bgimg=ui_button_trade_selected_active.png^[resize:64x64]"
   end
   form = form .. trades_listed_str
   form = form .. "scroll_container_end[]"
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

      if fields.tradescroller then
         -- Remember position of scrollbar
         local evnt = minetest.explode_scrollbar_event(fields.tradescroller)
         if evnt.type == "CHG" then
            active_tradings[name].scroll_pos = evnt.value
            return
         end
      end

      -- Selected a trade from trade list
      for f=1, #active_tradings[name].all_trades do
         if fields["tradesel_"..f] then
            local trade_index = f
            local all_trades = active_tradings[name].all_trades
            local trade_type = active_tradings[name].trade_type
            local trader = active_tradings[name].trader
            local trade = all_trades[trade_index]
            gold.trade(trade, trade_type, player, trader, trade_index, all_trades)
            return
	 end
      end

      -- Trade button pressed
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
      groups = {cracky=1, stone=1, ore=1, pathfinder_hard=1},
      drop = "rp_gold:lump_gold",
      is_ground_content = true,
      sounds = rp_sounds.node_sound_stone_defaults(),
      _rp_blast_resistance = 1,
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
      groups = {cracky = 2, pathfinder_hard=1},
      sounds = make_metal_sounds(gold.PITCH),
      is_ground_content = false,
      _rp_blast_resistance = 8,
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
