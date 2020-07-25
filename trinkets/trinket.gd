extends Control

var this_weapon
var contains_trinket = false
var slot_number

func _ready():
	this_weapon = $"../../.."
	Game.trinkets.append(self)

func trinket_insert(trinket):
	if !contains_trinket:
		trinket.set_size(rect_size)
		trinket.global_position = rect_global_position
		var curr_trinket = trinket.image.duplicate()
		add_child(curr_trinket)
		buff_set(trinket)
		this_weapon.emit_signal("trinket_inserted", trinket, this_weapon.weapon.slot, slot_number)
		contains_trinket = true
		Inventory.remove_item(trinket.title)
		trinket.queue_free()
		return true
	else:
		return false

func trinket_set(trinket):
	if !contains_trinket:
		add_child(trinket)
		trinket.rect_size = rect_size
		trinket.rect_global_position = rect_global_position
#		buff_set(trinket)
		contains_trinket = true

func buff_set(trinket):
	for buff in trinket.buffs:
			if this_weapon.weapon.values.has(buff):
				this_weapon.weapon.values[buff] += trinket.buffs[buff]
			else:
				this_weapon.weapon.values[buff] = trinket.buffs[buff]
