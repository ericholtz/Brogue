extends Node2D

func _ready():
	
	var boss_node = preload("res://Scenes/Enemies/Boss/Dragon.tscn").instantiate()
	boss_node.position = Vector2(13*16,13*16)
	add_child(boss_node)
	
	$"../../Player".global_position = Vector2(2*16, 2*16)


func add_exit():
	var exit_node = preload("res://Scenes/Rooms/exit_door.tscn").instantiate()
	exit_node.position = Vector2(2*16,2*16)
	add_child(exit_node)


func add_key():
	var key_node = preload("res://Scenes/Items/Misc/Keys/MetalKey.tscn").instantiate()
	key_node.position = $"../../Player".global_position
	add_child(key_node)
