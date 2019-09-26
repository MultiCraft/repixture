
--
-- Tool definitions
--

local S = minetest.get_translator("default")

local creative_digtime = 0

local tool_levels = nil

local creative_digtable = {
   crumbly = {
      [3] = creative_digtime,
      [2] = creative_digtime,
      [1] = creative_digtime,
   },
   choppy = {
      [3] = creative_digtime,
      [2] = creative_digtime,
      [1] = creative_digtime,
   },
   cracky = {
      [3] = creative_digtime,
      [2] = creative_digtime,
      [1] = creative_digtime,
   },
   snappy = {
      [3] = creative_digtime,
      [2] = creative_digtime,
      [1] = creative_digtime,
   },
   dig_immediate = {
      [3] = 0,
      [2] = math.min(creative_digtime, 0.5),
   },
}

-- Creative mode/hand defs
if minetest.settings:get_bool("creative_mode") == true then
   tool_levels = {
      wood = creative_digtable,
      stone = creative_digtable,
      wrought_iron = creative_digtable,
      steel = creative_digtable,
      carbon_steel = creative_digtable,
      bronze = creative_digtable,
   }

   minetest.register_item(
      ":",
      {
	 type = "none",
	 wield_image = "wieldhand.png",
	 wield_scale = {x=1.0,y=1.0,z=2.0},
	 tool_capabilities = {
	    full_punch_interval = 1.0,
	    max_drop_level = 0,
	    groupcaps = {
	       fleshy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	       crumbly = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	       choppy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	       cracky = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	       snappy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	       handy = {times={[1]=creative_digtime,[2]=creative_digtime,[3]=creative_digtime}, uses=0, maxlevel=1},
	       oddly_breakable_by_hand = {times={[1]=creative_digtime,[2]=creative_digtime,[3]=creative_digtime}, uses=0, maxlevel=3},
	       dig_immediate = {times={[2]=math.min(creative_digtime, 0.5), [3]=0}, uses=0, maxlevel=1},
	    },
	    damage_groups = {fleshy = 1}
	 },
	 range = 20,
   })
else
   tool_levels = {
      wood = {
         crumbly = {
            [3] = 1.6,
            [2] = 2.0,
         },
         choppy = {
            [3] = 2.6,
            [2] = 3.0,
         },
         cracky = {
            [3] = 3.8,
            [2] = 4.2,
         },
         snappy = {
            [3] = 0.5,
            [2] = 1.0,
         },
      },
      stone = {
         crumbly = {
            [3] = 1.3,
            [2] = 1.7,
         },
         choppy = {
            [3] = 2.3,
            [2] = 2.7,
         },
         cracky = {
            [3] = 3.3,
            [2] = 3.7,
         },
         snappy = {
            [3] = 0.4,
            [2] = 0.9,
         },
      },
      wrought_iron = {
         crumbly = {
            [3] = 1.0,
            [2] = 1.4,
         },
         choppy = {
            [3] = 2.0,
            [2] = 2.4,
         },
         cracky = {
            [3] = 2.8,
            [2] = 3.2,
         },
         snappy = {
            [3] = 0.3,
            [2] = 0.8,
         },
      },
      steel = {
         crumbly = {
            [3] = 0.9,
            [2] = 1.2,
            [1] = 3.5,
         },
         choppy = {
            [3] = 1.7,
            [2] = 2.1,
            [1] = 3.2,
         },
         cracky = {
            [3] = 2.3,
            [2] = 2.7,
            [1] = 3.8,
         },
         snappy = {
            [3] = 0.2,
            [2] = 0.7,
            [1] = 1.2,
         },
      },
      carbon_steel = {
         crumbly = {
            [3] = 0.6,
            [2] = 1.0,
            [1] = 2.7,
         },
         choppy = {
            [3] = 1.2,
            [2] = 1.8,
            [1] = 2.6,
         },
         cracky = {
            [3] = 1.8,
            [2] = 2.3,
            [1] = 3.3,
         },
         snappy = {
            [3] = 0.2,
            [2] = 0.5,
            [1] = 1.0,
         },
      },
      bronze = {
         crumbly = {
            [3] = 0.3,
            [2] = 0.7,
            [1] = 2.3,
         },
         choppy = {
            [3] = 0.6,
            [2] = 1.1,
            [1] = 1.8,
         },
         cracky = {
            [3] = 1.4,
            [2] = 1.9,
            [1] = 2.7,
         },
         snappy = {
            [3] = 0.1,
            [2] = 0.3,
            [1] = 0.7,
         },
      },
   }

   minetest.register_item(
      ":",
      {
	 type = "none",
	 wield_image = "wieldhand.png",
	 wield_scale = {x=1.0,y=1.0,z=2.0},
	 tool_capabilities = {
	    full_punch_interval = 1.0,
	    max_drop_level = 0,
	    groupcaps = {
	       fleshy = {times={[2]=1.6, [3]=1.0}, uses=0, maxlevel=1},
	       crumbly = {times={[2]=3.2, [3]=2.1}, uses=0, maxlevel=1},
	       choppy = {times={[2]=3.5, [3]=3.8}, uses=0, maxlevel=1},
	       cracky = {times={[3]=8.5}, uses=0, maxlevel=1},
	       snappy = {times={[1]=2.5, [2]=2.0, [3]=1.5}, uses=0, maxlevel=1},
	       handy = {times={[1]=1.0,[2]=0.5,[3]=0.25}, uses=0, maxlevel=1},
	       oddly_breakable_by_hand = {times={[1]=7.0,[2]=5.5,[3]=4.0}, uses=0, maxlevel=1},
	    },
	    damage_groups = {fleshy = 1}
	 },
	 range = 4,
   })
