# HandWidget class - Display cards like you have them in hand
extends Control

# Amount the card overlaps horizontally to reduce hand's width
export(int) var card_overlap = -125

# Amount the card is offset vertically, at 0 only the top-half of the card is within the hand's height
export(int) var vertical_offset = 200

# Cumulative angle between cards in degree
export(float) var card_angle = 3

# Amount the card is moved when the mouse hover it
export(Vector2) var mouse_hover_offset = Vector2(0, -280)

# Amount the card is moved vertically when selected
export(int) var selected_vertical_offset = -100

export(int) var centered_vertical_offset = -975

signal highlight()
signal unhighlight()
signal play(card)

# Position from where cards are drawn
export(NodePath) var draw_point

# Position to where cards are discarded
export(NodePath) var discard_point

var _container = null
var _focused_card = null
var _active_cards = Node2D.new()
var _discarded_cards = Node2D.new()
var place = null
var grabbed_offset = Vector2(-100,-1900)
var mouse_state = false
var press = null
var played = false

func _ready():
	add_child(_active_cards)
	add_child(_discarded_cards)
	connect("resized", self, "_apply_hand_transform")

#func _input_event(viewport, event, shape_idx):
#		grabbed_offset = _focused_card.position - get_global_mouse_position()

func _process(delta):
	if _focused_card != null and _focused_card.drag:
		_focused_card.position = get_global_mouse_position() + grabbed_offset

func set_container(container):
	_container = container
	_container.connect("card_added", self, "_on_container_card_added")
	_container.connect("multiple_card_added", self, "_on_container_multiple_card_added")
	_container.connect("card_removed", self, "_on_container_card_removed")

func set_focused_card(card):
	if _focused_card != null: return
	_focused_card = card
	_focused_card.bring_front()
	_focused_card.push_animation_state(mouse_hover_offset, 0, Vector2(1.25,1.25), true, false, true)

func unset_focused_card(card):
	if _focused_card != card: return
	_focused_card.pop_animation_state()
	_focused_card.reset_z_index()
	_focused_card = null

func set_selected_card(card):
	if _focused_card != card: return
#	_focused_card.position += place
	_focused_card.push_animation_state(Vector2(rect_size.x/2, selected_vertical_offset), 0, Vector2(1.5,1.5), false, true, true)

func unset_selected_card(card):
	if _focused_card != card: return
	_focused_card.pop_animation_state()

func _add_card_widget(card):
	var card_widget = CEInterface.card_instance()
	card_widget.set_card_data(card)
	_active_cards.add_child(card_widget)
	
	card_widget.connect("mouse_entered", self, "_on_card_mouse_entered", [card_widget])
	card_widget.connect("mouse_exited", self, "_on_card_mouse_exited", [card_widget])
	card_widget.connect("left_pressed", self, "_on_card_left_pressed", [card_widget])
	card_widget.connect("left_released", self, "_on_card_left_released", [card_widget])
	card_widget.connect("right_pressed", self, "_on_card_right_pressed", [card_widget])
	card_widget.connect("right_released", self, "_on_card_right_released", [card_widget])
	card_widget.connect("mouse_motion", self, "_on_mouse_motion", [card_widget])
	
	return card_widget

func _remove_card_widget(card):
	for card_widget in _active_cards.get_children():
		if card_widget.get_card_data() == card:
			_active_cards.remove_child(card_widget)
			_discarded_cards.add_child(card_widget)
			if _apply_discard_transform(card_widget):
				# If a transform has been applied we wait a second for the animation to finish
				yield(get_tree().create_timer(0.5), "timeout")
			_discarded_cards.remove_child(card_widget)
			card_widget.queue_free()
			#card_widget.call_deferred("queue_free")

