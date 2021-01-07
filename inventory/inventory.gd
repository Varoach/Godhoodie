extends Control

func _ready():
	set_bitmap()
	$background/panel.connect("dust", self, "_on_dust_emitted")

func set_bitmap():
	var bm = BitMap.new()
	bm.create_from_image_alpha($top/accents.texture.get_data())
	var rect = Rect2($top/accents.rect_position.x, $top/accents.rect_position.y, $top/accents.texture.get_width(), $top/accents.texture.get_height())
	var my_array = bm.opaque_to_polygons(rect, 8.0)
	var my_polygon = Polygon2D.new()
	my_polygon.set_polygons(my_array)
	for i in range(my_polygon.polygons.size()):
		var my_collision = CollisionPolygon2D.new()
		my_collision.set_polygon(my_polygon.polygons[i])
		$top/accents/accent_body.call_deferred("add_child", my_collision)

func _on_dust_emitted(pos, item_size):
	$particles.global_position = pos
	$animator.play("emit")
