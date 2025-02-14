extends Node

@onready var room_scene : Array[PackedScene] = [
	load("res://Scenes/Rooms/room.tscn"),
	load("res://Scenes/Rooms/hallway.tscn")
	]

@onready var items : Array[PackedScene] = [
	# Weapons
	load("res://Scenes/Items/Weapons/Melee/GoldSword.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalSword.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalHammer.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalBattleaxe.tscn"),
	
	# Armor
	load("res://Scenes/Items/Armor/LeatherArmor.tscn"),
	load("res://Scenes/Items/Armor/ChainArmor.tscn"),
	
	# Potions
	load("res://Scenes/Items/Potions/BluePotion.tscn"),
	load("res://Scenes/Items/Potions/GreenPotion.tscn"),
	load("res://Scenes/Items/Potions/OrangePotion.tscn"),
	load("res://Scenes/Items/Potions/PurplePotion.tscn"),
	load("res://Scenes/Items/Potions/RedPotion.tscn"),
	
	# Misc
	load("res://Scenes/Items/Misc/MetalKey.tscn"),
	]

@onready var Skeleton_Warrior : Array[PackedScene] = [
	load("res://Scenes/Monsters/enemies.tscn")
	]

@onready var gold : Array[PackedScene] = [
	load("res://Scenes/Gold/SmallGold.tscn"),
	load("res://Scenes/Gold/MediumGold.tscn"),
	load("res://Scenes/Gold/LargeGold.tscn")
	]

# variables for map
var map_width : int = 7
var map_height : int = 7
var rooms_to_generate : int = 12
var room_count : int = 0
var rooms_instantiated : int
var first_room_pos : Vector2
var last_room : Node
var max_distance = -1

var map : Array
var room_nodes : Array
var current_seed = randi()

#spawn chance
@export var enemy_spawn_chance : float = 0.7
@export var coin_spawn_chance : float = 0.8
@export var item_spawn_chance : float = 0.5
@export var heart_spawn_chance : float

@export var max_enemies_per_room : int = 7
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

# clear all child nodes under map_gen
func clear_map() -> void:
	for child in $"../map_gen".get_children():
		child.queue_free()
	await get_tree().process_frame

# start inserting rooms into map
func generate() -> void:
	# varify map clear is finished
	await get_tree().process_frame
	check_room(3, 3, 0, Vector2.ZERO, true)
	# Validate the first room position
	if not map[first_room_pos.x][first_room_pos.y]:
		adjust_first_room()
	
	# print view of map generation in the command line
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
	add_exit_to_last_room()
	
	# move player to start position
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
		
	#if not is_hallway:
	room_count += 1
	
	map[x][y] = true
	
	# determine direction of open doors
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
				
			var room
			if Vector2(x, y) == first_room_pos:
				room = room_scene[0].instantiate()
				print("changed first room")
			else:
				room = room_scene.pick_random().instantiate()
			
			room.position = Vector2(x, y) * 272
			var distance = get_distance(Vector2(x, y), first_room_pos)
			
			if distance > max_distance and not room.room_name == "hallway":
				max_distance = distance
				last_room = room
			
			if y < map_height - 1 and map[x][y + 1] == true:
				room.south()
			
			if y > 0 and map[x][y - 1] == true:
				room.north()
				
			if x > 0 and map[x - 1][y] == true:
				room.west()
				
			if x < map_width - 1 and map[x + 1][y] == true:
				room.east()
			
			if(first_room_pos != Vector2(x, y)):
				room.Generation = self
				
			# add room to the world map
			$"../map_gen".add_child(room)
			
			# dont spawn content if its a hallway
			if room.room_name == "hallway":
				room.corner()
				
			# Randomly spawn items or monsters
			else:
				spawn_room_content(room)
			
			room_nodes.append(room)
	
	get_tree().create_timer(1)
	calculate_key_and_exit()


func calculate_key_and_exit() -> void:
	pass
	
# adjust the first room position if it does not spawn
func adjust_first_room() -> void:
	for x in range(map_width):
		for y in range(map_height):
			if map[x][y]:
				first_room_pos = Vector2(x, y)
				print("Adjusted first room position to: ", first_room_pos)
				return

# spawn all items/monsters/coins for each room
func spawn_room_content(room: Node) -> void:
	# Spawn Skeleton_Warrior
	if randf() < enemy_spawn_chance:
		print("Spawning: Skeleton Warriors")
		for i in range(randi() % max_enemies_per_room + 1):  # Random number of coins
			var SW = Skeleton_Warrior.pick_random().instantiate()
			SW.z_index = 1
			SW.position = get_random_position_in_room(room)
			SW.position.x = floor(SW.position.x / 16) * 16
			SW.position.y = floor(SW.position.y / 16) * 16 
			print(SW.position)
			if is_position_valid_for_item(SW.position, room):
				$"../map_gen".call_deferred("add_child", SW)
	
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
				$"../map_gen".call_deferred("add_child", coin)

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
				$"../map_gen".call_deferred("add_child", item)

# get random location in each given room
func get_random_position_in_room(room : Node) -> Vector2:
	# Assuming a room size of 272x272
	return Vector2(
		(randf() * 144) + room.position.x + 16, 
		(randf() * 144) + room.position.y + 16
	)

# validate the item will land within the room
func is_position_valid_for_item(position: Vector2, room: Node) -> bool:
	var roomItems = room.get_children()
	for item in roomItems:
		if item is Node2D and item.position.distance_to(position) < 32:
			print("failed to add gold")
			return false
	return true

# get the distance between first room and target room
func get_distance(start_pos : Vector2, target_pos : Vector2) -> int:
	return abs(start_pos.x - target_pos.x) + abs(start_pos.y - target_pos.y)

# insert exit door at farthest room location
func add_exit_to_last_room() -> void:
	if last_room:
		var exit = load("res://Scenes/Rooms/exit_door.tscn").instantiate()
		exit.z_index = 10
		exit.position = get_random_position_in_room(last_room)
		exit.position.x = floor(exit.position.x / 16) * 16 + 8
		exit.position.y = floor(exit.position.y / 16) * 16 + 8
		print(exit.position)
		if is_position_valid_for_item(exit.position, last_room):
			$"../map_gen".call_deferred("add_child", exit)

# when the level is complete regenerate a new map
func regenerate_map() -> void:
	# clear all children under map
	clear_map()
	await get_tree().process_frame
	# reset variables
	room_count = 0
	max_distance = -1
	rooms_instantiated = 0
	first_room_pos = Vector2.ZERO
	map = []
	room_nodes = []
	
	for y in range(map_height):
		map.append([])
		for x in range(map_width):
			map[y].append(false)
	seed(randi_range(0, 1000000))
	generate()
