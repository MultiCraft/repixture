--
-- Gives initial stuff
-- By Kaadmy, for Pixture
--

local give_initial_enable = minetest.settings:get_bool("give_initial_enable")
local give_initial_items = minetest.settings:get("give_initial_items")
local give_list = string.split(give_initial_items, ",")

local function on_newplayer(player)
   if give_initial_enable then
      local inv = player:get_inventory()

      for _, itemstring in ipairs(give_list) do
	 local item = ItemStack(itemstring)
	 if minetest.registered_items[item:get_name()] then
	     -- Only give item if known
             inv:add_item("main", itemstring)
         end
      end
   end
end

minetest.register_on_newplayer(on_newplayer)

minetest.register_on_mods_loaded(function()
   if give_initial_enable then
      for _, itemstring in ipairs(give_list) do
         local item = ItemStack(itemstring)
         local itemname = item:get_name()
         if not minetest.registered_items[itemname] then
            minetest.log("action", "[rp_give_initial_items] Unknown item in 'give_initial_items' setting: "..itemname.. " - this item will not be given")
         end
      end
   end
end)


