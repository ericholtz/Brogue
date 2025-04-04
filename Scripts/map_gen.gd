extends Node

# rooms
@onready var room_scene: Array[PackedScene] = [
	load("res://Scenes/Rooms/fog_room.tscn"),
	load("res://Scenes/Rooms/room.tscn"),
	load("res://Scenes/Rooms/hallway.tscn"),
	load("res://Scenes/Rooms/largeroomHor.tscn"),
	load("res://Scenes/Rooms/largeroomVert.tscn")
	]

# items
@onready var melee_weapons: Array[PackedScene] = [
	load("res://Scenes/Items/Weapons/Melee/GoldSword.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalSword.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalHammer.tscn"),
	load("res://Scenes/Items/Weapons/Melee/MetalBattleaxe.tscn"),
	]

@onready var armor: Array[PackedScene] = [
	load("res://Scenes/Items/Armor/LeatherArmor.tscn"),
	load("res://Scenes/Items/Armor/ChainArmor.tscn"),
	]

@onready var potions: Array[PackedScene] = [
	load("res://Scenes/Items/Potions/RedPotion.tscn"),
	load("res://Scenes/Items/Potions/OrangePotion.tscn"),
	load("res://Scenes/Items/Potions/GreenPotion.tscn"),
	load("res://Scenes/Items/Potions/PurplePotion.tscn"),
	load("res://Scenes/Items/Potions/BluePotion.tscn"),
	]

@onready var misc: Array[PackedScene] = [
	load("res://Scenes/Items/Misc/Map.tscn"),
	]

@onready var keys: Array[PackedScene] = [
	load("res://Scenes/Items/Misc/Keys/MetalKey.tscn"),
	load("res://Scenes/Items/Misc/Keys/GoldKey.tscn"),
	]

	##-----(Enemy Types)-----##
@onready var Cave_enemies : Array[PackedScene] = [
	load("res://Scenes/Enemies/Cave_Enemies/Skeleton_Warrior.tscn"),
	load("res://Scenes/Enemies/Cave_Enemies/Bat.tscn"),
	load("res://Scenes/Enemies/Cave_Enemies/Skeleton_Archer.tscn")
	]
	
@onready var Big_ice_enemies : Array[PackedScene] = [
	load("res://Scenes/Enemies/Ice_Enemies/Polar_Bear.tscn"),
	load("res://Scenes/Enemies/Ice_Enemies/Enraged_Polar_Bear.tscn")
	]

@onready var Ice_enemies : Array[PackedScene] = [
	load("res://Scenes/Enemies/Ice_Enemies/Skeleton_Ice_Mage.tscn"),
	load("res://Scenes/Enemies/Ice_Enemies/Ice_Serpent.tscn")
	]

@onready var Boss : Array[PackedScene] = [
	load("res://Scenes/Enemies/Boss/Dragon.tscn")
	]

@onready var Rare_ice_enemies : Array[PackedScene] = [
	load("res://Scenes/Enemies/Rare_Enemies/Snowman.tscn")
	]
	##-----(Enemy Types)-----##


@onready var gold: Array[PackedScene] = [
	load("res://Scenes/Gold/SmallGold.tscn"),
	load("res://Scenes/Gold/MediumGold.tscn"),
	load("res://Scenes/Gold/LargeGold.tscn")
	]

@onready var exit_scene : Array[PackedScene] = [load("res://Scenes/Rooms/exit_door.tscn")]

var level : int = 1

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
var room_grid
var vec_map

# Base values for scaling
const BASE_MAP_SIZE = 7
const BASE_ROOMS = 12

##-----(Base Enemy Spawn Chance)-----##
const BASE_CAVE_ENEMY_SPAWN_CHANCE = 0.1
const BASE_RARE_ENEMY_SPAWN_CHANCE = 0.01
const BASE_ICE_ENEMY_SPAWN_CHANCE = 0.05
const BASE_BIG_ICE_ENEMY_SPAWN_CHANCE = 0.05
const BASE_BOSS_ENEMY_SPAWN_CHANCE = 1
const BASE_ICE_MAX_ENEMIES = 5
const BASE_CAVE_MAX_ENEMIES = 10
const BASE_BOSS_MAX_ENEMIES = 1
const BASE_RARE_ICE_MAX_ENEMIES = 1
const BASE_ICE_BIG_ENEMIES = 5
##-----(Base Enemy Spawn Chance)-----##

