extends Node

var _screens = {
		"menu": preload("res://screens/menu/screen_menu.tscn"),
		"new_game": preload("res://screens/new_game/screen_new_game.tscn"),
		"map": preload("res://screens/map/screen_map.tscn"),
		"battle": preload("res://screens/battle/screen_battle.tscn")
	}

func _ready():
	change_screen("battle")

func change_screen(screen_name):
	if !_screens.has(screen_name): return
	
	for child in $screen_layer.get_children():
		$screen_layer.remove_child(child)
		child.queue_free()
	
	var screen = _screens[screen_name].instance()
	screen.connect("next_screen", self, "change_screen")
	$screen_layer.add_child(screen)
