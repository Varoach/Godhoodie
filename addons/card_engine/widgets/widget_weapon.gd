extends VBoxContainer

onready var inventory = get_node("../../../..")

var _weapon_held = null
var _focused_weapon = null
var weapon_offset = Vector2()
var grabbed_offset = Vector2(0,-50)

signal highlight()
signal unhighlight()
signal play(weapon)

# Called when the node enters the scene tree for the first time.
func _ready():
	WeaponDB.connect("weapon_added", self, "_on_weapon_added")
	inventory.connect("weapon_played", self, "_on_weapon_played")
	set_weapons()

func _process(delta):
	var cursor_pos = get_global_mouse_position()

func _on_weapon_added(weapon):
	set_weapon(weapon)

func set_weapon(weapon):
	weapon.position = Vector2(0, 0) + Vector2(0, 237) * (Inventory.weapons-1)
	add_child(weapon)
	if !weapon.ready:
#			weapon.connect("mouse_entered", self, "_on_weapon_mouse_entered", [weapon])
#			weapon.connect("mouse_exited", self, "_on_weapon_mouse_exited", [weapon])
			weapon.connect("left_pressed", self, "_on_weapon_left_pressed", [weapon])
#			weapon.connect("left_released", self, "_on_weapon_left_released", [weapon])
#			weapon.connect("right_pressed", self, "_on_weapon_right_pressed", [weapon])
#			weapon.connect("right_released", self, "_on_weapon_right_released", [weapon])
#			weapon.connect("mouse_motion", self, "_on_mouse_motion", [weapon])
			weapon.ready = true

func set_weapons():
	var pos = Vector2(0,0)
	for child in get_children():
		remove_child(child)

	if Inventory.weapons > 0:
		for weapon_id in Inventory.player_inventory.weapons:
			if !Inventory.player_inventory.weapons[weapon_id].empty():
				var weapon = WeaponDB.whole_setup(Inventory.player_inventory.weapons[weapon_id].title)
				weapon.weapon.slot = weapon_id
				var trinket_slots = 0
				add_child(weapon)
				for trinket in Inventory.player_inventory.weapons[weapon_id].trinkets:
					if Inventory.player_inventory.weapons[weapon_id].trinkets[trinket] != null:
						weapon.weapon_trinkets.get_child(trinket_slots).trinket_set(ItemDB.trinket_setup(Inventory.player_inventory.weapons[weapon_id].trinkets[trinket]))
					trinket_slots += 1
				weapon.position = pos
				pos += Vector2(0,237)
				if !weapon.ready:
		#			weapon.connect("mouse_entered", self, "_on_weapon_mouse_entered", [weapon])
		#			weapon.connect("mouse_exited", self, "_on_weapon_mouse_exited", [weapon])
					weapon.connect("left_pressed", self, "_on_weapon_left_pressed", [weapon])
		#			weapon.connect("left_released", self, "_on_weapon_left_released", [weapon])
		#			weapon.connect("right_pressed", self, "_on_weapon_right_pressed", [weapon])
		#			weapon.connect("right_released", self, "_on_weapon_right_released", [weapon])
		#			weapon.connect("mouse_motion", self, "_on_mouse_motion", [weapon])
					weapon.ready = true

func _on_weapon_left_pressed(weapon):
#	if _focused_weapon != weapon: return 
	play(weapon)

func return_weapon():
	Inventory.add_weapon(_weapon_held)
	_weapon_held.return_weapon_state()
	_weapon_held = null

func play(weapon):
	emit_signal("play", weapon.get_weapon(), weapon.get_weapon().targets, name, weapon.get_weapon().bars)

func drop_weapon():
	Inventory.remove_weapon(_weapon_held.slot)
	_weapon_held.delete_background()
	_weapon_held.queue_free()
	_weapon_held = null
	set_weapons()

func _on_weapon_played(weapon, status):
	return
