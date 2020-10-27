extends TileMap

signal left_pressed()
signal left_released()
signal right_pressed()
signal right_released()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
#		emit_signal("mouse_motion", event.relative)
		pass
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_pressed", world_to_map(get_local_mouse_position()))
		else:
			emit_signal("left_released")
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			emit_signal("right_pressed")
		else:
			emit_signal("right_released")
