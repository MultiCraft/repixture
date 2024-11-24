local S = minetest.get_translator("rp_armor")

--[[----- ARMOR REGISTRATIONS -----]]

armor.register_armor_set("rp_armor", "wood", {
	craftitem = "group:planks",
	descriptions = { S("Wooden Helmet"), S("Wooden Chestplate"), S("Wooden Boots") },
	protections = 3,
	full_suit_bonus = 1,
	sound_equip = "rp_armor_equip_wood",
	sound_unequip = "rp_armor_unequip_wood",
	inventory_image_prefix = "armor",
})
armor.register_armor_set("rp_armor", "steel", {
	craftitem = "rp_default:ingot_steel",
	descriptions = { S("Steel Helmet"), S("Steel Chestplate"), S("Steel Boots") },
	protections = 6,
	full_suit_bonus = 2,
	sound_equip = "rp_armor_equip_metal",
	sound_unequip = "rp_armor_unequip_metal",
	sound_pitch = 0.90,
	inventory_image_prefix = "armor",
})
armor.register_armor_set("rp_armor", "chainmail", {
	craftitem = "rp_armor:chainmail_sheet",
	descriptions = { S("Chainmail Helmet"), S("Chainmail Chestplate"), S("Chainmail Boots") },
	protections = 10,
	full_suit_bonus = 3,
	sound_equip = "rp_armor_equip_chainmail",
	sound_unequip = "rp_armor_unequip_chainmail",
	inventory_image_prefix = "armor",
})
armor.register_armor_set("rp_armor", "carbon_steel", {
	craftitem = "rp_default:ingot_carbon_steel",
	descriptions = { S("Carbon Steel Helmet"), S("Carbon Steel Chestplate"), S("Carbon Steel Boots") },
	protections = 13,
	full_suit_bonus = 4,
	sound_equip = "rp_armor_equip_metal",
	sound_unequip = "rp_armor_unequip_metal",
	sound_pitch = 0.95,
	inventory_image_prefix = "armor",
})
armor.register_armor_set("rp_armor", "bronze", {
	craftitem = "rp_default:ingot_bronze",
	descriptions = { S("Bronze Helmet"), S("Bronze Chestplate"), S("Bronze Boots") },
	protections = 20,
	full_suit_bonus = 5,
	sound_equip = "rp_armor_equip_metal",
	sound_unequip = "rp_armor_unequip_metal",
	sound_pitch = 1.00,
	inventory_image_prefix = "armor",
})

-- Chainmail
minetest.register_craftitem("rp_armor:chainmail_sheet", {
	description = S("Chainmail Sheet"),
	inventory_image = "armor_chainmail.png",
	wield_image = "armor_chainmail.png",
	stack_max = 20,
})
crafting.register_craft({
	output = "rp_armor:chainmail_sheet 3",
	items = {
		"rp_default:ingot_steel 5",
	},
})

-- Wooden armor fuel recipes
minetest.register_craft({
	type = "fuel",
	recipe = "rp_armor:helmet_wood",
	burntime = 10
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_armor:chestplate_wood",
	burntime = 16
})
minetest.register_craft({
	type = "fuel",
	recipe = "rp_armor:boots_wood",
	burntime = 12
})

-- Armor-specific achievement

achievements.register_achievement("full_armor", {
-- REFERENCE ACHIEVEMENT 6
	title = S("Skin of Bronze"),
	description = S("Equip a full suit of bronze armor."),
	times = 1,
	icon = "rp_armor_achievement_full_armor.png",
	difficulty = 6,
})


