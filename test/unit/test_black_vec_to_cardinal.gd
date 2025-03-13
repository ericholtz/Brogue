extends GutTest
# black box unit test #
var bat_script = load("res://Scripts/Monster_Scripts/bat.gd")
var bat = null

func before_each():
	# Set up each time
	bat = bat_script.new()

func after_each():
	# Clean up each time
	autofree(bat)

func test_zero_vector():
	# Setup
	var result = bat.vec_to_cardinal(Vector2.ZERO)
	# Test
	assert_eq(result, Vector2.ZERO, "Expected Return: Vector2.ZERO")

func test_horizontal_right():
	# Setup
	var right = Vector2.RIGHT
	var result_right = bat.vec_to_cardinal(right)
	# Test
	assert_eq(result_right, right, "Expected Return: Vector2.RIGHT")


func test_horizontal_left():
	# Setup
	var left = Vector2.LEFT
	var result_left = bat.vec_to_cardinal(left)
	# Test
	assert_eq(result_left, left, "Expected Return: Vector2.LEFT")

func test_vertical_up():
	# Setup
	var up = Vector2.UP
	var result_up = bat.vec_to_cardinal(up)
	# Test
	assert_eq(result_up, up, "Expected Return: Vector2.UP")

func test_vertical_down():
	# Setup
	var down = Vector2.DOWN
	var result_down = bat.vec_to_cardinal(down)
	# Test
	assert_eq(result_down, down, "Expected Return: Vector2.DOWN")

func test_diagonal_direction():
	# Setup
	var diagonal = Vector2(1, 1)
	var diagonal2 = Vector2(-1, 1)
	var diagonal3 = Vector2(1, -1)
	var diagonal4 = Vector2(-1, -1)
	var result = bat.vec_to_cardinal(diagonal)
	var result2 = bat.vec_to_cardinal(diagonal2)
	var result3 = bat.vec_to_cardinal(diagonal3)
	var result4 = bat.vec_to_cardinal(diagonal4)
	# Test
	assert_true(result == Vector2.RIGHT or result == Vector2.DOWN, "Expected Return: Vector2.RIGHT or Vector2.UP")
	assert_true(result2 == Vector2.LEFT or result2 == Vector2.DOWN, "Expected Return: Vector2.LEFT or Vector2.UP")
	assert_true(result3 == Vector2.RIGHT or result3 == Vector2.UP, "Expected Return: Vector2.RIGHT or Vector2.DOWN")
	assert_true(result4 == Vector2.LEFT or result4 == Vector2.UP, "Expected Return: Vector2.LEFT or Vector2.DOWN")
