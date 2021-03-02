  
extends Node

var custom_enemy = load("res://characters/enemies/enemy.tscn")

const IMAGE_PATH = "res://assets/character/enemies/"
const SCRIPT_PATH = "res://characters/enemies/scripts/"

const ENEMIES = {
	"dummy": {
		"tags" : ["liquid"],
		"health" : 5,
		"loyal" : "player",
		"drops" : {
			"gel" : 100,
			"raw" : 10
		},
		"values":{
			"attack" : [2, 5],
		}
	},
	"slime": {
		"tags" : ["liquid"],
		"health" : 5,
		"loyal" : "player",
		"width" : 2,
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

func get_images(enemy_id):
	return load(IMAGE_PATH + enemy_id + "/" + enemy_id + ".png")

func enemy_setup(enemy_id):
	var enemy = custom_enemy.instance()
	enemy.title = enemy_id
#	enemy.set_script(load(SCRIPT_PATH + enemy_id + ".gd"))
	for tag in get_enemy(enemy_id)["tags"]:
		enemy.add_to_group(tag)
	if get_enemy(enemy_id)["width"]:
		enemy.width = get_enemy(enemy_id)["width"]
	enemy.max_health = get_enemy(enemy_id)["health"]
	enemy.health = get_enemy(enemy_id)["health"]
	enemy.drops = get_enemy(enemy_id)["drops"]
	enemy.values = get_enemy(enemy_id)["values"]
	enemy.sprite_set(get_images(enemy_id))
	return enemy
