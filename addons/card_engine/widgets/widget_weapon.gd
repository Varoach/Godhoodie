extends VBoxContainer

const custom_background = preload("res://addons/card_engine/demo/weapons/weapon.tscn")
const custom_weapon = preload("res://addons/card_engine/demo/weapons/custom_weapon.tscn")

onready var inventory = get_node("../../../../..")

var _weapon_held = null
var _focused_weapon = null
var weapon_offset = Vector2()
var grabbed_offset = Vector2(0,-50)

signal highlight()
signal unhighlight()
signal play(weapon)

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.connect("weapon_played", self, "_on_weapon_played")
	add_weapon("wood")

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if _focused_weapon != null and _focused_weapon.drag:
		_focused_weapon.global_position = get_global_mouse_position() + grabbed_offset
		_focused_weapon.rotation_degrees = -90

func background_setup(background_id):
	var background = custom_background.instance()
	background.set_meta("id", background_id)
	background.texture = load(WeaponDB.get_background(background_id)["icon"])
	return background

func weapon_setup(weapon_id):
	var weapon = custom_weapon.instance()
	weapon.set_meta("id", weapon_id)
	weapon.set_texture(load(WeaponDB.get_weapon(weapon_id)["icon"]))
	weapon.name = weapon_id
	weapon.targets = WeaponDB.get_weapon(weapon_id)["targets"]
	weapon.rarity = WeaponDB.get_weapon(weapon_id)["rarity"]
	weapon.bars = WeaponDB.get_weapon(weapon_id)["bars"]
	if WeaponDB.get_weapon(weapon_id).has("values"):
		weapon.values = WeaponDB.get_weapon(weapon_id)["values"]
	weapon.connect("mouse_entered", self, "_on_weapon_mouse_entered", [weapon])
	weapon.connect("mouse_exited", self, "_on_weapon_mouse_exited", [weapon])
	weapon.connect("left_pressed", self, "_on_weapon_left_pressed", [weapon])
	weapon.connect("left_released", self, "_on_weapon_left_released", [weapon])
	weapon.connect("right_pressed", self, "_on_weapon_right_pressed", [weapon])
	weapon.connect("right_released", self, "_on_weapon_right_released", [weapon])
	weapon.connect("mouse_motion", self, "_on_mouse_motion", [weapon])
	return weapon

func add_weapon(weapon_id):
	if Game.weapons.size() == 3:
		return
	var weapon = weapon_setup(weapon_id)
	var background = background_setup(WeaponDB.get_weapon(weapon_id)["rarity"])
	background.set_weapon(weapon)
	background.set_title(weapon.name.capitalize())
	add_child(background)
	Game.weapons.append(weapon)
	weapon.save_animation_state()

func set_focused_weapon(weapon):
	if _focused_weapon != null: return
	_focused_weapon = weapon
	_focused_weapon.bring_front()
	_focused_weapon.push_animation_state(Vector2(0, 0), 0, Vector2(1.10, 1.10), true, true, true)

func unset_focused_weapon(weapon):
	if _focused_weapon != weapon: return
	_focused_weapon.pop_animation_state()
	_focused_weapon.reset_z_index()
	_focused_weapon = null

func unset_selected_weapon(weapon):
	if _focused_weapon != weapon: return
	_focused_weapon.pop_animation_state()

func _on_weapon_mouse_entered(weapon):
	set_focused_weapon(weapon)

func _on_weapon_mouse_exited(weapon):
	unset_focused_weapon(weapon)

func _on_weapon_left_pressed(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.highlight:
		unset_highlight_weapon(weapon)
	else:
		_focused_weapon.drag = true
		_focused_weapon.bring_front()

func _on_weapon_left_released(weapon):
	if _focused_weapon != weapon: return
	if _focused_weapon.highlight: return
	if _focused_weapon.drag:
		play(weapon)

func return_weapon():
	Game.weapons.append(_weapon_held)
	_weapon_held.return_weapon_state()
	_weapon_held = null

func get_weapon_under_pos(pos):
	for weapon in Game.weapons:
		if weapon == null:
			continue
		if weapon.get_global_rect().has_point(pos):
			return weapon
	return null

func unset_highlight_weapon(weapon):
	pass

func play(weapon):
	if _focused_weapon != weapon: return
	weapon.set_as_toplevel(false)
	weapon.drag = false
	emit_signal("play", weapon, weapon.targets, name, null,weapon.bars)

func drop_weapon():
	Game.weapons.remove(Game.weapons.find(_weapon_held))
	_weapon_held.delete_background()
	_weapon_held = null

func _on_weapon_played(weapon, status):
	if status:
		unset_focused_weapon(weapon)
	else:
		unset_focused_weapon(weapon)
