extends Node2D

var armor : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var itemName = get_parent().get_child(0).name
	match itemName:
		"LeatherArmor":
			armor = 1
		"ChainArmor":
			armor = 2
		_:
			armor = 0
	print(itemName, "'s armor = ", armor)
	
