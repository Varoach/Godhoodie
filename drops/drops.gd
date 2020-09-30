extends Node2D

var held_object = null

func _ready():
	pickable_set()

func pickable_set():
	for node in get_tree().get_nodes_in_group("pickable"):
#		node.disconnect("left_pressed", self, "_on_pickable_left_pressed")
		if !node.is_connected("left_pressed", self, "_on_pickable_left_pressed"):
			node.connect("left_pressed", self, "_on_pickable_left_pressed")

func _on_pickable_left_pressed(object):
	if !held_object:
		held_object = object
		held_object.lift()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if held_object and !event.pressed:
			held_object.drop(Input.get_last_mouse_speed())
			held_object = null
