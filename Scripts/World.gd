extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var player_node = preload("res://Scenes/player.tscn").instantiate()
	add_child(player_node)
	
	var name_box_node = preload("res://Scenes/Menus/TextBox.tscn").instantiate()
	add_child(name_box_node)
	
	var map_node = preload("res://Scenes/map_gen.tscn").instantiate()
	add_child(map_node)
	
	
