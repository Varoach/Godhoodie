# CardData class - Holds the data for a card
extends Reference

signal changed()

# Base data
var id       = "" # Identifies the card, unique in the library
var category = "" # Specifies the card's category
var type     = "" # Specifies the card's type
var tags     = [] # Lists additional specifiers for the card
var targets  = ""
var images   = {} # Lists the different image used to represent this card
var values   = {} # Lists the different numerical values for this card
var texts    = {} # Lists the different texts displayed on the card

# Gameplay data
var player = null # Specifies to which player the card belongs
var origin = null # Specifies from where the card comes (Pile, Hand, ...)

# Creates a copy of the card
# As CardData is based on Reference, therefore you need to explicitly duplicate it
# Otherwise modifying a card results in modifying all cards using the same reference
func duplicate():
	var copy = get_script().new()
	
	copy.id       = id
	copy.category = category
	copy.type     = type
	copy.tags     = tags.duplicate()
	copy.targets  = targets
	copy.images   = images.duplicate()
	copy.values   = values.duplicate()
	copy.texts    = texts.duplicate()
	
	copy.player   = player
	copy.origin   = origin
	
	return copy

# Marks the data as changed for widgets to update their content
func mark_changed():
	emit_signal("changed")
