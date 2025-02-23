extends Node2D

var gold_worth : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var itemName = get_parent().get_child(0).name
	match itemName:
		"SmallGold":
			gold_worth = 2
		"MediumGold":
			gold_worth = 5
		"LargeGold":
			gold_worth = 10
		_:
			gold_worth = 0
	print(itemName, "'s gold worth = ", gold_worth)
