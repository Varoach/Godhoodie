extends Node

var last_item = null

var item_enemies_ref = funcref(self, "enemies_item")
var item_everyone_ref = funcref(self, "everyone_item")
var item_random_ref = funcref(self, "random_item")
var item_enemy_ref = funcref(self, "enemy_item")
var item_player_ref = funcref(self, "player_item")

var item_use_case = {"enemies" : item_enemies_ref, "everyone" : item_everyone_ref, "random" : item_random_ref, "enemy" : item_enemy_ref, "player" : item_player_ref}

func test_item(item):
	for cost in item.cost:
		if Game.values[cost] < item.cost[cost]:
			return false
	return true

func get_item_use(use):
	if use in item_use_case:
		return item_use_case[use]
	else:
		return null

func player_item(item):
	apply_item(item, Game.player)

func apply_item(item, target):
	if item.tags.has("weapon") or item.tags.has("jutsu"):
		if Game.values.energy == 0:
			print("energy false")
			return false
		if !test_item(item):
			print("cost false")
			return false
		if !item.cost.empty():
			for cost in item.cost:
				Game.values[cost] -= item.cost[cost]
		else:
			Game.values.energy -= 1
		Game.emit_signal("player_played")
	for value in item.values:
		var temp_value = item.values[value]
		if item.tags.has("container"):
			if item.stats.stacks == 0:
				return false
			temp_value *= item.stats.stacks
		target.use(value, temp_value, item)

	if item.tags.has("container"):
		item.stats.stacks = 0
		item.set_labels()
	if item.tags.has("weapon") or item.tags.has("container") or item.tags.has("jutsu"):
		return true
	else:
		item.emit_signal("remove_item", item)
	return true

func enemy_item(item):
	var first_enemy
	for enemy in Game.enemy_targets:
		if enemy != null:
			first_enemy = enemy
			break
	if first_enemy != null:
		apply_item(item, first_enemy)

func enemies_item(item):
	for target in Game.enemy_targets:
		apply_item(item, target)

func everyone_item(item):
	for target in Game.targets:
		apply_item(item, target)

func random_item(item):
	var target_type = item.targets
	if target_type == "enemy":
		apply_item(item, Game.enemy_targets[randi() % Game.enemy_targets.size()])
	elif target_type == "everyone":
		apply_item(item, Game.targets[(randi() % Game.targets.size())])
