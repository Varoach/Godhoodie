extends Node

var item_single_ref = funcref(self, "apply_item")
var item_enemies_ref = funcref(self, "enemies_item")
var item_everyone_ref = funcref(self, "everyone_item")
var item_random_ref = funcref(self, "random_item")
var item_first_ref = funcref(self, "first_item")

var item_use_case = {"single" : item_single_ref, "enemies" : item_enemies_ref, "everyone" : item_everyone_ref, "random" : item_random_ref, "first" : item_first_ref}

func get_item_use(case, use):
	if use in case:
		return case[use]
	else:
		return null

func apply_item(item, target):
	for value in item.values:
		var temp_value = item.values[value]
		if Game.temp_buffs.has(value):
			temp_value *= Game.temp_buffs[value]
			print(temp_value)
			print(Game.temp_buffs)
		if target != null:
			target.use(value, temp_value)

func enemies_item(item, target = null):
	for target in Game.enemy_targets:
		apply_item(item, target)

func everyone_item(item, target = null):
	for target in Game.targets:
		apply_item(item, target)

func random_item(item, target = null):
	var target_type = item.target_type
	var target_amount = item.target_amount
	if Game.targets.size() > 1:
		for _i in range(target_amount):
			random_hit_item(item)
	else:
		random_hit_item(item)

func first_item(item, target = null):
	apply_item(item, Game.enemy_targets[0])

func random_hit_item(item):
	var target_type = item.target_type
	if target_type == "enemy":
		apply_item(item, Game.enemy_targets[randi() % Game.enemy_targets.size()])
	elif target_type == "everyone":
		apply_item(item, Game.targets[(randi() % Game.targets.size())])
