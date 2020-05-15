extends Node

const ICON_PATH = "res://addons/card_engine/demo/assets/items/"

const ITEMS = {
	"potion": {
		"icon": ICON_PATH + "potion.png",
		"icon_rotate": ICON_PATH + "potion_rotate.png",
		"size": Vector2(2,4),
		"targets": "single",
		"values":{
			"heal" : 8
		},
		"bars":{
		}
	},
	"fish": {
		"icon": ICON_PATH + "fish.png",
		"icon_rotate": ICON_PATH + "fish_rotate.png",
		"size": Vector2(2,5),
		"targets": "single",
		"values":{
			"heal" : 4
		},
		"bars":{
		}
	},
	"kunai": {
		"icon": ICON_PATH + "kunai.png",
		"icon_rotate": ICON_PATH + "kunai_rotate.png",
		"size": Vector2(1,3),
		"targets": "single",
		"values":{
			"attack" : 5
		},
		"bars":{
			"stamina" : 1
		}
	},
	"error": {
		"icon": ICON_PATH + "error.png"
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
