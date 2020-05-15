extends Node

var jutsu_single_ref = funcref(self, "apply_jutsu")
var jutsu_enemies_ref = funcref(self, "enemies_jutsu")
var jutsu_everyone_ref = funcref(self, "everyone_jutsu")
var jutsu_random_ref = funcref(self, "random_jutsu")

var item_single_ref = funcref(self, "apply_item")
var item_enemies_ref = funcref(self, "enemies_item")
var item_everyone_ref = funcref(self, "everyone_item")
var item_random_ref = funcref(self, "random_item")

var jutsu_use_case = {"single" : jutsu_single_ref, "enemies" : jutsu_enemies_ref, "everyone" : jutsu_everyone_ref, "random" : jutsu_random_ref}
var item_use_case = {"single" : item_single_ref, "enemies" : item_enemies_ref, "everyone" : item_everyone_ref, "random" : item_random_ref}
var weapon_use_case = {"single" : item_single_ref, "enemies" : item_enemies_ref, "everyone" : item_everyone_ref, "random" : item_random_ref}


func get_item_use(case, use):
	if use in case:
		return case[use]
	else:
		return null

func apply_jutsu(card, target):
	for value in card._card_data.values:
		if target != null and value != "cost":
			target.use(value, CardEngine.final_value(card.get_card_data(), value))

func enemies_jutsu(card, target = null):
	for target in Game.enemy_targets:
		apply_jutsu(card, target)

func everyone_jutsu(card, target = null):
	for target in Game.targets:
		apply_jutsu(card, target)

func random_jutsu(card, target = null):
	var target_type = card._card_data.target_type
	var target_amount = card._card_data.target_amount
	if Game.targets.size() > 1:
		for i in range(target_amount):
			random_hit_jutsu(card, target)
	else:
		random_hit_jutsu(card, target)

func random_hit_jutsu(card, target):
	var target_type = card._card_data.target_type
	var target_amount = card._card_data.target_amount
	if target_type == "enemy":
		apply_jutsu(card, Game.enemy_targets[randi() % Game.enemy_targets.size()])
	elif target_type == "everyone":
		apply_jutsu(card, Game.targets[(randi() % Game.targets.size())])

func apply_item(item, target):
	for value in item.values:
		if target != null:
			target.use(value, item.values[value])

func enemies_item(item, target = null):
	for target in Game.enemy_targets:
		apply_item(item, target)

func everyone_item(item, target = null):
	for target in Game.targets:
		apply_item(item, target)

func random_item(item, target = null):
	var target_type = item._card_data.target_type
	var target_amount = item._card_data.target_amount
	if Game.targets.size() > 1:
		for i in range(target_amount):
			random_hit_item(item, target)
	else:
		random_hit_item(item, target)

func random_hit_item(item, target):
	var target_type = item._card_data.target_type
	var target_amount = item._card_data.target_amount
	if target_type == "enemy":
		apply_jutsu(item, Game.enemy_targets[randi() % Game.enemy_targets.size()])
	elif target_type == "everyone":
		apply_jutsu(item, Game.targets[(randi() % Game.targets.size())])
