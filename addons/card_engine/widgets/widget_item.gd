extends Node2D

const FORMAT_LABEL = "lbl_%s"
const FORMAT_IMAGE = "img_%s"

var default_z = 0 setget set_default_z

var targets = ""
var values = {}
var bars = {}
var texture_original
var texture_rotate
var rotated = false
var flipped = false
var item_state = {}

func rotate_item(rotation):
	if rotation == "right":
		rotate_right()
	if rotation == "left":
		rotate_left()

func rotate_right():
	if not flipped and not rotated:
		$Image.texture = texture_rotate
		flip_me()
		$Image.flip_h = false
		$Image.flip_v = false
		rotated = true
		flipped = false
	elif rotated and not flipped:
		$Image.texture = texture_original
		flip_me()
		$Image.flip_v = true
		$Image.flip_h = false
		rotated = false
		flipped = true
	elif not rotated and flipped:
		$Image.texture = texture_rotate
		flip_me()
		$Image.flip_v = false
		$Image.flip_h = true
		rotated = true
		flipped = true
	elif rotated and flipped:
		$Image.texture = texture_original
		flip_me()
		$Image.flip_v = false
		$Image.flip_h = false
		rotated = false
		flipped = false

func rotate_left():
	if not flipped and not rotated:
		$Image.texture = texture_rotate
		flip_me()
		$Image.flip_h = true
		$Image.flip_v = false
		rotated = true
		flipped = true
	elif rotated and not flipped:
		$Image.texture = texture_original
		flip_me()
		$Image.flip_v = false
		$Image.flip_h = false
		rotated = false
		flipped = false
	elif not rotated and flipped:
		$Image.texture = texture_rotate
		flip_me()
		$Image.flip_v = false
		$Image.flip_h = false
		rotated = true
		flipped = false
	elif rotated and flipped:
		$Image.texture = texture_original
		flip_me()
		$Image.flip_v = true
		$Image.flip_h = false
		rotated = false
		flipped = true

func save_item_state():
	item_state.texture = $Image.texture
	item_state.rect_size = $Image.rect_size
	item_state.position = global_position
	item_state.rotated = rotated
	item_state.flipped = flipped
	item_state.flip_v = $Image.flip_v
	item_state.flip_h = $Image.flip_h

func return_item_state():
	$Image.texture = item_state.texture
	$Image.rect_size = item_state.rect_size
	global_position = item_state.position
	$Image.flip_v = item_state.flip_v
	$Image.flip_h = item_state.flip_h
	rotated = item_state.rotated
	flipped = item_state.flipped
	item_state.clear()

func flip_me():
	var temp = $Image.rect_size.x
	$Image.rect_size.x = $Image.rect_size.y
	$Image.rect_size.y = temp

func recenter_item():
	position = Vector2(0, 0)

func set_texture(set):
	$Image.texture = set

func set_size(set):
	$Image.rect_size = set

func set_scale(set):
	$Image.rect_scale = set

func get_size():
	return $Image.rect_size

func get_global_rect():
	return $Image.get_global_rect()

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
