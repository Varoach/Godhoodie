extends "../abstract_screen.gd"

const TEXT_ANIM_SPEED = 2.0

signal end_battle()

var items

var _animation = Tween.new()

var can_craft = false

func _init():
	add_child(_animation)

func _ready():
	Game.game_screen = self
#	Game.connect("player_start", self, "_on_turn_started")
	Game.connect("step_text", self, "_change_step_text")
	Game.connect("spawn_enemy", self, "_spawn_enemy")
	Game.connect("replace_enemy", self, "_replace_enemy")
	Game.connect("move_character", self, "_move_character")
	Game.connect("spawn_next_enemy", self, "_spawn_next_enemy")
	Game.connect("player_played", self, "_on_player_played")
	connect("end_battle", self, "_on_end_battle")
	
	items = $inventory/background/panel/items

	ready_up()

func _process(_delta):
	if can_craft:
		if !_animation.is_active():
				if !$craft_button.visible:
					enable_craft_button()
	elif !can_craft:
		if !_animation.is_active():
				if $craft_button.visible:
					disable_craft_button()
	if Game.item_held:
		if !Game.crafting.empty() or distance_check(Game.item_held):
			if !_animation.is_active():
				if !$craft_spot.visible:
					enable_craft()
		else:
			if !_animation.is_active():
				if $craft_spot.visible:
					disable_craft()
	elif Game.crafting.empty():
		if !_animation.is_active():
			if $craft_spot.visible:
				disable_craft()

func _on_can_craft(value):
	can_craft = value

func distance_check(item):
	if item.global_position.distance_to($craft_spot.global_position) <= 500:
		return true
	return false

