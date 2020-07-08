extends "res://character/character.gd"

signal check()

onready var ui = get_node("../../playerui")
onready var animator = $character/appearance

func _ready():
	in_game()

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
	if defense > value:
		defense -= value
		value = 0
	elif value >= defense:
		value -= defense
		defense = 0
	$character/defense.text = String(defense)
	if value <= 0:
		$animations.play("defend")
		return
	$animations.play("damage")
	negative_health_update(value)
	heart_check()

func _healing_received(value):
	$animations.play("defend")
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
	$character/appearance.animation = value
