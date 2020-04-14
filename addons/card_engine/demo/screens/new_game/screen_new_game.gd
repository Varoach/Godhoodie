extends "../abstract_screen.gd"

func _on_btn_fighter_pressed():
	Game.create_game_real("fighter")
	emit_signal("next_screen", "game")

func _on_btn_mage_pressed():
	Game.create_game("mage_starter", "mage")
	emit_signal("next_screen", "game")

func _on_btn_back_pressed():
	emit_signal("next_screen", "menu")
