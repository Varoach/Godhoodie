extends "res://addons/card_engine/widgets/animated_object.gd"

signal mouse_entered()
signal mouse_exited()

var hpOffset = Vector2(0, -150)
var shOffset = Vector2(0, 0)
var attack
var focused
var defense = 0
var dead = false
var attack_ref = funcref(self, "_damage_received")
var lightning_ref = funcref(self, "_lightning_received")
var healing_ref = funcref(self, "_healing_received")

var use_type = {"attack" : attack_ref, "heal" : healing_ref, "lightning" : lightning_ref}

func _ready():
#	$character/shadow.set_position(Vector2(0, $character/appearance.get_rect().end.y*$character/appearance.scale.y) + shOffset)
#	$character/shadow.scale = $character/appearance.scale*2.5
	#Game.connect("use", attack, character)
	$mouse_area.connect("mouse_entered", self, "_on_mouse_area_entered")
	$mouse_area.connect("mouse_exited", self, "_on_mouse_area_exited")

func _on_mouse_area_entered():
	emit_signal("mouse_entered")

func _on_mouse_area_exited():
	emit_signal("mouse_exited")

func check_focus():
	focused = $mouse_area.get_rect().has_point(get_local_mouse_position())
	if focused:
		focused = true
		return true
	else:
		return false
	focused = false

func use(type, value):
	if type in use_type:
		use_type[type].call_func(value)

func _lightning_received(value):
	Game.emit_signal("lightning")
	attack_ref.call_func(value)

func _on_dead():
	dead = true
