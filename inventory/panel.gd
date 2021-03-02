extends Control

var grid = {}
var cell_size
var grid_width
var grid_height
var item_scale = Vector2(1,1)
var last_available_pos = []
var last_container = null
var last_cursor_pos = null

var _animation = Tween.new()

signal dust(pos, item_size)

func _init():
	add_child(_animation)

func _ready():
	var cell_sizey = {}
	cell_sizey.x = rect_size.x/38
	cell_sizey.y = rect_size.y/6
	cell_size = cell_sizey.values().min()
	ItemDB.cell_size = cell_size
	var s = get_full_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	var offset = (rect_size.y - (grid_height * cell_size)) / 2
	rect_position.y += offset
	$instrument.rect_global_position.y -= offset
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = {}
			grid[x][y]["carrying"] = false
			grid[x][y]["available"] = true
	_add_dots()
	ItemDB.connect("spawn_item", self, "_on_item_spawn")
#	ItemDB.spawn_item("kunai", Vector2(500, 500))
#	ItemDB.spawn_item("flask", Vector2(500, 500))
#	ItemDB.spawn_item("kunai", Vector2(500, 500))
#	ItemDB.spawn_item("kunai", Vector2(500, 500))
#	ItemDB.spawn_item("liquid ambrosia", Vector2(500, 500))
#	ItemDB.spawn_item("rusty dagger", Vector2(500, 500))
#	ItemDB.spawn_item("gel", Vector2(500, 500))
#	ItemDB.spawn_item("fine ash", Vector2(500, 500))
#	ItemDB.spawn_item("blue safflina", Vector2(500, 500))
#	ItemDB.spawn_item("weapon cleaning oil", Vector2(500, 500))
#	ItemDB.spawn_item("ice spear", Vector2(500, 500))
	ItemDB.spawn_item("dune walker blade", Vector2(500, 500))
	ItemDB.spawn_item("sand trapper", Vector2(500, 500))
	ItemDB.spawn_item("travelers cane", Vector2(500, 500))
	ItemDB.spawn_item("lady lucks comb", Vector2(500, 500))

func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("grab"):
		item_pressed(cursor_pos)
		last_cursor_pos = cursor_pos
	if last_cursor_pos != null:
		if last_cursor_pos.distance_to(cursor_pos) > 10:
			grab(last_cursor_pos)
			last_cursor_pos = null
	if Input.is_action_just_released("grab"):
		release(cursor_pos)
		Game.item_pressed = null
		last_cursor_pos = null
	if Game.item_held != null:
		Game.item_held.global_position = cursor_pos
		can_insert(Game.item_held)
	if Game.item_held:
		if !_animation.is_active():
			if !$dots.visible:
				enable_dots()
	else:
		if !_animation.is_active():
			if $dots.visible:
				disable_dots()

