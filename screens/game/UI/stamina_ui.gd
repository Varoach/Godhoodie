extends HBoxContainer

const custom_bar = preload("res://screens/game/Bars/stamina_bar.tscn")

const STAMINA_PATH = "res://screens/game/UI/stamina"

const STAMINA_OFFSET = 44

func _ready():
	stamina_create()
	stamina_set()

func stamina_create():
	for _i in range(Game.bars.stamina):
		var staminab = custom_bar.instance()
		staminab.texture_off = load(STAMINA_PATH + "1.png")
		staminab.texture_on = load(STAMINA_PATH + "2.png")
		staminab.enable()
		$stamina.add_child(staminab)

func stamina_setup():
#	for stamina in $stamina.get_children():
#		var index = stamina.get_index()
#
#		var x = index * STAMINA_OFFSET
#		stamina.rect_position = Vector2(x, 0)
	$staminanum.text = String(int(Game.curr_bars.stamina))

func stamina_set():
	for stamina in $stamina.get_children():
		var index = stamina.get_index()
		
		var x = index * STAMINA_OFFSET
		if (index+1) % 2 == 0:
			stamina.rect_position = Vector2(x, -45)
		else:
			stamina.rect_position = Vector2(x, 0)
	$staminanum.text = String(int(Game.bars.stamina))
	$stamina.rect_min_size.x = $stamina.get_children().size() * 45 + 30

func stamina_change():
	for child in $stamina.get_children():
		if child.get_index()+1 > Game.curr_bars.stamina:
			child.disable()
		else:
			child.enable()

func _on_stamina_toggled(status):
	if status:
		Game.count += 1
	else:
		Game.count -= 1

#func reset():
#	for child in $stamina.get_children():
#		if child.pressed:
#			Game.curr_bars.stamina -= 1
#		child.pressed = false
