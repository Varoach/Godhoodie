extends "../character.gd"

const HEART_PATH = "res://assets/ui/battle_ui/hearts/heart_"
const HEART_END = ".png"
const HEART_OFFSET = 50

const balance_view = preload("res://assets/ui/battle_ui/balance/balance.png")

const custom_heart = preload("res://ui/new_heart.tscn")

var balance_size = Vector2()

var values = {}
var drops = {}
var title = ""
var char_size = "large"
var labels = []
var loyal = null
var curr_targets = [Game.player]
var damage_type = []
var is_moving = false
var old_position = null
var hostile = true
var width = 1

func _ready():
	balance_size = Vector2(balance_view.get_width(), balance_view.get_height())
	set_ui()
	set_hearts()
	connect("damage_received", self, "_on_damage_received")
	connect("heal_received", self, "_on_heal_received")

func damage(value):
	emit_signal("damage_received", value)

func balance_break():
	if before_balance > 0 and balance <= 0:
		return true
	return false

func _on_damage():
	play_animation("damage")

func _move(new_pos):
	Game.emit_signal("move_character", self, new_pos)

func get_old_position():
	return old_position

func check_dead():
	if health <= 0:
		dead = true
		emit_signal("dead", self)

func attack():
	return int(rand_range(values.attack[0], values.attack[1]))

func heal():
	return int(rand_range(values.heal[0], values.heal[1]))

func set_ui():
	$ui.rect_position.y = $mouse_area.rect_position.y - health_offset

func _on_healing_received(value):
	if value == "max":
		health = max_health
	else:
		health = health.clamp(health + value, 0, max_health)
	play_animation("heal")
	update_hearts()
	check_dead()

func play_turn():
	if !slide_towards(Game.player):
		Game.player.use("attack", attack())

func _on_damage_received(value):
	if value >= health:
		before_balance = balance
		balance = 0
		health -= value
	elif value < health:
		if balance > 0:
			before_balance = balance
			balance -= 1
#			if balance == 0:
#				show_hearts()
		else:
			before_balance = 0
			health -= value
#			play_animation("damage")
	check_dead()
	update_hearts()

func restore_balance(amount):
	balance += amount
	update_hearts()

func update_hearts():
	for heart in $ui/hearts/container.get_children():
		var heart_spot = heart.get_index()+1
		if health <= 0:
			heart.texture = load(HEART_PATH + "0" + HEART_END)
		elif heart_spot*3 <= health:
			heart.texture = load(HEART_PATH + "3" + HEART_END)
			heart.status = 3
		elif health % 3 > 0 and heart_spot == health/3 + 1:
			heart.texture = load(HEART_PATH + String(health % 3) + HEART_END)
			heart.status = max_health % 3
		else:
			heart.texture = load(HEART_PATH + "0" + HEART_END)
			heart.status = 0
	for balanci in $ui/balances/container.get_children():
		if balance < balanci.get_index() + 1:
			balanci.modulate.a = 0
			$ui/hearts/container.get_child(balanci.get_index()).modulate.a = 1
		else:
			balanci.modulate.a = 1
			$ui/hearts/container.get_child(balanci.get_index()).modulate.a = 0
	
func show_hearts():
	if balance != 0:
		return
	for balance in $ui/hearts/container.get_children():
		balance.visible = false
	for heart in $ui/hearts/container.get_children():
		heart.visible = true

func hide_hearts():
	if balance == 0:
		return
	for balance in $ui/hearts/container.get_children():
		balance.visible = true
	for heart in $ui/hearts/container.get_children():
		heart.visible = false

func set_hearts():
	clear_hearts()
	for i in range(max_health / 3):
		var new_balance = TextureRect.new()
		new_balance.texture = balance_view
		$ui/balances/container.add_child(new_balance)
		var new_heart = custom_heart.instance()
		new_heart.texture = load(HEART_PATH + "3" + HEART_END)
		new_heart.rect_min_size = balance_size
#		new_heart.visible = false
		new_heart.modulate.a = 0
		new_heart.status = 3
		$ui/hearts/container.add_child(new_heart)
		balance += 1
	if (max_health % 3) != 0:
		var new_balance = TextureRect.new()
		new_balance.texture = balance_view
		$ui/balances/container.add_child(new_balance)
		new_balance.modulate.a = 0
		var new_heart = custom_heart.instance()
		new_heart.texture = load(HEART_PATH + String(max_health % 3) + HEART_END)
		new_heart.rect_min_size = balance_size
#		new_heart.visible = false
		new_heart.status = max_health % 3
		$ui/hearts/container.add_child(new_heart)

func clear_hearts():
	for child in $ui/balances/container.get_children():
		$ui/balances/container.remove_child(child)
		child.queue_free()
	balance = 0
	for child in $ui/hearts/container.get_children():
		$ui/hearts/container.remove_child(child)
		child.queue_free()
