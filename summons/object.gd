extends "res://character/character.gd"

var _is_ready = false

onready var healthbar = get_node("healthbar")

var tags = []

func _ready():
	_is_ready = true
	Game.connect("wall_damage", self, "damage_received")
	Game.connect("wall_dead", self, "_on_dead")
	healthbar.connect("dead", self, "_on_dead")
	healthbar.set_position(Vector2(healthbar.rect_position.x, $mouse_area.rect_position.y) + hpOffset * ($appearance.scale.y*1.5))
	healthbar.set_health(health)

func set_texture(texture):
	$appearance.texture = texture

func damage_received(value):
	healthbar.negative_health_update(value)

func _on_dead():
	queue_free()
	Game.walls.clear()

