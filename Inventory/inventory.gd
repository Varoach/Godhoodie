extends Node

var player_inventory = {"weapons" : { 1 : {}, 2 : {}, 3 : {}}, "items" : [], "cards" : []}
var item_locations = {}
var weapons = 0
var trinket_hold = {1 : null, 2 : null, 3 : null, 4 : null, 5 : null, 6 : null}

func add_weapon(weapon):
	for hold in player_inventory.weapons:
		if player_inventory.weapons[hold].empty():
			player_inventory.weapons[hold].title = weapon
			player_inventory.weapons[hold].trinkets = trinket_hold.duplicate()
			player_inventory.weapons[hold].slot = hold
			weapons += 1
			return hold

func add_item(item):
	player_inventory.items.append(item)

func add_card(card):
	player_inventory.cards.append(card)

func remove_weapon(slot):
	player_inventory.weapons[slot].clear()
	weapons -= 1

func remove_item(item):
	if item in player_inventory.items:
		player_inventory.items.erase(item)

func remove_card(card):
	if card in player_inventory.cards:
		player_inventory.cards.erase(card)

func copy():
	return self.duplicate()

func add_trinket(trinket, slot, trinket_slot):
	player_inventory.weapons[slot].trinkets[trinket_slot] = trinket.title
