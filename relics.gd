extends Node

var fools_gold_set = false

func fools_gold():
	if !Inventory.player_inventory.items.has("fools gold"):
#		print("false")
		fools_gold_setup(false)
	elif !fools_gold_set:
#		print("true")
		fools_gold_setup(true)
	elif !Game.temp_buffs.has("lightning"):
#		print("not here")
		Game.temp_buffs.lightning = 2
	else:
#		print("here")
		Game.temp_buffs.lightning += 1
	Game.emit_signal("update_cards")

func fools_gold_setup(status):
	if status:
		Game.connect("lightning", self, "fools_gold")
		fools_gold_set = true
	else:
		Game.disconnect("lightning", self, "fools_gold")
		fools_gold_set = false

func reset():
	fools_gold_set = false
