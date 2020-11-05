extends "../enemy.gd"

var slime_size = "large"

func _ready():
	connect("cut_received", self, "_on_cut")
	connect("freeze_received", self, "_on_freeze")
	connect("fire_received", self, "_on_fire")
	set_size(check_size())

func _on_cut(_value):
	slime_divide()

func _on_freeze(_value):
	var freeze_percent = randf()
	if freeze_percent < 0.5:
		sleep = 2

func _on_fire(_value):
	slime_combine()

func slime_divide():
	if dead or slime_size == "small" or before_balance > 0:
		return
	if $animator.is_playing():
		yield($animator, "animation_finished")
	var new_slime = EnemyDB.enemy_setup("slime")
	
	var new_slime_size = ""
	if slime_size == "large":
		new_slime_size = "medium"
	elif slime_size == "medium":
		new_slime_size = "small"
	slime_size = new_slime_size
	new_slime.slime_size = new_slime_size
	
	
	var new_health = health/2
	max_health = new_health
	health = new_health
	new_slime.max_health = new_health
	new_slime.health = new_health
	
	set_hearts()
	new_slime.set_hearts()
	
	set_size(check_size())
	new_slime.set_size(new_slime.check_size())
	
	Game.emit_signal("spawn_next_enemy", new_slime)

func slime_combine():
	if slime_size == "large":
		return

func set_size(size):
	$sprite.scale = Vector2(size, size)
	$mouse_area.rect_scale = Vector2(size, size)
	position.y = -$mouse_area.rect_size.y * $mouse_area.rect_scale.y / 2

func check_size():
	if slime_size == "large":
		return 0.8
	elif slime_size == "medium":
		return 0.6
	elif slime_size == "small":
		return 0.4
