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
	WeaponDB.pickup_weapon("wood sword")
	WeaponDB.pickup_weapon("wood sword")

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if _focused_weapon != null and _focused_weapon.drag:
		_focused_weapon.global_position = get_global_mouse_position() + grabbed_offset
		_focused_weapon.rotation_degrees = -90

func _on_weapon_added():
	set_weapons()

func set_weapons():
	var pos = Vector2(0,0)
	for child in get_children():
		remove_child(child)
	for weapon in Game.player_inventory.weapons:
		weapon.position = pos
		add_child(weapon)
		pos += Vector2(0,220)
#		weapon.connect("mouse_entered", self, "_on_weapon_mouse_entered", [weapon])
#		weapon.connect("mouse_exited", self, "_on_weapon_mouse_exited", [weapon])
#		weapon.connect("left_pressed", self, "_on_weapon_left_pressed", [weapon])
#		weapon.connect("left_released", self, "_on_weapon_left_released", [weapon])
#		weapon.connect("right_pressed", self, "_on_weapon_right_pressed", [weapon])
#		weapon.connect("right_released", self, "_on_weapon_right_released", [weapon])
#		weapon.connect("mouse_motion", self, "_on_mouse_motion", [weapon])

func set_focused_weapon(weapon):
	if _focused_weapon != null: return
	_focused_weapon = weapon
	weapon.save_animation_state()

func unset_focused_weapon(weapon):
	if _focused_weapon != weapon: return
	weapon.pop_animation_state()
	_focused_weapon = null
	weapon.reset_z_index()
#
func _on_weapon_mouse_entered(weapon):
	if weapon.highlight: return
	set_focused_weapon(weapon)

func _on_weapon_mouse_exited(weapon):
	if weapon.highlight: return
	unset_focused_weapon(weapon)

func _on_weapon_left_pressed(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.highlight:
		unset_highlight_weapon(weapon)
	else:
		_focused_weapon.drag = true

func _on_weapon_left_released(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.highlight: return
	if _focused_weapon.drag:
		play(weapon)

func _on_weapon_right_pressed(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.drag: return
	if weapon.highlight:
		unset_highlight_weapon(weapon)
	else:
		set_highlight_weapon(weapon)
		inventory.emit_signal("highlight", weapon)

func _on_weapon_right_released(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.drag: return

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
	Game.add_weapon(_weapon_held)
	_weapon_held.return_weapon_state()
	_weapon_held = null

func get_weapon_under_pos(pos):
	for weapon in Game.player_inventory.weapons:
		if weapon == null:
			continue
		if weapon.get_global_rect().has_point(pos):
			return weapon
	return null

func play(weapon):
	if _focused_weapon != weapon: return
	weapon.drag = false
	emit_signal("play", weapon.get_weapon(), weapon.get_weapon().targets, name, null, weapon.get_weapon().bars)

func drop_weapon():
	Game.remove_weapon(_weapon_held)
	_weapon_held.delete_background()
	_weapon_held = null

func _on_weapon_played(weapon, status):
	if status:
		unset_focused_weapon(weapon)
	else:
		unset_focused_weapon(weapon)
