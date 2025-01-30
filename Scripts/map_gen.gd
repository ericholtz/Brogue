extends Node

@onready var room_scene : PackedScene = load("res://Scenes/room.tscn")

@onready var items : Array[PackedScene] = [
	load("res://Scenes/Items/Weapons/Melee/MetalSword.tscn")
	]
@onready var gold : Array[PackedScene] = [
	load("res://Scenes/Gold/SmallGold.tscn"),
	load("res://Scenes/Gold/MediumGold.tscn"),
	load("res://Scenes/Gold/LargeGold.tscn")
	]

var map_width : int = 7
var map_height : int = 7
var rooms_to_generate : int = 12
var room_count : int = 0
var rooms_instantiated : int
var first_room_pos : Vector2

var map : Array
var room_nodes : Array

#spawn chance
@export var enemy_spawn_chance : float
@export var coin_spawn_chance : float = 0.8
@export var item_spawn_chance : float = 0.5
@export var heart_spawn_chance : float

@export var max_enemies_per_room : int
@export var max_hearts_per_room : int
@export var max_coins_per_room : int = 10
@export var max_items_per_room : int = 5

func _ready() -> void:
	map = []
	room_nodes = []
	for y in range(map_height):
		map.append([])
		for x in range(map_width):
			map[y].append(false)
	seed(randi_range(0, 1000000))
	generate()
	

func generate() -> void:
	check_room(3, 3, 0, Vector2.ZERO, true)
	# Validate the first room position
	if not map[first_room_pos.x][first_room_pos.y]:
		adjust_first_room()
		
	var stri = ""
	for y in range(map_height):
		stri += "\n"
		for x in range(map_width):
			if map[x][y]:
				stri += "0"
			else:
				stri += "X"
	print(stri)
	instantiate_rooms()
	
	$"../Player".global_position = (first_room_pos * (272 - 8)) + Vector2(128, 128)
	print("First room position (grid):", first_room_pos)
	print("Player global position:", $"../Player".global_position)

func check_room(x : int, y : int, remaining : int, general_direction : Vector2, first_room : bool = false) -> void:
	# no generated rooms reached max
	if room_count >= rooms_to_generate:
		return
	# position of rooms falls outside of map range
	if x < 0 or x > map_width - 1 or y < 0 or y > map_height - 1:
		return
	# no more remainig rooms required to generate
	if first_room == false and remaining <= 0:
		return
	# room already exists
	if map[x][y] == true:
		return
		
	# get first room position
	if first_room and map[x][y] == false:
		first_room_pos = Vector2(x,y)
		print(first_room_pos)
		print(first_room_pos.x)
		
	room_count += 1
	map[x][y] = true
	
	var north : bool = randf() > (0.2 if general_direction == Vector2.UP else 0.8)
	var south : bool = randf() > (0.2 if general_direction == Vector2.DOWN else 0.8)
	var east : bool = randf() > (0.2 if general_direction == Vector2.RIGHT else 0.8)
	var west : bool = randf() > (0.2 if general_direction == Vector2.LEFT else 0.8)
	
	var max_remaining : int = rooms_to_generate / 4
	
	if north or first_room:
		check_room(x, y + 1, max_remaining if first_room else remaining - 1, Vector2.UP if first_room else general_direction)
	if south or first_room:
		check_room(x, y - 1, max_remaining if first_room else remaining - 1, Vector2.DOWN if first_room else general_direction)
	if east or first_room:
		check_room(x + 1, y, max_remaining if first_room else remaining - 1, Vector2.RIGHT if first_room else general_direction)
	if west or first_room:
		check_room(x - 1, y, max_remaining if first_room else remaining - 1, Vector2.LEFT if first_room else general_direction)
		
func instantiate_rooms() -> void:
	if rooms_instantiated:
		return
	rooms_instantiated = true
	
	for x in range(map_width):
		for y in range(map_height):
			if not map[x][y]:
				continue
				
			var room = room_scene.instantiate()
			room.position = Vector2(x, y) * 272
			
			if y < map_height - 1 and map[x][y + 1] == true:
				#print("Room at", x, y, "has a north neighbor at", x, y + 1)
				room.south()
			
			if y > 0 and map[x][y - 1] == true:
				#print("Room at", x, y, "has a south neighbor at", x, y - 1)
				room.north()
				
			if x > 0 and map[x - 1][y] == true:
				#print("Room at", x, y, "has a west neighbor at", x - 1, y)
				room.west()
				
			if x < map_width - 1 and map[x + 1][y] == true:
				#print("Room at", x, y, "has an east neighbor at", x + 1, y)
				room.east()
				
			# Randomly spawn items or monsters
			spawn_room_content(room)
			
			if(first_room_pos != Vector2(x, y)):
				room.Generation = self
				
			$"..".call_deferred("add_child", room)
			room_nodes.append(room)
	
	get_tree().create_timer(1)
	calculate_key_and_exit()


func calculate_key_and_exit() -> void:
	pass
	
func adjust_first_room() -> void:
	for x in range(map_width):
		for y in range(map_height):
			if map[x][y]:
				first_room_pos = Vector2(x, y)
				print("Adjusted first room position to: ", first_room_pos)
				return
				
func spawn_room_content(room: Node) -> void:
	# Spawn enemies
	#if randf() < enemy_spawn_chance:
		#for i in range(randi() % max_enemies_per_room + 1):  # Random number of enemies
			#var enemy = load("res://Scenes/enemy.tscn").instantiate()
			#enemy.position = get_random_position_in_room()
			#room.add_child(enemy)
	
	# Spawn coins
	if randf() < coin_spawn_chance:
		print("spawning coins")
		for i in range(randi() % max_coins_per_room + 1):  # Random number of coins
			var coin = gold.pick_random().instantiate()
			coin.z_index = 1
			coin.position = get_random_position_in_room(room)
			coin.position.x = floor(coin.position.x / 16) * 16 + 8
			coin.position.y = floor(coin.position.y / 16) * 16 + 8
			print(coin.position)
			if is_position_valid_for_item(coin.position, room):
				$"..".call_deferred("add_child", coin)

	# Spawn items
	if randf() < item_spawn_chance:
		print("spawning items")
		for i in range(randi() % max_items_per_room + 1):  # Random number of items
			var item = items.pick_random().instantiate()
			item.z_index = 1
			item.position = get_random_position_in_room(room)
			item.position.x = floor(item.position.x / 16) * 16 + 8
			item.position.y = floor(item.position.y / 16) * 16 + 8
			print(item.position)
			if is_position_valid_for_item(item.position, room):
				$"..".call_deferred("add_child", item)

func get_random_position_in_room(room : Node) -> Vector2:
	# Assuming a room size of 272x272
	return Vector2(
		(randf() * 144) + room.position.x + 16, 
		(randf() * 144) + room.position.y + 16
	)
	
func is_position_valid_for_item(position: Vector2, room: Node) -> bool:
	var items = room.get_children()
	for item in items:
		if item is Node2D and item.position.distance_to(position) < 32:
			print("failed to add gold")
			return false
	return true
## Function to calculate the size of a TileMap in pixels
#func get_tilemap_size(tilemap: TileMap) -> Vector2:
	## Get the cell size of the tiles
	#var cell_size = tilemap.cell_size
	## Get the grid size by finding the used rectangle
	#var used_rect = tilemap.get_used_rect()
	## Calculate the size of the TileMap in pixels
	#var map_width = used_rect.size.x * cell_size.x
	#var map_height = used_rect.size.y * cell_size.y
	#return Vector2(map_width, map_height)
