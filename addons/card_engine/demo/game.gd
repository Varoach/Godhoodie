# Game class - Contains the game logic for the demo game
extends Node

# Imports
var CardHand = preload("../card_hand.gd")
var CardPile = preload("../card_pile.gd")
var CardRng  = preload("../card_rng.gd")
var PlayerInventory = preload("res://addons/card_engine/demo/Inventory/inventory.gd")

# Time to wait between step to account for animations
const STEP_WAIT_TIME = 0.5

signal player_spirit_changed()
signal turn_started()
signal use(card, target)

var targets = []

# Constant values
const HAND_SIZE = 4

var character = ""
var health = 10
var player_spirit    = 3
var player_max_spirit= 3

var player
var player_deck    = null
var player_hand    = CardHand.new()
var player_draw    = CardPile.new()
var player_discard = CardPile.new()
var player_weapons
var player_items
var player_jutsus
var player_inventory
var player_cards
var tacos = false

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
	
	_discard_rng.set_seed(CardEngine.master_rng().randomi())
	
# Creates a new game with the given deck
func create_game(deck_id, character_name):
	character = character_name
	player_deck = CardEngine.library().deck(deck_id)
	if player_deck == null:
		printerr("Invalid deck ID while creating a game")
	
	_current_step = 0
	
	player_hand.clear()
	player_draw.clear()
	player_discard.clear()
	
	player_draw.copy_from(player_deck)
	player_draw.shuffle()

	_stepper.start()

func create_game_real(character_name):
	character = character_name
	
	player_hand.clear()
	
	if not tacos:
		var player_inventory = PlayerInventory.new()
		player_weapons = player_inventory.weapons
		player_items = player_inventory.items
		player_jutsus = player_inventory.jutsus
		player_cards = player_inventory.player_cards
		player_jutsus.copy_from(CardEngine.library().deck("fighter_starter"))
		tacos = true
	
	player_cards.copy_from(player_items)
	
	_stepper.start()

func draw_one_card():
	player_hand.append(player_draw.draw())

func draw_cards(amount):
	player_hand.append_multiple(player_draw.draw_multiple(amount))

func draw_cards_real():
	player_hand.append_multiple(player_cards.draw_multiple(player_cards.size()))

func discard_random_card():
	var card = player_hand.discard(floor(_discard_rng.randomf()*player_hand.size()))
	player_discard.append(card)

func _step_start_turn():
	draw_cards_real()
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

func discard_card(cardIndex, group):
	player_jutsus.remove(cardIndex)
	player_discard.append(cardIndex)

func win():
	yield(get_tree(), "idle_frame")
	get_tree().reload_current_scene()

func game_over():
	yield(get_tree(), "idle_frame")
	get_tree().reload_current_scene()

func enemy_use(ability, target, value):
	target.use(ability, value)

func return_state():
	player_items.copy_from(player_hand)
	_steps = ["start_game", "your_turn"]
	_current_step = 0
	targets.clear()

func use(card, curr_target = null):
	if card._card_data.targets == "single":
		apply_effects(card, curr_target)
	elif card._card_data.targets == "enemies":
		for target in targets:
			if target == targets[0]:
				continue
			else:
				apply_effects(card, target)
	elif card._card_data.targets == "everyone":
		for target in targets:
			apply_effects(card, target)
	Game.player.get_node("animations").play("attack")

func apply_effects(card, target):
	for value in card._card_data.values:
			target.use(value, CardEngine.final_value(card.get_card_data(), value))
