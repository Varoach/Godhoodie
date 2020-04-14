extends "res://addons/card_engine/demo/character/enemy/current_enemy.gd"

const maxHP = 12
var currentHP = maxHP

func _ready():
	$character/healthbar.set_health(maxHP)
	abilities = {"attack" : 4, "heal" : 3}
