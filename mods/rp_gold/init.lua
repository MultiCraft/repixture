--
-- Gold and NPC Trading
-- By Kaadmy, for Pixture
--
local S = minetest.get_translator("rp_gold")

gold = {}

local mapseed = minetest.get_mapgen_setting("seed")
gold.pr = PseudoRandom(mapseed+8732)

gold.trades = {}
gold.trade_names = {}

if minetest.get_modpath("mobs") ~= nil then
   gold.trades["farmer"] = {
      -- plants
      {"rp_gold:ingot_gold", "", "rp_farming:wheat_1 6"},
      {"rp_gold:ingot_gold 3", "", "rp_farming:cotton_1 4"},
      {"rp_gold:ingot_gold 5", "", "rp_farming:cotton_1 8"},
      {"rp_gold:ingot_gold", "", "rp_default:papyrus 4"},
      {"rp_gold:ingot_gold 2", "", "rp_default:cactus"},

      -- crafts
      {"rp_gold:ingot_gold 7", "", "rp_farming:cotton_bale 3"},

      -- tool repair
      {"rp_gold:ingot_gold 6", "rp_default:shovel_stone", "rp_default:shovel_stone"},
      {"rp_gold:ingot_gold 8", "rp_default:shovel_steel", "rp_default:shovel_steel"},
      {"rp_gold:ingot_gold 10", "rp_default:shovel_carbon_steel", "rp_default:shovel_carbon_steel"},

      -- filling buckets
      {"rp_gold:ingot_gold", "rp_default:bucket", "rp_default:bucket_water"},
   }
   gold.trades["carpenter"] = {
      -- materials
      {"rp_gold:ingot_gold", "", "rp_default:planks 6"},
      {"rp_gold:ingot_gold", "", "rp_default:planks_birch 4"},
      {"rp_gold:ingot_gold 3", "", "rp_default:planks_oak 10"},
      {"rp_gold:ingot_gold", "", "rp_default:frame 2"},
      {"rp_gold:ingot_gold", "", "rp_default:reinforced_frame"},

      -- useables
      {"rp_gold:ingot_gold 9", "", "rp_bed:bed"},
      {"rp_gold:ingot_gold 2", "", "rp_default:chest"},
      {"rp_gold:ingot_gold 5", "mobs:wool 3", "rp_bed:bed"},
   }
   gold.trades["tavernkeeper"] = {
      -- edibles
      {"rp_gold:ingot_gold", "", "rp_default:apple 3"},
      {"rp_gold:ingot_gold", "", "rp_farming:bread"},
      {"rp_gold:ingot_gold 2", "", "mobs:meat"},
      {"rp_gold:ingot_gold 3", "", "mobs:pork"},

      -- filling buckets
      {"rp_gold:ingot_gold", "rp_default:bucket", "rp_default:bucket_water"},
   }
   gold.trades["blacksmith"] = {
      -- smeltables
      {"rp_gold:ingot_gold", "", "rp_default:lump_coal"},
      {"rp_gold:ingot_gold 3", "", "rp_default:lump_iron"},

      -- materials
      {"rp_gold:ingot_gold", "", "rp_default:cobble 5"},
      {"rp_gold:ingot_gold 3", "", "rp_default:stone 10"},
      {"rp_gold:ingot_gold", "", "rp_default:reinforced_cobble 2"},
      {"rp_gold:ingot_gold 25", "", "rp_default:block_steel"},
      {"rp_gold:ingot_gold 6", "", "rp_default:glass 5"},

      -- usebles
      {"rp_gold:ingot_gold 7", "", "rp_default:furnace"},

      -- ingots
      {"rp_gold:ingot_gold 5", "", "rp_default:ingot_steel"},
      {"rp_gold:ingot_gold 8", "", "rp_default:ingot_carbon_steel"},

      -- auto smelting
      {"rp_gold:ingot_gold 2", "rp_default:lump_iron", "rp_default:ingot_steel"},

      -- tool repair
      {"rp_gold:ingot_gold 8", "rp_default:pick_stone", "rp_default:pick_stone"},
      {"rp_gold:ingot_gold 12", "rp_default:pick_steel", "rp_default:pick_steel"},
      {"rp_gold:ingot_gold 16", "rp_default:pick_carbon_steel", "rp_default:pick_carbon_steel"},
   }
   gold.trades["butcher"] = {
      -- raw edibles
      {"rp_gold:ingot_gold", "", "mobs:meat_raw"},
      {"rp_gold:ingot_gold 3", "", "mobs:pork_raw 2"},

      -- cooking edibles
      {"rp_gold:ingot_gold 1", "mobs:meat_raw", "mobs:meat"},
      {"rp_gold:ingot_gold 2", "mobs:pork_raw", "mobs:pork"},

      -- tool repair
      {"rp_gold:ingot_gold 5", "rp_default:spear_stone", "rp_default:spear_stone"},
      {"rp_gold:ingot_gold 7", "rp_default:spear_steel", "rp_default:spear_steel"},
      {"rp_gold:ingot_gold 11", "rp_default:spear_carbon_steel", "rp_default:spear_carbon_steel"},

   }
   -- trading currency
   if minetest.get_modpath("rp_jewels") ~= nil then -- jewels/gold
      --farmer
      table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 16", "", "rp_jewels:jewel"})
      table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 22", "", "rp_jewels:jewel 2"})
      table.insert(gold.trades["farmer"], {"rp_gold:ingot_gold 34", "", "rp_jewels:jewel 4"})

      table.insert(gold.trades["farmer"], {"rp_jewels:jewel", "", "rp_gold:ingot_gold 14"})
      table.insert(gold.trades["farmer"], {"rp_jewels:jewel 2", "", "rp_gold:ingot_gold 20"})
      table.insert(gold.trades["farmer"], {"rp_jewels:jewel 4", "", "rp_gold:ingot_gold 32"})

      -- tavern keeper
      table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 14", "", "rp_jewels:jewel"})
      table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 20", "", "rp_jewels:jewel 2"})
      table.insert(gold.trades["tavernkeeper"], {"rp_gold:ingot_gold 32", "", "rp_jewels:jewel 4"})

      -- blacksmith
      table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 14", "", "rp_jewels:jewel"})
      table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 20", "", "rp_jewels:jewel 2"})
      table.insert(gold.trades["blacksmith"], {"rp_default:ingot_steel 32", "", "rp_jewels:jewel 4"})
   end

   -- carpenter (no mod check)
   table.insert(gold.trades["carpenter"], {"rp_default:tree 2", "", "rp_gold:ingot_gold"})

   -- butcher (no mod check)
   table.insert(gold.trades["butcher"], {"mobs:meat_raw 3", "", "rp_gold:ingot_gold"})
   table.insert(gold.trades["butcher"], {"mobs:meat_raw 4", "", "rp_gold:ingot_gold 2"})
   table.insert(gold.trades["butcher"], {"mobs:meat_raw 5", "", "rp_gold:ingot_gold 4"})

   gold.trade_names["farmer"] = S("Farmer")
   gold.trade_names["tavernkeeper"] = S("Tavern Keeper")
   gold.trade_names["carpenter"] = S("Carpenter")
   gold.trade_names["blacksmith"] = S("Blacksmith")
   gold.trade_names["butcher"] = S("Butcher")