func item_pressed(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("get_item"):
		Game.item_pressed = c.get_item(cursor_pos)

func disable_dots():
	_animation.interpolate_property($dots, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_completed")
	$dots.visible = false

func enable_dots():
	$dots.visible = true
	_animation.interpolate_property($dots, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

func _add_dots():
	for x in range(grid_width + 1):
		for y in range(grid_height + 1):
			var dot = TextureRect.new()
			dot.texture = load("res://assets/inventory/dot.png")
			dot.expand = true
			dot.rect_size = Vector2(10, 10)
			dot.rect_position = Vector2(x * cell_size - (dot.rect_size.x / 2), y * cell_size - (dot.rect_size.y / 2))
#			dot.visible = false
			$dots.add_child(dot)
			

func _on_item_spawn(item, location):
	item.connect("remove_item", self, "_on_remove_item")
#	item.connect("item_held", self, "_on_item_held")
#	item.connect("item_dropped", self, "_on_item_dropped")
	$items.add_child(item)
	item.global_position = location
	if item.random:
		item.explode()
	if item.grow:
		item.spawn_in()
	else:
		item.scale = Vector2.ONE

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		Game.item_held = c.grab_item(cursor_pos)
		if Game.item_held != null:
			last_container = c
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
   
	var item_pos = item.global_position - ((item.size * cell_size) / 2) + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	item.disconnect_relic()
	item.held = true
	item.mode = RigidBody2D.MODE_KINEMATIC
	item.bring_front()
	item.emit_signal("item_held")
	return item

func get_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
   
	return item

func get_container_under_cursor(cursor_pos):
	var containers = [self]
	if Game.play_space:
		containers.append(Game.play_space)
	for c in containers:
		if c.is_inside_tree():
			if c.get_global_rect().has_point(cursor_pos):
				return c
	return null

func select_item(pos):
	var item = get_item_under_pos(pos)
	return item

func play_item(cursor_pos):
	var item
	var c = get_container_under_cursor(cursor_pos)
	if c == self:
		item = c.select_item(cursor_pos)
		if item == null:
			return
		item.send_back()
		if item.targets == "none":
			return
		if item.tags.has("weapon") or item.tags.has("jutsu"):
			if Game.values.energy > 0:
				ItemUse.item_use_case[item.targets].call_func(item)
			else:
				Game.emit_signal("error", "energy is 0")
		else:
			ItemUse.item_use_case[item.targets].call_func(item)

func release(cursor_pos):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var c = get_container_under_cursor(cursor_pos)
	if Game.item_held == null and c == self:
		play_item(cursor_pos)
	elif Game.item_held == null:
		return
	elif c == null:
		if !last_available_pos.empty():
			insert_item_at_last_available_spot(Game.item_held, last_available_pos)
			Game.item_held = null
		else:
			return_item()
	elif c.has_method("drop"):
		c.drop(Game.item_held)
	elif c.has_method("insert_item"):
		if c.insert_item(Game.item_held):
			Game.item_held = null
		elif !last_available_pos.empty():
			insert_item_at_last_available_spot(Game.item_held, last_available_pos)
			Game.item_held = null
		else:
			return_item()
	else:
		return_item()

func _on_remove_item(item):
	var item_pos = item.global_position - ((item.size * cell_size) / 2) + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	$items.remove_child(item)
	item.queue_free()

func return_item():
	insert_item_at_first_available_spot(Game.item_held)
	Game.item_held.send_back()
	Game.item_held = null

func insert_item_at_last_available_spot(item, spot):
	var g_pos = spot.g_pos
	var item_size = spot.item_size
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
#	item.global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size
	animate_insert(item, rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size + ((item.size * cell_size) / 2))
	last_available_pos.clear()

func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j]["carrying"] = state

func get_grid_size(item):
	var results = {}
	results.x = item.size.x
	results.y = item.size.y
	return results

func get_full_grid_size(curr_grid):
	var results = {}
	var s = curr_grid.get_size()
	results.x = clamp(int(s.x / cell_size  * item_scale.x), 1, 500)
	results.y = clamp(int(s.y / cell_size  * item_scale.y), 1, 500)
	return results

func can_insert(item):
	var item_pos = item.global_position - ((item.size * cell_size) / 2) + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	g_pos = fit_pos(g_pos.x, g_pos.y, item_size.x, item_size.y)
	g_pos = find_fit(g_pos.x, g_pos.y, item_size.x, item_size.y)
	if g_pos != null and !g_pos.empty():
		if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
			last_available_pos = {"g_pos" : g_pos, "item_size" : item_size}

func is_grid_space_available(x, y, w, h):
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if !spot_check(i,j):
				return false
	return true

func pos_to_grid_coord(pos):
	var local_pos = pos - rect_global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	if results.x < 0:
		results.x = 0
	if results.y < 0:
		results.y = 0
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

func find_fit(x, y, w, h):
	var results = {"x" : x, "y": y, "w" : w, "h": h}
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

func spot_check(x,y):
	if !grid[x][y]["carrying"] and grid[x][y]["available"]:
		return true
	return false 

func get_item_under_pos(pos):
	for item in $items.get_children():
		if item == Game.item_held: continue
		if item.get_global_rect().has_point(pos):
			return item
	return null

func position_check(x,y):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		return true
	return false

func insert_item(item):
	var item_pos = item.global_position - ((item.size * cell_size) / 2) + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.connect_relic()
#		item.global_position = rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size
		var insert_pos = (rect_global_position + Vector2(g_pos.x, g_pos.y) * cell_size) + ((item.size * cell_size) / 2)
		animate_insert(item, insert_pos)
		yield(_animation,"tween_completed")
		emit_signal("dust", item.global_position, item_size)
		return true
	else:
		return false

func animate_insert(item, position):
	_animation.interpolate_property(item, "global_position", item.global_position, position, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT) #0.0008 * abs(item.global_position.distance_to(position))
	_animation.start()
	yield(_animation, "tween_completed")
	item.send_back()

func insert_item_at_first_available_spot(item):
	for x in range(grid_width):
		for y in range(grid_height):
			if spot_check(x,y):
				item.global_position = rect_global_position + Vector2(x, y) * cell_size + ((item.size * cell_size) / 2)
				if insert_item(item):
					return true
	return false
