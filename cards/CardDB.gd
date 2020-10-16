extends Node

signal card_added()

const custom_card = preload("res://cards/custom_card.tscn")

const CARD_PATH = "res://cards/"
const WALL_PATH = "res://summons/walls/"
const earth_color = "be9071"
const lightning_color = "a02c2c"

const CARDS = {
	"sword1": {
	  "category": "fighter",
	  "type": "attack",
	  "tags": [],
	  "targets": "single",
	  "images": {
		"background": "consumables",
		"picture": "sword"
	  },
	  "values": {
		"cost": 1,
		"attack": 1
	  },
	  "bars":{
		"focus": 2
	  },
	  "texts": {
		"name": "The Sword 1",
		"type": "attack",
		"desc": "[center]Deal [color=#a02c2c]$attack[/color] damage\nto [color=#2c68a0]$targets[/color][/center]"
	  }
	},
	"two hands": {
	  "category": "fighter",
	  "type": "attack",
	  "tags": [],
	  "targets": "single",
	  "images": {
		"background": "consumables",
		"picture": "sword"
	  },
	  "values": {
		"cost": 2,
		"attack": 4,
		"vulnerable": 1
	  },
	  "bars":{
		"focus": 2
	  },
	  "texts": {
		"name": "Two Hands Wack 4",
		"type": "attack",
		"desc": "[center]Deal [color=#a02c2c]$attack[/color] damage\nto [color=#2c68a0]$targets[/color]\nApply [color=#a02c2c]$vulnerable[/color] vulnerable[/center]"
	  }
	},
	"sword2": {
	  "category": "fighter",
	  "type": "attack",
	  "tags": [],
	  "targets": "everyone",
	  "images": {
		"background": "consumables",
		"picture": "sword"
	  },
	  "values": {
		"cost": 1,
		"attack": 2
	  },
	  "bars":{
		"focus": 1
	  },
	  "texts": {
		"name": "The Sword 2",
		"type": "attack",
		"desc": "[center]Deal [color=#a02c2c]$attack[/color] damage\nto [color=#2c68a0]$targets[/color][/center]"
	  }
	},
	"two handse": {
	  "category": "fighter",
	  "type": "attack",
	  "tags": [],
	  "targets": "enemies",
	  "images": {
		"background": "consumables",
		"picture": "sword"
	  },
	  "values": {
		"cost": 2,
		"attack": 3,
		"vulnerable": 1
	  },
	  "bars":{
		"focus": 2
	  },
	  "texts": {
		"name": "Two Hands Wack 3",
		"type": "attack",
		"desc": "[center]Deal [color=#a02c2c]$attack[/color] damage\nto [color=#2c68a0]$targets[/color]\nApply [color=#a02c2c]$vulnerable[/color] vulnerable[/center]"
	  }
	},
	"falling thunder": {
	  "category": "fighter",
	  "element" : "lightning",
	  "type": "attack",
	  "tags": [],
	  "targets": "enemies",
	  "images": {
		"background": "consumables",
		"picture": "lightning"
	  },
	  "values": {
		"cost": 2,
		"lightning": 3,
	  },
	  "bars":{
		"focus": 2
	  },
	  "texts": {
		"name": "Falling Thunder",
		"type": "attack",
		"desc": "[center]Deal [color=#" + lightning_color + "]$lightning[/color] [b][color=#ffe270]$element[/color][/b]damage\nto [color=#2c68a0]$targets[/color]"#\nApply [color=#a02c2c]$vulnerable[/color] vulnerable[/center]
	  }
	},
	"clay wall": {
	  "category": "fighter",
	  "element" : "earth",
	  "type": "summon",
	  "tags": [],
	  "targets": "walls",
	  "images": {
		"background": "consumables",
		"picture": "clay-wall",
	  },
	  "values": {
		"health": 3,
	  },
	  "bars":{
		"focus": 2
	  },
	  "texts": {
		"name": "Clay Wall",
		"type": "summon",
		"desc": "[center]Summon [b][color=#" + earth_color + "]$element[/color][/b] wall at target location"#\nApply [color=#a02c2c]$vulnerable[/color] vulnerable[/center]
	  }
	},
}

const CARD_BACKS = {
	"consumables": {
		"icon": CARD_PATH + "card-background-consumables.png",
		"icon_back": CARD_PATH + "card-back-consumables.png"
	}
}

func pickup_card(card_id):
	if Inventory.player_inventory.cards.size() == 8:
		return
	var card = card_setup(card_id)
	card._update_card()
	Inventory.add_card(card_id)
	emit_signal("card_added")

func get_card(card_id):
	if card_id in CARDS:
		return CARDS[card_id]
	else:
		return null

func get_back(back_id):
	if back_id in CARD_BACKS:
		return CARD_BACKS[back_id]
	else:
		return null

func card_setup(card_id):
	var card = custom_card.instance()
	card.set_meta("id", card_id)
	card.title = card_id
	card.type = get_card(card_id)["type"]
	if card.type == "summon":
		card.add_to_group("summon")
	card.targets = get_card(card_id)["targets"]
	card.bars = get_card(card_id)["bars"]
	card.texts = get_card(card_id)["texts"]
	card.images = get_card(card_id)["images"]
	if get_card(card_id).has("anim_ready"):
		card.anim_ready = get_card(card_id)["anim_ready"]
	if get_card(card_id).has("anim_use"):
		card.anim_use = get_card(card_id)["anim_use"]
	if get_card(card_id).has("values"):
		card.values = get_card(card_id)["values"]
	if get_card(card_id).has("element"):
		card.element = get_card(card_id)["element"]
	card.save_animation_state()
	return card
