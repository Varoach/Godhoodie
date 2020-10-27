extends Node

var custom_enemy = load("res://character/enemy/enemy.tscn")
const IMAGE_PATH = "res://assets/enemies/"
const SCRIPT_PATH = "res://character/enemy/scripts/"

const ENEMIES = {
	"slime": {
		"image" : IMAGE_PATH + "slime.png",
		"health" : 5,
		"drops" : {
			"gel" : 100,
			"raw" : 10
		},
		"values":{
			"attack" : [2, 5],
		}
	},
}

func get_enemy(enemy_id):
	if enemy_id in ENEMIES:
		return ENEMIES[enemy_id]

func random_enemy():
	return enemy_setup(ENEMIES.keys()[randi() % ENEMIES.size()])

func enemy_setup(enemy_id):
	var enemy = custom_enemy.instance()
	enemy.set_script(load(SCRIPT_PATH + enemy_id))
	enemy.set_texture(load(get_enemy(enemy_id)["image"]))
	enemy.set_meta("id", enemy_id)
	enemy.values = get_enemy(enemy_id)["values"]
	enemy.health = get_enemy(enemy_id)["health"]
	enemy.set_max_health()
	return enemy
