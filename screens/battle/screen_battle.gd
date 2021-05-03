extends "../abstract_screen.gd"

const TEXT_ANIM_SPEED = 2.0

signal end_battle()

var items

var _animation = Tween.new()

func _init():
	add_child(_animation)

func _ready():
	Game.game_screen = self
	Game.connect("step_text", self, "_change_step_text")
	Game.connect("spawn", $positions, "_spawn")
	Game.connect("replace_enemy", $positions, "_replace_enemy")
	Game.connect("move_character", $positions, "_move")
	Game.connect("slide_character", $positions, "_slide")
	Game.connect("player_played", self, "_on_player_played")
	connect("end_battle", self, "_on_end_battle")
	
	items = $inventory/background/panel/items

	ready_up()

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		$positions._slide(Game.player, 2)
	if Input.is_action_just_pressed("ui_left"):
		$positions._slide(Game.player, -2)

func ready_up():
	if !Game.player:
		var new_player = load("res://characters/players/player.tscn").instance()
		new_player = load("res://characters/players/player.tscn").instance()
		new_player.sprite_set(load("res://assets/character/players/player.png"), 0, 0.98)
		new_player.flip()
		new_player.set_name("Player")
		new_player.add_to_group("player")
		Game.player = new_player
	
	initial_spawn(EnemyDB.enemy_setup("slime"))
	Game.play_space = $drops
	energy_set()

func _on_player_played():
#	energy_set()
	pass

func energy_set():
	$clock/energy.text = String(Game.values.energy)

func _on_menu_button_pressed():
	emit_signal("next_screen", "menu")

func show_dead(character):
	_animation.interpolate_property(character, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()

func _spawn(character, spot):
	character.modulate.a = 0
	_animation.interpolate_property(character, "modulate:a", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$positions.get_child(spot).add_child(character)
	_animation.start()

func _on_end_battle():
	emit_signal("next_screen", "menu")

func apply_item(item):
	ItemUse.item_use_case[item.targets].call_func(item)

func initial_spawn(enemy, ambush = false):
	Game.rng.randomize()
	$positions.get_child(0).add_child(Game.player)
#	if !ambush:
#		$positions.get_child(Game.rng.randi_range(0,3)).add_child(Game.player)
#	elif ambush:
#		$positions.get_child(4).add_child(Game.player)
	enemy.connect("dead", self, "_on_enemy_dead")
	enemy.add_to_group("enemy")
	Game.rng.randomize()
#	$positions.get_child(Game.rng.randi_range(5,8)).add_child(enemy)
#	$positions.get_child(Game.rng.randi_range(5,8)).add_child(enemy)
	_spawn(enemy, 8)

func _on_enemy_dead(enemy):
	enemy.get_parent().remove_child(enemy)
	enemy.queue_free()

func _on_clock_pressed():
	print("turn end")
	if Game._steps[Game._current_step] != "your_turn":
		return
	Game.emit_signal("player_end")
	Game.round_buffs.clear()
	Game._stepper.start()
	yield(Game._stepper, "timeout")
	for character in $positions.get_children():
		if character.is_in_group("enemy"):
			character.play_turn()
			Game._stepper.start()
			yield(Game._stepper, "timeout")
	Game.values.energy = 2
	energy_set()

func spawn_random_item():
	ItemDB.spawn_item("random base", $player_position.rect_global_position)