const BASE_MAX_GOLD = 2
const BASE_MAX_MELEE_WEAPONS = 1
const BASE_MAX_ARMOR = 1
const BASE_MAX_POTIONS = 1
const BASE_MAX_MISC = 1

# Scaling factors
const MAP_GROWTH_RATE = 2  # How much the map increases each level
const ROOMS_GROWTH_RATE = 3  # Additional rooms per level
const SPAWN_RATE_INCREMENT = 0.05  # Increases spawn rates per level
const ENEMY_GROWTH_RATE = 1  # Increase max enemies per level

# spawn chance
##-----(Enemy Spawn Chance)-----##
@export var cave_enemy_spawn_chance : float = 0.9
@export var rare_ice_enemy_spawn_chance : float = 0.01
@export var ice_enemy_spawn_chance : float = 0.45
@export var big_ice_enemy_spawn_chance : float = 0.45
@export var boss_enemy_spawn_chance : float = 1.0
##-----(Enemy Spawn Chance)-----##

@export var gold_spawn_chance : float = 0.2
@export var melee_weapon_spawn_chance : float = 0.1
@export var armor_spawn_chance : float = 0.1
@export var potion_spawn_chance : float = 0.1
@export var misc_spawn_chance : float = 0.1
@export var heart_spawn_chance : float

# max per room
##-----(Max Enemies Per Room)-----##
@export var max_cave_enemies_per_room : int = 2
@export var max_boss_enemies_per_room : int = 1
@export var max_ice_enemies_per_room : int = 1
@export var max_big_ice_enemies_per_room : int = 1
@export var max_rare_ice_enemies_per_room : int = 1
##-----(Max Enemies Per Room)-----##

@export var max_hearts_per_room : int
@export var max_gold_per_room : int = 2
@export var max_melee_weapons_per_room : int = 1
@export var max_armor_per_room : int = 1
@export var max_potions_per_room : int = 1
@export var max_misc_per_room : int = 1

func _ready() -> void:
	# array of the valid rooms
	map = []
	# dictionary of location and room name
	room_grid = {}
	# dictionary of location and room node
	vec_map = {}
	
	# setup for inserting a seed befor begining of run
	if GameMaster.user_seed:
		GameMaster.current_seed = GameMaster.user_seed
	# start with random seed
	else:
		GameMaster.current_seed = randi_range(1, 1000000000)
	
	# initilize all nodes to false and null
	for y in range(map_height):
		map.append([])
		for x in range(map_width):
			map[y].append(false)
			room_grid[Vector2(x, y)] = null
			vec_map[Vector2(x,y)] = null
	generate(0)
	await get_tree().process_frame
	# move player to start position maybe need await for new tree before moving player
	$"../Player".global_position = (first_room_pos * (272)) + Vector2(80, 80)
	if GameMaster.DEBUG_MAP: 
		print("First room position (grid):", first_room_pos)
		print("Player global position:", $"../Player".global_position)

# clear all child nodes under map_gen
func clear_map() -> void:
	for child in get_children():
		child.queue_free()
	await get_tree().process_frame

# start inserting rooms into map
func generate(cur_level : int) -> void:
	# varify map clear is finished
	await get_tree().process_frame
	var size_h = round(map_height / 2)
	var size_w = round(map_width / 2)
	
	seed(GameMaster.current_seed + cur_level)
	# populate map with all rooms
	check_room(size_w, size_h, 0, Vector2.ZERO, true)
	
	# print view of map generation in the command line
	var stri = ""
	for y in range(map_height):
		stri += "\n"
		for x in range(map_width):
			if map[x][y]:
				stri += "0"
			else:
				stri += "X"
	if GameMaster.DEBUG_MAP: print(stri)
	# place rooms according to map
	instantiate_rooms()
	# insert the exit at the farthest room from start
	add_exit_to_last_room()
	# add key in a random room
	place_entity_in_random_room(keys.pick_random().instantiate())

# populates an array map for all valid rooms to be generated
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
	if map[x][y]:
		return
	
	# get first room position
	if first_room:
		first_room_pos = Vector2(x, y)
		if GameMaster.DEBUG_MAP: print(first_room_pos)
		
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

