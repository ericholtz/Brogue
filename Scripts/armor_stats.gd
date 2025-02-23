extends Node2D

var defense : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var itemName = get_parent().get_child(0).name
	match itemName:
		"LeatherArmor":
			defense = 1
		"ChainArmor":
			defense = 2
		_:
			defense = 0
	print(itemName, "'s defense = ", defense)
	