end

-- "Creative" Tool

minetest.register_tool(
   "default:creative_tool",
   {
      description = S("Creative Tool"),
      inventory_image = "default_creative_tool.png",
      tool_capabilities = {
	 full_punch_interval = 0.5,
	 max_drop_level = 0,
	 groupcaps = {
	    fleshy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	    crumbly = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	    choppy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	    cracky = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	    snappy = {times={[1]=creative_digtime, [2]=creative_digtime, [3]=creative_digtime}, uses=0, maxlevel=1},
	    handy = {times={[1]=creative_digtime,[2]=creative_digtime,[3]=creative_digtime}, uses=0, maxlevel=1},
	    oddly_breakable_by_hand = {times={[1]=creative_digtime,[2]=creative_digtime,[3]=creative_digtime}, uses=0, maxlevel=3},
	    dig_immediate = {times={[2]=math.min(creative_digtime, 0.5), [3]=0}, uses=0, maxlevel=1},
	 },
	 range = 20,
	 damage_groups = {fleshy = 1}
      },
      groups = { no_item_drop = 1 },
})

-- Pickaxes

minetest.register_tool(
   "default:pick_wood",
   {
      description = S("Wooden Pickaxe"),
      inventory_image = "default_pick_wood.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    cracky={times=tool_levels.wood.cracky, uses=10, maxlevel=1}
	 },
	 damage_groups = {fleshy = 2}
      },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "default:pick_stone",
   {
      description = S("Stone Pickaxe"),
      inventory_image = "default_pick_stone.png",
      tool_capabilities = {
	 max_drop_level = 0,
	 groupcaps = {
	    cracky = {times = tool_levels.stone.cracky, uses = 20, maxlevel = 1}
	 },
	 damage_groups = {fleshy = 3}
      },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "default:pick_wrought_iron",
   {
      description = S("Wrought Iron Pickaxe"),
      inventory_image = "default_pick_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.wrought_iron.cracky, uses=15, maxlevel=2}
	 },
	 damage_groups = {fleshy = 4}
      },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "default:pick_steel",
   {
      description = S("Steel Pickaxe"),
      inventory_image = "default_pick_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.steel.cracky, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "default:pick_carbon_steel",
   {
      description = S("Carbon Steel Pickaxe"),
      inventory_image = "default_pick_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.carbon_steel.cracky, uses=40, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "default:pick_bronze",
   {
      description = S("Bronze Pickaxe"),
      inventory_image = "default_pick_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.bronze.cracky, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { pickaxe = 1 },
})

-- Shovels

minetest.register_tool(
   "default:shovel_wood",
   {
      description = S("Wooden Shovel"),
      inventory_image = "default_shovel_wood.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    crumbly={times=tool_levels.wood.crumbly, uses=10, maxlevel=1}
	 },
	 damage_groups = {fleshy = 2}
      },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "default:shovel_stone",
   {
      description = S("Stone Shovel"),
      inventory_image = "default_shovel_stone.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    crumbly={times=tool_levels.stone.crumbly, uses=20, maxlevel=1}
	 },
	 damage_groups = {fleshy = 3}
      },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "default:shovel_wrought_iron",
   {
      description = S("Wrought Iron Shovel"),
      inventory_image = "default_shovel_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.wrought_iron.crumbly, uses=15, maxlevel=2}
	 },
	 damage_groups = {fleshy = 4}
      },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "default:shovel_steel",
   {
      description = S("Steel Shovel"),
      inventory_image = "default_shovel_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.steel.crumbly, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "default:shovel_carbon_steel",
   {
      description = S("Carbon Steel Shovel"),
      inventory_image = "default_shovel_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.carbon_steel.crumbly, uses=40, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "default:shovel_bronze",
   {
      description = S("Bronze Shovel"),
      inventory_image = "default_shovel_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.bronze.crumbly, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { shovel = 1 },
})

-- Axes

minetest.register_tool(
   "default:axe_wood",
   {
      description = S("Wooden Axe"),
      inventory_image = "default_axe_wood.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    choppy={times=tool_levels.wood.choppy, uses=10, maxlevel=1},
	    fleshy={times={[2]=1.20, [3]=0.60}, uses=20, maxlevel=1}
	 },
	 damage_groups = {fleshy = 3}
      },
      groups = { axe = 1 },
})