# pick a room from the list of rooms to put into the world
func instantiate_rooms() -> void:
	# Base room options (default to only room and hallway)
	if rooms_instantiated:
		return
	rooms_instantiated = true
	
	for x in range(map_width):
		for y in range(map_height):
			create_fog_room(x, y)
			if not map[x][y] or room_grid[Vector2(x, y)]:
				continue

			var valid_rooms = [room_scene[1], room_scene[2]]
			var room

			# See if next cells are mergeable
			var merge_right = x < map_width - 1 and map[x + 1][y] and room_grid[Vector2(x + 1, y)] == null
			var merge_down = y < map_height - 1 and map[x][y + 1] and room_grid[Vector2(x, y + 1)] == null
			
			# Try to merge horizontally if possible
			if merge_right:
				if GameMaster.DEBUG_MAP: print(map[x+1][y], Vector2(x+1,y))
				if y > 0 and x < map_width - 1 and not room_grid[Vector2(x, y - 1)] == "Large Vertical" and not room_grid[Vector2(x + 1, y - 1)] == "Large Vertical":
					valid_rooms.append(room_scene[3])
				elif y == 0:
					valid_rooms.append(room_scene[3])
			
			# Try to merge vertically if possible
			if merge_down:
				if GameMaster.DEBUG_MAP: print(map[x][y+1], Vector2(x, y+1))
				if x > 0 and y < map_height - 1 and not room_grid[Vector2(x - 1, y)] == "Large Horizontal" and not room_grid[Vector2(x - 1, y + 1)] == "Large Horizontal":
					valid_rooms.append(room_scene[4])  # Large Vertical
				elif x == 0:
					valid_rooms.append(room_scene[4])  # Large Vertical
			
			# this is supposed to make spawn room the base room every time...
			if Vector2(x, y) == first_room_pos:
				room = room_scene[1].instantiate()
				if GameMaster.DEBUG_MAP: print("changed first room")
			else:
				room = valid_rooms.pick_random().instantiate()  # Pick from valid list
			
			room_grid[Vector2(x, y)] = room.room_name
			# Mark merged tiles for large rooms
			if room.room_name == "Large Horizontal":
				room_grid[Vector2(x + 1, y)] = room.room_name
				vec_map[Vector2(x + 1, y)] = room
			elif room.room_name == "Large Vertical":
				room_grid[Vector2(x, y + 1)] = room.room_name
				vec_map[Vector2(x, y + 1)] = room
				
			# set position in room and check distance from first room
			room.position = Vector2(x, y) * 272
			var distance = get_distance(Vector2(x, y), first_room_pos)
			
			# set a last_room to the farthest room generated
			if distance > max_distance and not room.room_name == "hallway":
				max_distance = distance
				last_room = room
			
			# logic for opening doors between each of the generated rooms and halls
			if y < map_height - 1 and map[x][y + 1]:
				if room.room_name == "Large Horizontal":
					room.southleft()
				elif room.room_name != "Large Vertical":
					room.south()
			
			# check below double vertical room
			if y < map_height - 2 and map[x][y + 2] and room.room_name == "Large Vertical":
				room.south()
			
			if x < map_width - 1 and y < map_height - 1 and map[x + 1][y] and map[x + 1][y + 1]:
				if room.room_name == "Large Horizontal":
					room.southright()
			
			if y > 0 and map[x][y - 1]:
				if room.room_name == "Large Horizontal":
					room.northleft()
				else:
					room.north()
			
			if x < map_width - 1 and y > 0 and map[x + 1][y - 1] and map[x + 1][y]:
				if room.room_name == "Large Horizontal":
					room.northright()
			
			if x > 0 and map[x - 1][y]:
				if room.room_name == "Large Vertical":
					room.westtop()
				else:
					room.west()
			
			if x > 0 and y < map_height - 1 and map[x - 1][y + 1]:
				if room.room_name == "Large Vertical":
					room.westbot()
			
			if x < map_width - 1 and map[x + 1][y]: 
				if room.room_name == "Large Vertical":
					room.easttop()
				elif room.room_name != "Large Horizontal":
					room.east()
			
			# check to the right of a double horizontal room
			if x < map_width - 2 and map[x + 2][y]:
				if room.room_name == "Large Horizontal":
					room.east()
			
			if x < map_width - 1 and y < map_height - 1 and map[x + 1][y + 1]:
				if room.room_name == "Large Vertical":
					room.eastbot()
			
			if(first_room_pos != Vector2(x, y)):
				room.Generation = self
				
			# create dictionary to get room node back when needed
			vec_map[Vector2(x,y)] = room
			# add room to the world map
			add_child(room)
			
			# dont spawn content if its a hallway
			if room.room_name == "hallway":
				room.corner()
			
			# Randomly spawn items or monsters
			else:
				spawn_room_content(room)
			
	get_tree().create_timer(1)

