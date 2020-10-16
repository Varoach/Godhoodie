extends "../abstract_screen.gd"

func _on_btn_new_game_pressed():
	Game.create_game("fighter")
	emit_signal("next_screen", "game")

func _on_btn_options_pressed():
	emit_signal("options")

func _on_btn_quit_pressed():
	get_tree().quit()
