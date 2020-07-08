extends Node

var player_inventory = {"weapons" : [], "items" : [], "cards" : []}
var item_locations = {}

func add_weapon(weapon):
	player_inventory.weapons.append(weapon)

func add_item(item):
	player_inventory.items.append(item)

func add_card(card):
	player_inventory.cards.append(card)

func remove_weapon(weapon):
	if weapon in player_inventory.weapons:
		player_inventory.weapons.erase(weapon)

func remove_item(item):
	if item in player_inventory.items:
		player_inventory.items.erase(item)

func remove_card(card):
	if card in player_inventory.cards:
		player_inventory.cards.erase(card)

func copy():
	return self.duplicate()
