extends Node2D

var foreground_image
var background_image
var highlight = false

var weapon_shader = load("res://weapons/weapon_background.tres")
var weapon_trinket = load ("res://trinkets/trinket.tscn")

var drag = false
var ready = false
var weapon = null
var trinket_slots = 0

onready var weapon_trinkets = $background_front/weapon_trinkets

signal left_pressed()#button)
signal left_released()#button)
signal trinket_inserted(trinket)

func _ready():
	$mouse_area.connect("gui_input", self, "_on_mouse_area_event")
	connect("trinket_inserted", Inventory, "add_trinket")

func get_weapon():
	return $background_front/weapon_hold.get_child(0)

func set_weapon(weap):
	$background_front/weapon_hold.add_child(weap)
	$background_front/title.text = weap.name.capitalize()
	weapon = weap

func texture_setup(image, back):
	$background_front.texture = image
	$background_back.texture = back

func _on_mouse_area_mouse_entered():
	#	emit_signal("mouse_entered")
	Game.player.animation(weapon.anim_ready)
	$animations.play("flip")

func _on_mouse_area_mouse_exited():
		#	emit_signal("mouse_exited")
	Game.player.animation("default")
	$animations.play("flip_back")

func _on_mouse_area_event(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_pressed")#, event.button_index)
		else:
			emit_signal("left_released")#, event.button_index)
	elif event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			emit_signal("right_pressed")#, event.button_index)
		else:
			emit_signal("right_released")

func trinket_setup():
	var column = 0
	var original_pos = Vector2(969, 27)
	var trinket_difference = {}
	trinket_difference.x = -84
	trinket_difference.y = 85
	for i in range(1, WeaponDB.trinket_slots[get_weapon().rarity]+1):
		var new_trinket = weapon_trinket.instance()
		trinket_slots += 1
		new_trinket.slot_number = trinket_slots
		if i % 2 == 0:
			new_trinket.rect_position = original_pos + Vector2(trinket_difference.x * column, trinket_difference.y)
			column += 1
		else:
			new_trinket.rect_position = original_pos + Vector2(trinket_difference.x * column, 0)
		get_node("background_front/weapon_trinkets").add_child(new_trinket)
