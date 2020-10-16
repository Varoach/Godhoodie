extends Node

enum ENTITY_TYPES {PLAYER, OBSTACLE}

#var tile_size = $TileMap.get_cell_size()

var grid = []
var offset = -1

onready var Player = preload("res://character/player/fighter/fighter.tscn")

func _ready():
	$TileMap/character.rect_position = $TileMap.map_to_world(Vector2(-1 + offset, 0))
