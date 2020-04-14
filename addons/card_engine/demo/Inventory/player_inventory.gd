extends Control

func _ready():
	pass

func _on_inventory_ready():
	$container/horizontal_container/weapons_container/weapons_frame/weapons_scroll/grid.set_container(Game.player_weapons)
	$container/horizontal_container/items_container/items_frame/items_scroll/grid.set_container(Game.player_items)
	$container/horizontal_container/jutsus_container/jutsus_frame/jutsus_scroll/grid.set_container(Game.player_jutsus)
