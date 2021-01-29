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
	Game.connect("move_character", self, "_move")
	Game.connect("slide_character", self, "_slide")
	Game.connect("spawn_next_enemy", self, "_spawn_next_enemy")
	Game.connect("player_played", self, "_on_player_played")
	connect("end_battle", self, "_on_end_battle")
	
	items = $inventory/background/panel/items

	ready_up()

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		_slide(Game.player, 2)
	if Input.is_action_just_pressed("ui_left"):
		_slide(Game.player, -2)
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
		var new_player = load("res://characters/players/player.tscn").instance()
		new_player = load("res://characters/players/player.tscn").instance()
		new_player.sprite_set(load("res://assets/character/players/player.png"), 0, 0.98)
		new_player.flip()
		new_player.set_name("Player")
		new_player.add_to_group("player")
		Game.player = new_player
	
	initial_spawn(EnemyDB.random_enemy())
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

func spawn(character):
	_animation.interpolate_property(character, "modulate:a", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()

func _on_end_battle():
	emit_signal("next_screen", "menu")

func apply_item(item):
	ItemUse.item_use_case[item.targets].call_func(item)

func initial_spawn(enemy, ambush = false):
	Game.rng.randomize()
	$positions.get_child(7).add_child(Game.player)
#	if !ambush:
#		$positions.get_child(Game.rng.randi_range(0,3)).add_child(Game.player)
#	elif ambush:
#		$positions.get_child(4).add_child(Game.player)
	enemy.connect("dead", self, "_on_enemy_dead")
	enemy.add_to_group("enemy")
	Game.rng.randomize()
#	$positions.get_child(Game.rng.randi_range(5,8)).add_child(enemy)
	$positions.get_child(5).add_child(enemy)
	$positions.get_child(6).add_child(EnemyDB.random_enemy())
	$positions.get_child(4).add_child(EnemyDB.random_enemy())
	$positions.get_child(3).add_child(EnemyDB.random_enemy())
	$positions.get_child(2).add_child(EnemyDB.random_enemy())

func _on_enemy_dead(enemy, replace = false):
	if !replace:
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()
	else:
		yield(Game, "enemy_spawned")

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

#returns the position of character in question
func get_position(character):
	character.get_position()

#returns the character at the position, otherwise return null
func get_character(position):
	if $positions.get_child(position).get_children().empty():
		return null
	return $positions.get_child(position).get_child(0)

func direction_check(first_spot, active_spot):
	if active_spot - first_spot > 0:
		return true
	else:
		return false

func _move(character, position):
	if position > 8 or position < 0:
		return
	var curr_spot = character.get_position()
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(position).add_child(character)

func _prep_slide(character, move_spot):
	var curr_spot = character.get_position()
	_animation.interpolate_property(character, "global_position:x", character.global_position.x, $positions.get_child(move_spot).global_position.x, 0.2 * (abs(move_spot - curr_spot)),Tween.TRANS_SINE, Tween.EASE_OUT)
	yield(_animation, "tween_all_completed")
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(move_spot).add_child(character)
	character.moving = false

func _force_slide(move_spot, right):
	var blocking_character = get_character(move_spot)
	var push_spot
	if right:
		push_spot = move_spot - 1
		if push_spot < 0:
			push_spot + 2
	else:
		push_spot = move_spot + 1
		if push_spot > 8:
			push_spot - 2
	get_character(move_spot).moving = true
	if get_character(push_spot):
		if !get_character(push_spot).is_moving():
			_force_slide(push_spot, right)
	_prep_slide(blocking_character, push_spot)

func _slide(character, amount, absolute = false):
	if character.is_moving():
		return
	var curr_spot = character.get_position()
	var move_spot = int(clamp(amount + curr_spot, 0, $positions.get_child_count()-1))
	if move_spot > 8 or move_spot < 0 or move_spot == curr_spot:
		return
	if _animation.is_active():
		yield(_animation, "tween_all_completed")
	character.moving = true
	if get_character(move_spot):
		_force_slide(move_spot, direction_check(curr_spot, move_spot))
	character.bring_front()
	_animation.interpolate_property(character, "global_position:x", $positions.get_child(curr_spot).global_position.x, $positions.get_child(move_spot).global_position.x, 0.2 * (abs(move_spot - curr_spot)),Tween.TRANS_SINE, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_all_completed")
	character.send_back()
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(move_spot).add_child(character)
	character.moving = false

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
