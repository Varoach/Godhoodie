extends HBoxContainer

const custom_bar = preload("res://screens/game/Bars/focus_bar.tscn")

const FOCUS_PATH = "res://screens/game/UI/focus"

const FOCUS_OFFSET = 44

func _ready():
	focus_create()
	focus_set()

func focus_create():
	for i in range(Game.bars.focus):
		var focusb = custom_bar.instance()
		focusb.texture_off = load(FOCUS_PATH + "1.png")
		focusb.texture_on = load(FOCUS_PATH + "2.png")
		focusb.enable()
		$focus.add_child(focusb)

func focus_setup():
#	for focus in $focus.get_children():
#		var index = focus.get_index()
#
#		var x = index * FOCUS_OFFSET
#		focus.position = Vector2(x, 0)
	$focusnum.text = String(int(Game.curr_bars.focus))

func focus_set():
	for focus in $focus.get_children():
		var index = focus.get_index()
		
		var x = index * FOCUS_OFFSET
		focus.rect_position = Vector2(x, 0)
		if (index+1) % 2 == 0:
			focus.flip_v = true
	$focusnum.text = String(int(Game.bars.focus))
	$focus.rect_min_size.x = $focus.get_children().size() * 45 + 30

func focus_change():
	for child in $focus.get_children():
		if child.get_index()+1 > Game.curr_bars.focus:
			child.disable()
		else:
			child.enable()

func _on_focus_toggled(status):
	if status:
		Game.count += 1
	else:
		Game.count -= 1

#func reset():
#	for child in $focus.get_children():
#		if child.pressed:
#			Game.curr_bars.focus -= 1
#		child.pressed = false
