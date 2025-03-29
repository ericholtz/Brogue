extends "misc_item.gd"

@export var map_level: int

# each map item decides the level it has info about on creation
func _ready():
	var current_level = get_parent().level
	map_level = current_level
	entity_name = str("Map - level ", current_level)
