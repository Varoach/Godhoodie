extends Node2D

var max_health
var health
var attack
var sleep = 0
var dead = false

signal dead()
signal cut_received()
signal freeze_received()
signal fire_received()
signal damage_received(value)
signal healing_received(value)

export var health_offset = 160

func sprite_set(image, offset_y = 0 , size_diff = 1):
	$sprite.texture = image
	position.y -= image.get_height()/2 + offset_y
	scale = Vector2(1, 1) * size_diff
	$mouse_area.rect_size = Vector2(image.get_width(),image.get_height())
	$mouse_area.rect_position = Vector2(-image.get_width()/2,-image.get_height()/2)
	$mouse_area.rect_pivot_offset = $mouse_area.rect_size/2

func flip():
	$sprite.flip_h = !$sprite.flip_h

func check_dead():
	if health <= 0:
		emit_signal("dead")
		dead = true

func use(value_name, value):
	if value_name == "attack":
		emit_signal("damage_received", value)
	if value_name == "heal":
		emit_signal("healing_received", value)

func play_animation(animation):
	$animator.play(animation)
