# CardWidget class - Renders a card
extends "res://addons/card_engine/widgets/animated_object.gd"

const FORMAT_LABEL = "lbl_%s"
const FORMAT_IMAGE = "img_%s"

signal mouse_entered()
signal mouse_exited()
signal mouse_motion(relative)
signal left_pressed()#button)
signal left_released()#button)
signal right_pressed()
signal right_released()

var id       = "" # Identifies the card, unique in the library
var category = "" # Specifies the card's category
var element  = "" # Specifies the card's elements
var type     = "" # Specifies the card's type
var tags     = [] # Lists additional specifiers for the card
var triggers = []
var targets  = "" # Specifies the card's targets
var images   = {} # Lists the different image used to represent this card
var values   = {} # Lists the different numerical values for this card
var texts    = {} # Lists the different texts displayed on the card
var bars     = {} # Lists the card's bar usage (health/spirit/focus)
var title         # Specifies the card's title
var anim_ready = "" # Animation for ready stance
var anim_use = "" # Animation when used

# The size the card should be if no specific size apply
#export(Vector2) var default_size = Vector2(1,1)
export(Vector2) var default_size = Vector2(1500, 3000)

var default_z = 0 setget set_default_z

var _is_ready = false
var drag = false
var highlight = false
var _card_index= 1
var ready = false

# Returns the ideal scale given the card's default size and the given size
func calculate_scale(size):
	var ratio = size / default_size
	var result = Vector2(1, 1)
	if ratio.x > ratio.y:
		result = Vector2(ratio.y, ratio.y)
	else:
		result = Vector2(ratio.x, ratio.x)
	return result

func _ready():
	_is_ready = true
	Game.connect("update_cards", self, "_update_card")
	$mouse_area.connect("mouse_entered", self, "_on_mouse_area_entered")
	$mouse_area.connect("mouse_exited", self, "_on_mouse_area_exited")
	$mouse_area.connect("gui_input", self, "_on_mouse_area_event")

func _update_card():
	# Images update
	for image in images:
		var node = find_node(FORMAT_IMAGE % image)
		if node != null:
			var id = images[image]
			if id != "default":
				node.texture = load(Interface.card_image(image, id))
	
	# Value update
	for value in values:
		var node = find_node(FORMAT_LABEL % value)
		if node != null:
			node.text = "%d" % Game.test_item(self, value)
#			node.text = "%d" % Interface.final_value(self, value)
	
	# Text update
	for text in texts:
		var node = find_node(FORMAT_LABEL % text)
		if node != null:
			if node is RichTextLabel:
				node.bbcode_text = Interface.final_text(self, text)
			else:
				node.text = Interface.final_text(self, text)

# Makes the card appear in front of others Node2D
func bring_front():
	z_index = VisualServer.CANVAS_ITEM_Z_MAX

# Makes the card appear behind of others Node2D
func send_back():
	z_index = VisualServer.CANVAS_ITEM_Z_MIN

# Makes the card returns to its normal z position
func reset_z_index():
	z_index = default_z

# Allows to define a z index for the cards so if they overlap you can order them
func set_default_z(new_value):
	default_z = new_value
	z_index = new_value

func _on_mouse_area_entered():
	emit_signal("mouse_entered")
	$animations.play("flip_back")

func _on_mouse_area_exited():
	emit_signal("mouse_exited")
	$animations.play("flip")

func flip_back():
	$animations.play("flip_back")

func _on_mouse_area_event(event):
	if event is InputEventMouseMotion:
#		emit_signal("mouse_motion", event.relative)
		pass
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_pressed")#, event.button_index)
		else:
			emit_signal("left_released")#, event.button_index)
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			emit_signal("right_pressed")#, event.button_index)
		else:
			emit_signal("right_released")

func mouse_disconnect():
	$mouse_area.disconnect("mouse_exited", self, "_on_mouse_area_exited")
	
func mouse_connect():
	$mouse_area.connect("mouse_exited", self, "_on_mouse_area_exited")
