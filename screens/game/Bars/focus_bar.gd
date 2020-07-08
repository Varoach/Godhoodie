extends TextureRect

var texture_on
var texture_off

func disable():
	texture = texture_off

func enable():
	texture = texture_on
