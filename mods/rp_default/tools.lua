
--
-- Tool definitions
--

local S = minetest.get_translator("rp_default")

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
	 wield_scale = {x=1.0,y=1.0,z=3.0},
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
   "rp_default:creative_tool",
   {
      description = S("Creative Tool"),
      _tt_help = S("Can dig (nearly) every block"),
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

local tt_pick = S("Digs hard, cracky blocks")
local tt_shovel = S("Digs soft, crumbly blocks")
local tt_axe = S("Chops wood")
local tt_spear = S("Melee weapon")
local tt_shears = S("Cuts leaves and plants and shears sheep")

-- Pickaxes

minetest.register_tool(
   "rp_default:pick_wood",
   {
      description = S("Wooden Pickaxe"),
      _tt_help = tt_pick,
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
   "rp_default:pick_stone",
   {
      description = S("Stone Pickaxe"),
      _tt_help = tt_pick,
      inventory_image = "default_pick_stone.png",
      tool_capabilities = {
	 max_drop_level = 0,
	 groupcaps = {
	    cracky = {times = tool_levels.stone.cracky, uses = 20, maxlevel = 1}
	 },
	 damage_groups = {fleshy = 3}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "rp_default:pick_wrought_iron",
   {
      description = S("Wrought Iron Pickaxe"),
      _tt_help = tt_pick,
      inventory_image = "default_pick_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.wrought_iron.cracky, uses=15, maxlevel=2}
	 },
	 damage_groups = {fleshy = 4}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "rp_default:pick_steel",
   {
      description = S("Steel Pickaxe"),
      _tt_help = tt_pick,
      inventory_image = "default_pick_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.steel.cracky, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "rp_default:pick_carbon_steel",
   {
      description = S("Carbon Steel Pickaxe"),
      _tt_help = tt_pick,
      inventory_image = "default_pick_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.carbon_steel.cracky, uses=40, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { pickaxe = 1 },
})

minetest.register_tool(
   "rp_default:pick_bronze",
   {
      description = S("Bronze Pickaxe"),
      _tt_help = tt_pick,
      inventory_image = "default_pick_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    cracky={times=tool_levels.bronze.cracky, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { pickaxe = 1 },
})

-- Shovels

minetest.register_tool(
   "rp_default:shovel_wood",
   {
      description = S("Wooden Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_wood.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    crumbly={times=tool_levels.wood.crumbly, uses=10, maxlevel=1}
	 },
	 damage_groups = {fleshy = 2}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "rp_default:shovel_stone",
   {
      description = S("Stone Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_stone.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    crumbly={times=tool_levels.stone.crumbly, uses=20, maxlevel=1}
	 },
	 damage_groups = {fleshy = 3}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "rp_default:shovel_wrought_iron",
   {
      description = S("Wrought Iron Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.wrought_iron.crumbly, uses=15, maxlevel=2}
	 },
	 damage_groups = {fleshy = 4}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "rp_default:shovel_steel",
   {
      description = S("Steel Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.steel.crumbly, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "rp_default:shovel_carbon_steel",
   {
      description = S("Carbon Steel Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.carbon_steel.crumbly, uses=40, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

minetest.register_tool(
   "rp_default:shovel_bronze",
   {
      description = S("Bronze Shovel"),
      _tt_help = tt_shovel,
      inventory_image = "default_shovel_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    crumbly={times=tool_levels.bronze.crumbly, uses=30, maxlevel=2}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { shovel = 1 },
})

-- Axes

minetest.register_tool(
   "rp_default:axe_wood",
   {
      description = S("Wooden Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_wood.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    choppy={times=tool_levels.wood.choppy, uses=10, maxlevel=1},
	    fleshy={times={[2]=1.20, [3]=0.60}, uses=20, maxlevel=1}
	 },
	 damage_groups = {fleshy = 3}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

minetest.register_tool(
   "rp_default:axe_stone",
   {
      description = S("Stone Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_stone.png",
      tool_capabilities = {
	 max_drop_level=0,
	 groupcaps={
	    choppy={times=tool_levels.stone.choppy, uses=20, maxlevel=1},
	    fleshy={times={[2]=1.10, [3]=0.40}, uses=25, maxlevel=1}
	 },
	 damage_groups = {fleshy = 4}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

minetest.register_tool(
   "rp_default:axe_wrought_iron",
   {
      description = S("Wrought Iron Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_wrought_iron.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.wrought_iron.choppy, uses=15, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=30, maxlevel=1}
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

minetest.register_tool(
   "rp_default:axe_steel",
   {
      description = S("Steel Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.steel.choppy, uses=30, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=35, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

minetest.register_tool(
   "rp_default:axe_carbon_steel",
   {
      description = S("Carbon Steel Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_carbon_steel.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.carbon_steel.choppy, uses=40, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=40, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

minetest.register_tool(
   "rp_default:axe_bronze",
   {
      description = S("Bronze Axe"),
      _tt_help = tt_axe,
      inventory_image = "default_axe_bronze.png",
      tool_capabilities = {
	 max_drop_level=1,
	 groupcaps={
	    choppy={times=tool_levels.bronze.choppy, uses=30, maxlevel=2},
	    fleshy={times={[2]=1.00, [3]=0.20}, uses=40, maxlevel=1}
	 },
	 damage_groups = {fleshy = 6}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { axe = 1 },
})

-- Spears

minetest.register_tool(
   "rp_default:spear_wood",
   {
      description = S("Wooden Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_wood.png",
      wield_image = "default_spear_wood.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=0,
	 groupcaps={
	    fleshy={times={[2]=1.10, [3]=0.60}, uses=10, maxlevel=1},
	 },
	 damage_groups = {fleshy = 4}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

minetest.register_tool(
   "rp_default:spear_stone",
   {
      description = S("Stone Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_stone.png",
      wield_image = "default_spear_stone.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=0,
	 groupcaps={
	    fleshy={times={[2]=0.80, [3]=0.40}, uses=20, maxlevel=1},
	 },
	 damage_groups = {fleshy = 5}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

minetest.register_tool(
   "rp_default:spear_wrought_iron",
   {
      description = S("Wrought Iron Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_wrought_iron.png",
      wield_image = "default_spear_wrought_iron.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=15, maxlevel=2},
	 },
	 damage_groups = {fleshy = 6}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

minetest.register_tool(
   "rp_default:spear_steel",
   {
      description = S("Steel Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_steel.png",
      wield_image = "default_spear_steel.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=30, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

minetest.register_tool(
   "rp_default:spear_carbon_steel",
   {
      description = S("Carbon Steel Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_carbon_steel.png",
      wield_image = "default_spear_carbon_steel.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=40, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

minetest.register_tool(
   "rp_default:spear_bronze",
   {
      description = S("Bronze Spear"),
      _tt_help = tt_spear,
      inventory_image = "default_spear_bronze.png",
      wield_image = "default_spear_bronze.png^[transformR90",
      tool_capabilities = {
	 full_punch_interval = 1.0,
	 max_drop_level=1,
	 groupcaps={
	    fleshy={times={[1]=2.00, [2]=0.80, [3]=0.40}, uses=30, maxlevel=2},
	 },
	 damage_groups = {fleshy = 10}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { spear = 1 },
})

-- Broadsword

minetest.register_tool(
   "rp_default:broadsword",
   {
      description = S("Broadsword"),
      _tt_help = S("A mighty melee weapon"),
      inventory_image = "default_broadsword.png",
      wield_image = "default_broadsword.png",
      wield_scale = {x = 2.0, y = 2.0, z = 1.0},
      tool_capabilities = {
	 full_punch_interval = 4.0,
	 damage_groups = {fleshy = 12}
      },
      sound = { breaks = "default_tool_breaks" },
      groups = { sword = 1 },
})

-- Other

local trim = function(itemstack, player, pointed_thing)
    if pointed_thing.type == "node" then
        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        local def = minetest.registered_nodes[node.name]
        if def and def._on_trim then
            if minetest.is_protected(pos, player:get_player_name()) and
                    not minetest.check_player_privs(player, "protection_bypass") then
                minetest.record_protection_violation(pos, player:get_player_name())
                return
            end
            return def._on_trim(pos, node, player, itemstack, pointed_thing)
        end
    end
end

minetest.register_tool(
   "rp_default:shears",
   {
      description = S("Wrought Iron Shears"),
      _tt_help = tt_shears,
      inventory_image = "default_shears.png",
      wield_image = "default_shears.png^[transformR90",
      sound = { breaks = "default_tool_breaks" },
      groups = { shears = 1, sheep_cuts = 100 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.wrought_iron.snappy, uses=15, maxlevel=1},
         },
      },
      on_place = trim,
})
minetest.register_tool(
   "rp_default:shears_steel",
   {
      description = S("Steel Shears"),
      _tt_help = tt_shears,
      inventory_image = "default_shears_steel.png",
      wield_image = "default_shears_steel.png^[transformR90",
      sound = { breaks = "default_tool_breaks" },
      groups = { shears = 1, sheep_cuts = 200 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.steel.snappy, uses=30, maxlevel=1},
         },
      },
      on_place = trim,
})
minetest.register_tool(
   "rp_default:shears_carbon_steel",
   {
      description = S("Carbon Steel Shears"),
      _tt_help = tt_shears,
      inventory_image = "default_shears_carbon_steel.png",
      wield_image = "default_shears_carbon_steel.png^[transformR90",
      sound = { breaks = "default_tool_breaks" },
      groups = { shears = 1, sheep_cuts = 266 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.carbon_steel.snappy, uses=40, maxlevel=1},
         },
      },
      on_place = trim,
})
minetest.register_tool(
   "rp_default:shears_bronze",
   {
      description = S("Bronze Shears"),
      _tt_help = tt_shears,
      inventory_image = "default_shears_bronze.png",
      wield_image = "default_shears_bronze.png^[transformR90",
      sound = { breaks = "default_tool_breaks" },
      groups = { shears = 1, sheep_cuts = 200 },
      tool_capabilities = {
	 full_punch_interval = 1.0,
         max_drop_level=1,
         groupcaps={
	    snappy={times=tool_levels.bronze.snappy, uses=30, maxlevel=1},
         },
      },
      on_place = trim,
})

local tt_flint_and_steel
if minetest.settings:get_bool("tnt_enable", true) then
   tt_flint_and_steel = S("Ignites TNT and lights up torches")
else
   tt_flint_and_steel = S("Lights up torches")
end

minetest.register_tool(
   "rp_default:flint_and_steel",
   {
      description = S("Flint and Steel"),
      _tt_help = tt_flint_and_steel,
      inventory_image = "default_flint_and_steel.png",
      sound = { breaks = "default_tool_breaks" },
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
         local wear = false

         if nodename == "rp_default:torch_weak" then
            minetest.set_node(
               pos,
               {
                  name = "rp_default:torch",
                  param = node.param,
                  param2 = node.param2
            })
            wear = true

         elseif nodename == "rp_default:torch_weak_wall" then
            minetest.set_node(
               pos,
               {
                  name = "rp_default:torch_wall",
                  param = node.param,
                  param2 = node.param2
            })
            wear = true

         elseif nodename == "rp_default:torch_dead" then
            minetest.set_node(
               pos,
               {
                  name = "rp_default:torch_weak",
                  param = node.param,
                  param2 = node.param2
            })
            wear = true

         elseif nodename == "rp_default:torch_dead_wall" then
            minetest.set_node(
               pos,
               {
                  name = "rp_default:torch_weak_wall",
                  param = node.param,
                  param2 = node.param2
            })
            wear = true

         elseif nodename == "tnt:tnt" then
            local y = minetest.registered_nodes["tnt:tnt"]
            if y ~= nil then
               y.on_punch(pos, node, user)
               wear = true
            end
         end

         if wear and not minetest.settings:get_bool("creative_mode") then
            itemstack:add_wear(800)
         end

         return itemstack
      end,
})

default.log("tools", "loaded")
