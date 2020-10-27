extends "res://addons/card_engine/widgets/animated_object.gd"

signal mouse_entered()
signal mouse_exited()
signal tick_time()
signal cut_received()
signal freeze_received()
signal fire_received()
signal bomb_check()
signal dead()
signal spawn_character(character)

const STATUS_PATH = "res://character/status/images/"

var hpOffset = Vector2(0, -150)
var shOffset = Vector2(0, 0)
var attack
var defense = 0
var health
var active_effects = {}
var sleep = 0
var bombs = []
var attack_ref = funcref(self, "_damage_received")
var lightning_ref = funcref(self, "_lightning_received")
var healing_ref = funcref(self, "_healing_received")
var fire_ref = funcref(self, "_fire_received")
var earth_ref = funcref(self, "_bomb_received")
var fire_tick_ref = funcref(self, "_fire_tick")
var unburn_ref = funcref(self, "_unburn_received")
var focus_ref = funcref(self, "_focus_received")

var custom_status = preload("res://character/status/status.tscn")

export var STATUS_OFFSET = 150

var use_type = {"attack" : attack_ref, "heal" : healing_ref, "lightning" : lightning_ref, "fire" : fire_ref, "earth" : earth_ref, "unburn" : unburn_ref, "focus" : focus_ref}
var tick_type = {"fire" : fire_tick_ref}

func _ready():
	#Game.connect("use", attack, character)
	connect("bomb_check", self, "_bomb_activated")
	connect("tick_time", self, "ticks")
	$mouse_area.connect("mouse_entered", self, "_on_mouse_area_entered")
	$mouse_area.connect("mouse_exited", self, "_on_mouse_area_exited")
	$character/healthbar.connect("dead", self, "_on_dead")

func _on_dead():
	emit_signal("dead", self)

func _on_mouse_area_entered():
	emit_signal("mouse_entered")

func set_status_location(location):
	$statuses.rect_global_position = location

func _on_mouse_area_exited():
	emit_signal("mouse_exited")

func check_focus():
	var focused = $mouse_area.get_rect().has_point(get_local_mouse_position())
	if focused:
		focused = true
		return true
	else:
		return false
	focused = false

func use(type, value):
	if type in use_type:
		use_type[type].call_func(value)

func use_bomb(type, trigger, value):
	var trigger_found = false
	if !bombs.empty():
		for bomb in bombs:
			if bomb.trigger == trigger and bomb.type == type:
				bomb.value += value
				trigger_found = true
	if !trigger_found:
		var new_bomb = {"type" : type, "trigger" : trigger, "value" : value}
		bombs.append(new_bomb)
	add_status("bomb", value)

func _lightning_received(value):
	attack_ref.call_func(value)

func _fire_received(value):
	if "fire" in active_effects:
		active_effects.fire += value
		update_statuses()
	else:
		active_effects.fire = value
		add_status("fire", value)

func _unburn_received(value):
	if "fire" in active_effects:
		active_effects.fire -= value
		update_statuses()
	else:
		return

func _bomb_activated(trigger):
	if !bombs.empty():
		for bomb in bombs:
			if bomb.trigger == trigger:
				use_type[bomb.type].call_func(bomb.value)
				bombs.erase(bomb)
	update_statuses()

func ticks():
	print(active_effects)
	for effect in active_effects:
		tick_type[effect].call_func()

func _fire_tick():
	if active_effects.fire < 10:
		attack_ref.call_func(active_effects.fire)
		active_effects.erase("fire")
	elif active_effects.fire > 10:
		attack_ref.call_func(10)
		active_effects.fire -= 10
	update_statuses()
	emit_signal("bomb_check", "fire")

func play_effect(effect):
	$effect.play_effect(effect)

func add_status(status, value):
	var new_status = custom_status.instance()
	new_status.texture = load(STATUS_PATH + status + ".png")
	new_status.centered = true
	new_status.set_value(value)
	$statuses.add_child(new_status)
	for status in $statuses.get_children():	
		var index = status.get_index()
		
		var x = index * STATUS_OFFSET
		status.position = Vector2(x, 0)

func update_statuses():
	for status in $statuses.get_children():
		$statuses.remove_child(status)
		status.queue_free()
	for effect in active_effects:
		if active_effects[effect] <= 0:
			active_effects.erase(effect)
		else:
			add_status(effect, active_effects[effect])
	for bomb in bombs:
		add_status(bomb.type, bomb.value)
	for status in $statuses.get_children():
		var index = status.get_index()
		
		var x = index * STATUS_OFFSET
		status.position = Vector2(x, 0)
