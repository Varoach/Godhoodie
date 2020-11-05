extends Node

const STEP_WAIT_TIME = 0.5

signal player_start()
signal player_played()
signal player_end()
signal enemy_start()
signal enemy_end()
signal step_text()
signal spawn_enemy()
signal spawn_next_enemy()
signal error(value)

var targets = []
var player_targets = []
var enemy_targets = []
#var enemy_positions = []
var walls = []
var items
var clock = 2

var player

var item_held
var play_space

var inventory = null

var _stepper = Timer.new()
var _steps_back = ["start_game", "your_turn"]
var _steps = ["start_game", "your_turn"]
var _current_step = 0

func _init():
	_stepper.one_shot = true
	_stepper.wait_time = STEP_WAIT_TIME
	add_child(_stepper)
	_stepper.connect("timeout", self, "_on_stepper_timeout")
	connect("error", self, "_on_error")

func create_game(character):
	player = character
	
	_stepper.start()

func enemy_turn():
	pass

func _on_stepper_timeout():
	var step = _steps[_current_step]
	if step == "start_game":
		_step_start_turn()
	
	_current_step += 1
	if _current_step >= _steps.size():
		_current_step = 1

func _step_start_turn():
	emit_signal("player_start")
	print("steps: " + String(_steps))

func _on_error(error):
	print(error)
