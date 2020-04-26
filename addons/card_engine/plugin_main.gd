# PluginMain class - CardEngine plugin entry point
tool
extends EditorPlugin

func _enter_tree():
	print("CardEngine enabled")
	add_custom_type(
		"CardWidget", "Node2D",
		preload("res://addons/card_engine/widgets/widget_card.gd"),
		preload("res://addons/card_engine/icons/card-node.png"))
		
	add_custom_type(
		"GridWidget", "Control",
		preload("res://addons/card_engine/widgets/widget_grid.gd"),
		preload("res://addons/card_engine/icons/container-node.png"))
		
	add_custom_type(
		"HandWidget", "Control",
		preload("res://addons/card_engine/widgets/widget_hand.gd"),
		preload("res://addons/card_engine/icons/hand-node.png"))
	add_custom_type(
		"ItemWidget", "Node2D",
		preload("res://addons/card_engine/widgets/widget_item.gd"),
		preload("res://addons/card_engine/icons/item-node.png"))
		
	add_custom_type(
		"ItemGridWidget", "Control",
		preload("res://addons/card_engine/widgets/widget_item_grid.gd"),
		preload("res://addons/card_engine/icons/item-grid-node.png"))
	
	add_custom_type(
		"MaterialWidget", "Node2D",
		preload("res://addons/card_engine/widgets/widget_material.gd"),
		preload("res://addons/card_engine/icons/material-node.png"))
	
	add_custom_type(
		"WeaponWidget", "Node2D",
		preload("res://addons/card_engine/widgets/widget_weapon.gd"),
		preload("res://addons/card_engine/icons/weapon-node.png"))

func _exit_tree():
	print("CardEngine disabled")
	remove_custom_type("CardWidget")
	remove_custom_type("GridWidget")
	remove_custom_type("HandWidget")
	remove_custom_type("ItemWidget")
	remove_custom_type("MaterialWidget")
	remove_custom_type("WeaponWidget")
