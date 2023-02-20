--[[ ORES ]]

local mg_name = minetest.get_mapgen_setting("mg_name")

-- Graphite ore

default.register_ore( -- Common above sea level mainly
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 9*9*9,
      clust_num_ores = 8,
      clust_size     = 8,
      y_min          = -8,
      y_max          = 32,
})

default.register_ore( -- Slight scattering deeper down
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_graphite",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 6,
      clust_size     = 8,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = -32,
})

-- Coal ore

default.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 10*10*10,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = 32,
})

default.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 8,
      y_min          = -40,
      y_max          = -32,
})

default.register_ore( -- Deep ore sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_coal",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 26,
      clust_size     = 12,
      y_min          = -130,
      y_max          = -120,
})

-- Iron ore

default.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 12*12*12,
      clust_num_ores = 4,
      clust_size     = 3,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = -8,
})

default.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 20,
      clust_size     = 12,
      y_min          = -32,
      y_max          = -24,
})

default.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_iron",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 17,
      clust_size     = 6,
      y_min          = -80,
      y_max          = -60,
})

-- Tin ore

default.register_ore( -- Even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 14*14*14,
      clust_num_ores = 8,
      clust_size     = 4,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = -100,
})

default.register_ore( -- Dense sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_tin",
      wherein        = "rp_default:stone",
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = -150,
      y_max          = -140,
})

-- Copper ore

default.register_ore( -- Begin sheet
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 6*6*6,
      clust_num_ores = 12,
      clust_size     = 5,
      y_min          = -90,
      y_max          = -80,
})

default.register_ore( -- Rare even distribution
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 13*13*13,
      clust_num_ores = 10,
      clust_size     = 5,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = -90,
})

default.register_ore( -- Large clusters
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_copper",
      wherein        = "rp_default:stone",
      clust_scarcity = 8*8*8,
      clust_num_ores = 22,
      clust_size     = 10,
      y_min          = -230,
      y_max          = -180,
})

-- Small gravel blobs
default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:gravel",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = default.GLOBAL_Y_MIN,
	y_max          = default.GLOBAL_Y_MAX,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 58943,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})

-- Small sand blobs
default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:sand",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 40,
	clust_size     = 4,
	y_min          = default.GLOBAL_Y_MIN,
	y_max          = default.GLOBAL_Y_MAX,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 38943,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})


-- Dirt, Dry Dirt and Swamp Dirt blobs.
-- These get generated depending on the biome.
-- The following code is to generate the list
-- of biomes that include either dirt, dry dirt or swamp dirt.

-- Returns a list of biomes that use the specified nodename
-- as its dirt blob, by using the data from
-- default.get_biome_info.
-- * nodename: A name of the node (a dirt node)
local get_dirt_biomes = function(nodename)
	local biomes = default.get_core_biomes()
	local out_biomes = {}
	for b=1, #biomes do
		local biome_info = default.get_biome_info(biomes[b])
		-- Add biome to list iff it uses the specified node as dirt blob
		if biome_info.dirt_blob ~= nil and biome_info.dirt_blob == nodename then
			table.insert(out_biomes, biomes[b])
		end
	end
	return out_biomes
end

local dirt_biomes = get_dirt_biomes("rp_default:dirt")
local dry_dirt_biomes = get_dirt_biomes("rp_default:dry_dirt")
local swamp_dirt_biomes = get_dirt_biomes("rp_default:swamp_dirt")

minetest.log("verbose", "[rp_default] List of builtin biomes with Dirt blobs: "..dump(dirt_biomes))
minetest.log("verbose", "[rp_default] List of builtin biomes with Dry Dirt blobs: "..dump(dry_dirt_biomes))
minetest.log("verbose", "[rp_default] List of builtin biomes with Swamp Dirt blobs: "..dump(swamp_dirt_biomes))

local np_dirtlike = {
	offset  = 0,
	scale   = 1,
	spread  = {x=150, y=150, z=150},
	seed    = 98943,
	octaves = 3,
	persist = 0.5,
	lacunarity = 2,
	flags = "defaults",
}

default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = default.GLOBAL_Y_MIN,
	y_max          = default.GLOBAL_Y_MAX,
	biomes         = dirt_biomes,
	noise_params   = np_dirtlike,
})

default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:dry_dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = default.GLOBAL_Y_MIN,
	y_max          = default.GLOBAL_Y_MAX,
	biomes         = dry_dirt_biomes,
	noise_params   = np_dirtlike,
})

default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:swamp_dirt",
	wherein        = "rp_default:stone",
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = default.GLOBAL_Y_MIN,
	y_max          = default.GLOBAL_Y_MAX,
	biomes         = swamp_dirt_biomes,
	noise_params   = np_dirtlike,
})


-- Liquid "ores"

local function spring_ore_np(seed)
	return {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = seed or 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
end


-- Water
default.register_ore( -- Springs
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Grassland", "Dense Grassland"},
      clust_scarcity = 26*26*26,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = 20,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(),
})

default.register_ore( -- Pools
   {
      ore_type       = "blob",
      ore            = "rp_default:water_source",
      wherein        = "rp_default:dirt_with_grass",
      biomes         = {"Wilderness"},
      clust_scarcity = 32*32*32,
      clust_num_ores = 20,
      clust_size     = 6,
      y_min          = 10,
      y_max          = 30,
      noise_params   = spring_ore_np(),
})

