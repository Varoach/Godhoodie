extends "res://character/character.gd"

var _is_ready = false

onready var healthbar = get_node("healthbar")

var tags = []

func _ready():
	_is_ready = true
	healthbar.connect("dead", self, "_on_dead")
	healthbar.set_position(Vector2(healthbar.rect_position.x, $mouse_area.rect_position.y) + hpOffset * ($appearance.scale.y*1.5))

func set_texture(texture):
	$appearance.texture = texture
