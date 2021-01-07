extends Node

var hashed_recipes = []

const RECIPES = [
	["Kunai", "Gel", "Blue Safflina"]
]

func _init():
	_hash_recipes()

func _hash_recipes():
	for recipe in RECIPES: # Loop through the array
		var new_recipe = recipe.duplicate() # Create a new subarray to preserve the orignal 
		new_recipe.pop_front() # Remove the first element (the resulting item)
		new_recipe.sort() # Sort it alphabetically
		hashed_recipes.append(new_recipe.hash()) # Hash the resulting array and add it to the hastable (the hashed_recipes array)

func _craft(items):
	items.sort() # Sort it aplhabetically
	var resulting_item = hashed_recipes.find(items.hash()) # Checks the hashed_recipes array for the current mix
	if resulting_item >= 0: # The mix matches a recipe
		return RECIPES[resulting_item][0].to_lower() # Check if already have one or more of the item
	else:
		return null

func _can_craft(items):
	items.sort() # Sort it aplhabetically
	var resulting_item = hashed_recipes.find(items.hash()) # Checks the hashed_recipes array for the current mix
	if resulting_item >= 0: # The mix matches a recipe
		return true # Check if already have one or more of the item
	return false
