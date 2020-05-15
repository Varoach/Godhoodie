extends Node

const WEAPON_PATH = "res://addons/card_engine/demo/weapons/"

const WEAPONS = {
		"wood": {
		"icon": WEAPON_PATH + "wood.png",
		"targets": "single",
		"rarity": "basic",
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
	}
}

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
