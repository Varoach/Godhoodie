extends Node

signal item_added(item)

var cell_size
var rect_scale

const custom_item = preload("res://items/custom_item.tscn")

const ICON_PATH = "res://assets/items/"

const ITEMS = {
	"potion": {
		"name": "Potion",
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
		"name": "Fish",
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
		"name": "Kunai",
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

func pickup_item(item_id):
	var item = item_setup(item_id)
	Inventory.add_item(item_id)
	emit_signal("item_added" , item)

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]

func item_setup(item_id):
	var item = custom_item.instance()
	item.set_meta("id", item_id)
	item.title = item_id
	item.set_texture(load(get_item(item_id)["icon"]))
	item.texture_original = load(get_item(item_id)["icon"])
	item.texture_rotate = load(get_item(item_id)["icon_rotate"])
	item.targets = get_item(item_id)["targets"]
	item.bars = get_item(item_id)["bars"]
	item.size = get_item(item_id)["size"]
	if get_item(item_id).has("values"):
		item.values = get_item(item_id)["values"]
	item.save_animation_state()
	return item
