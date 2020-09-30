extends RigidBody2D

signal left_pressed()

var category = ""
var title = ""
var random = true
var up = Vector2(0, -1)
var maxTorqueFactor = 1

var held = false

var max_speed = 2000

func _ready():
	if random:
		linear_velocity = Vector2(rand_range(-1000, 1000),rand_range(-2000, -500))

func _physics_process(delta):
	if abs(get_linear_velocity().x) > max_speed or abs(get_linear_velocity().y) > max_speed:
		var new_speed = get_linear_velocity().normalized()
		new_speed *= max_speed
		set_linear_velocity(new_speed)
	if held:
		global_transform.origin = get_global_mouse_position()
		if Input.is_action_pressed("turn_left"):
			global_transform.rotated(-100)
		elif Input.is_action_pressed("turn_right"):
			global_transform.rotated(100)
		else:
			global_transform.rotated(0)
		# restore up rotation
#		if rotation_degrees < -3:
#			angular_velocity = 5
#		elif rotation_degrees > 3:
#			angular_velocity = -5
#		else:
#			angular_velocity = 0
#			rotation_degrees = 0

func pickup():
	if category == "card":
		CardDB.pickup_card(title)
	elif category == "weapon":
		WeaponDB.pickup_weapon(title)
	elif category == "item":
		ItemDB.pickup_item(title)
	queue_free()

func lift():
	if held:
		return
	mode = RigidBody2D.MODE_KINEMATIC
	held = true

func drop(impulse=Vector2.ZERO):
	if held:
		if global_position.y > 1346:
			pickup()
		else:
			mode = RigidBody2D.MODE_RIGID
			apply_central_impulse(impulse)
			held = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("left_pressed", self)

#func _on_drop_body_entered(body):
#	if body.is_in_group("pickable"):
#		if held:
#			body.eject(self)
#		else:
#			eject(body)
#
#func eject(body):
#	add_collision_exception_with(body)
#	apply_central_impulse(-position.direction_to(body.position))
#	yield(self,"body_exited")
#	remove_collision_exception_with(body)
