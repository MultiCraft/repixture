local S = minetest.get_translator("rp_spikes")

local SPIKES_PITCH_MODIFIER = 1.5

local make_metal_sounds = function(pitch)
	local sounds = rp_sounds.node_sound_metal_defaults()
	if not pitch then
		pitch = 1
	end
	pitch = pitch * SPIKES_PITCH_MODIFIER
	sounds.footstep = {}
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

local register_spikes = function(name, def)
	local disable_jump = 1
	if def.allow_jump then
		disable_jump = nil
	end
	local move_resistance = 4
	if def.move_resistance then
		move_resistance = def.move_resistance
	end
	local groups = { spikes = 1, disable_jump = disable_jump, attached_node = 1, cracky = 3, creative_decoblock = 1 }
	if def.groups_plus then
		for k,v in pairs(def.groups_plus) do
			groups[k] = v
		end
	end
	local spikedef = {
		description = def.description,
		drawtype = "plantlike",
		paramtype = "light",
		paramtype2 = "wallmounted",
		tiles = def.tiles,
		visual_scale = 1.45,
		walkable = false,
		inventory_image = def.image,
		wield_image = def.image,
		move_resistance = move_resistance,
		sunlight_propagates = false,
		is_ground_content = false,
		groups = groups,
		damage_per_second = def.damage_per_second,
		sounds = make_metal_sounds(def.pitch),
	}
	minetest.register_node(name, spikedef)

	if def.craftitem then
		crafting.register_craft({
			output = name,
			items = {
				def.craftitem .. " 5",
				"rp_default:stick 4",
				"rp_default:thistle",
			},
		})
	end
end

local mod_default = minetest.get_modpath("rp_default") ~= nil

register_spikes("rp_spikes:spikes_copper", {
	description = S("Copper Spikes"),
	tiles = { "rp_spikes_spikes_copper.png" },
	image = "rp_spikes_spikes_copper_inventory.png",
	damage_per_second = 2,
	craftitem = "rp_default:ingot_copper",
	pitch = mod_default and default.METAL_PITCH_COPPER,
})
register_spikes("rp_spikes:spikes_wrought_iron", {
	description = S("Wrought Iron Spikes"),
	tiles = { "rp_spikes_spikes_wrought_iron.png" },
	image = "rp_spikes_spikes_wrought_iron_inventory.png",
	damage_per_second = 3,
	craftitem = "rp_default:ingot_wrought_iron",
	groups_plus = { magnetic = 1 },
	pitch = mod_default and default.METAL_PITCH_WROUGHT_IRON,
})
register_spikes("rp_spikes:spikes_steel", {
	description = S("Steel Spikes"),
	tiles = { "rp_spikes_spikes_steel.png" },
	image = "rp_spikes_spikes_steel_inventory.png",
	damage_per_second = 4,
	craftitem = "rp_default:ingot_steel",
	pitch = mod_default and default.METAL_PITCH_STEEL,
})
register_spikes("rp_spikes:spikes_carbon_steel", {
	description = S("Carbon Steel Spikes"),
	tiles = { "rp_spikes_spikes_carbon_steel.png" },
	image = "rp_spikes_spikes_carbon_steel_inventory.png",
	damage_per_second = 5,
	craftitem = "rp_default:ingot_carbon_steel",
	pitch = mod_default and default.METAL_PITCH_CARBON_STEEL,
})
register_spikes("rp_spikes:spikes_bronze", {
	description = S("Bronze Spikes"),
	tiles = { "rp_spikes_spikes_bronze.png" },
	image = "rp_spikes_spikes_bronze_inventory.png",
	damage_per_second = 6,
	craftitem = "rp_default:ingot_bronze",
	pitch = mod_default and default.METAL_PITCH_BRONZE,
})

