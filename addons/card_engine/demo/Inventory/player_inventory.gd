extends Control

var played = false

func _ready():
	pass

func _on_inventory_ready():
	$container/horizontal_container/weapons_container/weapons_frame/weapons_scroll/weapons.set_container(Game.player_weapons)
	$container/horizontal_container/weapons_container/weapons_frame/weapons_scroll/weapons.connect("play" ,$".." ,"_on_hand_play")
	$container/horizontal_container/items_container/items_frame/items_scroll/items.set_container(Game.player_items)
	$container/horizontal_container/items_container/items_frame/items_scroll/items.connect("play" ,$".." ,"_on_hand_play")
	$container/horizontal_container/jutsus_container/jutsus_frame/jutsus_scroll/jutsus.set_container(Game.player_jutsus)
	$container/horizontal_container/jutsus_container/jutsus_frame/jutsus_scroll/jutsus.connect("play" ,$".." ,"_on_hand_play")
