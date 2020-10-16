#extends Node
#
#var Enemies = preload("enemies.gd")
#
#var _enemies = Enemies.new()
#
#func _init():
#	_enemies.load_from_database(CEInterface.enemy_database_path())
#
# #Returns the Library singleton
#func enemy():
#	return _enemies
#
## Returns the path to the image with the given type and id
#func enemy_image(img_type, img_id):
#	return CEInterface.enemy_image(img_id)
#
## Returns the given value with buffs/debuffs taken into account
#func final_value(enemy_data, value):
#	if !enemy_data.values.has(value):
#		return 0
#	else:
#		return CEInterface.calculate_final_value(enemy_data, value)
#
## Returns the given text with placeholders replaced with the corresponding final value
#func final_text(enemy_data, text):
#	var final_text = enemy_data.texts[text]
#	for value in enemy_data.values:
#		final_text = final_text.replace("$%s" % value, "%d" % final_value(enemy_data, value))
#	return final_text
