extends Control

var played = false
var hand = false

signal play(item, hand)
signal highlight(card)
signal unhighlight(card)
signal weapon_played(item, status)
signal item_played(item, status)
signal jutsu_played(item, status)

var highlight = false

func _ready():
	$background/horizontal_container/weapons_container/weapons.connect("play" ,self ,"_on_play")
	$background/horizontal_container/items_container/items.connect("play" ,self ,"_on_play")
	$background/horizontal_container/jutsus_container/jutsus.connect("play" ,self ,"_on_play")

func _on_play(item, targets, hand, bars = null):
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
			emit_signal("jutsu_played", item, true)
	else:
		if hand == "weapons":
			emit_signal("weapon_played", item, false)
		if hand == "items":
			emit_signal("item_played", item, false)
		if hand == "jutsus":
			emit_signal("jutsu_played", item, false)

func playable(targets):#card._card_data.targets
	if targets == "none":
		return false
	elif targets == "single":
		if $".."._check_targets() != null:
			return true
		else:
			return false
	elif targets == "first":
		return true
	elif targets != "single":
		if $"../Playable".get_rect().has_point(get_global_mouse_position()):
			return true
		else:
			return false

func character_check(bar, value):
	if value <= Game.curr_bars[bar]:
		return true
	return false
