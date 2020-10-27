extends Sprite

var value
var regular_pos = Vector2(-500,-452.5)

func set_value(value):
	$value.rect_position = regular_pos
	$value.text = String(value)
