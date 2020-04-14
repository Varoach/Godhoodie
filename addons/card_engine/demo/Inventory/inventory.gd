extends Node2D

var CardContainer= preload("res://addons/card_engine/card_container.gd")
var CardPile = preload("res://addons/card_engine/card_pile.gd")

var player_cards = CardPile.new()
var player_discard = CardPile.new()

var weapons = CardContainer.new()
var items = CardContainer.new()
var jutsus = CardContainer.new()
var ingredients = CardContainer.new()