end

local form_trading = ""

form_trading = form_trading .. rp_formspec.get_page("rp_default:2part")

form_trading = form_trading .. "list[current_player;gold_trade_out;4.75,2.25;1,1;]"

form_trading = form_trading .. rp_formspec.get_hotbar_itemslot_bg(4.75, 2.25, 1, 1)

form_trading = form_trading .. "list[current_player;main;0.25,4.75;8,4;]"
form_trading = form_trading .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
form_trading = form_trading .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)

form_trading = form_trading .. "list[current_player;gold_trade_in;1.25,2.25;2,1;]"
form_trading = form_trading .. rp_formspec.get_itemslot_bg(1.25, 2.25, 2, 1)

form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_in]"
form_trading = form_trading .. "listring[current_player;main]"
form_trading = form_trading .. "listring[current_player;gold_trade_out]"

form_trading = form_trading .. "image[3.5,1.25;1,1;ui_arrow_bg.png^[transformR270]"
form_trading = form_trading .. "image[3.5,2.25;1,1;ui_arrow.png^[transformR270]"

form_trading = form_trading .. rp_formspec.button(1.25, 3.25, 2, 1, "trade", S("Trade"))
form_trading = form_trading .. rp_formspec.button_exit(5.25, 3.25, 2, 1, "cancel", S("Cancel"))

