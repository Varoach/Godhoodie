extends Node

var item_test_ref = funcref(self, "test_item")
var item_single_ref = funcref(self, "apply_item")
var item_enemies_ref = funcref(self, "enemies_item")
var item_everyone_ref = funcref(self, "everyone_item")
var item_random_ref = funcref(self, "random_item")
var item_first_ref = funcref(self, "first_item")
var item_player_ref = funcref(self, "player_item")

var item_use_case = {"test" : item_test_ref, "single" : item_single_ref, "enemies" : item_enemies_ref, "everyone" : item_everyone_ref, "random" : item_random_ref, "first" : item_first_ref, "player" : item_player_ref}

func get_item_use(case, use):
	if use in case:
		return case[use]
	else:
		return null

func player_item(item, target = null):
	apply_item(item, Game.player)

func apply_item(item, target):
	var text_value = ""
	for value in item.values:
		var temp_value = item.values[value]
		if Game.temp_buffs.has(value):
			temp_value *= Game.temp_buffs[value]
	#			print(temp_value)
	#			print(Game.temp_buffs)
		if item.is_in_group("container"):
			temp_value *= item.stacks
		if target != null:
			if item.is_in_group("bomb"):
				for trigger in item.triggers:
					target.use_bomb(value, trigger, temp_value)
			else:
				target.use(value, temp_value)
			if Game.has_signal(value):
				Game.emit_signal(value)
			target.play_effect(item.title)
			if value != "cost":
				text_value = text_value + "\n" + String(temp_value) + " applied to " + target.name
	Game.emit_signal("step_text", text_value)

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

func test_item(item, value):
	var temp_value = item.values[value]
	if Game.temp_buffs.has(value):
		temp_value *= Game.temp_buffs[value]
	return temp_value
