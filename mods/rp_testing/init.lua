--
-- Testing mod
-- By Kaadmy and Wuzzy, for Repixture
--

-- No-op if this setting is disabled
if not minetest.settings:get_bool("rp_testing_enable", false) then
   return
end

local S = minetest.get_translator("rp_testing")

local function dumpvec(v)
   return v.x..":"..v.y..":"..v.z
end

do
   -- Function performance testing
   local t1 = os.clock()
   for i = 1, 10000 do
      dump({x=0,y=50,z=100})
   end
   minetest.log("action", "[rp_testing] " .. string.format("10000 iterations with dump({x=0,y=50,z=100}) took %.2fms", (os.clock() - t1) * 1000))

   local t2 = os.clock()
   for i = 1, 10000 do
      tostring({x=0,y=50,z=100})
   end
   minetest.log("action", "[rp_testing] " .. string.format("10000 iterations with tostring({x=0,y=50,z=100}) took %.2fms", (os.clock() - t2) * 1000))

   local t3 = os.clock()
   for i = 1, 10000 do
      minetest.serialize({x=0,y=50,z=100})
   end
   minetest.log("action", "[rp_testing] " .. string.format("10000 iterations with minetest.serialize({x=0,y=50,z=100}) took %.2fms", (os.clock() - t3) * 1000))

   local t4 = os.clock()
   for i = 1, 10000 do
      dumpvec({x=0,y=50,z=100})
   end
   minetest.log("action", "[rp_testing] " .. string.format("10000 iterations with (custom function) dumpvec({x=0,y=50,z=100}) took %.2fms", (os.clock() - t4) * 1000))

   local t5 = os.clock()
   for i = 1, 10000 do
      minetest.hash_node_position({x=0,y=50,z=100})
   end
   minetest.log("action", "[rp_testing] " .. string.format("10000 iterations with minetest.hash_node_position({x=0,y=50,z=100}) took %.2fms", (os.clock() - t5) * 1000))

   -- List fuel recipes
   minetest.register_chatcommand("list_fuels", {
	   description = S("List all furnace fuels and their burntime"),
	   privs = { debug = true },
	   func = function(name, param)
		   local fuels = {}
		   for itemstring, def in pairs(minetest.registered_items) do
			   local input = {
				   method = "fuel",
				   items = { itemstring },
			   }
			   local res = minetest.get_craft_result(input)
			   if res and res.time > 0 then
				   table.insert(fuels, {itemstring, res.time})
			   end
		   end
		   local sort_by_time = function(v1, v2)
			   return v1[2] < v2[2]
		   end
		   table.sort(fuels, sort_by_time)
		   for f=1, #fuels do
			   minetest.chat_send_player(name, S("@1: @2", fuels[f][1], fuels[f][2]))
		   end
		   return true
	   end,
   })

   -- List fuel recipes
   minetest.register_chatcommand("list_cookings", {
	   description = S("List all cooking recipes"),
	   privs = { debug = true },
	   func = function(name, param)
		   local recipes = {}
		   for itemstring, def in pairs(minetest.registered_items) do
			   local input = {
				   method = "cooking",
				   items = { itemstring },
			   }
			   local res = minetest.get_craft_result(input)
			   if res and res.time > 0 then
				   table.insert(recipes, {itemstring, res.item, res.time})
			   end
		   end
		   local sort_by_input = function(v1, v2)
			   return v1[1] < v2[1]
		   end
		   table.sort(recipes, sort_by_input)
		   for r=1, #recipes do
			   minetest.chat_send_player(name, S("@1 → @2 (time=@3)", recipes[r][1], recipes[r][2]:to_string(), recipes[r][3]))
		   end
		   return true
	   end,
   })
end
