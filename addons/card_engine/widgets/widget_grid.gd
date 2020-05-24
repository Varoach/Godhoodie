# GridWidget class - Display cards in a grid
extends Control

# Space in pixels between the cards horizontally and vertically
export(Vector2) var card_spacing = Vector2(0, 0)
export(Vector2) var offset = Vector2(0, 0)

export(int) var centered_vertical_offset = 400
# Number of columns
export(int) var columns = 4

export(float) var card_ratio = 1

var card_max = 8

signal play(card)

var grabbed_offset = Vector2(0,-50)

onready var inventory = get_node("../../../..")
var _focused_card = null
var _active_cards = Node2D.new()
var _used_cards = Node2D.new()
export(NodePath) var use_point

func _ready():
	CardDB.connect("card_added", self, "_on_card_added")
	connect("resized", self, "_on_resized")
	inventory.connect("jutsu_played", self, "_on_card_played")
	CardDB.pickup_card("two_handse")
	CardDB.pickup_card("two_handse")
	CardDB.pickup_card("two_handse")
	CardDB.pickup_card("two_handse")

func _process(delta):
	if _focused_card != null and _focused_card.drag:
		_focused_card.global_position = get_global_mouse_position() + grabbed_offset

func _on_card_added():
	_update_grid()

func _update_grid():
	for child in get_children():
		remove_child(child)

	for card in Game.player_inventory.cards:
		if !card.ready:
			card.connect("mouse_entered", self, "_on_card_mouse_entered", [card])
			card.connect("mouse_exited", self, "_on_card_mouse_exited", [card])
			card.connect("left_pressed", self, "_on_card_left_pressed", [card])
			card.connect("left_released", self, "_on_card_left_released", [card])
			card.connect("right_pressed", self, "_on_card_right_pressed", [card])
			card.connect("right_released", self, "_on_card_right_released", [card])
			card.connect("mouse_motion", self, "_on_mouse_motion", [card])
			card.ready = true
		
		add_child(card)
	
	_on_resized()

func _on_resized():
	yield(get_tree(), "idle_frame")
	var card_index = 0
	var total_card = Game.player_inventory.cards.size()
	var card_widget = CardDB.custom_card.instance()
	var final_row = 0
	
	# Size calculations
	var card_width = round((rect_size.x - (columns+1)*card_spacing.x) / columns)
	var ratio = (card_width / card_widget.default_size.x)
	var size = Vector2(card_width, round(card_widget.default_size.y * ratio))
		
	for card_widget in get_children():
		# Position calculations
		var col = card_index%columns
		var row = floor(card_index / columns)
		var pos = size*Vector2(col, row) + Vector2(size.x, size.y)/2 + card_spacing*Vector2(col+1, row+1) - offset
		
		if row > final_row:
			final_row = row
		card_widget.position = pos
		card_widget.scale = card_widget.calculate_scale(size) * card_ratio
		card_widget.save_animation_state()
		card_widget.before_scale = card_widget.scale
#		card_widget.push_animation_state(pos, 0, card_widget.calculate_scale(size) * card_ratio, false, false, false)
		
		card_index += 1
	
	# Minimum height calculation to fit all rows
	rect_min_size.y = (final_row+1)*(size.y + card_spacing.y)

func set_focused_card(card):
	if _focused_card != null: return
	_focused_card = card
	_focused_card.bring_front()
	card.push_animation_state(Vector2(0,0), 0, 1.35, true, false, true)

func unset_focused_card(card):
	if _focused_card != card: return
	card.pop_animation_state()
	_focused_card = null
	card.reset_z_index()

func _on_card_mouse_entered(card):
	if card.highlight: return
	set_focused_card(card)

func _on_card_mouse_exited(card):
	if card.highlight: return
	unset_focused_card(card)

func _on_card_left_pressed(card):
	if _focused_card != card: return
	if _focused_card.highlight:
		unset_highlight_card(card)
	else:
		_focused_card.drag = true

func _on_card_left_released(card):
	if _focused_card != card: return
	if _focused_card.highlight: return
	if _focused_card.drag:
		play(card)

func _on_card_right_pressed(card):
	if _focused_card != card: return
	if _focused_card.drag: return
	if card.highlight:
		unset_highlight_card(card)
		inventory.highlight = false
	elif !inventory.highlight:
		set_highlight_card(card)
		inventory.highlight = true
		inventory.emit_signal("highlight", card)

func _on_card_right_released(card):
	if _focused_card != card: return
	if _focused_card.drag: return

func unset_highlight_card(card):
	if _focused_card != card: return
	card.pop_animation_state_global()
	inventory.emit_signal("unhighlight", card)
	card.flip_back()
	card.highlight = false
	card.mouse_disconnect()
	_focused_card = null
	yield(get_tree().create_timer(0.6), "timeout")
	card.mouse_connect()
	

func set_highlight_card(card):
	if _focused_card != card: return
	card.highlight = true
	card.display_center()

func play(card):
	if _focused_card != card: return
	card.drag = false
	emit_signal("play", card, card.targets, name, card.bars)

func _on_card_played(card, status):
	if status:
		unset_focused_card(card)
		_on_resized()
	else:
		unset_focused_card(card)
		_on_resized()

func _apply_discard_transform(widget):
	if not use_point.is_empty():
		widget.push_animation_state(
			_to_local(get_node(use_point).global_position), 90, Vector2(0,0), false, false, false)
		return true
	return false

func _to_local(point):
	return get_global_transform().affine_inverse().xform(point)
