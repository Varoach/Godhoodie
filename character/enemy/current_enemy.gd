extends "res://character/character.gd"

var Character = preload("res://character/character.gd")
var character_node = Character.new()

const FORMAT_LABEL = "lbl_%s"
const FORMAT_IMAGE = "img_%s"

var _enemy_data = null
var _is_ready = false

onready var healthbar = get_node("character/healthbar")

var abilities = {}
var _targets = { "attack" : Game.player, "heal" : self}

#signal _on_turn()

func _init():
	pass

func _ready():
	_is_ready = true
	healthbar.connect("dead", self, "_on_dead")
	healthbar.set_position(Vector2(healthbar.rect_position.x, $mouse_area.rect_position.y) + hpOffset * ($character/appearance.scale.y*1.5))
#	_update_enemy()
#
#func _update_enemy():
#	if _enemy_data == null || !_is_ready: return
#
#	# Images update
#	for image in _enemy_data.images:
#		var node = find_node(FORMAT_IMAGE % image)
#		if node != null:
#			var id = _enemy_data.images[image]
#			if id != "default":
#				node.texture = load(EnemyEngine.enemy_image(image, id))
#
#	var node = find_node("healthbar")
#	var id = _enemy_data.health
#	node.max_value = id
#
#
#func set_enemy_data(enemy_data):
#	_enemy_data = enemy_data
#	_update_enemy()
#	_enemy_data.connect("changed", self, "_update_enemy")

func _abilities():
	var curr_ability = abilities.duplicate()
	if not $character/healthbar.can_heal():
		curr_ability.erase("heal")
	while curr_ability.size() > 1:
		var power = curr_ability.keys()
		var selected_power = power[randi() % curr_ability.size()]
		curr_ability.erase(selected_power)
	return curr_ability

func _damage_received(value):
#	$animations.play("damage")
	healthbar.negative_health_update(value)

func _healing_received(value):
#	$animations.play("defend")
	healthbar.positive_health_update(value)

func play_turn():
	Game._stepper.start()
	cast(_abilities())

func cast(ability):
	var target
	var type
	if ability.keys().has("attack"):
		target = Game.player
		type = "attack"
	if ability.keys().has("heal"):
		target = self
		type = "heal"
	Game.enemy_use(type, target, ability.values()[0])
#	$animations.play("attack")

func enemy_setup(enemy_id):
	var single_enemy = load(EnemyDB.get_enemy(enemy_id)["path"])
	var enemy = single_enemy.instance()
	enemy.set_meta("id", enemy_id)
	enemy.abilities = EnemyDB.get_enemy(enemy_id)["abilities"]
	return enemy
