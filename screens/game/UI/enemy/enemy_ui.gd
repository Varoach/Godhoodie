extends Control

const HEART_PATH = "res://screens/game/UI/heart"

const HEART_OFFSET = 880

onready var enemy = get_node("../")

func _ready():
	heart_create(enemy.health)
	heart_set(enemy.health)

func heart_create(health):
	for _i in range(health):
		var full_heart = Sprite.new()
		full_heart.texture = load(HEART_PATH + "1.png")
		full_heart.hframes = $health.hframes
		$emptyhealth.add_child(full_heart)
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + "4.png")
		new_heart.hframes = $health.hframes
		$health.add_child(new_heart)
	if int(Game.bars.health) % 3 != 0:
		var full_heart = Sprite.new()
		full_heart.texture = load(HEART_PATH + "1.png")
		full_heart.hframes = $health.hframes
		$emptyhealth.add_child(full_heart)
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + String((Game.bars.health % 3 + 1)) + ".png")
		new_heart.hframes = $health.hframes
		$health.add_child(new_heart)

func heart_setup(health):
	for heart in $health.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET + 25
		heart.position = Vector2(x, 0)
	$healthnum.text = String(int(health))

func heart_set(health):
	for heart in $health.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET + 25
		heart.position = Vector2(x, 0)
	for heart in $emptyhealth.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET + 25
		heart.position = Vector2(x, 0)
	$healthnum.rect_position.x = $emptyhealth.get_children().size() * 132 + 30
	$healthnum.text = String(int(health))

func heart_change(health):
	for child in $health.get_children():
		$health.remove_child(child)
	for _i in range(health/3):
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + "4.png")
		new_heart.hframes = $health.hframes
		$health.add_child(new_heart)
	if int(health) % 3 != 0:
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + String((int(health) % 3 + 1)) + ".png")
		new_heart.hframes = $health.hframes
		$health.add_child(new_heart)
