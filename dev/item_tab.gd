extends Tabs

var dev_item = load("res://dev/dev_item.tscn")

func _ready():
	var item_set = []
	for item in ItemDB.ITEMS:
		var new_item = dev_item.instance()
		new_item.item_id = item
		new_item.texture = load(ItemDB.get_item(item)["icon"])
		new_item.visible = true
		new_item.connect("left_pressed", self, "_on_left_pressed")
		item_set.append(new_item)
	set_items(item_set)

func set_items(item_set):
	for child in get_children():
		remove_child(child)
		child.queue_free()
	add_child(VBoxContainer.new())
	get_child(0).size_flags_horizontal = 2
	get_child(0).size_flags_vertical = 2
	get_child(0).margin_left = 20
	var counter = 0
	var step = -1
	for item in item_set:
		if counter % 8 == 0:
			get_child(0).add_child(HBoxContainer.new())
			step +=1
			get_child(0).get_child(step).rect_min_size = Vector2(0, 430)
		get_child(0).get_child(step).add_child(item)
		item.rect_min_size = Vector2(430, 430)
		counter += 1
	print(get_children())

func _on_left_pressed(item):
	ItemDB.pickup_item(item)