# add fog to all empty rooms to make it look nice
func create_fog_room(x : int, y : int):
	if map[x][y]:
		return
	var room = room_scene[0].instantiate()
	room.position = Vector2(x, y) * 272
	add_child(room)

# adjust the first room position if it does not spawn
func adjust_first_room() -> void:
	for x in range(map_width):
		for y in range(map_height):
			if map[x][y]:
				first_room_pos = Vector2(x, y)
				print("Adjusted first room position to: ", first_room_pos)
				return

# spawn all enemies/gold/items for each room
func spawn_room_content(room: Node) -> void:
	##-----(Spawn Enemies)-----##
	# Spawn Cave enemies
	if level == 1:
		if GameMaster.DEBUG_MAP: print("Spawning Cave: Enemies")
		spawn_entities(room, Cave_enemies, cave_enemy_spawn_chance, max_cave_enemies_per_room)
		
	if level >= 2:
		# Spawn Ice enemies
		spawn_entities(room, Big_ice_enemies, cave_enemy_spawn_chance, max_cave_enemies_per_room)
		if GameMaster.DEBUG_MAP: print("Spawning Small Ice: Enemies")
		spawn_entities(room, Ice_enemies, ice_enemy_spawn_chance, max_ice_enemies_per_room)
		# Spawn Big enemies
		if GameMaster.DEBUG_MAP: print("Spawning Big: Enemies")
		spawn_entities(room, Big_ice_enemies, big_ice_enemy_spawn_chance, max_big_ice_enemies_per_room)
		# Spawn Rare enemies
		if GameMaster.DEBUG_MAP: print("Spawning Rare: Enemies")
		spawn_entities(room, Rare_ice_enemies, rare_ice_enemy_spawn_chance, max_rare_ice_enemies_per_room)
	
	#if level == 3:
		## Spawn Boss enemies
		#if GameMaster.DEBUG_MAP: print("Spawning Boss: Enemy")
		#spawn_entities(room, Boss, boss_enemy_spawn_chance, max_boss_enemies_per_room)
	##-----(Spawn Enemies)-----##
	
	# Spawn gold
	if GameMaster.DEBUG_MAP: print("Spawning: Gold")
	spawn_entities(room, gold, gold_spawn_chance, max_gold_per_room)
	# Spawn melee_weapons
	if GameMaster.DEBUG_MAP: print("Spawning: Weapons")
	spawn_entities(room, melee_weapons, melee_weapon_spawn_chance, max_melee_weapons_per_room)
	# Spawn armor
	if GameMaster.DEBUG_MAP: print("Spawning: Armor")
	spawn_entities(room, armor, armor_spawn_chance, max_armor_per_room)
	# Spawn potions
	if GameMaster.DEBUG_MAP: print("Spawning: Potions")
	spawn_entities(room, potions, potion_spawn_chance, max_potions_per_room)
	# Spawn misc
	if GameMaster.DEBUG_MAP: print("Spawning: Misc")
	spawn_entities(room, misc, misc_spawn_chance, max_misc_per_room)

# spawn one entity based off room, instantiated node, and chance and max constants about the node
func spawn_entities(room : Node, entity_pool : Array[PackedScene], spawn_chance : float, max_per_room : int) -> void:
	if randf() < spawn_chance:
		for i in range(randi() % max_per_room + 1):  # Random number of gold
			var positions = []
			var entity = entity_pool.pick_random().instantiate()
			var check_pos = get_random_position_in_room(room, entity.entity_size)
			check_pos.x = floor(check_pos.x / 16) * 16
			check_pos.y = floor(check_pos.y / 16) * 16
			for j in range(entity.entity_size.x):
				for k in range(entity.entity_size.y):
					positions.append(Vector2i(check_pos.x + j, check_pos.y + k))
			var type = GameMaster.EntityType.keys()[entity.entity_type]
			#if positions.size() > 1:
			for vect in positions:
				if room.spawned_entity[type].has(vect):
					entity.queue_free()
					return
				else:
					room.spawned_entity[type].append(vect)
			entity.position = check_pos
			
			if GameMaster.DEBUG_MAP: print(entity.position)
			if is_position_valid_for_item(entity.position, room):
				call_deferred("add_child", entity)

