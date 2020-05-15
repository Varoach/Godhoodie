extends Node

const ENEMY_PATH = "res://addons/card_engine/demo/character/enemy/"
const IMAGE_PATH = "res://addons/card_engine/demo/enemies/images/"

const ENEMIES = {
	"enemy1": {
		"path" : ENEMY_PATH + "enemy1/enemy1.tscn",
		"health" : 5,
		"abilities":{
			"attack" : 2,
			"heal" : 3
		}
	},
	"enemy2": {
		"path": ENEMY_PATH + "enemy2/enemy2.tscn",
		"health" : 8,
		"abilities":{
			"attack" : 4
		},
	},
#	"error": {
#		"icon": ICON_PATH + "error.png"
#	}
}

func get_enemy(enemy_id):
	if enemy_id in ENEMIES:
		return ENEMIES[enemy_id]

func random_enemy():
	return ENEMIES.keys()[randi() % ENEMIES.size()]
