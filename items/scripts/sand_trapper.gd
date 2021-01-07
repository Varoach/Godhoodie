extends "res://items/custom_item.gd"

func _ready():
	summon_on_kill = true
	connect("on_balance_break", self, "_drag")

func _drag(target):
	Game.emit_signal("move_character", target, target.get_old_position())
