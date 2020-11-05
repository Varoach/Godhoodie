extends Control

func add_to_place_space(item):
	add_child(item)
	item.mode = 0

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	item.held = true
	item.mode = RigidBody2D.MODE_KINEMATIC
	item.bring_front()
	item.emit_signal("item_held")
   
	return item

func get_item_under_pos(pos):
	for item in get_parent().items.get_children():
#		if item.hover:
			if item == Game.item_held: continue
			if item.get_global_rect().has_point(pos):
				return item
	return null

func drop(item, impulse=Vector2.ZERO):
	if item.held:
		item.mode = RigidBody2D.MODE_CHARACTER
		item.apply_central_impulse(impulse)
		item.held = false
		item.emit_signal("item_dropped")
		Game.item_held = null
		item.send_back()