minetest.register_tool(
   "default:axe_stone",
   {
      description = S("Stone Axe"),
      inventory_image = "default_axe_stone.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    choppy={times=tool_levels.stone.choppy, uses=20, maxlevel=1},
	    fleshy={times={[2]=1.10, [3]=0.40}, uses=25, maxlevel=1}
	 },
	 damage_groups = {fleshy = 4}
      },
      groups = { axe = 1 },
})

minetest.register_tool(
   "default:axe_wrought_iron",
   {
      description = S("Wrought Iron Axe"),
      inventory_image = "default_axe_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.wrought_iron.choppy, uses=15, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=30, maxlevel=1}
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { axe = 1 },
})

minetest.register_tool(
   "default:axe_steel",
   {
      description = S("Steel Axe"),
      inventory_image = "default_axe_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.steel.choppy, uses=30, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=35, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      groups = { axe = 1 },
})

minetest.register_tool(
   "default:axe_carbon_steel",
   {
      description = S("Carbon Steel Axe"),
      inventory_image = "default_axe_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.carbon_steel.choppy, uses=40, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=40, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      groups = { axe = 1 },
})

minetest.register_tool(
   "default:axe_bronze",
   {
      description = S("Bronze Axe"),
      inventory_image = "default_axe_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.bronze.choppy, uses=30, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=40, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      groups = { axe = 1 },
})

-- Spears

minetest.register_tool(
   "default:spear_wood",
   {
      description = S("Wooden Spear"),
      inventory_image = "default_spear_wood.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=0,
	 groupcaps={
	    fleshy={times={[2]=1.10, [3]=0.60}, uses=10, maxlevel=1},
	 },
	 damage_groups = {fleshy = 4}
      },
      groups = { spear = 1 },
})

minetest.register_tool(
   "default:spear_stone",
   {
      description = S("Stone Spear"),
      inventory_image = "default_spear_stone.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=0,
	 groupcaps={
	    fleshy={times={[2]=0.80, [3]=0.40}, uses=20, maxlevel=1},
	 },
	 damage_groups = {fleshy = 5}
      },
      groups = { spear = 1 },
})