# get random location in each given room
func get_random_position_in_room(room : Node, size : Vector2i) -> Vector2:
	# Assuming a room size of 272x272
	return Vector2(
		(randf() * (room.inside_width - (size.x - 1)) * 16) + room.position.x + 16, 
		(randf() * (room.inside_height - (size.y - 1)) * 16) + room.position.y + 16
	)

# validate the item will land within the room
func is_position_valid_for_item(position: Vector2, room: Node) -> bool:
	var roomItems = room.get_children()
	for item in roomItems:
		if item is Node2D and item.position.distance_to(position) < 32:
			print("failed to add thing to room")
			return false
	return true

# get the distance between first room and target room
func get_distance(start_pos : Vector2, target_pos : Vector2) -> int:
	return abs(start_pos.x - target_pos.x) + abs(start_pos.y - target_pos.y)

# insert exit door at farthest room location
func add_exit_to_last_room():
	if last_room:
		var exit = exit_scene[0].instantiate()
		exit.position = get_random_position_in_room(last_room, exit.entity_size)
		exit.position.x = floor(exit.position.x / 16) * 16
		exit.position.y = floor(exit.position.y / 16) * 16
		if GameMaster.DEBUG_MAP: print(exit.position)
		call_deferred("add_child", exit)
		return true
	else:
		return false

# command line spawn
func force_spawn(player_pos : Vector2, entity : String, option : int):
	var spawn_options = {
		"melee_weapon": melee_weapons,
		"armor": armor,
		"potion": potions,
		"misc": misc,
		"cave_enemy": Cave_enemies,
		"big_ice_enemy": Big_ice_enemies,
		"ice_enemy": Ice_enemies,
		"rare_ice_enemy": Rare_ice_enemies,
		"boss_enemy": Boss,
		"gold": gold,
		"exit": exit_scene,
		"keys": keys
		}
	if spawn_options.keys().has(entity):
		if spawn_options[entity].size() > option and option >= 0:
			var cur_room = vec_map[((player_pos) / 272).floor()]
			if cur_room.room_name == "hallway":
				$"../CommandLine".command_history.append("cant spawn inside " + cur_room.room_name)
				return false
			var thing = spawn_options[entity][option].instantiate()
			thing.position = get_random_position_in_room(cur_room, thing.entity_size)
			thing.position.x = floor(thing.position.x / 16) * 16
			thing.position.y = floor(thing.position.y / 16) * 16
			if GameMaster.DEBUG_MAP: print(thing.position)
			if is_position_valid_for_item(thing.position, cur_room):
				call_deferred("add_child", thing)
				$"../CommandLine".command_history.append("Succesfully spawned " + thing.get_child(0).name)
				return true
		else:
			$"../CommandLine".command_history.append("no option found for entity request")
			print("no option found for entity request")
			return false
	else:
		$"../CommandLine".command_history.append("Entity requested does not exist")
		print("Entity requested does not exist")
		return false
	return false

func place_entity_in_random_room(entity: Node2D):
	var room = vec_map.values().filter(func(value): return value != null and value.room_name != "hallway").pick_random()
	# entity.position = Vector2i(0, 0)
	entity.position = get_random_position_in_room(room, entity.entity_size)
	entity.position.x = floor(entity.position.x / 16) * 16
	entity.position.y = floor(entity.position.y / 16) * 16
	call_deferred("add_child", entity)

