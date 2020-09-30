# Game class - Contains the game logic for the demo game
extends Node

# Imports
var CardRng  = preload("res://addons/card_engine/card_rng.gd")

# Time to wait between step to account for animations
const STEP_WAIT_TIME = 0.5

signal turn_started()
signal player_check()
signal player_end()
signal lightning()
signal update_cards()

var targets = []
var items = []
var enemy_targets = []
var walls = []

var moves

var character = ""
var player

var tacos = false
var highlight = false
var once = false
var bars = {"health" : 9, "focus" : 8, "stamina" : 5, "strength" : 0, "speed" : 2, "perception" : 0}
var curr_bars = {}
var bar_press = {"focus" : 0, "stamina" : 0}
var curr_bar_press = {}
var temp_buffs = {}
var count = 0
var trinkets = []
var inventory = null
var wall_defense = 0

var _stepper = Timer.new()
var _steps = ["start_game", "your_turn"]
var _current_step = 0
var _discard_rng = CardRng.new()
export (NodePath) var hand

func _init():
	_stepper.one_shot = true
	_stepper.wait_time = STEP_WAIT_TIME
	add_child(_stepper)
	_stepper.connect("timeout", self, "_on_stepper_timeout")

func create_game(character_name):
	character = character_name
	
#	player_cards.copy_from(player_items)
	
	_stepper.start()

func bar_regen():
	if curr_bars.focus < bars.focus:
		curr_bars.focus += 1
	if curr_bars.stamina < bars.stamina:
		curr_bars.stamina += 1

func _step_start_turn():
	emit_signal("turn_started")
	print("steps: " + String(_steps))

func _on_stepper_timeout():
	var step = _steps[_current_step]
	if step == "start_game":
		_step_start_turn()
	
	_current_step += 1
	if _current_step >= _steps.size():
		_current_step = 1
	#print("current step: " + String(_current_step))

func enemy_use(ability, target, value):
	if walls.empty():
		target.use(ability, value)

func item_use(item, handy, curr_target = null):
	var curr_attacks = 1
	if item.tags.has("melee"):
		var melee_offset = Vector2(100, 0)
		Game.player.attack_position(player.global_position + melee_offset)
#		Game.player.attack_position(enemy_targets[0].global_position - melee_offset)
	if item.values.has("attacks"):
		curr_attacks = item.values["attacks"]
	for i in range(curr_attacks):
		if item.targets in ItemUses.item_use_case:
			ItemUses.item_use_case[item.targets].call_func(item, curr_target)
	if !item.anim_use.empty():
		yield(player._animation, "tween_completed")
		player.animation(item.anim_use)
	else:
		player.animation("default")

func locate(title):
	var results = {}
	results.title = title
	if CardDB.get_card(title):
		results.category = "card"
	elif ItemDB.get_item(title):
		results.category = "item"
	elif WeaponDB.get_item(title):
		results.category = "weapon"
	return results

func test_item(item, value):
	return ItemUses.item_use_case["test"].call_func(item, value)

func bar_add(bar, value):
	bars[bar] += value

func return_state():
	_steps = ["start_game", "your_turn"]
	_current_step = 0
	targets.clear()
	enemy_targets.clear()
	trinkets.clear()
	items.clear()
	temp_buffs.clear()
	walls.clear()
	Relics.reset()
