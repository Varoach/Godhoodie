extends Node2D

func play_effect(effect):
	$sprite.play(effect)

func _on_sprite_animation_finished():
	$sprite.animation = "default"
	$sprite.stop()
