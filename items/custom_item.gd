extends RigidBody2D

var size = Vector2(2,4)
var held = false
var hover = false
var back_state

var buffs = {}
var title = ""
var real_title = ""
var tags = []
var desc = ""
var stats = {}
var values = {}
var targets = ""
var labels = {}
var ticks = 1
var damage = []
var cost = {}
var type = ""
var summon_on_kill = false

var random = true
var grow = false

signal item_held()
signal item_dropped()
signal remove_item()
signal on_kill(target_pos)
signal on_balance_break()

var max_speed = 2500

var _animation = Tween.new()

func _init():
	add_child(_animation)

func _ready():
	connect("item_held", self, "_on_item_held")
	connect("tree_exiting", self, "_on_exit")
	connect("item_dropped", self, "_on_item_dropped")
	if labels.empty():
		for child in $sprite_back.get_children():
			child.queue_free()
	set_labels()

func _on_exit():
	disconnect_relic()

func set_labels():
	for label in labels:
		get_node("sprite_back/label_" + label).text = String(stats[labels[label]])

func _physics_process(_delta):
	if abs(get_linear_velocity().x) > max_speed or abs(get_linear_velocity().y) > max_speed:
		var new_speed = get_linear_velocity().normalized()
		new_speed *= max_speed
		set_linear_velocity(new_speed)
	if (global_position.y + ($mouse_area.rect_size.y / 2) < 1550) and !_animation.is_active():
		if $sprite_back.visible:
			disable_back()
	elif (global_position.y + ($mouse_area.rect_size.y / 2) > 1550) and !_animation.is_active():
		if !$sprite_back.visible:
			enable_back()

func _on_item_held():
	for node in get_tree().get_nodes_in_group("items"):
		add_collision_exception_with(node)

func _on_item_dropped():
	for node in get_tree().get_nodes_in_group("items"):
		remove_collision_exception_with(node)

func explode():
	randomize()
	set_linear_velocity(Vector2(rand_range(-1000, 1000), rand_range(-1750, -1000)))

func _exit_tree():
	_animation.stop_all()

func sprite_set_full(image):
	$sprite.texture = image
	$mouse_area.rect_size = Vector2(image.get_width(), image.get_height())

func sprite_set(image, image_back):
	if !image or !image_back:
		return
	$sprite.texture = image
	$sprite_back.texture = image_back
	shrink_to_fit(image_back)
	set_bitmap(image)

func spawn_in():
	mode = MODE_STATIC
	$mouse_area.visible = false
	_animation.interpolate_property(self, "scale", Vector2.ZERO, Vector2.ONE, 0.5, Tween.TRANS_BACK, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_all_completed")
	yield(get_tree().create_timer(0.1), "timeout")
	mode = MODE_CHARACTER
	$mouse_area.visible = true

func shrink_to_fit(image_back):
	if !image_back:
		return
	var image_size = image_back.get_size()
	var target = Vector2(size.x, size.y) * ItemDB.cell_size
	var new_scale = target/image_size
	$sprite.scale = new_scale
	$sprite_back.scale = new_scale
	$mouse_area.rect_size = size * ItemDB.cell_size
	$mouse_area.rect_position = -image_back.get_size()*new_scale/2

func set_bitmap(image):
	var bm = BitMap.new()
	bm.create_from_image_alpha($sprite.texture.get_data())
	var rect = Rect2($sprite.position.x, $sprite.position.y, $sprite.texture.get_width(), $sprite.texture.get_height())
	var my_array = bm.opaque_to_polygons(rect, 8.0)
	var my_polygon = Polygon2D.new()
	my_polygon.set_polygons(my_array)
	for polygon in my_polygon.polygons:
		var new_collider = CollisionPolygon2D.new()
		new_collider.position = $mouse_area.rect_position
		new_collider.set_polygon(polygon)
		new_collider.scale = $sprite.scale
		add_child(new_collider)

func get_size():
	return $mouse_area.get_size()

func get_global_rect():
	return $mouse_area.get_global_rect()

func get_full_size():
	return Vector2(size.x * ItemDB.cell_size, size.y * ItemDB.cell_size)

func disable_back():
	_animation.interpolate_property($sprite_back, "modulate:a", 1, 0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()
	yield(_animation, "tween_completed")
	$sprite_back.visible = false

func enable_back():
	$sprite_back.visible = true
	_animation.interpolate_property($sprite_back, "modulate:a", 0, 1, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_animation.start()

func bring_front():
	z_index = 4

func send_back():
	z_index = 3

func connect_relic():
	if !tags.has("relic"):
		return
	var function = real_title
	RelicDB.call(function)

func disconnect_relic():
	if !tags.has("relic"):
		return
	var function = real_title + "_drop"
	RelicDB.call(function)
