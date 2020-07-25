extends TextureProgress

signal dead

func check_health():
	if value <= 0:
		emit_signal("dead")

func negative_health_update(health_change):
	value -= health_change
	check_health()

func positive_health_update(health_change):
	value += health_change
	check_health()

func set_health(max_health):
	max_value = max_health
	value = max_health

func can_heal():
	if value == max_value:
		return false
	else:
		return true
