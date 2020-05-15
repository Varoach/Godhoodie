extends Control

var played = false

signal play(item, hand)
signal weapon_played(item, status)
signal item_played(item, status)
signal jutsu_played(item, status)

func _ready():
	#$container/horizontal_container/weapons_container/weapons_frame/weapons_scroll/weapons.set_container(Game.player_weapons)
	$container/horizontal_container/weapons_container/weapons_frame/weapons.connect("play" ,self ,"_on_play")
#	$container/horizontal_container/items_container/items_frame/items_scroll/items.set_container(Game.player_items)
	$container/horizontal_container/items_container/items_frame/items.connect("play" ,self ,"_on_play")
	$container/horizontal_container/jutsus_container/jutsus_frame/jutsus.set_container(Game.player_jutsus)
	$container/horizontal_container/jutsus_container/jutsus_frame/jutsus.connect("play" ,self ,"_on_play")

func _on_play(item, targets, hand, container = null, bars = null):
	var temp_bars = {}
	var possible = true
	if bars != null:
		for value in bars:
			if !character_check(value, bars.get(value)):
				possible = false
				break
			else:
				temp_bars[value] = bars.get(value)
	else:
		temp_bars = null
	if Game.moves <= 0:
		possible = false
	if Game._current_step == 1 and !played and playable(targets) and possible:
		played = true
		emit_signal("play", item, hand, temp_bars)
		if hand == "weapons":
			emit_signal("weapon_played", item, true)
		if hand == "items":
			emit_signal("item_played", item, true)
		if hand == "jutsus":
			emit_signal("jutsu_played", item, true, container)
	else:
		if hand == "weapons":
			emit_signal("weapon_played", item, false)
		if hand == "items":
			emit_signal("item_played", item, false)
		if hand == "jutsus":
			emit_signal("jutsu_played", item, false, container)

func bar_check(bars):
	pass

func playable(targets):#card._card_data.targets
	if targets == "none":
		return false
	if targets == "single":
		if $".."._check_targets() != null:
			return true
		else:
			return false
	elif targets != "single":
		if $"../Playable".get_rect().has_point(get_global_mouse_position()):
			return true
		else:
			return false

func character_check(bar, value):
	if value < Game.curr_bars[bar]:
		return true
	return false
