extends Node

const STEP_WAIT_TIME = 1

signal player_start()
signal player_played()
signal player_end()
signal enemy_start()
signal enemy_end()
signal step_text()
signal spawn_enemy()
signal replace_enemy()
signal enemy_spawned()
signal spawn_next_enemy()
signal move_character()
signal slide_character()
signal enemy_moved()
signal error(value)

var targets = []
var player_targets = []
var enemy_targets = []
var neutral_targets = []
var enemies = []
var positions = []
var enemy_targets_count = 0
var round_buffs = {}
var game_buffs = {}
var items
var values = {"energy" : 2}

var player

var game_screen

var item_held = null
var item_pressed = null
var play_space

var inventory = null

var rng = RandomNumberGenerator.new()

var crafting = []
var crafting_items = []

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

func _ready():
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

func reset_craft():
	crafting = []
	crafting_items = []
