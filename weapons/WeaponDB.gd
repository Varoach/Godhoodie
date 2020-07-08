extends Node

signal weapon_added()

const custom_background = preload("res://weapons/weapon_background.tscn")
const custom_weapon = preload("res://weapons/custom_weapon.tscn")

const WEAPON_PATH = "res://weapons/"

const WEAPONS = {
		"wood sword": {
		"icon": WEAPON_PATH + "wood.png",
		"targets": "first",
		"rarity": "common",
		"values":{
			"attack" : 4
		},
		"bars":{
			"stamina" : 3
		}
	},
}

const BACKGROUNDS = {
	"basic": {
		"icon": WEAPON_PATH + "template.png",
		"icon_back": WEAPON_PATH + "common_back.png"
	},
	"common": {
		"icon": WEAPON_PATH + "common.png",
		"icon_back": WEAPON_PATH + "common_back.png"
	},
	"epic": {
		"icon": WEAPON_PATH + "epic.png",
		"icon_back": WEAPON_PATH + "common_back.png"
	},
	"legendary": {
		"icon": WEAPON_PATH + "legendary.png",
		"icon_back": WEAPON_PATH + "common_back.png"
	},
}

func pickup_weapon(weapon_id):
	if Inventory.player_inventory.weapons.size() == 3:
		return
	var weapon = whole_setup(weapon_id)
	Inventory.add_weapon(weapon_id)
	emit_signal("weapon_added")

func get_weapon(weapon_id):
	if weapon_id in WEAPONS:
		return WEAPONS[weapon_id]
	else:
		return null

func get_background(background_id):
	if background_id in BACKGROUNDS:
		return BACKGROUNDS[background_id]
	else:
		return null

func background_setup(background_id):
	var background = custom_background.instance()
	background.set_meta("id", background_id)
	background.texture_setup(load(get_background(background_id)["icon"]), load(get_background(background_id)["icon_back"]))
	return background

func weapon_setup(weapon_id):
	var weapon = custom_weapon.instance()
	weapon.set_meta("id", weapon_id)
	weapon.set_texture(load(get_weapon(weapon_id)["icon"]))
	weapon.name = weapon_id
	weapon.targets = get_weapon(weapon_id)["targets"]
	weapon.rarity = get_weapon(weapon_id)["rarity"]
	weapon.bars = get_weapon(weapon_id)["bars"]
	if get_weapon(weapon_id).has("values"):
		weapon.values = get_weapon(weapon_id)["values"]
	return weapon

func whole_setup(weapon_id):
	var weapon = weapon_setup(weapon_id)
	var background = background_setup(weapon.rarity)
	background.set_weapon(weapon)
	return background
