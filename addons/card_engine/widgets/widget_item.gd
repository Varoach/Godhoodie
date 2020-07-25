extends Node2D

const FORMAT_LABEL = "lbl_%s"
const FORMAT_IMAGE = "img_%s"

var default_z = 0 setget set_default_z

var targets = ""
var title = ""
var anim_ready = ""
var anim_use = ""
var tags = []
var real_title = ""
var desc = ""
var ability = null
var values = {}
var bars = {}
var size = Vector2()
var texture_original
var texture_rotate
var rotated = false
var flipped = false
var ready = false
var buffs = {}
onready var image = get_node("Image")

var _animation = Tween.new()
var _animation_stack = []
var _animation_stack_global = []
var drag = false
var highlight = false
var rarity = ""
var weapon_state = {}

signal mouse_entered()
signal mouse_exited()
signal mouse_motion(relative)
signal left_pressed()#button)
signal left_released()#button)
signal right_pressed()
signal right_released()
signal shake()
signal shake_done()

class AnimationState extends Reference:
	var pos = Vector2(0.0, 0.0)
	var rot = 0.0
	var scale = Vector2(1.0, 1.0)

# Animation speed in second
export(float) var animation_speed = 0.6

func _init():
	add_child(_animation)

func _ready():
	connect("shake", self, "_on_shake")
	$Image.connect("mouse_entered", self, "_on_mouse_area_entered")
	$Image.connect("mouse_exited", self, "_on_mouse_area_exited")
	$Image.connect("gui_input", self, "_on_mouse_area_event")
	_animation.connect("tween_completed", self, "_on_animation_completed")

func _process(delta):
	if not _animation.is_active():
		_animation.start()

func _exit_tree():
	_animation.stop_all()

func _on_shake():
	$animations.play("shake")

# Adds an animation state from the current values
func push_animation_state_from_current():
	var state = AnimationState.new()
	state.pos = position
	state.rot = rotation_degrees
	state.scale = scale
	_animation_stack.push_back(state)

# Adds an animation state from the given values and animate the card to the state
func push_animation_state(pos, rot, scale_ratio, is_pos_relative=false, is_rot_relative=false, is_scale_relative=false):
	var previous_state = null
	if !_animation_stack.empty():
		previous_state = _animation_stack.back()
	else:
		previous_state = AnimationState.new()
		previous_state.pos = position
		previous_state.rot = rotation_degrees
		previous_state.scale = scale
		
	var state = AnimationState.new()
	state.pos = pos if !is_pos_relative else previous_state.pos + pos
	state.rot = rot if !is_rot_relative else previous_state.rot + rot
	state.scale = scale_ratio if !is_scale_relative else previous_state.scale*scale_ratio
	_animation_stack.push_back(state)
	_animate(previous_state, state)

func save_animation_state():
	var state = AnimationState.new()
	state.pos = position
	state.rot = rotation
	state.scale = scale
	_animation_stack.push_back(state)

 #Removes the last animation state and animate the card to the previous state
func pop_animation_state():
	if _animation_stack.empty(): return
	var state = _animation_stack.pop_back()
	if !_animation_stack.empty():
		var previous_state = _animation_stack.back()
		_animate(state, previous_state)
		#call_deferred("_animate(state, previous_state)")

# Internal animation from one state to another
func _animate(from_state, to_state):
	_animation.interpolate_property(
		self, "position", from_state.pos, to_state.pos, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "rotation_degrees", from_state.rot, to_state.rot, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "scale", from_state.scale, to_state.scale, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

func _on_mouse_area_entered():
	emit_signal("mouse_entered")

func _on_mouse_area_exited():
	emit_signal("mouse_exited")

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

func _on_animation_completed(object, key):
	_animation.remove(object, key)

# Makes the card appear in front of others Node2D
func bring_front():
	z_index = 2

func bring_super_front():
	z_index = 1

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

func pop_animation_state_global():
	if _animation_stack_global.empty(): return
	var state = _animation_stack_global.pop_back()
	if !_animation_stack_global.empty():
		var previous_state = _animation_stack_global.back()
		_animate_global(state, previous_state)
	_animation_stack_global.clear()

func _animate_global(from_state, to_state):
	_animation.interpolate_property(
		self, "global_position", from_state.pos, to_state.pos, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "global_rotation_degrees", from_state.rot, to_state.rot, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "global_scale", from_state.scale, to_state.scale, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

func push_animation_state_global(pos, rot, scale_ratio, is_pos_relative=false, is_rot_relative=false, is_scale_relative=false):
	var previous_state = null
	if !_animation_stack_global.empty():
		previous_state = _animation_stack_global.back()
	else:
		previous_state = AnimationState.new()
		previous_state.pos = global_position
		previous_state.rot = global_rotation_degrees
		previous_state.scale = global_scale
		_animation_stack_global.push_back(previous_state)
	
	var state = AnimationState.new()
	state.pos = pos if !is_pos_relative else previous_state.pos + pos
	state.rot = rot if !is_rot_relative else previous_state.rot + rot
	state.scale = scale_ratio if !is_scale_relative else previous_state.scale*scale_ratio
	_animation_stack_global.push_back(state)
	_animate_global(previous_state, state)

func display_center():
	push_animation_state_global(Vector2((get_viewport_rect().size/2).x-($Image.rect_size.x)-50,(get_viewport_rect().size/2).y-250-($Image.rect_size.y)), 0, 3, false, false, true)

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
	var item_state = {}
	item_state.texture = $Image.texture
	item_state.rect_size = $Image.rect_size
	item_state.position = global_position
	item_state.rotated = rotated
	item_state.flipped = flipped
	item_state.flip_v = $Image.flip_v
	item_state.flip_h = $Image.flip_h
	return item_state

func return_item_state(state):
	$Image.texture = state.texture
	$Image.rect_size = state.rect_size
	global_position = state.position
	$Image.flip_v = state.flip_v
	$Image.flip_h = state.flip_h
	rotated = state.rotated
	flipped = state.flipped

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

func _on_stop_shake():
	$animations.stop(true)

func _on_animation_finished(shake):
	emit_signal("shake_done")