func _apply_hand_transform():
	yield(get_tree(), "idle_frame")
	var card_index = 0
	var total_card = _container.size()
	var half_total = float(total_card) / 2.0 # Using float to deal with odd card number
	var final_overlap = card_overlap
	var card_widget = CEInterface.card_instance()
	
	# Size calculations
	var card_height = rect_size.y*2
	var ratio = card_height / card_widget.default_size.y
	var size = Vector2(round(card_widget.default_size.x * ratio), card_height)
	
	# Overlap check
	var total_width = (size.x - card_overlap) * total_card
	if total_width > rect_size.x:
		# If the hand is larger than the widget, we recalculate an overlap which make all the cards visible
		final_overlap = ceil((size.x*total_card-rect_size.x)/(total_card-1))
	
	for card_widget in _active_cards.get_children():
		# Position calculations
		var middle = rect_size.x/2 
		var dist = float(card_index) - half_total + 0.5 # We add 0.5 so the distance is from the middle of the card
		var pos = Vector2(middle+dist*(size.x-final_overlap), -vertical_offset+card_height/2)
		
		# Rotation calculations
		var rot = card_angle*dist
		
		card_widget.default_z = card_index
		card_widget.push_animation_state(pos, rot, card_widget.calculate_scale(size), false, false, false)
		
		card_index += 1

func _apply_draw_transform(widget):
	if not draw_point.is_empty():
		widget.global_position = get_node(draw_point).global_position
		widget.rotation_degrees = 90
		widget.scale = Vector2(0, 0)
		return true
	return false

func _apply_discard_transform(widget):
	if not discard_point.is_empty():
		widget.push_animation_state(
			_to_local(get_node(discard_point).global_position), 90, Vector2(0,0), false, false, false)
		return true
	return false

# Implementation of Node2D to_local function as it is not present in Control
func _to_local(point):
	return get_global_transform().affine_inverse().xform(point)

func _on_container_card_added(card):
	var widget = _add_card_widget(card)
	_apply_draw_transform(widget)
	_apply_hand_transform()

func _on_container_multiple_card_added(cards):
	for card in cards:
		#for amount in inventory:
		var widget = _add_card_widget(card)
		_apply_draw_transform(widget)
	_apply_hand_transform()
	
func _on_container_card_removed(card):
	_remove_card_widget(card)
	_apply_hand_transform()

func _on_card_mouse_entered(card):
	set_focused_card(card)

func _on_card_mouse_exited(card):
	unset_focused_card(card)

func _on_card_left_pressed(card):
	if _focused_card != card: return
	if _focused_card.highlight:
		unset_selected_card(card)
		card.mouse_connect()
		card.highlight = false
		emit_signal("unhighlight")
	else:
		_focused_card.drag = true
		shrink_card(card)

func _on_card_left_released(card):
	if _focused_card != card: return
	if _focused_card.highlight: return
	if _focused_card.drag:
		play(card)

func _on_card_right_pressed(card):
	if _focused_card != card: return
	if _focused_card.drag: return
	if _focused_card.highlight:
		unset_selected_card(card)
		card.mouse_connect()
		card.highlight = false
		emit_signal("unhighlight")
	else:
		_focused_card.highlight = true
		set_highlight_card(card)
		card.mouse_disconnect()
		emit_signal("highlight")
	
func _on_card_right_released(card):
	if _focused_card != card: return
	if _focused_card.drag: return

# Highlight selected card and display in center of screen for player to read easily
func set_highlight_card(card):
	if _focused_card != card: return
	_focused_card.push_animation_state(Vector2(rect_size.x/2, centered_vertical_offset), 0, Vector2(2,2), false, false, true)

func shrink_card(card):
	card.push_animation_state(Vector2(0,0), 0,  Vector2(0.15,0.15))

func play(card):
	if Game._current_step == 1 and played == false and playable(card):
		card.drag = false
		_focused_card = null
		played = true
		Game.discard_card(card.get_index())
		emit_signal("play", card)
	else:
		_focused_card.drag = false
		card.pop_animation_state()
		unset_focused_card(card)
		#yield(get_tree().create_timer(0.25), "timeout")
		set_focused_card(card)

func playable(card):
	var targets = card._card_data.targets
	if targets == "single":
		if $"../.."._check_targets() != null:
			return true
		else:
			return false
	elif targets != "single":
		if $"../../Playable".get_rect().has_point(get_global_mouse_position()):
			return true
		else:
			return false
	
