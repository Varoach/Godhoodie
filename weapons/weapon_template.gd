extends Node2D

var foreground_image
var background_image
var highlight = false

var weapon_shader = load("res://weapons/weapon_background.tres")

var drag = false
var ready = false

signal left_pressed()#button)
signal left_released()#button)

func _ready():	
	$mouse_area.connect("gui_input", self, "_on_mouse_area_event")

func get_weapon():
	return $background/weapon_hold.get_child(0)

func set_weapon(weapon):
	$background/weapon_hold.add_child(weapon)
	$background/title.text = weapon.name.capitalize()

func texture_setup(image, back):
	$background.texture = image
	foreground_image = image
	background_image = back
	$animations.get_animation("flip").track_set_key_value(0,0,foreground_image)
	$animations.get_animation("flip").track_set_key_value(0,1,background_image)
	$animations.get_animation("flip_back").track_set_key_value(0,0,background_image)
	$animations.get_animation("flip_back").track_set_key_value(0,1,foreground_image)

func _on_mouse_area_mouse_entered():
	#	emit_signal("mouse_entered")
	Game.player.animation("ready")
	$animations.play("flip")

func _on_mouse_area_mouse_exited():
		#	emit_signal("mouse_exited")
	Game.player.animation("default")
	$animations.play("flip_back")

func _on_mouse_area_event(event):
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