# when the level is complete regenerate a new map
func regenerate_map() -> void:
	GameMaster.can_move = false
	# clear all children under map
	clear_map()
	# reset zoom and fog from possible map use
	GameMaster.DISABLE_FOG = false
	$"../Player".find_child("Camera2D").zoom = Vector2(3, 3)
	
	await get_tree().process_frame
	
	level += 1
	if level % 5 == 0:
		var boss_room_node = preload("res://Scenes/Rooms/boss_room.tscn").instantiate()
		add_child(boss_room_node)
		return
		
	
	map_width = BASE_MAP_SIZE + (level * MAP_GROWTH_RATE)
	map_height = BASE_MAP_SIZE + (level * MAP_GROWTH_RATE)
	
	rooms_to_generate = BASE_ROOMS + (level * ROOMS_GROWTH_RATE)
	
	# Scale spawn rates but cap them at 1.0 (100%)
	##-----(Scaleing Spawn Chances)-----##
	cave_enemy_spawn_chance = min(BASE_CAVE_ENEMY_SPAWN_CHANCE + (level * SPAWN_RATE_INCREMENT), 1.0)
	ice_enemy_spawn_chance = min(BASE_ICE_ENEMY_SPAWN_CHANCE + (level * SPAWN_RATE_INCREMENT), 1.0)
	rare_ice_enemy_spawn_chance = min(BASE_RARE_ENEMY_SPAWN_CHANCE + (level * SPAWN_RATE_INCREMENT), 1.0)
	boss_enemy_spawn_chance = min(BASE_BOSS_ENEMY_SPAWN_CHANCE + (level * SPAWN_RATE_INCREMENT), 1.0)
	big_ice_enemy_spawn_chance = min(BASE_BIG_ICE_ENEMY_SPAWN_CHANCE + (level * SPAWN_RATE_INCREMENT), 1.0)
	##-----(Scaleing Spawn Chances)-----##
	
	gold_spawn_chance = min(gold_spawn_chance + (level * SPAWN_RATE_INCREMENT), 1.0)
	melee_weapon_spawn_chance = min(melee_weapon_spawn_chance + (level * SPAWN_RATE_INCREMENT), 1.0)
	armor_spawn_chance = min(armor_spawn_chance + (level * SPAWN_RATE_INCREMENT), 1.0)
	potion_spawn_chance = min(potion_spawn_chance + (level * SPAWN_RATE_INCREMENT), 1.0)
	misc_spawn_chance = min(misc_spawn_chance + (level * SPAWN_RATE_INCREMENT), 1.0)
	
	# Increase enemy capacity per room
	##-----(Scaleing Max Enemies)-----##
	max_cave_enemies_per_room = BASE_CAVE_MAX_ENEMIES + (level * ENEMY_GROWTH_RATE)
	max_ice_enemies_per_room = BASE_ICE_MAX_ENEMIES + (level * ENEMY_GROWTH_RATE)
	max_rare_ice_enemies_per_room = BASE_RARE_ICE_MAX_ENEMIES + (level * ENEMY_GROWTH_RATE)
	#max_boss_enemies_per_room = BASE_BOSS_MAX_ENEMIES + (level * ENEMY_GROWTH_RATE)
	max_big_ice_enemies_per_room = BASE_RARE_ICE_MAX_ENEMIES + (level * ENEMY_GROWTH_RATE)
	##-----(Scaleing Max Enemies)-----##
	
	max_gold_per_room = BASE_MAX_GOLD + (level * ENEMY_GROWTH_RATE)
	max_melee_weapons_per_room = BASE_MAX_MELEE_WEAPONS + (level * ENEMY_GROWTH_RATE)
	max_armor_per_room = BASE_MAX_ARMOR + (level * ENEMY_GROWTH_RATE)
	max_potions_per_room = BASE_MAX_POTIONS + (level * ENEMY_GROWTH_RATE)
	max_misc_per_room = BASE_MAX_MISC + (level * ENEMY_GROWTH_RATE)
	
	# reset variables
	room_count = 0
	max_distance = -1
	rooms_instantiated = 0
	first_room_pos = Vector2.ZERO
	map = []
	room_grid = {}
	vec_map = {}
	
	for y in range(map_height):
		map.append([])
		for x in range(map_width):
			map[y].append(false)
			room_grid[Vector2(x, y)] = null
	generate(level)
	await get_tree().process_frame
	# move player to start position maybe need await for new tree before moving player
	$"../Player".global_position = (first_room_pos * (272)) + Vector2(80, 80)
	if GameMaster.DEBUG_MAP: 
		print("First room position (grid):", first_room_pos)
		print("Player global position:", $"../Player".global_position)
	GameMaster.can_move = true