func disable_craft():
	_animation.interpolate_property($craft_spot, "scale", Vector2.ONE, Vector2.ZERO, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.interpolate_property($craft_spot, "modulate:a", 1, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_completed")
	$craft_spot.visible = false

func enable_craft():
	$craft_spot.visible = true
	_animation.interpolate_property($craft_spot, "scale", Vector2.ZERO, Vector2.ONE, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.interpolate_property($craft_spot, "modulate:a", 0, 1, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

func enable_craft_button():
	$craft_button.visible = true
	_animation.interpolate_property($craft_button, "rect_scale", Vector2.ZERO, Vector2.ONE, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.interpolate_property($craft_button, "modulate:a", 0, 1, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

func disable_craft_button():
	_animation.interpolate_property($craft_button, "rect_scale", Vector2.ONE, Vector2.ZERO, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.interpolate_property($craft_button, "modulate:a", 1, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_completed")
	$craft_button.visible = false

func ready_up():
	if !Game.player:
		Game.player = load("res://characters/players/player.tscn").instance()
		Game.player.sprite_set(load("res://assets/character/players/player.png"), 0, 0.98)
		Game.player.flip()
		Game.player.set_name("Player")
	
	initial_spawn(EnemyDB.random_enemy())
#	pos_set()
	Game.play_space = $drops
	energy_set()

func _on_player_played():
	energy_set()

func energy_set():
	$clock/energy.text = String(Game.values.energy)

func _on_menu_button_pressed():
	emit_signal("next_screen", "menu")

func _spawn_enemy(enemy, position):
	if Game.enemy_targets[position]:
		return false
	var spawn_pos = get_enemy_pos(position)
	spawn_pos.add_child(enemy)
	Game.enemy_targets[position] = spawn_pos.get_child(0)
	check_spawned()
	return true

func _replace_enemy(enemy, position):
	var spawn_pos = get_enemy_pos(position)
	if Game.enemy_targets[position]:
		for child in spawn_pos.get_children():
			show_dead(child)
			yield(_animation, "tween_all_completed")
			spawn_pos.remove_child(child)
			child.queue_free()
	enemy.modulate.a = 0
	spawn_pos.add_child(enemy)
	spawn(enemy)
	Game.enemy_targets[position] = spawn_pos.get_child(0)
	check_spawned()
	return true

func show_dead(character):
	_animation.interpolate_property(character, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()

func spawn(character):
	_animation.interpolate_property(character, "modulate:a", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()

func get_enemy_pos(position):
	return $enemy_positions.get_child(position) 

func _spawn_next_enemy(enemy):
	for child in $enemy_positions.get_children():
		if child.get_children().empty():
			child.add_child(enemy)
			enemy.connect("dead", self, "_on_enemy_dead")
			break
	check_spawned()

func check_spawned():
	Game.targets.clear()
	Game.enemy_targets.clear()
	Game.enemy_targets_count = 0
	Game._steps = Game._steps_back
	for player in $player_position.get_children():
		Game.targets.append(player)
	for enemy_pos in $enemy_positions.get_children():
		if enemy_pos.get_children().empty():
			Game.targets.append(null)
			Game.enemy_targets.append(null)
		else:
			var curr_enemy = enemy_pos.get_child(0)
			Game.targets.append(curr_enemy)
			Game.enemy_targets.append(curr_enemy)
			Game._steps.append("enemy turn")
			Game.enemy_targets_count += 1
	if !Game.enemy_targets_count:
		emit_signal("end_battle")

func _on_end_battle():
	emit_signal("next_screen", "menu")

func apply_item(item):
	ItemUse.item_use_case[item.targets].call_func(item)

func initial_spawn(enemy, ambush = false):
	Game.rng.randomize()
	if !ambush:
		$positions.get_child(Game.rng.randi_range(0,3)).add_child(Game.player)
	elif ambush:
		$positions.get_child(4).add_child(Game.player)
	enemy.connect("dead", self, "_on_enemy_dead")
	$positions.get_child(Game.rng.randi_range(5,8)).add_child(enemy)
	check_spawned()

func _on_enemy_dead(enemy, replace = false):
	if !replace:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
		check_spawned()
	else:
		yield(Game, "enemy_spawned")
		check_spawned()

func _on_clock_pressed():
	if Game._steps[Game._current_step] != "your_turn":
		return
	Game.emit_signal("player_end")
	Game.round_buffs.clear()
	Game._stepper.start()
	yield(Game._stepper, "timeout")
	for enemy in Game.enemy_targets:
		if enemy:
			enemy.play_turn()
			Game._stepper.start()
			yield(Game._stepper, "timeout")
	Game.values.energy = 2
	energy_set()

func _move(character, position):
	if _animation.is_active():
		yield(_animation, "tween_all_completed")
	character.bring_front()
	if position < 0 or position > 8:
		print("Can't move out of play area!")
		return
	var curr_pos = character.get_parent().get_index()
	_animation.interpolate_property($enemy_positions.get_child(curr_pos), "rect_global_position:x", character.global_position.x, $enemy_positions.get_child(position).rect_global_position.x, 0.1 * (abs(position - curr_pos)),Tween.TRANS_SINE, Tween.EASE_OUT)
	_animation.start()
	character.send_back()
	yield(_animation, "tween_all_completed")
	if character != Game.player:
		Game.emit_signal("enemy_moved")
	elif character == Game.player:
		Game.emit_signal("player_moved")

func _hop(character, position):
	pass

func _on_craft_button_pressed():
	var current_craft = Game.crafting.duplicate()
	for item in Game.crafting_items:
		item.queue_free()
	Game.reset_craft()
	Game.item_held = null
	disable_craft()
	disable_craft_button()
	$craft_spot.collision_layer = 2
	$craft_spot.collision_mask = 2
	yield(_animation, "tween_completed")
	ItemDB.spawn_item(RecipeDB._craft(current_craft), $craft_spot.global_position, false, true)
	yield(get_tree().create_timer(1.2), "timeout")
	$craft_spot.collision_layer = 1
	$craft_spot.collision_mask = 1

func spawn_random_item():
	ItemDB.spawn_item("random base", $player_position.rect_global_position)
