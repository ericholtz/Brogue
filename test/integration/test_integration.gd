extends GutTest

var bat_scene = load("res://Scenes/Enemies/Cave_Enemies/Bat.tscn")
var map_gen_script = load("res://Scripts/map_gen.gd")

var bat = null
var map_gen = null

func before_each():
	# Initialize
	#map_gen = map_gen_script.new()
	bat = bat_scene.instantiate()
	add_child(bat)

func after_each():
	# Clean up
	if bat:
		autofree(bat)
	autofree(map_gen)

func test_bat_spawns_on_map():
	# Ensure the bat spawns correctly on the map
	var spawn_position = Vector2(100, 100)
	bat.position = spawn_position
	# Check if the bat is in the correct position
	assert_eq(bat.position, spawn_position, "Bat should spawn at the correct position on the map")

func test_bat_movement_within_room():
	# Simulate the bat moving within a room
	var initial_position = bat.position
	var move_direction = Vector2(1, 0)  # Move right
	# Call the bat's move function
	await bat.move(move_direction)
	# Check if the bat moved correctly
	assert_almost_eq(bat.position.x, initial_position.x + 16, 0.1, "Bat should move 16 pixels to the right")
	assert_almost_eq(bat.position.y, initial_position.y, 0.1, "Bat should not move vertically")

func test_bat_player_detection():
	# Simulate the bat detecting the player
	var player = Node2D.new()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(50, 50)
	# Trigger the bat's area detection
	bat._on_area_2d_body_entered(player)
	# Check if the bat detected the player
	assert_eq(bat.player, player, "Bat should detect the player when they enter the area")
	# Clean up the player instance
	autofree(player)

func test_bat_player_lost():
	# Simulate the bat losing sight of the player
	var player = Node2D.new()
	player.name = "Player"
	add_child(player)
	player.position = Vector2(50, 50)
	# Trigger the bat's area detection and then exit
	bat._on_area_2d_body_entered(player)
	bat._on_area_2d_body_exited(player)
	# Check if the bat lost the player
	assert_null(bat.player, "Bat should lose the player when they exit the area")
	# Clean up the player instance
	autofree(player)
