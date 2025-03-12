extends GutTest
# Integration test #
var bat_scene = load("res://Scenes/Enemies/Cave_Enemies/Bat.tscn")
var map_gen_script = load("res://Scripts/map_gen.gd")

var bat = null
var map_gen = null

func before_each():
	# Initialize
	bat = bat_scene.instantiate()
	add_child(bat)

func after_each():
	# Clean up
	if bat:
		autofree(bat)
	autofree(map_gen)

func test_bat_spawns():
	# Simulate: spawns correctly
	var spawn_position = Vector2(100, 100)
	bat.position = spawn_position
	# Check if correct position
	assert_eq(bat.position, spawn_position, "Expected Return: Spawn at map 100, 100")

func test_bat_movement():
	# Simulate: moving within room
	var initial_position = bat.position
	var move_direction = Vector2(1, 0)
	# move 
	await bat.move(move_direction)
	# Test if moved correctly
	assert_almost_eq(bat.position.x, initial_position.x + 16, 0.1, "Expected Return: Move 16 right")
	assert_almost_eq(bat.position.y, initial_position.y, 0.1, "Expected Return: Should not move vertically")

func test_bat_player_detection():
	# Simulate: detecting the player
	var player = Node2D.new()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(50, 50)
	# Trigger area detection
	bat._on_area_2d_body_entered(player)
	# Test if detected player
	assert_eq(bat.player, player, "Expected Return: Detect player on entering area")
	# Clean up
	autofree(player)

func test_bat_player_detection_lost():
	# Simulate: losing sight of the player
	var player = Node2D.new()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(50, 50)
	# Trigger area detection
	bat._on_area_2d_body_entered(player)
	bat._on_area_2d_body_exited(player)
	# Test if lost player
	assert_null(bat.player, "Expected Return: Lose player on exit area")
	# Clean up
	autofree(player)
