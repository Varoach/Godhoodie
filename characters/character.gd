extends Node2D

var max_health
var health
var attack
var sleep = 0
var balance = 0
var before_balance = 0
var dead = false
var moving = false

signal dead()
signal cut_received(value)
signal freeze_received(value)
signal fire_received(value)
signal damage_received(value)
signal heal_received(value)
signal ice_received(value)
signal water_received(value)
signal sand_received(value)

export var health_offset = 160

var _animation = Tween.new()

func _init():
	add_child(_animation)

func sprite_set(image, offset_y = 0 , size_diff = 1):
	$sprite.texture = image
	position.y -= image.get_height()/2 + offset_y
	scale = Vector2(1, 1) * size_diff
	$mouse_area.rect_size = Vector2(image.get_width(),image.get_height())
	$mouse_area.rect_position = Vector2(-image.get_width()/2,-image.get_height()/2)
	$mouse_area.rect_pivot_offset = $mouse_area.rect_size/2

func flip():
	$sprite.flip_h = !$sprite.flip_h

func use(value_name, value, item = null):
	if item:
		ItemUse.last_item = item
	if value_name == "attack":
		emit_signal("damage_received", value, item)
	else:
		emit_signal(value_name + "_received", value, item)

func play_animation(animation):
	$animator.play(animation)

func bring_front():
	get_parent().z_index = 10

func send_back():
	get_parent().z_index = 0

func get_position():
	return int(get_parent().get_index())

func get_position_diff(character):
	return get_position() - character.get_position()

func slide_towards(character):
	if abs(character.get_position() - get_position()) == 1:
		return false
	var end_pos
	if character.get_position() > get_position():
		end_pos = 1
	else:
		end_pos = -1
	Game.emit_signal("slide_character", self, end_pos)
	return true

func is_moving():
	if moving:
		return true
	return false
