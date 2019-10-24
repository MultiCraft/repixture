--
-- Jeweled tool defs
--

local S = minetest.get_translator("jewels")

--  Automatic jeweling on specific tools

local tool_types = {
   pick = {
      steel = {
         description = S("Jeweled Steel Pickaxe"),
         digspeed = {
            digspeed = -0.1,
         },
         damage = {
            fleshy = 1,
         },
         uses = {
            uses = 3,
         },
      },
      carbon_steel = {
         description = S("Jeweled Carbon Steel Pickaxe"),
         digspeed = {
            digspeed = -0.13,
         },
         damage = {
            fleshy = 2,
         },
         uses = {
            uses = 5,
         },
      },
      bronze = {
         description = S("Jeweled Bronze Pickaxe"),
         digspeed = {
            digspeed = -0.14,
         },
         damage = {
            fleshy = 3,
         },
         uses = {
            uses = 6,
         },
      },
   },
   shovel = {
      steel = {
         description = S("Jeweled Steel Shovel"),
         digspeed = {
            digspeed = -0.1,
         },
         damage = {
            fleshy = 1,
         },
         uses = {
            uses = 3,
         },
      },
      carbon_steel = {
         description = S("Jeweled Carbon Steel Shovel"),
         digspeed = {
            digspeed = -0.13,
         },
         damage = {
            fleshy = 2,
         },
         uses = {
            uses = 5,
         },
      },
      bronze = {
         description = S("Jeweled Bronze Shovel"),
         digspeed = {
            digspeed = -0.14,
         },
         damage = {
            fleshy = 3,
         },
         uses = {
            uses = 6,
         },
      },
   },
   axe = {
      steel = {
         description = S("Jeweled Steel Axe"),
         digspeed = {
            digspeed = -0.1,
         },
         damage = {
            fleshy = 2,
         },
         uses = {
            uses = 3,
         },
      },
      carbon_steel = {
         description = S("Jeweled Carbon Steel Axe"),
         digspeed = {
            digspeed = -0.13,
         },
         damage = {
            fleshy = 3,
         },
         uses = {
            uses = 5,
         },
      },
      bronze = {
         description = S("Jeweled Bronze Axe"),
         digspeed = {
            digspeed = -0.14,
         },
         damage = {
            fleshy = 4,
         },
         uses = {
            uses = 6,
         },
      },
   },
   spear = {
      steel = {
         description = S("Jeweled Steel Spear"),
         reach = {
            range = 1,
         },
         damage = {
            fleshy = 3,
         },
         uses = {
            uses = 3,
         },
      },
      carbon_steel = {
         description = S("Jeweled Carbon Steel Spear"),
         reach = {
            range = 2,
         },
         damage = {
            fleshy = 4,
         },
         uses = {
            uses = 5,
         },
      },
      bronze = {
         description = S("Jeweled Bronze Spear"),
         reach = {
            range = 2,
         },
         damage = {
            fleshy = 5,
         },
         uses = {
            uses = 6,
         },
      },
   },
   shears = {
      steel = {
         description = S("Jeweled Steel Shears"),
         digspeed = {
            digspeed = -0.1,
         },
         uses = {
            uses = 3,
         },
      },
      carbon_steel = {
         description = S("Jeweled Carbon Steel Shears"),
         digspeed = {
            digspeed = -0.13,
         },
         uses = {
            uses = 5,
         },
      },
      bronze = {
         description = S("Jeweled Bronze Shears"),
         digspeed = {
            digspeed = -0.14,
         },
         uses = {
            uses = 6,
         },
      },
   }
}

for tool_name, tool_def in pairs(tool_types) do
   for material_name, material_def in pairs(tool_def) do
      for jewel_name, jewel_def in pairs(material_def) do
         if jewel_name ~= "description" then
            jewels.register_jewel(
               "default:" .. tool_name .. "_" .. material_name,
               "jewels:" .. tool_name .. "_" .. material_name .. "_" .. jewel_name,
               {
                  stats = jewel_def,
                  description = material_def.description,
               }
            )
         end
      end
   end
end

-- Broadswords

jewels.register_jewel(
   "default:broadsword",
   "jewels:broadsword_jeweled_pommel",
   {
      description = S("Jeweled Pommel Broadsword"),
      overlay = "jewels_jeweled_pommel.png",
      stats = {
	 fleshy = 2,
      }
})

jewels.register_jewel(
   "jewels:broadsword_jeweled_pommel",
   "jewels:broadsword_jeweled_pommel_and_guard",
   {
      description = S("Jeweled Pommel&Guard Broadsword"),
      overlay = "jewels_jeweled_guard.png",
      stats = {
	 range = 1,
      }
})

jewels.register_jewel(
   "jewels:broadsword_jeweled_pommel_and_guard",
   "jewels:serrated_broadsword",
   {
      description = S("Serrated Broadsword"),
      overlay = "jewels_jeweled_blade.png",
      stats = {
	 fleshy = 2,
	 range = 1,
      }
})

default.log("jewels", "loaded")
