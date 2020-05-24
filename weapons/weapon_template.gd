extends Node2D

var foreground_image
var background_image
var highlight = false

var weapon_shader = load("res://weapons/weapon_background.tres")

var drag = false

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
	$animations.play("flip")


func _on_mouse_area_mouse_exited():
		#	emit_signal("mouse_exited")
	$animations.play("flip_back")
