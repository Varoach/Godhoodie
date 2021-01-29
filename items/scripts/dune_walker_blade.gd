extends "res://items/custom_item.gd"

func _ready():
	summon_on_kill = true
	connect("on_kill", self, "_summon_dune")

func _summon_dune(target_pos):
	var dune_walker = EnemyDB.enemy_setup("dummy")
	Game.neutral_targets.append(dune_walker)
	dune_walker.modulate = Color.orangered
	Game.emit_signal("replace_enemy", dune_walker, target_pos)
