extends "item.gd"

@export var effect: GameMaster.PotionEffect

func _ready():
	effect = GameMaster.potion_types[entity_name]
