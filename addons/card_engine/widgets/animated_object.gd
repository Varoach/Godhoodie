extends Node2D

var _animation = Tween.new()
var _animation_stack = []
var _animation_stack_global = []

# Animation speed in second
export(float) var animation_speed = 1

var before_scale = Vector2()

class AnimationState extends Reference:
	var pos = Vector2(0.0, 0.0)
	var rot = 0.0
	var scale = Vector2(1.0, 1.0)

func _init():
	add_child(_animation)

func _ready():
	_animation.connect("tween_completed", self, "_on_animation_completed")

func _process(delta):
	if not _animation.is_active():
		_animation.start()

func _exit_tree():
	_animation.stop_all()

func _on_animation_completed(object, key):
	_animation.remove(object, key)

# Adds an animation state from the current values
func push_animation_state_from_current():
	var state = AnimationState.new()
	state.pos = position
	state.rot = rotation_degrees
	state.scale = scale
	_animation_stack.push_back(state)

func display_center():
	_animation_stack.pop_back()
	push_animation_state_global(Vector2((get_viewport_rect().size/2).x,(get_viewport_rect().size/2).y-250), 0, 3, false, false, true)

func push_animation_state_global(pos, rot, scale_ratio, is_pos_relative=false, is_rot_relative=false, is_scale_relative=false):
	var previous_state = null
	if !_animation_stack_global.empty():
		previous_state = _animation_stack_global.back()
	else:
		previous_state = AnimationState.new()
		previous_state.pos = global_position
		previous_state.rot = global_rotation_degrees
		previous_state.scale = before_scale
		_animation_stack_global.push_back(previous_state)
	
	var state = AnimationState.new()
	state.pos = pos if !is_pos_relative else previous_state.pos + pos
	state.rot = rot if !is_rot_relative else previous_state.rot + rot
	state.scale = scale_ratio if !is_scale_relative else previous_state.scale*scale_ratio
	_animation_stack_global.push_back(state)
	_animate_global(previous_state, state)

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
	state.rot = rotation_degrees
	state.scale = scale
	_animation_stack.push_back(state)

func save_animation_state_global():
	var state = AnimationState.new()
	state.pos = global_position
	state.rot = global_rotation_degrees
	state.scale = global_scale
	_animation_stack_global.push_back(state)

 #Removes the last animation state and animate the card to the previous state
func pop_animation_state():
	if _animation_stack.empty(): return
	var state = _animation_stack.pop_back()
	if !_animation_stack.empty():
		var previous_state = _animation_stack.back()
		_animate(state, previous_state)
		#call_deferred("_animate(state, previous_state)")

func pop_animation_state_global():
	if _animation_stack_global.empty(): return
	var state = _animation_stack_global.pop_back()
	if !_animation_stack_global.empty():
		var previous_state = _animation_stack_global.back()
		_animate_global(state, previous_state)

# Internal animation from one state to another
func _animate(from_state, to_state):
	_animation.interpolate_property(
		self, "position", from_state.pos, to_state.pos, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "rotation_degrees", from_state.rot, to_state.rot, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "scale", from_state.scale, to_state.scale, animation_speed, Tween.TRANS_BACK, Tween.EASE_OUT)

func _animate_global(from_state, to_state):
	_animation.interpolate_property(
		self, "global_position", from_state.pos, to_state.pos, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "global_rotation_degrees", from_state.rot, to_state.rot, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)

	_animation.interpolate_property(
		self, "global_scale", from_state.scale, to_state.scale, animation_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
