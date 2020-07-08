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

func _on_weapon_added():
	set_weapons()

func set_weapons():
	var pos = Vector2(0,0)
	for child in get_children():
		remove_child(child)

	for weapon_id in Inventory.player_inventory.weapons:
		var weapon = WeaponDB.whole_setup(weapon_id)
		weapon.position = pos
		add_child(weapon)
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

func set_focused_weapon(weapon):
	if _focused_weapon != null: return
	_focused_weapon = weapon
	weapon.save_animation_state()

func unset_focused_weapon(weapon):
	if _focused_weapon != weapon: return
	weapon.pop_animation_state()
	_focused_weapon = null
	weapon.reset_z_index()

func _on_weapon_mouse_entered(weapon):
	if weapon.highlight: return
	set_focused_weapon(weapon)

func _on_weapon_mouse_exited(weapon):
	if weapon.highlight: return
	unset_focused_weapon(weapon)

func _on_weapon_left_pressed(weapon):
#	if _focused_weapon != weapon: return
	play(weapon)

func _on_weapon_left_released(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.highlight: return

func _on_weapon_right_pressed(weapon):
	if _focused_weapon != weapon: return
	if weapon.highlight:
		unset_highlight_weapon(weapon)
	else:
		set_highlight_weapon(weapon)
		inventory.emit_signal("highlight", weapon)

func _on_weapon_right_released(weapon):
	if _focused_weapon != weapon: return

func unset_highlight_weapon(weapon):
	if _focused_weapon != weapon: return
	weapon.highlight = false
	weapon.pop_animation_state_global()
	inventory.emit_signal("unhighlight", weapon)

func set_highlight_weapon(weapon):
	if _focused_weapon != weapon: return
	weapon.highlight = true
	weapon.display_center()

func return_weapon():
	Inventory.add_weapon(_weapon_held)
	_weapon_held.return_weapon_state()
	_weapon_held = null

func get_weapon_under_pos(pos):
	for weapon in Inventory.player_inventory.weapons:
		if weapon == null:
			continue
		if weapon.get_global_rect().has_point(pos):
			return weapon
	return null

func play(weapon):
	emit_signal("play", weapon.get_weapon(), weapon.get_weapon().targets, name, weapon.get_weapon().bars)

func drop_weapon():
	Inventory.remove_weapon(_weapon_held)
	_weapon_held.delete_background()
	_weapon_held = null

func _on_weapon_played(weapon, status):
	if status:
		unset_focused_weapon(weapon)
	else:
		unset_focused_weapon(weapon)
