extends Node

signal spawn_item(item, position)

const custom_item = preload("res://items/custom_item.tscn")

const IMAGE_PATH = "res://assets/items/"
const SCRIPT_PATH = "res://items/scripts/"

var cell_size = 101.05
var rect_scale
var bases = []

const ITEMS = {
	"blue stone": {
		"name": "Blue Stone",
		"tags": ["base"],
		"desc": "Blue Boy.",
		"size": Vector2(2,1),
		"targets": "none",
		"values":
		{
		},
		"bars":{
		},
	},
	"clay shards": {
		"name": "Clay Shards",
		"tags": ["base"],
		"desc": "clay blockies.",
		"size": Vector2(2,1),
		"targets": "none",
		"values":
		{
		},
		"bars":{
		},
	},
	"rough stone": {
		"name": "Rough Stone",
		"tags": ["base"],
		"desc": "lil stone.",
		"size": Vector2(2,1),
		"targets": "none",
		"values":
		{
		},
		"bars":{
		},
	},
	"shimmering twig": {
		"name": "Shimmering Twig",
		"tags": ["base"],
		"desc": "shimmer twig.",
		"size": Vector2(2,1),
		"targets": "none",
		"values":
		{
		},
		"bars":{
		},
	},
	"burn cream": {
		"name": "Burn Cream",
		"tags": [],
		"desc": "Burn cream will remove 5 stacks of burn.",
		"size": Vector2(2,1),
		"targets": "single",
		"values":
		{
			"unburn" : 5
		},
		"bars":{
		},
	},
	"cool leaf": {
		"name": "Cool Leaf",
		"tags": ["base"],
		"desc": "omg its a blue leaf.",
		"size": Vector2(1,1),
		"targets": "none",
		"values":
		{
			"heal" : 1
		},
		"bars":{
		},
	},
	"focus potion": {
		"name": "Focus Potion",
		"tags": [],
		"desc": "Gimme that 2 focus.",
		"size": Vector2(1,2),
		"targets": "player",
		"values":
		{
			"focus" : 2
		},
		"bars":{
		},
	},
	"flask": {
		"name": "The Flask",
		"tags": ["relic", "container"],
		"desc": "The beginning.",
		"size": Vector2(2,3),
		"targets": "player",
		"stats":{
			"stacks" : 1
		},
		"values":{
			"heal" : 1
		},
		"labels":
			{
				"1" : "stacks"
			},
		"bars":{
		},
	},
	"fools gold": {
		"name": "Fool's Gold",
		"tags": ["relic"],
		"ability": "fools_gold",
		"desc": "This small golden rock has, for generations, been confused for gold, leading would be thieves to their doom. What is thought to be a lump of treasure, happens to be a thunderstone, capable of reducing those that make contact with it to ash. Hence it's name 'fools gold'.",
		"size": Vector2(3,3),
		"targets": "none",
	},
	"electric rune": {
		"name": "Electric Rune",
		"buffs": {
			"lightning" : 1,
		},
		"tags": ["trinket"],
		"desc": "Lock it and Sock-et.",
		"size": Vector2(2,2),
		"targets": "none",
	},
	"kunai": {
		"name": "Kunai",
		"tags": [],
		"desc": "Stabby stab.",
		"size": Vector2(1,2),
		"targets": "enemy",
		"values":
			{
				"attack" : 1,
			}
	},
	"liquid ambrosia": {
		"name": "Liquid Ambrosia",
		"tags": [],
		"desc": "Fully heals the player, replenishes that turns time, and resets all cooldowns.",
		"size": Vector2(2,2),
		"targets": "none",
		"values":
			{
				"heal" : "max",
			}
	},
	"rusty dagger": {
		"name": "Rusty Dagger",
		"tags": ["weapon"],
		"desc": "Stabby stab stab.",
		"size": Vector2(4,2),
		"targets": "enemy",
		"cost": {
			"energy" : 1,
		},
		"values":
			{
				"cut" : 1,
			}
	},
	"ice spear": {
		"name": "Ice Spear",
		"tags": ["weapon"],
		"desc": "Stabby stab stab.",
		"size": Vector2(6,2),
		"targets": "enemy",
		"cost": {
			"energy" : 2,
		},
		"values":
			{
				"cut" : 3,
				"ice" : 1
			}
	},
		"lady lucks comb": {
		"name": "Lady Luck's Comb",
		"tags": ["relic"],
		"desc": "Comby comb comb.",
		"size": Vector2(2,2),
	},
		"travelers cane": {
		"name": "Traveler's Cane",
		"tags": ["relic"],
		"desc": "Walky walk walk.",
		"size": Vector2(2,6),
	},
	"dune walker blade": {
		"name": "Dune Walker Blade",
		"tags": ["weapon"],
		"desc": "Stabby stab stab.",
		"size": Vector2(5,2),
		"targets": "enemy",
		"script": true,
		"cost": {
			"energy" : 2,
		},
		"values":
			{
				"sand" : 2,
			}
	},
	"sand trapper": {
		"name": "Sand Trapper",
		"tags": ["weapon"],
		"desc": "Shooty shoot shoot.",
		"size": Vector2(5,2),
		"targets": "enemy",
		"script": true,
		"cost": {
			"energy" : 2,
		},
		"values":
			{
				"sand" : 1,
			}
	},
	"gel": {
		"name": "Gel",
		"tags": ["base"],
		"desc": "Sticky stuff.",
		"size": Vector2(1,1),
		"targets": "none",
		"values":
		{
			"heal" : 1
		},
	},
	"fine ash": {
		"name": "Fine Ash",
		"tags": ["base"],
		"desc": "Really just gunpowder.",
		"size": Vector2(1,1),
		"targets": "none",
	},
	"blue safflina": {
		"name": "Blue Safflina",
		"tags": [],
		"desc": "Focus up.",
		"size": Vector2(1,2),
		"targets": "none",
		"ticks": 2,
		"values":
			{
				"focus" : 2,
			}
	},
	"weapon cleaning oil": {
		"name": "Weapon Cleaning Oil",
		"tags": [],
		"desc": "Clean dat shizz-nizz",
		"size": Vector2(2,2),
		"targets": "none",
		"values":
			{
				"durability" : 2,
			}
	},
	"error": {
		"icon": IMAGE_PATH + "error.png"
	}
}