rp_formspec.register_page("rp_gold_trading_book", form_trading)

function gold.trade(trade, trade_type, player)
   local name = player:get_player_name()
   local item = player:get_wielded_item()

   local itemname = item:get_name()
   local item_alias = minetest.registered_aliases[itemname]
   if itemname ~= "rp_gold:trading_book" and item_alias ~= "rp_gold:trading_book" then return end

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

   inv:set_stack("gold_trade_wanted", 1, trade[1])
   inv:set_stack("gold_trade_wanted", 2, trade[2])

   local meta = minetest.deserialize(item:get_metadata())

   if not meta then meta = {} end
   meta.trade = trade

   local trade_name = gold.trade_names[trade_type]

   local trade_wanted1 = inv:get_stack("gold_trade_wanted", 1)
   local trade_wanted2 = inv:get_stack("gold_trade_wanted", 2)

   local form = rp_formspec.get_page("rp_gold_trading_book")
   form = form .. "label[0.25,0.25;"..minetest.formspec_escape(trade_name).."]"

   form = form .. rp_formspec.fake_itemstack(1.25, 1.25, trade_wanted1)
   form = form .. rp_formspec.fake_itemstack(2.25, 1.25, trade_wanted2)
   form = form .. rp_formspec.fake_itemstack(4.75, 1.25, ItemStack(trade[3]))

   minetest.show_formspec(name, "rp_gold:trading_book", form)

   meta.trade_type = trade_type

   item:set_metadata(minetest.serialize(meta))
   player:set_wielded_item(item)

   return true
end

minetest.register_on_player_receive_fields(
   function(player, form_name, fields)
      if form_name ~= "rp_gold:trading_book" or fields.cancel then return end

      local inv = player:get_inventory()

      if fields.trade then
	 local item = player:get_wielded_item()

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

	 local meta = minetest.deserialize(item:get_metadata())

	 local trade = {"rp_gold:ingot_gold", "rp_gold:ingot_gold", "rp_default:stick"}
	 local trade_type = ""

	 if meta then
	    trade = meta.trade
	    trade_type = meta.trade_type
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

-- Items

minetest.register_craftitem(
   "rp_gold:trading_book",
   {
      description = S("Trading Book"),
      _tt_help = S("Show this to a villager to trade"),
      inventory_image = "default_book.png^gold_bookribbon.png",
      stack_max = 1,
})

minetest.register_craftitem(
   "rp_gold:lump_gold",
   {
      description = S("Gold Lump"),
      inventory_image = "gold_lump_gold.png",
})

minetest.register_craftitem(
   "rp_gold:ingot_gold",
   {
      description = S("Gold Ingot"),
      inventory_image = "gold_ingot_gold.png",
})

-- Nodes

minetest.register_node(
   "rp_gold:stone_with_gold",
   {
      description = S("Stone with Gold"),
      tiles ={"default_stone.png^gold_mineral_gold.png"},
      groups = {cracky=1, stone=1},
      drop = "rp_gold:lump_gold",
      is_ground_content = true,
      sounds = rp_sounds.node_sound_stone_defaults(),
})

minetest.register_node(
   "rp_gold:block_gold",
   {
      description = S("Gold Block"),
      tiles = {"gold_block.png"},
      groups = {cracky = 2},
      sounds = rp_sounds.node_sound_stone_defaults(),
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
         "rp_default:book",
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

minetest.register_craft(
   {
      type = "cooking",
      output = "rp_gold:ingot_gold",
      recipe = "rp_gold:lump_gold",
      cooktime = 7,
})

-- Achievements

achievements.register_achievement(
   "trader",
   {
      title = S("Trader"),
      description = S("Trade with a villager."),
      times = 1,
})

achievements.register_achievement(
   "gold_rush",
   {
      title = S("Gold Rush"),
      description = S("Dig a gold ore."),
      times = 1,
      dignode = "rp_gold:stone_with_gold",
})

if minetest.settings:get_bool("pixture_debug", false) == true then
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

default.log("mod:rp_gold", "loaded")
