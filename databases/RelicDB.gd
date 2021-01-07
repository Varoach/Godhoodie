extends Node

func lady_lucks_comb():
	Game.connect("enemy_moved", Game.player, "restore_one_balance")

func lady_lucks_comb_drop():
	Game.disconnect("enemy_moved", Game.player, "restore_one_balance")

func travelers_cane():
	Game.connect("enemy_moved", Game.game_screen, "spawn_random_item")

func travelers_cane_drop():
	Game.disconnect("enemy_moved", Game.game_screen, "spawn_random_item")
