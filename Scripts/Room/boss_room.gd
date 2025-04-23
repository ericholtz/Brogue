extends Node2D

var level
var player_start_pos = Vector2(2*16, 2*16)
var player_node: Node2D = null

func _ready():
	level = get_parent().level
	var boss_node = preload("res://Scenes/Enemies/Boss/Dragon.tscn").instantiate()
	boss_node.position = Vector2(13*16,13*16)
	add_child(boss_node)
	player_node = $"../../Player"
	player_node.global_position = player_start_pos

func _physics_process(delta):
	if player_node and not is_player_inside_room():
		player_node.global_position = player_start_pos

func is_player_inside_room() -> bool:
	# Room bounds based on prefab size and offset for walls
	var room_origin = global_position + Vector2(1 * 16, 1 * 16)  # offset by 1 tile from top-left
	var room_size = Vector2(30 * 16, 30 * 16)  # 30x30 tiles inside walls
	var room_rect = Rect2(room_origin, room_size)
	return room_rect.has_point(player_node.global_position)

func add_exit():
	var exit_node = preload("res://Scenes/Rooms/exit_door.tscn").instantiate()
	exit_node.position = Vector2(2*16,2*16)
	add_child(exit_node)


func add_key():
	var key_node = preload("res://Scenes/Items/Misc/Keys/MetalKey.tscn").instantiate()
	key_node.position = $"../../Player".global_position
	add_child(key_node)
