extends Node2D

var attack : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var itemName = get_parent().get_child(0).name
	match itemName:
		"GoldSword":
			attack = 1
		"MetalBattleaxe":
			attack = 3
		"MetalHammer":
			attack = 2
		"MetalSword":
			attack = 4
	print(itemName, "'s attack = ", attack)
	
