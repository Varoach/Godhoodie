extends Node

var SingleEnemy = preload("enemy.gd")

var _enemies = {}

# Loads the Library from the given file
func load_from_database(path):
	var file = File.new()
	var err = file.open(path, File.READ)
	if err == OK:
		var json = JSON.parse(file.get_as_text())
		if json.error == OK:
			_load_enemies(json.result)
		else:
			printerr("Error while parsing card database: ", json.error_string)
	else:
		printerr("Error while opening card database: ", file.get_error())

# Returns all the enemies as an array
func enemies():
	return _enemies.values()

# Returns the enemy with the given ID, duplicates the enemy by default
func enemy(single_enemy, duplicate = true):
	if !_enemies.has(single_enemy): return null
	
	if duplicate:
		return _enemies[single_enemy].duplicate()
	else:
		return _enemies[single_enemy]

# Returns the number of enemies
func size():
	return _enemies.size()

func _load_enemies(raw_data):
	var enemies =_extract_array_data(raw_data)
#	var papa_data = {"Enemies" : array_data}
#	var enemies = _extract_data(papa_data, "Enemies", {})
	
	for single_enemy in enemies:
		var enemy = SingleEnemy.new()
		
		enemy.id       = _extract_data(enemies[single_enemy], "title", "")
		enemy.health   = _extract_data(enemies[single_enemy], "health", "")
		enemy.category = _extract_data(enemies[single_enemy], "category", "")
		enemy.diff     = _extract_data(enemies[single_enemy], "difficulty", "")
		enemy.type     = _extract_data(enemies[single_enemy], "type", "")
		enemy.images   = _extract_data(enemies[single_enemy], "images", {})
		enemy.values   = _extract_data(enemies[single_enemy], "values", {})
		enemy.texts    = _extract_data(enemies[single_enemy], "texts", {})
		
		_enemies[single_enemy] = enemy

func _extract_data(dict, key, default):
	if dict.has(key):
		return dict[key]
	else:
		return default

func _extract_array_data(array):
	var array_data = {}
	for value in array:
		var newKey = value["title"]
		array_data[newKey] = value
	return array_data
