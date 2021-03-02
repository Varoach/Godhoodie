extends Control

var _animation = Tween.new()

func _init():
	add_child(_animation)

#returns the position of character in question
func get_char_position(character):
	character.get_position()

#returns the character at the position, otherwise return null
func get_character(position):
	if $positions.get_child(position).get_children().empty():
		return null
	return $positions.get_child(position).get_child(0)

func direction_check(first_spot, active_spot):
	if active_spot - first_spot > 0:
		return true
	else:
		return false

func _move(character, position):
	if position > 8 or position < 0:
		return
	var curr_spot = character.get_position()
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(position).add_child(character)

func _prep_slide(character, move_spot):
	var curr_spot = character.get_position()
	_animation.interpolate_property(character, "global_position:x", character.global_position.x, $positions.get_child(move_spot).global_position.x, 0.2 * (abs(move_spot - curr_spot)),Tween.TRANS_SINE, Tween.EASE_OUT)
	yield(_animation, "tween_all_completed")
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(move_spot).add_child(character)
	character.moving = false

func _force_slide(move_spot, right):
	var blocking_character = get_character(move_spot)
	var push_spot
	if right:
		push_spot = move_spot - 1
		if push_spot < 0:
			push_spot + 2
	else:
		push_spot = move_spot + 1
		if push_spot > 8:
			push_spot - 2
	get_character(move_spot).moving = true
	if get_character(push_spot):
		if !get_character(push_spot).is_moving():
			_force_slide(push_spot, right)
	_prep_slide(blocking_character, push_spot)

func _slide(character, amount, absolute = false):
	if character.is_moving():
		return
	var curr_spot = character.get_position()
	var move_spot = int(clamp(amount + curr_spot, 0, $positions.get_child_count()-1))
	if move_spot > 8 or move_spot < 0 or move_spot == curr_spot:
		return
	if _animation.is_active():
		yield(_animation, "tween_all_completed")
	character.moving = true
	if get_character(move_spot):
		_force_slide(move_spot, direction_check(curr_spot, move_spot))
	character.bring_front()
	_animation.interpolate_property(character, "global_position:x", $positions.get_child(curr_spot).global_position.x, $positions.get_child(move_spot).global_position.x, 0.2 * (abs(move_spot - curr_spot)),Tween.TRANS_SINE, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_all_completed")
	character.send_back()
	$positions.get_child(curr_spot).remove_child(character)
	character.position.x = 0
	$positions.get_child(move_spot).add_child(character)
	character.moving = false

func _hop(character, position):
	pass
