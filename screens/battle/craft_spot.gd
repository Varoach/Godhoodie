extends Area2D

signal can_craft()

func _ready():
	connect("can_craft", $"../", "_on_can_craft")

func _on_craft_spot_body_entered(body):
	Game.crafting_items.append(body)
	Game.crafting.append(body.title)
	_craft_check()

func _on_craft_spot_body_exited(body):
	Game.crafting_items.erase(body)
	Game.crafting.erase(body.title)
	_craft_check()

func _craft_check():
	if RecipeDB._can_craft(Game.crafting):
		emit_signal("can_craft", true)
	else:
		emit_signal("can_craft", false)
