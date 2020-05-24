# CEInterface class - Serves as an interface between your game and CardEngine
extends Node

# TODO: make a template out of this file before releasing the plugin

# Folders
const FOLDER_CARDS = "res://cards/images"

# Filename formats
const FORMAT_CARDS = "card-%s-%s.png"

# Players name
const PLAYER_PLAYER = "player"
const PLAYER_ENEMY  = "enemy"

# Decks name
const DECK_PLAYER = "player_deck"

# Piles name
const PILE_DRAW    = "draw_pile"
const PILE_DISCARD = "discard_pile"

var _custom_card = preload("res://cards/custom_card.tscn")

# Returns the path to the file containing the card database
func card_database_path():
	return "res:///cards.json"

# Returns the path to the image with the given type and id
func card_image(img_type, img_id):
	var filename = FORMAT_CARDS % [img_type, img_id]
	return "%s/%s" % [FOLDER_CARDS, filename]

# Calculate the the given value of the given card taking into account possible buffs/debuffs
func calculate_final_value(card, value):
	# TODO: take into account buffs/debuffs
	return card.values[value]

func final_value(card, value):
	if !card.values.has(value):
		return 0
	else:
		return calculate_final_value(card, value)

func final_text(card, text):
	var final_text = card.texts[text]
	for value in card.values:
		final_text = final_text.replace("$%s" % value, "%d" % final_value(card, value))
	final_text = final_text.replace("$%s" % "targets", card.targets)
	return final_text

# Returns an instance of the custom card design
func card_instance():
	return _custom_card.instance()
	#return _custom_card.call_deferred("instance")
