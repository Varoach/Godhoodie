extends "res://character/character.gd"

signal check()

onready var ui = get_node("../../playerui")
onready var animator = $character/appearance
var curr_pos = null

func _ready():
	animation_speed = 0.01
	in_game()
	save_animation_state_global()
	curr_pos = global_position
#	$animations.connect("animation_finished", self, "_on_animation_finish")

func in_game():
	Game.connect("player_check", self, "player_update")
	Game.connect("player_end", self, "turn_end")

func player_update():
	stamina_check()
	focus_check()

func turn_end():
	add_defense()
#	reset()
	Game.bar_regen()
	stamina_check()
	focus_check()

func add_defense():
	defense += Game.count
	$character/defense.text = String(defense)

func _damage_received(value):
	if Game.wall_defense > value:
		Game.wall_defense -= value
		value = 0
	elif Game.wall_defense >= Game.wall_defense:
		value -= Game.wall_defense
		Game.wall_defense = 0
	if defense > value:
		defense -= value
		value = 0
	elif value >= defense:
		value -= defense
		defense = 0
	$character/defense.text = String(defense)
	if value <= 0:
#		$animations.play("defend")
		return
#	$animations.play("damage")
	negative_health_update(value)
	heart_check()

func _healing_received(value):
#	$animations.play("defend")
	positive_health_update(value)
	heart_check()

func heart_check():
	emit_signal("check")
	ui.hearts.heart_change()
	ui.hearts.heart_setup()

func stamina_check():
	emit_signal("check")
	ui.staminas.stamina_change()
	ui.staminas.stamina_setup()

func focus_check():
	emit_signal("check")
	ui.focuses.focus_change()
	ui.focuses.focus_setup()

func positive_health_update(value):
	if Game.curr_bars.health + value > Game.bars.health:
		Game.curr_bars.health = Game.bars.health
	else:
		Game.curr_bars.health += value

func negative_health_update(value):
	Game.curr_bars.health -= value

#func reset():
#	ui.staminas.reset()
#	ui.focuses.reset()

func animation(value):
	if "use" in $character/appearance.animation:
		yield($character/appearance, "animation_finished")
		$character/appearance.animation = value
	else:
		$character/appearance.animation = value

func animation_instant(value):
	$character/appearance.animation = value

func _on_appearance_animation_finished():
	if "use" in $character/appearance.animation:
		$character/appearance.animation = "default"
		if curr_pos != null:
			pop_animation_state_global()
#			global_position = curr_pos

func attack_position(pos):
	push_animation_state_global(Vector2(pos.x, global_position.y), global_rotation_degrees, global_scale)
#	global_position.x = pos.x
