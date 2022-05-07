--
-- Testing mod
-- By Kaadmy and Wuzzy, for Repixture
--

-- No-op if this setting is disabled
if not minetest.settings:get_bool("rp_testing_enable", false) then
   return
end

-- Note: Intentionally NOT translated. This is a mod for development.

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
	   description = "List all furnace fuels and their burntime",
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
			   minetest.chat_send_player(name, fuels[f][1]..": "..fuels[f][2])
		   end
	   end,
   })
end
