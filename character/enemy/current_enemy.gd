extends "res://character/character.gd"

const FORMAT_LABEL = "lbl_%s"
const FORMAT_IMAGE = "img_%s"

var _enemy_data = null
var _is_ready = false

onready var healthbar = get_node("character/healthbar")

var abilities = {}
var values = {}
var drops = {}
var _targets = { "attack" : Game.player, "heal" : self}

func _ready():
	_is_ready = true
	healthbar.connect("dead", self, "_on_dead")
	healthbar.set_position(Vector2(healthbar.rect_position.x, $mouse_area.rect_position.y) + hpOffset * ($character/appearance.scale.y*1.5))

func _abilities():
	var curr_ability = values.duplicate()
	if not $character/healthbar.can_heal():
		curr_ability.erase("heal")
	while curr_ability.size() > 1:
		var power = curr_ability.keys()
		var selected_power = power[randi() % curr_ability.size()]
		curr_ability.erase(selected_power)
	return curr_ability

func _damage_received(value):
	if Game.wall_defense > 0:
		if Game.wall_defense > value:
			Game.wall_defense -= value
			Game.emit_signal("wall_damage", value)
			value = 0
		elif Game.wall_defense >= Game.wall_defense:
			value -= Game.wall_defense
			Game.wall_defense = 0
			Game.emit_signal("wall_dead")
	if defense > value:
		defense -= value
		value = 0
	elif value >= defense:
		value -= defense
		defense = 0
	$character/defense.text = String(defense)
	if value <= 0:
#		$animations.play("defend")
		return
#	$animations.play("damage")
	healthbar.negative_health_update(value)

func _healing_received(value):
#	$animations.play("defend")
	healthbar.positive_health_update(value)

func play_turn():
	Game._stepper.start()
	cast(_abilities())

func set_max_health():
	$character/healthbar.set_health(health)

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

func set_texture(image):
	var sprite_frame = SpriteFrames.new()
	sprite_frame.add_animation("default")
	sprite_frame.add_frame("default", image)
	$character/appearance.frames = sprite_frame
