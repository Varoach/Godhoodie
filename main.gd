# Main scene - Demo main scene
extends Node

var _screens = {
		"menu": preload("res://screens/menu/screen_menu.tscn"),
		"library": preload("res://screens/library/screen_library.tscn"),
		"new_game": preload("res://screens/new_game/screen_new_game.tscn"),
		"map": preload("res://screens/menu/screen_menu.tscn"),
		"game": preload("res://screens/game/screen_game.tscn")
	}

func _ready():
	change_screen("menu")

func change_screen(screen_name):
	if !_screens.has(screen_name): return
	Game.return_state()
	
	for child in $screen_layer.get_children():
		$screen_layer.remove_child(child)
		child.queue_free()
	
	var screen = _screens[screen_name].instance()
	screen.connect("next_screen", self, "change_screen")
	$screen_layer.add_child(screen)
