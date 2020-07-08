extends Node

const RECIPES = {
	"fish" : {"fish" : "potion"}
}

func craft(item, held):
	if item in RECIPES:
		if held in RECIPES[item]:
			return ItemDB.item_setup(RECIPES[item][held])
		return null
	return null

func can_craft(item, held):
	if item in RECIPES:
		if held in RECIPES[item]:
			return true
		return false
	return false
