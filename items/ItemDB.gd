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
	"blue stone": {
		"name": "Blue Stone",
		"tags": [],
		"desc": "Blue Boy",
		"icon": ICON_PATH + "blue_stone.png",
		"size": Vector2(2,1),
		"targets": "none",
		"values":{
		},
		"bars":{
		},
	},
	"clay shards": {
		"name": "Clay Shards",
		"tags": [],
		"desc": "clay blockies",
		"icon": ICON_PATH + "clay_shards.png",
		"size": Vector2(2,1),
		"targets": "none",
		"values":{
		},
		"bars":{
		},
	},
	"rough stone": {
		"name": "Rough Stone",
		"tags": [],
		"desc": "lil stone",
		"icon": ICON_PATH + "rough_stone.png",
		"size": Vector2(2,1),
		"targets": "none",
		"values":{
		},
		"bars":{
		},
	},
	"burn powder": {
		"name": "Burn Powder",
		"tags": [],
		"desc": "Really just gunpowder",
		"icon": ICON_PATH + "burn_powder.png",
		"size": Vector2(2,1),
		"targets": "none",
		"values":{
		},
		"bars":{
		},
	},
	"shimmering twig": {
		"name": "Shimmering Twig",
		"tags": [],
		"desc": "shimmer twig",
		"icon": ICON_PATH + "shimmering_twig.png",
		"size": Vector2(2,1),
		"targets": "none",
		"values":{
		},
		"bars":{
		},
	},
	"burn cream": {
		"name": "Burn Cream",
		"tags": [],
		"desc": "Burn cream will remove 5 stacks of burn",
		"icon": ICON_PATH + "burn_cream.png",
		"size": Vector2(2,1),
		"targets": "single",
		"values":{
			"unburn" : 5
		},
		"bars":{
		},
	},
	"cool leaf": {
		"name": "Cool Leaf",
		"tags": ["base"],
		"desc": "omg its a blue leaf",
		"icon": ICON_PATH + "cool_leaf.png",
		"size": Vector2(1,1),
		"targets": "none",
		"values":{
			"heal" : 1
		},
		"bars":{
		},
	},
	"focus potion": {
		"name": "Focus Potion",
		"tags": [],
		"desc": "gimme that 2 focus",
		"icon": ICON_PATH + "focus_potion.png",
		"size": Vector2(1,2),
		"targets": "player",
		"values":{
			"focus" : 2
		},
		"bars":{
		},
	},
	"gel": {
		"name": "Gel",
		"tags": ["base"],
		"desc": "gelly bois",
		"icon": ICON_PATH + "gel.png",
		"size": Vector2(1,1),
		"targets": "none",
		"values":{
			"heal" : 1
		},
		"bars":{
		},
	},
	"flask": {
		"name": "The Flask",
		"tags": ["relic", "container"],
		"desc": "The beginning",
		"icon": ICON_PATH + "flask.png",
		"size": Vector2(2,3),
		"targets": "player",
		"values":{
			"heal" : 1,
			"stacks" : 1
		},
		"bars":{
		},
	},
	"fools gold": {
		"name": "Fool's Gold",
		"tags": ["relic"],
		"ability": "fools_gold",
		"desc": "This small golden rock has, for generations, been confused for gold, leading would be thieves to their doom. What is thought to be a lump of treasure, happens to be a thunderstone, capable of reducing those that make contact with it to ash. Hence it's name 'fools gold'.",
		"icon": ICON_PATH + "fools_gold.png",
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
	item.texture_rotate = load(get_item(item_id)["icon"].replace(".png", "_rotate.png"))
	item.targets = get_item(item_id)["targets"]
	if item.tags.has("container"):
		item.add_to_group("container")
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


