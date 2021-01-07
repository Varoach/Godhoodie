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

func _ready():
	balance_size = Vector2(balance_view.get_width(), balance_view.get_height())
	set_ui()
	set_hearts()
	connect("damage_received", self, "_on_damage_received")
	connect("heal_received", self, "_on_heal_received")
	connect("cut_received", self, "_on_cut")
	connect("ice_received", self, "_on_ice")
	connect("fire_received", self, "_on_fire")
	connect("water_received", self, "_on_water")
	connect("sand_received", self, "_on_sand")
	set_size(check_size())

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

func _on_sand(value, item):
	var new_value = value
	if Game.round_buffs.has("sand"):
		new_value += Game.round_buffs.sand
	damage(new_value)
	if balance_break():
		Game.emit_signal("move_enemy", self, get_position() + 1)
		yield(Game, "enemy_moved")
		item.emit_signal("on_balance_break", self)

func get_position():
	return Game.enemy_targets.find(self)

func get_old_position():
	return old_position

func check_dead():
	if health <= 0:
		var summon
		if ItemUse.last_item.has_signal("on_kill"):
			ItemUse.last_item.emit_signal("on_kill", get_position())
			if ItemUse.last_item.summon_on_kill:
				summon = true
		if !summon:
			dead = true
			emit_signal("dead", self)
		else:
			dead = true
			emit_signal("dead", self, true)

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
	var man_present = false
	var new_targets = curr_targets.duplicate()
	for target in Game.global_targets:
		if target != self:
			new_targets.append(target)
	if sleep > 0:
		sleep -= 1
		return
	if loyal:
		if loyal != "player":
			for target in new_targets:
				if target.is_in_group(loyal):
					new_targets.erase(target)
	if !new_targets:
		return
	if is_in_group("man"):
		for target in new_targets:
				if target.is_in_group("monster"):
					new_targets.append(target)
				if target.is_in_group("beast"):
					new_targets.erase(target)
				if target.is_in_group("spirit"):
					pass
	if is_in_group("monster"):
		for target in new_targets:
			if target.is_in_group("man"):
				new_targets.append(target)
	if is_in_group("beast"):
		for target in new_targets:
			if target.is_in_group("man"):
				man_present = true
				break
	if man_present:
		for target in new_targets:
			if target.is_in_group("monster"):
				new_targets.append(target)
	if is_in_group("fear"):
		pass
	new_targets[randi() % new_targets.size()].use("attack", attack())

func loyal_set(target):
	loyal = target
	if loyal == "player":
		if curr_targets.has(Game.player):
			curr_targets.erase(Game.player)
	if loyal == "man":
		for target in curr_targets:
			if target.is_in_group("man"):
				if curr_targets.has(target):
					curr_targets.erase(target)

func loyal_unset():
	loyal = null
	if !curr_targets.has(Game.player):
		curr_targets.append(Game.player)

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

func divide():
	if dead or char_size == "small" or before_balance > 0:
		return
	if $animator.is_playing():
		yield($animator, "animation_finished")
	var new_char = EnemyDB.enemy_setup(title)
	
	var new_char_size = ""
	if char_size == "large":
		new_char_size = "medium"
	elif char_size == "medium":
		new_char_size = "small"
	char_size = new_char_size
	new_char.char_size = new_char_size
	
	var new_health = health/2
	max_health = new_health
	health = new_health
	new_char.max_health = new_health
	new_char.health = new_health
	
	set_hearts()
	new_char.set_hearts()
	
	set_size(check_size())
	new_char.set_size(new_char.check_size())
	
	Game.emit_signal("spawn_next_enemy", new_char)

func combine():
	if char_size == "large":
		return

func set_size(size):
	$sprite.scale = Vector2(size, size)
	$mouse_area.rect_scale = Vector2(size, size)
	position.y = -$mouse_area.rect_size.y * $mouse_area.rect_scale.y / 2

func check_size():
	if char_size == "large":
		return 0.8
	elif char_size == "medium":
		return 0.6
	elif char_size == "small":
		return 0.4
