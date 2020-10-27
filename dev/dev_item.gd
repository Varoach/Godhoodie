extends TextureRect

signal left_pressed()
signal left_released()
signal right_pressed()
signal right_released()

var item_id = ""

var _animation = Tween.new()

func init():
	add_child(_animation)

func _gui_input(event):
	if event is InputEventMouseMotion:
#		emit_signal("mouse_motion", event.relative)
		pass
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_pressed", item_id)#, event.button_index)
		else:
			emit_signal("left_released")#, event.button_index)
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			emit_signal("right_pressed")#, event.button_index)
		else:
			emit_signal("right_released")
