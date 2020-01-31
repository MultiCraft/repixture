--
-- Jeweled tool defs
--

local S = minetest.get_translator("jewels")

--  Automatic jeweling on specific tools

-- Adjectives:
-- * Swift: lower dig speed
-- * Harming: more damage
-- * Durable: more uses
-- * Ranged: higher range

local tool_types = {
   pick = {
      steel = {
         digspeed = {
            description = S("Swift Jewel Steel Pickaxe"),
            digspeed = -0.1,
         },
         damage = {
            description = S("Harming Jewel Steel Pickaxe"),
            fleshy = 1,
         },
         uses = {
            description = S("Durable Jewel Steel Pickaxe"),
            uses = 3,
         },
      },
      carbon_steel = {
         digspeed = {
            description = S("Swift Jewel Carbon Steel Pickaxe"),
            digspeed = -0.13,
         },
         damage = {
            description = S("Harming Jewel Carbon Steel Pickaxe"),
            fleshy = 2,
         },
         uses = {
            description = S("Durable Jewel Carbon Steel Pickaxe"),
            uses = 5,
         },
      },
      bronze = {
         digspeed = {
            description = S("Swift Jewel Bronze Pickaxe"),
            digspeed = -0.14,
         },
         damage = {
            description = S("Harming Jewel Bronze Pickaxe"),
            fleshy = 3,
         },
         uses = {
            description = S("Durable Jewel Bronze Pickaxe"),
            uses = 6,
         },
      },
   },
   shovel = {
      steel = {
         digspeed = {
            description = S("Swift Jewel Steel Shovel"),
            digspeed = -0.1,
         },
         damage = {
            description = S("Harming Jewel Steel Shovel"),
            fleshy = 1,
         },
         uses = {
            description = S("Durable Jewel Steel Shovel"),
            uses = 3,
         },
      },
      carbon_steel = {
         digspeed = {
            description = S("Swift Jewel Carbon Steel Shovel"),
            digspeed = -0.13,
         },
         damage = {
            description = S("Harming Jewel Carbon Steel Shovel"),
            fleshy = 2,
         },
         uses = {
            description = S("Durable Jewel Carbon Steel Shovel"),
            uses = 5,
         },
      },
      bronze = {
         digspeed = {
            description = S("Swift Jewel Bronze Shovel"),
            digspeed = -0.14,
         },
         damage = {
            description = S("Harming Jewel Bronze Shovel"),
            fleshy = 3,
         },
         uses = {
            description = S("Durable Jewel Bronze Shovel"),
            uses = 6,
         },
      },
   },
   axe = {
      steel = {
         digspeed = {
            description = S("Swift Jewel Steel Axe"),
            digspeed = -0.1,
         },
         damage = {
            description = S("Harming Jewel Steel Axe"),
            fleshy = 2,
         },
         uses = {
            description = S("Durable Jewel Steel Axe"),
            uses = 3,
         },
      },
      carbon_steel = {
         digspeed = {
            description = S("Swift Jewel Carbon Steel Axe"),
            digspeed = -0.13,
         },
         damage = {
            description = S("Harming Jewel Carbon Steel Axe"),
            fleshy = 3,
         },
         uses = {
            description = S("Durable Jewel Carbon Steel Axe"),
            uses = 5,
         },
      },
      bronze = {
         digspeed = {
            description = S("Swift Jewel Bronze Axe"),
            digspeed = -0.14,
         },
         damage = {
            description = S("Harming Jewel Bronze Axe"),
            fleshy = 4,
         },
         uses = {
            description = S("Durable Jewel Bronze Axe"),
            uses = 6,
         },
      },
   },
   spear = {
      steel = {
         reach = {
            overlay = "jewels_jeweled_spear_reach.png",
            overlay_wield = "jewels_jeweled_spear_reach.png^[transformR90",
            description = S("Extended Jewel Steel Spear"),
            range = 1,
         },
         damage = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Harming Jewel Steel Spear"),
            fleshy = 3,
         },
         uses = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Durable Jewel Steel Spear"),
            uses = 3,
         },
      },
      carbon_steel = {
         reach = {
            description = S("Extended Jewel Carbon Steel Spear"),
            overlay = "jewels_jeweled_spear_reach.png",
            overlay_wield = "jewels_jeweled_spear_reach.png^[transformR90",
            range = 2,
         },
         damage = {
            description = S("Harming Jewel Carbon Steel Spear"),
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            fleshy = 4,
         },
         uses = {
            description = S("Durable Jewel Carbon Steel Spear"),
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            uses = 5,
         },
      },
      bronze = {
         reach = {
            description = S("Extended Jewel Bronze Spear"),
            overlay = "jewels_jeweled_spear_reach.png",
            overlay_wield = "jewels_jeweled_spear_reach.png^[transformR90",
            range = 2,
         },
         damage = {
            description = S("Harming Jewel Bronze Spear"),
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            fleshy = 5,
         },
         uses = {
            description = S("Durable Jewel Bronze Spear"),
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            uses = 6,
         },
      },
   },
   shears = {
      steel = {
         digspeed = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Swift Jewel Steel Shears"),
            digspeed = -0.1,
         },
         uses = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Durable Jewel Steel Shears"),
            uses = 3,
         },
      },
      carbon_steel = {
         digspeed = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Swift Jewel Carbon Steel Shears"),
            digspeed = -0.13,
         },
         uses = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Durable Jewel Carbon Steel Shears"),
            uses = 5,
         },
      },
      bronze = {
         digspeed = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Swift Jewel Bronze Shears"),
            digspeed = -0.14,
         },
         uses = {
            overlay_wield = "jewels_jeweled_handle.png^[transformR90",
            description = S("Durable Jewel Bronze Shears"),
            uses = 6,
         },
      },
   }
}

for tool_name, tool_def in pairs(tool_types) do
   for material_name, material_def in pairs(tool_def) do
      for jewel_name, jewel_def in pairs(material_def) do
         local description = jewel_def.description
         local overlay = jewel_def.overlay
         local overlay_wield = jewel_def.overlay_wield
         jewel_def.description = nil
         jewel_def.overlay = nil
         jewel_def.overlay_wield = nil
         jewels.register_jewel(
            "default:" .. tool_name .. "_" .. material_name,
            "jewels:" .. tool_name .. "_" .. material_name .. "_" .. jewel_name,
            {
               stats = jewel_def,
               description = description,
               overlay = overlay,
               overlay_wield = overlay_wield,
            }
         )
      end
   end
end

-- Broadswords

jewels.register_jewel(
   "default:broadsword",
   "jewels:broadsword_jeweled_pommel",
   {
      description = S("Pommel Jewel Broadsword"),
      overlay = "jewels_jeweled_pommel.png",
      stats = {
	 fleshy = 2,
      }
})

jewels.register_jewel(
   "jewels:broadsword_jeweled_pommel",
   "jewels:broadsword_jeweled_pommel_and_guard",
   {
      description = S("Pommel&Guard Jewel Broadsword"),
      overlay = "jewels_jeweled_guard.png",
      stats = {
	 range = 1,
      }
})

jewels.register_jewel(
   "jewels:broadsword_jeweled_pommel_and_guard",
   "jewels:serrated_broadsword",
   {
      description = S("Serrated Jewel Broadsword"),
      overlay = "jewels_jeweled_blade.png",
      stats = {
	 fleshy = 2,
	 range = 1,
      }
})

default.log("jewels", "loaded")
