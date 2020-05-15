extends "res://addons/card_engine/demo/character/character.gd"

onready var staminabar = get_node("../../playerui/playeruivertical/stamina")
onready var spiritbar = get_node("../../playerui/playeruivertical/spirit")

func _ready():
	in_game()

func in_game():
	Game.connect("player_check", self, "player_update")
	healthbar = $"../../playerui/playeruivertical/health"
	healthbar.max_value = Game.bars.health
	healthbar.value = healthbar.max_value
	staminabar.max_value = Game.bars.stamina
	staminabar.value = staminabar.max_value
	spiritbar.max_value = Game.bars.spirit
	spiritbar.value = spiritbar.max_value

func player_update():
	staminabar.value = Game.curr_bars.stamina
	spiritbar.value = Game.curr_bars.spirit
