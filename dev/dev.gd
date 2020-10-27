extends Control

func _on_TextureButton_pressed():
	get_node("../").remove_child(self)
	queue_free()