if mg_name ~= "v6" then

-- Swamp Water
default.register_ore( -- Swamp (big springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Mixed Swamp Highland", "Papyrus Swamp", "Swamp Forest", "Swamp Forest Highland", "Swamp Meadow", "Swamp Meadow Highland"},
      clust_scarcity = 7*7*7,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(13943),
})
default.register_ore( -- Swamp (medium springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Mixed Swamp Highland", "Papyrus Swamp", "Swamp Forest", "Swamp Forest Highland", "Swamp Meadow", "Swamp Meadow Highland"},
      clust_scarcity = 5*5*5,
      clust_num_ores = 8,
      clust_size     = 2,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(49494),
})

default.register_ore( -- Swamp (small springs)
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_swamp_grass", "rp_default:swamp_dirt"},
      biomes         = {"Mixed Swamp", "Mixed Swamp Highland", "Papyrus Swamp", "Swamp Forest", "Swamp Forest Highland", "Swamp Meadow", "Swamp Meadow Highland"},
      clust_scarcity = 6*6*6,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(59330),
})

default.register_ore( -- Marsh
   {
      ore_type       = "blob",
      ore            = "rp_default:swamp_water_source",
      wherein        = {"rp_default:dirt_with_grass", "rp_default:dirt"},
      biomes         = {"Marsh"},
      clust_scarcity = 8*8*8,
      clust_num_ores = 10,
      clust_size     = 6,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(),
})

-- Gravelly surface
default.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:gravel",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Rocky Dryland"},
      clust_scarcity = 8*8*8,
      clust_size     = 8,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 43400,
      },
})
default.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:stone",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Rocky Dryland"},
      clust_scarcity = 8*8*8,
      clust_size     = 7,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 13940,
      },
})


-- Landscape "ores"
default.register_ore( -- Dry Swamp (dirt with grass)
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt_with_grass",
      wherein        = {"rp_default:dirt_with_swamp_grass"},
      biomes         = {"Dry Swamp", "Dry Swamp Highland"},
      clust_scarcity = 3*3*3,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(13943),
})
default.register_ore( -- Dry Swamp (dirt)
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt",
      wherein        = {"rp_default:swamp_dirt"},
      biomes         = {"Dry Swamp", "Dry Swamp Beach", "Dry Swamp Highland"},
      clust_scarcity = 3*3*3,
      clust_num_ores = 10,
      clust_size     = 4,
      y_min          = default.GLOBAL_Y_MIN,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params   = spring_ore_np(13943),
})

default.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_default:dirt_with_dry_grass",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Savannic Wasteland"},
      clust_scarcity = 6*6*6,
      clust_size     = 6,
      clust_num_ores = 40,
      y_min          = 2,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 1,
	      scale = 1,
	      offset = 0.1,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 12449,
      },
})

default.register_ore(
   {
      ore_type       = "blob",
      ore            = "rp_default:dirt_with_dry_grass",
      wherein        = "rp_default:dry_dirt",
      biomes = {"Savannic Wasteland"},
      clust_scarcity = 7*7*7,
      clust_size     = 4,
      y_min          = 2,
      y_max          = default.GLOBAL_Y_MAX,
      noise_params = {
	      octaves = 2,
	      scale = 1,
	      offset = 0.2,
	      spread = { x = 100, y = 100, z = 100 },
	      lacunarity = 2.0,
	      persistence = 0.5,
	      seed = 12450,
      },
})

default.register_ore(
   {
      ore_type       = "scatter",
      ore            = "rp_default:stone_with_sulfur",
      wherein        = "rp_default:stone",
      biomes         = { "Rocky Dryland", "Wooded Dryland"},
      clust_scarcity = 9*9*9,
      clust_num_ores = 1,
      clust_size     = 1,
      y_min          = -8,
      y_max          = 32,
})

-- Underwater ground variations
default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:gravel",
	wherein        = {"rp_default:sand"},
	clust_scarcity = 10*10*10,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = default.UNDERGROUND_Y_MAX+1,
	y_max          = 0,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 39393,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})
default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:swamp_dirt",
	wherein        = {"rp_default:dirt"},
	biomes = { "Mixed Swamp Underwater", "Papyrus Swamp Underwater", "Swamp Forest Underwater", "Swamp Meadow Underwater", "Dry Swamp Underwater" },
	clust_scarcity = 8*8*8,
	clust_num_ores = 40,
	clust_size     = 5,
	y_min          = -30,
	y_max          = 0,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 39393,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})

default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:sand",
	wherein        = "rp_default:dirt",
	clust_scarcity = 10*10*10,
	clust_num_ores = 40,
	clust_size     = 4,
	y_min          = default.UNDERGROUND_Y_MAX+1,
	y_max          = 0,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 40440,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})
default.register_ore({
	ore_type       = "blob",
	ore            = "rp_default:dirt",
	wherein        = "rp_default:sand",
	clust_scarcity = 15*15*15,
	clust_num_ores = 40,
	clust_size     = 4,
	y_min          = default.UNDERGROUND_Y_MAX+1,
	y_max          = -3,
	noise_params   = {
		offset  = 0,
		scale   = 1,
		spread  = {x=150, y=150, z=150},
		seed    = 40440,
		octaves = 3,
		persist = 0.5,
		lacunarity = 2,
		flags = "defaults",
	},
})


end
