extends Control

const item = preload("res://addons/card_engine/demo/items/custom_item.tscn")
const single_grid = preload("res://addons/card_engine/demo/items/single_grid.tscn")

onready var inv_base = $ItemBase

var items = []

var grid = {}
var cell_size = 32
var grid_width = 0
var grid_height = 0

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()

func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y][0] = false
			if x < 6: 
				grid[x][y][1] = true
				new_grid(x,y)
			else:
				grid[x][y][1] = false

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("grab"):
		grab_item(cursor_pos)
	if Input.is_action_just_released("grab"):
		release(cursor_pos)
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset

func new_grid(x, y):
	grid[x][y][1].add_child(single_grid.instance())
	grid[x][y][1].get_node("single_grid").size = Vector2(cell_size, cell_size)

func insert_item(item):
	var item_pos = item.rect_global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.rect_global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size
		items.append(item)
		return true
	else:
		return false

func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j][0] = state

func set_grid_space_available(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j][1] = state
			new_grid(i, j)

func is_grid_space_available(x, y, w, h):
	if x<0 or y < 0:
		return false
	if x + w > grid_width or y+h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j][0] or not grid[i][j][1]:
				return false
	return true

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.rect_global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null
func get_grid_size(item):
	var results = {}
	var s = item.rect_size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results

func pos_to_grid_coord(pos):
	var local_pos = pos - rect_global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results

func get_item_under_pos(pos):
	for item in items:
		if item.get_global_rect().has_point(pos):
			return item
	return null

func grab_item(cursor_pos):
	var item = get_item_under_pos(cursor_pos)
	if item == null:
		return null
		
		last_pos = item_held.rect_global_position
		item_offset = item_held.rect_global_position - cursor_pos
		move_child(item_held, get_child_count())

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()

func get_container_under_cursor(cursor_pos):
	var containers = [inv_base]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null
