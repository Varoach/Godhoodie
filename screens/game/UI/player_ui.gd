extends CenterContainer

const HEART_PATH = "res://screens/game/UI/heart"

const HEART_OFFSET = 900

func _ready():
	heart_create()
	heart_set()

func heart_create():
	for i in range(Game.bars.health/3):
		var full_heart = Sprite.new()
		full_heart.texture = load(HEART_PATH + "1.png")
		full_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/emptyhealth.add_child(full_heart)
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + "4.png")
		new_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/health.add_child(new_heart)
	if int(Game.bars.health) % 3 != 0:
		var full_heart = Sprite.new()
		full_heart.texture = load(HEART_PATH + "1.png")
		full_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/emptyhealth.add_child(full_heart)
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + String((Game.bars.health % 3 + 1)) + ".png")
		new_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/health.add_child(new_heart)

func heart_setup():
	for heart in $playeruivertical/hearts/health.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET
		heart.position = Vector2(x, 0)
	$playeruivertical/hearts/healthnum.text = String(int(Game.curr_bars.health))

func heart_set():
	for heart in $playeruivertical/hearts/health.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET
		heart.position = Vector2(x, 0)
	for heart in $playeruivertical/hearts/emptyhealth.get_children():
		var index = heart.get_index()
		
		var x = index * HEART_OFFSET
		heart.position = Vector2(x, 0)
	$playeruivertical/hearts/healthnum.rect_position.x = $playeruivertical/hearts/emptyhealth.get_children().size() * 180
	$playeruivertical/hearts/healthnum.text = String(int(Game.bars.health))

func heart_change():
	for child in $playeruivertical/hearts/health.get_children():
		$playeruivertical/hearts/health.remove_child(child)
	for i in range(Game.curr_bars.health/3):
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + "4.png")
		new_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/health.add_child(new_heart)
	if int(Game.curr_bars.health) % 3 != 0:
		var new_heart = Sprite.new()
		new_heart.texture = load(HEART_PATH + String((int(Game.curr_bars.health) % 3 + 1)) + ".png")
		new_heart.hframes = $playeruivertical/hearts/health.hframes
		$playeruivertical/hearts/health.add_child(new_heart)
