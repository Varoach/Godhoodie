# GridWidget class - Display cards in a grid
extends Control

# Space in pixels between the cards horizontally and vertically
export(Vector2) var card_spacing = Vector2(0, 0)
export(Vector2) var offset = Vector2(0, 0)

export(int) var centered_vertical_offset = 400
# Number of columns
export(int) var columns = 3

export(float) var card_ratio = 0.6

signal highlight()
signal unhighlight()
signal play(card)

var grabbed_offset = Vector2(0,-50)

onready var inventory = get_node("../../../../../..")
var _container = null
var _focused_card = null
var _active_cards = Node2D.new()
var _used_cards = Node2D.new()
export(NodePath) var use_point

func _ready():
#	add_child(_active_cards)
#	add_child(_discarded_cards)
	connect("resized", self, "_on_resized")

func _process(delta):
	if _focused_card != null and _focused_card.drag:
		_focused_card.position = get_global_mouse_position() + grabbed_offset

func set_container(container):
	_container = container
	_container.connect("card_added", self, "_on_container_card_added")
	_container.connect("multiple_card_added", self, "_on_container_multiple_card_added")
	_container.connect("card_removed", self, "_on_container_card_removed")
	_update_grid()

func _update_grid():
	for child in get_children():
		remove_child(child)

	for card in _container.cards():
		var card_widget = CEInterface.card_instance()
		card_widget.set_card_data(card)
		
		card_widget.connect("mouse_entered", self, "_on_card_mouse_entered", [card_widget])
		card_widget.connect("mouse_exited", self, "_on_card_mouse_exited", [card_widget])
		card_widget.connect("left_pressed", self, "_on_card_left_pressed", [card_widget])
		card_widget.connect("left_released", self, "_on_card_left_released", [card_widget])
		card_widget.connect("right_pressed", self, "_on_card_right_pressed", [card_widget])
		card_widget.connect("right_released", self, "_on_card_right_released", [card_widget])
		card_widget.connect("mouse_motion", self, "_on_mouse_motion", [card_widget])
		
		add_child(card_widget)
	
	_on_resized()

func _update_grid_play():
	pass

func _on_resized():
	yield(get_tree(), "idle_frame")
	var card_index = 0
	var total_card = _container.size()
	var card_widget = CEInterface.card_instance()
	var final_row = 0
	
	# Size calculations
	var card_width = round((rect_size.x - (columns+1)*card_spacing.x) / columns)
	var ratio = card_width / card_widget.default_size.x*card_ratio
	var size = Vector2(card_width, round(card_widget.default_size.y*card_ratio * ratio))
		
	for card_widget in get_children():
		# Position calculations
		var col = card_index%columns
		var row = floor(card_index / columns)
		var pos = size*Vector2(col, row) + Vector2(size.x, size.y)/2 + card_spacing*Vector2(col+1, row+1) - offset
		
		if row > final_row:
			final_row = row
		
		card_widget.push_animation_state(pos, 0, card_widget.calculate_scale(size), false, false, false)
		
		card_index += 1
	
	# Minimum height calculation to fit all rows
	rect_min_size.y = (final_row+1)*(size.y + card_spacing.y)

func set_focused_card(card):
	if _focused_card != null: return
	_focused_card = card
	_focused_card.bring_front()
	card.push_animation_state(Vector2(0, 0), 0, Vector2(1.05, 1.05), true, true, true)

func unset_focused_card(card):
	if _focused_card != card: return
	_focused_card.pop_animation_state()
	_focused_card.reset_z_index()
	_focused_card = null

func unset_selected_card(card):
	if _focused_card != card: return
	_focused_card.pop_animation_state()

func _on_card_mouse_entered(card):
	set_focused_card(card)

func _on_card_mouse_exited(card):
	unset_focused_card(card)

func _on_card_left_pressed(card):
	if _focused_card != card: return
	if _focused_card.highlight:
		unset_highlight_card(card)
	else:
		_focused_card.drag = true
		_focused_card.set_as_toplevel(true)

func _on_card_left_released(card):
	if _focused_card != card: return
	if _focused_card.highlight: return
	if _focused_card.drag:
		play(card)

func _on_card_right_pressed(card):
	if _focused_card != card: return
	if _focused_card.drag: return
	if _focused_card.highlight:
		unset_highlight_card(card)
	else:
		_focused_card.set_as_toplevel(true)
		card.highlight = true
		set_highlight_card(card)
		card.mouse_disconnect()
		emit_signal("highlight")

func _on_card_right_released(card):
	if _focused_card != card: return
	if _focused_card.drag: return

func unset_highlight_card(card):
	if _focused_card != card: return
#	focused_card.set_as_toplevel(false)
	card.highlight = false
	unset_selected_card(card)
	card.mouse_connect()
	emit_signal("unhighlight")
	$"../".scroll_vertical_enabled = true

func set_highlight_card(card):
	if _focused_card != card: return
#	_focused_card.set_as_toplevel(true)
	$"../".scroll_vertical_enabled = false
	_focused_card.push_animation_state(Vector2(rect_size.x/2, centered_vertical_offset), 0, Vector2(1.5,1.5), false, false, true)

func play(card):
	if _focused_card != card: return
	card.set_as_toplevel(false)
	card.drag = false
	if Game._current_step == 1 and inventory.played == false and playable(card):
		_focused_card = null
		inventory.played = true
		if name == "items" or name == "weapons":
			_container.remove(card.get_index())
			_update_grid()
		_on_resized()
		emit_signal("play", card, name)
	else:
		card.pop_animation_state()
		unset_focused_card(card)
		_on_resized()
		set_focused_card(card)

func playable(card):
	var targets = card._card_data.targets
	if targets == "single":
		if $"../../../../../../.."._check_targets() != null:
			return true
		else:
			return false
	elif targets != "single":
		if $"../../../../../../../Playable".get_rect().has_point(get_global_mouse_position()):
			return true
		else:
			return false

func _remove_card_widget(card):
	for card_widget in _active_cards.get_children():
		if card_widget.get_card_data() == card:
			_active_cards.remove_child(card_widget)
			_used_cards.add_child(card_widget)
			if _apply_discard_transform(card_widget):
				# If a transform has been applied we wait a second for the animation to finish
				yield(get_tree().create_timer(0.5), "timeout")
			_used_cards.remove_child(card_widget)
			card_widget.queue_free()

func _apply_discard_transform(widget):
	if not use_point.is_empty():
		widget.push_animation_state(
			_to_local(get_node(use_point).global_position), 90, Vector2(0,0), false, false, false)
		return true
	return false

func _to_local(point):
	return get_global_transform().affine_inverse().xform(point)

func _on_container_card_removed(card):
	_remove_card_widget(card)
	_on_resized()
