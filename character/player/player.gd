extends "res://character/character.gd"

onready var staminabar = get_node("../../playerui/playeruivertical/stamina")
onready var spiritbar = get_node("../../playerui/playeruivertical/spirit")
onready var healthbar = get_node("../../playerui/playeruivertical/oldhealth")
onready var ui = get_node("../../playerui")

func _ready():
	in_game()

func in_game():
	Game.connect("player_check", self, "player_update")
	healthbar.max_value = Game.bars.health
	healthbar.value = healthbar.max_value
	staminabar.max_value = Game.bars.stamina
	staminabar.value = staminabar.max_value
	spiritbar.max_value = Game.bars.spirit
	spiritbar.value = spiritbar.max_value

func player_update():
	staminabar.value = Game.curr_bars.stamina
	spiritbar.value = Game.curr_bars.spirit

func _damage_received(value):
	$animations.play("damage")
	healthbar.negative_health_update(value)
	heart_check()
	

func _healing_received(value):
	$animations.play("defend")
	healthbar.positive_health_update(value)
	heart_check()

func heart_check():
	Game.curr_bars.health = healthbar.value
	ui.heart_change()
	ui.heart_setup()
