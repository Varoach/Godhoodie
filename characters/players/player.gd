extends "../character.gd"

func _ready():
	max_health = 10
	health = 10
	connect("damage_received", self, "_on_damage_received")
	connect("heal_received", self, "_on_heal_received")
	balance = health/3

func _on_heal_received(value):
	if typeof(value) == TYPE_STRING:
		if value == "max":
			health = max_health
	else:
		health = int(clamp(health + value, 0, max_health))
	play_animation("heal")
	check_dead()

func _on_damage_received(value):
	if value >= health:
		before_balance = balance
		balance = 0
		health -= value
	elif value < health:
		if balance > 0:
			before_balance = balance
			balance -= 1
		else:
			before_balance = 0
			health -= value
#			play_animation("damage")
	check_dead()

func check_dead():
	if health <= 0:
		dead = true
		emit_signal("dead", self)

func restore_balance(amount):
	balance += amount

func restore_one_balance():
	balance += 1
