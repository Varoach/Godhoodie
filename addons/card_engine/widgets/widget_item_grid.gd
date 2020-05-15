extends Control

const custom_item = preload("res://addons/card_engine/demo/items/custom_item.tscn")
const single_grid = preload("res://addons/card_engine/demo/items/single_grid.tscn")

var items = []

var grid = {}
var cell_size = 82.5
var grid_width = 0
var grid_height = 0
var curr_grid_width = 10
var curr_grid_height = 0

signal play(item)

onready var inventory = get_node("../../../../..")
var item_rotate = []
var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()
var last_available_pos = {}
var single_grid_scale = Vector2(0.435,0.435)
var item_texture = null
#var item_scale = Vector2(1.07,1.07)
var item_scale = Vector2(1,1)

func _ready():
	inventory.connect("item_played", self, "_on_item_played")
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = {}
			if x < 10: 
				grid[x][y]["carrying"] = false
				grid[x][y]["available"] = true
				grid[x][y]["infected"] = false
				new_grid(x, y)
			elif (x == 11 or x == 12) and y < 6:
				grid[x][y]["carrying"] = false
				grid[x][y]["available"] = true
				grid[x][y]["infected"] = false
				new_grid(x, y)
			else:
				grid[x][y]["carrying"] = false
				grid[x][y]["available"] = false
				grid[x][y]["infected"] = false
	pickup_item("potion")
	pickup_item("potion")
	pickup_item("fish")
	pickup_item("kunai")

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("grab") and get_global_rect().has_point(cursor_pos):
		grab(cursor_pos)
	if Input.is_action_just_released("grab"):
		release(cursor_pos)
	if Input.is_action_just_pressed("turn_left"):
		rotate("left")
	if Input.is_action_just_pressed("turn_right"):
		rotate("right")
	if item_held != null:
		item_held.global_position = cursor_pos - item_held.get_size() / 2
		can_insert(item_held)
		if distance_check():
			show_position()
		else:
			turn_off_texture()
	if item_held == null and item_texture != null:
			turn_off_texture()

func turn_off_texture():
	if item_texture != null:
		item_texture.queue_free()
		item_texture = null
		last_available_pos.clear()

func show_position():
	if last_available_pos.empty():
		return
	if item_texture == null:
		reset_item_texture()
		add_child(item_texture)
	item_texture.position = Vector2(last_available_pos.g_pos.x*cell_size,last_available_pos.g_pos.y*cell_size)

func new_grid(x, y):
	var local_pos = Vector2(x * cell_size, y * cell_size)
	var new_child = single_grid.instance()
	new_child.rect_size = Vector2(cell_size, cell_size)
	new_child.rect_position = local_pos - Vector2(2,0)
	new_child.rect_scale = single_grid_scale
	add_child(new_child)

func insert_item(item):
	var item_pos = item.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size
		items.append(item)
		return true
	else:
		return false

func position_check(x,y):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		return true
	return false

func can_insert(item):
	var item_pos = item.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	g_pos = fit_pos(g_pos.x, g_pos.y, item_size.x, item_size.y)
	g_pos = find_fit(g_pos.x, g_pos.y, item_size.x, item_size.y)
	if g_pos != null and !g_pos.empty():
		if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
			last_available_pos = {"g_pos" : g_pos, "item_size" : item_size}

func find_fit(x, y, w, h):
	var results = {"x" : x, "y": y, "w" : w, "h": h}
	var under_item = get_item_under_pos(item_held.global_position + (item_held.get_size()/2))
#	if under_item == null:
#		return result
	var tempx = x
	var tempy = y
	var tempx2 = x
	var tempy2 = y
	while !is_grid_space_available(x, y, w, h) or !is_grid_space_available(tempx, y, w, h):
		if !position_check(x,y) or !position_check(tempx,y) or !position_check(tempx2,tempy2) or !position_check(tempx2,tempy):
			break
		x += 1
		tempx -= 1
		tempy += 1
		tempy2 -= 1
		if is_grid_space_available(x, y, w, h):
			results.x = x
			results.y = y
			break
		elif is_grid_space_available(tempx, y, w, h):
			results.x = tempx
			results.y = y
			break
		elif is_grid_space_available(tempx2, tempy2, w, h):
			results.x = tempx2
			results.y = tempy2
			break
		elif is_grid_space_available(tempx2, tempy, w, h):
			results.x = tempx2
			results.y = tempy
			break
	return results

