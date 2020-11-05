extends "../abstract_screen.gd"

const TEXT_ANIM_SPEED = 2.0

var items

func _ready():
	Game.connect("player_start", self, "_on_turn_started")
	Game.connect("step_text", self, "_change_step_text")
	Game.connect("spawn_enemy", self, "_spawn_enemy")
	Game.connect("spawn_next_enemy", self, "_spawn_next_enemy")
	Game.connect("player_played", self, "_on_player_played")
	
	items = $inventory/background/panel/items

	ready_up()

func ready_up():
	if !Game.player:
		Game.player = load("res://characters/players/player.tscn").instance()
		Game.player.sprite_set(load("res://assets/character/players/player.png"), 50, 0.98)
		Game.player.flip()
	
	initial_spawn(EnemyDB.random_enemy())
#	pos_set()
	Game.play_space = $drops
	clock_set()

func _on_player_played():
	clock_set()

func clock_set():
	$clock/time.text = String(Game.clock)

func _on_menu_button_pressed():
	emit_signal("next_screen", "menu")

func _spawn_enemy(enemy, position):
	if Game.enemy_targets[position-1]:
		return false
	$enemy_positions.get_child(position-1).add_child(enemy)
	Game.enemy_targets[position-1] = $enemy_positions.get_child(position-1).get_child(0)
	check_spawned()
	return true

func _spawn_next_enemy(enemy):
	for child in $enemy_positions.get_children():
		if child.get_children().empty():
			child.add_child(enemy)
			break
	check_spawned()

func check_spawned():
	Game.targets.clear()
	Game.enemy_targets.clear()
	Game._steps = Game._steps_back
	for player in $player_position.get_children():
		Game.targets.append(player)
	for enemy_pos in $enemy_positions.get_children():
		if enemy_pos.get_children().empty():
			Game.targets.append(null)
			Game.enemy_targets.append(null)
		else:
			Game.targets.append(enemy_pos.get_child(0))
			Game.enemy_targets.append(enemy_pos.get_child(0))
			Game._steps.append("enemy turn")

func apply_item(item):
	ItemUse.item_use_case[item.targets].call_func(item)

func initial_spawn(enemy):
	$player_position.add_child(Game.player)
	$"enemy_positions/2".add_child(enemy)
	check_spawned()


func _on_clock_pressed():
	if Game._steps[Game._current_step] != "your turn":
		return
	Game.emit_signal("player_end")
	Game._stepper.start()
