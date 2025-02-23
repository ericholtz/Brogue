extends Node2D

enum Effect {HEALING, SPEED, POISON, PSYCHADELIC, PROTECTION}
var effect : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var itemName = get_parent().get_child(0).name
	match itemName:
		"BluePotion":
			effect = Effect.PROTECTION
		"GreenPotion":
			effect = Effect.POISON
		"OrangePotion":
			effect = Effect.SPEED
		"PurplePotion":
			effect = Effect.PSYCHADELIC
		"RedPotion":
			effect = Effect.HEALING
		_:
			effect = -1
	print(itemName, "'s effect = ", effect)
	
