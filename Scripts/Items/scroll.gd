extends "item.gd"

@export var effect: GameMaster.ScrollEffect

func _ready():
	effect = GameMaster.ScrollEffect.values().pick_random()
	entity_name = "Scroll titled '" + GameMaster.scroll_titles[effect] + "'"
	find_child("Sprite2D").set_region_rect(GameMaster.scroll_sprite_regions[effect])