minetest.register_tool(
   "default:spear_wrought_iron",
   {
      description = S("Wrought Iron Spear"),
      inventory_image = "default_spear_wrought_iron.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=15, maxlevel=2},
	 },
	 damage_groups = {fleshy = 6}
      },
      groups = { spear = 1 },
})

minetest.register_tool(
   "default:spear_steel",
   {
      description = S("Steel Spear"),
      inventory_image = "default_spear_steel.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=30, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      groups = { spear = 1 },
})

minetest.register_tool(
   "default:spear_carbon_steel",
   {
      description = S("Carbon Steel Spear"),
      inventory_image = "default_spear_carbon_steel.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=40, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      groups = { spear = 1 },
})

minetest.register_tool(
   "default:spear_bronze",
   {
      description = S("Bronze Spear"),
      inventory_image = "default_spear_bronze.png",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=30, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      groups = { spear = 1 },
})

-- Broadsword

minetest.register_tool(
   "default:broadsword",
   {
      description = S("Broadsword"),
      inventory_image = "default_broadsword.png",
      wield_image = "default_broadsword.png",
      wield_scale = {x = 2.0, y = 2.0, z = 1.0},
      tool_capabilities = {
	 full_punch_interval = 4.0,
	 damage_groups = {fleshy = 12}
      },
      groups = { sword = 1 },
})

-- Other

minetest.register_tool(
   "default:shears",
   {
      description = S("Wrought Iron Shears"),
      inventory_image = "default_shears.png",
      groups = { shears = 1, sheep_cuts = 100 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.wrought_iron.snappy, uses=15, maxlevel=1},
         },
      },
})
minetest.register_tool(
   "default:shears_steel",
   {
      description = S("Steel Shears"),
      inventory_image = "default_shears_steel.png",
      groups = { shears = 1, sheep_cuts = 200 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.steel.snappy, uses=30, maxlevel=1},
         },
      },
})
minetest.register_tool(
   "default:shears_carbon_steel",
   {
      description = S("Carbon Steel Shears"),
      inventory_image = "default_shears_carbon_steel.png",
      groups = { shears = 1, sheep_cuts = 266 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.carbon_steel.snappy, uses=40, maxlevel=1},
         },
      },
})
minetest.register_tool(
   "default:shears_bronze",
   {
      description = S("Bronze Shears"),
      inventory_image = "default_shears_bronze.png",
      groups = { shears = 1, sheep_cuts = 200 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.bronze.snappy, uses=30, maxlevel=1},
         },
      },
})

minetest.register_tool(
   "default:flint_and_steel",
   {
      description = S("Flint and Steel"),
      inventory_image = "default_flint_and_steel.png",
      on_use = function(itemstack, user, pointed_thing)
         if pointed_thing == nil then return end
         if pointed_thing.type ~= "node" then return end

         local pos = pointed_thing.under
         if minetest.is_protected(pos, user:get_player_name()) and
                 not minetest.check_player_privs(user, "protection_bypass") then
             minetest.record_protection_violation(pos, user:get_player_name())
             return itemstack
         end

         local node = minetest.get_node(pos)
         local nodename = node.name

         if nodename == "default:torch_weak" then
            minetest.set_node(
               pos,
               {
                  name = "default:torch",
                  param = node.param,
                  param2 = node.param2
            })

            if not minetest.settings:get_bool("creative_mode") then
                itemstack:add_wear(800)
            end
         elseif nodename == "default:torch_dead" then
            minetest.set_node(
               pos,
               {
                  name = "default:torch_weak",
                  param = node.param,
                  param2 = node.param2
            })

            if not minetest.settings:get_bool("creative_mode") then
                itemstack:add_wear(800)
            end
         elseif nodename == "tnt:tnt" then
            local y = minetest.registered_nodes["tnt:tnt"]
            if y ~= nil then
               y.on_punch(pos, node, user)

               if not minetest.settings:get_bool("creative_mode") then
                   itemstack:add_wear(800)
               end
            end
         end

         return itemstack
      end,
})

default.log("tools", "loaded")
