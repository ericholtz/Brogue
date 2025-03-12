extends GutTest
# white box unit test #

# The tests here cover 
	# Being called when actively moving. 
	# Testing when random moving is disabled and enabled.
	# When the 2D area is exited or entered by the player.

# The test that were not covered
	# If the move was blocked by Collision or if the move was not blocked.

var bat_script = load("res://Scripts/Monster_Scripts/bat.gd")
var bat = null

func before_each():
	# Set up each time
	bat = bat_script.new()
	# Set up ray
	bat.Ray = RayCast2D.new()
	bat.Animations = AnimatedSprite2D.new()
	add_child(bat.Animations)
	add_child(bat.Ray)
	# Set up vars
	bat.Ray.enabled = true
	bat.tileSize = 16
	bat.animationSpeed = 18
	bat.Movement_Speed = 2
	bat.player = null

func after_each():
	# Clean up each time
	autofree(bat.Ray)
	autofree(bat.Animations)
	autofree(bat)

func test_moveing():
	# Setup: Moveing
	var moving = true
	var result = bat.take_turn()
	# Test
	assert_eq(result, null, "Expected Return: null")

func test_random_move_disabled():
	# Setup: No player and random move disabled
	GameMaster.DEBUG_RANDMOVE = false
	bat.take_turn()
	# Assertions
	assert_false(bat.moving, "Expected Return: Bat should not move")

func test_random_move_enabled():
	# Setup: No player and random move enabled
	GameMaster.DEBUG_RANDMOVE = true
	bat.take_turn()
	# Assertions
	assert_true(bat.moving, "Expected Return: Bat should attempt to move randomly")

func test_on_area_2d_entered():
	# Setup: Simulate player entering the area
	var player = Node2D.new()
	player.name = "Player"
	# Call
	bat._on_area_2d_body_entered(player)
	# Assertions
	assert_eq(bat.player, player, "Expected Return: Player should be set when entering the area")
	autofree(bat.player)

func test_on_area_2d_exited():
	# Setup: Simulate player exiting the area
	var player = Node2D.new()
	player.name = "Player"
	bat.player = player
	# Call
	bat._on_area_2d_body_exited(player)
	# Assertions
	assert_eq(bat.player, null, "Expected Return: Player should be null when exiting the area")
	autofree(player)
