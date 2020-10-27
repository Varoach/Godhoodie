extends Node

var player_pos = Vector2()
var spawn = Vector2(-1, 0)

var _animation = Tween.new()

onready var Player = preload("res://character/player/fighter/fighter.tscn")

func _init():
	add_child(_animation)	

func _ready():
	spawn_player(spawn)
	play($TileMap.get_cellv(spawn))
	$TileMap.connect("left_pressed", self, "_on_map_left_pressed")
	_animation.connect("tween_completed", self, "_on_animation_completed")

func spawn_player(spot):
	$TileMap/character.position = $TileMap.map_to_world(spot)
	player_pos = spot
	_animation.interpolate_property($TileMap/character, "modulate:a", 0, 1, 1.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()

func _on_map_left_pressed(mouse_map):
	var cell_info = $TileMap.get_cellv(mouse_map)
	if (abs(mouse_map.x-player_pos.x) + abs(mouse_map.y-player_pos.y)) <=1 and mouse_map < player_pos:
		if cell_info != 15:
			move_player(mouse_map)
			yield(_animation,"tween_completed")
			play(cell_info)
	return

func move_player(spot):
#	$TileMap/character.position = $TileMap.map_to_world(spot)
	animate_position($TileMap/character.position, $TileMap.map_to_world(spot))
	player_pos = spot

func play(cell_info):
	pass

func animate_position(start, end):
	_animation.interpolate_property($TileMap/character, "position", start, end, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_animation.start()
