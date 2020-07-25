extends Panel

signal shake()

var curr_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$animations.get_animation("show").track_set_key_value(1, 0, rect_position + Vector2(0, 100))
	$animations.get_animation("show").track_set_key_value(1, 1, rect_position)
	$animations.play("show")

func setup(title, desc, item):
	$item_set.position -= item.size * ItemDB.cell_size / 2
	$item_set.add_child(item)
	item.connect("shake_done", self, "_on_shake_done")
	curr_item = item
	$title.text = title
	$desc.text = desc

func _on_shake_done():
	emit_signal("shake")