func fit_pos(x, y, w, h):
	var results = {}
	if x < 0 and x >= -2:
		x = 0
	elif x+w > grid_width:
		x = grid_width - w
	if y < 0 and y >= -2:
		y = 0
	elif y > grid_height-h:
		y = grid_height - h
	results.x = x
	results.y = y
	return results

func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j]["carrying"] = state

func set_grid_space_available(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j]["available"] = state
			new_grid(i, j)

func is_grid_space_available(x, y, w, h):
	if x<0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if !spot_check(i,j):
				return false
	return true

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.return_item_state()
	last_container.insert_item(item_held)
	item_held.reset_z_index()
	item_held = null

func get_grid_size(item):
	var results = {}
	var s = item.get_size()
	results.x = clamp(int(s.x / cell_size  * item_scale.x), 1, 500)
	results.y = clamp(int(s.y / cell_size  * item_scale.y), 1, 500)
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

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			item_held.save_item_state()
			item_offset = item_held.global_position - cursor_pos
			move_child(item_held, get_child_count())
			item_held.bring_front()

func rotate(rotation):
	if item_held == null:
		return
	item_rotate.append(item_held)
	if item_texture != null:
		item_rotate.append(item_texture)
	for item in item_rotate:
		if item != null and item.has_method("rotate_item"):
			item.rotate_item(rotation)
			last_available_pos.clear()
	item_rotate.clear()
	if item_held == null or item_texture == null:
		return
	elif item_held.flipped != item_texture.flipped or item_held.rotated != item_texture.rotated:
		turn_off_texture()
		reset_item_texture()
		add_child(item_texture)

func reset_item_texture():
	item_texture = item_held.duplicate()
	item_texture.name = "item_texture"
	item_texture.modulate = Color(1,1,1,0.5)
	item_texture.texture_original = item_held.texture_original
	item_texture.texture_rotate = item_held.texture_rotate
	item_texture.show_behind_parent = true

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
   
	var item_pos = item.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	
	items.remove(items.find(item))
	return item

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		if !item_held.values.empty():
			emit_signal("play", item_held, item_held.targets, name, item_held.bars)
		else:
			return_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held.reset_z_index()
			item_held = null
		elif !last_available_pos.empty():
			insert_item_at_last_available_spot(item_held, last_available_pos)
			item_held.reset_z_index()
			item_held = null
		else:
			return_item()
	else:
		return_item()

func get_container_under_cursor(cursor_pos):
	var containers = [self]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null
	

func insert_item_at_last_available_spot(item, spot):
	var g_pos = spot.g_pos
	var item_size = spot.item_size
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
	item.global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size
	items.append(item)
	last_available_pos.clear()

func insert_item_at_first_available_spot(item):
	for x in range(grid_width):
		for y in range(grid_height):
				if spot_check(x,y):
					item.global_position = rect_global_position + Vector2(x, y) * cell_size
					if insert_item(item):
						return true
	return false

func pickup_item(item_id):
	var item = item_setup(item_id)
	add_child(item)
	if !insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true

func spot_check(x,y):
	if !grid[x][y]["carrying"] and grid[x][y]["available"] and !grid[x][y]["infected"]:
		return true
	return false

func item_setup(item_id):
	var item = custom_item.instance()
	item.set_meta("id", item_id)
	item.set_texture(load(ItemDB.get_item(item_id)["icon"]))
	item.texture_original = load(ItemDB.get_item(item_id)["icon"])
	item.texture_rotate = load(ItemDB.get_item(item_id)["icon_rotate"])
	item.set_size(ItemDB.get_item(item_id)["size"] * cell_size)
	item.set_scale(rect_scale * item_scale)
	item.targets = ItemDB.get_item(item_id)["targets"]
	item.bars = ItemDB.get_item(item_id)["bars"]
	if ItemDB.get_item(item_id).has("values"):
		item.values = ItemDB.get_item(item_id)["values"]
	return item

func _on_item_played(item, status):
	if status:
		drop_item()
	elif not status and distance_check():
		insert_item_at_last_available_spot(item_held, last_available_pos)
		item_held = null
	else:
		return_item()

func distance_check():
	if item_held == null or last_available_pos.empty():
		return false
	var last_position = rect_global_position + Vector2(last_available_pos.g_pos.x*cell_size, last_available_pos.g_pos.y*cell_size)
	if last_position.distance_to(item_held.global_position) < 300 and !last_available_pos.empty():
		return true
	return false
