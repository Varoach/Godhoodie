extends "res://character/enemy/current_enemy.gd"

var slime_size = 0

func _ready():
	connect("cut_received", self, "_on_cut")
	connect("freeze_received", self, "_on_freeze")
	connect("fire_received", self, "_on_fire")

func _on_cut():
	if slime_size == 2:
		return
	slime_divide()

func _on_freeze():
	var freeze_percent = randf()
	if freeze_percent < 0.5:
		sleep = 2

func _on_fire():
	if slime_size == 0:
		return
	slime_combine()

func slime_divide():
	var split_health = int(health/2)
	health = int(health/2)
	var new_slime = EnemyDB.enemy_setup("slime")
	new_slime.health = split_health
	new_slime.shrink()
	shrink()
	emit_signal("spawn_character", new_slime)

func slime_combine():
	var combine_target = can_combine()
	combine_target.grow()

func can_combine():
	for target in Game.enemy_targets:
		if target.slime_size > 0:
			return target

func shrink():
	slime_size += 1
	if slime_size == 1:
		scale = Vector2(0.8, 0.8)
	elif slime_size == 2:
		scale = Vector2(0.6, 0.6)

func grow():
	slime_size -= 1
	if slime_size == 0:
		scale = Vector2(1, 1)
	elif slime_size == 1:
		scale = Vector2(0.8, 0.8)
