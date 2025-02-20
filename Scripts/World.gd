extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var cmd_node = preload("res://Scenes/Menus/command_line.tscn").instantiate()
	add_child(cmd_node)
	
	var player_node = preload("res://Scenes/Player.tscn").instantiate()
	add_child(player_node)
	
	var name_box_node = preload("res://Scenes/Menus/TextBox.tscn").instantiate()
	add_child(name_box_node)
	
	var map_node = preload("res://Scenes/map_gen.tscn").instantiate()
	add_child(map_node)
