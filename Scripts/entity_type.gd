extends Node2D

enum Type {GOLD, MELEE_WEAPON, ARMOR, POTION, MISC}
var type : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match name:
		"SmallGold", "MediumGold", "LargeGold":
			type = Type.GOLD
		"GoldSword", "MetalBattleaxe", "MetalHammer", "MetalSword":
			type = Type.MELEE_WEAPON
		"ChainArmor", "LeatherArmor":
			type = Type.ARMOR
		"BluePotion", "GreenPotion", "OrangePotion", "PurplePotion", "RedPotion":
			type = Type.POTION
		"MetalKey":
			type = Type.MISC
		_:
			type = -1
	print(name, "'s type is ", type)
