extends "../abstract_screen.gd"

const TEXT_ANIM_SPEED = 2.0

var _animation = Tween.new()
var _player_characters = {
		"fighter": preload("res://character/player/fighter/fighter.tscn")
	}

var _enemies = load("res://character/enemy/current_enemy.gd").new()

#var weapon_ref = funcref(Game, "weapon_use")
#var item_ref = funcref(Game, "item_use")
#var jutsu_ref = funcref(Game, "jutsu_use")
#
#var hand_use = {"weapons" : weapon_ref, "items" : item_ref, "jutsus" : jutsu_ref}

var targets = []
var enemy_targets = []
var enemy_positions = []
var enemy_position = Vector2(0,0)
var possible_enemy_positions = []

var _focused_target = null

func _init():
	add_child(_animation)
	_animation.connect("tween_completed", self, "_on_animation_completed")

func _ready():
	Game.moves = Game.max_moves
	Game.curr_bars = Game.bars.duplicate()
	$TurnCon/TurnButton/Label.text = String(Game.moves)
	$Inventory.connect("play", self, "_on_play")
	
	Game.connect("turn_started", self, "_on_turn_started")
	
	_change_step_text("Get ready!")
	
	ready_up()
	
	add_targets()
	if !Game.once:
		WeaponDB.pickup_weapon("daggers")
		WeaponDB.pickup_weapon("wood sword")
		ItemDB.pickup_item("potion")
		ItemDB.pickup_item("potion")
		ItemDB.pickup_item("fools gold")
		ItemDB.pickup_item("electric rune")
		ItemDB.pickup_item("electric rune")
		ItemDB.pickup_item("electric rune")
		ItemDB.pickup_item("kunai")
		ItemDB.pickup_item("fish")
		ItemDB.pickup_item("fish")
		CardDB.pickup_card("light me up")
		Game.once = true

func _enter_tree():
	pass

func move_update():
	$TurnCon/TurnButton/Label.text = String(Game.moves)

func _exit_tree():
	_animation.stop_all()
	_animation.queue_free()

func ready_up():
	$enemy_position.add_child(_enemies.enemy_setup(EnemyDB.random_enemy()))
#	possible_enemy_positions = [Vector2(0,0), Vector2(-700,0), Vector2(700,0)]
#	var positions = randi() % 3+1
#	for i in range(positions):
##		$enemy_position.add_child(_enemy_characters.values()[randi() % _enemy_characters.size()].instance())
#		$enemy_position.add_child(_enemies.enemy_setup(EnemyDB.random_enemy()))
#	if positions == 1:
#		enemy_positions = [possible_enemy_positions[0]]
#	if positions == 2:
#		enemy_positions = [possible_enemy_positions[1]+Vector2(300,0),possible_enemy_positions[2]+Vector2(-300,0)]
#	if positions == 3:
#		enemy_positions = [possible_enemy_positions[1]+Vector2(-150,0),possible_enemy_positions[0]+Vector2(-150,0),possible_enemy_positions[2]+Vector2(-150,0)]

func add_targets():
	$player_position.add_child(_player_characters[Game.character].instance())
	for child in $player_position.get_children():
		Game.player = child
		targets.append(child)
		child.connect("mouse_entered", self, "_on_target_mouse_entered", [child])
		child.connect("mouse_exited", self, "_on_target_mouse_exited", [child])
	for child in $enemy_position.get_children():
#		child.position.x = enemy_positions[child.get_index()].x
		child.position.x = enemy_position.x
		targets.append(child)
		enemy_targets.append(child)
		child.connect("mouse_entered", self, "_on_target_mouse_entered", [child])
		child.connect("mouse_exited", self, "_on_target_mouse_exited", [child])
		Game._steps.append("enemy_turn")
	Game.targets = targets
	Game.enemy_targets = enemy_targets

func _change_step_text(text):
	$lbl_step.text = text
	_animation.interpolate_property(
		$lbl_step, "modulate", $lbl_step.modulate,  Color(1.0, 1.0, 1.0, 1.0), TEXT_ANIM_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_animation.start()
	yield(get_tree().create_timer(TEXT_ANIM_SPEED), "timeout")
	_animation.interpolate_property(
		$lbl_step, "modulate", $lbl_step.modulate,  Color(1.0, 1.0, 1.0, 0.0), TEXT_ANIM_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_animation.start()

func _update_deck(new_size):
	$btn_deck/lbl_deck_count.text = "%d" % Game.player_deck.size()

func _update_draw_pile(new_size):
	$btn_draw_pile/lbl_draw_pile_count.text = "%d" % new_size

func _update_discard_pile(new_size):
	$btn_discard_pile/lbl_discard_pile_count.text = "%d" % new_size

func _update_player_focus():
	$img_energy/lbl_energy.text = "%d/%d" % [Game.focus, Game.focus]

func _on_btn_exit_pressed():
	Game.return_state()
	emit_signal("next_screen", "menu")

func _on_btn_draw_pile_pressed():
	Game.draw_one_card()

func _on_btn_discard_pile_pressed():
	Game.discard_random_card()

func _on_turn_started():
	_change_step_text("Your turn")

func _on_animation_completed(object, key):
	_animation.remove(object, key)

func _on_play(card, hand, bars = null):
	if bars != null:
		for bar in bars:
			Game.curr_bars[bar] -= bars[bar]
	Game.emit_signal("player_check")
	var target = _check_targets()
	Game.item_use(card, hand, target)
	Game.moves -= 1
	move_update()
	$Inventory.played = false

func end_turn():
	if $Inventory.played:
		return
	$Inventory.played = true
	Game.emit_signal("player_end")
	Game._stepper.start()
	_change_step_text("Turn Ended")
	yield(Game._stepper,"timeout")
	_change_step_text("Enemy turn")
	for child in $enemy_position.get_children():
		child.play_turn()
		yield(Game._stepper,"timeout")
	_change_step_text("Your turn")
	Game.moves = Game.max_moves
	Game.temp_buffs.clear()
	move_update()
	$Inventory.played = false

func set_focused_target(target):
	if _focused_target != null: return
	_focused_target = target

func unset_focused_target(target):
	if _focused_target != target: return
	_focused_target = null

func _on_target_mouse_entered(target):
	set_focused_target(target)

func _on_target_mouse_exited(target):
	unset_focused_target(target)

func _check_targets():
	var current_target = null
	for person in targets:
		if person.check_focus():
			current_target = person
	if current_target != null:
		return current_target

func win():
	yield(get_tree(), "idle_frame")
	get_tree().reload_current_scene()

func game_over():
	yield(get_tree(), "idle_frame")
	get_tree().reload_current_scene()
