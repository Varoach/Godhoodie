extends Node

signal item_added(item)

var cell_size
var rect_scale
var fools_gold_ref = funcref(Relics, "fools_gold")
var electric_rune_ref = funcref(Trinkets, "electric_rune")

const custom_item = preload("res://items/custom_item.tscn")

const custom_trinket = preload("res://trinkets/trinket_script.tscn")

const ICON_PATH = "res://assets/items/"

const ITEMS = {
	"potion": {
		"name": "Potion",
		"tags": [],
		"desc": "Surprise in a bottle",
		"icon": ICON_PATH + "potion.png",
		"icon_rotate": ICON_PATH + "potion_rotate.png",
		"size": Vector2(2,4),
		"targets": "single",
		"values":{
			"heal" : 8
		},
		"bars":{
		},
	},
	"fish": {
		"name": "Fish",
		"tags": [],
		"desc": "It's just a fish",
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
		"tags": [],
		"desc": "Throw it at people and see what happens",
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
	"fools gold": {
		"name": "Fool's Gold",
		"tags": [],
		"ability": "fools_gold",
		"desc": "This small golden rock has, for generations, been confused for gold, leading would be thieves to their doom. What is thought to be a lump of treasure, happens to be a thunderstone, capable of reducing those that make contact with it to ash. Hence it's name 'fools gold'.",
		"icon": ICON_PATH + "fools_gold.png",
		"icon_rotate": ICON_PATH + "fools_gold_rotate.png",
		"size": Vector2(3,3),
		"targets": "none",
	},
	"electric rune": {
		"name": "Electric Rune",
		"buffs": {
			"lightning" : 1,
		},
		"tags": ["trinket"],
		"desc": "Lock it and Sock-et",
		"icon": ICON_PATH + "electric_rune.png",
		"icon_rotate": ICON_PATH + "electric_rune_rotate.png",
		"size": Vector2(2,2),
		"targets": "none",
	},
	"error": {
		"icon": ICON_PATH + "error.png"
	}
}

func pickup_item(item_id):
	Inventory.add_item(item_id)
	var item = item_setup(item_id)
	emit_signal("item_added", item)

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]

func item_setup(item_id):
	var item = custom_item.instance()
	item.title = item_id
	item.real_title = get_item(item_id)["name"]
	item.desc = get_item(item_id)["desc"]
	item.tags = get_item(item_id)["tags"]
	item.set_texture(load(get_item(item_id)["icon"]))
	item.texture_original = load(get_item(item_id)["icon"])
	item.texture_rotate = load(get_item(item_id)["icon_rotate"])
	item.targets = get_item(item_id)["targets"]
	if get_item(item_id).has("anim_ready"):
		item.anim_ready = get_item(item_id)["anim_ready"]
	if get_item(item_id).has("anim_use"):
		item.anim_use = get_item(item_id)["anim_use"]
	if get_item(item_id).has("buffs"):
		item.buffs = get_item(item_id)["buffs"]
	if get_item(item_id).has("bars"):
		item.bars = get_item(item_id)["bars"]
	item.size = get_item(item_id)["size"]
	if get_item(item_id).has("values"):
		item.values = get_item(item_id)["values"]
	if get_item(item_id).has("ability"):
		item.ability = funcref(Relics, get_item(item_id)["ability"])
		item.ability.call_func()
	return item

func trinket_setup(trinket_id):
	var trinket = custom_trinket.instance()
	trinket.texture = load(get_item(trinket_id)["icon"])
	trinket.buffs = get_item(trinket_id)["buffs"]
	return trinket