func _ready():
	for item in ITEMS:
		if get_item(item).has("tags"):
			if get_item(item)["tags"].has("base"):
				bases.append(item)
	print(bases)

func spawn_item(item_id, position, random = true, grow = false):
	var item
	if item_id == "random":
		pass
	elif item_id == "random base":
		item = item_setup(bases[randi() % bases.size()])
	else:
		item = item_setup(item_id)
	item.random = random
	item.grow = grow
	emit_signal("spawn_item", item, position)
	for node in get_tree().get_nodes_in_group("items"):
		item.add_collision_exception_with(node)
	yield(get_tree().create_timer(0.6),"timeout")
	for node in get_tree().get_nodes_in_group("items"):
		item.remove_collision_exception_with(node)

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]

func get_image(item_id):
	var new_id = item_id.replacen(" ", "_")
	return load(IMAGE_PATH + new_id + ".png")

func get_image_back(item_id):
	var new_id = item_id.replacen(" ", "_")
	return load(IMAGE_PATH + new_id + "_back.png")

func script_set(item_id, item):
	var new_id = item_id.replacen(" ", "_")
	item.set_script(load(SCRIPT_PATH + new_id + ".gd"))

func item_setup(item_id):
	var item = custom_item.instance()
	if get_item(item_id).has("script"):
		if get_item(item_id)["script"]:
			script_set(item_id, item)
	item.title = get_item(item_id)["name"]
	item.real_title = item_id.replacen(" ", "_")
	item.tags = get_item(item_id)["tags"]
	item.desc = get_item(item_id)["desc"]
	item.size = get_item(item_id)["size"]
	if get_item(item_id).has("targets"):
		item.targets = get_item(item_id)["targets"]
	if get_item(item_id).has("type"):
		item.stats = get_item(item_id)["type"]
	if get_item(item_id).has("cost"):
		item.stats = get_item(item_id)["cost"]
	if get_item(item_id).has("stats"):
		item.stats = get_item(item_id)["stats"]
	if get_item(item_id).has("values"):
		item.values = get_item(item_id)["values"]
	if get_item(item_id).has("damage"):
		item.damage = get_item(item_id)["damage"]
	if get_item(item_id).has("ticks"):
		item.values = get_item(item_id)["ticks"]
	if get_item(item_id).has("buffs"):
		item.buffs = get_item(item_id)["buffs"]
	if get_item(item_id).has("labels"):
		item.labels = get_item(item_id)["labels"]
	item.sprite_set(get_image(item_id), get_image_back(item_id))
	return item
