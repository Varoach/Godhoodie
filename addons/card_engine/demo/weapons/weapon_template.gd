extends TextureRect

func set_weapon(weapon):
	$hcon/vcon/hcon2.add_child(weapon)

func set_title(title):
	$title.text = title
