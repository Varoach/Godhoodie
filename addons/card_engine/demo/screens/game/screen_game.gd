extends "../abstract_screen.gd"

const TEXT_ANIM_SPEED = 2.0

var _animation = Tween.new()
var _player_characters = {
		"fighter": preload("res://addons/card_engine/demo/character/player/fighter/fighter.tscn")
		#"mage": preload("res://addons/card_engine/demo/character/player/mage/mage.tscn")
	}
var _enemy_characters = {
		"enemy1": preload("res://addons/card_engine/demo/character/enemy/enemy1/enemy1.tscn"),
		"enemy2": preload("res://addons/card_engine/demo/character/enemy/enemy2/enemy2.tscn")
	}

var targets = []
var enemy_positions = []
var possible_enemy_positions = []

var _focused_target = null

signal enemy_move()
signal your_turn()

func _init():
	add_child(_animation)
	_animation.connect("tween_completed", self, "_on_animation_completed")

func _ready():
	$CanvasLayer/hand.set_container(Game.player_hand)
	
	#Game.player_deck.connect("size_changed", self, "_update_deck")
	#_update_deck(Game.player_deck.size())
	
	Game.player_draw.connect("size_changed", self, "_update_draw_pile")
	_update_draw_pile(Game.player_draw.size())
	
	Game.player_discard.connect("size_changed", self, "_update_discard_pile")
	_update_discard_pile(Game.player_discard.size())
	
	Game.connect("player_spirit_changed", self, "_update_player_spirit")
	_update_player_spirit()
	
	Game.connect("turn_started", self, "_on_turn_started")
	
	_change_step_text("Get ready!")
	
	ready_up()
	
	add_targets()

func _enter_tree():
	pass

func _physics_process(delta):
	pass
	
func _exit_tree():
	_animation.stop_all()

func ready_up():
	possible_enemy_positions = [Vector2(0,0), Vector2(-700,0), Vector2(700,0)]
	var positions = floor(Game._discard_rng.randomf()*3)
	for i in range(positions+1):
		$enemy_position.add_child(_enemy_characters.values()[floor(Game._discard_rng.randomf()*_enemy_characters.size())].instance())
	if positions == 0:
		enemy_positions = [possible_enemy_positions[0]]
	if positions == 1:
		enemy_positions = [possible_enemy_positions[1]+Vector2(300,0),possible_enemy_positions[2]+Vector2(-300,0)]
	if positions == 2:
		enemy_positions = [possible_enemy_positions[1]+Vector2(-150,0),possible_enemy_positions[0]+Vector2(-150,0),possible_enemy_positions[2]+Vector2(-150,0)]

func add_targets():
	$player_position.add_child(_player_characters[Game.character].instance())
	for child in $player_position.get_children():
		Game.player = child
		targets.append(child)
		child.connect("mouse_entered", self, "_on_target_mouse_entered", [child])
		child.connect("mouse_exited", self, "_on_target_mouse_exited", [child])
#		child.connect("focus", self, "_on_focus", [child])
#		child.connect("unfocus", self, "_on_unfocus", [child])
	for child in $enemy_position.get_children():
		child.position.x = enemy_positions[child.get_index()].x
		targets.append(child)
		child.connect("mouse_entered", self, "_on_target_mouse_entered", [child])
		child.connect("mouse_exited", self, "_on_target_mouse_exited", [child])
#		child.connect("focus", self, "_on_focus", [child])
#		child.connect("unfocus", self, "_on_unfocus", [child])
		Game._steps.append("enemy_turn")
	Game.targets = targets

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

func _update_player_spirit():
	$img_energy/lbl_energy.text = "%d/%d" % [Game.player_spirit, Game.player_max_spirit]

func _toggle_in():
	_animation.interpolate_property(
		$Layer/Alpha, "modulate", $Layer/Alpha.modulate, Color(0,0,0,0.4), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

func _toggle_out():
	_animation.interpolate_property(
		$Layer/Alpha, "modulate", $Layer/Alpha.modulate, Color(0,0,0,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

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

func _on_hand_play(card):
	Game._stepper.start()
	Game.use(card, _check_targets())
	_change_step_text("Enemy turn")
	yield(Game._stepper,"timeout")
	for child in $enemy_position.get_children():
		child.play_turn()
		yield(Game._stepper,"timeout")
	$CanvasLayer/hand.played = false

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

func enemy_turn():
	pass
